//
//  WatchRunnerApp.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI
import Kingfisher
import KingfisherWebP

@main
struct WatchRunner_Watch_AppApp: App {
    init() {
        configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureKingfisher() {
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
    }
}
