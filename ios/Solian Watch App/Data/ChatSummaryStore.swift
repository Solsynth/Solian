import Combine
import Foundation

/// Shared, observable per-room chat summary state. The room list reads it to
/// render last-message previews + unread badges; the room detail clears a
/// room's unread when opened; live WebSocket messages increment the unread of
/// rooms that aren't currently open. Injected via `@EnvironmentObject`.
@MainActor
final class ChatSummaryStore: ObservableObject {
    /// App-wide instance, wired to the shared AppState + ChatCache.
    static let shared = ChatSummaryStore(appState: .shared, chatCache: .shared)

    @Published private(set) var roomSummaries: [String: ChatSummary] = [:]
    private(set) var openRoomId: String?

    private let appState: AppState
    private let chatCache: ChatCache
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState, chatCache: ChatCache) {
        self.appState = appState
        self.chatCache = chatCache
    }

    /// Seeds summaries from the cache (instant/offline launch).
    func loadCached() {
        for (room, summary) in chatCache.loadRooms() {
            roomSummaries[room.id] = summary
        }
    }

    /// Replaces summaries with freshly-fetched endpoint data (authoritative).
    func apply(_ summaries: [String: SnChatSummary]) {
        for (roomId, summary) in summaries {
            roomSummaries[roomId] = ChatSummary(
                lastMessage: summary.lastMessage,
                unreadCount: summary.unreadCount
            )
            chatCache.updateRoomSummary(
                roomId: roomId,
                summary: ChatSummary(lastMessage: summary.lastMessage, unreadCount: summary.unreadCount)
            )
        }
    }

    /// Marks a room read (opened). Called from the room detail.
    func markRead(_ roomId: String) {
        openRoomId = roomId
        guard let summary = roomSummaries[roomId], summary.unreadCount > 0 else { return }
        roomSummaries[roomId]?.unreadCount = 0
        chatCache.updateRoomSummary(roomId: roomId, summary: ChatSummary(
            lastMessage: summary.lastMessage,
            unreadCount: 0
        ))
    }

    func summary(for roomId: String) -> ChatSummary? {
        roomSummaries[roomId]
    }

    /// Subscribes to live `messages.new` to bump unread for rooms that aren't
    /// currently open. Returns a cancellable so the owner can tear it down.
    func observeLiveMessages() -> AnyCancellable {
        appState.networkService.packetStream
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] packet in
                guard let self = self else { return }
                guard packet.type == "messages.new",
                      let data = packet.data,
                      let roomId = data["chat_room_id"] as? String else { return }
                if roomId == self.openRoomId { return }
                let senderId = data["sender_id"] as? String
                if let senderId = senderId, senderId == self.appState.currentAccountId { return }

                var summary = self.roomSummaries[roomId] ?? .empty
                summary.unreadCount += 1
                self.roomSummaries[roomId] = summary
                self.chatCache.updateRoomSummary(
                    roomId: roomId,
                    summary: ChatSummary(lastMessage: summary.lastMessage, unreadCount: summary.unreadCount)
                )
            })
    }
}
