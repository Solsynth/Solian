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
    var isCompact: Bool = false
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    private var screenWidth: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenBounds.width - 32
        #else
        return 200
        #endif
    }

    var body: some View {
        Group {
            if let mimeType = attachment.mimeType {
                if mimeType.starts(with: "image") {
                    imageContent
                } else if mimeType.starts(with: "video") {
                    videoContent
                } else if mimeType.starts(with: "audio") {
                    audioContent
                } else {
                    fileContent
                }
            } else {
                fileContent
            }
        }
        .task(id: attachment.id) {
            await loadThumbnail()
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let serverUrl = appState.serverUrl, let imageUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
            if isCompact {
                thumbnailLink(url: imageUrl, showPlayIcon: false)
            } else {
                NavigationLink(
                    destination: ImageViewer(imageUrl: imageUrl).environmentObject(appState)
                ) {
                    thumbnailView
                }
                .buttonStyle(PlainButtonStyle())
            }
        } else {
            placeholderView(icon: "photo")
        }
    }

    @ViewBuilder
    private var videoContent: some View {
        if let serverUrl = appState.serverUrl, let videoUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
            if isCompact {
                thumbnailLink(url: videoUrl, showPlayIcon: true)
            } else {
                NavigationLink(destination: VideoPlayerView(videoUrl: videoUrl)) {
                    videoThumbnailView
                }
                .buttonStyle(PlainButtonStyle())
            }
        } else {
            placeholderView(icon: "video")
        }
    }

    @ViewBuilder
    private var audioContent: some View {
        if let serverUrl = appState.serverUrl, let audioUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl) {
            if isCompact {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.caption)
                    Text(formatFileSize(attachment.size))
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            } else {
                AudioPlayerView(audioUrl: audioUrl)
            }
        } else {
            placeholderView(icon: "waveform")
        }
    }

    @ViewBuilder
    private var fileContent: some View {
        if isCompact {
            HStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.caption)
                Text(attachment.name ?? "File")
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)
        } else {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(attachment.name ?? "File")
                        .font(.subheadline)
                    Text(formatFileSize(attachment.size))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private func thumbnailLink(url: URL, showPlayIcon: Bool) -> some View {
        NavigationLink(
            destination: ImageViewer(imageUrl: url).environmentObject(appState)
        ) {
            ThumbnailImageView(
                isLoading: imageLoader.isLoading,
                image: imageLoader.image,
                errorMessage: imageLoader.errorMessage,
                isCompact: isCompact,
                showPlayIcon: showPlayIcon,
                placeholderContent: placeholderContent,
                maxWidth: screenWidth
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var thumbnailView: some View {
        ThumbnailImageView(
            isLoading: imageLoader.isLoading,
            image: imageLoader.image,
            errorMessage: imageLoader.errorMessage,
            isCompact: isCompact,
            showPlayIcon: false,
            placeholderContent: placeholderContent,
            maxWidth: screenWidth
        )
    }

    @ViewBuilder
    private var videoThumbnailView: some View {
        ThumbnailImageView(
            isLoading: imageLoader.isLoading,
            image: imageLoader.image,
            errorMessage: imageLoader.errorMessage,
            isCompact: isCompact,
            showPlayIcon: true,
            placeholderContent: placeholderContent,
            maxWidth: screenWidth
        )
    }

    private struct ThumbnailImageView: View {
        let isLoading: Bool
        let image: Image?
        let errorMessage: String?
        let isCompact: Bool
        let showPlayIcon: Bool
        let placeholderContent: (String, String?) -> AnyView
        let maxWidth: CGFloat

        var body: some View {
            ZStack {
                if isLoading {
                    if isCompact {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 80)
                            .overlay(ProgressView())
                    } else {
                        ProgressView()
                    }
                } else if let img = image {
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: maxWidth, height: isCompact ? 80 : 180)
                        .clipped()
                        .cornerRadius(8)
                } else if let error = errorMessage {
                    placeholderContent("photo", error)
                } else {
                    placeholderContent("photo", nil)
                }

                if showPlayIcon {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                }
            }
            .frame(width: maxWidth, height: isCompact ? 80 : 180)
        }
    }

    private var placeholderContent: (String, String?) -> AnyView {
        return { icon, message in
            AnyView(placeholderView(icon: icon, message: message))
        }
    }

    @ViewBuilder
    private func placeholderView(icon: String, message: String? = nil) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: screenWidth, height: isCompact ? 80 : 180)
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(isCompact ? .title3 : .title)
                if let message = message {
                    Text(message)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: screenWidth, height: isCompact ? 80 : 180)
    }

    private func loadThumbnail() async {
        guard let serverUrl = appState.serverUrl,
              let attachmentUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl),
              let token = appState.token else { return }

        let mimeType = attachment.mimeType ?? ""
        
        if mimeType.starts(with: "image") {
            await imageLoader.loadImage(from: attachmentUrl, token: token)
        } else if mimeType.starts(with: "video") {
            let thumbnailUrl = attachmentUrl.appending(queryItems: [URLQueryItem(name: "thumbnail", value: "true")])
            await imageLoader.loadImage(from: thumbnailUrl, token: token)
        }
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
