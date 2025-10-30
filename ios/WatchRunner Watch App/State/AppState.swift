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
            if let token = token, let serverUrl = serverUrl {
                self?.isReady = true
                // Auto-connect WebSocket here
                self?.networkService.connectWebSocket(token: token, serverUrl: serverUrl)
            } else {
                self?.isReady = false
                // Disconnect WebSocket if token or serverUrl become nil
                self?.networkService.disconnectWebSocket()
            }            }
            .store(in: &cancellables)
    }
    
    func requestData() {
        wcService.requestDataFromPhone()
    }
}
