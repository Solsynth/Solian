//
//  ChatCache.swift
//  WatchRunner Watch App
//
//  SwiftData-backed cache for chat rooms, messages, and per-room summaries.
//  Used to launch the room list instantly (offline) and to surface a chat
//  summary (last message + unread count) without a network round-trip.
//

import Foundation
import SwiftData

/// What a room list row needs beyond the room itself.
struct ChatSummary {
    var lastMessage: SnChatMessage?
    var unreadCount: Int

    static let empty = ChatSummary(lastMessage: nil, unreadCount: 0)
}

/// Persists chat rooms + messages with a SwiftData `ModelContext`. Encoding
/// the models as JSON keeps the cache faithful to `SnChatRoom`/`SnChatMessage`
/// without hand-migrating every field. All methods are `@MainActor` since the
/// `ModelContext` is accessed from views/ViewModels.
@MainActor
final class ChatCache {
    /// The app-wide cache. Set once at launch to the real store-backed
    /// instance; defaults to a no-persistence fallback.
    static var shared = ChatCache(modelContext: nil)

    private let modelContext: ModelContext?
    /// Cap the cached message rows per room to bound disk usage on watchOS.
    private let maxMessagesPerRoom = 100

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }

    var isAvailable: Bool { modelContext != nil }

    // MARK: - Rooms

    /// Loads cached rooms (most recently updated first). Returns decoded
    /// `SnChatRoom` values plus their summaries.
    func loadRooms() -> [(room: SnChatRoom, summary: ChatSummary)] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<CachedChatRoom>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.compactMap { row in
            guard let room = decodeRoom(row.roomData) else { return nil }
            let last = row.lastMessageData.flatMap(decodeMessage)
            return (room, ChatSummary(lastMessage: last, unreadCount: row.unreadCount))
        }
    }

    func saveRooms(_ rooms: [SnChatRoom]) {
        guard let context = modelContext else { return }
        for room in rooms {
            guard let data = try? JSONEncoder().encode(room) else { continue }
            upsertRoom(id: room.id, roomData: data, updatedAt: room.updatedAt)
        }
        try? context.save()
    }

    func updateRoomSummary(roomId: String, summary: ChatSummary) {
        guard let context = modelContext else { return }
        let row = fetchRoom(roomId)
        if let row = row {
            row.lastMessageData = summary.lastMessage.flatMap { try? JSONEncoder().encode($0) }
            row.lastMessageAt = summary.lastMessage?.createdAt
            row.unreadCount = summary.unreadCount
        } else {
            // No cached room row yet (summary arrived first).
            upsertRoom(id: roomId, roomData: Data(), updatedAt: summary.lastMessage?.createdAt ?? Date())
            if let fresh = fetchRoom(roomId) {
                fresh.lastMessageData = summary.lastMessage.flatMap { try? JSONEncoder().encode($0) }
                fresh.lastMessageAt = summary.lastMessage?.createdAt
                fresh.unreadCount = summary.unreadCount
            }
        }
        try? context.save()
    }

    private func upsertRoom(id: String, roomData: Data, updatedAt: Date) {
        guard let context = modelContext else { return }
        if let row = fetchRoom(id) {
            row.roomData = roomData
            row.updatedAt = updatedAt
        } else {
            context.insert(CachedChatRoom(id: id, roomData: roomData, updatedAt: updatedAt))
        }
    }

    private func fetchRoom(_ id: String) -> CachedChatRoom? {
        guard let context = modelContext else { return nil }
        var descriptor = FetchDescriptor<CachedChatRoom>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - Messages

    /// Cached displayable messages for a room, oldest first.
    func loadMessages(roomId: String) -> [SnChatMessage] {
        guard let context = modelContext else { return [] }
        var descriptor = FetchDescriptor<CachedChatMessage>(
            predicate: #Predicate { $0.roomId == roomId },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.fetchLimit = maxMessagesPerRoom
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.compactMap { decodeMessage($0.messageData) }
    }

    func saveMessages(roomId: String, _ messages: [SnChatMessage]) {
        guard let context = modelContext else { return }
        var seen = Set<String>()
        var rows = (try? context.fetch(FetchDescriptor<CachedChatMessage>(
            predicate: #Predicate { $0.roomId == roomId }
        ))) ?? []

        for message in messages {
            guard !seen.contains(message.id) else { continue }
            seen.insert(message.id)
            guard let data = try? JSONEncoder().encode(message) else { continue }
            if let existing = rows.first(where: { $0.id == message.id }) {
                existing.messageData = data
                existing.createdAt = message.createdAt
            } else {
                let row = CachedChatMessage(id: message.id, roomId: roomId, messageData: data, createdAt: message.createdAt)
                context.insert(row)
                rows.append(row)
            }
        }

        // Enforce the per-room cap (drop oldest beyond the limit).
        let sorted = rows.sorted { $0.createdAt < $1.createdAt }
        if sorted.count > maxMessagesPerRoom {
            for row in sorted.prefix(sorted.count - maxMessagesPerRoom) {
                context.delete(row)
            }
        }
        try? context.save()
    }

    // MARK: - Decoding helpers

    private func decodeRoom(_ data: Data) -> SnChatRoom? {
        guard !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(SnChatRoom.self, from: data)
    }

    private func decodeMessage(_ data: Data) -> SnChatMessage? {
        try? JSONDecoder().decode(SnChatMessage.self, from: data)
    }
}
