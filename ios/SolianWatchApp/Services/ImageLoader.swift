//
//  ImageLoader.swift
//  Solian Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import Kingfisher
import Combine
#if os(watchOS)
import WatchKit
#endif

// MARK: - Image Loader

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var currentTask: DownloadTask?

    init() {}

    deinit {
        currentTask?.cancel()
    }

    func loadImage(from initialUrl: URL, token: String, targetSize: CGSize? = nil) async {
        currentTask?.cancel()
        isLoading = true
        errorMessage = nil
        image = nil

        // Create request modifier for authorization
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            r.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
            return r
        }

        var options: KingfisherOptionsInfo = [
            .requestModifier(modifier),
            .backgroundDecode
        ]
        if let targetSize {
            #if os(watchOS)
            let scale = WKInterfaceDevice.current().screenScale
            #else
            let scale: CGFloat = 2.0
            #endif
            let processor = DownsamplingImageProcessor(size: targetSize)
            options.append(.processor(processor))
            options.append(.scaleFactor(scale))
        } else {
            options.append(.cacheOriginalImage)
        }

        // Use KingfisherManager to retrieve image with caching
        currentTask = KingfisherManager.shared.retrieveImage(
            with: initialUrl,
            options: options
        ) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success(let value):
                    self.image = Image(uiImage: value.image)
                    self.isLoading = false
                case .failure(let error):
                    if error.isTaskCancelled { return }
                    // Fall back to DefaultImageProcessor (e.g. formats DownsamplingImageProcessor
                    // or WebPProcessor cannot handle directly).
                    var fallbackOptions: KingfisherOptionsInfo = [
                        .requestModifier(modifier),
                        .processor(DefaultImageProcessor.default),
                        .backgroundDecode
                    ]
                    if targetSize == nil {
                        fallbackOptions.append(.cacheOriginalImage)
                    }
                    self.currentTask = KingfisherManager.shared.retrieveImage(
                        with: initialUrl,
                        options: fallbackOptions
                    ) { [weak self] fallbackResult in
                        guard let self = self else { return }

                        Task { @MainActor in
                            switch fallbackResult {
                            case .success(let value):
                                self.image = Image(uiImage: value.image)
                            case .failure(let fallbackError):
                                if !fallbackError.isTaskCancelled {
                                    self.errorMessage = fallbackError.localizedDescription
                                    print("[watchOS] Image loading failed: \(fallbackError.localizedDescription)")
                                }
                            }
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }

    func cancel() {
        currentTask?.cancel()
    }

    /// Drops every cached image — memory and disk. Static so the local-data
    /// purge can call it without holding a loader instance.
    static func clearCache() {
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
}
