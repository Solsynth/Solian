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
                    Text(L10n.accountFailedToLoad)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let user = user {
                VStack(alignment: .leading, spacing: 16) {
                    // Banner (single branch; duplicate loading/error/empty
                    // rects collapsed into one placeholder).
                    if user.profile?.background != nil {
                        Group {
                            if bannerImageLoader.isLoading {
                                ProgressView()
                            } else if let bannerImage = bannerImageLoader.image {
                                bannerImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                        }
                        .frame(height: 80)
                        .clipped()
                        .cornerRadius(8)
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
                            Text(L10n.accountStatus)
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
                                        .fill((status.isOnline ?? false) ? Color.green : Color.gray)
                                        .frame(width: 8, height: 8)
                                    Text(status.label.isEmpty ? L10n.accountNoStatus : status.label)
                                        .font(.body)
                                }
                                
                                if status.isInvisible {
                                    Text(L10n.accountInvisible)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if status.isNotDisturb {
                                    Text(L10n.accountDoNotDisturb)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if let clearedAt = status.clearedAt {
                                    Text(String(format: L10n.accountClearsAt, clearedAt.formatted(date: .abbreviated, time: .shortened)))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text(L10n.accountNoStatusSet)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Level and Progress
                    VStack(alignment: .leading, spacing: 8) {
                        if let profile = user.profile {
                            Text(String(format: L10n.accountLevel, profile.level))
                                .font(.title3)
                                .bold()
                            ProgressView(value: profile.levelingProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(height: 8)
                            Text(String(format: L10n.accountExperience, profile.experience))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Bio
                    if let profile = user.profile, !profile.bio.isEmpty {
                        Text(profile.bio)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                    } else {
                        Text(L10n.accountNoBio)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Member since
                    if let createdAt = user.createdAt {
                        Text(String(format: L10n.accountJoinedAt, createdAt.formatted(.dateTime.month(.abbreviated).year())))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                // Load images when user data is available
                .task(id: user.profile?.picture?.id) {
                    guard let serverUrl = appState.serverUrl,
                          let pictureId = user.profile?.picture?.id,
                          let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
                          let token = appState.token else { return }
                    await profileImageLoader.loadImage(from: imageUrl, token: token)
                }
                .task(id: user.profile?.background?.id) {
                    guard let serverUrl = appState.serverUrl,
                          let backgroundId = user.profile?.background?.id,
                          let imageUrl = getAttachmentUrl(for: backgroundId, serverUrl: serverUrl),
                          let token = appState.token else { return }
                    await bannerImageLoader.loadImage(from: imageUrl, token: token)
                }
            } else {
                Text(L10n.accountNoAccountData)
                    .padding()
            }

            if appState.standaloneAuth.hasStoredSession {
                Button(role: .destructive) {
                    appState.signOutStandalone()
                } label: {
                    Label(L10n.accountSignOut, systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .accessibilityLabel(L10n.accountSignOutAccessibility)
            }
        }
        .navigationTitle(L10n.accountTitle)
        .confirmationDialog(L10n.accountClearStatus, isPresented: $showingClearConfirmation) {
            Button(L10n.accountClearStatusButton, role: .destructive) {
                Task {
                    await clearStatus()
                }
            }
            Button(L10n.accountCancel, role: .cancel) {}
        } message: {
            Text(L10n.accountClearStatusMessage)
        }
        .onAppear {
            Task {
                await loadUserProfile()
            }
        }
    }
    
    private func loadUserProfile() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            print("[AccountView] loadUserProfile - no token or serverUrl, token: \(appState.token != nil), serverUrl: \(appState.serverUrl != nil)")
            error = NSError(domain: "AccountView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication not available"])
            return
        }

        print("[AccountView] loadUserProfile - token: \(token.prefix(10))..., serverUrl: \(serverUrl)")
        
        isLoading = true
        error = nil

        do {
            print("[AccountView] loadUserProfile - calling fetchUserProfile")
            user = try await networkService.fetchUserProfile(token: token, serverUrl: serverUrl)
            print("[AccountView] loadUserProfile - calling fetchAccountStatus")
            status = try await networkService.fetchAccountStatus(token: token, serverUrl: serverUrl)
        } catch {
            print("[AccountView] loadUserProfile - error: \(error)")
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
