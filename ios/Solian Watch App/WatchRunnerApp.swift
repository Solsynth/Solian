//
//  WatchRunnerApp.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI
import SwiftData
import Kingfisher
import KingfisherWebP

@main
struct WatchRunner_Watch_AppApp: App {
    private let chatCache: ChatCache

    init() {
        // The app-wide cache; ChatCache.shared must point at the real store.
        let cache = Self.makeChatCache()
        self.chatCache = cache
        ChatCache.shared = cache
        configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.chatCache, chatCache)
        }
    }

    /// Builds a SwiftData-backed chat cache (single persistent store). Falls
    /// back to an in-memory store if the container can't be created, so chat
    /// still works (just without persistence).
    private static func makeChatCache() -> ChatCache {
        let schema = Schema([CachedChatRoom.self, CachedChatMessage.self])
        do {
            // Pin the store to the app's own Application Support directory and
            // create it explicitly. Without this, SwiftData resolves the store
            // into the App Group container's missing Application Support dir,
            // producing CoreData sandbox-creation errors (Code=512) on launch.
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!
            try FileManager.default.createDirectory(
                at: appSupport,
                withIntermediateDirectories: true
            )
            let storeURL = appSupport.appendingPathComponent("SolianChat.store")

            let config = ModelConfiguration(
                url: storeURL,
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(for: schema, configurations: [config])
            return ChatCache(modelContext: ModelContext(container))
        } catch {
            print("[watchOS] SwiftData store creation failed, using in-memory: \(error)")
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let memoryContainer = try! ModelContainer(for: schema, configurations: [memoryConfig])
            return ChatCache(modelContext: ModelContext(memoryContainer))
        }
    }

    private func configureKingfisher() {
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
    }
}

// MARK: - Environment

private struct ChatCacheKey: EnvironmentKey {
    static let defaultValue: ChatCache = .shared
}

extension EnvironmentValues {
    var chatCache: ChatCache {
        get { self[ChatCacheKey.self] }
        set { self[ChatCacheKey.self] = newValue }
    }
}
