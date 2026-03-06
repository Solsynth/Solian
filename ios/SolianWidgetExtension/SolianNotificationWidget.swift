//
//  SolianNotificationWidget.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/4.
//

import Foundation
import WidgetKit
import SwiftUI

// MARK: - Notification Widget

struct NotificationMeta: Codable {
    let pfp: String?
    let images: [String]?
    let actionUri: String?
    
    enum CodingKeys: String, CodingKey {
        case pfp
        case images
        case actionUri = "action_uri"
    }
}

struct SnNotification: Codable, Identifiable {
    let id: String
    let topic: String
    let title: String
    let subtitle: String
    let content: String
    let meta: NotificationMeta?
    let priority: Int
    let viewedAt: String?
    let accountId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case topic
        case title
        case subtitle
        case content
        case meta
        case priority
        case viewedAt = "viewed_at"
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: createdAt) {
            return date
        }

        // Fallback for timestamps without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt)
    }
    
    var isUnread: Bool {
        return viewedAt == nil
    }
    
    func getTopicIcon() -> String {
        switch topic {
        case "post.replies":
            return "arrow.uturn.backward"
        case "wallet.transactions":
            return "wallet.pass"
        case "relationships.friends.request":
            return "person.badge.plus"
        case "invites.chat":
            return "message.badge"
        case "invites.realm":
            return "globe"
        case "auth.login":
            return "arrow.right.square"
        case "posts.new":
            return "doc.badge.plus"
        case "wallet.orders.paid":
            return "baggage"
        case "posts.reactions.new":
            return "face.smiling"
        default:
            return "bell"
        }
    }
}

struct NotificationEntry: TimelineEntry {
    let date: Date
    let notifications: [SnNotification]?
    let unreadCount: Int
    let error: String?
    let isLoading: Bool
    
    static func placeholder() -> NotificationEntry {
        NotificationEntry(date: Date(), notifications: nil, unreadCount: 0, error: nil, isLoading: true)
    }
}

class NotificationService {
    private let networkService = WidgetNetworkService()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
    
    func fetchRecentNotifications(take: Int = 5) async throws -> [SnNotification] {
        if take == 0 {
            return []
        }
        
        guard let token = networkService.token else {
            throw RemoteError.missingCredentials
        }
        
        let baseURL = networkService.baseURL
        guard let url = URL(string: "\(baseURL)/ring/notifications?unmark=true&take=\(take)") else {
            throw RemoteError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            let notifications = try decoder.decode([SnNotification].self, from: data)
            return notifications
        case 404:
            return []
        default:
            throw RemoteError.httpError(httpResponse.statusCode)
        }
    }
    
    func fetchUnreadCount() async throws -> Int {
        guard let token = networkService.token else {
            throw RemoteError.missingCredentials
        }
        
        let baseURL = networkService.baseURL
        guard let url = URL(string: "\(baseURL)/ring/notifications/count") else {
            throw RemoteError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            if let count = try? JSONSerialization.jsonObject(with: data) as? Int {
                return count
            } else if let count = try? JSONSerialization.jsonObject(with: data) as? Double {
                return Int(count)
            }
            return 0
        case 404:
            return 0
        default:
            throw RemoteError.httpError(httpResponse.statusCode)
        }
    }
}

struct NotificationProvider: TimelineProvider {
    private let notificationService = NotificationService()
    
    func placeholder(in context: Context) -> NotificationEntry {
        NotificationEntry.placeholder()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NotificationEntry) -> ()) {
        Task {
            print("[WidgetKit] [NotificationProvider] Getting snapshot...")
            async let notifications = try? await notificationService.fetchRecentNotifications(take: 5)
            async let unreadCount = try? await notificationService.fetchUnreadCount()
            
            let notifs = try? await notifications
            let unread = (try? await unreadCount) ?? 0
            
            print("[WidgetKit] [NotificationProvider] Snapshot - Notifications: \(notifs?.count ?? 0), Unread: \(unread)")
            
            let entry = NotificationEntry(date: Date(), notifications: notifs, unreadCount: unread, error: nil, isLoading: false)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currentDate = Date()
            print("[WidgetKit] [NotificationProvider] Getting timeline at \(currentDate)...")
            
            do {
                let takeLimit: Int
                switch context.family {
                case .systemSmall:
                    takeLimit = 0
                case .systemMedium:
                    takeLimit = 1
                case .systemLarge:
                    takeLimit = 3
                default:
                    takeLimit = 0
                }
                
                async let notifications = try await notificationService.fetchRecentNotifications(take: takeLimit)
                async let unreadCount = try await notificationService.fetchUnreadCount()
                
                let notifs = try await notifications
                let unread = try await unreadCount
                
                print("[WidgetKit] [NotificationProvider] Timeline - Notifications: \(notifs.count), Unread: \(unread)")
                
                let entry = NotificationEntry(date: currentDate, notifications: notifs, unreadCount: unread, error: nil, isLoading: false)
                
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
                print("[WidgetKit] [NotificationProvider] Next update at: \(nextUpdate)")
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("[WidgetKit] [NotificationProvider] Error in getTimeline: \(error.localizedDescription)")
                let entry = NotificationEntry(date: currentDate, notifications: nil, unreadCount: 0, error: error.localizedDescription, isLoading: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct NotificationWidgetEntryView: View {
    var entry: NotificationProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let notifications = entry.notifications, !notifications.isEmpty {
            HasNotificationsView(notifications: notifications, unreadCount: entry.unreadCount)
        } else if entry.isLoading {
            LoadingView()
        } else if let error = entry.error {
            ErrorView(error: error)
        } else {
            EmptyView()
        }
    }
    
    private var isCompact: Bool {
        family == .systemSmall || isAccessory
    }
    
    private var isAccessory: Bool {
        if #available(iOS 16.0, *) {
            if case .accessoryRectangular = family {
                return true
            }
            if case .accessoryCircular = family {
                return true
            }
        }
        return false
    }
    
    private var isCircular: Bool {
        if #available(iOS 16.0, *) {
            if case .accessoryCircular = family {
                return true
            }
        }
        return false
    }
    
    @ViewBuilder
    private func HasNotificationsView(notifications: [SnNotification], unreadCount: Int) -> some View {
        Link(destination: URL(string: "solian://notifications")!) {
            if isCompact {
                if isAccessory {
                    if isCircular {
                        ZStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(unreadCount > 0 ? .orange : .gray)
                            
                            if unreadCount > 0 {
                                Text("\(min(unreadCount, 99))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Circle().fill(Color.blue))
                                    .offset(x: 12, y: -12)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "bell.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .padding(.leading, 1.5)
                                
                                Text(NSLocalizedString("notifications", comment: "Notifications"))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            
                            if unreadCount > 0 {
                                HStack(spacing: 4) {
                                    Text("\(unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue.opacity(0.5))
                                        )
                                    
                                    Text(NSLocalizedString("unread", comment: "unread"))
                                        .font(.caption2)
                                }
                            }
                            
                            Text("on the Solar Network")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 1.5)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Text(NSLocalizedString("notifications", comment: "Notifications"))
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }.padding(.bottom, 8)
                        
                        Spacer(minLength: 2)
                        
                        if unreadCount > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(unreadCount)")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                
                            }
                        }
                        
                        Spacer(minLength: 2)
                        
                        if unreadCount > 0 {
                            Text(NSLocalizedString("unreadNotifications", comment: "unread notifications"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(NSLocalizedString("noUnreadNotifications", comment: "no unread notifications"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Text(NSLocalizedString("notifications", comment: "Notifications"))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                    }.padding(.bottom, 8)
                    
                    let displayCount = family == .systemMedium ? 1 : 5
                    let displayNotifications = Array(notifications.prefix(displayCount))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(displayNotifications) { notification in
                            NotificationItemView(notification: notification, compact: false)
                        }
                    }
                    
                    if family == .systemMedium {
                        Spacer()
                    } else {
                        Spacer()
                        Text(NSLocalizedString("tapToViewAll", comment: "Tap to view all notifications"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
            }
        }
    }
    
    @ViewBuilder
    private func NotificationItemView(notification: SnNotification, compact: Bool) -> some View {
        HStack(alignment: .top, spacing: compact ? 6 : 12) {
            if compact {
                Image(systemName: notification.getTopicIcon())
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: notification.getTopicIcon())
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(notification.isUnread ? .semibold : .regular)
                    .lineLimit(1)
                
                if !compact && !notification.subtitle.isEmpty {
                    Text(notification.subtitle)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                if !compact && !notification.content.isEmpty {
                    Text(notification.content)
                        .font(.caption2)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                if let createdDate = notification.createdDate {
                    Text(formatRelativeTime(createdDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            if notification.isUnread {
                Circle()
                    .fill(Color.blue)
                    .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
                    .padding(.trailing, 6)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, compact ? 2 : 4)
    }
    
    @ViewBuilder
    private func NotificationCompactItem(notification: SnNotification) -> some View {
        HStack(spacing: 4) {
            Image(systemName: notification.getTopicIcon())
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(notification.title)
                .font(.caption2)
                .lineLimit(1)
                .fontWeight(notification.isUnread ? .semibold : .regular)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func EmptyView() -> some View {
        Link(destination: URL(string: "solian://notifications")!) {
            if isCircular {
                ZStack {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading, spacing: isAccessory ? 4 : 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "bell")
                            .font(isAccessory ? .caption : .title3)
                            .foregroundColor(.secondary)
                        
                        Text(NSLocalizedString("notifications", comment: "Notifications"))
                            .font(isAccessory ? .caption2 : .headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    if !isAccessory {
                        Text(NSLocalizedString("noNotifications", comment: "No notifications yet"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .padding(isAccessory ? 4 : 12)
            }
        }
    }
    
    @ViewBuilder
    private func LoadingView() -> some View {
        if isCircular {
            ProgressView()
                .scaleEffect(0.8)
        } else {
            VStack(alignment: .leading, spacing: isAccessory ? 4 : 8) {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(isAccessory ? 0.6 : 0.8)
                    Text(NSLocalizedString("loading", comment: "Loading..."))
                        .font(isAccessory ? .caption2 : .caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                if !isAccessory {
                    Spacer()
                }
            }
            .padding(isAccessory ? 4 : 12)
        }
    }
    
    @ViewBuilder
    private func ErrorView(error: String) -> some View {
        Link(destination: URL(string: "solian://notifications")!) {
            if isCircular {
                ZStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            } else {
                VStack(alignment: .leading, spacing: isAccessory ? 4 : 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.secondary)
                            .font(isAccessory ? .caption : .title3)
                        
                        Text(NSLocalizedString("error", comment: "Error"))
                            .font(isAccessory ? .caption2 : .headline)
                        Spacer()
                    }
                    
                    if !isAccessory {
                        Text(NSLocalizedString("openAppToRefresh", comment: "Open app to refresh"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                .padding(isAccessory ? 4 : 12)
            }
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return NSLocalizedString("justNow", comment: "Just now")
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return String(format: NSLocalizedString("minutesAgo", comment: "%d min ago"), minutes)
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return String(format: NSLocalizedString("hoursAgo", comment: "%d hr ago"), hours)
        } else {
            let days = Int(interval / 86400)
            return String(format: NSLocalizedString("daysAgo", comment: "%d d ago"), days)
        }
    }
}

struct NotificationWidgetRootView: View {
    var entry: NotificationProvider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                NotificationWidgetEntryView(entry: entry)
                
                if let notifications = entry.notifications, !notifications.isEmpty {
                    GeometryReader { geometry in
                        Image(colorScheme == .dark ? "CloudyLambDark" : "CloudyLamb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: geometry.size.width * 0.9,
                                height: geometry.size.width * 0.9
                            )
                            .opacity(0.12)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white,
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .position(
                                x: geometry.size.width * 0.85,
                                y: 20
                            )
                    }
                    .allowsHitTesting(false)
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
            .padding(.vertical, 8)
        } else {
            NotificationWidgetEntryView(entry: entry)
                .padding()
                .background()
        }
    }
}

struct SolianNotificationWidget: Widget {
    let kind: String = "SolianNotificationWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NotificationProvider()) { entry in
            NotificationWidgetRootView(entry: entry)
        }
        .configurationDisplayName("Notifications")
        .description("View your recent notifications")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        return [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular]
#else
        return [.systemSmall, .systemMedium, .systemLarge]
#endif
    }
}

#if os(iOS)
#Preview(as: .accessoryRectangular) {
    SolianNotificationWidget()
} timeline: {
    NotificationEntry(
        date: .now,
        notifications: [
            SnNotification(
                id: "1",
                topic: "post.replies",
                title: "New reply to your post",
                subtitle: "Someone replied to your message",
                content: "This is notification content",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "2",
                topic: "relationships.friends.request",
                title: "New friend request",
                subtitle: "You have a pending friend request",
                content: "Someone wants to be your friend",
                meta: nil,
                priority: 0,
                viewedAt: ISO8601DateFormatter().string(from: Date()),
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            )
        ],
        unreadCount: 1,
        error: nil,
        isLoading: false
    )
}
#endif

#Preview(as: .systemSmall) {
    SolianNotificationWidget()
} timeline: {
    NotificationEntry(
        date: .now,
        notifications: [
            SnNotification(
                id: "1",
                topic: "post.replies",
                title: "New reply to your post",
                subtitle: "Someone replied to your message",
                content: "This is notification content",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "2",
                topic: "relationships.friends.request",
                title: "New friend request",
                subtitle: "You have a pending friend request",
                content: "Someone wants to be your friend",
                meta: nil,
                priority: 0,
                viewedAt: ISO8601DateFormatter().string(from: Date()),
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            )
        ],
        unreadCount: 1,
        error: nil,
        isLoading: false
    )
}

#Preview(as: .systemMedium) {
    SolianNotificationWidget()
} timeline: {
    NotificationEntry(
        date: .now,
        notifications: [
            SnNotification(
                id: "1",
                topic: "post.replies",
                title: "New reply to your post",
                subtitle: "Someone replied to your message",
                content: "This is notification content",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "2",
                topic: "relationships.friends.request",
                title: "New friend request",
                subtitle: "You have a pending friend request",
                content: "Someone wants to be your friend",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "3",
                topic: "invites.chat",
                title: "New chat invite",
                subtitle: "You've been invited to a chat",
                content: "Join the conversation",
                meta: nil,
                priority: 0,
                viewedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            )
        ],
        unreadCount: 2,
        error: nil,
        isLoading: false
    )
}

#if os(iOS)
#Preview(as: .systemLarge) {
    SolianNotificationWidget()
} timeline: {
    NotificationEntry(
        date: .now,
        notifications: [
            SnNotification(
                id: "1",
                topic: "post.replies",
                title: "New reply",
                subtitle: "Someone replied",
                content: "Content",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "2",
                topic: "relationships.friends.request",
                title: "New friend request",
                subtitle: "You have a pending friend request",
                content: "Someone wants to be your friend",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            ),
            SnNotification(
                id: "3",
                topic: "invites.chat",
                title: "New chat invite",
                subtitle: "You've been invited to a chat",
                content: "Join the conversation",
                meta: nil,
                priority: 0,
                viewedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            )
        ],
        unreadCount: 3,
        error: nil,
        isLoading: false
    )
}

#Preview(as: .accessoryCircular) {
    SolianNotificationWidget()
} timeline: {
    NotificationEntry(
        date: .now,
        notifications: [
            SnNotification(
                id: "1",
                topic: "post.replies",
                title: "New reply",
                subtitle: "Someone replied",
                content: "Content",
                meta: nil,
                priority: 0,
                viewedAt: nil,
                accountId: "acc-1",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                deletedAt: nil
            )
        ],
        unreadCount: 5,
        error: nil,
        isLoading: false
    )
}
#endif
