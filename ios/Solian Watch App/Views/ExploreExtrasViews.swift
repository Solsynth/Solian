//
//  ExploreExtrasViews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  Second-tier Explore screens that mirror the main app's explore surface:
//  publisher follow/unfollow + publisher feeds, category/tag browse with
//  follow toggles and feeds, and server-filtered / shuffled post lists.
//

import SwiftUI
import WatchKit

// MARK: - Publisher subscriptions (follow/unfollow)

struct PublisherManagementView: View {
    @EnvironmentObject var appState: AppState
    @State private var subscriptions: [SnPublisherSubscriptionRow] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let networkService = NetworkService()

    var body: some View {
        Group {
            if isLoading && subscriptions.isEmpty {
                ProgressView("Loading publishers…")
            } else if let errorMessage = errorMessage, subscriptions.isEmpty {
                VStack(spacing: 6) {
                    Text("Couldn't load publishers").font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if subscriptions.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "star")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Not following any publishers yet")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(subscriptions, id: \.subscription.publisherId) { row in
                        let publisher = row.subscription.publisher
                        NavigationLink(
                            destination: PostQueryListView(
                                title: publisher.nick ?? publisher.name,
                                publisherNames: [publisher.name]
                            )
                            .environmentObject(appState)
                        ) {
                            HStack(spacing: 8) {
                                PublisherAvatarView(publisher: publisher, size: 30)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(publisher.nick ?? publisher.name)
                                        .font(.caption)
                                        .bold()
                                        .lineLimit(1)
                                    if let latest = row.latestContentAt {
                                        Text(latest, style: .relative)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer(minLength: 0)
                                if row.hasNewContent {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                unfollow(row)
                            } label: {
                                Label("Unfollow", systemImage: "person.crop.square.badge.minus")
                            }
                        }
                    }
                }
                .listStyle(.carousel)
            }
        }
        .navigationTitle("Publishers")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            subscriptions = try await networkService.fetchPublisherSubscriptions(
                token: token, serverUrl: serverUrl
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func unfollow(_ row: SnPublisherSubscriptionRow) {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        let name = row.subscription.publisher.name
        Task {
            do {
                try await networkService.unsubscribePublisher(
                    name: name, token: token, serverUrl: serverUrl
                )
                WKInterfaceDevice.current().play(.success)
                await MainActor.run {
                    subscriptions.removeAll { $0.subscription.publisher.name == name }
                }
            } catch {
                WKInterfaceDevice.current().play(.failure)
                print("[watchOS] unfollow failed: \(error)")
            }
        }
    }
}

/// Remote publisher avatar (Kingfisher + bearer token).
struct PublisherAvatarView: View {
    let publisher: SnPublisher
    var size: CGFloat = 30

    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if imageLoader.isLoading {
                ProgressView()
                    .frame(width: size, height: size)
            } else if let image = imageLoader.image {
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.square")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .task(id: publisher.picture?.id) {
            guard let serverUrl = appState.serverUrl,
                  let token = appState.token,
                  let pictureId = publisher.picture?.id,
                  let url = getAttachmentUrl(for: pictureId, serverUrl: serverUrl) else { return }
            await imageLoader.loadImage(from: url, token: token)
        }
    }
}

// MARK: - Category / tag browse with follow toggles

/// One followable category or tag row with its current subscription state.
struct FollowableRow: Identifiable {
    let id: String
    let slug: String
    let name: String
    let usage: Int?
    let isTag: Bool
    var isSubscribed: Bool
}

struct CategoriesTagsView: View {
    @EnvironmentObject var appState: AppState
    @State private var categories: [FollowableRow] = []
    @State private var tags: [FollowableRow] = []
    @State private var subscribedCategories = Set<String>()
    @State private var subscribedTags = Set<String>()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var picker: PickerKind = .categories
    @State private var toggling = Set<String>()

    private let networkService = NetworkService()

    private enum PickerKind: String, CaseIterable, Identifiable {
        case categories = "Categories"
        case tags = "Tags"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            // watchOS has no segmented picker; a capsule toggle is the
            // platform-native equivalent.
            HStack(spacing: 6) {
                ForEach(PickerKind.allCases) { kind in
                    Button {
                        picker = kind
                    } label: {
                        Text(kind.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(
                                    picker == kind
                                        ? Color.accentColor.opacity(0.3)
                                        : Color.gray.opacity(0.15)
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)

            List {
                if isLoading && rows.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if let errorMessage = errorMessage, rows.isEmpty {
                    VStack(spacing: 6) {
                        Text("Couldn't load categories").font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if rows.isEmpty {
                    Text("Nothing here yet")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(rows) { row in
                        FollowableRowView(
                            row: row,
                            isToggling: toggling.contains(row.slug),
                            onToggle: { toggle(row) }
                        )
                    }
                }
            }
        }
        .navigationTitle("Categories & Tags")
        .task { await loadAll() }
        .refreshable { await loadAll() }
    }

    private var rows: [FollowableRow] {
        switch picker {
        case .categories: return categories
        case .tags: return tags
        }
    }

    private func loadAll() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let catsTask = networkService.fetchCategories(
                token: token, serverUrl: serverUrl, take: 100
            )
            async let tagsTask = networkService.fetchTags(
                token: token, serverUrl: serverUrl, take: 100
            )
            async let subsTask = networkService.fetchCategorySubscriptions(
                token: token, serverUrl: serverUrl
            )
            let (fetchedCats, fetchedTags, subs) = try await (catsTask, tagsTask, subsTask)

            var catSet = Set<String>()
            var tagSet = Set<String>()
            for sub in subs {
                if let category = sub.category { catSet.insert(category.slug) }
                if let tag = sub.tag { tagSet.insert(tag.slug) }
            }
            subscribedCategories = catSet
            subscribedTags = tagSet
            categories = fetchedCats.map {
                FollowableRow(
                    id: $0.id, slug: $0.slug, name: $0.displayName,
                    usage: $0.usage, isTag: false, isSubscribed: catSet.contains($0.slug)
                )
            }
            tags = fetchedTags.map {
                FollowableRow(
                    id: $0.id, slug: $0.slug, name: $0.displayName,
                    usage: nil, isTag: true, isSubscribed: tagSet.contains($0.slug)
                )
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggle(_ row: FollowableRow) {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        let slug = row.slug
        let subscribing = !row.isSubscribed
        toggling.insert(slug)
        Task {
            do {
                if subscribing {
                    try await networkService.subscribeCategory(
                        slug: slug, token: token, serverUrl: serverUrl
                    )
                } else {
                    try await networkService.unsubscribeCategory(
                        slug: slug, token: token, serverUrl: serverUrl
                    )
                }
                await MainActor.run {
                    if row.isTag {
                        if subscribing { subscribedTags.insert(slug) } else { subscribedTags.remove(slug) }
                        if let idx = tags.firstIndex(where: { $0.slug == slug }) {
                            tags[idx].isSubscribed = subscribing
                        }
                    } else {
                        if subscribing { subscribedCategories.insert(slug) } else { subscribedCategories.remove(slug) }
                        if let idx = categories.firstIndex(where: { $0.slug == slug }) {
                            categories[idx].isSubscribed = subscribing
                        }
                    }
                    WKInterfaceDevice.current().play(.success)
                }
            } catch {
                WKInterfaceDevice.current().play(.failure)
                print("[watchOS] toggle subscription failed: \(error)")
            }
            toggling.remove(slug)
        }
    }
}

struct FollowableRowView: View {
    @EnvironmentObject var appState: AppState
    let row: FollowableRow
    let isToggling: Bool
    let onToggle: () -> Void

    var body: some View {
        NavigationLink(
            destination: PostQueryListView(
                title: row.name,
                categorySlugs: row.isTag ? [] : [row.slug],
                tagSlugs: row.isTag ? [row.slug] : []
            )
            .environmentObject(appState)
        ) {
            HStack(spacing: 8) {
                Image(systemName: row.isTag
                      ? (row.isSubscribed ? "tag.fill" : "tag")
                      : (row.isSubscribed ? "square.grid.2x2.fill" : "square.grid.2x2"))
                    .font(.body)
                    .foregroundStyle(row.isSubscribed ? Color.accentColor : Color.secondary)
                Text(row.name)
                    .font(.body)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if let usage = row.usage, usage > 0 {
                    Text("\(usage)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: row.isSubscribed ? "checkmark.circle.fill" : "plus.circle")
                    .font(.body)
                    .foregroundStyle(row.isSubscribed ? Color.green : Color.secondary)
            }
            .padding(.vertical, 4)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onToggle()
            } label: {
                Label(row.isSubscribed ? "Unfollow" : "Follow",
                      systemImage: row.isSubscribed ? "xmark.circle" : "plus.circle")
            }
            .tint(row.isSubscribed ? .red : .accentColor)
        }
        .accessibilityLabel(row.isTag ? "Tag \(row.name)" : "Category \(row.name)")
        .accessibilityValue(row.isSubscribed ? "Following" : "Not following")
    }
}

// MARK: - Filtered post list

/// Fetch-only list of posts for a server-filtered query: publisher feed,
/// category feed, tag feed, combined subscription feed, or shuffle. Reuses
/// PostRowView rows, re-fetches when the query changes, and paginates with
/// a "Load More" row.
struct PostQueryListView: View {
    let title: String
    var publisherNames: [String] = []
    var categorySlugs: [String] = []
    var tagSlugs: [String] = []
    var shuffle = false

    @EnvironmentObject var appState: AppState
    @State private var posts: [SnPost] = []
    @State private var total = 0
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var hasLoadedOnce = false

    private let networkService = NetworkService()
    private let pageSize = 20

    var body: some View {
        Group {
            if isLoading && posts.isEmpty {
                ProgressView("Loading…")
            } else if let errorMessage = errorMessage, posts.isEmpty {
                VStack(spacing: 6) {
                    Text("Couldn't load posts").font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if posts.isEmpty {
                Text("No posts yet")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                List {
                    ForEach(posts) { post in
                        NavigationLink(
                            destination: PostDetailView(post: post).environmentObject(appState)
                        ) {
                            PostRowView(post: post)
                        }
                    }
                    if hasMore {
                        Button(isLoadingMore ? "Loading…" : "Load More") {
                            Task { await loadMore() }
                        }
                        .disabled(isLoadingMore)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: queryKey) {
            if !hasLoadedOnce { await load() }
        }
        .refreshable { await load() }
    }

    private var queryKey: String {
        [publisherNames.joined(separator: ","),
         categorySlugs.joined(separator: ","),
         tagSlugs.joined(separator: ","),
         shuffle ? "s" : ""].joined(separator: "|")
    }

    private var hasMore: Bool {
        posts.count < total
    }

    private func load() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await networkService.fetchPosts(
                take: pageSize,
                offset: 0,
                publishers: publisherNames,
                pubName: publisherNames.count == 1 ? publisherNames[0] : nil,
                categories: categorySlugs,
                tags: tagSlugs,
                shuffle: shuffle,
                token: token,
                serverUrl: serverUrl
            )
            posts = response.posts
            total = response.total
            hasLoadedOnce = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let response = try await networkService.fetchPosts(
                take: pageSize,
                offset: posts.count,
                publishers: publisherNames,
                pubName: publisherNames.count == 1 ? publisherNames[0] : nil,
                categories: categorySlugs,
                tags: tagSlugs,
                shuffle: shuffle,
                token: token,
                serverUrl: serverUrl
            )
            posts.append(contentsOf: response.posts)
            total = response.total
        } catch {
            print("[watchOS] load more posts failed: \(error)")
        }
    }
}
