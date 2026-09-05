//
//  PostViews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import WatchKit

// MARK: - Author header (shared by rows, quote cards, and detail)

/// Compact publisher/actor avatar + name header, shared so every post surface
/// (timeline row, quoted card, detail header) renders identically. Embeds the
/// boosted-by line when the post was shared into this feed by someone else.
struct PostAuthorHeader: View {
    let post: SnPost
    var isCompact: Bool = false
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    private var displayName: String {
        if let actor = post.actor {
            return actor.displayName ?? actor.preferredUsername ?? actor.name ?? L10n.postUnknown
        }
        return post.publisher?.nick ?? post.publisher?.name ?? L10n.postUnknown
    }

    private var pictureId: String? {
        post.actor?.icon?.id ?? post.publisher?.picture?.id
    }

    var body: some View {
        HStack(spacing: 6) {
            if imageLoader.isLoading {
                ProgressView()
                    .frame(width: avatarSize, height: avatarSize)
            } else if let image = imageLoader.image {
                image
                    .resizable()
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
            } else if imageLoader.errorMessage != nil {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: avatarSize, height: avatarSize)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(displayName)
                    .font(isCompact ? .caption : .subheadline)
                    .bold()
                    .lineLimit(1)
                if post.boostedAt != nil, let booster = boostedByName {
                    Text(booster)
                        .font(.system(size: isCompact ? 9 : 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .task(id: pictureId) {
            guard let serverUrl = appState.serverUrl,
                  let pictureId = pictureId,
                  let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
                  let token = appState.token else { return }
            await imageLoader.loadImage(from: imageUrl, token: token)
        }
    }

    private var avatarSize: CGFloat { isCompact ? 20 : 32 }

    private var boostedByName: String? {
        guard let boostedBy = post.boostedBy else { return nil }
        let name = boostedBy.displayName ?? boostedBy.preferredUsername ?? boostedBy.name
        guard let name, !name.isEmpty else { return nil }
        return String(format: L10n.postBoostedBy, name)
    }
}

// MARK: - Referenced-post (reply / forward) context

/// A referenced-post chip: the reply/forward header (author, label) plus the
/// referenced post's own compact content. Renders in the current post's body
/// (reply/quote context) and in replies previews. The model only embeds a
/// lightweight `SnPostReference` (id + title/content/publisher) rather than a
/// full post, so the chip is a static preview — no detail navigation. Mirrors
/// the main app's `ReferencedPostWidget`.
struct ReferencedPostReferenceView: View {
    let reference: SnPostReference
    var isReply: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: isReply ? "arrowshape.turn.up.left" : "arrowshape.turn.up.right")
                    .font(.system(size: 10))
                Text(isReply ? "Replied to \(authorName)" : "Forwarded from \(authorName)")
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.secondary)

            if let title = reference.title, !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .bold()
                    .lineLimit(2)
            }
            if let content = reference.content, !content.isEmpty {
                MarkdownText(
                    content: content,
                    lineLimit: 3
                )
                .font(.system(size: 11))
                .foregroundStyle(.primary.opacity(0.9))
            }
            if let publisher = reference.publisher {
                Text("@\(publisher.nick ?? publisher.name)")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var authorName: String {
        reference.publisher?.nick ?? reference.publisher?.name ?? "a post"
    }
}


// MARK: - Post rows

struct PostRowView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @State private var showReactionSheet = false
    @State private var showComposeSheet = false
    @State private var composeMode: ComposePostViewMode = .reply

    private var reactionPills: [(String, Int)] {
        guard let reactions = post.reactionsCount else { return [] }
        return Array(reactions.sorted { $0.value > $1.value }.prefix(3))
    }

    private var engagementViews: some View {
        HStack(spacing: 12) {
            if let upvotes = post.upvotes, upvotes > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                    Text("\(upvotes)")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            if let downvotes = post.downvotes, downvotes > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                    Text("\(downvotes)")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            if let replies = post.repliesCount, replies > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "bubble.right.fill")
                    Text("\(replies)")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PostAuthorHeader(post: post, isCompact: true)

            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
            }

            if let content = post.content, !content.isEmpty {
                MarkdownText(
                    content: content,
                    lineLimit: 4,
                    isHTML: (post.contentType ?? 0) == 1
                )
                .font(.caption)
                .foregroundStyle(.primary)
            }

            if let attachments = post.attachments, !attachments.isEmpty {
                AttachmentView(attachment: attachments[0], isCompact: true)
                    .frame(maxWidth: .infinity)
                if attachments.count > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                        Text("+\(attachments.count - 1)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            if let reference = referencedPost {
                ReferencedPostReferenceView(reference: reference, isReply: post.repliedPostId != nil)
            }

            if !reactionPills.isEmpty || post.upvotes != nil || post.downvotes != nil || post.repliesCount != nil {
                HStack(spacing: 6) {
                    if !reactionPills.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(reactionPills, id: \.0) { symbol, count in
                                HStack(spacing: 2) {
                                    Text(getReactionIcon(symbol))
                                    Text("\(count)")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    (post.reactionsMade?[symbol] ?? false)
                                        ? Color.accentColor.opacity(0.3)
                                        : Color.gray.opacity(0.2)
                                )
                                .clipShape(Capsule())
                            }
                        }
                    }
                    engagementViews
                    Spacer()
                    if let pinMode = post.pinMode, pinMode > 0 {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical)
        .contentShape(Rectangle())
        .sheet(isPresented: $showReactionSheet) {
            ReactionSheetView(post: post)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showComposeSheet) {
            switch composeMode {
            case .reply:
                ComposePostView(replyingTo: post)
                    .environmentObject(appState)
            case .forward:
                ComposePostView(forwardingTo: post)
                    .environmentObject(appState)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                showReactionSheet = true
            } label: {
                Image(systemName: "face.smiling")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                composeMode = .forward
                showComposeSheet = true
            } label: {
                Image(systemName: "arrowshape.turn.up.right")
            }
            .tint(.blue)
            Button {
                composeMode = .reply
                showComposeSheet = true
            } label: {
                Image(systemName: "bubble.right")
            }
            .tint(.green)
        }
    }

    private var referencedPost: SnPostReference? {
        if let replied = post.repliedPost {
            return replied
        }
        if let forwarded = post.forwardedPost {
            return forwarded
        }
        // Reply/quote rows keep their reference content inline; a row that
        // only carries the reference id still shows the chip once the fresh
        // detail view loads it. Rows without a loaded reference (e.g. summary
        // rows that predate reference embedding) surface nothing here.
        return nil
    }

}

/// Which anchored compose a post row presents.
enum ComposePostViewMode {
    case reply
    case forward
}

struct PostDetailView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @State private var showReactionSheet = false
    @State private var showComposeSheet = false
    @State private var composeMode: ComposePostViewMode = .reply
    @State private var expandedReactions = false
    @State private var isEngaging = false
    /// Fresh server state; mirrors the main app's detail refresh after an
    /// engagement (boost/bookmark/reaction) round-trips.
    @State private var refreshedPost: SnPost?
    /// Server-loaded replies (direct replies to this post).
    @State private var replies: [SnPost] = []
    @State private var repliesTotal = 0
    @State private var isLoadingReplies = false
    @State private var isLoadingMoreReplies = false

    private let networkService = NetworkService()
    private let repliesPageSize = 10

    private var currentPost: SnPost { refreshedPost ?? post }

    private var reactionPills: [(String, Int)] {
        guard let reactions = currentPost.reactionsCount else { return [] }
        let sorted = reactions.sorted { $0.value > $1.value }
        return expandedReactions ? Array(sorted.prefix(10)) : Array(sorted.prefix(5))
    }

    private var repliesPreviewCount: Int {
        max(0, (currentPost.repliesCount ?? repliesTotal) - replies.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                content
                if !reactionPills.isEmpty { reactionStrip }
                attachmentsSection
                tagsSection
                embedSection
                statsRow
                actionRail
                referencedPosts
                repliesSection
            }
            .padding()
        }
        .navigationTitle(L10n.postTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReactionSheet) {
            ReactionSheetView(post: currentPost)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showComposeSheet) {
            switch composeMode {
            case .reply:
                ComposePostView(replyingTo: currentPost)
                    .environmentObject(appState)
            case .forward:
                ComposePostView(forwardingTo: currentPost)
                    .environmentObject(appState)
            }
        }
        .task(id: post.id) { await loadFresh() }
        .refreshable { await loadFresh() }
        .onChange(of: showComposeSheet) { _, isPresented in
            // A reply/forward composed from this detail may change counts or
            // add a reply — refresh once the sheet goes away.
            if !isPresented {
                Task { await loadFresh() }
            }
        }
    }

    // MARK: Detail sections

    private var header: some View {
        PostAuthorHeader(post: currentPost)
    }

    @ViewBuilder
    private var content: some View {
        if let title = currentPost.title, !title.isEmpty {
            Text(title)
                .font(.headline)
                .bold()
        }
        if let description = currentPost.description, !description.isEmpty {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        if let content = currentPost.content, !content.isEmpty {
            MarkdownText(
                content: content,
                isHTML: (currentPost.contentType ?? 0) == 1
            )
            .font(.body)
        }
    }

    private var reactionStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(reactionPills, id: \.0) { symbol, count in
                        Button {
                            Task {
                                await toggleReaction(symbol: symbol)
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Text(getReactionIcon(symbol))
                                Text("\(count)")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (currentPost.reactionsMade?[symbol] ?? false)
                                    ? Color.accentColor.opacity(0.3)
                                    : Color.gray.opacity(0.15)
                            )
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    if (currentPost.reactionsCount?.count ?? 0) > 5 {
                        Button {
                            expandedReactions.toggle()
                        } label: {
                            Text(expandedReactions ? L10n.postLess : "+\((currentPost.reactionsCount?.count ?? 0) - 5)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        if let attachments = currentPost.attachments, !attachments.isEmpty {
            Text(L10n.postAttachments)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(attachments) { attachment in
                AttachmentView(attachment: attachment)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if let tags = currentPost.tags, !tags.isEmpty {
            FlowLayout(alignment: .leading, spacing: 4) {
                ForEach(tags) { tag in
                    Text("#\(tag.name ?? tag.slug)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                        .cornerRadius(5)
                }
            }
        }
    }

    @ViewBuilder
    private var embedSection: some View {
        if let embed = currentPost.embedView {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.postLink)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Link(embed.uri, destination: URL(string: embed.uri)!)
                    .font(.caption)
                    .lineLimit(2)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            if let upvotes = currentPost.upvotes, upvotes > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                    Text("\(upvotes)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            if let downvotes = currentPost.downvotes, downvotes > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                    Text("\(downvotes)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            if let replies = currentPost.repliesCount, replies > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right.fill")
                    Text("\(replies)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            if let views = currentPost.viewsUnique, views > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                    Text("\(views)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if let pinMode = currentPost.pinMode, pinMode > 0 {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding(.top, 8)
    }

    // MARK: Engagement actions

    private var actionRail: some View {
        HStack(spacing: 18) {
            Button {
                composeMode = .reply
                showComposeSheet = true
            } label: {
                Image(systemName: "arrowshape.turn.up.left")
                    .font(.body)
                    .foregroundStyle(Color.green)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.postReply)

            Button {
                composeMode = .forward
                showComposeSheet = true
            } label: {
                Image(systemName: "arrowshape.turn.up.right")
                    .font(.body)
                    .foregroundStyle(Color.blue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.postForward)

            Spacer(minLength: 0)

            Button {
                Task { await boost() }
            } label: {
                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.postBoost)
            .disabled(isEngaging)

            Button {
                Task { await toggleBookmark() }
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.body)
                    .foregroundStyle(isBookmarked ? Color.orange : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isBookmarked ? L10n.postRemoveBookmark : L10n.postBookmark)
            .disabled(isEngaging)
        }
        .padding(.top, 6)
    }

    private var isBookmarked: Bool {
        refreshedPost?.isBookmarked ?? post.isBookmarked ?? false
    }

    private func boost() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isEngaging = true
        defer { isEngaging = false }
        do {
            try await networkService.boostPost(postId: currentPost.id, token: token, serverUrl: serverUrl)
            WKInterfaceDevice.current().play(.success)
            await loadFresh()
        } catch {
            print("[watchOS] boost failed: \(error)")
            WKInterfaceDevice.current().play(.failure)
        }
    }

    private func toggleBookmark() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isEngaging = true
        defer { isEngaging = false }
        do {
            if isBookmarked {
                try await networkService.unbookmarkPost(postId: currentPost.id, token: token, serverUrl: serverUrl)
            } else {
                try await networkService.bookmarkPost(postId: currentPost.id, token: token, serverUrl: serverUrl)
            }
            WKInterfaceDevice.current().play(.success)
            await loadFresh()
        } catch {
            print("[watchOS] bookmark toggle failed: \(error)")
            WKInterfaceDevice.current().play(.failure)
        }
    }

    /// The referenced post (reply target or quoted/forwarded post), rendered
    /// as a chip under the content when present.
    @ViewBuilder
    private var referencedPosts: some View {
        if let reference = currentPost.repliedPost {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.postInReplyTo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ReferencedPostReferenceView(reference: reference, isReply: true)
            }
        } else if let reference = currentPost.forwardedPost {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.postForwarded)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ReferencedPostReferenceView(reference: reference, isReply: false)
            }
        }
    }

    // MARK: Replies preview

    @ViewBuilder
    private var repliesSection: some View {
        if !replies.isEmpty || isLoadingReplies || (currentPost.repliesCount ?? 0) > 0 {
            Divider()
                .padding(.vertical, 4)

            HStack(spacing: 6) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(L10n.postReplies)
                    .font(.subheadline)
                    .bold()
                Spacer()
                if let repliesCount = currentPost.repliesCount, repliesCount > 0 {
                    Text("\(repliesCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if isLoadingReplies && replies.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else if replies.isEmpty {
                if let repliesCount = currentPost.repliesCount, repliesCount > 0 {
                    // Server reported replies but the window is empty
                    // (usually a truncated row); keep the section honest.
                    Text(L10n.postRepliesLoadFromApp)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(replies) { reply in
                    ReplyRowView(post: reply)
                        .environmentObject(appState)
                }
                if repliesTotal > replies.count || repliesPreviewCount > 0 {
                    Button(isLoadingMoreReplies ? L10n.postLoading : L10n.postLoadMoreReplies) {
                        Task { await loadMoreReplies() }
                    }
                    .disabled(isLoadingMoreReplies)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: Loading

    /// Refresh the post and its reply preview from the server. Called on first
    /// appearance and pull-to-refresh; reconciles optimistic state after any
    /// engagement round-trip.
    private func loadFresh() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        async let freshTask = fetchFresh(token: token, serverUrl: serverUrl)
        async let repliesTask = fetchReplies(token: token, serverUrl: serverUrl)
        let (fresh, repliesResult) = await (freshTask, repliesTask)
        if let fresh { refreshedPost = fresh }
        if let repliesResult {
            replies = repliesResult.posts
            repliesTotal = repliesResult.total
        }
    }

    private func fetchFresh(token: String, serverUrl: String) async -> SnPost? {
        do {
            return try await networkService.fetchPost(postId: post.id, token: token, serverUrl: serverUrl)
        } catch {
            print("[watchOS] fetch post detail failed: \(error)")
            return nil
        }
    }

    private func fetchReplies(token: String, serverUrl: String) async -> PostListResponse? {
        guard (currentPost.repliesCount ?? 0) > 0 || replies.isEmpty else { return nil }
        isLoadingReplies = true
        defer { isLoadingReplies = false }
        do {
            return try await networkService.fetchPostReplies(
                postId: post.id,
                offset: 0,
                take: repliesPageSize,
                token: token,
                serverUrl: serverUrl
            )
        } catch {
            print("[watchOS] fetch post replies failed: \(error)")
            return nil
        }
    }

    private func loadMoreReplies() async {
        guard !isLoadingMoreReplies, repliesTotal > replies.count else { return }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoadingMoreReplies = true
        defer { isLoadingMoreReplies = false }
        do {
            let result = try await networkService.fetchPostReplies(
                postId: post.id,
                offset: replies.count,
                take: repliesPageSize,
                token: token,
                serverUrl: serverUrl
            )
            replies.append(contentsOf: result.posts)
            repliesTotal = result.total
        } catch {
            print("[watchOS] load more replies failed: \(error)")
        }
    }


    // MARK: Actions

    private func toggleReaction(symbol: String) async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        do {
            _ = try await networkService.reactToPost(
                postId: currentPost.id,
                symbol: symbol,
                attitude: getReactionAttitude(symbol),
                token: token,
                serverUrl: serverUrl
            )
            await loadFresh()
        } catch {
            print("Reaction error: \(error)")
        }
    }
}

/// A single reply row in the post-detail replies preview: author, content,
/// reaction pills, and engagement counts — mirrors the main app's reply card
/// and keeps reply interaction (react, reply-to-reply) available on the watch.
struct ReplyRowView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @State private var showReactionSheet = false
    @State private var showReplySheet = false

    private var reactionPills: [(String, Int)] {
        guard let reactions = post.reactionsCount else { return [] }
        return Array(reactions.sorted { $0.value > $1.value }.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PostAuthorHeader(post: post, isCompact: true)

            if let content = post.content, !content.isEmpty {
                MarkdownText(
                    content: content,
                    lineLimit: 6,
                    isHTML: (post.contentType ?? 0) == 1
                )
                .font(.caption)
                .foregroundStyle(.primary)
            }

            if !reactionPills.isEmpty || (post.upvotes ?? 0) > 0 || (post.repliesCount ?? 0) > 0 {
                HStack(spacing: 8) {
                    if !reactionPills.isEmpty {
                        HStack(spacing: 3) {
                            ForEach(reactionPills, id: \.0) { symbol, count in
                                Text(getReactionIcon(symbol))
                                    .font(.caption2)
                                Text("\(count)")
                                    .font(.system(size: 9))
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                        }
                    }
                    if let upvotes = post.upvotes, upvotes > 0 {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9))
                        Text("\(upvotes)")
                            .font(.system(size: 9))
                    }
                    if let replies = post.repliesCount, replies > 0 {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 9))
                        Text("\(replies)")
                            .font(.system(size: 9))
                    }
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .sheet(isPresented: $showReactionSheet) {
            ReactionSheetView(post: post)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showReplySheet) {
            ComposePostView(replyingTo: post)
                .environmentObject(appState)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                showReactionSheet = true
            } label: {
                Image(systemName: "face.smiling")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                showReplySheet = true
            } label: {
                Image(systemName: "bubble.right")
            }
            .tint(.green)
        }
    }
}
