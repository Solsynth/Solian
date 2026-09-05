import Combine
import Foundation

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
    private let pageSize = 20
    private var hasLoaded = false
    /// Raw rows fetched so far (before displayable filtering). The server pages
    /// newest-first (offset 0 = newest), so pagination advances on the number
    /// of rows consumed, not the filtered display count.
    private var fetchedRowCount = 0
    private var pendingFetches = Set<String>()
    private var cancellables = Set<AnyCancellable>()

    init(room: SnChatRoom, appState: AppState) {
        self.room = room
        self.appState = appState
        observeWebSocket()
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
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

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
            self.messages = result.messages
                .filter(\.isDisplayable)
                .sorted { $0.createdAt < $1.createdAt }
            self.fetchedRowCount = result.messages.count
            self.totalCount = result.totalCount
            self.hasMore = result.hasMore
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
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
        case "messages.delete":
            messages.removeAll { $0.id == message.id }
        default:
            break
        }
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
