//
//  ChatView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/30.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var summaryStore: ChatSummaryStore
    @Environment(\.chatCache) private var chatCache
    @State private var selectedTab = 0
    @State private var chatRooms: [SnChatRoom] = []
    @State private var chatInvites: [SnChatMember] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingInvites = false
    @State private var liveCancellable: AnyCancellable?
    /// The room-list load. Stored (not `.task`) so it isn't cancelled when the
    /// view disappears (panel switch), which left the list empty.
    @State private var loadTask: Task<Void, Never>?

    private let tabs = ["All", "Direct", "Group"]

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<tabs.count, id: \.self) { index in
                VStack {
                    if isLoading {
                        ProgressView()
                    } else if error != nil {
                        VStack {
                            Text("Error loading chats")
                                .font(.caption)
                            Button("Retry") {
                                Task {
                                    await loadChatRooms()
                                }
                            }
                            .font(.caption2)
                        }
                    } else {
                        ChatRoomListView(
                            chatRooms: filteredChatRooms(for: index),
                            selectedTab: index,
                            summaries: summaryStore.roomSummaries
                        )
                    }
                }
                .tabItem {
                    Text(tabs[index])
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInvites = true
                } label: {
                    ZStack {
                        Image(systemName: "envelope")
                        if !chatInvites.isEmpty {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingInvites) {
            ChatInvitesView(invites: $chatInvites, appState: appState)
        }
        .onAppear {
            // Seed the room list from cache immediately (offline/instant).
            loadCachedRooms()
            summaryStore.loadCached()
            if liveCancellable == nil {
                liveCancellable = summaryStore.observeLiveMessages()
            }
            // Launch the network loads in a stored task so switching panels
            // can't cancel them mid-flight (which left the list empty).
            if loadTask == nil || loadTask?.isCancelled == true {
                loadTask = Task { @MainActor in
                    await loadChatRooms()
                    await loadChatSummaries()
                    await loadChatInvites()
                }
            }
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
            liveCancellable?.cancel()
            liveCancellable = nil
        }
    }

    /// Seeds the room list from the SwiftData cache immediately (offline /
    /// instant launch). Overwritten by a successful network fetch.
    private func loadCachedRooms() {
        guard !isLoading else { return }
        let cached = chatCache.loadRooms()
        guard !cached.isEmpty else { return }
        chatRooms = cached.map(\.room)
        summaryStore.loadCached()
    }

    private func filteredChatRooms(for tabIndex: Int) -> [SnChatRoom] {
        switch tabIndex {
        case 0: // All
            return chatRooms
        case 1: // Direct
            return chatRooms.filter { $0.type == 1 }
        case 2: // Group
            return chatRooms.filter { $0.type != 1 }
        default:
            return chatRooms
        }
    }

    private func loadChatRooms() async {
        // Await credentials (the first `.task` can run before auth resolves).
        while appState.token == nil || appState.serverUrl == nil {
            try? await Task.sleep(for: .milliseconds(250))
            if Task.isCancelled { return }
        }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        
        print("[ChatView] loadChatRooms - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        isLoading = true
        error = nil
        // Always clear `isLoading` — including on cancellation — otherwise the
        // spinner spins forever after a panel-switch cancels the task.
        defer { isLoading = false }

        do {
            let response = try await appState.networkService.fetchChatRooms(token: token, serverUrl: serverUrl)
            chatRooms = response.rooms
            // Persist rooms + seed summaries (unread=0 until a summary arrives).
            chatCache.saveRooms(response.rooms)
            for room in response.rooms where summaryStore.summary(for: room.id) == nil {
                summaryStore.apply([room.id: SnChatSummary(unreadCount: 0, lastMessage: nil)])
            }
            print("[ChatView] loadChatRooms - success, rooms: \(chatRooms.count)")
        } catch is CancellationError {
            // View teardown cancelled the task — never surface as an error.
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch let decodingError as DecodingError {
            print("[ChatView] loadChatRooms - decoding error: \(decodingError)")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("  Key '\(key.stringValue)' not found. Debug: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("  Type mismatch: \(type). Debug: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("  Value not found: \(type). Debug: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("  Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("  Unknown decoding error")
            }
            // If we already have cached rooms, don't surface the error — show
            // the offline list instead.
            self.error = chatRooms.isEmpty ? decodingError : nil
        } catch {
            print("[ChatView] loadChatRooms - error: \(error.localizedDescription)")
            self.error = chatRooms.isEmpty ? error : nil
        }
    }

    private func loadChatInvites() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        do {
            let response = try await appState.networkService.fetchChatInvites(token: token, serverUrl: serverUrl)
            chatInvites = response.invites
        } catch {
            // Handle error silently for invites
        }
    }

    /// Loads per-room summaries (unread + last message) and refreshes the room
    /// list previews. Falls back to cached summaries on failure.
    private func loadChatSummaries() async {
        while appState.token == nil || appState.serverUrl == nil {
            try? await Task.sleep(for: .milliseconds(250))
            if Task.isCancelled { return }
        }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        do {
            let summaries = try await appState.networkService.fetchChatSummary(token: token, serverUrl: serverUrl)
            summaryStore.apply(summaries)
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            // Fall back to summaries already loaded from cache by loadCachedRooms.
            print("[ChatView] loadChatSummaries - failed: \(error.localizedDescription)")
        }
    }
}

struct ChatRoomListView: View {
    let chatRooms: [SnChatRoom]
    let selectedTab: Int
    var summaries: [String: ChatSummary] = [:]

    var body: some View {
        if chatRooms.isEmpty {
            VStack {
                Image(systemName: "message")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("No chats yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            List(chatRooms) { room in
                ChatRoomListItem(room: room, summary: summaries[room.id])
            }
            .listStyle(.plain)
        }
    }
}

struct ChatRoomListItem: View {
    let room: SnChatRoom
    var summary: ChatSummary?
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var summaryStore: ChatSummaryStore
    @Environment(\.chatCache) private var chatCache
    @StateObject private var avatarLoader = ImageLoader()

    private var displayName: String {
        if room.type == 1, let members = room.members, !members.isEmpty, let account = members[0].account {
            // For direct messages, show the other member's display name
            // (nick first, then account name), matching Flutter's getRoomTitle.
            if !account.nick.isEmpty { return account.nick }
            if !account.name.isEmpty { return account.name }
            return "Direct Message"
        } else {
            // For group chats, show room name or fallback
            return room.name ?? "Group Chat"
        }
    }

    private var subtitle: String {
        if room.type == 1, let members = room.members, members.count > 1 {
            // For direct messages, show member usernames
            return members.compactMap { $0.account?.name }.map { "@\($0)" }.joined(separator: ", ")
        } else if let description = room.description {
            // For group chats with description
            return description
        } else {
            // Fallback
            return ""
        }
    }

    private var avatarPictureId: String? {
        if room.type == 1, let members = room.members, !members.isEmpty, let account = members[0].account {
            // For direct messages, use the other member's avatar
            return account.profile?.picture?.id
        } else {
            // For group chats, use room picture
            return room.picture?.id
        }
    }

    /// `<sender>: <msg>` preview from the summary's last message, falling back
    /// to the room description when no summary has arrived yet.
    private var lastMessagePreview: String {
        guard let last = summary?.lastMessage else { return subtitle }
        let sender = last.sender.displayName
        let content = last.content?.isEmpty == false ? last.content! : "Attachment"
        return "\(sender): \(content)"
    }

    /// Short relative timestamp like `1d`, `2h`, `10m`, `now` for the last
    /// message, shown at the row's trailing edge.
    private var relativeTimeText: String {
        guard let date = summary?.lastMessage?.createdAt else { return "" }
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        if days < 7 { return "\(days)d" }
        return ""
    }

    var body: some View {
        NavigationLink(
            destination: ChatRoomView(room: room, appState: appState, chatCache: chatCache)
                .environmentObject(appState)
                .environmentObject(summaryStore)
        ) {
            HStack {
                // Avatar using ImageLoader pattern
                Group {
                    if avatarLoader.isLoading {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    } else if let image = avatarLoader.image {
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } else if avatarLoader.errorMessage != nil {
                        // Error state - show fallback
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            )
                    } else {
                        // No image available - show initial
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            )
                    }
                }
                .task(id: avatarPictureId) {
                    if let serverUrl = appState.serverUrl,
                       let pictureId = avatarPictureId,
                       let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
                       let token = appState.token {
                        await avatarLoader.loadImage(from: imageUrl, token: token)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    // `<sender>: <msg>` preview. One line, truncated.
                    Text(lastMessagePreview)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // Short relative time (e.g. `1d`, `2h`, `10m`).
                    if !relativeTimeText.isEmpty {
                        Text(relativeTimeText)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    if let summary = summary, summary.unreadCount > 0 {
                        // Cap at "99+" so a 3+ digit count never bloats the capsule.
                        let label = summary.unreadCount > 99 ? "99+" : "\(summary.unreadCount)"
                        Text(label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.red, in: Capsule())
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

import Combine
import SwiftUI
import WatchKit

struct ChatRoomView: View {
    let room: SnChatRoom
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var summaryStore: ChatSummaryStore
    @Environment(\.chatCache) private var chatCache
    @StateObject private var viewModel: ChatRoomViewModel

    init(room: SnChatRoom, appState: AppState, chatCache: ChatCache) {
        self.room = room
        // `appState`/`chatCache` construct the ViewModel; the view reads them
        // via @EnvironmentObject / @Environment as usual.
        self._viewModel = .init(wrappedValue: ChatRoomViewModel(room: room, appState: appState, chatCache: chatCache))
    }

    @State private var showComposer = false

    var body: some View {
        messageList
            .navigationTitle(room.name ?? "Chat")
            .task {
                // Opening the room marks it read (clears unread).
                summaryStore.markRead(room.id)
                await viewModel.loadInitial()
            }
            .onDisappear {
                viewModel.stop()
            }
            .sheet(isPresented: $showComposer) {
                ComposeMessageView(viewModel: viewModel)
            }
    }

    // MARK: - Message list

    /// The whole chat surface is one scrollable section: message groups plus a
    /// trailing compose footer, so the composer scrolls with the timeline
    /// rather than being pinned as a separate bar.
    @ViewBuilder
    private var messageList: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            VStack {
                Text(error)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") {
                    Task { await viewModel.loadInitial() }
                }
                .font(.caption2)
            }
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if viewModel.messages.isEmpty {
                            emptyState
                        } else {
                            // Older messages are prepended at the top, so the
                            // pagination trigger belongs at the head.
                            if viewModel.hasMore {
                                Button("Load older") {
                                    Task { await viewModel.loadMore() }
                                }
                                .id("load-older")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            ForEach(Array(groupedMessages.enumerated()), id: \.offset) { _, group in
                                MessageGroupView(group: group, isOwn: isOwnGroup(group), viewModel: viewModel)
                                    .environmentObject(appState)
                            }
                        }
                        composeFooter
                            .id("compose-footer")
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                }
                .onAppear { scrollToLatest(proxy) }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if viewModel.lastScrollTarget == .top {
                        scrollToTop(proxy)
                    } else {
                        scrollToLatest(proxy)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No messages yet")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    /// Trailing compose affordance at the bottom of the scroll — opens the
    /// message sheet. Scrolls into view with the timeline.
    private var composeFooter: some View {
        Button {
            WKInterfaceDevice.current().play(.click)
            showComposer = true
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 17, weight: .medium))
                Text("Message")
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.18))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Compose a message")
        .padding(.vertical, 8)
    }

    private func scrollToLatest(_ proxy: ScrollViewProxy) {
        withAnimation { proxy.scrollTo("compose-footer", anchor: .bottom) }
    }

    private func scrollToTop(_ proxy: ScrollViewProxy) {
        withAnimation { proxy.scrollTo("load-older", anchor: .top) }
    }

    /// Groups consecutive same-sender messages within a 3-minute window, at
    /// which point a fresh bubble is started (matches Flutter's grouping).
    private var groupedMessages: [[SnChatMessage]] {
        var groups: [[SnChatMessage]] = []
        for message in viewModel.messages {
            if let last = groups.last?.last,
               last.senderId == message.senderId,
               message.createdAt.timeIntervalSince(last.createdAt) <= 180 {
                groups[groups.count - 1].append(message)
            } else {
                groups.append([message])
            }
        }
        return groups
    }

    /// Whether the whole group (same sender) is the current user's.
    private func isOwnGroup(_ group: [SnChatMessage]) -> Bool {
        guard let first = group.first else { return false }
        return viewModel.isOwnMessage(first)
    }
}

// MARK: - Compose

/// Full composer presented as a sheet. The inline bar in the timeline is
/// compact; typing happens here where there's room for a real input.
struct ComposeMessageView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            // No manual background/capsule — let watchOS render its native
            // field chrome cleanly. Auto-focus opens the system text input
            // (dictation/scribble) the moment the sheet appears.
            TextField("Message", text: $viewModel.draft, axis: .vertical)
                .font(.system(size: 15))
                .lineLimit(1...4)
                .foregroundStyle(.primary)
                .disableAutocorrection(true)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit { send() }
                .onChange(of: viewModel.draft) { _, newValue in
                    viewModel.typingChanged(to: newValue)
                }

            Button {
                send()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isSending {
                        ProgressView()
                            .frame(width: 14, height: 14)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 18))
                    }
                    Text(viewModel.isSending ? "Sending…" : "Send")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Color.accentColor.opacity(0.9))
                .clipShape(Capsule())
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || viewModel.isSending)
            .accessibilityLabel("Send message")
        }
        .padding()
        .onAppear {
            // Open the watchOS keyboard text-input immediately.
            isFocused = true
        }
    }

    private func send() {
        WKInterfaceDevice.current().play(.click)
        Task {
            await viewModel.send()
            if viewModel.draft.isEmpty {
                dismiss()
            }
        }
    }
}

// MARK: - Window Controls


/// Renders a sender-grouped run of messages as chat bubbles, aligning own
/// messages to the right and others to the left — the watch-appropriate
/// interpretation of Flutter's bubble layout.
///
/// Card layout per group: a header row (avatar left, username+datetime beside
/// it) for the first message, then full-width body boxes below. Continuation
/// messages in the group render as body boxes only (no repeated header) to
/// save space. Own groups are right-aligned with an accent body and no avatar.
struct MessageGroupView: View {
    let group: [SnChatMessage]
    let isOwn: Bool
    @ObservedObject var viewModel: ChatRoomViewModel
    @EnvironmentObject var appState: AppState

    private var first: SnChatMessage { group[0] }
    private var avatarPictureId: String? {
        first.sender.account?.profile?.picture?.id
    }
    /// The in-chat / realm nick (member `nick`) takes precedence, matching the
    /// quoted-message rendering and Flutter's sender-name derivation.
    private var senderName: String {
        first.sender.displayName
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 6) {
            if isOwn {
                Spacer(minLength: 28)
                Text(first.createdAt, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            } else {
                AvatarView(name: senderName, pictureId: avatarPictureId, size: 22)
                    .environmentObject(appState)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(senderName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(first.createdAt, style: .time)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 28)
            }
        }
    }

    var body: some View {
        VStack(alignment: isOwn ? .trailing : .leading, spacing: 3) {
            header
            ForEach(group) { message in
                MessageBubbleView(message: message, isOwn: isOwn, viewModel: viewModel)
                    .environmentObject(appState)
            }
        }
        .frame(maxWidth: .infinity, alignment: isOwn ? .trailing : .leading)
        .padding(.vertical, 2)
    }
}

/// A single message body box — full-width under the header. Own messages use a
/// tinted (accent) background and right alignment; others a neutral surface.
/// Renders quote/forward references and the "Edited" meta when present.
struct MessageBubbleView: View {
    let message: SnChatMessage
    let isOwn: Bool
    @ObservedObject var viewModel: ChatRoomViewModel
    @EnvironmentObject var appState: AppState

    private var bubbleColor: Color {
        // Pending messages render semi-transparent (Flutter's optimistic state).
        if status == .pending {
            return (isOwn ? Color.accentColor : Color.gray)
                .opacity(isOwn ? 0.4 : 0.2)
        }
        return isOwn ? Color.accentColor.opacity(0.85) : Color.gray.opacity(0.16)
    }
    private var textColor: Color {
        isOwn ? .white : .primary
    }
    private var status: ChatRoomViewModel.MessageSendStatus? {
        viewModel.messageStatus[message.id]
    }

    var body: some View {
        if message.isDeletedRow {
            // Deleted messages collapse to an inline system row, not a bubble.
            HStack(spacing: 4) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                Text(message.content?.isEmpty == false ? message.content! : "Deleted a message")
                    .font(.system(size: 11, weight: .medium))
                    .italic()
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: isOwn ? .trailing : .leading)
            .padding(.vertical, 2)
        } else {
            VStack(alignment: isOwn ? .trailing : .leading, spacing: 2) {
                if let quotedId = message.repliedMessageId {
                    QuoteReferenceView(messageId: quotedId, isReply: true, viewModel: viewModel)
                } else if let forwardedId = message.forwardedMessageId {
                    QuoteReferenceView(messageId: forwardedId, isReply: false, viewModel: viewModel)
                }
                if let content = message.content, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !message.attachments.isEmpty {
                    ForEach(message.attachments.prefix(2)) { attachment in
                        AttachmentView(attachment: attachment, isCompact: true)
                            .environmentObject(appState)
                    }
                    if message.attachments.count > 2 {
                        Label("\(message.attachments.count - 2)+ more", systemImage: "paperclip")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                statusFooter
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bubbleColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundColor(textColor)
            .opacity(status == .pending ? 0.9 : 1.0)
            .frame(maxWidth: .infinity, alignment: isOwn ? .trailing : .leading)
        }
    }

    /// Status footer: a spinner while pending, an error mark on failure,
    /// "edited" for edited messages (Flutter's MessageIndicators).
    @ViewBuilder
    private var statusFooter: some View {
        switch status {
        case .pending:
            HStack(spacing: 4) {
                ProgressView()
                    .controlSize(.mini)
                Text("Sending…")
                    .font(.system(size: 9))
                    .foregroundColor(textColor.opacity(0.8))
            }
        case .failed:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                Text("Failed")
                    .font(.system(size: 9))
                    .foregroundColor(.red)
            }
        case nil:
            if viewModel.isEdited(message) {
                Text("edited")
                    .font(.system(size: 10))
                    .foregroundColor(textColor.opacity(0.7))
            }
        }
    }
}

/// Compact inline quote/forward reference. Fetches the referenced content via
/// the ViewModel cache on first appearance (Flutter's `MessageQuoteWidget`).
struct QuoteReferenceView: View {
    let messageId: String
    let isReply: Bool
    @ObservedObject var viewModel: ChatRoomViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let quoted = viewModel.referencedMessages[messageId] {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: isReply ? "arrowshape.turn.up.left" : "arrowshape.turn.up.right")
                        .font(.system(size: 10))
                    Text(isReply ? "Replied to \(quoted.sender.displayName)" : "Forwarded from \(quoted.sender.displayName)")
                        .font(.system(size: 10, weight: .semibold))
                        .lineLimit(1)
                }
                if let content = quoted.content, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 11))
                        .lineLimit(2)
                        .foregroundColor(.primary.opacity(0.85))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            // Placeholder while resolving — shows a compact affordance.
            HStack(spacing: 4) {
                Image(systemName: isReply ? "arrowshape.turn.up.left" : "arrowshape.turn.up.right")
                    .font(.system(size: 10))
                Text(isReply ? "Replied to a message" : "Forwarded message")
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .task(id: messageId) {
                await viewModel.resolveReferencedMessage(messageId)
            }
        }
    }
}

/// Reusable circular avatar with the sender's initial fallback.
struct AvatarView: View {
    let name: String
    let pictureId: String?
    let size: CGFloat
    @EnvironmentObject var appState: AppState
    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if loader.isLoading {
                ProgressView()
                    .frame(width: size, height: size)
            } else if let image = loader.image {
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(name.prefix(1))
                            .font(.system(size: size * 0.45, weight: .medium))
                            .foregroundColor(.primary)
                    )
            }
        }
        .task(id: pictureId) {
            if let serverUrl = appState.serverUrl,
               let pictureId = pictureId,
               let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
               let token = appState.token {
                await loader.loadImage(from: imageUrl, token: token)
            }
        }
    }
}

struct ChatInvitesView: View {
    @Binding var invites: [SnChatMember]
    let appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if invites.isEmpty {
                    VStack {
                        Image(systemName: "envelope.open")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No invites")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(invites) { invite in
                        ChatInviteItem(invite: invite, appState: appState, invites: $invites)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Invites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatInviteItem: View {
    let invite: SnChatMember
    let appState: AppState
    @Binding var invites: [SnChatMember]
    @State private var isAccepting = false
    @State private var isDeclining = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text((invite.chatRoom?.name ?? "C").prefix(1).uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(invite.chatRoom?.name ?? "Unknown Chat")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        let roleValue = invite.role ?? 0
                        Text(roleValue == 100 ? "Owner" : roleValue >= 50 ? "Moderator" : "Member")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        if invite.chatRoom?.type == 1 {
                            Text("Direct")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Button {
                    Task {
                        await acceptInvite()
                    }
                } label: {
                    if isAccepting {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "checkmark")
                            .frame(width: 20, height: 20)
                    }
                }
                .disabled(isAccepting || isDeclining)

                Button {
                    Task {
                        await declineInvite()
                    }
                } label: {
                    if isDeclining {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "xmark")
                            .frame(width: 20, height: 20)
                    }
                }
                .disabled(isAccepting || isDeclining)
            }
        }
        .padding(.vertical, 8)
    }

    private func acceptInvite() async {
        guard let token = appState.token,
              let serverUrl = appState.serverUrl,
              let chatRoomId = invite.chatRoom?.id else { return }

        isAccepting = true

        do {
            try await appState.networkService.acceptChatInvite(chatRoomId: chatRoomId, token: token, serverUrl: serverUrl)
            // Remove from invites list
            invites.removeAll { $0.id == invite.id }
        } catch {
            // Handle error - could show alert
            print("Failed to accept invite: \(error)")
        }

        isAccepting = false
    }

    private func declineInvite() async {
        guard let token = appState.token,
              let serverUrl = appState.serverUrl,
              let chatRoomId = invite.chatRoom?.id else { return }

        isDeclining = true

        do {
            try await appState.networkService.declineChatInvite(chatRoomId: chatRoomId, token: token, serverUrl: serverUrl)
            // Remove from invites list
            invites.removeAll { $0.id == invite.id }
        } catch {
            // Handle error - could show alert
            print("Failed to decline invite: \(error)")
        }

        isDeclining = false
    }
}
