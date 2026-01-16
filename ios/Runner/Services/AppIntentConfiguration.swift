//
//  AppIntentConfiguration.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import AppIntents

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "Open chat with \(.applicationName)",
                    "Go to chat using \(.applicationName)",
                    "Show chat in \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: OpenPostIntent(),
                phrases: [
                    "Open post with \(.applicationName)",
                    "Show post using \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: OpenComposeIntent(),
                phrases: [
                    "Open compose with \(.applicationName)",
                    "New post using \(.applicationName)",
                    "Write post in \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: SearchContentIntent(),
                phrases: [
                    "Search in \(.applicationName)",
                    "Find content using \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: CheckNotificationsIntent(),
                phrases: [
                    "Check notifications with \(.applicationName)",
                    "Get notifications using \(.applicationName)",
                    "Do I have notifications in \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: SendMessageIntent(),
                phrases: [
                    "Send message with \(.applicationName)",
                    "Post message using \(.applicationName)",
                    "Send text using \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: ReadMessagesIntent(),
                phrases: [
                    "Read messages with \(.applicationName)",
                    "Get chat using \(.applicationName)",
                    "Show messages with \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: CheckUnreadChatsIntent(),
                phrases: [
                    "Check unread chats with \(.applicationName)",
                    "Do I have messages using \(.applicationName)",
                    "Get unread messages with \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: MarkNotificationsReadIntent(),
                phrases: [
                    "Mark notifications read with \(.applicationName)",
                    "Clear notifications using \(.applicationName)",
                    "Mark all read with \(.applicationName)"
                ]
            )
        ]
    }
}
