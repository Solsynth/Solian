//
//  NetworkService.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    private var baseUrl: String {
        UserDefaults.shared.getServerUrl()
    }

    private var authHeaders: [String: String] {
        var headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        if let token = UserDefaults.shared.getAuthToken() {
            headers["Authorization"] = "AtField \(token)"
        }
        return headers
    }

    func getNotificationCount() async throws -> Int {
        let url = try buildUrl(path: SharedConstants.API.notificationsCount)
        let response: NotificationCountResponse = try await get(url: url)
        return response.count
    }

    func markNotificationsRead() async throws {
        let url = try buildUrl(path: SharedConstants.API.notificationsMarkRead)
        let _: EmptyResponse = try await post(url: url, body: nil)
    }

    func getUnreadChatsCount() async throws -> Int {
        let url = try buildUrl(path: SharedConstants.API.unreadChats)
        let response: UnreadChatsResponse = try await get(url: url)
        return response.unreadCount
    }

    func getMessages(channelId: String, offset: Int = 0, take: Int = 5) async throws -> [MessageResponse] {
        let path = String(format: SharedConstants.API.messages, channelId)
        let url = try buildUrl(path: path, queryItems: [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "take", value: String(take))
        ])
        let response: MessagesResponse = try await get(url: url)
        return response.messages
    }

    func sendMessage(channelId: String, content: String) async throws {
        let path = String(format: SharedConstants.API.sendMessage, channelId)
        let url = try buildUrl(path: path)
        let body = SendMessageBody(content: content, nonce: generateNonce())
        let _: EmptyResponse = try await post(url: url, body: body)
    }

    private func buildUrl(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents(string: baseUrl + path)
        if let queryItems = queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw NetworkError.invalidUrl
        }
        return url
    }

    private func get<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        authHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func post<T: Decodable, B: Encodable>(url: URL, body: B?) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        authHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        return try decoder.decode(T.self, from: data)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    private func generateNonce() -> String {
        "\(Date().timeIntervalSince1970)"
    }
}

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case httpError(statusCode: Int)
}

private struct NotificationCountResponse: Decodable {
    let count: Int
}

private struct UnreadChatsResponse: Decodable {
    let unreadCount: Int
}

private struct MessagesResponse: Decodable {
    let messages: [MessageResponse]
}

private struct MessageResponse: Decodable {
    let content: String?
    let sender: SenderResponse?

    struct SenderResponse: Decodable {
        let account: AccountResponse?

        struct AccountResponse: Decodable {
            let name: String?
        }
    }
}

private struct SendMessageBody: Encodable {
    let content: String
    let nonce: String
}

private struct EmptyResponse: Decodable {}
