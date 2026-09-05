//
//  CloudImageLinkerView.swift
//  WatchRunner Watch App
//
//  "Link a cloud image" sheet: a grid of the user's Drive image files; tapping
//  one sends it as a chat message attachment without re-uploading. Mirrors
//  Flutter's `ChatLinkAttachment` recent-uploads tab returning an `SnCloudFile`,
//  which is sent with `attachments_id: [file.id]`.
//

import SwiftUI
import WatchKit

struct CloudImageLinkerView: View {
    @EnvironmentObject var appState: AppState

    /// Called with the chosen cloud file once the user confirms.
    let onSend: (SnCloudFile) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var files: [SnCloudFile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Link Cloud Image")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if files.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "cloud")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(errorMessage ?? "No cloud images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)],
                        spacing: 6
                    ) {
                        ForEach(files) { file in
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                onSend(file)
                                dismiss()
                            } label: {
                                CloudImageThumb(file: file)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task {
            await load()
        }
    }

    private func load() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let all = try await appState.networkService.fetchMyCloudFiles(
                token: token,
                serverUrl: serverUrl,
                offset: 0,
                take: 50
            )
            files = all.filter { ($0.mimeType ?? "").hasPrefix("image") }
            if files.isEmpty {
                errorMessage = "No cloud images"
            }
        } catch {
            errorMessage = "Could not load cloud images"
        }
    }
}

/// A square image tile that fills its grid cell. Shows a spinner while loading
/// and a placeholder icon on failure. Sized from the screen width so every
/// tile has a stable, full-cell tap target (a GeometryReader-based label gives
/// the grid cell ambiguous height, collapsing the touch area).
private struct CloudImageThumb: View {
    let file: SnCloudFile
    @EnvironmentObject var appState: AppState
    @StateObject private var loader = ImageLoader()

    /// Two columns across the screen: width minus 2×12pt padding and 6pt
    /// inter-column spacing, halved. Falls back to 100pt on a non-watch target.
    private var side: CGFloat {
        #if os(watchOS)
        return (WKInterfaceDevice.current().screenBounds.width - 24 - 6) / 2
        #else
        return 100
        #endif
    }

    var body: some View {
        Group {
            if loader.isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay(ProgressView())
            } else if let image = loader.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .task(id: file.id) {
            guard let serverUrl = appState.serverUrl,
                  let imageUrl = getAttachmentUrl(for: file.id, serverUrl: serverUrl),
                  let token = appState.token else { return }
            await loader.loadImage(from: imageUrl, token: token)
        }
    }
}
