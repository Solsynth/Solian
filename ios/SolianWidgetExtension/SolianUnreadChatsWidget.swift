//
//  SolianUnreadChatsWidget.swift
//  SolianWidgetExtension
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct WidgetChatRoom: Codable, Identifiable {
    let id: String
    let name: String?
    let type: Int
    let members: [WidgetChatMember]?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, members
        case updatedAt = "updated_at"
    }

    var displayName: String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty { return trimmed }
        let memberNames = (members ?? []).compactMap(\.displayName)
        if !memberNames.isEmpty {
            return memberNames.joined(separator: ", ")
        }
        return "Chat \(id.prefix(6))"
    }
}

struct WidgetChatMember: Codable {
    let id: String
    let nick: String?
    let username: String?
    let account: WidgetChatAccount?

    var displayName: String? {
        let candidates = [nick, account?.nick, account?.name, username]
        return candidates.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.first { !$0.isEmpty }
    }
}

struct WidgetChatAccount: Codable {
    let id: String?
    let name: String?
    let nick: String?
}

struct WidgetChatSummary: Codable {
    let unreadCount: Int
    let lastMessage: WidgetChatMessage?

    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
        case lastMessage = "last_message"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
        lastMessage = try container.decodeIfPresent(WidgetChatMessage.self, forKey: .lastMessage)
    }
}

struct WidgetChatMessage: Codable {
    let content: String?
    let type: String?
    let sender: WidgetChatMember?

    var previewText: String {
        let trimmed = content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty { return trimmed }
        return "[\(type ?? "attachment")]"
    }
}

struct WidgetChatRoomsWrapper: Codable {
    let rooms: [WidgetChatRoom]?
    let items: [WidgetChatRoom]?
}

struct WidgetConversationPreview: Identifiable {
    let id: String
    let title: String
    let unreadCount: Int
    let lastMessage: String?
    let senderName: String?
}

@available(iOS 17.0, *)
struct WidgetChatRoomEntity: AppEntity {
    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Chat Room")
    }

    static var defaultQuery = WidgetChatRoomEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

@available(iOS 17.0, *)
struct WidgetChatRoomEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [WidgetChatRoomEntity] {
        let rooms = (try? await UnreadChatsService().fetchRooms()) ?? []
        return rooms
            .filter { identifiers.contains($0.id) }
            .map { WidgetChatRoomEntity(id: $0.id, name: $0.displayName) }
    }

    func suggestedEntities() async throws -> [WidgetChatRoomEntity] {
        let rooms = (try? await UnreadChatsService().fetchRooms()) ?? []
        return rooms.prefix(20).map { WidgetChatRoomEntity(id: $0.id, name: $0.displayName) }
    }
}

@available(iOS 17.0, *)
struct SelectChatRoomWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Chat Room"
    static var description = IntentDescription("Optionally pin a specific chat room, or leave empty to show unread chats.")

    @Parameter(title: "Chat Room")
    var chatRoom: WidgetChatRoomEntity?
}

struct UnreadChatsEntry: TimelineEntry {
    let date: Date
    let totalUnread: Int
    let conversations: [WidgetConversationPreview]
    let pinnedRoomId: String?
    let error: String?
}

final class UnreadChatsService {
    private let networkService = WidgetNetworkService()

    func fetchUnreadCount() async throws -> Int {
        if let count: Int = try? await networkService.makeRequest(path: "/messager/chat/unread") {
            return count
        }
        return 0
    }

    func fetchSummary() async throws -> [String: WidgetChatSummary] {
        (try await networkService.makeRequest(path: "/messager/chat/summary")) ?? [:]
    }

    func fetchRooms() async throws -> [WidgetChatRoom] {
        if let direct: [WidgetChatRoom] = try? await networkService.makeRequest(path: "/messager/chat") {
            return direct
        }
        if let wrapped: WidgetChatRoomsWrapper = try? await networkService.makeRequest(path: "/messager/chat") {
            return wrapped.rooms ?? wrapped.items ?? []
        }
        return []
    }

    func fetchOverview(pinnedRoomId: String? = nil) async throws -> (totalUnread: Int, conversations: [WidgetConversationPreview]) {
        async let totalTask = fetchUnreadCount()
        async let summaryTask = fetchSummary()
        async let roomsTask = fetchRooms()

        let total = try await totalTask
        let summary = (try? await summaryTask) ?? [:]
        let rooms = (try? await roomsTask) ?? []

        let roomById = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })

        if let pinnedRoomId {
            let roomSummary = summary[pinnedRoomId]
            let title = roomById[pinnedRoomId]?.displayName ?? "Chat"
            let preview = WidgetConversationPreview(
                id: pinnedRoomId,
                title: title,
                unreadCount: roomSummary?.unreadCount ?? 0,
                lastMessage: roomSummary?.lastMessage?.previewText,
                senderName: roomSummary?.lastMessage?.sender?.displayName
            )
            return (roomSummary?.unreadCount ?? total, [preview])
        }

        let unreadPreviews = summary
            .filter { $0.value.unreadCount > 0 || $0.value.lastMessage != nil }
            .sorted { lhs, rhs in
                if lhs.value.unreadCount != rhs.value.unreadCount {
                    return lhs.value.unreadCount > rhs.value.unreadCount
                }
                return lhs.key < rhs.key
            }
            .map { roomId, item in
                WidgetConversationPreview(
                    id: roomId,
                    title: roomById[roomId]?.displayName ?? "Chat \(roomId.prefix(6))",
                    unreadCount: item.unreadCount,
                    lastMessage: item.lastMessage?.previewText,
                    senderName: item.lastMessage?.sender?.displayName
                )
            }

        return (total, unreadPreviews)
    }
}

@available(iOS 17.0, *)
struct UnreadChatsIntentProvider: AppIntentTimelineProvider {
    private let service = UnreadChatsService()

    func placeholder(in context: Context) -> UnreadChatsEntry {
        UnreadChatsEntry(date: Date(), totalUnread: 0, conversations: [], pinnedRoomId: nil, error: nil)
    }

    func snapshot(for configuration: SelectChatRoomWidgetIntent, in context: Context) async -> UnreadChatsEntry {
        let pinnedId = configuration.chatRoom?.id
        let overview = try? await service.fetchOverview(pinnedRoomId: pinnedId)
        return UnreadChatsEntry(
            date: Date(),
            totalUnread: overview?.totalUnread ?? 0,
            conversations: overview?.conversations ?? [],
            pinnedRoomId: pinnedId,
            error: nil
        )
    }

    func timeline(for configuration: SelectChatRoomWidgetIntent, in context: Context) async -> Timeline<UnreadChatsEntry> {
        let now = Date()
        let pinnedId = configuration.chatRoom?.id
        do {
            let overview = try await service.fetchOverview(pinnedRoomId: pinnedId)
            let entry = UnreadChatsEntry(
                date: now,
                totalUnread: overview.totalUnread,
                conversations: overview.conversations,
                pinnedRoomId: pinnedId,
                error: nil
            )
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        } catch {
            let entry = UnreadChatsEntry(
                date: now,
                totalUnread: 0,
                conversations: [],
                pinnedRoomId: pinnedId,
                error: error.localizedDescription
            )
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        }
    }
}

struct UnreadChatsStaticProvider: TimelineProvider {
    private let service = UnreadChatsService()

    func placeholder(in context: Context) -> UnreadChatsEntry {
        UnreadChatsEntry(date: Date(), totalUnread: 0, conversations: [], pinnedRoomId: nil, error: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (UnreadChatsEntry) -> Void) {
        Task {
            let overview = try? await service.fetchOverview()
            completion(UnreadChatsEntry(
                date: Date(),
                totalUnread: overview?.totalUnread ?? 0,
                conversations: overview?.conversations ?? [],
                pinnedRoomId: nil,
                error: nil
            ))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UnreadChatsEntry>) -> Void) {
        Task {
            let now = Date()
            do {
                let overview = try await service.fetchOverview()
                let entry = UnreadChatsEntry(
                    date: now,
                    totalUnread: overview.totalUnread,
                    conversations: overview.conversations,
                    pinnedRoomId: nil,
                    error: nil
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            } catch {
                let entry = UnreadChatsEntry(
                    date: now,
                    totalUnread: 0,
                    conversations: [],
                    pinnedRoomId: nil,
                    error: error.localizedDescription
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            }
        }
    }
}

struct UnreadChatsWidgetEntryView: View {
    let entry: UnreadChatsEntry
    @Environment(\.widgetFamily) private var family

    private var defaultDestination: URL {
        if let pinnedRoomId = entry.pinnedRoomId {
            return URL(string: "solian://chat/\(pinnedRoomId)")!
        }
        return URL(string: "solian://chat")!
    }

    var body: some View {
        if family == .accessoryCircular {
            Link(destination: defaultDestination) {
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 1) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.caption2)
                        Text("\(entry.totalUnread)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Link(destination: defaultDestination) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(.tint)
                        Text(entry.pinnedRoomId != nil ? (entry.conversations.first?.title ?? "Chat") : "Messages")
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        if entry.totalUnread > 0 {
                            Text("\(entry.totalUnread)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }

                if let error = entry.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else if entry.conversations.isEmpty {
                    Spacer()
                    Text("No unread messages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    let limit = family == .systemSmall ? 1 : (family == .systemLarge ? 5 : 2)
                    ForEach(entry.conversations.prefix(limit)) { item in
                        Link(destination: URL(string: "solian://chat/\(item.id)")!) {
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(item.title)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        Spacer()
                                        if item.unreadCount > 0 {
                                            Text("\(item.unreadCount)")
                                                .font(.caption2)
                                                .foregroundStyle(.tint)
                                        }
                                    }
                                    if let lastMessage = item.lastMessage {
                                        let prefix = item.senderName.map { "\($0): " } ?? ""
                                        Text("\(prefix)\(lastMessage)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(family == .systemSmall ? 2 : 1)
                                    }
                                }
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

struct SolianUnreadChatsWidget: Widget {
    let kind = "SolianUnreadChatsWidget"

    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: SelectChatRoomWidgetIntent.self,
                provider: UnreadChatsIntentProvider()
            ) { entry in
                UnreadChatsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
            .configurationDisplayName("Unread Chats")
            .description("View unread message counts and recent conversations.")
            .supportedFamilies(supportedFamilies)
        } else {
            return StaticConfiguration(kind: kind, provider: UnreadChatsStaticProvider()) { entry in
                UnreadChatsWidgetEntryView(entry: entry)
                    .background()
            }
            .configurationDisplayName("Unread Chats")
            .description("View unread message counts and recent conversations.")
            .supportedFamilies(supportedFamilies)
        }
    }

    private var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular]
#else
        return [.systemSmall, .systemMedium, .systemLarge]
#endif
    }
}
