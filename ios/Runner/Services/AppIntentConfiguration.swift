//
//  AppIntentConfiguration.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import AppIntents

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenChatIntent(),
            phrases: [
                "Open chat in \(.applicationName)",
                "Open conversation in \(.applicationName)",
                "在 \(.applicationName) 打开聊天"
            ],
            shortTitle: "Open Chat",
            systemImageName: "bubble.left.and.bubble.right.fill"
        )
        AppShortcut(
            intent: OpenPostIntent(),
            phrases: [
                "Open post in \(.applicationName)",
                "View post using \(.applicationName)",
                "在 \(.applicationName) 打开帖子"
            ],
            shortTitle: "Open Post",
            systemImageName: "doc.text.fill"
        )
        AppShortcut(
            intent: OpenComposeIntent(),
            phrases: [
                "Open compose with \(.applicationName)",
                "New post using \(.applicationName)",
                "Write post in \(.applicationName)",
                "在 \(.applicationName) 撰写新帖子"
            ],
            shortTitle: "New Post",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SearchContentIntent(),
            phrases: [
                "Search in \(.applicationName)",
                "Find content using \(.applicationName)",
                "在 \(.applicationName) 搜索"
            ],
            shortTitle: "Search",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: CheckNotificationsIntent(),
            phrases: [
                "Check notifications with \(.applicationName)",
                "Get notifications using \(.applicationName)",
                "Do I have notifications in \(.applicationName)",
                "查看 \(.applicationName) 通知"
            ],
            shortTitle: "Check Notifications",
            systemImageName: "bell.fill"
        )
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send message with \(.applicationName)",
                "Send message in \(.applicationName)",
                "在 \(.applicationName) 发送消息"
            ],
            shortTitle: "Send Message",
            systemImageName: "paperplane.fill"
        )
        AppShortcut(
            intent: ReadMessagesIntent(),
            phrases: [
                "Read messages with \(.applicationName)",
                "Get chat messages using \(.applicationName)",
                "在 \(.applicationName) 读取消息"
            ],
            shortTitle: "Read Messages",
            systemImageName: "text.bubble.fill"
        )
        AppShortcut(
            intent: CheckUnreadChatsIntent(),
            phrases: [
                "Check unread chats with \(.applicationName)",
                "Do I have messages using \(.applicationName)",
                "Get unread messages with \(.applicationName)",
                "查看 \(.applicationName) 未读消息"
            ],
            shortTitle: "Unread Chats",
            systemImageName: "envelope.badge.fill"
        )
        AppShortcut(
            intent: MarkNotificationsReadIntent(),
            phrases: [
                "Mark notifications read with \(.applicationName)",
                "Clear notifications using \(.applicationName)",
                "Mark all read with \(.applicationName)",
                "标记 \(.applicationName) 通知为已读"
            ],
            shortTitle: "Mark Read",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
