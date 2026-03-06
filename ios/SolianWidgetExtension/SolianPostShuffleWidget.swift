//
//  SolianPostShuffleWidget.swift
//  SolianWidgetExtension
//
//  Created by LittleSheep on 2026/1/4.
//

import Foundation
import WidgetKit
import SwiftUI

struct SnPostPublisher: Codable {
    let id: String
    let name: String
    let nick: String?
    let description: String?
    let picture: SnCloudFile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nick
        case description
        case picture
    }
}

struct SnCloudFile: Codable {
    let id: String
    let url: String?
    let thumbnail: String?
    let mimeType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnail
        case mimeType = "mimetype"
    }
}

struct SnPost: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let content: String?
    let publisher: SnPostPublisher
    let tags: [SnPostTag]?
    let createdAt: String?
    let updatedAt: String?
    let attachments: [SnCloudFile]?
    
    var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: createdAt) {
            return date
        }

        // Fallback for timestamps without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt)
    }
    
    var hasTitle: Bool {
        guard let title = title else { return false }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasDescription: Bool {
        guard let description = description else { return false }
        return !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasContent: Bool {
        guard let content = content else { return false }
        return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var attachmentCount: Int {
        attachments?.count ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case publisher
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case attachments
    }
}

struct SnPostTag: Codable {
    let id: String
    let slug: String
    let name: String?
}

class PostShuffleService {
    private let networkService = WidgetNetworkService()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
    
    func fetchRandomPost() async throws -> SnPost? {
        guard let token = networkService.token else {
            throw RemoteError.missingCredentials
        }
        
        let baseURL = networkService.baseURL
        guard let url = URL(string: "\(baseURL)/sphere/posts?shuffle=true&take=1") else {
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
            let posts = try decoder.decode([SnPost].self, from: data)
            return posts.first
        case 404:
            return nil
        default:
            throw RemoteError.httpError(httpResponse.statusCode)
        }
    }
}

struct PostShuffleEntry: TimelineEntry {
    let date: Date
    let post: SnPost?
    let error: String?
    let isLoading: Bool
    
    static func placeholder() -> PostShuffleEntry {
        PostShuffleEntry(date: Date(), post: nil, error: nil, isLoading: true)
    }
}

struct PostShuffleProvider: TimelineProvider {
    private let postShuffleService = PostShuffleService()
    
    func placeholder(in context: Context) -> PostShuffleEntry {
        PostShuffleEntry.placeholder()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PostShuffleEntry) -> ()) {
        Task {
            print("[WidgetKit] [PostShuffleProvider] Getting snapshot...")
            let post = try? await postShuffleService.fetchRandomPost()
            
            print("[WidgetKit] [PostShuffleProvider] Snapshot - Post: \(post != nil ? "Found" : "Not found")")
            
            let entry = PostShuffleEntry(date: Date(), post: post, error: nil, isLoading: false)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currentDate = Date()
            print("[WidgetKit] [PostShuffleProvider] Getting timeline at \(currentDate)...")
            
            do {
                let post = try await postShuffleService.fetchRandomPost()
                
                print("[WidgetKit] [PostShuffleProvider] Timeline - Post: \(post != nil ? "Found" : "Not found")")
                
                let entry = PostShuffleEntry(date: currentDate, post: post, error: nil, isLoading: false)
                
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                print("[WidgetKit] [PostShuffleProvider] Next update at: \(nextUpdate)")
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("[WidgetKit] [PostShuffleProvider] Error in getTimeline: \(error.localizedDescription)")
                let entry = PostShuffleEntry(date: currentDate, post: nil, error: error.localizedDescription, isLoading: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct PostShuffleWidgetEntryView: View {
    var entry: PostShuffleProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let post = entry.post {
            PostContentView(post: post)
        } else if entry.isLoading {
            LoadingView()
        } else if let error = entry.error {
            ErrorView(error: error)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func PostContentView(post: SnPost) -> some View {
        Link(destination: URL(string: "solian://posts/\(post.id)")!) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    if let avatarUrl = post.publisher.picture?.url ?? post.publisher.picture?.thumbnail {
                        AsyncImage(url: URL(string: avatarUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            default:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.5)
                                    )
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.publisher.nick ?? post.publisher.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        if let createdDate = post.createdDate {
                            Text(formatRelativeTime(createdDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                if post.attachmentCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(post.attachmentCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if post.hasTitle {
                    Text(post.title!)
                        .font(family == .systemMedium ? .subheadline : .body)
                        .fontWeight(.semibold)
                        .lineLimit(family == .systemMedium ? 2 : 3)
                }
                
                if post.hasDescription {
                    Text(post.description!)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(family == .systemMedium ? 2 : 4)
                }
                
                if post.hasContent {
                    Text(post.content!)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(family == .systemMedium ? 3 : 8)
                }
                
                if let tags = post.tags, !tags.isEmpty {
                    let displayTags = Array(tags.prefix(family == .systemMedium ? 2 : 4))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(displayTags, id: \.id) { tag in
                                Text("#\(tag.name ?? tag.slug)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(12)
        }
    }
    
    @ViewBuilder
    private func EmptyView() -> some View {
        Link(destination: URL(string: "solian://posts/shuffle")!) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "text.alignleft")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text(NSLocalizedString("noPostsAvailable", comment: "No posts available"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(NSLocalizedString("tapToRefresh", comment: "Tap to refresh"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
    }
    
    @ViewBuilder
    private func LoadingView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(NSLocalizedString("loadingPost", comment: "Loading post..."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Spacer()
        }
        .padding(12)
    }
    
    @ViewBuilder
    private func ErrorView(error: String) -> some View {
        Link(destination: URL(string: "solian://posts/shuffle")!) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(NSLocalizedString("error", comment: "Error"))
                        .font(.headline)
                    
                    Spacer()
                }
                
                Text(NSLocalizedString("openAppToRefresh", comment: "Open app to refresh"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(12)
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

struct PostShuffleWidgetRootView: View {
    var entry: PostShuffleProvider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                PostShuffleWidgetEntryView(entry: entry)
                
                if entry.post != nil {
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
                                x: geometry.size.width * 0.9,
                                y: 20
                            )
                    }
                    .allowsHitTesting(false)
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
            .padding(.vertical, 8)
        } else {
            PostShuffleWidgetEntryView(entry: entry)
                .padding()
                .background()
        }
    }
}

struct SolianPostShuffleWidget: Widget {
    let kind: String = "SolianPostShuffleWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PostShuffleProvider()) { entry in
            PostShuffleWidgetRootView(entry: entry)
        }
        .configurationDisplayName("Random Post")
        .description("Discover a random post from the network")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
        return [.systemMedium, .systemLarge]
    }
}

#Preview(as: .systemMedium) {
    SolianPostShuffleWidget()
} timeline: {
    PostShuffleEntry(
        date: .now,
        post: SnPost(
            id: "test-post-id",
            title: "Hello World!",
            description: "This is a test post description",
            content: "This is a content of a test post. It can be longer and show more text in the widget.",
            publisher: SnPostPublisher(
                id: "publisher-1",
                name: "Test Publisher",
                nick: "Testy",
                description: "A test publisher",
                picture: nil
            ),
            tags: [
                SnPostTag(id: "tag-1", slug: "test", name: "Test"),
                SnPostTag(id: "tag-2", slug: "example", name: "Example")
            ],
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            attachments: []
        ),
        error: nil,
        isLoading: false
    )
}

#Preview(as: .systemLarge) {
    SolianPostShuffleWidget()
} timeline: {
    PostShuffleEntry(
        date: .now,
        post: SnPost(
            id: "test-post-id",
            title: "Welcome to the Solar Network!",
            description: "This is a test post description that is a bit longer to demonstrate the widget layout with various content types",
            content: "This is content of a test post. It can be longer and show more text in the widget. The large widget should display more content and allow for better reading experience. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            publisher: SnPostPublisher(
                id: "publisher-1",
                name: "Test Publisher",
                nick: "Testy McTestface",
                description: "A test publisher",
                picture: nil
            ),
            tags: [
                SnPostTag(id: "tag-1", slug: "test", name: "Test"),
                SnPostTag(id: "tag-2", slug: "example", name: "Example"),
                SnPostTag(id: "tag-3", slug: "widget", name: "Widget"),
                SnPostTag(id: "tag-4", slug: "ios", name: "iOS")
            ],
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            attachments: [
                SnCloudFile(id: "file-1", url: nil, thumbnail: nil, mimeType: "image/jpeg"),
                SnCloudFile(id: "file-2", url: nil, thumbnail: nil, mimeType: "image/png")
            ]
        ),
        error: nil,
        isLoading: false
    )
}
