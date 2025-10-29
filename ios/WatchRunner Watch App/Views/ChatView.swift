//
//  ChatView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/30.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var chatRooms: [SnChatRoom] = []
    @State private var chatInvites: [SnChatMember] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingInvites = false

    private let tabs = ["All", "Direct", "Group"]

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<tabs.count, id: \.self) { index in
                VStack {
                    if isLoading {
                        ProgressView()
                    } else if error != nil {
                        VStack {
                            Text("Error loading chats")
                                .font(.caption)
                            Button("Retry") {
                                Task {
                                    await loadChatRooms()
                                }
                            }
                            .font(.caption2)
                        }
                    } else {
                        ChatRoomListView(
                            chatRooms: filteredChatRooms(for: index),
                            selectedTab: index
                        )
                    }
                }
                .tabItem {
                    Text(tabs[index])
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInvites = true
                } label: {
                    ZStack {
                        Image(systemName: "envelope")
                        if !chatInvites.isEmpty {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingInvites) {
            ChatInvitesView(invites: $chatInvites, appState: appState)
        }
        .onAppear {
            Task.detached {
                await loadChatRooms()
                await loadChatInvites()
            }
        }
    }

    private func filteredChatRooms(for tabIndex: Int) -> [SnChatRoom] {
        switch tabIndex {
        case 0: // All
            return chatRooms
        case 1: // Direct
            return chatRooms.filter { $0.type == 1 }
        case 2: // Group
            return chatRooms.filter { $0.type != 1 }
        default:
            return chatRooms
        }
    }

    private func loadChatRooms() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        isLoading = true
        error = nil

        do {
            let response = try await appState.networkService.fetchChatRooms(token: token, serverUrl: serverUrl)
            chatRooms = response.rooms
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func loadChatInvites() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }

        do {
            let response = try await appState.networkService.fetchChatInvites(token: token, serverUrl: serverUrl)
            chatInvites = response.invites
        } catch {
            // Handle error silently for invites
        }
    }
}

struct ChatRoomListView: View {
    let chatRooms: [SnChatRoom]
    let selectedTab: Int

    var body: some View {
        if chatRooms.isEmpty {
            VStack {
                Image(systemName: "message")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("No chats yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            List(chatRooms) { room in
                ChatRoomListItem(room: room)
            }
            .listStyle(.plain)
        }
    }
}

struct ChatRoomListItem: View {
    let room: SnChatRoom
    @EnvironmentObject var appState: AppState
    @StateObject private var avatarLoader = ImageLoader()

    private var displayName: String {
        if room.type == 1, let members = room.members, !members.isEmpty {
            // For direct messages, show the other member's name
            return members[0].account.nick
        } else {
            // For group chats, show room name or fallback
            return room.name ?? "Group Chat"
        }
    }

    private var subtitle: String {
        if room.type == 1, let members = room.members, members.count > 1 {
            // For direct messages, show member usernames
            return members.map { "@\($0.account.name)" }.joined(separator: ", ")
        } else if let description = room.description {
            // For group chats with description
            return description
        } else {
            // Fallback
            return ""
        }
    }

    private var avatarPictureId: String? {
        if room.type == 1, let members = room.members, !members.isEmpty {
            // For direct messages, use the other member's avatar
            return members[0].account.profile.picture?.id
        } else {
            // For group chats, use room picture
            return room.picture?.id
        }
    }

    var body: some View {
        NavigationLink(destination: ChatRoomView(room: room)) {
            HStack {
                // Avatar using ImageLoader pattern
                Group {
                    if avatarLoader.isLoading {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    } else if let image = avatarLoader.image {
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } else if let errorMessage = avatarLoader.errorMessage {
                        // Error state - show fallback
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            )
                    } else {
                        // No image available - show initial
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            )
                    }
                }
                .task(id: avatarPictureId) {
                    if let serverUrl = appState.serverUrl,
                       let pictureId = avatarPictureId,
                       let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
                       let token = appState.token {
                        await avatarLoader.loadImage(from: imageUrl, token: token)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Unread count badge placeholder
                // In a full implementation, this would show unread count
            }
            .padding(.vertical, 4)
        }
    }
}

struct ChatRoomView: View {
    let room: SnChatRoom
    @EnvironmentObject var appState: AppState
    @State private var messages: [SnChatMessage] = []
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if error != nil {
                VStack {
                    Text("Error loading messages")
                        .font(.caption)
                    Button("Retry") {
                        Task {
                            await loadMessages()
                        }
                    }
                    .font(.caption2)
                }
            } else if messages.isEmpty {
                VStack {
                    Image(systemName: "bubble.left")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No messages yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                List(messages) { message in
                    ChatMessageItem(message: message)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(room.name ?? "Chat")
        .task {
            await loadMessages()
        }
    }

    private func loadMessages() async {
        // Placeholder for message loading
        // In a full implementation, this would fetch messages from the API
        // For now, just show empty state
        isLoading = false
    }
}

struct ChatMessageItem: View {
    let message: SnChatMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.sender.account.nick)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text(message.createdAt, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if let content = message.content {
                Text(content)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChatInvitesView: View {
    @Binding var invites: [SnChatMember]
    let appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if invites.isEmpty {
                    VStack {
                        Image(systemName: "envelope.open")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No invites")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(invites) { invite in
                        ChatInviteItem(invite: invite, appState: appState, invites: $invites)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Invites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatInviteItem: View {
    let invite: SnChatMember
    let appState: AppState
    @Binding var invites: [SnChatMember]
    @State private var isAccepting = false
    @State private var isDeclining = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text((invite.chatRoom?.name ?? "C").prefix(1).uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(invite.chatRoom?.name ?? "Unknown Chat")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(invite.role == 100 ? "Owner" : invite.role >= 50 ? "Moderator" : "Member")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        if invite.chatRoom?.type == 1 {
                            Text("Direct")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Button {
                    Task {
                        await acceptInvite()
                    }
                } label: {
                    if isAccepting {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "checkmark")
                            .frame(width: 20, height: 20)
                    }
                }
                .disabled(isAccepting || isDeclining)

                Button {
                    Task {
                        await declineInvite()
                    }
                } label: {
                    if isDeclining {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "xmark")
                            .frame(width: 20, height: 20)
                    }
                }
                .disabled(isAccepting || isDeclining)
            }
        }
        .padding(.vertical, 8)
    }

    private func acceptInvite() async {
        guard let token = appState.token,
              let serverUrl = appState.serverUrl,
              let chatRoomId = invite.chatRoom?.id else { return }

        isAccepting = true

        do {
            try await appState.networkService.acceptChatInvite(chatRoomId: chatRoomId, token: token, serverUrl: serverUrl)
            // Remove from invites list
            invites.removeAll { $0.id == invite.id }
        } catch {
            // Handle error - could show alert
            print("Failed to accept invite: \(error)")
        }

        isAccepting = false
    }

    private func declineInvite() async {
        guard let token = appState.token,
              let serverUrl = appState.serverUrl,
              let chatRoomId = invite.chatRoom?.id else { return }

        isDeclining = true

        do {
            try await appState.networkService.declineChatInvite(chatRoomId: chatRoomId, token: token, serverUrl: serverUrl)
            // Remove from invites list
            invites.removeAll { $0.id == invite.id }
        } catch {
            // Handle error - could show alert
            print("Failed to decline invite: \(error)")
        }

        isDeclining = false
    }
}
