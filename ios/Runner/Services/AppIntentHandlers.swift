//
//  AppIntentHandlers.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import AppIntents
import UIKit

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Chat"
    static var description = IntentDescription("Open a specific chat room")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Channel ID")
    var channelId: String?

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let channelId = channelId, !channelId.isEmpty else {
            throw AppIntentError.requiredParameter("Channel ID")
        }

        DeepLinkHandler.shared.handle(url: URL(string: "solian://chat/\(channelId)")!)

        return .result(value: "Opening chat \(channelId)")
    }
}

@available(iOS 16.0, *)
struct OpenPostIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Post"
    static var description = IntentDescription("Open a specific post")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Post ID")
    var postId: String?

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let postId = postId, !postId.isEmpty else {
            throw AppIntentError.requiredParameter("Post ID")
        }

        DeepLinkHandler.shared.handle(url: URL(string: "solian://posts/\(postId)")!)

        return .result(value: "Opening post \(postId)")
    }
}

@available(iOS 16.0, *)
struct OpenComposeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Compose"
    static var description = IntentDescription("Open compose post screen")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://compose")!)

        return .result(value: "Opening compose screen")
    }
}

@available(iOS 16.0, *)
struct ComposePostIntent: AppIntent {
    static var title: LocalizedStringResource = "Compose Post"
    static var description = IntentDescription("Create a new post")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://compose")!)

        return .result(value: "Opening compose screen")
    }
}

@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Content"
    static var description = IntentDescription("Search for content")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Search Query")
    var query: String?

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let query = query, !query.isEmpty else {
            throw AppIntentError.requiredParameter("Search Query")
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        DeepLinkHandler.shared.handle(url: URL(string: "solian://search?q=\(encodedQuery)")!)

        return .result(value: "Searching for \"\(query)\"")
    }
}

@available(iOS 16.0, *)
struct ViewNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Notifications"
    static var description = IntentDescription("View notifications")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & OpensIntent {
        DeepLinkHandler.shared.handle(url: URL(string: "solian://notifications")!)

        return .result(value: "Opening notifications")
    }
}

@available(iOS 16.0, *)
struct CheckNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Notifications"
    static var description = IntentDescription("Check notification count")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let count = try await NetworkService.shared.getNotificationCount()

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

@available(iOS 16.0, *)
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Message"
    static var description = IntentDescription("Send a message to a chat channel")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    @Parameter(title: "Channel ID")
    var channelId: String?

    @Parameter(title: "Message Content")
    var content: String?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let channelId = channelId, !channelId.isEmpty else {
            throw AppIntentError.requiredParameter("Channel ID")
        }

        guard let content = content, !content.isEmpty else {
            throw AppIntentError.requiredParameter("Message Content")
        }

        do {
            try await NetworkService.shared.sendMessage(channelId: channelId, content: content)

            return .result(
                value: "Message sent to channel \(channelId)",
                dialog: "Message sent successfully"
            )
        } catch {
            throw AppIntentError.networkError("Failed to send message: \(error.localizedDescription)")
        }
    }
}

@available(iOS 16.0, *)
struct ReadMessagesIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Messages"
    static var description = IntentDescription("Read recent messages from a chat channel")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    @Parameter(title: "Channel ID")
    var channelId: String?

    @Parameter(title: "Number of Messages", default: "5")
    var limit: String?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let channelId = channelId, !channelId.isEmpty else {
            throw AppIntentError.requiredParameter("Channel ID")
        }

        let limitValue = Int(limit ?? "5") ?? 5
        let safeLimit = max(1, min(20, limitValue))

        do {
            let messages = try await NetworkService.shared.getMessages(
                channelId: channelId,
                offset: 0,
                take: safeLimit
            )

            if messages.isEmpty {
                return .result(
                    value: "No messages found in channel \(channelId)",
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

@available(iOS 16.0, *)
struct CheckUnreadChatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Unread Chats"
    static var description = IntentDescription("Check number of unread chat messages")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let count = try await NetworkService.shared.getUnreadChatsCount()

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

@available(iOS 16.0, *)
struct MarkNotificationsReadIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Notifications Read"
    static var description = IntentDescription("Mark all notifications as read")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            try await NetworkService.shared.markNotificationsRead()

            return .result(
                value: "All notifications marked as read",
                dialog: "All notifications marked as read"
            )
        } catch {
            throw AppIntentError.networkError("Failed to mark notifications: \(error.localizedDescription)")
        }
    }
}

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
