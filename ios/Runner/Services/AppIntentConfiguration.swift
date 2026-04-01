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
                "Open chat with \(\.$chatRoom) in \(.applicationName)",
                "Open \(\.$chatRoom) chat in \(.applicationName)",
                "Open conversation with \(\.$chatRoom) using \(.applicationName)",
                "在 \(.applicationName) 打开 \(\.$chatRoom) 聊天",
                "在 \(.applicationName) 和 \(\.$chatRoom) 聊天"
            ],
            shortTitle: "Open Chat",
            systemImageName: "bubble.left.and.bubble.right.fill"
        )
        AppShortcut(
            intent: OpenPostIntent(),
            phrases: [
                "Open post \(\.$post) in \(.applicationName)",
                "View \(\.$post) post using \(.applicationName)",
                "在 \(.applicationName) 打开帖子 \(\.$post)",
                "在 \(.applicationName) 查看 \(\.$post)"
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
                "在 \(.applicationName) 撰写新帖子",
                "用 \(.applicationName) 发帖子"
            ],
            shortTitle: "New Post",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SearchContentIntent(),
            phrases: [
                "Search in \(.applicationName) for \(\.$query)",
                "Find \(\.$query) using \(.applicationName)",
                "在 \(.applicationName) 搜索 \(\.$query)",
                "用 \(.applicationName) 找 \(\.$query)"
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
                "查看 \(.applicationName) 通知",
                "\(.applicationName) 有新通知吗"
            ],
            shortTitle: "Check Notifications",
            systemImageName: "bell.fill"
        )
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send message to \(\.$chatRoom) in \(.applicationName)",
                "Message \(\.$message) to \(\.$chatRoom) using \(.applicationName)",
                "Send \"\(\.$message)\" to \(\.$chatRoom) with \(.applicationName)",
                "在 \(.applicationName) 给 \(\.$chatRoom) 发送消息",
                "用 \(.applicationName) 发消息给 \(\.$chatRoom)"
            ],
            shortTitle: "Send Message",
            systemImageName: "paperplane.fill"
        )
        AppShortcut(
            intent: ReadMessagesIntent(),
            phrases: [
                "Read messages from \(\.$chatRoom) in \(.applicationName)",
                "Get chat messages from \(\.$chatRoom) using \(.applicationName)",
                "在 \(.applicationName) 读取 \(\.$chatRoom) 的消息",
                "查看 \(\.$chatRoom) 的聊天记录"
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
                "查看 \(.applicationName) 未读消息",
                "\(.applicationName) 有多少未读"
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
                "标记 \(.applicationName) 通知为已读",
                "清除 \(.applicationName) 通知"
            ],
            shortTitle: "Mark Read",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
