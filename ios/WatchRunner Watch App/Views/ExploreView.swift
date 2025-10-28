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

    var body: some View {
        NavigationStack {
            Group {
                if appState.isReady {
                    TabView {
                        NavigationStack {
                            ActivityListView(filter: "Explore")
                        }
                        .tabItem {
                            Label("Explore", systemImage: "safari")
                        }

                        NavigationStack {
                            ActivityListView(filter: "Subscriptions")
                        }
                        .tabItem {
                            Label("Subscriptions", systemImage: "star")
                        }

                        NavigationStack {
                            ActivityListView(filter: "Friends")
                        }
                        .tabItem {
                            Label("Friends", systemImage: "person.2")
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
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isComposing = true }) {
                        Label("Compose", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isComposing) {
                ComposePostView()
                    .environmentObject(appState)
            }
        }
    }
}