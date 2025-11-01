//
//  ImageLoader.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import Kingfisher
import KingfisherWebP
import Combine

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

    func loadImage(from initialUrl: URL, token: String) async {
        isLoading = true
        errorMessage = nil
        image = nil

        // Create request modifier for authorization
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
            r.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")
            return r
        }

        // Use WebP processor as default since the app seems to handle WebP images
        let processor = WebPProcessor.default

        // Use KingfisherManager to retrieve image with caching
        currentTask = KingfisherManager.shared.retrieveImage(
            with: initialUrl,
            options: [
                .requestModifier(modifier),
                .processor(processor),
                .cacheOriginalImage, // Cache the original image data
                .loadDiskFileSynchronously // Load from disk cache synchronously if available
            ]
        ) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success(let value):
                    self.image = Image(uiImage: value.image)
                    self.isLoading = false
                case .failure(_):
                    // If WebP processor fails (likely due to format), try with default processor
                    let defaultProcessor = DefaultImageProcessor.default
                    self.currentTask = KingfisherManager.shared.retrieveImage(
                        with: initialUrl,
                        options: [
                            .requestModifier(modifier),
                            .processor(defaultProcessor),
                            .cacheOriginalImage,
                            .loadDiskFileSynchronously
                        ]
                    ) { [weak self] fallbackResult in
                        guard let self = self else { return }

                        Task { @MainActor in
                            switch fallbackResult {
                            case .success(let value):
                                self.image = Image(uiImage: value.image)
                            case .failure(let fallbackError):
                                self.errorMessage = fallbackError.localizedDescription
                                print("[watchOS] Image loading failed: \(fallbackError.localizedDescription)")
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
}
