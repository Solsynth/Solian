//
//  ContentView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI
import Combine

// The root view of the app.
struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var summaryStore = ChatSummaryStore.shared
    @State private var selection: Panel?
    @State private var liveCancellable: AnyCancellable?

    enum Panel: String, Hashable {
        case explore
        case chat
        case notifications
        case account
        case checkIn
    }

    init() {
        // Launch into the last used panel (watchOS HIG: the source list should
        // remember the destination across launches).
        let stored = UserDefaults.standard.string(forKey: "lastPanel") ?? "explore"
        _selection = State(initialValue: Panel(rawValue: stored) ?? .explore)
    }

    var body: some View {
        Group {
            if appState.requiresSignIn {
                NavigationStack {
                    SignInView()
                        .environmentObject(appState)
                }
            } else {
                NavigationSplitView {
                    sidebar
                } detail: {
                    detail
                }
            }
        }
        .onAppear {
            // Own the live unread subscription at the root, not inside
            // ChatView, so the Chat badge is truthful no matter which panel
            // is on screen. Idempotent guard prevents double-counting.
            guard liveCancellable == nil else { return }
            summaryStore.loadCached()
            liveCancellable = summaryStore.observeLiveMessages()
        }
        .onDisappear {
            liveCancellable?.cancel()
            liveCancellable = nil
        }
        .onChange(of: selection) { _, newValue in
            if let newValue {
                UserDefaults.standard.set(newValue.rawValue, forKey: "lastPanel")
            }
        }
    }

    private var totalChatUnread: Int {
        summaryStore.roomSummaries.values.reduce(0) { $0 + $1.unreadCount }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            AppInfoHeaderView()
                .listRowBackground(Color.clear)
                .environmentObject(appState)

            navTile(panel: .explore, icon: "globe.fill", label: "Explore")
            navTile(panel: .chat, icon: "message.fill", label: "Chat", unread: totalChatUnread)
            navTile(panel: .notifications, icon: "bell.fill", label: "Notifications")
            navTile(panel: .account, icon: "person.circle.fill", label: "Account")
            navTile(panel: .checkIn, icon: "checkmark.seal.fill", label: "Check In")
        }
        .listStyle(.automatic)
    }

    /// A destination as a tappable card: leading icon in a rounded container,
    /// label, and an optional unread pill (matching the room-list convention).
    /// Idle rows are quiet; the selected tile lights up with the system accent
    /// so the current panel is unmistakable at a glance.
    private func navTile(panel: Panel, icon: String, label: String, unread: Int = 0) -> some View {
        let isSelected = selection == panel
        return HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
            }
            Text(label)
                .font(.body)
                .foregroundColor(isSelected ? Color.accentColor : Color.primary)
                .lineLimit(1)
            Spacer(minLength: 4)
            if unread > 0 {
                Text(unread > 99 ? "99+" : "\(unread)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red, in: Capsule())
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowBackground(Color.clear)
        .tag(panel)
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .explore:
            ExploreView().environmentObject(appState)
        case .chat:
            ChatView()
                .environmentObject(appState)
                .environmentObject(summaryStore)
        case .notifications:
            NotificationView().environmentObject(appState)
        case .account:
            AccountView().environmentObject(appState)
        case .checkIn:
            CheckInView().environmentObject(appState)
        case .none:
            Text("Select a panel")
        }
    }
}

// --- Placeholder Implementations for Preview ---

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
