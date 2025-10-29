//
//  ExploreView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

// The main view with the TabView for filtering.
struct ExploreView: View {
    @StateObject private var appState = AppState()
    @State private var isComposing = false
    @State private var selectedTab: String = "Explore"

    var body: some View {
        NavigationStack {
            if appState.isReady {
                TabView(selection: $selectedTab) {
                    ActivityListView(filter: "Explore")
                        .tag("Explore")
                        .tabItem {
                            Label("Explore", systemImage: "safari")
                        }
                        .labelStyle(.titleOnly)

                    ActivityListView(filter: "Subscriptions")
                        .tag("Subscriptions")
                        .tabItem {
                            Label("Subscriptions", systemImage: "star")
                        }
                        .labelStyle(.titleOnly)

                    ActivityListView(filter: "Friends")
                        .tag("Friends")
                        .tabItem {
                            Label("Friends", systemImage: "person.2")
                        }
                        .labelStyle(.titleOnly)
                }
                .navigationTitle(selectedTab)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { isComposing = true }) {
                            Label("Compose", systemImage: "plus")
                        }
                    }
                }
                .environmentObject(appState)
            } else {
                ProgressView { Text("Connecting to phone...") }
                    .onAppear {
                        appState.requestData()
                    }
            }
        }
        .sheet(isPresented: $isComposing) {
            ComposePostView()
                .environmentObject(appState)
        }
    }
}
