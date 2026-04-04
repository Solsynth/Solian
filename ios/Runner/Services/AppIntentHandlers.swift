//
//  AppIntentHandlers.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import AppIntents

// MARK: - Token Helper

@available(iOS 16.0, *)
struct AppIntentCredential {
    static func getToken() -> String? {
        let defaults = UserDefaults(suiteName: SharedConstants.appGroupId)
        guard let jsonString = defaults?.string(forKey: SharedConstants.tokenKey),
              let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any],
              let token = jsonDict["token"] as? String else {
            print("[AppIntentCredential] Failed to get token")
            return nil
        }
        print("[AppIntentCredential] Token retrieved successfully")
        return token
    }

    static func getServerUrl() -> String {
        let defaults = UserDefaults(suiteName: SharedConstants.appGroupId)
        return defaults?.string(forKey: SharedConstants.serverUrlKey) ?? SharedConstants.defaultServerUrl
    }
}

// MARK: - Cache Helper

@available(iOS 16.0, *)
final class EntityCache<T> {
    private var cachedItems: [T] = []
    private var cacheTimestamp: Date?
    private let expirySeconds: TimeInterval

    init(expirySeconds: TimeInterval = 300) {
        self.expirySeconds = expirySeconds
    }

    func getItems() -> [T]? {
        let now = Date()
        if let cache = cacheTimestamp, now.timeIntervalSince(cache) < expirySeconds, !cachedItems.isEmpty {
            return cachedItems
        }
        return nil
    }

    func setItems(_ items: [T]) {
        cachedItems = items
        cacheTimestamp = Date()
    }
}

// MARK: - Chat Room Entity

@available(iOS 16.0, *)
struct ChatRoomEntity: AppEntity {
    let id: String
    let name: String?
    let type: Int
    let pictureURL: String?

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "intent_chat_room_title")
    }

    static var defaultQuery = ChatRoomEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        let title = name ?? "Chat Room \(id.prefix(8))"
        let subtitle = type == 0 ? "Direct Message" : (type == 1 ? "Group Chat" : "Chat")
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(subtitle)",
            image: pictureURL.flatMap { URL(string: $0) }.map { .init(url: $0) }
        )
    }
}

@available(iOS 16.0, *)
struct ChatRoomEntityQuery: EntityQuery {
    private static var cache = EntityCache<ChatRoomEntity>()

    func entities(for identifiers: [String]) async throws -> [ChatRoomEntity] {
        let rooms = try await Self.fetchRooms()
        return rooms.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ChatRoomEntity] {
        let rooms = try await Self.fetchRooms()
        return Array(rooms.prefix(20))
    }

    func entities(matching string: String) async throws -> [ChatRoomEntity] {
        let rooms = try await Self.fetchRooms()
        let lowercased = string.lowercased()
        return rooms.filter { room in
            room.name?.lowercased().contains(lowercased) ?? false
        }
    }

    private static func fetchRooms() async throws -> [ChatRoomEntity] {
        if let cached = cache.getItems() {
            return cached
        }

        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        let rooms = try await NetworkService.shared.getChatRooms(token: token, serverUrl: serverUrl)
        let entities = rooms.map { room in
            ChatRoomEntity(
                id: room.id,
                name: room.name ?? room.description,
                type: room.type,
                pictureURL: room.picture?.url
            )
        }
        cache.setItems(entities)
        return entities
    }
}

// MARK: - Post Entity

@available(iOS 16.0, *)
struct PostEntity: AppEntity {
    let id: String
    let content: String?
    let authorName: String?
    let authorPictureURL: String?
    let createdAt: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "intent_post_title")
    }

    static var defaultQuery = PostEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        let title = content?.prefix(50).description ?? "Post \(id.prefix(8))"
        let subtitle = authorName.map { "by \($0)" } ?? ""
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(subtitle)",
            image: authorPictureURL.flatMap { URL(string: $0) }.map { .init(url: $0) }
        )
    }
}

@available(iOS 16.0, *)
struct PostEntityQuery: EntityQuery {
    private static var cache = EntityCache<PostEntity>()

    func entities(for identifiers: [String]) async throws -> [PostEntity] {
        let posts = try await Self.fetchPosts()
        return posts.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [PostEntity] {
        let posts = try await Self.fetchPosts()
        return Array(posts.prefix(10))
    }

    func entities(matching string: String) async throws -> [PostEntity] {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        let posts = try await NetworkService.shared.searchPosts(query: string, token: token, serverUrl: serverUrl)
        return posts.map { post in
            PostEntity(
                id: post.id,
                content: post.content,
                authorName: post.author?.name,
                authorPictureURL: post.author?.picture?.url,
                createdAt: post.createdAt
            )
        }
    }

    private static func fetchPosts() async throws -> [PostEntity] {
        if let cached = cache.getItems() {
            return cached
        }

        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        let posts = try await NetworkService.shared.searchPosts(query: "", limit: 10, token: token, serverUrl: serverUrl)
        let entities = posts.map { post in
            PostEntity(
                id: post.id,
                content: post.content,
                authorName: post.author?.name,
                authorPictureURL: post.author?.picture?.url,
                createdAt: post.createdAt
            )
        }
        cache.setItems(entities)
        return entities
    }
}

// MARK: - Open Chat Intent

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_open_chat_title"
    static var description = IntentDescription("intent_open_chat_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "intent_chat_room_parameter", description: "The chat room to open")
    var chatRoom: ChatRoomEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Open chat with \(\.$chatRoom)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        if let chatRoom = chatRoom {
            DeepLinkHandler.shared.handle(url: URL(string: "solian://chat/\(chatRoom.id)")!)
            return .result(value: "Opening chat \(chatRoom.name ?? chatRoom.id)")
        } else {
            DeepLinkHandler.shared.handle(url: URL(string: "solian://chat")!)
            return .result(value: "Opening chat list")
        }
    }
}

// MARK: - Open Post Intent

@available(iOS 16.0, *)
struct OpenPostIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_open_post_title"
    static var description = IntentDescription("intent_open_post_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "intent_post_parameter", description: "The post to open")
    var post: PostEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Open post \(\.$post)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let post = post else {
            throw AppIntentError.requiredParameter("Post")
        }

        DeepLinkHandler.shared.handle(url: URL(string: "solian://posts/\(post.id)")!)

        return .result(value: "Opening post \(post.id)")
    }
}

// MARK: - Open Compose Intent

@available(iOS 16.0, *)
struct OpenComposeIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_open_compose_title"
    static var description = IntentDescription("intent_open_compose_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://compose")!)

        return .result(value: "Opening compose screen")
    }
}

// MARK: - Compose Post Intent

@available(iOS 16.0, *)
struct ComposePostIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_compose_post_title"
    static var description = IntentDescription("intent_compose_post_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://compose")!)

        return .result(value: "Opening compose screen")
    }
}

// MARK: - Search Content Intent

@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_search_title"
    static var description = IntentDescription("intent_search_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "intent_search_query_parameter")
    var query: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Search for \(\.$query)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let query = query, !query.isEmpty else {
            throw AppIntentError.requiredParameter("Search Query")
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        DeepLinkHandler.shared.handle(url: URL(string: "solian://search?q=\(encodedQuery)")!)

        return .result(value: "Searching for \"\(query)\"")
    }
}

// MARK: - View Notifications Intent

@available(iOS 16.0, *)
struct ViewNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_notifications_title"
    static var description = IntentDescription("intent_notifications_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://notifications")!)

        return .result(value: "Opening notifications")
    }
}

// MARK: - Check Notifications Intent

@available(iOS 16.0, *)
struct CheckNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_check_notifications_title"
    static var description = IntentDescription("intent_check_notifications_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()
        
        do {
            let count = try await NetworkService.shared.getNotificationCount(token: token, serverUrl: serverUrl)

            let message: String
            if count == 0 {
                message = "You have no new notifications"
            } else if count == 1 {
                message = "You have 1 new notification"
            } else {
                message = "You have \(count) new notifications"
            }

            return .result(
                value: message,
                dialog: "\(message)"
            )
        } catch {
            throw AppIntentError.networkError("Failed to check notifications: \(error.localizedDescription)")
        }
    }
}

// MARK: - Send Message Intent

@available(iOS 16.0, *)
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_send_message_title"
    static var description = IntentDescription("intent_send_message_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    @Parameter(title: "intent_chat_room_parameter")
    var chatRoom: ChatRoomEntity

    @Parameter(title: "intent_message_parameter")
    var message: String

    static var parameterSummary: some ParameterSummary {
        Summary("Send message to \(\.$chatRoom)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        do {
            try await NetworkService.shared.sendMessage(channelId: chatRoom.id, content: message, token: token, serverUrl: serverUrl)

            return .result(
                value: "Message sent to \(chatRoom.name ?? chatRoom.id)",
                dialog: "Message sent successfully"
            )
        } catch {
            throw AppIntentError.networkError("Failed to send message: \(error.localizedDescription)")
        }
    }
}

// MARK: - Read Messages Intent

@available(iOS 16.0, *)
struct ReadMessagesIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_read_messages_title"
    static var description = IntentDescription("intent_read_messages_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    @Parameter(title: "intent_chat_room_parameter")
    var chatRoom: ChatRoomEntity

    @Parameter(title: "intent_message_count_parameter", default: 5)
    var limit: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Read messages from \(\.$chatRoom)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        let safeLimit = max(1, min(20, limit))

        do {
            let messages = try await NetworkService.shared.getMessages(
                channelId: chatRoom.id,
                offset: 0,
                take: safeLimit,
                token: token,
                serverUrl: serverUrl
            )

            if messages.isEmpty {
                return .result(
                    value: "No messages found in \(chatRoom.name ?? chatRoom.id)",
                    dialog: "No messages found"
                )
            }

            let formattedMessages = messages.compactMap { message -> String? in
                let senderName = message.sender?.account?.name ?? "Unknown"
                let content = message.content ?? ""
                return "\(senderName): \(content)"
            }.joined(separator: "\n")

            return .result(
                value: formattedMessages,
                dialog: "Found \(messages.count) messages"
            )
        } catch {
            throw AppIntentError.networkError("Failed to read messages: \(error.localizedDescription)")
        }
    }
}

// MARK: - Check Unread Chats Intent

@available(iOS 16.0, *)
struct CheckUnreadChatsIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_unread_chats_title"
    static var description = IntentDescription("intent_unread_chats_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        do {
            let count = try await NetworkService.shared.getUnreadChatsCount(token: token, serverUrl: serverUrl)

            let message: String
            if count == 0 {
                message = "You have no unread messages"
            } else if count == 1 {
                message = "You have 1 unread message"
            } else {
                message = "You have \(count) unread messages"
            }

            return .result(
                value: message,
                dialog: "\(message)"
            )
        } catch {
            throw AppIntentError.networkError("Failed to check unread chats: \(error.localizedDescription)")
        }
    }
}

// MARK: - Mark Notifications Read Intent

@available(iOS 16.0, *)
struct MarkNotificationsReadIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_mark_read_title"
    static var description = IntentDescription("intent_mark_read_desc")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = AppIntentCredential.getToken() else {
            throw AppIntentError.networkError("Not logged in")
        }
        let serverUrl = AppIntentCredential.getServerUrl()

        do {
            try await NetworkService.shared.markNotificationsRead(token: token, serverUrl: serverUrl)

            return .result(
                value: "All notifications marked as read",
                dialog: "All notifications marked as read"
            )
        } catch {
            throw AppIntentError.networkError("Failed to mark notifications: \(error.localizedDescription)")
        }
    }
}

// MARK: - Error Handling

enum AppIntentError: Error, CustomLocalizedStringResourceConvertible {
    case requiredParameter(String)
    case networkError(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .requiredParameter(let param):
            return "\(param) is required"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
