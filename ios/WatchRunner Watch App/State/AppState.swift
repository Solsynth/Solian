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
    private var hasAttemptedConnection = false

    init() {
        wcService.$token.combineLatest(wcService.$serverUrl, wcService.$isFetched)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (token: String?, serverUrl: String?, isFetched: Bool?) in
                guard let self = self else { return }
                
                self.token = token
                self.serverUrl = serverUrl

                if let token = token, let serverUrl = serverUrl, !token.isEmpty, !serverUrl.isEmpty {
                    self.isReady = true
                    // Only connect once when we have valid credentials and tried fetch from phone
                    if !self.hasAttemptedConnection && isFetched == true {
                        self.hasAttemptedConnection = true
                        print("[AppState] Connecting WebSocket to server: \(serverUrl)")
                        self.networkService.connectWebSocket(token: token, serverUrl: serverUrl)
                    }
                } else {
                    self.isReady = false
                    if self.hasAttemptedConnection {
                        self.hasAttemptedConnection = false
                        // Disconnect WebSocket if token or serverUrl become invalid
                        self.networkService.disconnectWebSocket()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func requestData() {
        wcService.requestDataFromPhone()
    }
}
