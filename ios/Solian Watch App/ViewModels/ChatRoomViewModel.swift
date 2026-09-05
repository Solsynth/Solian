import Combine
import Foundation

/// Raised when the server returns messages but none could be decoded.
enum ChatDecodeError: LocalizedError {
    case allMessagesUndecodable(total: Int)

    var errorDescription: String? {
        switch self {
        case .allMessagesUndecodable(let total):
            return "Messages couldn't be read (the server returned \(total), but none matched the expected format)."
        }
    }
}

/// State for one chat room's timeline + composer, mirroring Flutter's
/// `ChatRoomState` / `MessagesNotifier` behaviors that matter on a watch:
/// paginated load, real-time append, and send-with-optimistic-insert.
@MainActor
final class ChatRoomViewModel: ObservableObject {
    @Published private(set) var messages: [SnChatMessage] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMore = false
    @Published private(set) var totalCount = 0
    @Published private(set) var errorMessage: String?
    @Published private(set) var wsState: WebSocketState = .disconnected
    @Published var draft = ""
    @Published private(set) var isSending = false
    @Published private(set) var identity: SnChatMember?
    /// Resolved quoted/forwarded message content, keyed by message id.
    /// Mirrors Flutter's `referencedChatMessageCacheProvider`.
    @Published private(set) var referencedMessages: [String: SnChatMessage] = [:]
    /// Where the view should scroll after the next `messages` mutation:
    /// `.bottom` for new arrivals, `.top` after loading older.
    @Published private(set) var lastScrollTarget: ScrollTarget = .bottom

    /// Sending status per message id. Rows with `.pending` show a translucent
    /// bubble + spinner; `.failed` shows an error mark. Confirmed rows are absent.
    @Published private(set) var messageStatus: [String: MessageSendStatus] = [:]

    /// Messages received while this room was closed (not from self), i.e. the
    /// live unread count. Reset to 0 when the room is opened.
    @Published private(set) var unreadCount = 0

    enum MessageSendStatus: Equatable {
        case pending
        case failed
    }

    enum ScrollTarget: Equatable {
        case bottom
        case top
    }

    let room: SnChatRoom
    private let appState: AppState
    private let chatCache: ChatCache
    private let pageSize = 20
    private var hasLoaded = false
    /// Raw rows fetched so far (before displayable filtering). The server pages
    /// newest-first (offset 0 = newest), so pagination advances on the number
    /// of rows consumed, not the filtered display count.
    private var fetchedRowCount = 0
    private var pendingFetches = Set<String>()
    private var cancellables = Set<AnyCancellable>()

    init(room: SnChatRoom, appState: AppState, chatCache: ChatCache) {
        self.room = room
        self.appState = appState
        self.chatCache = chatCache
        observeWebSocket()
        // Seed the timeline from cache for instant/offline rendering.
        self.messages = chatCache.loadMessages(roomId: room.id)
    }

    /// True when a message was sent by the current user (used to render own
    /// vs other bubbles and to align them right).
    func isOwnMessage(_ message: SnChatMessage) -> Bool {
        if let identity = identity {
            return identity.id == message.senderId
        }
        return message.senderId == appState.currentAccountId
    }

    // MARK: - Loading

    /// Tear down WebSocket subscriptions when the view goes away.
    func stop() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func loadInitial() async {
        guard !hasLoaded, !isLoading else { return }

        // Wait for credentials to be ready. The first `.task` often runs before
        // the token/serverUrl are set (phone sync / token refresh in flight),
        // which is why an immediate fetch fails and a manual Retry succeeds.
        // Cap the wait so we never spin forever if auth is unavailable.
        var waitCount = 0
        while appState.token == nil || appState.serverUrl == nil {
            guard waitCount < 24 else { return } // max ~6s
            try? await Task.sleep(for: .milliseconds(250))
            if Task.isCancelled { return }
            waitCount += 1
        }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Retry transient failures with short backoff (up to a few attempts).
        let attempts = 3
        for attempt in 0..<attempts {
            do {
                async let identity = loadIdentity(token: token, serverUrl: serverUrl)
                let result = try await appState.networkService.fetchChatMessages(
                    chatRoomId: room.id,
                    token: token,
                    serverUrl: serverUrl,
                    offset: 0,
                    take: pageSize
                )
                self.identity = try? await identity
                let displayable = result.messages.filter(\.isDisplayable)
                // If the server reported messages but none decodable, surface a
                // decode error rather than a misleading empty timeline.
                if displayable.isEmpty && result.totalCount > 0 {
                    throw ChatDecodeError.allMessagesUndecodable(total: result.totalCount)
                }
                self.messages = displayable.sorted { $0.createdAt < $1.createdAt }
                self.fetchedRowCount = result.messages.count
                self.totalCount = result.totalCount
                self.hasMore = result.hasMore
                // Opening the room clears its unread count.
                self.unreadCount = 0
                hasLoaded = true
                persist()
                return
            } catch {
                if attempt == attempts - 1 {
                    // Last attempt failed. Keep any cached content visible;
                    // only show a retry when there's genuinely nothing to show.
                    if messages.isEmpty {
                        errorMessage = error.localizedDescription
                    }
                } else {
                    try? await Task.sleep(for: .milliseconds(500 * (attempt + 1)))
                }
            }
        }
    }

    /// Persists the current timeline + room summary to the SwiftData cache.
    private func persist() {
        chatCache.saveMessages(roomId: room.id, messages)
        chatCache.updateRoomSummary(roomId: room.id, summary: currentSummary)
    }

    /// Last displayable message + live unread count for this room.
    private var currentSummary: ChatSummary {
        ChatSummary(lastMessage: messages.last, unreadCount: unreadCount)
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            // Offset advances on raw rows consumed (newest-first paging), so
            // consecutive pages don't overlap after displayable filtering.
            let result = try await appState.networkService.fetchChatMessages(
                chatRoomId: room.id,
                token: token,
                serverUrl: serverUrl,
                offset: fetchedRowCount,
                take: pageSize
            )
            let existing = Set(messages.map(\.id))
            let older = result.messages
                .filter(\.isDisplayable)
                .filter { !existing.contains($0.id) }
            self.fetchedRowCount += result.messages.count
            guard !older.isEmpty else {
                self.totalCount = result.totalCount
                self.hasMore = result.hasMore
                return
            }
            // Older rows go to the TOP of the list (newest-first timeline).
            self.messages = (older + self.messages)
                .sorted { $0.createdAt < $1.createdAt }
            self.lastScrollTarget = .top
            self.totalCount = result.totalCount
            self.hasMore = result.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadIdentity(token: String, serverUrl: String) async throws -> SnChatMember? {
        try? await appState.networkService.fetchChatIdentity(
            chatRoomId: room.id,
            token: token,
            serverUrl: serverUrl
        )
    }

    /// Resolves a quoted/forwarded message's content from cache or network.
    /// Guards against duplicate in-flight fetches (Flutter's
    /// `ReferencedChatMessageCache.resolve`).
    func resolveReferencedMessage(_ messageId: String) async {
        guard !pendingFetches.contains(messageId), referencedMessages[messageId] == nil,
              let token = appState.token, let serverUrl = appState.serverUrl else { return }
        pendingFetches.insert(messageId)
        defer { pendingFetches.remove(messageId) }

        do {
            if let msg = try await appState.networkService.fetchChatMessage(
                byId: messageId,
                chatRoomId: room.id,
                token: token,
                serverUrl: serverUrl
            ) {
                referencedMessages[messageId] = msg
            }
        } catch {
            // Best-effort; leave unresolved so the quote shows its fallback.
        }
    }

    /// Whether the message has been edited (visible "Edited" meta).
    func isEdited(_ message: SnChatMessage) -> Bool {
        message.editedAt != nil
    }

    // MARK: - Sending

    private var lastTypingSentAt: Date?

    /// Throttled typing indicator (850ms cooldown, matching Flutter's
    /// `_typingSendCooldown`). Returns the exact key the view binds to draft.
    func typingChanged(to text: String) {
        guard !text.isEmpty else { return }
        let now = Date()
        if let last = lastTypingSentAt, now.timeIntervalSince(last) < 0.85 { return }
        lastTypingSentAt = now
        appState.networkService.sendTypingStatus(chatRoomId: room.id)
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending,
              let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isSending = true

        // Optimistic pending message (Flutter's `pending_<uuid>`). Inserted
        // immediately, rendered translucent + spinner, replaced on ack.
        let pendingId = "pending_\(UUID().uuidString)"
        let clientMessageId = UUID().uuidString
        let pending = SnChatMessage(
            id: pendingId,
            type: "text",
            content: text,
            clientMessageId: clientMessageId,
            nonce: nil,
            meta: [:],
            membersMentioned: [],
            editedAt: nil,
            attachments: [],
            reactions: [],
            repliedMessageId: nil,
            forwardedMessageId: nil,
            senderId: identity?.id ?? appState.currentAccountId ?? "",
            sender: identity ?? .fallback,
            chatRoomId: room.id,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
        messages.append(pending)
        messageStatus[pendingId] = .pending
        lastScrollTarget = .bottom
        draft = ""

        do {
            let sent = try await appState.networkService.sendChatMessage(
                chatRoomId: room.id,
                content: text,
                clientMessageId: clientMessageId,
                token: token,
                serverUrl: serverUrl
            )
            // Replace the optimistic row with the server-confirmed message.
            if let index = messages.firstIndex(where: { $0.id == pendingId }) {
                messages[index] = sent
                messageStatus.removeValue(forKey: pendingId)
                updateReferencedCacheIfNeeded(sent)
            } else if sent.isDisplayable, !messages.contains(where: { $0.id == sent.id }) {
                messages.append(sent)
            }
            persist()
        } catch {
            print("[ChatRoomViewModel] send - failed: \(error.localizedDescription)")
            messageStatus[pendingId] = .failed
        }
        isSending = false
    }

    /// Keeps referenced (quote/forward) cache coherent when a confirmed message
    /// replaces a pending one.
    private func updateReferencedCacheIfNeeded(_ message: SnChatMessage) {
        if let quotedId = message.repliedMessageId, referencedMessages[quotedId] == nil {
            Task { await resolveReferencedMessage(quotedId) }
        }
    }

    // MARK: - WebSocket

    private func observeWebSocket() {
        appState.networkService.packetStream
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] packet in
                self?.handle(packet)
            })
            .store(in: &cancellables)

        appState.networkService.stateStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.wsState = state
            }
            .store(in: &cancellables)
    }

    private func handle(_ packet: WebSocketPacket) {
        guard ["messages.new", "messages.update", "messages.delete"].contains(packet.type),
              let data = packet.data else { return }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("[ChatRoomViewModel] handle - could not serialize packet data")
            return
        }
        let decoder = makeDecoder()
        let message: SnChatMessage
        do {
            message = try decoder.decode(SnChatMessage.self, from: jsonData)
        } catch {
            print("[ChatRoomViewModel] handle - decode failed: \(error)")
            return
        }

        guard message.chatRoomId == room.id else { return }

        switch packet.type {
        case "messages.new":
            // If a pending optimistic row for this client_message_id exists,
            // replace it with the server-confirmed message (Flutter's ack path).
            let pending = messages.first {
                $0.id.hasPrefix("pending_") && $0.clientMessageId == message.clientMessageId
            }
            if let pending = pending {
                if let index = messages.firstIndex(where: { $0.id == pending.id }) {
                    messages[index] = message
                    messageStatus.removeValue(forKey: pending.id)
                    messageStatus.removeValue(forKey: message.id)
                    lastScrollTarget = .bottom
                }
            } else if message.isDisplayable,
                      !messages.contains(where: { $0.id == message.id }) {
                messages.append(message)
                lastScrollTarget = .bottom
            }
            appState.networkService.sendReadReceipt(chatRoomId: room.id)
        case "messages.update":
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index] = message
            }
            persist()
        case "messages.delete":
            messages.removeAll { $0.id == message.id }
            persist()
        default:
            break
        }
        // Persist after any live mutation that changed the list.
        if packet.type == "messages.new", chatCache.isAvailable {
            persist()
        }
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
