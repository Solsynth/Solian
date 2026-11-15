//
//  SolianFriendsWidget.swift
//  SolianWidgetExtension
//

import Foundation
import SwiftUI
import WidgetKit

struct WidgetFriendOverviewItem: Codable, Identifiable {
    let account: WidgetFriendAccount
    let status: WidgetFriendStatus?

    var id: String { account.id }

    var isOnline: Bool {
        guard let status else { return false }
        return status.isOnline == true && status.isInvisible != true
    }

    var displayName: String {
        let nick = account.nick?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !nick.isEmpty { return nick }
        return account.name
    }

    var statusLabel: String {
        let custom = status?.label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !custom.isEmpty { return custom }
        if !isOnline { return "Offline" }
        switch status?.type {
        case 1: return "Busy"
        case 2: return "Do Not Disturb"
        default: return "Online"
        }
    }

    var statusColor: Color {
        if !isOnline { return .gray }
        switch status?.type {
        case 1: return .orange
        case 2: return .red
        default: return .green
        }
    }
}

struct WidgetFriendAccount: Codable {
    let id: String
    let name: String
    let nick: String?
    let profile: WidgetFriendProfile?
}

struct WidgetFriendProfile: Codable {
    let picture: SnCloudFile?
}

struct WidgetFriendStatus: Codable {
    let type: Int?
    let label: String?
    let symbol: String?
    let isOnline: Bool?
    let isInvisible: Bool?

    enum CodingKeys: String, CodingKey {
        case type, label, symbol
        case isOnline = "is_online"
        case isInvisible = "is_invisible"
    }
}

struct FriendsEntry: TimelineEntry {
    let date: Date
    let friends: [WidgetFriendOverviewItem]
    let onlineCount: Int
    let error: String?
}

final class FriendsWidgetService {
    private let networkService = WidgetNetworkService()

    func fetchFriends() async throws -> (friends: [WidgetFriendOverviewItem], onlineCount: Int) {
        let items: [WidgetFriendOverviewItem] = (try await networkService.makeRequest(
            path: "/stargate/friends/overview?includeOffline=true"
        )) ?? []

        let online = items.filter(\.isOnline)
        let display = online.isEmpty ? items : online
        return (display, online.count)
    }
}

struct FriendsProvider: TimelineProvider {
    private let service = FriendsWidgetService()

    func placeholder(in context: Context) -> FriendsEntry {
        FriendsEntry(date: Date(), friends: [], onlineCount: 0, error: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (FriendsEntry) -> Void) {
        Task {
            let result = try? await service.fetchFriends()
            completion(FriendsEntry(
                date: Date(),
                friends: result?.friends ?? [],
                onlineCount: result?.onlineCount ?? 0,
                error: nil
            ))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FriendsEntry>) -> Void) {
        Task {
            let now = Date()
            do {
                let result = try await service.fetchFriends()
                let entry = FriendsEntry(
                    date: now,
                    friends: result.friends,
                    onlineCount: result.onlineCount,
                    error: nil
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            } catch {
                let entry = FriendsEntry(
                    date: now,
                    friends: [],
                    onlineCount: 0,
                    error: error.localizedDescription
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            }
        }
    }
}

struct FriendsWidgetEntryView: View {
    let entry: FriendsEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Link(destination: URL(string: "solian://dashboard")!) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.tint)
                    Text("Friends")
                        .font(.headline)
                    Spacer()
                    if entry.onlineCount > 0 {
                        Text("\(entry.onlineCount) online")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                if let error = entry.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else if entry.friends.isEmpty {
                    Spacer()
                    Text("No friends online")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    let limit = family == .systemSmall ? 2 : (family == .systemLarge ? 6 : 3)
                    ForEach(entry.friends.prefix(limit)) { friend in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(friend.statusColor)
                                .frame(width: 8, height: 8)
                            Text(friend.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Spacer()
                            if family != .systemSmall {
                                Text(friend.statusLabel)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(12)
        }
    }
}

struct SolianFriendsWidget: Widget {
    let kind = "SolianFriendsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FriendsProvider()) { entry in
            if #available(iOS 17.0, *) {
                FriendsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FriendsWidgetEntryView(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("Friends Online")
        .description("See which friends are online and their current status.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
