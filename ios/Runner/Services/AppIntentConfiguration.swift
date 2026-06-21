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
                "在 \(.applicationName) 打开聊天",
                "在 \(.applicationName) 開啟聊天"
            ],
            shortTitle: "intent_open_chat_short_title",
            systemImageName: "bubble.left.and.bubble.right.fill"
        )
        AppShortcut(
            intent: OpenPostIntent(),
            phrases: [
                "Open post in \(.applicationName)",
                "View post using \(.applicationName)",
                "在 \(.applicationName) 打开帖子",
                "在 \(.applicationName) 打開貼文"
            ],
            shortTitle: "intent_open_post_short_title",
            systemImageName: "doc.text.fill"
        )
        AppShortcut(
            intent: OpenComposeIntent(),
            phrases: [
                "Open compose with \(.applicationName)",
                "New post using \(.applicationName)",
                "Write post in \(.applicationName)",
                "在 \(.applicationName) 撰写新帖子",
                "在 \(.applicationName) 撰寫新貼文"
            ],
            shortTitle: "intent_open_compose_short_title",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SearchContentIntent(),
            phrases: [
                "Search in \(.applicationName)",
                "Find content using \(.applicationName)",
                "在 \(.applicationName) 搜索",
                "在 \(.applicationName) 搜尋"
            ],
            shortTitle: "intent_search_short_title",
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
            shortTitle: "intent_check_notifications_short_title",
            systemImageName: "bell.fill"
        )
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send message with \(.applicationName)",
                "Send message in \(.applicationName)",
                "在 \(.applicationName) 发送消息",
                "在 \(.applicationName) 傳送訊息"
            ],
            shortTitle: "intent_send_message_short_title",
            systemImageName: "paperplane.fill"
        )
        AppShortcut(
            intent: ReadMessagesIntent(),
            phrases: [
                "Read messages with \(.applicationName)",
                "Get chat messages using \(.applicationName)",
                "在 \(.applicationName) 读取消息",
                "在 \(.applicationName) 讀取訊息"
            ],
            shortTitle: "intent_read_messages_short_title",
            systemImageName: "text.bubble.fill"
        )
        AppShortcut(
            intent: CheckUnreadChatsIntent(),
            phrases: [
                "Check unread chats with \(.applicationName)",
                "Do I have messages using \(.applicationName)",
                "Get unread messages with \(.applicationName)",
                "查看 \(.applicationName) 未读消息",
                "查看 \(.applicationName) 未讀訊息"
            ],
            shortTitle: "intent_unread_chats_short_title",
            systemImageName: "envelope.badge.fill"
        )
        AppShortcut(
            intent: MarkNotificationsReadIntent(),
            phrases: [
                "Mark notifications read with \(.applicationName)",
                "Clear notifications using \(.applicationName)",
                "Mark all read with \(.applicationName)",
                "标记 \(.applicationName) 通知为已读",
                "標記 \(.applicationName) 通知為已讀"
            ],
            shortTitle: "intent_mark_read_short_title",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
