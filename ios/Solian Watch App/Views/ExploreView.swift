//
//  ExploreView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isComposing = false

    var body: some View {
        NavigationStack {
            if appState.isReady {
                ActivityListView(filter: nil)
                    .navigationTitle("Feed")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { isComposing = true }) {
                                Label("Compose", systemImage: "plus")
                            }
                        }
                    }
            } else {
                VStack {
                    ProgressView()
                    Text("Loading...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $isComposing) {
            ComposePostView(replyingTo: nil)
                .environmentObject(appState)
        }
    }
}