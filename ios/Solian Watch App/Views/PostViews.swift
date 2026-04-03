//
//  PostViews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

struct PostRowView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()
    @State private var showReactionSheet = false
    @State private var showComposeSheet = false

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
            HStack(spacing: 6) {
                if imageLoader.isLoading {
                    ProgressView()
                        .frame(width: 20, height: 20)
                } else if let image = imageLoader.image {
                    image
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                } else if imageLoader.errorMessage != nil {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                Text(post.publisher?.nick ?? post.publisher?.name ?? "Unknown")
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                
                Spacer()
                
                if post.boostedAt != nil {
                    Image(systemName: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .task(id: post.publisher?.picture?.id) {
                if let serverUrl = appState.serverUrl, let pictureId = post.publisher?.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                    await imageLoader.loadImage(from: imageUrl, token: token)
                }
            }

            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
            }

            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.caption)
                    .lineLimit(3)
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
                    if !reactionPills.isEmpty {
                        engagementViews
                    } else {
                        engagementViews
                    }
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
                showComposeSheet = true
            } label: {
                Image(systemName: "bubble.right")
            }
            .tint(.green)
        }
    }
}

struct PostDetailView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @StateObject private var publisherImageLoader = ImageLoader()
    @State private var showReactionSheet = false
    @State private var expandedReactions = false

    private var reactionPills: [(String, Int)] {
        guard let reactions = post.reactionsCount else { return [] }
        let sorted = reactions.sorted { $0.value > $1.value }
        return expandedReactions ? Array(sorted.prefix(10)) : Array(sorted.prefix(5))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    if publisherImageLoader.isLoading {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    } else if let image = publisherImageLoader.image {
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } else if publisherImageLoader.errorMessage != nil {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.publisher?.nick ?? post.publisher?.name ?? "Unknown")
                            .font(.subheadline)
                            .bold()
                        Text("@\(post.publisher?.nick ?? "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .task(id: post.publisher?.picture?.id) {
                    if let serverUrl = appState.serverUrl, let pictureId = post.publisher?.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                        await publisherImageLoader.loadImage(from: imageUrl, token: token)
                    }
                }

                if let title = post.title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                        .bold()
                }

                if let content = post.content, !content.isEmpty {
                    Text(content)
                        .font(.body)
                        .lineLimit(nil)
                }

                if !reactionPills.isEmpty {
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
                                            (post.reactionsMade?[symbol] ?? false)
                                                ? Color.accentColor.opacity(0.3)
                                                : Color.gray.opacity(0.15)
                                        )
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                                if (post.reactionsCount?.count ?? 0) > 5 {
                                    Button {
                                        expandedReactions.toggle()
                                    } label: {
                                        Text(expandedReactions ? "Less" : "+\((post.reactionsCount?.count ?? 0) - 5)")
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

                if let attachments = post.attachments, !attachments.isEmpty {
                    Text("Attachments")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ForEach(attachments) { attachment in
                        AttachmentView(attachment: attachment)
                            .frame(maxWidth: .infinity)
                    }
                }

                if let tags = post.tags, !tags.isEmpty {
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

                if let embed = post.embedView {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Link")
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

                HStack(spacing: 16) {
                    if let upvotes = post.upvotes, upvotes > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                            Text("\(upvotes)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    if let downvotes = post.downvotes, downvotes > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                            Text("\(downvotes)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    if let replies = post.repliesCount, replies > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right.fill")
                            Text("\(replies)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    if let views = post.viewsUnique, views > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.fill")
                            Text("\(views)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let pinMode = post.pinMode, pinMode > 0 {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                    }
                    if post.boostedAt != nil {
                        HStack(spacing: 2) {
                            Image(systemName: "repeat")
                            Text("Boosted")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Post")
        .sheet(isPresented: $showReactionSheet) {
            ReactionSheetView(post: post)
                .environmentObject(appState)
        }
    }

    private func toggleReaction(symbol: String) async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        
        let networkService = NetworkService()
        
        do {
            _ = try await networkService.reactToPost(
                postId: post.id,
                symbol: symbol,
                attitude: getReactionAttitude(symbol),
                token: token,
                serverUrl: serverUrl
            )
        } catch {
            print("Reaction error: \(error)")
        }
    }
}
