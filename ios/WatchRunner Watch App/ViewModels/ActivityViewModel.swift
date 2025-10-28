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
    @Published var errorMessage: String?

    private let networkService = NetworkService()
    let filter: String
    private var isMock = false
    private var hasFetched = false // Add this

    init(filter: String, mockActivities: [SnActivity]? = nil) {
        self.filter = filter
        if let mockActivities = mockActivities {
            self.activities = mockActivities
            self.isMock = true
        }
    }

    func fetchActivities(token: String, serverUrl: String) async {
        if isMock || hasFetched { return } // Check hasFetched
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        hasFetched = true // Set hasFetched

        do {
            let fetchedActivities = try await networkService.fetchActivities(filter: filter, token: token, serverUrl: serverUrl)
            self.activities = fetchedActivities
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] fetchActivities failed with error: \(error)")
            hasFetched = false // Reset on error
        }

        isLoading = false
    }
}
