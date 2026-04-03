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
    let data: AnyCodable?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, type, data, createdAt = "created_at"
    }
    
    var isPost: Bool {
        guard let data = data?.value as? [String: Any] else { return false }
        return data["title"] != nil || data["content"] != nil || data["publisher"] != nil
    }
    
    var isDiscovery: Bool {
        guard let data = data?.value as? [String: Any] else { return false }
        return data["items"] != nil
    }
    
    func decodePost() -> SnPost? {
        guard let data = data?.value as? [String: Any] else { return nil }
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        guard let jsonData = jsonData else { return nil }
        return try? JSONDecoder().decode(SnPost.self, from: jsonData)
    }
    
    func decodeDiscovery() -> DiscoveryData? {
        guard let data = data?.value as? [String: Any] else { return nil }
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        guard let jsonData = jsonData else { return nil }
        return try? JSONDecoder().decode(DiscoveryData.self, from: jsonData)
    }
}

struct SnPost: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let language: String?
    let editedAt: Date?
    let draftedAt: Date?
    let publishedAt: Date?
    let visibility: Int?
    let content: String?
    let slug: String?
    let type: Int?
    let meta: [String: AnyCodable]?
    let embedView: SnPostEmbedView?
    let viewsUnique: Int?
    let viewsTotal: Int?
    let upvotes: Int?
    let downvotes: Int?
    let repliesCount: Int?
    let threadedRepliesCount: Int?
    let debugRank: Double?
    let awardedScore: Int?
    let pinMode: Int?
    let threadedPostId: String?
    let repliedPostId: String?
    let forwardedPostId: String?
    let realmId: String?
    let realm: SnRealm?
    let publisherId: String?
    let publisher: SnPublisher?
    let actorid: String?
    let fediverseUri: String?
    let fediverseType: Int?
    let isCached: Bool?
    let contentType: Int?
    let attachments: [SnCloudFile]?
    let reactionsCount: [String: Int]?
    let reactionsMade: [String: Bool]?
    let reactions: [AnyCodable]?
    let tags: [SnPostTag]?
    let featuredRecords: [AnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let repliedGone: Bool?
    let forwardedGone: Bool?
    let boostedBy: SnActivityPubActor?
    let boostedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, language, editedAt, draftedAt, publishedAt, visibility
        case content, slug, type, meta, embedView
        case viewsUnique = "views_unique"
        case viewsTotal = "views_total"
        case upvotes, downvotes
        case repliesCount = "replies_count"
        case threadedRepliesCount = "threaded_replies_count"
        case debugRank = "debug_rank"
        case awardedScore = "awarded_score"
        case pinMode = "pin_mode"
        case threadedPostId = "threaded_post_id"
        case repliedPostId = "replied_post_id"
        case forwardedPostId = "forwarded_post_id"
        case realmId = "realm_id"
        case realm
        case publisherId = "publisher_id"
        case publisher
        case actorid = "actor_id"
        case fediverseUri = "fediverse_uri"
        case fediverseType = "fediverse_type"
        case isCached = "is_cached"
        case contentType = "content_type"
        case attachments
        case reactionsCount = "reactions_count"
        case reactionsMade = "reactions_made"
        case reactions, tags
        case featuredRecords = "featured_records"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case repliedGone = "replied_gone"
        case forwardedGone = "forwarded_gone"
        case boostedBy = "boosted_by"
        case boostedAt = "boosted_at"
    }
}

struct SnPostEmbedView: Codable {
    let uri: String
    let aspectRatio: Double?
    let renderer: Int?
    
    enum CodingKeys: String, CodingKey {
        case uri
        case aspectRatio = "aspect_ratio"
        case renderer
    }
}

struct SnActivityPubActor: Codable, Identifiable {
    let id: String
    let type: String?
    let name: String?
    let preferredUsername: String?
    let summary: String?
    let url: String?
    let icon: SnCloudFile?
    let image: SnCloudFile?
    let inbox: String?
    let outbox: String?
    let followers: String?
    let following: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, name, summary, url, icon, image, inbox, outbox, followers, following
        case preferredUsername = "preferred_username"
    }
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
    let slug: String
    let name: String
    let description: String?
    let verifiedAs: String?
    let verifiedAt: Date?
    let isCommunity: Bool
    let isPublic: Bool
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let boostPoints: Int
    let boostLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case description
        case verifiedAs = "verified_as"
        case verifiedAt = "verified_at"
        case isCommunity = "is_community"
        case isPublic = "is_public"
        case picture
        case background
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case boostPoints = "boost_points"
        case boostLevel = "boost_level"
    }
}

struct SnPublisher: Codable, Identifiable {
    let id: String
    let type: Int
    let name: String
    let nick: String?
    let bio: String?
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let account: SnAccount?
    let accountId: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let realmId: String?
    let verification: SnVerificationMark?
    let followRequiresApproval: Bool
    let postsRequireFollow: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case nick
        case bio
        case picture
        case background
        case account
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case realmId = "realm_id"
        case verification
        case followRequiresApproval = "follow_requires_approval"
        case postsRequireFollow = "posts_require_follow"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decodeIfPresent(Int.self, forKey: .type) ?? 0
        name = try container.decode(String.self, forKey: .name)
        nick = try container.decodeIfPresent(String.self, forKey: .nick)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        account = try container.decodeIfPresent(SnAccount.self, forKey: .account)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        realmId = try container.decodeIfPresent(String.self, forKey: .realmId)
        verification = try container.decodeIfPresent(SnVerificationMark.self, forKey: .verification)
        followRequiresApproval = try container.decodeIfPresent(Bool.self, forKey: .followRequiresApproval) ?? false
        postsRequireFollow = try container.decodeIfPresent(Bool.self, forKey: .postsRequireFollow) ?? false
    }
}

struct SnVerificationMark: Codable {
    let type: Int
    let title: String?
    let description: String?
    let verifiedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case verifiedBy = "verified_by"
    }
}

struct SnCloudFile: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let fileMeta: [String: AnyCodable]?
    let userMeta: [String: AnyCodable]?
    let sensitiveMarks: [Int]?
    let mimeType: String?
    let hash: String?
    let size: Int
    let uploadedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case fileMeta = "file_meta"
        case userMeta = "user_meta"
        case sensitiveMarks = "sensitive_marks"
        case mimeType = "mime_type"
        case hash
        case size
        case uploadedAt = "uploaded_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case url
    }
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
    let meta: [String: AnyCodable]
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        topic = try container.decode(String.self, forKey: .topic)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        content = try container.decode(String.self, forKey: .content)
        meta = try container.decodeIfPresent([String: AnyCodable].self, forKey: .meta) ?? [:]
        priority = try container.decode(Int.self, forKey: .priority)
        viewedAt = try container.decodeIfPresent(Date.self, forKey: .viewedAt)
        accountId = try container.decode(String.self, forKey: .accountId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
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

// MARK: - Timeline Models

struct SnTimelineEvent: Codable, Identifiable {
    let id: String
    let type: String
    let resourceIdentifier: String?
    let data: AnyCodable?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case resourceIdentifier = "resource_identifier"
        case data
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    var isPost: Bool {
        guard let data = data?.value as? [String: Any] else { return false }
        return data["title"] != nil || data["content"] != nil || data["publisher"] != nil
    }
    
    var isDiscovery: Bool {
        guard let data = data?.value as? [String: Any] else { return false }
        return data["items"] != nil
    }
    
    func decodePost() -> SnPost? {
        guard let data = data?.value as? [String: Any] else { return nil }
        
        do {
            let cleanData = convertToValidJsonTypes(data)
            let jsonData = try JSONSerialization.data(withJSONObject: cleanData, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(SnPost.self, from: jsonData)
        } catch {
            return nil
        }
    }
    
    func decodeDiscovery() -> DiscoveryData? {
        guard let data = data?.value as? [String: Any] else { return nil }
        
        do {
            let cleanData = convertToValidJsonTypes(data)
            let jsonData = try JSONSerialization.data(withJSONObject: cleanData, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(DiscoveryData.self, from: jsonData)
        } catch {
            return nil
        }
    }
    
    private func convertToValidJsonTypes(_ value: Any) -> Any {
        if let codable = value as? AnyCodable {
            return convertToValidJsonTypes(codable.value)
        } else if let dict = value as? [String: Any] {
            var result: [String: Any] = [:]
            for (k, v) in dict {
                result[k] = convertToValidJsonTypes(v)
            }
            return result
        } else if let array = value as? [Any] {
            return array.map { convertToValidJsonTypes($0) }
        } else if let intVal = value as? Int {
            return NSNumber(value: intVal)
        } else if let doubleVal = value as? Double {
            return NSNumber(value: doubleVal)
        } else if let boolVal = value as? Bool {
            return NSNumber(value: boolVal)
        } else if value is String {
            return value
        } else if value is NSNull {
            return NSNull()
        } else if value is [Any] || value is [String: Any] {
            return value
        } else {
            return NSNull()
        }
    }
}

struct TimelineResponseWrapper: Codable {
    let items: [SnTimelineEvent]
    let nextCursor: String?
    let mode: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
        case mode
    }
}

struct ActivityResponse {
    let activities: [SnTimelineEvent]
    let hasMore: Bool
    let nextCursor: String?
}

struct SnAccount: Codable {
    let id: String
    let name: String
    let nick: String
    let language: String
    let region: String
    let isSuperuser: Bool
    let automatedId: String?
    let profile: SnUserProfile
    let perkSubscription: SnWalletSubscriptionRef?
    let badges: [SnAccountBadge]
    let contacts: [SnContactMethod]
    let activatedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nick
        case language
        case region
        case isSuperuser = "is_superuser"
        case automatedId = "automated_id"
        case profile
        case perkSubscription = "perk_subscription"
        case badges
        case contacts
        case activatedAt = "activated_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nick = try container.decode(String.self, forKey: .nick)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
        region = try container.decodeIfPresent(String.self, forKey: .region) ?? ""
        isSuperuser = try container.decode(Bool.self, forKey: .isSuperuser)
        automatedId = try container.decodeIfPresent(String.self, forKey: .automatedId)
        profile = try container.decode(SnUserProfile.self, forKey: .profile)
        perkSubscription = try container.decodeIfPresent(SnWalletSubscriptionRef.self, forKey: .perkSubscription)
        badges = try container.decodeIfPresent([SnAccountBadge].self, forKey: .badges) ?? []
        contacts = try container.decodeIfPresent([SnContactMethod].self, forKey: .contacts) ?? []
        activatedAt = try container.decodeIfPresent(Date.self, forKey: .activatedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}

struct SnWalletSubscriptionRef: Codable {
    let subscriptionId: String?
    let subscriptionType: String?
    let expiredAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case subscriptionId = "subscription_id"
        case subscriptionType = "subscription_type"
        case expiredAt = "expired_at"
    }
}

struct SnAccountBadge: Codable, Identifiable {
    let id: String
    let type: String
    let label: String?
    let caption: String?
    let meta: [String: AnyCodable]
    let expiredAt: Date?
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let activatedAt: Date?
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label
        case caption
        case meta
        case expiredAt = "expired_at"
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case activatedAt = "activated_at"
        case deletedAt = "deleted_at"
    }
}

struct SnContactMethod: Codable, Identifiable {
    let id: String
    let type: Int
    let verifiedAt: Date?
    let isPrimary: Bool
    let isPublic: Bool
    let content: String
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case verifiedAt = "verified_at"
        case isPrimary = "is_primary"
        case isPublic = "is_public"
        case content
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct SnUserProfile: Codable {
    let id: String
    let firstName: String
    let middleName: String
    let lastName: String
    let bio: String
    let gender: String
    let pronouns: String
    let location: String
    let timeZone: String
    let birthday: Date?
    let links: [ProfileLink]
    let lastSeenAt: Date?
    let activeBadge: SnAccountBadge?
    let experience: Int
    let level: Int
    let socialCredits: Double
    let socialCreditsLevel: Int
    let levelingProgress: Double
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let verification: SnVerificationMark?
    let usernameColor: UsernameColor?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case middleName = "middle_name"
        case lastName = "last_name"
        case bio
        case gender
        case pronouns
        case location
        case timeZone = "time_zone"
        case birthday
        case links
        case lastSeenAt = "last_seen_at"
        case activeBadge = "active_badge"
        case experience
        case level
        case socialCredits = "social_credits"
        case socialCreditsLevel = "social_credits_level"
        case levelingProgress = "leveling_progress"
        case picture
        case background
        case verification
        case usernameColor = "username_color"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        pronouns = try container.decodeIfPresent(String.self, forKey: .pronouns) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        timeZone = try container.decodeIfPresent(String.self, forKey: .timeZone) ?? ""
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        links = try container.decodeIfPresent([ProfileLink].self, forKey: .links) ?? []
        lastSeenAt = try container.decodeIfPresent(Date.self, forKey: .lastSeenAt)
        activeBadge = try container.decodeIfPresent(SnAccountBadge.self, forKey: .activeBadge)
        experience = try container.decode(Int.self, forKey: .experience)
        level = try container.decode(Int.self, forKey: .level)
        socialCredits = try container.decodeIfPresent(Double.self, forKey: .socialCredits) ?? 100.0
        socialCreditsLevel = try container.decodeIfPresent(Int.self, forKey: .socialCreditsLevel) ?? 0
        levelingProgress = try container.decode(Double.self, forKey: .levelingProgress)
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        verification = try container.decodeIfPresent(SnVerificationMark.self, forKey: .verification)
        usernameColor = try container.decodeIfPresent(UsernameColor.self, forKey: .usernameColor)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}

struct ProfileLink: Codable {
    let name: String
    let url: String
}

struct UsernameColor: Codable {
    let type: String
    let value: String?
    let direction: String?
    let colors: [String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "plain"
        value = try container.decodeIfPresent(String.self, forKey: .value)
        direction = try container.decodeIfPresent(String.self, forKey: .direction)
        colors = try container.decodeIfPresent([String].self, forKey: .colors)
    }
    
    enum CodingKeys: String, CodingKey {
        case type, value, direction, colors
    }
}

struct SnAccountStatus: Codable {
    let id: String
    let attitude: Int
    let isOnline: Bool
    let isCustomized: Bool
    let type: Int
    let label: String
    let symbol: String?
    let meta: [String: AnyCodable]?
    let clearedAt: Date?
    let appIdentifier: String?
    let isAutomated: Bool
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case attitude
        case isOnline = "is_online"
        case isCustomized = "is_customized"
        case type
        case label
        case symbol
        case meta
        case clearedAt = "cleared_at"
        case appIdentifier = "app_identifier"
        case isAutomated = "is_automated"
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        attitude = try container.decode(Int.self, forKey: .attitude)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        isCustomized = try container.decodeIfPresent(Bool.self, forKey: .isCustomized) ?? false
        
        if let isInvisible = try? container.decodeIfPresent(Bool.self, forKey: .isOnline), isInvisible == true {
            type = 3
        } else if container.contains(.isOnline) {
            type = 0
        } else {
            type = try container.decodeIfPresent(Int.self, forKey: .type) ?? 0
        }
        
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        meta = try container.decodeIfPresent([String: AnyCodable].self, forKey: .meta)
        clearedAt = try container.decodeIfPresent(Date.self, forKey: .clearedAt)
        appIdentifier = try container.decodeIfPresent(String.self, forKey: .appIdentifier)
        isAutomated = try container.decodeIfPresent(Bool.self, forKey: .isAutomated) ?? false
        accountId = try container.decode(String.self, forKey: .accountId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
    
    var isInvisible: Bool {
        type == 3
    }
    
    var isNotDisturb: Bool {
        type == 2
    }
}

// MARK: - Chat Models

struct SnChatRoom: Codable, Identifiable {
    let id: String
    let name: String?
    let description: String?
    let type: Int
    let encryptionMode: Int
    let mlsGroupId: String?
    let isPublic: Bool
    let isCommunity: Bool
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let realmId: String?
    let accountId: String?
    let realm: SnRealm?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let members: [SnChatMember]?
    let isPinned: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case encryptionMode = "encryption_mode"
        case mlsGroupId = "mls_group_id"
        case isPublic = "is_public"
        case isCommunity = "is_community"
        case picture
        case background
        case realmId = "realm_id"
        case accountId = "account_id"
        case realm
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case members
        case isPinned = "is_pinned"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decode(Int.self, forKey: .type)
        encryptionMode = try container.decodeIfPresent(Int.self, forKey: .encryptionMode) ?? 0
        mlsGroupId = try container.decodeIfPresent(String.self, forKey: .mlsGroupId)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        isCommunity = try container.decodeIfPresent(Bool.self, forKey: .isCommunity) ?? false
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        realmId = try container.decodeIfPresent(String.self, forKey: .realmId)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        realm = try container.decodeIfPresent(SnRealm.self, forKey: .realm)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        members = try container.decodeIfPresent([SnChatMember].self, forKey: .members)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }
}

struct SnChatMessage: Codable, Identifiable {
    let id: String
    let type: String
    let content: String?
    let clientMessageId: String?
    let nonce: String?
    let meta: [String: AnyCodable]
    let membersMentioned: [String]
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
        case id, type, content, clientMessageId = "client_message_id", nonce, meta, membersMentioned, editedAt, attachments, reactions, repliedMessageId, forwardedMessageId, senderId, sender, chatRoomId, createdAt, updatedAt, deletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "text"
        content = try container.decodeIfPresent(String.self, forKey: .content)
        clientMessageId = try container.decodeIfPresent(String.self, forKey: .clientMessageId)
        nonce = try container.decodeIfPresent(String.self, forKey: .nonce)
        meta = try container.decodeIfPresent([String: AnyCodable].self, forKey: .meta) ?? [:]
        membersMentioned = try container.decodeIfPresent([String].self, forKey: .membersMentioned) ?? []
        editedAt = try container.decodeIfPresent(Date.self, forKey: .editedAt)
        attachments = try container.decodeIfPresent([SnCloudFile].self, forKey: .attachments) ?? []
        reactions = try container.decodeIfPresent([SnChatReaction].self, forKey: .reactions) ?? []
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
    let lastReadAt: Date?
    let status: SnAccountStatus?
    let realmNick: String?
    let realmBio: String?
    let realmExperience: Int?
    let realmLevel: Int?
    let realmLevelingProgress: Double?
    let realmLabel: SnRealmLabel?
    let lastTyped: Date?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatRoomId = "chat_room_id"
        case chatRoom
        case accountId = "account_id"
        case account
        case nick
        case role
        case notify
        case joinedAt = "joined_at"
        case breakUntil = "break_until"
        case timeoutUntil = "timeout_until"
        case lastReadAt = "last_read_at"
        case status
        case realmNick = "realm_nick"
        case realmBio = "realm_bio"
        case realmExperience = "realm_experience"
        case realmLevel = "realm_level"
        case realmLevelingProgress = "realm_leveling_progress"
        case realmLabel = "realm_label"
        case lastTyped = "last_typed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        chatRoomId = try container.decode(String.self, forKey: .chatRoomId)
        chatRoom = try container.decodeIfPresent(SnChatRoom.self, forKey: .chatRoom)
        accountId = try container.decode(String.self, forKey: .accountId)
        account = try container.decode(SnAccount.self, forKey: .account)
        nick = try container.decodeIfPresent(String.self, forKey: .nick)
        role = try container.decode(Int.self, forKey: .role)
        notify = try container.decode(Int.self, forKey: .notify)
        joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
        breakUntil = try container.decodeIfPresent(Date.self, forKey: .breakUntil)
        timeoutUntil = try container.decodeIfPresent(Date.self, forKey: .timeoutUntil)
        lastReadAt = try container.decodeIfPresent(Date.self, forKey: .lastReadAt)
        status = try container.decodeIfPresent(SnAccountStatus.self, forKey: .status)
        realmNick = try container.decodeIfPresent(String.self, forKey: .realmNick)
        realmBio = try container.decodeIfPresent(String.self, forKey: .realmBio)
        realmExperience = try container.decodeIfPresent(Int.self, forKey: .realmExperience)
        realmLevel = try container.decodeIfPresent(Int.self, forKey: .realmLevel)
        realmLevelingProgress = try container.decodeIfPresent(Double.self, forKey: .realmLevelingProgress)
        realmLabel = try container.decodeIfPresent(SnRealmLabel.self, forKey: .realmLabel)
        lastTyped = try container.decodeIfPresent(Date.self, forKey: .lastTyped)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}

struct SnRealmLabel: Codable, Identifiable {
    let id: String
    let realmId: String
    let name: String
    let description: String?
    let color: String?
    let icon: String?
    let createdByAccountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case realmId = "realm_id"
        case name
        case description
        case color
        case icon
        case createdByAccountId = "created_by_account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
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
    let totalCount: Int
    let currentTimestamp: Date

    enum CodingKeys: String, CodingKey {
        case messages
        case totalCount = "total_count"
        case currentTimestamp = "current_timestamp"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decodeIfPresent([SnChatMessage].self, forKey: .messages) ?? []
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        currentTimestamp = try container.decode(Date.self, forKey: .currentTimestamp)
    }
}
