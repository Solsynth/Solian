//
//  ChatCacheModels.swift
//  WatchRunner Watch App
//
//  SwiftData models that persist chat rooms, messages, and summaries so the
//  watch can launch instantly (offline) and show a chat summary (last message
//  + unread count) without a network round-trip.
//

import Foundation
import SwiftData

/// Cached room row. Stores the full `SnChatRoom` as JSON so no field is lost,
/// plus the derived summary fields for the room list.
@Model
final class CachedChatRoom {
    @Attribute(.unique) var id: String
    /// JSON-encoded `SnChatRoom`.
    var roomData: Data
    var lastMessageData: Data?
    var lastMessageAt: Date?
    var unreadCount: Int
    var updatedAt: Date

    init(
        id: String,
        roomData: Data,
        lastMessageData: Data? = nil,
        lastMessageAt: Date? = nil,
        unreadCount: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.roomData = roomData
        self.lastMessageData = lastMessageData
        self.lastMessageAt = lastMessageAt
        self.unreadCount = unreadCount
        self.updatedAt = updatedAt
    }
}

/// Cached message row per room. Keeps the latest `maxMessagesPerRoom` rows so
/// the timeline can render instantly on next launch.
@Model
final class CachedChatMessage {
    @Attribute(.unique) var id: String
    var roomId: String
    /// JSON-encoded `SnChatMessage`.
    var messageData: Data
    var createdAt: Date

    init(id: String, roomId: String, messageData: Data, createdAt: Date) {
        self.id = id
        self.roomId = roomId
        self.messageData = messageData
        self.createdAt = createdAt
    }
}
