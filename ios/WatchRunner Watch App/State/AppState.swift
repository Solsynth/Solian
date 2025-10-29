//
//  AppState.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import Combine

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var token: String? = nil
    @Published var serverUrl: String? = nil
    @Published var isReady = false

    let networkService = NetworkService()
    private var wcService = WatchConnectivityService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        wcService.$token.combineLatest(wcService.$serverUrl)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] token, serverUrl in
                self?.token = token
                self?.serverUrl = serverUrl
                if token != nil && serverUrl != nil {
                    self?.isReady = true
                }
            }
            .store(in: &cancellables)
    }
    
    func requestData() {
        wcService.requestDataFromPhone()
    }
}
