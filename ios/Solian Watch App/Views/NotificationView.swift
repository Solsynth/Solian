
//
//  NotificationView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications = [SnNotification]()
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMore = false

    private let networkService = NetworkService()
    private var hasFetched = false
    private var offset = 0
    private let pageSize = 20

    func fetchNotifications(token: String, serverUrl: String) async {
        if hasFetched { return }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        hasFetched = true
        offset = 0

        do {
            let response = try await networkService.fetchNotifications(offset: offset, take: pageSize, token: token, serverUrl: serverUrl)
            self.notifications = response.notifications
            self.hasMore = response.hasMore
            offset += response.notifications.count
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] fetchNotifications failed with error: \(error)")
            hasFetched = false
        }

        isLoading = false
    }

    func loadMoreNotifications(token: String, serverUrl: String) async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true

        do {
            let response = try await networkService.fetchNotifications(offset: offset, take: pageSize, token: token, serverUrl: serverUrl)
            self.notifications.append(contentsOf: response.notifications)
            self.hasMore = response.hasMore
            offset += response.notifications.count
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] loadMoreNotifications failed with error: \(error)")
        }

        isLoadingMore = false
    }
}

struct NotificationView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = NotificationViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                    Button("Retry") {
                        Task {
                            if let token = appState.token, let serverUrl = appState.serverUrl {
                                await viewModel.fetchNotifications(token: token, serverUrl: serverUrl)
                            }
                        }
                    }
                }
                .padding()
            } else if viewModel.notifications.isEmpty {
                Text("No notifications")
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NavigationLink(destination: NotificationDetailView(notification: notification)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(notification.title)
                                        .font(.headline)
                                    Spacer()
                                    if notification.viewedAt == nil {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                if !notification.subtitle.isEmpty {
                                    Text(notification.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if notification.content.count > 100 {
                                    Text(notification.content.prefix(100) + "...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                } else {
                                    Text(notification.content)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                Text(notification.createdAt, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
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
                                        await viewModel.loadMoreNotifications(token: token, serverUrl: serverUrl)
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
                    await viewModel.fetchNotifications(token: token, serverUrl: serverUrl)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationDetailView: View {
    let notification: SnNotification

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(notification.title)
                    .font(.headline)
                
                if !notification.subtitle.isEmpty {
                    Text(notification.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(notification.content)
                    .font(.body)
                
                HStack {
                    Text(notification.createdAt, style: .date)
                    Text("·")
                    Text(notification.createdAt, style: .time)
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                if notification.viewedAt == nil {
                    Text("Unread")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
    }
}
