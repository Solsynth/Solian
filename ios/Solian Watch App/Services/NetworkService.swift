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

/// A `CheckedContinuation` wrapper that resumes exactly once, whatever thread
/// the resume comes from. A reference type so all closures share the same
/// guard; the lock makes it safe to resume from the ack thread, a URLSession
/// callback, and the main-queue timeout concurrently. Guards against the
/// timeout racing an early ack (or a send error), which would otherwise trip
/// Swift's "continuation resumed more than once" trap. `@unchecked Sendable`
/// because the lock serializes all access to `resumed`.
final class ResumeOnce<Value>: @unchecked Sendable {
    private let continuation: CheckedContinuation<Value, Error>
    private let lock = NSLock()
    private var resumed = false

    init(_ continuation: CheckedContinuation<Value, Error>) {
        self.continuation = continuation
    }

    func resume(returning value: Value) {
        lock.lock(); defer { lock.unlock() }
        guard !resumed else { return }
        resumed = true
        continuation.resume(returning: value)
    }

    func resume(throwing error: Error) {
        lock.lock(); defer { lock.unlock() }
        guard !resumed else { return }
        resumed = true
        continuation.resume(throwing: error)
    }
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

    private func deleteEmpty(path: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
    
    /// POST /sphere/posts — create a post, a reply, or a forward (quote).
    ///
    /// `replyTo` (the post being replied to) and `forwardTo` (the post being
    /// quoted) mirror the main app's `compose_shared.dart`, which sends
    /// `replied_post_id` and `forwarded_post_id` on the same create endpoint.
    /// At most one of `replyTo` / `forwardTo` applies.
    func createPost(
        content: String,
        visibility: Int = 0,
        replyTo: String? = nil,
        forwardTo: String? = nil,
        token: String,
        serverUrl: String
    ) async throws {
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
        
        var body: [String: Any] = [
            "content": content,
            "visibility": visibility
        ]
        // Threading relationship goes in the wire payload only when a
        // meaningful target was given, matching the Flutter SDK's
        // conditionally-built create payload.
        if let replyTo {
            body["replied_post_id"] = replyTo
        }
        if let forwardTo {
            body["forwarded_post_id"] = forwardTo
        }
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
        try await createPost(
            content: content,
            visibility: visibility,
            replyTo: postId,
            token: token,
            serverUrl: serverUrl
        )
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
        
        // No `.convertFromSnakeCase`: models declare explicit snake_case
        // CodingKeys, and the strategy rewrites those raw key strings (the
        // decoder then looks up camelCased keys, never matching "account_id"),
        // which breaks nested models like SnAccountBadge.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
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

    // MARK: - Check-in & Fortune (mirrors Flutter AccountsApi)

    /// GET /passport/accounts/me/check-in?version=2 — today's check-in, or nil
    /// if not checked in yet (404). Mirrors `getCheckInResultToday`.
    func fetchCheckInResult(token: String, serverUrl: String) async throws -> SnCheckInResult? {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/passport/accounts/me/check-in"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "version", value: "2")]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            return nil
        }
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] fetchCheckInResult failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnCheckInResult.self, from: data)
    }

    /// POST /passport/accounts/me/check-in?version=2 — perform today's
    /// check-in. Mirrors `checkIn`.
    func checkIn(token: String, serverUrl: String) async throws -> SnCheckInResult {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/passport/accounts/me/check-in"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "version", value: "2")]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] checkIn failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnCheckInResult.self, from: data)
    }

    /// GET /passport/fortune/daily — today's fortune saying. Mirrors
    /// `getDailyFortune`.
    func fetchDailyFortune(token: String, serverUrl: String) async throws -> SnFortuneSaying {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/fortune/daily")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] fetchDailyFortune failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnFortuneSaying.self, from: data)
    }

    // MARK: - Post engagement APIs (boost / bookmark)

    /// POST /sphere/posts/{postId}/boost — boost/repost a post.
    func boostPost(postId: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/posts/\(postId)/boost", token: token, serverUrl: serverUrl)
    }

    /// DELETE /sphere/posts/{postId}/boost — undo a boost.
    func unboostPost(postId: String, token: String, serverUrl: String) async throws {
        try await deleteEmpty(path: "/sphere/posts/\(postId)/boost", token: token, serverUrl: serverUrl)
    }

    /// POST /sphere/posts/{postId}/bookmark — bookmark a post.
    func bookmarkPost(postId: String, token: String, serverUrl: String) async throws {
        try await postEmpty(path: "/sphere/posts/\(postId)/bookmark", token: token, serverUrl: serverUrl)
    }

    /// DELETE /sphere/posts/{postId}/bookmark — remove a bookmark.
    func unbookmarkPost(postId: String, token: String, serverUrl: String) async throws {
        try await deleteEmpty(path: "/sphere/posts/\(postId)/bookmark", token: token, serverUrl: serverUrl)
    }

    /// GET /sphere/posts/{postId} — fresh post (context / refreshed state).
    func fetchPost(postId: String, token: String, serverUrl: String) async throws -> SnPost {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/posts/\(postId)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] fetchPost failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        return try Self.decodeJSON(SnPost.self, from: data)
    }

    /// GET /sphere/posts/{postId}/replies — paginated direct replies, newest
    /// first. Mirrors the SDK's `getPostReplies` query (`offset`, `take`).
    func fetchPostReplies(postId: String, offset: Int = 0, take: Int = 10, token: String, serverUrl: String) async throws -> PostListResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/sphere/posts/\(postId)/replies"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "take", value: "\(take)"),
            URLQueryItem(name: "orderDesc", value: "true"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        let http = response as? HTTPURLResponse
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] fetchPostReplies failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        let total = Int(http?.value(forHTTPHeaderField: "X-Total") ?? "0") ?? 0
        let posts = try Self.decodeJSON([SnPost].self, from: data)
        return PostListResponse(posts: posts, total: total)
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

    /// Fetches per-room chat summaries (unread count + last message), keyed by
    /// room id. Mirrors Flutter's `GET /messager/chat/summary`.
    func fetchChatSummary(token: String, serverUrl: String) async throws -> [String: SnChatSummary] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/summary")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[NetworkService] fetchChatSummary failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([String: SnChatSummary].self, from: data)
    }

    func fetchChatRooms(token: String, serverUrl: String, offset: Int = 0, take: Int = 100) async throws -> ChatRoomsResponse {
        print("[NetworkService] fetchChatRooms - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")

        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchChatRooms - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }

        // Bare `/messager/chat` returns `{ "rooms": [...] }` — this is the
        // shape the iOS Runner decodes (ChatRoomsResponse.rooms). The
        // `/messager/chat/rooms` route is a 404 (SDK-only, unimplemented here).
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent("/messager/chat"),
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }
        // Offset/take are optional hints; the bare endpoint returns the full
        // list, and we bound by `take` client-side.
        components.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "take", value: String(take)),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[NetworkService] fetchChatRooms failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        let totalCount = Int((response as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "X-Total") ?? "0") ?? 0

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            // Server wraps the list in `{ "rooms": [...] }`. Tolerate a bare
            // array too, in case a deployment returns the list unwrapped.
            let rooms = try decodeRoomList(from: data, decoder: decoder)
            print("[NetworkService] fetchChatRooms - decode success, rooms count: \(rooms.count), total: \(totalCount)")
            return ChatRoomsResponse(rooms: rooms, totalCount: totalCount)
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

    /// Decodes a room list from a `{ "rooms": [...] }` wrapper (or a bare
    /// array), mirroring the iOS Runner's `ChatRoomsResponse`.
    private func decodeRoomList(from data: Data, decoder: JSONDecoder) throws -> [SnChatRoom] {
        if let rooms = try? decoder.decode([SnChatRoom].self, from: data) {
            return rooms
        }
        struct WrappedRooms: Decodable {
            let rooms: [SnChatRoom]
        }
        let wrapped = try decoder.decode(WrappedRooms.self, from: data)
        return wrapped.rooms
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
    
    // MARK: - Sticker API Methods

    /// Fetches sticker packs owned by the current user (`GET
    /// /sphere/stickers/me`). Each element is an ownership row `{ pack_id,
    /// account_id, pack: { …stickers } }`; the packs are extracted from the
    /// nested `pack`. Mirrors Flutter's `myStickerOwnerships` / `myStickerPacks`.
    func fetchMyStickerPacks(token: String, serverUrl: String) async throws -> [SnStickerPack] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/stickers/me")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("[NetworkService] fetchMyStickerPacks failed with status \(httpResponse.statusCode), body: \(body)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let rawList = try Self.decodeRawList(from: data)
        let packs: [SnStickerPack] = rawList.compactMap { element in
            guard let itemData = try? JSONSerialization.data(withJSONObject: element),
                  let ownership = try? decoder.decode(SnStickerOwnershipRow.self, from: itemData) else {
                return nil
            }
            return ownership.pack
        }
        return packs
    }

    /// Resolves a `:prefix+slug:` placeholder to its sticker (`GET
    /// /sphere/stickers/lookup/{identifier}`), used to render sticker image
    /// URLs for received messages. Mirrors Flutter's `stickerLookupProvider`.
    func fetchStickerLookup(identifier: String, token: String, serverUrl: String) async throws -> SnSticker? {
        guard let baseURL = URL(string: serverUrl),
              let encoded = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/stickers/lookup/\(encoded)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[NetworkService] fetchStickerLookup failed with status \(httpResponse.statusCode)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(SnSticker.self, from: data)
    }

    /// Decodes response bytes into a raw JSON array, tolerating the gateway's
    /// `{ "items": [...] }` wrapper used on some list endpoints.
    private static func decodeRawList(from data: Data) throws -> [Any] {
        if let array = (try? JSONSerialization.jsonObject(with: data)) as? [Any] {
            return array
        }
        if let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
           let items = dict["items"] as? [Any] {
            return items
        }
        throw DecodingError.dataCorrupted(.init(
            codingPath: [],
            debugDescription: "Expected a JSON array or {items:[...]} wrapper"
        ))
    }

    // MARK: - Message API Methods
    
    func fetchChatMessages(
        chatRoomId: String,
        token: String,
        serverUrl: String,
        offset: Int = 0,
        take: Int = 50
    ) async throws -> ChatMessagesResult {
        print("[NetworkService] fetchChatMessages - chatRoomId: \(chatRoomId), offset: \(offset), take: \(take)")

        guard let baseURL = URL(string: serverUrl) else {
            print("[NetworkService] fetchChatMessages - bad URL: \(serverUrl)")
            throw URLError(.badURL)
        }

        // Matches the Flutter MessageRepository shape:
        // GET /messager/chat/{roomId}/messages?offset=&take= with x-total header.
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/messages"),
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "take", value: String(take)),
        ]

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

        let totalCount = Int((response as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "X-Total") ?? "0") ?? 0

        if offset >= totalCount && totalCount > 0 {
            print("[NetworkService] fetchChatMessages - offset beyond total, returning empty")
            return ChatMessagesResult(messages: [], totalCount: totalCount)
        }

        if data.isEmpty {
            print("[NetworkService] fetchChatMessages received empty response data")
            return ChatMessagesResult(messages: [], totalCount: totalCount)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            // Tolerate either a bare JSON array or a `{items:[...]}` wrapper —
            // the gateway wraps list responses in a dictionary for the rooms
            // endpoint, so apply the same resilience here.
            let messages = try decodeMessageList(from: data, decoder: decoder)
            print("[NetworkService] fetchChatMessages - decode success, messages: \(messages.count), total: \(totalCount)")
            return ChatMessagesResult(messages: messages, totalCount: totalCount)
        } catch {
            print("[NetworkService] fetchChatMessages - decode error: \(error)")
            print("[NetworkService] fetchChatMessages - raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw error
        }
    }

    /// Decodes a message list from either a JSON array or a `{ "items": [...] }`
    /// wrapper. Each element is decoded independently and malformed rows are
    /// skipped (Flutter's `_tryParseMessage`), so one bad message never breaks
    /// the whole timeline.
    private func decodeMessageList(from data: Data, decoder: JSONDecoder) throws -> [SnChatMessage] {
        let rawList: [Any]
        if let array = (try? JSONSerialization.jsonObject(with: data)) as? [Any] {
            rawList = array
        } else if let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let items = dict["items"] as? [Any] {
            rawList = items
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "Expected a message array or {items:[...]} wrapper"
            ))
        }
        return rawList.compactMap { element in
            guard let itemData = try? JSONSerialization.data(withJSONObject: element) else { return nil }
            return try? decoder.decode(SnChatMessage.self, from: itemData)
        }
    }

    /// Fetches a single message by id — used to resolve quoted/forwarded
    /// message content, mirroring Flutter's `fetchRemoteMessage`
    /// (`GET /messager/chat/{room}/messages/{messageId}`).
    func fetchChatMessage(byId messageId: String, chatRoomId: String, token: String, serverUrl: String) async throws -> SnChatMessage? {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/messages/\(messageId)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 { return nil }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnChatMessage.self, from: data)
    }

    /// Fetches the current user's identity (member) in a room, matching
    /// Flutter's `GET /messager/chat/{id}/members/me`.
    func fetchChatIdentity(chatRoomId: String, token: String, serverUrl: String) async throws -> SnChatMember {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/members/me")

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
        return try decoder.decode(SnChatMember.self, from: data)
    }

    /// Sends a message. Non-E2EE rooms send via WebSocket
    /// (`messages.send` → awaited `messages.delivered`) with an HTTP POST
    /// fallback, mirroring Flutter's MessageSender. Returns the server message.
    func sendChatMessage(
        chatRoomId: String,
        content: String,
        clientMessageId: String,
        token: String,
        serverUrl: String,
        replyToId: String? = nil,
        threadId: String? = nil,
        attachmentIds: [String] = []
    ) async throws -> SnChatMessage {
        var payload: [String: Any] = [
            "content": content,
            "attachments_id": attachmentIds,
            "meta": [:],
            "client_message_id": clientMessageId,
        ]
        if let replyToId = replyToId { payload["replied_message_id"] = replyToId }
        if let threadId = threadId { payload["thread_id"] = threadId }

        // WebSocket-first when connected.
        if currentConnectionState == .connected, webSocketTask != nil {
            if let sent = try? await sendViaWebSocket(chatRoomId: chatRoomId, payload: payload) {
                return sent
            }
            print("[NetworkService] sendChatMessage - WS send failed, falling back to HTTP")
        }

        // HTTP fallback: POST /messager/chat/{roomId}/messages.
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/messages")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[NetworkService] sendChatMessage failed with status \(httpResponse.statusCode), body: \(body)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnChatMessage.self, from: data)
    }

    /// Uploads a voice recording and sends a `voice` message in one multipart
    /// POST, mirroring Flutter's `MessageSender.sendVoiceMessage`
    /// (`POST /messager/chat/{roomId}/messages/voice`). Returns the server
    /// message, which carries `meta.voice_url` + `meta.duration_ms`.
    func sendVoiceMessage(
        chatRoomId: String,
        fileURL: URL,
        durationMs: Int,
        clientMessageId: String,
        token: String,
        serverUrl: String
    ) async throws -> SnChatMessage {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat/\(chatRoomId)/messages/voice")

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let fileData = try Data(contentsOf: fileURL)
        var body = Data()
        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
        append("Content-Type: audio/mp4\r\n\r\n")
        body.append(fileData)
        append("\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"client_message_id\"\r\n\r\n")
        append("\(clientMessageId)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"durationMs\"\r\n\r\n")
        append("\(durationMs)\r\n")

        append("--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[NetworkService] sendVoiceMessage failed with status \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnChatMessage.self, from: data)
    }

    /// Uploads a file to Drive (`POST /drive/files/upload/direct`) and returns
    /// the resulting cloud file. `usage` mirrors Flutter's `chat_message`
    /// upload usage. Mirrors `DriveFileUploader.createCloudFile`.
    func uploadCloudFile(
        fileURL: URL,
        contentType: String,
        usage: String,
        token: String,
        serverUrl: String
    ) async throws -> SnCloudFile {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/drive/files/upload/direct")

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let fileData = try Data(contentsOf: fileURL)
        var body = Data()
        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
        append("Content-Type: \(contentType)\r\n\r\n")
        body.append(fileData)
        append("\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"usage\"\r\n\r\n")
        append("\(usage)\r\n")

        append("--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[NetworkService] uploadCloudFile failed with status \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        let any = try JSONSerialization.jsonObject(with: data, options: [])
        guard let object = any as? [String: Any] else {
            throw URLError(.cannotDecodeContentData)
        }
        // The direct-upload response nests the file under one of several keys
        // (Flutter's `_parseUploadedFileResponse`): `file`, `file_info`,
        // `data.file`, or a bare file object.
        if let file = object["file"] as? [String: Any] {
            let jsonData = try JSONSerialization.data(withJSONObject: file)
            return try decoderWithoutSnake(SnCloudFile.self, from: jsonData)
        }
        if let fileInfo = object["file_info"] as? [String: Any] {
            let jsonData = try JSONSerialization.data(withJSONObject: fileInfo)
            return try decoderWithoutSnake(SnCloudFile.self, from: jsonData)
        }
        if let dataObj = object["data"] as? [String: Any] {
            if let file = dataObj["file"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: file)
                return try decoderWithoutSnake(SnCloudFile.self, from: jsonData)
            }
            if dataObj["id"] != nil {
                let jsonData = try JSONSerialization.data(withJSONObject: dataObj)
                return try decoderWithoutSnake(SnCloudFile.self, from: jsonData)
            }
        }
        if object["id"] != nil {
            let jsonData = try JSONSerialization.data(withJSONObject: object)
            return try decoderWithoutSnake(SnCloudFile.self, from: jsonData)
        }
        throw URLError(.cannotDecodeContentData)
    }

    /// Fetches the current user's cloud files (`GET /drive/files/me`), used by
    /// the "link a cloud image" picker. Mirrors `DriveApi.listMyFiles`.
    func fetchMyCloudFiles(
        token: String,
        serverUrl: String,
        offset: Int = 0,
        take: Int = 20
    ) async throws -> [SnCloudFile] {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/drive/files/me"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "recycled", value: "false"),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "take", value: String(take)),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        // Returns a bare JSON array of cloud files (DriveApi.listMyFiles).
        let any = try JSONSerialization.jsonObject(with: data, options: [])
        guard let items = any as? [[String: Any]] else { return [] }
        return items.compactMap { item in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: item) else { return nil }
            return try? decoderWithoutSnake(SnCloudFile.self, from: jsonData)
        }
    }

    /// Decodes without `.convertFromSnakeCase` — every model declares its own
    /// snake_case CodingKeys, so the key strategy would corrupt raw keys.
    private func decoderWithoutSnake<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    /// Sends a `messages.send` packet over WebSocket and awaits the matching
    /// `messages.delivered` ack (≤3s). Throws on timeout/absence so callers
    /// fall back to HTTP.
    private func sendViaWebSocket(chatRoomId: String, payload: [String: Any]) async throws -> SnChatMessage {
        guard let task = webSocketTask else { throw URLError(.notConnectedToInternet) }

        let packet: [String: Any] = [
            "type": "messages.send",
            "endpoint": "messager",
            "data": ["chat_room_id": chatRoomId].merging(payload) { (_, new) in new },
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: packet)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let clientId = payload["client_message_id"] as? String

        let sent = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SnChatMessage, Error>) in
            // Resume exactly once. All three paths (send error, ack, timeout)
            // funnel through `resume`; the flag guards against the timeout
            // racing an already-resumed ack, which would trip Swfit's
            // "continuation resumed more than once" trap.
            let resumeOnce = ResumeOnce<SnChatMessage>(continuation)

            task.send(.string(jsonString)) { error in
                if let error = error {
                    resumeOnce.resume(throwing: error)
                }
            }

            var cancellable: AnyCancellable?
            cancellable = self.packetSubject
                .filter { $0.type == "messages.delivered" }
                .compactMap { $0.data }
                .filter { data in
                    let roomId = data["chat_room_id"] as? String
                    let ackClientId = (data["client_message_id"] as? String) ?? (data["nonce"] as? String)
                    return roomId == chatRoomId && ackClientId == clientId
                }
                .prefix(1)
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let message = try decoder.decode(SnChatMessage.self, from: jsonData)
                        resumeOnce.resume(returning: message)
                    } catch {
                        resumeOnce.resume(throwing: error)
                    }
                })

            // 3s delivery timeout → HTTP fallback. Cancels the ack subscription
            // and only resumes if nothing else already did.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                cancellable?.cancel()
                resumeOnce.resume(throwing: URLError(.timedOut))
            }
        }
        return sent
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

    /// Sends a `messages.send` packet with the given `type` + `data`, matching
    /// the Flutter WebSocketPacket shape used by chat_subscribe.dart.
    func sendChatPacket(type: String, data: [String: Any], endpoint: String = "messager") {
        let packet: [String: Any] = [
            "type": type,
            "data": data,
            "endpoint": endpoint,
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: packet),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        sendWebSocketMessage(message: jsonString)
    }

    /// Marks a room as read via WebSocket (`messages.read`).
    func sendReadReceipt(chatRoomId: String) {
        sendChatPacket(type: "messages.read", data: ["chat_room_id": chatRoomId])
    }

    /// Broadcasts a typing indicator (`messages.typing`), throttled by the caller.
    func sendTypingStatus(chatRoomId: String) {
        let now = Int(Date().timeIntervalSince1970 * 1000)
        sendChatPacket(type: "messages.typing", data: [
            "chat_room_id": chatRoomId,
            "ts": now,
            "type": "typing",
        ])
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
