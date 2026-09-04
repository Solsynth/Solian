//
//  DiscoveryViews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import WatchKit

// MARK: - Discovery (Explore feed blocks)

/// A discovery block rendered as a section inside the activity list. Unlike
/// the old generic "N items to discover" row, it shows the resolved kind
/// (realms / publishers / people / articles / shuffled posts) and renders
/// each payload with the matching row so posts stay tappable and readable.
struct DiscoverySectionView: View {
    let section: DiscoverySection

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: Self.icon(for: section.kind))
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text(section.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
            }
            .padding(.bottom, 2)
            .accessibilityAddTraits(.isHeader)

            ForEach(section.items) { item in
                DiscoveryItemRow(item: item)
            }
        }
        .padding(.vertical, 6)
    }

    static func icon(for kind: String) -> String {
        switch kind {
        case "realm": return "globe"
        case "publisher": return "person.crop.square"
        case "account": return "person.2.fill"
        case "article": return "doc.plaintext"
        case "post": return "shuffle"
        default: return "safari"
        }
    }
}

/// A single suggested entity inside a discovery section.
struct DiscoveryItemRow: View {
    let item: DiscoveryItem
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                switch item.payload {
                case .post(let post):
                    NavigationLink(
                        destination: PostDetailView(post: post).environmentObject(appState)
                    ) {
                        DiscoveryPostSummary(post: post, item: item)
                    }
                case .realm(let realm):
                    NavigationLink(destination: RealmDetailView(realm: realm)) {
                        DiscoveryEntityRow(
                            name: realm.name,
                            subtitle: realm.description,
                            picture: realm.picture,
                            icon: "globe",
                            rank: item.rank
                        )
                    }
                case .publisher(let publisher):
                    NavigationLink(destination: PublisherDetailView(publisher: publisher)) {
                        DiscoveryEntityRow(
                            name: publisher.nick ?? publisher.name,
                            subtitle: publisher.bio,
                            picture: publisher.picture,
                            icon: "person.crop.square",
                            rank: item.rank
                        )
                    }
                case .account(let account):
                    NavigationLink(destination: AccountDetailView(account: account)) {
                        DiscoveryEntityRow(
                            name: account.nick,
                            subtitle: "@\(account.name)",
                            picture: account.profile?.picture,
                            icon: "person.circle.fill",
                            rank: item.rank
                        )
                    }
                case .article(let article):
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        DiscoveryEntityRow(
                            name: article.title,
                            subtitle: article.url,
                            picture: nil,
                            icon: "doc.plaintext",
                            rank: item.rank
                        )
                    }
                case .unknown:
                    Text("Unknown suggestion")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if item.payload.kind != "unknown" {
                DiscoveryActionsView(kind: item.payload.kind, referenceId: item.payload.referenceId)
                    .environmentObject(appState)
            }
        }
    }
}

/// Good / not-interested actions for a suggestion; mirrors the main app's
/// DiscoveryFeedbackWidget (positive feedback + uninterested).
struct DiscoveryActionsView: View {
    let kind: String
    let referenceId: String

    @EnvironmentObject var appState: AppState
    @State private var thanked = false
    @State private var busy = false

    private let networkService = NetworkService()

    var body: some View {
        HStack(spacing: 8) {
            Button {
                Task { await sendGood() }
            } label: {
                Label(thanked ? "Thanks" : "Good",
                      systemImage: thanked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(thanked ? .green : .secondary)
            .disabled(busy)
            .accessibilityLabel("Show more like this")

            Button {
                Task { await hide() }
            } label: {
                Label("Not for me", systemImage: "eye.slash")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .disabled(busy)
            .accessibilityLabel("Not interested, hide this")

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }

    private func sendGood() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        busy = true
        defer { busy = false }
        do {
            try await networkService.submitDiscoveryFeedback(
                kind: kind, referenceId: referenceId, good: true,
                token: token, serverUrl: serverUrl
            )
            WKInterfaceDevice.current().play(.success)
            thanked = true
        } catch {
            WKInterfaceDevice.current().play(.failure)
            print("[watchOS] discovery feedback failed: \(error)")
        }
    }

    private func hide() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        busy = true
        defer { busy = false }
        do {
            try await networkService.markDiscoveryUninterested(
                kind: kind, referenceId: referenceId,
                token: token, serverUrl: serverUrl
            )
            WKInterfaceDevice.current().play(.click)
        } catch {
            WKInterfaceDevice.current().play(.failure)
            print("[watchOS] discovery uninterested failed: \(error)")
        }
    }
}

/// "Top pick" / "Not recommended" chip for post-shuffle ranks.
struct RankBadge: View {
    let rank: String?

    var body: some View {
        if let rank = rank, rank == "highest" {
            Text("Top Pick")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.green.opacity(0.2)))
        } else if let rank = rank, rank == "lowest" {
            Text("Not Recommended")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.red.opacity(0.2)))
        }
    }
}

/// A two-line entity row with a remote avatar (realm / publisher / account /
/// article use this; posts get their own summary).
struct DiscoveryEntityRow: View {
    let name: String
    let subtitle: String?
    let picture: SnCloudFile?
    let icon: String
    var rank: String? = nil

    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if imageLoader.isLoading {
                    ProgressView()
                        .frame(width: 28, height: 28)
                } else if let image = imageLoader.image {
                    image
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.body)
                    .bold()
                    .lineLimit(2)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 0)
            RankBadge(rank: rank)
        }
        .padding(.vertical, 2)
        .task(id: picture?.id) {
            guard let serverUrl = appState.serverUrl,
                  let token = appState.token,
                  let pictureId = picture?.id,
                  let url = getAttachmentUrl(for: pictureId, serverUrl: serverUrl) else { return }
            await imageLoader.loadImage(from: url, token: token)
        }
    }
}

/// Post rows inside discovery render like feed posts but capped: title +
/// publisher + a compact content preview.
struct DiscoveryPostSummary: View {
    let post: SnPost
    let item: DiscoveryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(post.publisher?.nick ?? post.publisher?.name ?? "Unknown")
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                Spacer()
                RankBadge(rank: item.rank)
            }
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.body)
                    .bold()
                    .lineLimit(3)
            }
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundStyle(.secondary)
            }
            if !item.reasons.isEmpty {
                Text(item.reasons.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Detail destinations

struct RealmDetailView: View {
    let realm: SnRealm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(realm.name).font(.headline)
                if let description = realm.description {
                    Text(description).font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Realm")
    }
}

struct PublisherDetailView: View {
    let publisher: SnPublisher

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(publisher.nick ?? publisher.name).font(.headline)
                if let bio = publisher.bio, !bio.isEmpty {
                    Text(bio).font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Publisher")
    }
}

/// Account suggestion destination: profile card + bio, matching the main
/// app's account-discovery card semantics (name/avatar, bio) without pulling
/// in the full account screen.
struct AccountDetailView: View {
    let account: SnAccount

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(account.nick).font(.headline)
                Text("@\(account.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let bio = account.profile?.bio, !bio.isEmpty {
                    Text(bio).font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Account")
    }
}

struct ArticleDetailView: View {
    let article: SnWebArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title).font(.headline)
                Link(article.url, destination: URL(string: article.url)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .navigationTitle("Article")
    }
}
