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
    
    func decodeDiscovery() -> DiscoverySection? {
        guard let data = data?.value as? [String: Any] else { return nil }
        return DiscoverySection(
            eventType: type,
            resourceIdentifier: nil,
            rawData: data
        )
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
    let threadedPost: SnPostReference?
    let repliedPostId: String?
    let repliedPost: SnPostReference?
    let forwardedPostId: String?
    let forwardedPost: SnPostReference?
    let realmId: String?
    let realm: SnRealm?
    let publisherId: String?
    let publisher: SnPublisher?
    let actorid: String?
    let actor: SnActivityPubActor?
    let fediverseUri: String?
    let fediverseType: Int?
    let isCached: Bool?
    let contentType: Int?
    let attachments: [SnCloudFile]?
    let reactionsCount: [String: Int]?
    let reactionsMade: [String: Bool]?
    let reactions: [AnyCodable]?
    let tags: [SnPostTag]?
    let categories: [SnPostCategory]?
    let collections: [AnyCodable]?
    let publisherCollections: [SnPostCollection]?
    let featuredRecords: [AnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let repliedGone: Bool?
    let forwardedGone: Bool?
    let isTruncated: Bool?
    let boostedBy: SnActivityPubActor?
    let boostedAt: Date?
    let sponsored: Bool?
    let isBookmarked: Bool?
    
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
        case threadedPost = "threaded_post"
        case repliedPostId = "replied_post_id"
        case repliedPost = "replied_post"
        case forwardedPostId = "forwarded_post_id"
        case forwardedPost = "forwarded_post"
        case realmId = "realm_id"
        case realm
        case publisherId = "publisher_id"
        case publisher
        case actorid = "actor_id"
        case actor
        case fediverseUri = "fediverse_uri"
        case fediverseType = "fediverse_type"
        case isCached = "is_cached"
        case contentType = "content_type"
        case attachments
        case reactionsCount = "reactions_count"
        case reactionsMade = "reactions_made"
        case reactions, tags, categories, collections
        case publisherCollections = "publisher_collections"
        case featuredRecords = "featured_records"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case repliedGone = "replied_gone"
        case forwardedGone = "forwarded_gone"
        case isTruncated = "is_truncated"
        case boostedBy = "boosted_by"
        case boostedAt = "boosted_at"
        case sponsored
        case isBookmarked = "is_bookmarked"
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

struct SnPostReference: Codable, Identifiable {
    let id: String
    let title: String?
    let content: String?
    let publisher: SnPublisher?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, content, publisher
        case createdAt = "created_at"
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

// MARK: - Discovery Models

/// One discovery event on the timeline (`/sphere/timeline`).
///
/// The server sends `discovery` / `discovery.v2` events whose whole section
/// lives in the event `data`: `{ kind, title?, items: [ { type, data, … } ] }`.
/// The `kind` (realm / publisher / account / article / post) selects the
/// entity type of every item in the section.
struct DiscoverySection: Identifiable {
    let kind: String
    let title: String?
    let items: [DiscoveryItem]

    var id: String { "\(kind)-\(items.count)" }

    /// The visual title for the block: the server-provided custom title when
    /// present, otherwise the kind's canonical label.
    var displayTitle: String {
        if let title = title, !title.isEmpty { return title }
        return Self.defaultTitle(for: kind)
    }

    static func defaultTitle(for kind: String) -> String {
        switch kind {
        case "realm": return "Suggested Realms"
        case "publisher": return "Suggested Publishers"
        case "account": return "Suggested People"
        case "article": return "Articles"
        case "post": return "Shuffled Post"
        default: return "Discover"
        }
    }

    /// Builds a section from the raw `data` of a timeline event. Mirrors the
    /// main app's `_resolveDiscoveryType`: `discovery.v2` reads `data.kind`
    /// (falling back to the last `resource_identifier` segment), then the
    /// first item's own `type`, then `data.kind` again. The resolved kind is
    /// the decode target for every item payload.
    init?(eventType: String, resourceIdentifier: String?, rawData: Any?) {
        guard let dict = rawData as? [String: Any] else { return nil }
        let rawItems = dict["items"] as? [[String: Any]] ?? []

        var kind = ""
        if eventType == "discovery.v2" {
            if let rawKind = dict["kind"] as? String, !rawKind.isEmpty {
                kind = rawKind
            } else if let identifier = resourceIdentifier {
                let parts = identifier.split(separator: ":")
                if let last = parts.last, !last.isEmpty { kind = String(last) }
            }
        }
        if kind.isEmpty, let itemType = rawItems.first?["type"] as? String,
           !itemType.isEmpty {
            kind = itemType
        }
        if kind.isEmpty, let rawKind = dict["kind"] as? String, !rawKind.isEmpty {
            kind = rawKind
        }

        guard !kind.isEmpty else { return nil }
        self.kind = kind
        title = dict["title"] as? String
        // A whole section shares one kind; decode every item with it unless
        // the item declares its own known kind.
        items = rawItems.compactMap { DiscoveryItem(raw: $0, sectionKind: kind) }
    }
}

/// A single entry inside a discovery section.
struct DiscoveryItem: Identifiable {
    var id = UUID()

    /// Item-level entity kind as declared by the server (`items[].type`).
    let rawType: String?
    let rank: String?
    let score: Double?
    let reasons: [String]
    let payload: DiscoveryItemPayload

    var kind: String {
        payload.kind
    }

    init?(raw: [String: Any], sectionKind: String) {
        rawType = raw["type"] as? String
        rank = raw["rank"] as? String
        if let rawScore = raw["score"] as? NSNumber {
            score = rawScore.doubleValue
        } else {
            score = raw["score"] as? Double
        }
        reasons = (raw["reasons"] as? [Any])?.compactMap { $0 as? String } ?? []

        let itemData = raw["data"] as? [String: Any] ?? raw
        // The item's own known type wins; otherwise the section's resolved
        // kind decodes it. Either way the payload is decoded once, with the
        // matching model only.
        let knownKinds = ["realm", "publisher", "account", "article", "post"]
        let effectiveKind: String
        if let declared = rawType, knownKinds.contains(declared) {
            effectiveKind = declared
        } else if let declared = rawType,
                  let lastSegment = declared.split(separator: ":").last,
                  knownKinds.contains(String(lastSegment)) {
            effectiveKind = String(lastSegment)
        } else {
            effectiveKind = sectionKind
        }
        payload = DiscoveryItemPayload(raw: itemData, kind: effectiveKind)
    }
}

/// A discovery payload decoded from its declared kind: the item's own `type`
/// when it is a known kind, otherwise the enclosing section's `kind`. The
/// entity is then decoded only with the matching model, so a publisher payload
/// can never "decode successfully" as a post just because both are dicts.
enum DiscoveryItemPayload {
    case realm(SnRealm)
    case publisher(SnPublisher)
    case account(SnAccount)
    case article(SnWebArticle)
    case post(SnPost)
    case unknown

    var kind: String {
        switch self {
        case .realm: return "realm"
        case .publisher: return "publisher"
        case .account: return "account"
        case .article: return "article"
        case .post: return "post"
        case .unknown: return "unknown"
        }
    }

    /// Entity id used as the feedback/uninterested reference.
    var referenceId: String {
        switch self {
        case .realm(let realm): return realm.id
        case .publisher(let publisher): return publisher.id
        case .account(let account): return account.id
        case .article(let article): return article.id
        case .post(let post): return post.id
        case .unknown: return ""
        }
    }

    init(raw: [String: Any], kind: String) {
        switch kind {
        case "realm":
            self = DiscoveryItemPayload.decode(SnRealm.self, from: raw).map(Self.realm) ?? .unknown
        case "publisher":
            self = DiscoveryItemPayload.decode(SnPublisher.self, from: raw).map(Self.publisher) ?? .unknown
        case "account":
            self = DiscoveryItemPayload.decode(SnAccount.self, from: raw).map(Self.account) ?? .unknown
        case "article":
            self = DiscoveryItemPayload.decode(SnWebArticle.self, from: raw).map(Self.article) ?? .unknown
        case "post":
            self = DiscoveryItemPayload.decode(SnPost.self, from: raw).map(Self.post) ?? .unknown
        default:
            self = .unknown
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from raw: [String: Any]) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: raw) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }
}

struct SnRealm: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String
    let description: String?
    let verifiedAs: String?
    let verifiedAt: Date?
    let isCommunity: Bool?
    let isPublic: Bool?
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let accountId: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let boostPoints: Int
    let boostLevel: Int
    let resourceIdentifier: String?
    let verification: SnVerificationMark?
    
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
        case resourceIdentifier = "resource_identifier"
        case verification
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        slug = try container.decode(String.self, forKey: .slug)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        verifiedAs = try container.decodeIfPresent(String.self, forKey: .verifiedAs)
        verifiedAt = try container.decodeIfPresent(Date.self, forKey: .verifiedAt)
        isCommunity = try container.decodeIfPresent(Bool.self, forKey: .isCommunity)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        boostPoints = try container.decodeIfPresent(Int.self, forKey: .boostPoints) ?? 0
        boostLevel = try container.decodeIfPresent(Int.self, forKey: .boostLevel) ?? 0
        resourceIdentifier = try container.decodeIfPresent(String.self, forKey: .resourceIdentifier)
        verification = try container.decodeIfPresent(SnVerificationMark.self, forKey: .verification)
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
    let isShadowbanned: Bool
    let isGatekept: Bool
    let isModerateSubscription: Bool
    let rating: Double
    let ratingLevel: Int
    
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
        case isShadowbanned = "is_shadowbanned"
        case isGatekept = "is_gatekept"
        case isModerateSubscription = "is_moderate_subscription"
        case rating
        case ratingLevel = "rating_level"
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
        isShadowbanned = try container.decodeIfPresent(Bool.self, forKey: .isShadowbanned) ?? false
        isGatekept = try container.decodeIfPresent(Bool.self, forKey: .isGatekept) ?? false
        isModerateSubscription = try container.decodeIfPresent(Bool.self, forKey: .isModerateSubscription) ?? false
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 100
        ratingLevel = try container.decodeIfPresent(Int.self, forKey: .ratingLevel) ?? 0
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
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let url: String?
    let hasCompression: Bool?
    let width: Int?
    let height: Int?
    let blurhash: String?
    
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
        case hasCompression = "has_compression"
        case width
        case height
        case blurhash
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // `name` and `description` are not always present on referenced
        // files (e.g. profile/room avatars), so default them rather than fail
        // the whole decode.
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description)
        fileMeta = try container.decodeIfPresent([String: AnyCodable].self, forKey: .fileMeta)
        userMeta = try container.decodeIfPresent([String: AnyCodable].self, forKey: .userMeta)
        sensitiveMarks = try container.decodeIfPresent([Int].self, forKey: .sensitiveMarks)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        hash = try container.decodeIfPresent(String.self, forKey: .hash)
        size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 0
        uploadedAt = try container.decodeIfPresent(Date.self, forKey: .uploadedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        hasCompression = try container.decodeIfPresent(Bool.self, forKey: .hasCompression)
        width = try container.decodeIfPresent(Int.self, forKey: .width)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        blurhash = try container.decodeIfPresent(String.self, forKey: .blurhash)
    }
}

struct SnPostTag: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String?
    let isProtected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, slug, name
        case isProtected = "is_protected"
    }

    var displayName: String {
        tagDisplayName(slug, name: name)
    }
}

struct SnPostCategory: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String?
    let usage: Int?

    var displayName: String {
        name ?? localizedCategoryName(slug)
    }
}

struct SnPostCollection: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String?
    let description: String?
    let publisherId: String
    let publisher: SnPublisher?
    let background: SnCloudFile?
    let icon: SnCloudFile?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, description, publisher, background, icon
        case publisherId = "publisher_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
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
        if type == "posts.new" || type == "posts.new.replies" {
            return true
        }
        guard let data = data?.value as? [String: Any] else { return false }
        return data["title"] != nil || data["content"] != nil || data["publisher"] != nil
    }
    
    var isDiscovery: Bool {
        if type == "discovery" || type == "discovery.v2" {
            return true
        }
        guard let data = data?.value as? [String: Any] else { return false }
        return data["items"] != nil
    }
    
    /// Friend presence (e.g. a friend is gaming / listening to music).
    var isFriendPresence: Bool {
        type == "presence.friend"
    }
    
    /// Friend status update.
    var isFriendStatus: Bool {
        type == "status.friend"
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
    
    func decodeDiscovery() -> DiscoverySection? {
        guard let data = data?.value as? [String: Any] else { return nil }

        // AnyCodable trees keep nested dictionaries as [String: AnyCodable];
        // flatten them back to JSON-safe dictionaries before decoding.
        let cleanData = convertToValidJsonTypes(data)
        guard let cleanDict = cleanData as? [String: Any] else { return nil }
        return DiscoverySection(
            eventType: type,
            resourceIdentifier: resourceIdentifier,
            rawData: cleanDict
        )
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
        } else if let codableDict = value as? [String: AnyCodable] {
            var result: [String: Any] = [:]
            for (k, v) in codableDict {
                result[k] = convertToValidJsonTypes(v)
            }
            return result
        } else if let array = value as? [Any] {
            return array.map { convertToValidJsonTypes($0) }
        } else if let codableArray = value as? [AnyCodable] {
            return codableArray.map { convertToValidJsonTypes($0) }
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

// MARK: - Explore API Models

struct PostListResponse {
    let posts: [SnPost]
    let total: Int
    var hasMore: Bool { posts.count < total }
}

/// A paginated-list result shared by categories/tags feeds.
struct EntityListResponse<T> {
    let items: [T]
    let total: Int
    var hasMore: Bool { items.count < total }
}

/// One row of `GET /sphere/publishers/subscriptions`:
/// `{ subscription: { account_id, publisher_id, publisher }, last_read_at?,
///    latest_content_at?, has_new_content?, is_live? }`.
/// Fields decode via explicit CodingKeys (no `.convertFromSnakeCase`).
struct SnPublisherSubscriptionRow: Codable {
    let subscription: SnPublisherSubscription
    let lastReadAt: Date?
    let latestContentAt: Date?
    let hasNewContent: Bool
    let isLive: Bool

    enum CodingKeys: String, CodingKey {
        case subscription
        case lastReadAt = "last_read_at"
        case latestContentAt = "latest_content_at"
        case hasNewContent = "has_new_content"
        case isLive = "is_live"
    }
}

/// `{ account_id, publisher_id, publisher }`.
struct SnPublisherSubscription: Codable {
    let accountId: String?
    let publisherId: String
    let publisher: SnPublisher

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case publisherId = "publisher_id"
        case publisher
    }
}

/// One row of `GET /sphere/categories/subscriptions`: either a category
/// (`category_id` + `category`) or a tag (`tag_id` + `tag`).
struct SnCategorySubscription: Codable {
    let id: String
    let categoryId: String?
    let category: SnPostCategory?
    let tagId: String?
    let tag: SnPostTag?

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case category
        case tagId = "tag_id"
        case tag
    }
}

struct SnAccount: Codable {
    let id: String
    let name: String
    let nick: String
    let language: String
    let region: String
    let isSuperuser: Bool?
    let automatedId: String?
    let profile: SnUserProfile?
    let perkSubscription: SnWalletSubscriptionRef?
    let badges: [SnAccountBadge]
    let contacts: [SnContactMethod]
    let activatedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let accountId: String?
    let resourceIdentifier: String?
    let perkLevel: Int?
    
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
        case accountId = "account_id"
        case resourceIdentifier = "resource_identifier"
        case perkLevel = "perk_level"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nick = try container.decode(String.self, forKey: .nick)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
        region = try container.decodeIfPresent(String.self, forKey: .region) ?? ""
        isSuperuser = try container.decodeIfPresent(Bool.self, forKey: .isSuperuser)
        automatedId = try container.decodeIfPresent(String.self, forKey: .automatedId)
        profile = try? container.decodeIfPresent(SnUserProfile.self, forKey: .profile)
        perkSubscription = try container.decodeIfPresent(SnWalletSubscriptionRef.self, forKey: .perkSubscription)
        badges = try container.decodeIfPresent([SnAccountBadge].self, forKey: .badges) ?? []
        contacts = try container.decodeIfPresent([SnContactMethod].self, forKey: .contacts) ?? []
        activatedAt = try container.decodeIfPresent(Date.self, forKey: .activatedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        accountId = try? container.decode(String.self, forKey: .accountId)
        resourceIdentifier = try? container.decodeIfPresent(String.self, forKey: .resourceIdentifier)
        perkLevel = try? container.decodeIfPresent(Int.self, forKey: .perkLevel)
    }
}

struct SnWalletSubscriptionRef: Codable {
    let id: String?
    let identifier: String?
    let groupIdentifier: String?
    let displayName: String?
    let subscriptionId: String?
    let subscriptionType: String?
    let perkLevel: Int?
    let isTesting: Bool?
    let begunAt: Date?
    let endedAt: Date?
    let expiredAt: Date?
    let isActive: Bool?
    let isAvailable: Bool?
    let isFreeTrial: Bool?
    let status: Int?
    let basePrice: Int?
    let finalPrice: Int?
    let renewalAt: Date?
    let accountId: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case groupIdentifier = "group_identifier"
        case displayName = "display_name"
        case subscriptionId = "subscription_id"
        case subscriptionType = "subscription_type"
        case perkLevel = "perk_level"
        case isTesting = "is_testing"
        case begunAt = "begun_at"
        case endedAt = "ended_at"
        case expiredAt = "expired_at"
        case isActive = "is_active"
        case isAvailable = "is_available"
        case isFreeTrial = "is_free_trial"
        case status
        case basePrice = "base_price"
        case finalPrice = "final_price"
        case renewalAt = "renewal_at"
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
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
    let isPrimary: Bool?
    let isPublic: Bool?
    let content: String
    let accountId: String?
    let createdAt: Date?
    let updatedAt: Date?
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
    let createdAt: Date?
    let updatedAt: Date?
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
        experience = try container.decodeIfPresent(Int.self, forKey: .experience) ?? 0
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        socialCredits = try container.decodeIfPresent(Double.self, forKey: .socialCredits) ?? 100.0
        socialCreditsLevel = try container.decodeIfPresent(Int.self, forKey: .socialCreditsLevel) ?? 0
        levelingProgress = try container.decodeIfPresent(Double.self, forKey: .levelingProgress) ?? 0.0
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        verification = try container.decodeIfPresent(SnVerificationMark.self, forKey: .verification)
        usernameColor = try container.decodeIfPresent(UsernameColor.self, forKey: .usernameColor)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
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
    let attitude: Int?
    let isOnline: Bool?
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
        attitude = try container.decodeIfPresent(Int.self, forKey: .attitude)
        isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline)
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
        accountId = (try? container.decode(String.self, forKey: .accountId)) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
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
    let e2eePolicy: String?
    let isPublic: Bool
    let isCommunity: Bool
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let realmId: String?
    let accountId: String?
    let account: SnAccount?
    let realm: SnRealm?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let members: [SnChatMember]?
    let isPinned: Bool
    let resourceIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case encryptionMode = "encryption_mode"
        case mlsGroupId = "mls_group_id"
        case e2eePolicy = "e2ee_policy"
        case isPublic = "is_public"
        case isCommunity = "is_community"
        case picture
        case background
        case realmId = "realm_id"
        case accountId = "account_id"
        case account
        case realm
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case members
        case isPinned = "is_pinned"
        case resourceIdentifier = "resource_identifier"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decodeIfPresent(Int.self, forKey: .type) ?? 0
        encryptionMode = try container.decodeIfPresent(Int.self, forKey: .encryptionMode) ?? 0
        mlsGroupId = try container.decodeIfPresent(String.self, forKey: .mlsGroupId)
        e2eePolicy = try container.decodeIfPresent(String.self, forKey: .e2eePolicy)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        isCommunity = try container.decodeIfPresent(Bool.self, forKey: .isCommunity) ?? false
        picture = try container.decodeIfPresent(SnCloudFile.self, forKey: .picture)
        background = try container.decodeIfPresent(SnCloudFile.self, forKey: .background)
        realmId = try container.decodeIfPresent(String.self, forKey: .realmId)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        account = try container.decodeIfPresent(SnAccount.self, forKey: .account)
        realm = try container.decodeIfPresent(SnRealm.self, forKey: .realm)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        members = try container.decodeIfPresent([SnChatMember].self, forKey: .members)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        resourceIdentifier = try container.decodeIfPresent(String.self, forKey: .resourceIdentifier)
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
        case id, type, content, nonce, meta, attachments, reactions, sender
        case clientMessageId = "client_message_id"
        case membersMentioned = "members_mentioned"
        case editedAt = "edited_at"
        case repliedMessageId = "replied_message_id"
        case forwardedMessageId = "forwarded_message_id"
        case senderId = "sender_id"
        case chatRoomId = "chat_room_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
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
        // Live `messages.new` packets may omit a field for one frame; default
        // so a real message still renders instead of dropping the whole row.
        senderId = try container.decodeIfPresent(String.self, forKey: .senderId) ?? ""
        sender = try container.decodeIfPresent(SnChatMember.self, forKey: .sender) ?? .fallback
        chatRoomId = try container.decodeIfPresent(String.self, forKey: .chatRoomId) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }

    /// Explicit memberwise init (a custom `init(from:)` suppresses the
    /// synthesized one) — used for optimistic pending messages and tests.
    init(
        id: String,
        type: String,
        content: String?,
        clientMessageId: String?,
        nonce: String?,
        meta: [String: AnyCodable],
        membersMentioned: [String],
        editedAt: Date?,
        attachments: [SnCloudFile],
        reactions: [SnChatReaction],
        repliedMessageId: String?,
        forwardedMessageId: String?,
        senderId: String,
        sender: SnChatMember,
        chatRoomId: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.clientMessageId = clientMessageId
        self.nonce = nonce
        self.meta = meta
        self.membersMentioned = membersMentioned
        self.editedAt = editedAt
        self.attachments = attachments
        self.reactions = reactions
        self.repliedMessageId = repliedMessageId
        self.forwardedMessageId = forwardedMessageId
        self.senderId = senderId
        self.sender = sender
        self.chatRoomId = chatRoomId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

/// Timeline rendering helpers for a chat message.
extension SnChatMessage {
    /// Whether the message belongs in the chat timeline. Sync/mutation
    /// envelopes and system rows are consumed to update other messages rather
    /// than rendered as their own bubbles (Flutter's `isChatMessageMutationEnvelope`
    /// + system `state.*` rows). Deleted messages stay as inline system rows.
    var isDisplayable: Bool {
        if type == "messages.delete" || deletedAt != nil { return true }
        switch type {
        case "messages.update",
             "messages.sync.file",
             "messages.sync.finalize",
             "messages.sync.links",
             "messages.reaction.added",
             "messages.reaction.removed",
             "placeholder",
             "system.e2ee.enabled",
             "system.e2ee.history_unavailable",
             "content.new",
             "content.edit",
             "content.delete":
            return false
        default:
            // `messages.new`, `messages.pinned`, `messages.unpinned` and plain
            // `text`/`voice` are real timeline rows.
            return true
        }
    }

    /// Whether this row is a user-visible deletion placeholder.
    var isDeletedRow: Bool {
        type == "messages.delete" || deletedAt != nil
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

    enum CodingKeys: String, CodingKey {
        case id, symbol, sender
        case messageId = "message_id"
        case senderId = "sender_id"
        case attitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        messageId = try container.decodeIfPresent(String.self, forKey: .messageId) ?? ""
        senderId = try container.decodeIfPresent(String.self, forKey: .senderId) ?? ""
        sender = try container.decodeIfPresent(SnChatMember.self, forKey: .sender) ?? SnChatMember.fallback
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        attitude = try container.decodeIfPresent(Int.self, forKey: .attitude) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}

struct SnChatMember: Codable, Identifiable {
    let id: String
    let chatRoomId: String?
    let chatRoom: SnChatRoom?
    let accountId: String?
    let account: SnAccount?
    let nick: String?
    let role: Int?
    let notify: Int?
    let joinedAt: Date?
    let leaveAt: Date?
    let invitedById: String?
    let breakUntil: Date?
    let timeoutUntil: Date?
    let timeoutCause: String?
    let lastReadAt: Date?
    let status: SnAccountStatus?
    let realmNick: String?
    let realmBio: String?
    let realmExperience: Int?
    let realmLevel: Int?
    let realmLevelingProgress: Double?
    let realmLabel: SnRealmLabel?
    let lastTyped: Date?
    let createdAt: Date?
    let updatedAt: Date?
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
        case leaveAt = "leave_at"
        case invitedById = "invited_by_id"
        case breakUntil = "break_until"
        case timeoutUntil = "timeout_until"
        case timeoutCause = "timeout_cause"
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
        chatRoomId = try container.decodeIfPresent(String.self, forKey: .chatRoomId)
        chatRoom = try container.decodeIfPresent(SnChatRoom.self, forKey: .chatRoom)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        account = try container.decodeIfPresent(SnAccount.self, forKey: .account)
        nick = try container.decodeIfPresent(String.self, forKey: .nick)
        role = try container.decodeIfPresent(Int.self, forKey: .role)
        notify = try container.decodeIfPresent(Int.self, forKey: .notify)
        joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
        leaveAt = try container.decodeIfPresent(Date.self, forKey: .leaveAt)
        invitedById = try container.decodeIfPresent(String.self, forKey: .invitedById)
        breakUntil = try container.decodeIfPresent(Date.self, forKey: .breakUntil)
        timeoutUntil = try container.decodeIfPresent(Date.self, forKey: .timeoutUntil)
        timeoutCause = try container.decodeIfPresent(String.self, forKey: .timeoutCause)
        lastReadAt = try container.decodeIfPresent(Date.self, forKey: .lastReadAt)
        status = try container.decodeIfPresent(SnAccountStatus.self, forKey: .status)
        realmNick = try container.decodeIfPresent(String.self, forKey: .realmNick)
        realmBio = try container.decodeIfPresent(String.self, forKey: .realmBio)
        realmExperience = try container.decodeIfPresent(Int.self, forKey: .realmExperience)
        realmLevel = try container.decodeIfPresent(Int.self, forKey: .realmLevel)
        realmLevelingProgress = try container.decodeIfPresent(Double.self, forKey: .realmLevelingProgress)
        realmLabel = try container.decodeIfPresent(SnRealmLabel.self, forKey: .realmLabel)
        lastTyped = try container.decodeIfPresent(Date.self, forKey: .lastTyped)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }

    init(
        id: String,
        chatRoomId: String?,
        chatRoom: SnChatRoom?,
        accountId: String?,
        account: SnAccount?,
        nick: String?,
        role: Int?,
        notify: Int?,
        joinedAt: Date?,
        leaveAt: Date?,
        invitedById: String?,
        breakUntil: Date?,
        timeoutUntil: Date?,
        timeoutCause: String?,
        lastReadAt: Date?,
        status: SnAccountStatus?,
        realmNick: String?,
        realmBio: String?,
        realmExperience: Int?,
        realmLevel: Int?,
        realmLevelingProgress: Double?,
        realmLabel: SnRealmLabel?,
        lastTyped: Date?,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
    ) {
        self.id = id
        self.chatRoomId = chatRoomId
        self.chatRoom = chatRoom
        self.accountId = accountId
        self.account = account
        self.nick = nick
        self.role = role
        self.notify = notify
        self.joinedAt = joinedAt
        self.leaveAt = leaveAt
        self.invitedById = invitedById
        self.breakUntil = breakUntil
        self.timeoutUntil = timeoutUntil
        self.timeoutCause = timeoutCause
        self.lastReadAt = lastReadAt
        self.status = status
        self.realmNick = realmNick
        self.realmBio = realmBio
        self.realmExperience = realmExperience
        self.realmLevel = realmLevel
        self.realmLevelingProgress = realmLevelingProgress
        self.realmLabel = realmLabel
        self.lastTyped = lastTyped
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    /// Display name for this member: the house nick if set, else the account
    /// nick, else the account name, else a placeholder.
    var displayName: String {
        if let nick = nick, !nick.isEmpty { return nick }
        if let account = account {
            if !account.nick.isEmpty { return account.nick }
            if !account.name.isEmpty { return account.name }
        }
        return "User \(id.prefix(6))"
    }

    /// A minimal member used when a nested decode is missing or optional.
    static let fallback = SnChatMember(
        id: "",
        chatRoomId: nil,
        chatRoom: nil,
        accountId: nil,
        account: nil,
        nick: nil,
        role: nil,
        notify: nil,
        joinedAt: nil,
        leaveAt: nil,
        invitedById: nil,
        breakUntil: nil,
        timeoutUntil: nil,
        timeoutCause: nil,
        lastReadAt: nil,
        status: nil,
        realmNick: nil,
        realmBio: nil,
        realmExperience: nil,
        realmLevel: nil,
        realmLevelingProgress: nil,
        realmLabel: nil,
        lastTyped: nil,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0),
        deletedAt: nil
    )
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

    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
        case lastMessage = "last_message"
    }

    init(unreadCount: Int, lastMessage: SnChatMessage?) {
        self.unreadCount = unreadCount
        self.lastMessage = lastMessage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
        lastMessage = try container.decodeIfPresent(SnChatMessage.self, forKey: .lastMessage)
    }
}

struct ChatRoomsResponse {
    let rooms: [SnChatRoom]
    let totalCount: Int

    /// Mirrors Flutter's `PaginatedResult.hasMore`; when `totalCount` is
    /// unknown (no `X-Total` header) we conservatively assume more may exist.
    var hasMore: Bool {
        guard totalCount > 0 else { return false }
        return rooms.count < totalCount
    }
}

struct ChatInvitesResponse {
    let invites: [SnChatMember]
}

/// Paginated message result mirroring Flutter's `FetchMessagesResult`:
/// the server reports the full count in the `x-total` response header.
struct ChatMessagesResult {
    let messages: [SnChatMessage]
    let totalCount: Int

    var hasMore: Bool { messages.count < totalCount }
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
