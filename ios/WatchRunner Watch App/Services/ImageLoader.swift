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

    private var dataTask: URLSessionDataTask?
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    deinit {
        dataTask?.cancel()
    }

    func loadImage(from initialUrl: URL, token: String) async {
        isLoading = true
        errorMessage = nil
        image = nil

        do {
            // First request with Authorization header
            var request = URLRequest(url: initialUrl)
            request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 302, let redirectLocation = httpResponse.allHeaderFields["Location"] as? String, let redirectUrl = URL(string: redirectLocation) {
                    print("[watchOS] Redirecting to: \(redirectUrl)")
                    // Second request to the redirected URL (S3 signed URL) without Authorization header
                    let (redirectData, _) = try await session.data(from: redirectUrl)
                    if let uiImage = UIImage(data: redirectData) {
                        self.image = Image(uiImage: uiImage)
                        print("[watchOS] Image loaded successfully from redirect URL.")
                    } else {
                        // Try KingfisherWebP for WebP
                        let processor = WebPProcessor.default // Correct usage
                        if let kfImage = processor.process(item: .data(redirectData), options: KingfisherParsedOptionsInfo(
                            [
                                .processor(processor),
                                .loadDiskFileSynchronously,
                                .cacheOriginalImage
                            ]
                        )) {
                            self.image = Image(uiImage: kfImage)
                            print("[watchOS] Image loaded successfully from redirect URL using KingfisherWebP.")
                        } else {
                            self.errorMessage = "Invalid image data from redirect (could not decode with KingfisherWebP)."
                        }
                    }
                } else if httpResponse.statusCode == 200 {
                    if let uiImage = UIImage(data: data) {
                        self.image = Image(uiImage: uiImage)
                        print("[watchOS] Image loaded successfully from initial URL.")
                    } else {
                        // Try KingfisherWebP for WebP
                        let processor = WebPProcessor.default // Correct usage
                        if let kfImage = processor.process(item: .data(data), options: KingfisherParsedOptionsInfo(
                            [
                                .processor(processor),
                                .loadDiskFileSynchronously,
                                .cacheOriginalImage
                            ]
                        )) {
                            self.image = Image(uiImage: kfImage)
                            print("[watchOS] Image loaded successfully from initial URL using KingfisherWebP.")
                        } else {
                            self.errorMessage = "Invalid image data (could not decode with KingfisherWebP)."
                        }
                    }
                } else {
                    self.errorMessage = "HTTP Status Code: \(httpResponse.statusCode)"
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] Image loading failed: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func cancel() {
        dataTask?.cancel()
    }
}
