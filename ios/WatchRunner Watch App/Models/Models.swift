//
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
