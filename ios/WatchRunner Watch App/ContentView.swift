//
//  ContentView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI

// The root view of the app.
struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selection: Panel? = .explore

    enum Panel: Hashable {
        case explore
        case notifications
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("Explore", systemImage: "globe").tag(Panel.explore)
                Label("Notifications", systemImage: "bell").tag(Panel.notifications)
            }
            .listStyle(.automatic)
        } detail: {
            switch selection {
            case .explore:
                ExploreView()
                    .environmentObject(appState)
            case .notifications:
                NotificationView()
                    .environmentObject(appState)
            case .none:
                Text("Select a panel")
            }
        }
    }
}
