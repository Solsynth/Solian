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

    /// An optional view rendered as the first List row/section, so it scrolls
    /// with the content (e.g. the explore options row above the posts).
    var header: AnyView? = nil

    init(filter: String?, mockActivities: [SnTimelineEvent]? = nil, header: AnyView? = nil) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(filter: filter, mockActivities: mockActivities))
        self.header = header
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 0) {
                    if let header { header }
                    ProgressView()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 0) {
                    if let header { header }
                    VStack {
                        Text("Error fetching data")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    .padding()
                }
            } else if viewModel.activities.isEmpty {
                VStack(spacing: 0) {
                    if let header { header }
                    Text("No activities found.")
                }
            } else {
                List {
                    if let header {
                        header
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                    ForEach(viewModel.activities) { activity in
                        if activity.isPost {
                            if let post = activity.decodePost() {
                                NavigationLink(
                                    destination: PostDetailView(post: post).environmentObject(appState)
                                ) {
                                    PostRowView(post: post)
                                }
                            } else {
                                Text("Unknown activity")
                            }
                        } else if activity.isDiscovery {
                            if let section = activity.decodeDiscovery() {
                                DiscoverySectionView(section: section)
                                    .environmentObject(appState)
                            } else {
                                Text("Unknown activity")
                            }
                        } else if activity.isFriendPresence || activity.isFriendStatus {
                            ActivityEventRow(event: activity)
                        } else {
                            Text("Unknown activity")
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

/// A compact row for friend-presence / friend-status timeline events. Unlike
/// posts and discovery sections, these carry a small payload (a friend's
/// activity / status) that we render as a one-to-two-line summary. Never
/// surfaces "Unknown activity".
struct ActivityEventRow: View {
    let event: SnTimelineEvent

    // MARK: - Presence

    /// Decodes the friend's name from the embedded account object.
    private var friendName: String? {
        guard let data = event.data?.value as? [String: Any] else { return nil }
        let container = event.isFriendStatus ? data["status"] : data["activity"]
        guard let payload = container as? [String: Any] else { return nil }
        if let account = payload["account"] as? [String: Any] {
            if let nick = account["nick"] as? String, !nick.isEmpty { return nick }
            if let name = account["name"] as? String, !name.isEmpty { return name }
        }
        if let accountId = payload["account_id"] as? String, !accountId.isEmpty {
            return nil // no embedded account; show a generic label
        }
        return nil
    }

    private var presenceType: String? {
        guard let data = event.data?.value as? [String: Any],
              let activity = data["activity"] as? [String: Any] else { return nil }
        // activity.type is an int enum (1 gaming, 2 music, 3 workout) or a
        // raw string. Mirror the main app's switch.
        if let raw = activity["type"] as? Int {
            switch raw {
            case 1: return "Gaming"
            case 2: return "Music"
            case 3: return "Workout"
            default: return nil
            }
        }
        if let raw = activity["type"] as? String {
            switch raw.lowercased() {
            case "gaming": return "Gaming"
            case "music": return "Music"
            case "workout", "fitness": return "Workout"
            case "1": return "Gaming"
            case "2": return "Music"
            case "3": return "Workout"
            default: return raw
            }
        }
        return nil
    }

    private var presenceTitle: String? {
        guard let data = event.data?.value as? [String: Any],
              let activity = data["activity"] as? [String: Any] else { return nil }
        return (activity["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Status

    private var statusPayload: [String: Any]? {
        guard let data = event.data?.value as? [String: Any] else { return nil }
        return data["status"] as? [String: Any]
    }

    private var statusLabel: String {
        guard let status = statusPayload else {
            return event.isFriendStatus ? "Friend updated status" : "Friend activity"
        }
        if let label = status["label"] as? String, !label.isEmpty { return label }
        if let text = status["text"] as? String, !text.isEmpty { return text }
        // Fall back to the type int.
        if let t = status["type"] as? Int {
            switch t {
            case 1: return "Busy"
            case 2: return "Do Not Disturb"
            case 3: return "Invisible"
            default: return "Online"
            }
        }
        return "Friend updated status"
    }

    // MARK: - View

    private var icon: String {
        if event.isFriendStatus {
            switch statusPayload?["type"] as? Int ?? 0 {
            case 2: return "moon.zzz.fill"   // DND
            case 3: return "eye.slash.fill"  // invisible
            default: return "person.crop.circle.badge.checkmark"
            }
        }
        switch presenceType?.lowercased() {
        case "gaming": return "gamecontroller.fill"
        case "music": return "music.note"
        case "workout", "fitness": return "figure.run"
        default: return "person.2.wave.2"
        }
    }

    private var headline: String {
        if let friendName = friendName, !friendName.isEmpty {
            return event.isFriendStatus
                ? "\(friendName) · \(statusLabel)"
                : "\(friendName) · \(presenceTitle ?? presenceType ?? "is active")"
        }
        return event.isFriendStatus ? statusLabel : (presenceTitle ?? presenceType ?? "Friend activity")
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 1) {
                Text(headline)
                    .font(.caption)
                    .lineLimit(2)
                if presenceType != nil, presenceTitle == nil {
                    Text(presenceType!)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}
