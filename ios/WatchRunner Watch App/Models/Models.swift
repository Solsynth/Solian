//  Models.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation

// MARK: - Models

struct AppToken: Codable {
    let token: String
}

struct SnActivity: Codable, Identifiable {
    let id: String
    let type: String
    let data: ActivityData?
    let createdAt: Date
}

enum ActivityData: Codable {
    case post(SnPost)
    case discovery(DiscoveryData)
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let post = try? container.decode(SnPost.self) {
            self = .post(post)
            return
        }
        if let discoveryData = try? container.decode(DiscoveryData.self) {
            self = .discovery(discoveryData)
            return
        }
        self = .unknown
    }

    func encode(to encoder: Encoder) throws {
        // Not needed for decoding
    }
}

struct SnPost: Codable, Identifiable {
    let id: String
    let title: String?
    let content: String?
    let publisher: SnPublisher
    let attachments: [SnCloudFile]
    let tags: [SnPostTag]
}

struct DiscoveryData: Codable {
    let items: [DiscoveryItem]
}

struct DiscoveryItem: Codable, Identifiable {
    var id = UUID()
    let type: String
    let data: DiscoveryItemData

    enum CodingKeys: String, CodingKey {
        case type, data
    }
}

enum DiscoveryItemData: Codable {
    case realm(SnRealm)
    case publisher(SnPublisher)
    case article(SnWebArticle)
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let realm = try? container.decode(SnRealm.self) {
            self = .realm(realm)
            return
        }
        if let publisher = try? container.decode(SnPublisher.self) {
            self = .publisher(publisher)
            return
        }
        if let article = try? container.decode(SnWebArticle.self) {
            self = .article(article)
            return
        }
        self = .unknown
    }

    func encode(to encoder: Encoder) throws {
        // Not needed for decoding
    }
}

struct SnRealm: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
}

struct SnPublisher: Codable, Identifiable {
    let id: String
    let name: String
    let nick: String?
    let description: String?
    let picture: SnCloudFile?
}

struct SnCloudFile: Codable, Identifiable {
    let id: String
    let mimeType: String?
}

struct SnPostTag: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String?
}

struct SnWebArticle: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
}

struct SnNotification: Codable, Identifiable {
    let id: String
    let topic: String
    let title: String
    let subtitle: String
    let content: String
    let meta: [String: AnyCodable]?
    let priority: Int
    let viewedAt: Date?
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case topic
        case title
        case subtitle
        case content
        case meta
        case priority
        case viewedAt = "viewedAt"
        case accountId = "accountId"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case deletedAt = "deletedAt"
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let arrayValue as [AnyCodable]:
            try container.encode(arrayValue)
        case let dictValue as [String: AnyCodable]:
            try container.encode(dictValue)
        default:
            try container.encodeNil()
        }
    }
}

struct NotificationResponse {
    let notifications: [SnNotification]
    let total: Int
    let hasMore: Bool
}

struct ActivityResponse {
    let activities: [SnActivity]
    let hasMore: Bool
    let nextCursor: String?
}

struct SnAccount: Codable {
    let id: String
    let name: String
    let nick: String
    let profile: SnUserProfile
    let createdAt: Date
}

struct SnUserProfile: Codable {
    let bio: String?
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let level: Int
    let experience: Int
    let levelingProgress: Double
}

struct SnAccountStatus: Codable {
    let id: String
    let attitude: Int
    let isOnline: Bool
    let isInvisible: Bool
    let isNotDisturb: Bool
    let isCustomized: Bool
    let label: String
    let meta: [String: AnyCodable]?
    let clearedAt: Date?
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}

// MARK: - Chat Models

struct SnChatRoom: Codable, Identifiable {
    let id: String
    let name: String?
    let description: String?
    let type: Int
    let isPublic: Bool
    let isCommunity: Bool
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let realmId: String?
    let realm: SnRealm?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let members: [SnChatMember]?
}

struct SnChatMessage: Codable, Identifiable {
    let id: String
    let type: String
    let content: String?
    let nonce: String?
    let meta: [String: AnyCodable]
    let membersMentioned: [String]?
    let editedAt: Date?
    let attachments: [SnCloudFile]
    let reactions: [SnChatReaction]
    let repliedMessageId: String?
    let forwardedMessageId: String?
    let senderId: String
    let sender: SnChatMember
    let chatRoomId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, type, content, nonce, meta, membersMentioned, editedAt, attachments, reactions, repliedMessageId, forwardedMessageId, senderId, sender, chatRoomId, createdAt, updatedAt, deletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        nonce = try container.decodeIfPresent(String.self, forKey: .nonce)
        meta = try container.decode([String: AnyCodable].self, forKey: .meta)
        membersMentioned = try container.decodeIfPresent([String].self, forKey: .membersMentioned) ?? []
        editedAt = try container.decodeIfPresent(Date.self, forKey: .editedAt)
        attachments = try container.decode([SnCloudFile].self, forKey: .attachments)
        reactions = try container.decode([SnChatReaction].self, forKey: .reactions)
        repliedMessageId = try container.decodeIfPresent(String.self, forKey: .repliedMessageId)
        forwardedMessageId = try container.decodeIfPresent(String.self, forKey: .forwardedMessageId)
        senderId = try container.decode(String.self, forKey: .senderId)
        sender = try container.decode(SnChatMember.self, forKey: .sender)
        chatRoomId = try container.decode(String.self, forKey: .chatRoomId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}

struct SnChatReaction: Codable, Identifiable {
    let id: String
    let messageId: String
    let senderId: String
    let sender: SnChatMember
    let symbol: String
    let attitude: Int
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}

struct SnChatMember: Codable, Identifiable {
    let id: String
    let chatRoomId: String
    let chatRoom: SnChatRoom?
    let accountId: String
    let account: SnAccount
    let nick: String?
    let role: Int
    let notify: Int
    let joinedAt: Date?
    let breakUntil: Date?
    let timeoutUntil: Date?
    let isBot: Bool
    let status: SnAccountStatus?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}

struct SnChatSummary: Codable {
    let unreadCount: Int
    let lastMessage: SnChatMessage?
}

struct ChatRoomsResponse {
    let rooms: [SnChatRoom]
}

struct ChatInvitesResponse {
    let invites: [SnChatMember]
}

struct MessageSyncResponse: Codable {
    let messages: [SnChatMessage]
    let currentTimestamp: Date

    enum CodingKeys: String, CodingKey {
        case messages
        case currentTimestamp = "current_timestamp"
    }
}
