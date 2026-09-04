//
//  ExploreView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

/// Explore hub: the three server-filtered feeds (Explore / Subscriptions /
/// Friends) as vertical Digital-Crown pages — each page is one full feed
/// (watchOS navigation model), with the secondary tools in a bottom bar and
/// compose as the primary bottom action. Launching lands on the Explore feed
/// so the screen never shows an empty source list.
struct ExploreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isComposing = false
    @State private var showPublishers = false
    @State private var showCategoriesTags = false
    @State private var showShuffle = false

    // Order matters: page 0 is where the app launches.
    private static let filters: [(label: String, systemImage: String, filter: String?)] = [
        ("Explore", "safari.fill", nil),
        ("Subscriptions", "star.fill", "subscriptions"),
        ("Friends", "person.2.fill", "friends"),
    ]

    var body: some View {
        NavigationStack {
            if appState.isReady {
                TabView {
                    ForEach(Self.filters, id: \.filter) { item in
                        FeedPageView(
                            label: item.label,
                            systemImage: item.systemImage,
                            filter: item.filter,
                            onCompose: { isComposing = true },
                            onShuffle: { showShuffle = true },
                            onPublishers: { showPublishers = true },
                            onBrowse: { showCategoriesTags = true }
                        )
                        .environmentObject(appState)
                        .tag(item.filter)
                    }
                }
                .tabViewStyle(.verticalPage)
                .navigationDestination(isPresented: $showPublishers) {
                    PublisherManagementView().environmentObject(appState)
                }
                .navigationDestination(isPresented: $showCategoriesTags) {
                    CategoriesTagsView().environmentObject(appState)
                }
                .navigationDestination(isPresented: $showShuffle) {
                    PostQueryListView(title: "Shuffle", shuffle: true)
                        .environmentObject(appState)
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

/// One vertical feed page: a titled activity list. Compose is a top-right
/// toolbar icon button (mirroring the nav-menu button top-left), and the
/// explore options (shuffle / publishers / categories) sit in a fixed detail
/// row above the posts, matching the main app's filter toolbar.
private struct FeedPageView: View {
    let label: String
    let systemImage: String
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
                    .accessibilityLabel("Compose")
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
            .accessibilityLabel("Shuffle posts")

            Button(action: onPublishers) {
                Image(systemName: "person.crop.square")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .clipShape(Circle())
            .accessibilityLabel("Manage publishers")

            Button(action: onBrowse) {
                Image(systemName: "square.grid.2x2")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .clipShape(Circle())
            .accessibilityLabel("Browse categories and tags")
            Spacer()
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}
