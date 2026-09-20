//
//  StickerImage.swift
//  WatchRunner Watch App
//
//  Auth'd image loading for sticker images and pack icons. The drive file
//  endpoints need a bearer token; this wraps the shared ImageLoader pattern
//  into a small view so timeline stickers, pack rails, and the sticker
//  message row all render identically.
//
//  Sticker files are often animated GIFs. `DownsampledAnimatedProcessor`
//  decodes every frame through ImageIO at a pixel size bounded to the render
//  target (never the file's native resolution), so a grid holding several
//  animated stickers stays within watch memory budgets — preloading every
//  frame at full resolution was a device-only OOM. The resulting `UIImage`
//  carries the small frame array in `.images`, which `StickerImageView`
//  cycles with a TimelineView (SwiftUI's `Image(uiImage:)` otherwise shows
//  just the first frame of an animated UIImage on watchOS).
//

import SwiftUI
import Kingfisher
import Combine
import ImageIO
import WatchKit

/// Decodes sticker image data into a `UIImage` whose frames are never larger
/// than `maxPixelSize` pixels on their longest side.
///
/// Runs inside Kingfisher's processing pipeline, so the downsampled result
/// (animated or static) is cached by Kingfisher under `identifier` — keyed by
/// target size — and repeated views reuse it without refetching or redecode.
/// Animated GIFs decode each frame through `CGImageSourceCreateThumbnailAtIndex`,
/// which bounds memory to one small frame at a time instead of allocating the
/// file's native resolution for every frame.
struct DownsampledAnimatedProcessor: ImageProcessor {
    /// Longest-side cap for a decoded frame, in pixels. `StickerImageLoader`
    /// derives it from the render dimension × screen scale.
    let maxPixelSize: CGFloat

    let identifier: String

    init(maxPixelSize: CGFloat) {
        self.maxPixelSize = max(32, min(maxPixelSize, 256))
        self.identifier = "com.solian.DownsampledAnimatedProcessor(\(Int(self.maxPixelSize)))"
    }

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        guard case .data(let data) = item else { return nil }
        return Self.decode(data: data, maxPixelSize: maxPixelSize)
    }

    private static func decode(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        if frameCount > 1 {
            var frames: [UIImage] = []
            var totalDuration: TimeInterval = 0
            for index in 0..<frameCount {
                guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary) else {
                    return nil
                }
                frames.append(UIImage(cgImage: cgImage))
                totalDuration += frameDelay(source: source, index: index)
            }
            let duration = totalDuration > 0 ? totalDuration : Double(frames.count) / 10.0
            return UIImage.animatedImage(with: frames, duration: duration)
        }

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// Per-frame GIF delay in seconds; falls back to 0.1 when the metadata is
    /// absent or malformed (GIFs commonly carry no delay on the first frame).
    private static func frameDelay(source: CGImageSource, index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }
        if let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
            return unclamped
        }
        if let delay = gif[kCGImagePropertyGIFDelayTime] as? Double, delay > 0 {
            return delay
        }
        return 0.1
    }
}

/// Loads a sticker file and keeps its decoded frames. Unlike the shared
/// `ImageLoader` (first-frame only), this decodes every GIF frame so
/// animated stickers animate — but each frame is downsampled to the render
/// target first, keeping device memory bounded (see
/// `DownsampledAnimatedProcessor`).
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

    func loadImage(from url: URL, token: String, targetDimension: CGFloat) async {
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

        let processor = DownsampledAnimatedProcessor(
            maxPixelSize: ceil(targetDimension * WKInterfaceDevice.current().screenScale)
        )

        currentTask = KingfisherManager.shared.retrieveImage(
            with: url,
            options: [
                .requestModifier(modifier),
                .processor(processor), // decode every GIF frame, size-bounded
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
                        // Normalize: the animated UIImage reports the
                        // whole-loop duration we built from frame delays.
                        self.duration = value.image.duration > 0
                            ? value.image.duration
                            : Double(frames.count) / 10.0
                    } else {
                        self.frames = [value.image]
                        self.duration = 0
                    }
                    self.isLoading = false
                case .failure:
                    // Fall back to the default processor (formats ImageIO
                    // can't thumbnail, e.g. some WebP). Static only: the
                    // default path decodes a single frame.
                    let defaultProcessor = DefaultImageProcessor.default
                    self.currentTask = KingfisherManager.shared.retrieveImage(
                        with: url,
                        options: [
                            .requestModifier(modifier),
                            .processor(defaultProcessor),
                            .cacheOriginalImage,
                            .loadDiskFileSynchronously
                        ]
                    ) { fallback in
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
        .task(id: "\(file?.id ?? "nil")-\(Int(dimension))") {
            guard let file,
                  let serverUrl = appState.serverUrl,
                  let token = appState.token,
                  let imageUrl = stickerFileURL(file, serverUrl: serverUrl) else { return }
            await loader.loadImage(from: imageUrl, token: token, targetDimension: dimension)
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
