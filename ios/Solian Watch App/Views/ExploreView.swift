//
//  ExploreView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

/// Explore hub: one Explore feed (# mode only) with the explore options
/// (shuffle / publishers / categories) as a scrollable row above the posts,
/// and compose as a top-right toolbar icon. No Subscriptions / Friends tabs.
struct ExploreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isComposing = false
    @State private var showPublishers = false
    @State private var showCategoriesTags = false
    @State private var showShuffle = false

    var body: some View {
        NavigationStack {
            if appState.isReady {
                FeedPageView(
                    filter: nil,
                    onCompose: { isComposing = true },
                    onShuffle: { showShuffle = true },
                    onPublishers: { showPublishers = true },
                    onBrowse: { showCategoriesTags = true }
                )
                .environmentObject(appState)
                .navigationDestination(isPresented: $showPublishers) {
                    PublisherManagementView().environmentObject(appState)
                }
                .navigationDestination(isPresented: $showCategoriesTags) {
                    CategoriesTagsView().environmentObject(appState)
                }
                .navigationDestination(isPresented: $showShuffle) {
                    PostQueryListView(title: L10n.exploreShuffle, shuffle: true)
                        .environmentObject(appState)
                }
            } else {
                VStack {
                    ProgressView()
                    Text(L10n.exploreLoading)
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

/// The single explore feed page. Compose is a top-right toolbar icon button
/// (mirroring the nav-menu button top-left), and the explore options
/// (shuffle / publishers / categories) sit in a fixed detail row above the
/// posts, matching the main app's filter toolbar.
private struct FeedPageView: View {
    let filter: String?
    let onCompose: () -> Void
    let onShuffle: () -> Void
    let onPublishers: () -> Void
    let onBrowse: () -> Void

    var body: some View {
        ActivityListView(filter: filter, header: AnyView(exploreOptions))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onCompose) {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel(L10n.exploreCompose)
                }
            }
    }

    /// The explore options row, rendered as the first scrollable row so it
    /// scrolls away with the posts.
    private var exploreOptions: some View {
        HStack(spacing: 10) {
            Spacer()
            Button(action: onShuffle) {
                Image(systemName: "shuffle")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .clipShape(Circle())
            .accessibilityLabel(L10n.exploreShuffle)

            Button(action: onPublishers) {
                Image(systemName: "person.crop.square")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .clipShape(Circle())
            .accessibilityLabel(L10n.explorePublishers)

            Button(action: onBrowse) {
                Image(systemName: "square.grid.2x2")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .clipShape(Circle())
            .accessibilityLabel(L10n.exploreBrowseCategories)
            Spacer()
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}
