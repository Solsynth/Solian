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
    
    func createPost(title: String, content: String, token: String, serverUrl: String) async throws {
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
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/accounts/me")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(SnAccount.self, from: data)
    }
    
    func fetchAccountStatus(token: String, serverUrl: String) async throws -> SnAccountStatus? {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/passport/accounts/me/statuses")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(SnAccountStatus.self, from: data)
    }
    
    func createOrUpdateStatus(attitude: Int, isInvisible: Bool, isNotDisturb: Bool, label: String?, token: String, serverUrl: String) async throws -> SnAccountStatus {
        // Check if there\'s already a customized status
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
            "is_invisible": isInvisible,
            "is_not_disturb": isNotDisturb,
        ]
        
        if let label = label, !label.isEmpty {
            body["label"] = label
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
    
    // MARK: - Chat API Methods
    
    func fetchChatRooms(token: String, serverUrl: String) async throws -> ChatRoomsResponse {
        guard let baseURL = URL(string: serverUrl) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("/messager/chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let rooms = try decoder.decode([SnChatRoom].self, from: data)
        return ChatRoomsResponse(rooms: rooms)
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
        guard let baseURL = URL(string: serverUrl) else {
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
            _ = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
            
            if httpResponse.statusCode != 200 {
                print("[watchOS] fetchChatMessages failed with status \(httpResponse.statusCode)")
                throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
            }
        }
        
        // Check if data is empty
        if data.isEmpty {
            print("[watchOS] fetchChatMessages received empty response data")
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let messages = try decoder.decode([SnChatMessage].self, from: data)
            print("[watchOS] fetchChatMessages successfully decoded \(messages.count) messages")
            return messages
        } catch {
            print("error: ", error)
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
            guard let self = self, let token = self.lastToken, let serverUrl = self.lastServerUrl else { return }
            print("[WebSocket] Attempting to reconnect...")
            
            // No need to call disconnectWebSocket here, connectWebSocket will handle cancelling old task
            self.isDisconnectingManually = false // Reset for the new connection attempt
            
            self.connectWebSocket(token: token, serverUrl: serverUrl)
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
