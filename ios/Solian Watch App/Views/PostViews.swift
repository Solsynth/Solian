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
    @StateObject private var imageLoader = ImageLoader() // Instantiate ImageLoader

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if imageLoader.isLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else if let image = imageLoader.image {
                    image
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } else if let errorMessage = imageLoader.errorMessage {
                    Text("Failed: \(errorMessage)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                } else {
                    // Placeholder if no image and not loading
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                Text(post.publisher?.nick ?? post.publisher?.name ?? "Unknown")
                    .font(.subheadline)
                    .bold()
            }
            .task(id: post.publisher?.picture?.id) {
                if let serverUrl = appState.serverUrl, let pictureId = post.publisher?.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                    await imageLoader.loadImage(from: imageUrl, token: token)
                }
            }
            
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
            }
            
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.body)
            }
            
            if let attachments = post.attachments, !attachments.isEmpty {
                AttachmentView(attachment: attachments[0])
                if attachments.count > 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "paperclip.circle.fill")
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.gray)
                        Text("\(attachments.count - 1)+ attachments")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }.padding(.vertical)
    }
}

struct PostDetailView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @StateObject private var publisherImageLoader = ImageLoader() // Instantiate ImageLoader for publisher avatar

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if publisherImageLoader.isLoading {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    } else if let image = publisherImageLoader.image {
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } else if let errorMessage = publisherImageLoader.errorMessage {
                        Text("Failed: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                    Text("@\(post.publisher?.name ?? "Unknown")")
                        .font(.headline)
                }
                .task(id: post.publisher?.picture?.id) {
                    if let serverUrl = appState.serverUrl, let pictureId = post.publisher?.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                        await publisherImageLoader.loadImage(from: imageUrl, token: token)
                    }
                }
                
                if let title = post.title, !title.isEmpty {
                    Text(title)
                        .font(.title2)
                        .bold()
                }
                
                if let content = post.content, !content.isEmpty {
                    Text(content)
                        .font(.body)
                }
                
                if let attachments = post.attachments, !attachments.isEmpty {
                    Text("Attachments").font(.headline)
                    ForEach(attachments) { attachment in
                        AttachmentView(attachment: attachment)
                    }
                }
                
                if let tags = post.tags, !tags.isEmpty {
                    Text("Tags").font(.headline)
                    FlowLayout(alignment: .leading, spacing: 4) {
                        ForEach(tags) { tag in
                            Text("#\(tag.name ?? tag.slug)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.accentColor.opacity(0.2)))
                                .cornerRadius(5)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post")
    }
}
