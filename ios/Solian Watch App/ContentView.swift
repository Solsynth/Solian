//
//  ContentView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI

// The root view of the app.
struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selection: Panel? = .explore
    
    enum Panel: Hashable {
        case explore
        case chat
        case notifications
        case account
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                AppInfoHeaderView()
                    .listRowBackground(Color.clear)
                    .environmentObject(appState)
                
                Label("Explore", systemImage: "globe.fill").tag(Panel.explore)
                Label("Chat", systemImage: "message.fill").tag(Panel.chat)
                Label("Notifications", systemImage: "bell.fill").tag(Panel.notifications)
                Label("Account", systemImage: "person.circle.fill").tag(Panel.account)
            }
            .listStyle(.automatic)
        } detail: {
            switch selection {
            case .explore:
                ExploreView().environmentObject(appState)
            case .chat:
                ChatView().environmentObject(appState)
            case .notifications:
                NotificationView().environmentObject(appState)
            case .account:
                AccountView().environmentObject(appState)
            case .none:
                Text("Select a panel")
            }
        }
    }
}
