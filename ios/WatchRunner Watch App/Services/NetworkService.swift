//
//  NetworkService.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation

// MARK: - Network Service

class NetworkService {
    private let session = URLSession.shared

    func fetchActivities(filter: String, cursor: String? = nil, token: String, serverUrl: String) async throws -> ActivityResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/sphere/activities"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "take", value: "20")]
        if filter.lowercased() != "explore" {
            queryItems.append(URLQueryItem(name: "filter", value: filter.lowercased()))
        }
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let activities = try decoder.decode([SnActivity].self, from: data)

        let hasMore = (activities.first?.type ?? "empty") != "empty"
        let nextCursor = activities.isEmpty ? nil : activities.map { $0.createdAt }.min()?.ISO8601Format()

        return ActivityResponse(activities: activities, hasMore: hasMore, nextCursor: nextCursor)
    }

    func createPost(title: String, content: String, token: String, serverUrl: String) async throws {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/sphere/posts")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let body: [String: Any] = ["title": title, "content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("[watchOS] createPost failed with status code: \(httpResponse.statusCode), body: \(responseBody)")
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
    }

    func fetchNotifications(offset: Int = 0, take: Int = 20, token: String, serverUrl: String) async throws -> NotificationResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/ring/notifications"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "offset", value: String(offset)), URLQueryItem(name: "take", value: String(take))]
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
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
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/pass/accounts/me")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(SnAccount.self, from: data)
    }
}
