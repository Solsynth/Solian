//
//  AccountView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/30.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @State private var user: SnAccount?
    @State private var status: SnAccountStatus?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingClearConfirmation = false

    @StateObject private var profileImageLoader = ImageLoader()
    @StateObject private var bannerImageLoader = ImageLoader()

    private let networkService = NetworkService()
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding()
            } else if let error = error {
                VStack {
                    Text("Failed to load account")
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let user = user {
                VStack(spacing: 16) {
                    // Banner
                    if user.profile.background != nil {
                        if bannerImageLoader.isLoading {
                            ProgressView()
                                .frame(height: 80)
                        } else if let bannerImage = bannerImageLoader.image {
                            bannerImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 80)
                                .clipped()
                                .cornerRadius(8)
                        } else if bannerImageLoader.errorMessage != nil {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 80)
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 80)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Profile Picture
                    HStack(spacing: 16)
                    {
                        if profileImageLoader.isLoading {
                            ProgressView()
                                .frame(width: 60, height: 60)
                        } else if let profileImage = profileImageLoader.image {
                            profileImage
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else if profileImageLoader.errorMessage != nil {
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.red)
                                )
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // Username and Handle
                        VStack(alignment: .leading) {
                            Text(user.nick)
                                .font(.headline)
                            Text("@\(user.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Status
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Status")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            if status?.isCustomized == true {
                                Button(action: {
                                    showingClearConfirmation = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .buttonStyle(.plain)
                                .frame(width: 28, height: 28)
                            }
                            NavigationLink(
                                destination: StatusCreationView(initialStatus: status?.isCustomized == true ? status : nil)
                                    .environmentObject(appState)
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 28, height: 28)
                        }
                        
                        if let status = status {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Circle()
                                        .fill(status.isOnline ? Color.green : Color.gray)
                                        .frame(width: 8, height: 8)
                                    Text(status.label.isEmpty ? "No status" : status.label)
                                        .font(.body)
                                }
                                
                                if status.isInvisible {
                                    Text("Invisible")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if status.isNotDisturb {
                                    Text("Do Not Disturb")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if let clearedAt = status.clearedAt {
                                    Text("Clears: \(clearedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text("No status set")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Level and Progress
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Level \(user.profile.level)")
                            .font(.title3)
                            .bold()
                        ProgressView(value: user.profile.levelingProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 8)
                        Text("Experience: \(user.profile.experience)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Bio
                    if !user.profile.bio.isEmpty {
                        Text(user.profile.bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .frame(alignment: .leading)
                    } else {
                        Text("No bio available")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(alignment: .leading)
                    }
                    
                    // Member since
                    Text("Joined at \(user.createdAt.formatted(.dateTime.month(.abbreviated).year()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(alignment: .leading)
                }
                .padding()
                // Load images when user data is available
                .task(id: user.profile.picture?.id) {
                    if let serverUrl = appState.serverUrl, let pictureId = user.profile.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                        await profileImageLoader.loadImage(from: imageUrl, token: token)
                    }
                }
                .task(id: user.profile.background?.id) {
                    if let serverUrl = appState.serverUrl, let backgroundId = user.profile.background?.id, let imageUrl = getAttachmentUrl(for: backgroundId, serverUrl: serverUrl), let token = appState.token {
                        await bannerImageLoader.loadImage(from: imageUrl, token: token)
                    }
                }
            } else {
                Text("No account data")
                    .padding()
            }
        }
        .navigationTitle("Account")
        .confirmationDialog("Clear Status", isPresented: $showingClearConfirmation) {
            Button("Clear Status", role: .destructive) {
                Task {
                    await clearStatus()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear your status? This action cannot be undone.")
        }
        .onAppear {
            Task.detached {
                await loadUserProfile()
            }
        }
    }
    
    private func loadUserProfile() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            error = NSError(domain: "AccountView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication not available"])
            return
        }

        isLoading = true
        error = nil

        do {
            user = try await networkService.fetchUserProfile(token: token, serverUrl: serverUrl)
            status = try await networkService.fetchAccountStatus(token: token, serverUrl: serverUrl)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func clearStatus() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            error = NSError(domain: "AccountView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication not available"])
            return
        }

        do {
            try await networkService.clearStatus(token: token, serverUrl: serverUrl)
            // Refresh status after clearing
            status = try await networkService.fetchAccountStatus(token: token, serverUrl: serverUrl)
        } catch {
            self.error = error
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
}
