//
//  ExploreView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

// The main view with the TabView for filtering.
struct ExploreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isComposing = false
    @State private var selectedTab: String = "Explore"

    var body: some View {
        NavigationStack {
            if appState.isReady {
                TabView(selection: $selectedTab) {
                    ActivityListView(filter: nil)
                        .tag("Explore")
                        .tabItem {
                            Label("Explore", systemImage: "safari")
                        }
                        .labelStyle(.titleOnly)

                    ActivityListView(filter: "subscriptions")
                        .tag("Subscriptions")
                        .tabItem {
                            Label("Subscriptions", systemImage: "star")
                        }
                        .labelStyle(.titleOnly)

                    ActivityListView(filter: "friends")
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
            } else {
                VStack {
                    ProgressView { Text("Syncing...") }
                    Button("Retry") {
                        appState.requestData()
                    }
                }
            }
        }
        .sheet(isPresented: $isComposing) {
            ComposePostView()
        }
        .alert("Error", isPresented: .constant(appState.errorMessage != nil), actions: {
            Button("OK") { appState.errorMessage = nil }
        }, message: {
            Text(appState.errorMessage ?? "")
        })
    }
}
