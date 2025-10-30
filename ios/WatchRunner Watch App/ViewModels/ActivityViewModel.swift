//
//  ActivityViewModel.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation
import Combine

// MARK: - View Models

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [SnActivity] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMore = false

    private let networkService = NetworkService()
    let filter: String
    private var isMock = false
    private var hasFetched = false
    private var nextCursor: String?

    init(filter: String, mockActivities: [SnActivity]? = nil) {
        self.filter = filter
        if let mockActivities = mockActivities {
            self.activities = mockActivities
            self.isMock = true
        }
    }

    func fetchActivities(token: String, serverUrl: String) async {
        if isMock || hasFetched { return }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        hasFetched = true
        nextCursor = nil

        do {
            let response = try await networkService.fetchActivities(filter: filter, cursor: nil, token: token, serverUrl: serverUrl)
            self.activities = response.activities
            self.hasMore = response.hasMore
            self.nextCursor = response.nextCursor
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] fetchActivities failed with error: \(error)")
            hasFetched = false
        }

        isLoading = false
    }

    func loadMoreActivities(token: String, serverUrl: String) async {
        guard !isLoadingMore && hasMore && nextCursor != nil else { return }
        isLoadingMore = true

        do {
            let response = try await networkService.fetchActivities(filter: filter, cursor: nextCursor, token: token, serverUrl: serverUrl)
            self.activities.append(contentsOf: response.activities)
            self.hasMore = response.hasMore
            self.nextCursor = response.nextCursor
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] loadMoreActivities failed with error: \(error)")
        }

        isLoadingMore = false
    }
}
