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
    @State private var isLoading = false
    @State private var error: Error?
    
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
                        VStack(alignment: .leading, content: <#T##() -> View#>, spacing: 4) {
                            Text(user.nick)
                                .font(.headline)
                            Text("@\(user.name)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Bio
                    if let bio = user.profile.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No bio available")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Level and Progress
                    VStack(spacing: 8) {
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
                    
                    // Member since
                    Text("Member since: \(user.createdAt.formatted(.dateTime.month(.abbreviated).year()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
}
