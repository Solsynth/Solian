//
//  ChatCache.swift
//  Solian Watch App
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
    /// Cap the cached message rows per room to bound disk & memory usage on watchOS.
    private let maxMessagesPerRoom = 50
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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
        let existingRows = (try? context.fetch(FetchDescriptor<CachedChatRoom>())) ?? []
        let byId = Dictionary(uniqueKeysWithValues: existingRows.map { ($0.id, $0) })
        for room in rooms {
            guard let data = try? encoder.encode(room) else { continue }
            if let row = byId[room.id] {
                row.roomData = data
                row.updatedAt = room.updatedAt
            } else {
                context.insert(CachedChatRoom(id: room.id, roomData: data, updatedAt: room.updatedAt))
            }
        }
        try? context.save()
    }

    func updateRoomSummary(roomId: String, summary: ChatSummary) {
        guard let context = modelContext else { return }
        let encodedLast = summary.lastMessage.flatMap { try? encoder.encode($0) }
        if let row = fetchRoom(roomId) {
            row.lastMessageData = encodedLast
            row.lastMessageAt = summary.lastMessage?.createdAt
            row.unreadCount = summary.unreadCount
        } else {
            // No cached room row yet (summary arrived first).
            let fresh = CachedChatRoom(
                id: roomId,
                roomData: Data(),
                lastMessageData: encodedLast,
                lastMessageAt: summary.lastMessage?.createdAt,
                unreadCount: summary.unreadCount,
                updatedAt: summary.lastMessage?.createdAt ?? Date()
            )
            context.insert(fresh)
        }
        try? context.save()
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
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = maxMessagesPerRoom
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.reversed().compactMap { decodeMessage($0.messageData) }
    }

    func saveMessages(roomId: String, _ messages: [SnChatMessage]) {
        guard let context = modelContext else { return }
        let persistable = messages
            .filter { !$0.id.hasPrefix("pending_") }
            .suffix(maxMessagesPerRoom)

        let existingRows = (try? context.fetch(FetchDescriptor<CachedChatMessage>(
            predicate: #Predicate { $0.roomId == roomId }
        ))) ?? []
        var byId: [String: CachedChatMessage] = [:]
        byId.reserveCapacity(existingRows.count)
        for row in existingRows {
            byId[row.id] = row
        }

        var seen = Set<String>()
        var allRows = existingRows
        for message in persistable {
            guard !seen.contains(message.id) else { continue }
            seen.insert(message.id)
            guard let data = try? encoder.encode(message) else { continue }
            if let existing = byId[message.id] {
                existing.messageData = data
                existing.createdAt = message.createdAt
            } else {
                let row = CachedChatMessage(id: message.id, roomId: roomId, messageData: data, createdAt: message.createdAt)
                context.insert(row)
                byId[message.id] = row
                allRows.append(row)
            }
        }

        // Enforce the per-room cap (drop oldest beyond the limit).
        if allRows.count > maxMessagesPerRoom {
            let sorted = allRows.sorted { $0.createdAt < $1.createdAt }
            for row in sorted.prefix(allRows.count - maxMessagesPerRoom) {
                context.delete(row)
            }
        }
        try? context.save()
    }

    /// Inserts or updates a single message in the cache without re-encoding the
    /// entire room history.
    func upsertMessage(roomId: String, _ message: SnChatMessage) {
        guard let context = modelContext, !message.id.hasPrefix("pending_") else { return }
        guard let data = try? encoder.encode(message) else { return }

        let msgId = message.id
        var descriptor = FetchDescriptor<CachedChatMessage>(predicate: #Predicate { $0.id == msgId })
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            existing.messageData = data
            existing.createdAt = message.createdAt
        } else {
            context.insert(CachedChatMessage(id: message.id, roomId: roomId, messageData: data, createdAt: message.createdAt))
            trimRoomMessagesIfNeeded(roomId: roomId, context: context)
        }
        try? context.save()
    }

    /// Removes a single message from the cache by id.
    func deleteMessage(id: String) {
        guard let context = modelContext, !id.hasPrefix("pending_") else { return }
        var descriptor = FetchDescriptor<CachedChatMessage>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
    }

    private func trimRoomMessagesIfNeeded(roomId: String, context: ModelContext) {
        let descriptor = FetchDescriptor<CachedChatMessage>(
            predicate: #Predicate { $0.roomId == roomId },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        guard let rows = try? context.fetch(descriptor), rows.count > maxMessagesPerRoom else { return }
        for row in rows.prefix(rows.count - maxMessagesPerRoom) {
            context.delete(row)
        }
    }

    // MARK: - Invalidation

    /// Deletes every cached room and message.
    ///
    /// The cache is per-account, so this runs on sign-out: the next account
    /// must never see the previous one's chats. Bulk delete rather than
    /// fetch-then-delete so no rows are materialised.
    func clear() {
        guard let context = modelContext else { return }
        try? context.delete(model: CachedChatRoom.self)
        try? context.delete(model: CachedChatMessage.self)
        try? context.save()
    }

    // MARK: - Decoding helpers

    private func decodeRoom(_ data: Data) -> SnChatRoom? {
        guard !data.isEmpty else { return nil }
        return try? decoder.decode(SnChatRoom.self, from: data)
    }

    private func decodeMessage(_ data: Data) -> SnChatMessage? {
        try? decoder.decode(SnChatMessage.self, from: data)
    }
}
