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

    init(filter: String?, mockActivities: [SnTimelineEvent]? = nil) {
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
                List {
                    ForEach(viewModel.activities) { activity in
                        switch activity.data {
                        case .post(let post):
                            NavigationLink(
                                destination: PostDetailView(post: post).environmentObject(appState)
                            ) {
                                PostRowView(post: post)
                            }
                        case .discovery(let discoveryData):
                            DiscoveryView(discoveryData: discoveryData)
                        case .unknown, .none:
                            Text("Unknown activity type: \(activity.type)")
                        }
                    }
                    if viewModel.hasMore {
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Button("Load More") {
                                Task {
                                    if let token = appState.token, let serverUrl = appState.serverUrl {
                                        await viewModel.loadMoreActivities(token: token, serverUrl: serverUrl)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .onAppear {
            if appState.isReady, let token = appState.token, let serverUrl = appState.serverUrl {
                Task.detached {
                    await viewModel.fetchActivities(token: token, serverUrl: serverUrl)
                }
            }
        }
        .navigationTitle(viewModel.filter ?? "Explore")
        .navigationBarTitleDisplayMode(.inline)
    }
}
