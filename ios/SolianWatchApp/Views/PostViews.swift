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
                HStack(spacing: 4) {
                    Text(displayName)
                        .font(isCompact ? .caption : .subheadline)
                        .bold()
                        .lineLimit(1)
                    if let createdAt = post.createdAt {
                        Text(createdAt, style: .relative)
                            .font(.system(size: isCompact ? 9 : 10))
                            .foregroundStyle(.secondary)
                    }
                }
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
/// (reply/quote context) and in replies previews. Tapping it opens the
/// referenced post's full detail (fetched by id on appear). The model only
/// embeds a lightweight `SnPostReference` (id + title/content/publisher), so
/// the chip navigates using `reference.shell` and the detail refetches. Mirrors
/// the main app's `ReferencedPostWidget`.
struct ReferencedPostReferenceView: View {
    let reference: SnPostReference
    var isReply: Bool = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationLink(destination: PostDetailView(post: reference.shell)
            .environmentObject(appState)) {
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
        .buttonStyle(.plain)
    }

    private var authorName: String {
        reference.publisher?.nick ?? reference.publisher?.name ?? "a post"
    }
}


// MARK: - Post rows

struct PostRowView: View {
    let post: SnPost
    /// Called after this post is deleted here, so the owning list drops the row.
    var onDeleted: ((String) -> Void)? = nil
    /// Called after this post is edited here, so the owning list refetches it.
    var onUpdated: (() -> Void)? = nil

    @EnvironmentObject var appState: AppState
    @State private var isNavigating = false
    @State private var showActionMenu = false
    /// Set once the long press fires, so the release that follows doesn't also
    /// open the post — the row's tap and long press share one control.
    @State private var didLongPress = false

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
            Button {
                // A long press already claimed this interaction; don't also
                // open the post when the finger lifts.
                if didLongPress {
                    didLongPress = false
                    return
                }
                isNavigating = true
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                    didLongPress = true
                    WKInterfaceDevice.current().play(.click)
                    showActionMenu = true
                }
            )

            // The referenced (reply/forward) chip is a sibling link OUTSIDE the
            // row's own link, so tapping it opens the referenced post rather
            // than being swallowed by the row's navigation.
            if let reference = referencedPost {
                ReferencedPostReferenceView(reference: reference, isReply: post.repliedPostId != nil)
            }
        }
        .padding(.vertical)
        .onChange(of: showActionMenu) { _, isPresented in
            // The menu can close without the row's tap ever firing (a long
            // press that SwiftUI didn't follow with a release); clear the
            // guard so the next tap navigates.
            if !isPresented { didLongPress = false }
        }
        .navigationDestination(isPresented: $isNavigating) {
            PostDetailView(
                post: post,
                onDeleted: { onDeleted?(post.id) },
                onUpdated: { onUpdated?() }
            )
            .environmentObject(appState)
        }
        .postActionMenu(
            isPresented: $showActionMenu,
            post: post,
            onDeleted: { onDeleted?(post.id) },
            onUpdated: { onUpdated?() }
        )
    }

    /// The row's own content (header, title, body, attachments, engagement
    /// stats) — opened via the row's `NavigationLink`. The referenced
    /// reply/forward chip is kept OUT of here so it can be its own link.
    private var rowContent: some View {
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

            if !reactionPills.isEmpty || post.upvotes != nil || post.downvotes != nil || post.repliesCount != nil {
                HStack(spacing: 6) {
                    if !reactionPills.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(reactionPills, id: \.0) { symbol, count in
                                HStack(spacing: 2) {
                                    ReactionGlyphView(symbol: symbol, size: 18)
                                    Text("\(count)")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    (post.reactionsMade?[symbol] ?? false)
                                        ? Color.accentColor.opacity(0.5)
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
        .contentShape(Rectangle())
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

/// A choice from a post's long-press action menu.
enum PostMenuAction {
    case react
    case reply
    case forward
    case edit
    case delete
}

/// A watchOS-style action menu sheet shown on long-press of a post row or a
/// reply row (and from the post detail's toolbar). Offers what the old
/// left/right swipes carried (react, reply, forward) plus edit/delete for a
/// post the account may author — mirroring the main app's post menu and the
/// chat surfaces' `MessageActionMenuView`.
struct PostActionMenuView: View {
    let post: SnPost
    /// Reports the chosen action after the sheet dismisses itself; the host
    /// owns the follow-up so nothing is presented while this menu is still up.
    let onSelect: (PostMenuAction) -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isOwn = false

    private let networkService = NetworkService()

    var body: some View {
        NavigationView {
            List {
                Button { select(.react) } label: {
                    Label(L10n.postReact, systemImage: "face.smiling")
                }
                Button { select(.reply) } label: {
                    Label(L10n.postReply, systemImage: "arrowshape.turn.up.left")
                }
                Button { select(.forward) } label: {
                    Label(L10n.postForward, systemImage: "arrowshape.turn.up.right")
                }

                if isOwn {
                    Button { select(.edit) } label: {
                        Label(L10n.postEdit, systemImage: "pencil")
                    }
                    Button(role: .destructive) { select(.delete) } label: {
                        Label(L10n.postDelete, systemImage: "trash")
                    }
                }
            }
            .navigationTitle(L10n.postActions)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await resolveOwnership() }
    }

    private func select(_ action: PostMenuAction) {
        WKInterfaceDevice.current().play(.click)
        dismiss()
        onSelect(action)
    }

    /// Edit/delete are offered only to the post's author: the account itself
    /// (`publisher.account_id`) or an account that manages the post's
    /// publisher (`GET /sphere/publishers`). Mirrors the main app's `isAuthor`.
    private func resolveOwnership() async {
        guard let publisher = post.publisher else { return }
        if let accountId = publisher.accountId, accountId == appState.currentAccountId {
            isOwn = true
            return
        }
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        let managed = (try? await networkService.fetchManagedPublishers(token: token, serverUrl: serverUrl)) ?? []
        isOwn = managed.contains { $0.id == publisher.id }
    }
}

/// Attaches the post action menu and the follow-ups it triggers (reaction
/// picker, reply/forward composer, edit composer, delete confirmation).
/// Shared by the timeline row, the reply row, and the post detail so all three
/// behave identically; the host raises `isPresented` (long press or toolbar).
private struct PostActionMenuModifier: ViewModifier {
    @Binding var isPresented: Bool
    let post: SnPost
    /// Runs after the post was deleted here (drop the row / pop the detail).
    let onDeleted: () -> Void
    /// Runs after the post was edited here (refetch the list / detail).
    let onUpdated: () -> Void

    @EnvironmentObject private var appState: AppState
    @State private var pendingAction: PostMenuAction?
    @State private var followUp: PostMenuFollowUp?
    @State private var showDeleteConfirmation = false
    @State private var didEdit = false
    @State private var errorMessage: String?

    private let networkService = NetworkService()

    /// The sheet a menu choice opens once the menu has closed.
    private enum PostMenuFollowUp: Identifiable {
        case reactions
        case reply
        case forward
        case edit

        var id: String {
            switch self {
            case .reactions: return "reactions"
            case .reply: return "reply"
            case .forward: return "forward"
            case .edit: return "edit"
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: presentPendingAction) {
                PostActionMenuView(post: post) { pendingAction = $0 }
                    .environmentObject(appState)
            }
            .sheet(item: $followUp, onDismiss: {
                if didEdit {
                    didEdit = false
                    onUpdated()
                }
            }) { followUp in
                followUpView(for: followUp)
            }
            .alert(L10n.postDeleteConfirm, isPresented: $showDeleteConfirmation) {
                Button(L10n.postDelete, role: .destructive) {
                    Task { await deletePost() }
                }
                Button(L10n.composeCancel, role: .cancel) {}
            }
            .alert(L10n.postActionFailed, isPresented: .constant(errorMessage != nil)) {
                Button(L10n.postActionOk) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
    }

    /// Opens the choice's follow-up once the menu sheet has fully dismissed —
    /// presenting a sheet while another is still on screen gets dropped.
    private func presentPendingAction() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            switch action {
            case .react: followUp = .reactions
            case .reply: followUp = .reply
            case .forward: followUp = .forward
            case .edit: followUp = .edit
            case .delete: showDeleteConfirmation = true
            }
        }
    }

    @ViewBuilder
    private func followUpView(for followUp: PostMenuFollowUp) -> some View {
        switch followUp {
        case .reactions:
            ReactionSheetView(post: post)
                .environmentObject(appState)
        case .reply:
            ComposePostView(replyingTo: post)
                .environmentObject(appState)
        case .forward:
            ComposePostView(forwardingTo: post)
                .environmentObject(appState)
        case .edit:
            ComposePostView(editing: post, onSaved: { didEdit = true })
                .environmentObject(appState)
        }
    }

    private func deletePost() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        do {
            try await networkService.deletePost(postId: post.id, token: token, serverUrl: serverUrl)
            WKInterfaceDevice.current().play(.success)
            onDeleted()
        } catch {
            print("[watchOS] delete post failed: \(error)")
            WKInterfaceDevice.current().play(.failure)
            errorMessage = error.localizedDescription
        }
    }
}

extension View {
    /// Attaches the long-press post action menu and its follow-up sheets and
    /// alerts to a post surface (row, reply row, or detail).
    func postActionMenu(
        isPresented: Binding<Bool>,
        post: SnPost,
        onDeleted: @escaping () -> Void,
        onUpdated: @escaping () -> Void
    ) -> some View {
        modifier(PostActionMenuModifier(
            isPresented: isPresented,
            post: post,
            onDeleted: onDeleted,
            onUpdated: onUpdated
        ))
    }
}

/// Which anchored compose a post row presents.
enum ComposePostViewMode {
    case reply
    case forward
}

struct PostDetailView: View {
    let post: SnPost
    /// Called when this post is deleted from here, so the presenting list can
    /// drop its row (nil when there is no owning list).
    var onDeleted: (() -> Void)? = nil
    /// Called when this post is edited from here, so the presenting list can
    /// refetch it (nil when there is no owning list).
    var onUpdated: (() -> Void)? = nil

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showReactionSheet = false
    @State private var showComposeSheet = false
    @State private var showActionMenu = false
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
                categoriesSection
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
        .toolbar {
            // The detail keeps its action rail for the common interactions;
            // the ellipsis opens the same menu as a long press on a row, which
            // is where edit/delete live.
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    WKInterfaceDevice.current().play(.click)
                    showActionMenu = true
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel(L10n.postActions)
            }
        }
        .postActionMenu(
            isPresented: $showActionMenu,
            post: currentPost,
            onDeleted: {
                onDeleted?()
                dismiss()
            },
            onUpdated: {
                onUpdated?()
                Task { await loadFresh() }
            }
        )
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
                                ReactionGlyphView(symbol: symbol, size: 18)
                                Text("\(count)")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (currentPost.reactionsMade?[symbol] ?? false)
                                    ? Color.accentColor.opacity(0.5)
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
            FlowLayout(alignment: .leading, spacing: 6) {
                ForEach(tags) { tag in
                    // Tapping a tag opens a filtered list of posts that use it.
                    NavigationLink(
                        destination: PostQueryListView(
                            title: "#\(tag.displayName)",
                            tagSlugs: [tag.slug]
                        ).environmentObject(appState)
                    ) {
                        Text("#\(tag.displayName)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                            .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var categoriesSection: some View {
        if let categories = currentPost.categories, !categories.isEmpty {
            FlowLayout(alignment: .leading, spacing: 6) {
                ForEach(categories) { category in
                    // Tapping a category opens a filtered list of posts that
                    // belong to it.
                    NavigationLink(
                        destination: PostQueryListView(
                            title: category.displayName,
                            categorySlugs: [category.slug]
                        ).environmentObject(appState)
                    ) {
                        Text(category.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                            .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
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
                // Not a `Link` — watchOS has no browser, so a `Link` to an
                // HTTPS URL shows the failed "view on your iPhone" Handoff
                // flow. Copy the URL to the pasteboard instead.
                ExternalLinkView(urlString: embed.uri)
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
                    ReplyRowView(
                        post: reply,
                        onDeleted: { id in
                            replies.removeAll { $0.id == id }
                            repliesTotal = max(0, repliesTotal - 1)
                        },
                        onUpdated: { Task { await loadFresh() } }
                    )
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
/// and keeps reply interaction (react, reply-to-reply, edit, delete) available
/// on the watch through the same long-press action menu as timeline rows.
struct ReplyRowView: View {
    let post: SnPost
    /// Called after this reply is deleted here, so the detail can drop it.
    var onDeleted: ((String) -> Void)? = nil
    /// Called after this reply is edited here, so the detail can refetch.
    var onUpdated: (() -> Void)? = nil

    @EnvironmentObject var appState: AppState
    @State private var isNavigating = false
    @State private var showActionMenu = false
    /// Set once the long press fires, so the release that follows doesn't also
    /// open the reply — the row's tap and long press share one control.
    @State private var didLongPress = false

    private var reactionPills: [(String, Int)] {
        guard let reactions = post.reactionsCount else { return [] }
        return Array(reactions.sorted { $0.value > $1.value }.prefix(3))
    }

    var body: some View {
        Button {
            // A long press already claimed this interaction; don't also open
            // the reply when the finger lifts.
            if didLongPress {
                didLongPress = false
                return
            }
            isNavigating = true
        } label: {
            replyContent
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                didLongPress = true
                WKInterfaceDevice.current().play(.click)
                showActionMenu = true
            }
        )
        .onChange(of: showActionMenu) { _, isPresented in
            // The menu can close without the row's tap ever firing; clear the
            // guard so the next tap navigates.
            if !isPresented { didLongPress = false }
        }
        .navigationDestination(isPresented: $isNavigating) {
            PostDetailView(post: post)
                .environmentObject(appState)
        }
        .postActionMenu(
            isPresented: $showActionMenu,
            post: post,
            onDeleted: { onDeleted?(post.id) },
            onUpdated: { onUpdated?() }
        )
    }

    private var replyContent: some View {
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
                                HStack(spacing: 3) {
                                    ReactionGlyphView(symbol: symbol, size: 16)
                                    Text("\(count)")
                                        .font(.system(size: 9))
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(
                                    (post.reactionsMade?[symbol] ?? false)
                                        ? Color.accentColor.opacity(0.4)
                                        : Color.gray.opacity(0.15)
                                )
                                .clipShape(Capsule())
                            }
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
    }
}
