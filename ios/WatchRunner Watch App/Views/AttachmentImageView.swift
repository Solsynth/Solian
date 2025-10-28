//
//  AttachmentImageView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

struct AttachmentImageView: View {
    let attachment: SnCloudFile
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if imageLoader.isLoading {
                ProgressView()
            } else if let image = imageLoader.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = imageLoader.errorMessage {
                Text("Failed to load attachment: \(errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("File: \(attachment.id)")
            }
        }
        .task(id: attachment.id) {
            if let serverUrl = appState.serverUrl, let imageUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl), let token = appState.token, attachment.mimeType?.starts(with: "image") == true {
                await imageLoader.loadImage(from: imageUrl, token: token)
            }
        }
    }
}
