//
//  NetworkService.swift
//  Solian
//
//  Created by LittleSheep on 2026/1/16.
//

import Foundation
import AppIntents

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

    private func buildUrl(baseUrl: String, path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents(string: baseUrl + path)
        if let queryItems = queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw NetworkError.invalidUrl
        }
        return url
    }

    private func get<T: Decodable>(baseUrl: String, token: String?, url: URL) async throws -> T {
        print("[NetworkService] GET: \(url.absoluteString)")
        print("[NetworkService] Token: \(token != nil ? "present" : "nil")")

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            print("[NetworkService] Response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            try validateResponse(response)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[NetworkService] GET Error: \(error.localizedDescription)")
            throw error
        }
    }

    private func post<T: Decodable>(baseUrl: String, token: String?, url: URL) async throws -> T {
        print("[NetworkService] POST: \(url.absoluteString)")
        print("[NetworkService] Token: \(token != nil ? "present" : "nil")")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            print("[NetworkService] Response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            try validateResponse(response)

            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            return try decoder.decode(T.self, from: data)
        } catch {
            print("[NetworkService] POST Error: \(error.localizedDescription)")
            throw error
        }
    }

    private func post<T: Decodable, B: Encodable>(baseUrl: String, token: String?, url: URL, body: B) async throws -> T {
        print("[NetworkService] POST with body: \(url.absoluteString)")
        print("[NetworkService] Token: \(token != nil ? "present" : "nil")")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await session.data(for: request)
            print("[NetworkService] Response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            try validateResponse(response)

            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            return try decoder.decode(T.self, from: data)
        } catch {
            print("[NetworkService] POST body Error: \(error.localizedDescription)")
            throw error
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    private func generateClientMessageId() -> String {
        UUID().uuidString.lowercased()
    }

    private func decodeFlexibleCount(from data: Data) throws -> Int {
        if let count = try? decoder.decode(Int.self, from: data) {
            return count
        }
        if let text = try? decoder.decode(String.self, from: data),
           let count = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return count
        }
        if let wrapped = try? decoder.decode(NotificationCountResponse.self, from: data) {
            return wrapped.count
        }
        let wrapped = try decoder.decode(UnreadChatsResponse.self, from: data)
        return wrapped.unreadCount
    }

    private func getRaw(token: String?, url: URL) async throws -> Data {
        print("[NetworkService] GET: \(url.absoluteString)")
        print("[NetworkService] Token: \(token != nil ? "present" : "nil")")

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            print("[NetworkService] Response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            try validateResponse(response)
            return data
        } catch {
            print("[NetworkService] GET Error: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Public Methods

    func getNotificationCount(token: String, serverUrl: String) async throws -> Int {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.notificationsCount)
        let data = try await getRaw(token: token, url: url)
        return try decodeFlexibleCount(from: data)
    }

    func markNotificationsRead(token: String, serverUrl: String) async throws {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.notificationsMarkRead)
        let _: EmptyResponse = try await post(baseUrl: serverUrl, token: token, url: url)
    }

    func getUnreadChatsCount(token: String, serverUrl: String) async throws -> Int {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.unreadChats)
        let data = try await getRaw(token: token, url: url)
        return try decodeFlexibleCount(from: data)
    }

    func getMessages(channelId: String, offset: Int = 0, take: Int = 5, token: String, serverUrl: String) async throws -> [MessageResponse] {
        let path = String(format: SharedConstants.API.messages, channelId)
        let url = try buildUrl(baseUrl: serverUrl, path: path, queryItems: [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "take", value: String(take))
        ])
        let data = try await getRaw(token: token, url: url)
        if let list = try? decoder.decode([MessageResponse].self, from: data) {
            return list
        }
        if let wrapped = try? decoder.decode(MessagesResponse.self, from: data) {
            return wrapped.messages
        }
        let itemsWrapped = try decoder.decode(ItemsWrapper<MessageResponse>.self, from: data)
        return itemsWrapped.items
    }

    func sendMessage(channelId: String, content: String, token: String, serverUrl: String) async throws {
        let path = String(format: SharedConstants.API.sendMessage, channelId)
        let url = try buildUrl(baseUrl: serverUrl, path: path)
        let body = SendMessageBody(
            content: content,
            attachmentsId: [],
            meta: [:],
            clientMessageId: generateClientMessageId(),
            isThreadRoot: false
        )
        let _: EmptyResponse = try await post(baseUrl: serverUrl, token: token, url: url, body: body)
    }

    func getChatRooms(token: String, serverUrl: String) async throws -> [ChatRoomResponse] {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.chatRooms)
        let data = try await getRaw(token: token, url: url)
        return try decodeChatRooms(from: data)
    }

    func getCurrentAccount(token: String, serverUrl: String) async throws -> AccountResponse {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.currentAccount)
        return try await get(baseUrl: serverUrl, token: token, url: url)
    }

    func searchChatRooms(query: String, token: String, serverUrl: String) async throws -> [ChatRoomResponse] {
        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.chatRooms, queryItems: [
            URLQueryItem(name: "query", value: query)
        ])
        let data = try await getRaw(token: token, url: url)
        return try decodeChatRooms(from: data)
    }

    private func decodeChatRooms(from data: Data) throws -> [ChatRoomResponse] {
        if let list = try? decoder.decode([ChatRoomResponse].self, from: data) {
            return list
        }
        if let wrapped = try? decoder.decode(ChatRoomsResponse.self, from: data) {
            return wrapped.rooms
        }
        let itemsWrapped = try decoder.decode(ItemsWrapper<ChatRoomResponse>.self, from: data)
        return itemsWrapped.items
    }

    func searchPosts(query: String, limit: Int = 20, token: String, serverUrl: String) async throws -> [PostResponse] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.timeline, queryItems: [
                URLQueryItem(name: "take", value: String(limit)),
                URLQueryItem(name: "mode", value: "personalized")
            ])
            let response: PostsResponse = try await get(baseUrl: serverUrl, token: token, url: url)
            return response.items.compactMap { $0.post }
        }

        let url = try buildUrl(baseUrl: serverUrl, path: SharedConstants.API.searchPosts, queryItems: [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "take", value: String(limit))
        ])
        let data = try await getRaw(token: token, url: url)
        if let list = try? decoder.decode([PostResponse].self, from: data) {
            return list
        }
        let itemsWrapped = try decoder.decode(ItemsWrapper<PostResponse>.self, from: data)
        return itemsWrapped.items
    }
}

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case httpError(statusCode: Int)
}

struct ItemsWrapper<T: Decodable>: Decodable {
    let items: [T]
}

struct NotificationCountResponse: Decodable {
    let count: Int
}

struct UnreadChatsResponse: Decodable {
    let unreadCount: Int
}

struct MessagesResponse: Decodable {
    let messages: [MessageResponse]
}

struct MessageResponse: Decodable {
    let id: String?
    let type: String?
    let content: String?
    let senderId: String?
    let sender: SenderResponse?

    struct SenderResponse: Decodable {
        let nick: String?
        let username: String?
        let account: AccountResponse?

        struct AccountResponse: Decodable {
            let name: String?
            let nick: String?
        }

        var displayName: String? {
            if let nick, !nick.isEmpty { return nick }
            if let accountNick = account?.nick, !accountNick.isEmpty { return accountNick }
            if let accountName = account?.name, !accountName.isEmpty { return accountName }
            if let username, !username.isEmpty { return username }
            return nil
        }
    }
}

struct SendMessageBody: Encodable {
    let content: String
    let attachmentsId: [String]
    let meta: [String: String]
    let clientMessageId: String
    let isThreadRoot: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case attachmentsId = "attachments_id"
        case meta
        case clientMessageId = "client_message_id"
        case isThreadRoot = "is_thread_root"
    }
}

struct EmptyResponse: Decodable {}

struct ChatRoomsResponse: Decodable {
    let rooms: [ChatRoomResponse]
}

struct ChatRoomResponse: Decodable {
    let id: String
    let name: String?
    let description: String?
    let type: Int
    let isPublic: Bool?
    let isCommunity: Bool?
    let picture: SnCloudFile?
    let background: SnCloudFile?
    let realmId: String?
    let accountId: String?
    let account: AccountResponse?
    let createdAt: String?
    let updatedAt: String?
    let members: [ChatMemberResponse]?
}

struct ChatMemberResponse: Decodable {
    let id: String
    let accountId: String?
    let account: AccountResponse?
    let nick: String?
    let username: String?
}

struct AccountResponse: Decodable {
    let id: String
    let name: String?
    let nick: String?
}

struct SnCloudFile: Codable {
    let url: String?
    let mime: String?
    let size: Int?
}

struct PostsResponse: Decodable {
    let items: [TimelineItemResponse]
}

struct TimelineItemResponse: Decodable {
    let post: PostResponse?
}

struct PostResponse: Decodable {
    let id: String
    let content: String?
    let author: AuthorResponse?
    let createdAt: String?
    let updatedAt: String?

    struct AuthorResponse: Decodable {
        let id: String
        let name: String?
        let nick: String?
        let picture: SnCloudFile?
    }
}
