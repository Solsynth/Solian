//
//  AttachmentImageView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import AVKit
import AVFoundation

struct AttachmentView: View {
    let attachment: SnCloudFile
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if let mimeType = attachment.mimeType {
                if mimeType.starts(with: "image") {
                    if let serverUrl = appState.serverUrl, let imageUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
                        NavigationLink(
                            destination: ImageViewer(imageUrl: imageUrl).environmentObject(appState)
                        ) {
                            if imageLoader.isLoading {
                                ProgressView()
                            } else if let image = imageLoader.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(8)
                            } else if let errorMessage = imageLoader.errorMessage {
                                Text("Failed to load attachment: \(errorMessage)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            } else {
                                Text("File: \(attachment.id)")
                                    .cornerRadius(8)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("Image URL not available.")
                    }
                } else if mimeType.starts(with: "video") {
                    if let serverUrl = appState.serverUrl, let videoUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
                        let thumbnailUrl = videoUrl.appendingPathComponent("thumbnail") // Construct thumbnail URL
                        NavigationLink(destination: VideoPlayerView(videoUrl: videoUrl)) {
                            AsyncImage(url: thumbnailUrl) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                } else if phase.error != nil {
                                    Image(systemName: "play.rectangle.fill") // Placeholder for video thumbnail
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                        .cornerRadius(8)
                                } else {
                                    ProgressView()
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("Video URL not available.")
                    }
                } else if mimeType.starts(with: "audio") {
                    if let serverUrl = appState.serverUrl, let audioUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
                        AudioPlayerView(audioUrl: audioUrl)
                    } else {
                        Text("Cannot play audio: URL not available.")
                    }
                } else {
                    Text("Unsupported media type: \(mimeType)")
                }
            } else {
                Text("File: \(attachment.id) (No MIME type)")
            }
        }
        .task(id: attachment.id) {
            if let serverUrl = appState.serverUrl, let attachmentUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl), let token = appState.token {
                if attachment.mimeType?.starts(with: "image") == true {
                    await imageLoader.loadImage(from: attachmentUrl, token: token)
                }
            }
        }
    }
}
