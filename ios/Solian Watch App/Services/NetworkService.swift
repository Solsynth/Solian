//
//  NetworkService.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29. //

import Combine
import Foundation

// MARK: - WebSocket Data Structures

enum WebSocketState: Equatable {
    case connected
    case connecting
    case disconnected
    case serverDown
    case duplicateDevice
    case error(String)
    
    // Equatable conformance
    static func == (lhs: WebSocketState, rhs: WebSocketState) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected),
            (.connecting, .connecting),
            (.disconnected, .disconnected),
            (.serverDown, .serverDown),
            (.duplicateDevice, .duplicateDevice):
            return true
        case let (.error(a), .error(b)):
            return a == b
        default:
            return false
        }
    }
}

struct WebSocketPacket {
    let type: String
    let data: [String: Any]?
    let endpoint: String?
    let errorMessage: String?
}

// MARK: - Network Service

class NetworkService {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        session = URLSession(configuration: config)
    }
    
    // Add a serial queue for WebSocket operations
    private let webSocketQueue = DispatchQueue(label: "com.solian.websocketQueue")
    
    func fetchTimeline(filter: String?, cursor: String? = nil, mode: String = "personalized", aggressive: Bool = true, token: String, serverUrl: String) async throws -> ActivityResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/sphere/timeline"), resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "take", value: "20"),
            URLQueryItem(name: "mode", value: mode),
            URLQueryItem(name: "aggressive", value: aggressive ? "true" : "false")
        ]
        
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        // filter is optional - only add if not nil and not "explore"
        if let filter = filter, filter.lowercased() != "explore" {
            queryItems.append(URLQueryItem(name: "filter", value: filter.lowercased()))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // The response has an "items" wrapper
        let responseWrapper = try decoder.decode(TimelineResponseWrapper.self, from: data)
        
        let activities = responseWrapper.items
        
        let hasMore = responseWrapper.nextCursor != nil && !responseWrapper.nextCursor!.isEmpty
        let nextCursor = responseWrapper.nextCursor
        
        return ActivityResponse(activities: activities, hasMore: hasMore, nextCursor: nextCursor)
    }

    // MARK: - Explore API

    /// GET /sphere/publishers/subscriptions (paginated, ordered by latest
    /// public root post). Each row: { subscription: { account_id,
    /// publisher_id, publisher }, last_read_at?, latest_content_at?,
    /// has_new_content?, is_live? }.
    func fetchPublisherSubscriptions(token: String, serverUrl: String) async throws -> [SnPublisherSubscriptionRow] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/sphere/publishers/subscriptions"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "order", value: "latest_posted_at"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "take", value: "100"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        return try Self.decodeJSON([SnPublisherSubscriptionRow].self, from: data)
    }

    /// POST /sphere/publishers/{name}/subscribe — follow a publisher.
    func subscribePublisher(name: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/publishers/\(name)/subscribe", token: token, serverUrl: serverUrl)
    }

    /// POST /sphere/publishers/{name}/unsubscribe — unfollow a publisher.
    func unsubscribePublisher(name: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/publishers/\(name)/unsubscribe", token: token, serverUrl: serverUrl)
    }

    /// GET /sphere/categories/subscriptions — subscribed categories & tags.
    func fetchCategorySubscriptions(token: String, serverUrl: String) async throws -> [SnCategorySubscription] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/categories/subscriptions")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        return try Self.decodeJSON([SnCategorySubscription].self, from: data)
    }

    /// GET /sphere/posts/categories?order=popularity — popular categories.
    func fetchPopularCategories(token: String, serverUrl: String, take: Int = 5) async throws -> [SnPostCategory] {
        try await fetchCategories(order: "popularity", take: take, token: token, serverUrl: serverUrl)
    }

    /// GET /sphere/posts/categories?order=usage — all categories.
    func fetchCategories(token: String, serverUrl: String, take: Int = 100) async throws -> [SnPostCategory] {
        try await fetchCategories(order: "usage", take: take, token: token, serverUrl: serverUrl)
    }

    private func fetchCategories(order: String, take: Int, token: String, serverUrl: String) async throws -> [SnPostCategory] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/sphere/posts/categories"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "take", value: "\(take)"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        return try Self.decodeJSON([SnPostCategory].self, from: data)
    }

    /// GET /sphere/posts/tags?order=popularity — popular tags.
    func fetchPopularTags(token: String, serverUrl: String, take: Int = 5) async throws -> [SnPostTag] {
        try await fetchTags(order: "popularity", take: take, token: token, serverUrl: serverUrl)
    }

    /// GET /sphere/posts/tags?order=usage — all tags.
    func fetchTags(token: String, serverUrl: String, take: Int = 100) async throws -> [SnPostTag] {
        try await fetchTags(order: "usage", take: take, token: token, serverUrl: serverUrl)
    }

    private func fetchTags(order: String, take: Int, token: String, serverUrl: String) async throws -> [SnPostTag] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/sphere/posts/tags"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "take", value: "\(take)"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        return try Self.decodeJSON([SnPostTag].self, from: data)
    }

    /// GET /sphere/posts — filtered post list (filtered feed, category feed,
    /// tag feed, publisher feed, shuffle).
    func fetchPosts(
        take: Int = 20,
        offset: Int = 0,
        publishers: [String]? = nil,
        pubName: String? = nil,
        categories: [String]? = nil,
        tags: [String]? = nil,
        shuffle: Bool = false,
        replies: Bool = false,
        token: String,
        serverUrl: String
    ) async throws -> PostListResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/sphere/posts"),
            resolvingAgainstBaseURL: false
        )!

        var query: [URLQueryItem] = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "take", value: "\(take)"),
            URLQueryItem(name: "replies", value: replies ? "true" : "false"),
            URLQueryItem(name: "orderDesc", value: "true"),
        ]
        if shuffle {
            query.append(URLQueryItem(name: "shuffle", value: "true"))
        }
        if let pubName = pubName {
            query.append(URLQueryItem(name: "pub", value: pubName))
        }
        for publisher in publishers ?? [] {
            query.append(URLQueryItem(name: "pub", value: publisher))
        }
        for category in categories ?? [] {
            query.append(URLQueryItem(name: "categories", value: category))
        }
        for tag in tags ?? [] {
            query.append(URLQueryItem(name: "tags", value: tag))
        }
        components.queryItems = query

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        let http = response as? HTTPURLResponse
        let total = Int(http?.value(forHTTPHeaderField: "X-Total") ?? "0") ?? 0
        let posts = try Self.decodeJSON([SnPost].self, from: data)
        return PostListResponse(posts: posts, total: total)
    }

    /// POST /sphere/categories/{slug}/subscribe — follow a category.
    func subscribeCategory(slug: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/categories/\(slug)/subscribe", token: token, serverUrl: serverUrl)
    }

    /// POST /sphere/categories/{slug}/unsubscribe — unfollow a category.
    func unsubscribeCategory(slug: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/categories/\(slug)/unsubscribe", token: token, serverUrl: serverUrl)
    }

    /// POST /sphere/timeline/discovery/uninterested — hide a suggestion.
    func markDiscoveryUninterested(kind: String, referenceId: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/timeline/discovery/uninterested")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: ["kind": kind, "reference_id": referenceId]
        )
        _ = try await session.data(for: request)
    }

    /// POST /sphere/timeline/discovery/feedback — good/bad signal.
    func submitDiscoveryFeedback(
        kind: String,
        referenceId: String,
        good: Bool,
        token: String,
        serverUrl: String
    ) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/timeline/discovery/feedback")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: [
                "kind": kind,
                "reference_id": referenceId,
                "feedback": good ? "good" : "bad",
            ]
        )
        _ = try await session.data(for: request)
    }

    // MARK: - Explore helpers

    private func postEmpty(path: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        _ = try await session.data(for: request)
    }

    private static func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // NOTE: no `.convertFromSnakeCase` here. Every model declares its own
        // snake_case CodingKeys (SnPost/SnPublisher/SnRealm/… have custom
        // `init(from:)`), and `.convertFromSnakeCase` rewrites those explicit
        // raw key strings, breaking fields like `replies_count` / `views`.
        return try decoder.decode(type, from: data)
    }
    
    func createPost(content: String, visibility: Int = 0, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/posts")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let body: [String: Any] = [
            "content": content,
            "visibility": visibility
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("[watchOS] POST createPost - URL: \(url.absoluteString), body: \(body)")
        print("[watchOS] createPost - token prefix: \(String(token.prefix(20)))...")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[watchOS] createPost response - status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 201 {
                let responseBody = String(data: data, encoding: .utf8) ?? ""
                print("[watchOS] createPost failed - body: \(responseBody)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
    }
    
    func replyToPost(postId: String, content: String, visibility: Int = 0, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/posts")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let body: [String: Any] = [
            "content": content,
            "visibility": visibility,
            "reply_to": postId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("[watchOS] POST replyToPost - URL: \(url.absoluteString), body: \(body)")
        print("[watchOS] replyToPost - token prefix: \(String(token.prefix(20)))...")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[watchOS] replyToPost response - status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 201 {
                let responseBody = String(data: data, encoding: .utf8) ?? ""
                print("[watchOS] replyToPost failed - body: \(responseBody)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
    }
    
    func fetchNotifications(offset: Int = 0, take: Int = 20, token: String, serverUrl: String) async throws -> NotificationResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/metoer/notifications"), resolvingAgainstBaseURL: false)!
        let queryItems = [URLQueryItem(name: "offset", value: String(offset)), URLQueryItem(name: "take", value: String(take))]
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let notifications = try decoder.decode([SnNotification].self, from: data)
        
        let httpResponse = response as? HTTPURLResponse
        let total = Int(httpResponse?.value(forHTTPHeaderField: "X-Total") ?? "0") ?? 0
        let hasMore = offset + notifications.count < total
        
        return NotificationResponse(notifications: notifications, total: total, hasMore: hasMore)
    }
    
    func fetchUserProfile(token: String, serverUrl: String) async throws -> SnAccount {
        print("[NetworkService] fetchUserProfile - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        
        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchUserProfile - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }
        // Moved from Passport to Stargate: the edge serves /stargate/** and
        // Blade routes it to Stargate's /api/accounts/me. The legacy
        // /passport/accounts/me is no longer rewritten for new tokens.
        let url = baseURL.appendingPathComponent("/stargate/accounts/me")
        print("[NetworkService] fetchUserProfile - url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[NetworkService] fetchUserProfile - statusCode: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let account = try decoder.decode(SnAccount.self, from: data)
            print("[NetworkService] fetchUserProfile - decode success, account: \(account.nick)")
            return account
        } catch {
            print("[NetworkService] fetchUserProfile - decode error: \(error)")
            print("[NetworkService] fetchUserProfile - raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw error
        }
    }
    
    func fetchAccountStatus(token: String, serverUrl: String) async throws -> SnAccountStatus? {
        print("[NetworkService] fetchAccountStatus - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        
        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchAccountStatus - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/accounts/me/statuses")
        print("[NetworkService] fetchAccountStatus - url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[NetworkService] fetchAccountStatus - statusCode: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 404 {
                print("[NetworkService] fetchAccountStatus - no status found")
                return nil
            }
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let status = try decoder.decode(SnAccountStatus.self, from: data)
        print("[NetworkService] fetchAccountStatus - success")
        return status
    }
    
    func createOrUpdateStatus(attitude: Int, statusType: Int, clearedAt: Date?, label: String?, symbol: String?, token: String, serverUrl: String) async throws -> SnAccountStatus {
        // Check if there's already a customized status
        let existingStatus = try? await fetchAccountStatus(token: token, serverUrl: serverUrl)
        let method = (existingStatus?.isCustomized == true) ? "PATCH" : "POST"
        
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/accounts/me/statuses")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        var body: [String: Any] = [
            "attitude": attitude,
            "type": statusType,
        ]
        
        if let clearedAt = clearedAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            body["cleared_at"] = formatter.string(from: clearedAt)
        }
        
        if let label = label, !label.isEmpty {
            body["label"] = label
        }
        
        if let symbol = symbol, !symbol.isEmpty {
            body["symbol"] = symbol
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] createOrUpdateStatus failed with status code: \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(SnAccountStatus.self, from: data)
    }
    
    func clearStatus(token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/accounts/me/statuses")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] clearStatus failed with status code: \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
    }
    
    // MARK: - Reactions API
    
    func reactToPost(postId: String, symbol: String, attitude: Int, token: String, serverUrl: String) async throws -> Bool {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/posts/\(postId)/reactions")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let body: [String: Any] = ["symbol": symbol, "attitude": attitude]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("[watchOS] reactToPost - symbol: \(symbol)")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[watchOS] reactToPost response - status: \(httpResponse.statusCode)")
            if let responseBody = String(data: data, encoding: .utf8), !responseBody.isEmpty {
                print("[watchOS] reactToPost response body: \(responseBody)")
            }
            return httpResponse.statusCode == 201
        }
        return false
    }
    
    // MARK: - Chat API Methods
    
    func fetchChatRooms(token: String, serverUrl: String) async throws -> ChatRoomsResponse {
        print("[NetworkService] fetchChatRooms - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        
        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchChatRooms - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[NetworkService] fetchChatRooms - statusCode: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let rooms = try decoder.decode([SnChatRoom].self, from: data)
            print("[NetworkService] fetchChatRooms - decode success, rooms count: \(rooms.count)")
            return ChatRoomsResponse(rooms: rooms)
        } catch let decodingError as DecodingError {
            print("[NetworkService] fetchChatRooms - decode error: \(decodingError)")
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
            throw decodingError
        } catch {
            print("[NetworkService] fetchChatRooms - other error: \(error)")
            throw error
        }
    }
    
    func fetchChatRoom(identifier: String, token: String, serverUrl: String) async throws -> SnChatRoom {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/\(identifier)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            throw URLError(.resourceUnavailable)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(SnChatRoom.self, from: data)
    }
    
    func fetchChatInvites(token: String, serverUrl: String) async throws -> ChatInvitesResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/invites")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let invites = try decoder.decode([SnChatMember].self, from: data)
        return ChatInvitesResponse(invites: invites)
    }
    
    func acceptChatInvite(chatRoomId: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/invites/\(chatRoomId)/accept")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] acceptChatInvite failed with status code: \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
    }
    
    func declineChatInvite(chatRoomId: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/invites/\(chatRoomId)/decline")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] declineChatInvite failed with status code: \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
    }
    
    // MARK: - Message API Methods
    
    func fetchChatMessages(chatRoomId: String, token: String, serverUrl: String, before: Date? = nil, take: Int = 50) async throws -> [SnChatMessage] {
        print("[NetworkService] fetchChatMessages - chatRoomId: \(chatRoomId), token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        
        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchChatMessages - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }
        
        // Try a different pattern: /messager/chat/messages with roomId as query param
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/messages"),
            resolvingAgainstBaseURL: false
        )!
        var queryItems = [
            URLQueryItem(name: "take", value: String(take)),
        ]
        if let before = before {
            queryItems.append(URLQueryItem(name: "before", value: ISO8601DateFormatter().string(from: before)))
        }
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[NetworkService] fetchChatMessages - statusCode: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
                print("[NetworkService] fetchChatMessages failed with status \(httpResponse.statusCode), body: \(responseBody)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
        
        // Check if data is empty
        if data.isEmpty {
            print("[NetworkService] fetchChatMessages received empty response data")
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let messages = try decoder.decode([SnChatMessage].self, from: data)
            print("[NetworkService] fetchChatMessages - decode success, messages: \(messages.count)")
            return messages
        } catch {
            print("[NetworkService] fetchChatMessages - decode error: \(error)")
            print("[NetworkService] fetchChatMessages - raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw error
        }
    }
    
    // MARK: - WebSocket

    private var webSocketTask: URLSessionWebSocketTask?
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    private var isDisconnectingManually = false

    private var lastToken: String?
    private var lastServerUrl: String?

    private var heartbeatAt: Date?
    var heartbeatDelay: TimeInterval?

    private let connectLock = NSLock()
    
    private let packetSubject = PassthroughSubject<WebSocketPacket, Error>()
    private let stateSubject = CurrentValueSubject<WebSocketState, Never>(.disconnected) // Changed to CurrentValueSubject
    
    private var currentConnectionState: WebSocketState = .disconnected { // New property
        didSet {
            // Only send updates if the state has actually changed
            if oldValue != currentConnectionState {
                stateSubject.send(currentConnectionState)
            }
        }
    }
    
    var packetStream: AnyPublisher<WebSocketPacket, Error> {
        packetSubject.eraseToAnyPublisher()
    }
    
    var stateStream: AnyPublisher<WebSocketState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func connectWebSocket(token: String, serverUrl: String) {
        webSocketQueue.async { [weak self] in
            guard let self = self else { return }

            self.connectLock.lock()
            defer { self.connectLock.unlock() }
            
            // Prevent redundant connection attempts
            if self.currentConnectionState == .connecting || self.currentConnectionState == .connected {
                print("[WebSocket] Already connecting or connected, ignoring new connect request.")
                return
            }
            
            self.currentConnectionState = .connecting

            // Ensure any existing task is cancelled before starting a new one
            self.webSocketTask?.cancel(with: .goingAway, reason: nil)
            self.webSocketTask = nil

            self.isDisconnectingManually = false // Reset this flag for a new connection attempt

            self.lastToken = token
            self.lastServerUrl = serverUrl

            guard var urlComponents = URLComponents(string: serverUrl) else {
                self.currentConnectionState = .error("Invalid server URL")
                return
            }

            urlComponents.scheme = urlComponents.scheme?.replacingOccurrences(of: "http", with: "ws")
            urlComponents.path = "/ws"
            urlComponents.queryItems = [URLQueryItem(name: "deviceAlt", value: "watch")]

            guard let url = urlComponents.url else {
                self.currentConnectionState = .error("Invalid WebSocket URL")
                return
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print("[WebSocket] Trying connecting to \(url)")
            
            self.webSocketTask = self.session.webSocketTask(with: request)
            self.webSocketTask?.resume()

            self.listenForWebSocketMessages()
            self.scheduleHeartbeat()
            self.currentConnectionState = .connected
        }
    }

    private func listenForWebSocketMessages() {
        // Ensure webSocketTask is still valid before attempting to receive
        guard let task = webSocketTask else {
            print("[WebSocket] listenForWebSocketMessages: webSocketTask is nil, stopping listen.")
            return
        }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("[WebSocket] Error in receiving message: \(error)")
                // Only attempt to reconnect if not manually disconnecting
                if !self.isDisconnectingManually {
                    self.currentConnectionState = .error(error.localizedDescription)
                    self.scheduleReconnect()
                } else {
                    // If manually disconnecting, just ensure state is disconnected
                    self.currentConnectionState = .disconnected
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleWebSocketMessage(text: text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleWebSocketMessage(text: text)
                    }
                @unknown default:
                    break
                }
                // Continue listening for next message only if task is still valid
                if self.webSocketTask === task { // Check if it's the same task
                    self.listenForWebSocketMessages()
                } else {
                    print("[WebSocket] listenForWebSocketMessages: Task changed, stopping listen for old task.")
                }
            }
        }
    }
    
    private func handleWebSocketMessage(text: String) {
        guard let data = text.data(using: .utf8) else {
            print("[WebSocket] Could not convert message to data")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let type = json["type"] as? String
            {
                let packet = WebSocketPacket(
                    type: type,
                    data: json["data"] as? [String: Any],
                    endpoint: json["endpoint"] as? String,
                    errorMessage: json["errorMessage"] as? String
                )
                
                print("[WebSocket] Received packet: \(packet.type) \(packet.errorMessage ?? "")")
                
                if packet.type == "error.dupe" {
                    self.currentConnectionState = .duplicateDevice
                    self.disconnectWebSocket()
                    return
                }
                
                if packet.type == "pong" {
                    if let beatAt = self.heartbeatAt {
                        let now = Date()
                        self.heartbeatDelay = now.timeIntervalSince(beatAt)
                        print("[WebSocket] Server respond last heartbeat for \((self.heartbeatDelay ?? 0) * 1000) ms")
                    }
                }
                
                self.packetSubject.send(packet)
            }
        } catch {
            print("[WebSocket] Could not parse message json: \(error.localizedDescription)")
        }
    }
    
    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self, let serverUrl = self.lastServerUrl else { return }
            print("[WebSocket] Attempting to reconnect...")

            // No need to call disconnectWebSocket here, connectWebSocket will handle cancelling old task
            self.isDisconnectingManually = false // Reset for the new connection attempt

            // When a standalone session exists the access token may have
            // expired; refresh it first so reconnect uses a live bearer.
            let auth = StandaloneAuthService.shared
            if auth.hasStoredSession {
                Task { @MainActor in
                    do {
                        let fresh = try await auth.validAccessToken(serverUrl: serverUrl)
                        self.lastToken = fresh
                        self.connectWebSocket(token: fresh, serverUrl: serverUrl)
                    } catch {
                        print("[WebSocket] Token refresh failed before reconnect: \(error)")
                    }
                }
            } else if let token = self.lastToken {
                self.connectWebSocket(token: token, serverUrl: serverUrl)
            }
        }
    }
    
    private func scheduleHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.beatTheHeart()
        }
    }
    
    private func beatTheHeart() {
        heartbeatAt = Date()
        print("[WebSocket] We\'re beating the heart! \(String(describing: self.heartbeatAt))")
        sendWebSocketMessage(message: "{\"type\":\"ping\"}")
    }
    
    func sendWebSocketMessage(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("[WebSocket] Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func disconnectWebSocket() {
        isDisconnectingManually = true
        reconnectTimer?.invalidate()
        heartbeatTimer?.invalidate()
        
        // Cancel the task and then nil it out
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil // Set to nil immediately after cancelling
        
        self.currentConnectionState = .disconnected
    }
}
