//
//  StickerImage.swift
//  WatchRunner Watch App
//
//  Auth'd image loading for sticker images and pack icons. The drive file
//  endpoints need a bearer token; this wraps the shared ImageLoader pattern
//  into a small view so timeline stickers, pack rails, and the sticker
//  message row all render identically.
//
//  Sticker files are often animated GIFs. Kingfisher's `retrieveImage`
//  default path decodes only the first frame; requesting
//  `.preloadAllAnimationData` produces a `UIImage` whose `.images` array
//  holds every frame, which this view cycles with a TimelineView (SwiftUI's
//  `Image(uiImage:)` otherwise shows just the first frame of an animated
//  UIImage on watchOS).
//

import SwiftUI
import Kingfisher
import Combine

/// Loads a sticker file and keeps its decoded frames. Unlike the shared
/// `ImageLoader` (first-frame only), this requests `.preloadAllAnimationData`
/// so animated GIF stickers expose their full frame array.
@MainActor
final class StickerImageLoader: ObservableObject {
    @Published private(set) var frames: [UIImage] = []
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var currentTask: DownloadTask?

    deinit {
        currentTask?.cancel()
    }

    func loadImage(from url: URL, token: String) async {
        currentTask?.cancel()
        isLoading = true
        errorMessage = nil
        frames = []
        duration = 0

        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            r.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
            return r
        }

        currentTask = KingfisherManager.shared.retrieveImage(
            with: url,
            options: [
                .requestModifier(modifier),
                .preloadAllAnimationData, // decode every GIF frame
                .cacheOriginalImage,
                .loadDiskFileSynchronously
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in
                switch result {
                case .success(let value):
                    if let frames = value.image.images, frames.count > 1 {
                        self.frames = frames
                        // Normalize: Kingfisher reports whole-loop duration.
                        self.duration = value.image.duration > 0
                            ? value.image.duration
                            : Double(frames.count) / 10.0
                    } else {
                        self.frames = [value.image]
                        self.duration = 0
                    }
                    self.isLoading = false
                case .failure(let error):
                    // Fall back to the default processor (non-GIF formats).
                    let defaultProcessor = DefaultImageProcessor.default
                    self.currentTask = KingfisherManager.shared.retrieveImage(
                        with: url,
                        options: [
                            .requestModifier(modifier),
                            .processor(defaultProcessor),
                            .cacheOriginalImage,
                            .loadDiskFileSynchronously
                        ]
                    ) { [weak self] fallback in
                        guard let self = self else { return }
                        Task { @MainActor in
                            switch fallback {
                            case .success(let value):
                                self.frames = [value.image]
                                self.duration = 0
                            case .failure(let fallbackError):
                                self.errorMessage = fallbackError.localizedDescription
                                print("[StickerImageLoader] failed: \(fallbackError.localizedDescription)")
                            }
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
}

/// A sticker/pack-icon image resolved from a drive file id. Animated GIFs
/// cycle their frames; static images render once. Falls back to a tinted
/// placeholder while loading or on failure.
struct StickerImageView: View {
    let file: SnCloudFileReference?
    var dimension: CGFloat = 32
    var fallbackIcon: String = "face.smiling"

    @EnvironmentObject var appState: AppState
    @StateObject private var loader = StickerImageLoader()

    var body: some View {
        Group {
            if loader.isLoading {
                placeholder
            } else if loader.frames.count > 1 {
                // Animated: cycle frames at the GIF's own pace.
                AnimatedFramesView(frames: loader.frames, duration: loader.duration)
                    .frame(width: dimension, height: dimension)
            } else if let frame = loader.frames.first {
                Image(uiImage: frame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dimension, height: dimension)
            } else {
                placeholder
            }
        }
        .task(id: file?.id) {
            guard let file,
                  let serverUrl = appState.serverUrl,
                  let token = appState.token,
                  let imageUrl = stickerFileURL(file, serverUrl: serverUrl) else { return }
            await loader.loadImage(from: imageUrl, token: token)
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.gray.opacity(0.12))
            .frame(width: dimension, height: dimension)
            .overlay(
                Image(systemName: fallbackIcon)
                    .font(.system(size: dimension * 0.35))
                    .foregroundColor(.secondary)
            )
    }
}

/// Cycles `frames` in a TimelineView, showing frame `i` where `i` advances
/// with the elapsed animation time. Per-frame duration = loop duration /
/// frame count (GIF frames are commonly uniform).
private struct AnimatedFramesView: View {
    let frames: [UIImage]
    let duration: TimeInterval

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let frameDuration = duration / Double(max(frames.count, 1))
            let index = frameDuration > 0
                ? Int(elapsed / frameDuration) % max(frames.count, 1)
                : 0
            Image(uiImage: frames[max(0, min(index, frames.count - 1))])
                .resizable()
                .scaledToFit()
        }
    }
}

/// Resolves a sticker file reference to its loadable URL. A direct `url`
/// wins; otherwise the drive-file endpoint is used (mirrors
/// `getAttachmentUrl` for full cloud files).
func stickerFileURL(_ file: SnCloudFileReference, serverUrl: String) -> URL? {
    if let urlString = file.url, !urlString.isEmpty {
        return URL(string: urlString)
    }
    return getAttachmentUrl(for: file.id, serverUrl: serverUrl)
}
