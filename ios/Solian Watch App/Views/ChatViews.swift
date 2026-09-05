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
    
    /// The last message to preview, or nil when no summary has arrived.
    private var lastMessage: SnChatMessage? {
        summary?.lastMessage
    }
    
    /// Content text for the preview, or the room description fallback.
    private var previewContent: String {
        guard let last = lastMessage else { return subtitle }
        return last.content?.isEmpty == false ? last.content! : "Attachment"
    }
    
    /// `<sender>: <msg>` preview below the avatar row, with the sender name
    /// tinted distinctly from the content (Apple Messages shows the sender in
    /// the conversation's accent color and the message body in secondary).
    @ViewBuilder
    private var previewLine: some View {
        if let last = lastMessage {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(last.sender.displayName)
                    .foregroundColor(Color.accentColor)
                Text(":  \(previewContent)")
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 13))
            .lineLimit(2)
        } else {
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
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
    
    /// Large (52pt) circular badge behind the initial for the card avatar.
    private var badgeColor: Color {
        // Stable hue per room so each card reads distinctly.
        let index = abs(room.id.hashValue) % 6
        let palette: [Color] = [
            Color(red: 0.45, green: 0.55, blue: 0.85),
            Color(red: 0.55, green: 0.45, blue: 0.85),
            Color(red: 0.45, green: 0.75, blue: 0.60),
            Color(red: 0.85, green: 0.55, blue: 0.45),
            Color(red: 0.60, green: 0.70, blue: 0.45),
            Color(red: 0.75, green: 0.45, blue: 0.65),
        ]
        return palette[index]
    }
    
    var body: some View {
        NavigationLink(
            destination: ChatRoomView(room: room, appState: appState, chatCache: chatCache)
                .environmentObject(appState)
                .environmentObject(summaryStore)
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    // Smaller circular avatar with initial fallback.
                    Group {
                        if avatarLoader.isLoading {
                            ProgressView()
                                .frame(width: 36, height: 36)
                        } else if let image = avatarLoader.image {
                            image
                                .resizable()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(badgeColor)
                                    .frame(width: 36, height: 36)
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
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
                        // Title + unread badge on the same row.
                        HStack(alignment: .center, spacing: 6) {
                            Text(displayName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            if let summary = summary, summary.unreadCount > 0 {
                                let label = summary.unreadCount > 99 ? "99+" : "\(summary.unreadCount)"
                                Text(label)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red, in: Capsule())
                            }
                            Spacer(minLength: 0)
                        }
                        if !relativeTimeText.isEmpty {
                            Text(relativeTimeText)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Full-width last-message preview below the avatar row.
                previewLine
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        // Remove the List's default edge insets so the card spans nearly
        // edge-to-edge, matching Apple Messages' full-width conversation cards.
        .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
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
    
    @State private var showStickerPicker = false
    @State private var showComposerActions = false
    @FocusState private var composerFocused: Bool
    @ObservedObject private var stickerStore = StickerStore.shared
    
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
            .sheet(isPresented: $showStickerPicker) {
                StickerPickerView(store: stickerStore) { pack, sticker in
                    Task { await viewModel.sendSticker(pack, sticker) }
                }
                .environmentObject(appState)
            }
            .sheet(isPresented: $showComposerActions) {
                ChatComposerActionsView {
                    // Present the sticker picker from the "+" menu. Load packs
                    // first so the sheet has content when it appears.
                    openStickerPicker()
                }
                .environmentObject(appState)
            }
    }
    
    /// Opens the sticker picker, loading owned packs first so the sheet has
    /// content (or a readable empty/error state) when it appears.
    private func openStickerPicker() {
        WKInterfaceDevice.current().play(.click)
        Task { @MainActor in
            await loadStickerPacksIfNeeded()
            // Only present once the load attempt settles, so the sheet never
            // flashes an empty state.
            showStickerPicker = true
        }
    }
    
    private func loadStickerPacksIfNeeded() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        await stickerStore.loadOwnedPacks(token: token, serverUrl: serverUrl)
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
                            ForEach(timelinePieces) { piece in
                                switch piece {
                                case .watermark:
                                    watermarkRow
                                case .dateDivider(let date):
                                    dateDividerRow(date)
                                case .group(let group, let showsHeader):
                                    MessageGroupView(
                                        group: group,
                                        isOwn: isOwnGroup(group),
                                        showsHeader: showsHeader,
                                        viewModel: viewModel
                                    )
                                    .environmentObject(appState)
                                }
                            }
                        }
                        composeBar
                            .id("compose-bar")
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
                // Track whether the newest end of the timeline is on screen:
                // only then are live arrivals actually "read" (Flutter's
                // `isAtLatestMessages`), which gates read receipts and hides
                // the read-watermark divider.
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    let contentBottom = geometry.contentSize.height
                    return geometry.visibleRect.maxY >= contentBottom - 12
                } action: { _, isAtLatest in
                    viewModel.setAtLatest(isAtLatest)
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
    
    // MARK: - Read watermark
    
    /// The "read here" divider between already-read history (above) and
    /// messages you haven't read yet (below). Mirrors Flutter's "new message
    /// below" marker; hidden while the timeline is pinned to the latest.
    private var watermarkRow: some View {
        HStack(spacing: 5) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 9))
            Text("Read")
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(Color.accentColor)
        .opacity(0.85)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .overlay(alignment: .center) {
            // Hairline rule spanning the row behind the capsule label.
            Rectangle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(height: 0.7)
        }
        .background(Color.accentColor.opacity(0.08), in: Capsule())
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
    
    /// A centered day stamp like Apple Messages' "Yesterday 10:12 PM" row —
    /// labels the start of a new calendar day in the timeline. Rendered as a
    /// subtle capsule pill so it reads as a section marker between days.
    private func dateDividerRow(_ date: Date) -> some View {
        Text(Self.dayStamp(for: date))
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.16), in: Capsule())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
    
    /// Relative day label with the time: today → "Today", yesterday →
    /// "Yesterday", else the absolute date. Matches the messaging convention.
    private static func dayStamp(for date: Date) -> String {
        let calendar = Calendar.current
        let time = date.formatted(date: .omitted, time: .shortened)
        if calendar.isDateInToday(date) {
            return "Today \(time)"
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday \(time)"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    
    /// Timeline rows in render order: message groups, with a read-watermark
    /// divider inserted at the read boundary. The boundary can fall in the
    /// middle of a same-sender run, so the run owning the boundary is split
    /// into two groups; the lower half keeps no header (the sender hasn't
    /// changed — only the divider separates it from its own earlier messages).
    private enum TimelinePiece: Identifiable {
        case watermark
        case dateDivider(Date)
        case group(messages: [SnChatMessage], showsHeader: Bool)
        
        var id: String {
            switch self {
            case .watermark:
                return "read-watermark"
            case .dateDivider(let date):
                // A day boundary belongs between two distinct calendar days;
                // keying on its day-stamp keeps exactly one divider per day.
                return "date-\(Calendar.current.startOfDay(for: date).timeIntervalSince1970)"
            case .group(let messages, _):
                // Group pieces are contiguous, non-overlapping message runs,
                // so the first message's id uniquely identifies the piece.
                return "group-\(messages[0].id)"
            }
        }
    }
    
    private var timelinePieces: [TimelinePiece] {
        // Reading `isAtLatest` here makes SwiftUI re-evaluate the pieces when
        // the user pins/unpins the latest end (Flutter nulls its anchor while
        // at the latest — the divider belongs to history scrollback).
        let isAtLatest = viewModel.isAtLatest
        let seamId = isAtLatest ? nil : viewModel.readWatermarkMessageId
        guard let seamId,
              let seamIndex = viewModel.messages.firstIndex(where: { $0.id == seamId }) else {
            return makeTimelinePieces(from: viewModel.messages, continuingSender: nil, previousDay: nil)
        }
        let readMessages = Array(viewModel.messages[..<seamIndex])
        let unreadMessages = Array(viewModel.messages[seamIndex...])
        var pieces = makeTimelinePieces(
            from: readMessages,
            continuingSender: nil,
            previousDay: nil
        )
        pieces.append(.watermark)
        // The first unread run continues the sender of the last read message
        // unless it's actually a sender change at the seam. The seam keeps the
        // last read day-stamp so a same-day unread segment doesn't re-emit the
        // divider the read side already drew.
        pieces += makeTimelinePieces(
            from: unreadMessages,
            continuingSender: readMessages.last,
            previousDay: readMessages.last.map { Calendar.current.startOfDay(for: $0.createdAt) }
        )
        return pieces
    }
    
    /// Groups a message array into same-sender runs (≤3 min apart) as pieces,
    /// inserting a day-boundary divider whenever the calendar date rolls over.
    /// `previousDay` is the day-stamp of the last message rendered before this
    /// segment (nil for the oldest segment), so a divider is emitted only on a
    /// real day change — never twice when the read watermark splits a day.
    private func makeTimelinePieces(
        from messages: [SnChatMessage],
        continuingSender: SnChatMessage?,
        previousDay: Date?
    ) -> [TimelinePiece] {
        var pieces: [TimelinePiece] = []
        var run: [SnChatMessage] = []
        var isFirstRun = true
        
        func flush() {
            guard !run.isEmpty else { return }
            var showsHeader = true
            if isFirstRun, let continuing = continuingSender,
               continuing.senderId == run[0].senderId,
               run[0].createdAt.timeIntervalSince(continuing.createdAt) <= 180 {
                showsHeader = false
            }
            pieces.append(.group(messages: run, showsHeader: showsHeader))
            run = []
            isFirstRun = false
        }
        
        let calendar = Calendar.current
        var prevDay = previousDay
        for message in messages {
            // A day-boundary divider when the date rolls over (or at the very
            // first message of the conversation, so it anchors to a labeled
            // day like Apple Messages).
            let day = calendar.startOfDay(for: message.createdAt)
            if prevDay == nil || day != prevDay {
                flush()
                pieces.append(.dateDivider(message.createdAt))
                prevDay = day
            }
            if let last = run.last,
               !(last.senderId == message.senderId
                 && message.createdAt.timeIntervalSince(last.createdAt) <= 180) {
                flush()
            }
            run.append(message)
        }
        flush()
        return pieces
    }
    
    /// The trailing compose affordance, styled after Apple Messages' input
    /// bar: a round "+" (opens the content-type menu) beside an inline text
    /// field with a send button. The field expands with its content and the
    /// send arrow appears once there's text. Both scroll with the timeline.
    ///
    /// On watchOS 26+ the "+" and field use Liquid Glass (the material of the
    /// navigation/floating layer); on older watchOS they fall back to a flat
    /// gray fill.
    private var composeBar: some View {
        HStack(alignment: .center, spacing: 12) {
            plusButton
            messageField
            if showSendButton {
                sendButton
            }
        }
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    private var plusButton: some View {
        Button {
            WKInterfaceDevice.current().play(.click)
            showComposerActions = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More compose options")
        .accessibilityHint("Choose a message content type")
        .glassSurface(in: .circle)
    }
    
    @ViewBuilder
    private var messageField: some View {
        TextField("Messages", text: $viewModel.draft)
            .buttonBorderShape(.capsule)
            .submitLabel(.send)
            .labelsHidden()
            .onSubmit { sendFromBar() }
            .onChange(of: viewModel.draft) { _, newValue in
                viewModel.typingChanged(to: newValue)
            }
            .focused($composerFocused)
            .textFieldStyle(.plain)
    }
    
    @ViewBuilder
    private var sendButton: some View {
        Button {
            sendFromBar()
        } label: {
            if viewModel.isSending {
                ProgressView()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 22))
            }
        }
        .buttonStyle(.plain)
        .disabled(!canSendFromBar || viewModel.isSending)
        .accessibilityLabel("Send message")
    }
    
    private var canSendFromBar: Bool {
        !viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Apple Messages only reveals the send arrow once there's text, which
    /// also frees the arrow's width for the field while it's empty.
    private var showSendButton: Bool {
        canSendFromBar || viewModel.isSending
    }
    
    /// Sends the inline draft and opens the system text input on first tap
    /// (watchOS opens its keyboard/scribble when the field gains focus).
    private func sendFromBar() {
        guard canSendFromBar else { return }
        WKInterfaceDevice.current().play(.click)
        Task {
            await viewModel.send()
            if !viewModel.isSending {
                composerFocused = true
            }
        }
    }
    
    private func scrollToLatest(_ proxy: ScrollViewProxy) {
        withAnimation { proxy.scrollTo("compose-bar", anchor: .bottom) }
    }
    
    private func scrollToTop(_ proxy: ScrollViewProxy) {
        withAnimation { proxy.scrollTo("load-older", anchor: .top) }
    }
    
    /// Whether the whole group (same sender) is the current user's.
    private func isOwnGroup(_ group: [SnChatMessage]) -> Bool {
        guard let first = group.first else { return false }
        return viewModel.isOwnMessage(first)
    }
}

/// Liquid Glass surface for the floating compose controls (the "+" and the
/// message field). Glass is the material of the floating/navigation layer, so
/// it's the right treatment here. On watchOS 26+ it renders as real glass;
/// on earlier systems it falls back to a flat gray fill.
private struct ComposeGlassModifier: ViewModifier {
    let shape: ComposeGlassShape
    
    func body(content: Content) -> some View {
        if #available(watchOS 26, *) {
            content.glassEffect(.regular, in: shape.glassShape)
        } else {
            content.background(shape.fillColor, in: shape.fillShape)
        }
    }
}

enum ComposeGlassShape {
    case circle
    case capsule
    
    @available(watchOS 26, *)
    var glassShape: any Shape {
        switch self {
        case .circle: return Circle()
        case .capsule: return Capsule()
        }
    }
    
    var fillColor: Color { Color.gray.opacity(0.22) }
    var fillShape: AnyShape {
        switch self {
        case .circle: return AnyShape(Circle())
        case .capsule: return AnyShape(Capsule())
        }
    }
}

extension View {
    func glassSurface(in shape: ComposeGlassShape) -> some View {
        modifier(ComposeGlassModifier(shape: shape))
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
    /// False for the lower half of a group split by the read watermark: the
    /// sender header already belongs to the upper half, so repeating it below
    /// the divider would duplicate it.
    var showsHeader = true
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
            if showsHeader {
                header
            }
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
        // Standalone sticker rows get a subdued tint (the image carries the
        // visual weight) — Flutter's sticker bubble is likewise a light
        // container, not the full text-bubble accent.
        if contentIsStandaloneSticker {
            return (isOwn ? Color.accentColor : Color.gray)
                .opacity(isOwn ? 0.18 : 0.08)
        }
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
    /// True when the body is exactly one sticker (renders large, subdued
    /// bubble, no quote/attachment chrome).
    private var contentIsStandaloneSticker: Bool {
        guard let content = message.content, !content.isEmpty else { return false }
        return isStandaloneStickerContent(content)
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
                    ChatStickerContent(content: content, isOwn: isOwn)
                        .environmentObject(appState)
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
            .padding(.horizontal, contentIsStandaloneSticker ? 4 : 10)
            .padding(.vertical, contentIsStandaloneSticker ? 2 : 6)
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
