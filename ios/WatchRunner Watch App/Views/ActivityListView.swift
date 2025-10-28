//
//  ActivityListView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

// MARK: - Views

struct ActivityListView: View {
    @StateObject private var viewModel: ActivityViewModel
    @EnvironmentObject var appState: AppState

    init(filter: String, mockActivities: [SnActivity]? = nil) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(filter: filter, mockActivities: mockActivities))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error fetching data")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .lineLimit(nil)
                }
                .padding()
            } else if viewModel.activities.isEmpty {
                Text("No activities found.")
            } else {
                List(viewModel.activities) { activity in
                    switch activity.type {
                    case "posts.new", "posts.new.replies":
                        if case .post(let post) = activity.data {
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostRowView(post: post)
                            }
                        }
                    case "discovery":
                         if case .discovery(let discoveryData) = activity.data {
                             DiscoveryView(discoveryData: discoveryData)
                         }
                    default:
                        Text("Unknown activity type: \(activity.type)")
                    }
                }
            }
        }
        .task {
            // Only fetch if appState is ready and token/serverUrl are available
            if appState.isReady, let token = appState.token, let serverUrl = appState.serverUrl {
                await viewModel.fetchActivities(token: token, serverUrl: serverUrl)
            }
        }
        .navigationTitle(viewModel.filter)
        .navigationBarTitleDisplayMode(.inline)
    }
}
