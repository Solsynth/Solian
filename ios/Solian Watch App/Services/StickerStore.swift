//
//  StickerStore.swift
//  WatchRunner Watch App
//
//  Shared sticker state: the current user's owned packs (fetched on demand),
//  plus a small placeholder→resolved-sticker cache so message bubbles can
//  render `:prefix+slug:` placeholders without refetching per row. Lives at
//  app scope so the composer pack rail and the timeline share one source.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class StickerStore: ObservableObject {
    /// App-wide store, created once.
    static let shared = StickerStore()

    @Published private(set) var packs: [SnStickerPack] = []
    @Published private(set) var isLoadingPacks = false
    @Published private(set) var loadError: String?
    /// True once a fetch completed (even with zero owned packs), so callers
    /// can distinguish "still loading" from "owns nothing".
    @Published private(set) var hasLoadedPacks = false

    /// Placeholder identifier (without the surrounding colons) → resolved
    /// sticker, so each sticker is fetched once per session.
    private(set) var lookupCache: [String: SnSticker] = [:]

    private let networkService = NetworkService()

    /// Fetches sticker packs owned by the current user. Views own their
    /// `AppState`, so credentials are passed in explicitly.
    func loadOwnedPacks(token: String, serverUrl: String, force: Bool = false) async {
        guard !isLoadingPacks else { return }
        if !force, hasLoadedPacks { return }

        isLoadingPacks = true
        loadError = nil
        defer { isLoadingPacks = false }

        do {
            packs = try await networkService.fetchMyStickerPacks(token: token, serverUrl: serverUrl)
            hasLoadedPacks = true
        } catch {
            loadError = error.localizedDescription
            print("[StickerStore] loadOwnedPacks failed: \(error)")
        }
    }

    /// Resolves a `prefix+slug` identifier to its sticker, hitting the lookup
    /// endpoint only on a cache miss.
    func resolve(identifier: String, token: String, serverUrl: String) async -> SnSticker? {
        if let cached = lookupCache[identifier] {
            return cached
        }
        guard let sticker = try? await networkService.fetchStickerLookup(
            identifier: identifier, token: token, serverUrl: serverUrl
        ) else { return nil }
        lookupCache[identifier] = sticker
        return sticker
    }
}
