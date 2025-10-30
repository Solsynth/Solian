//
//  AppInfoHeader.swift
//  Runner
//
//  Created by LittleSheep on 2025/10/30.
//

import Combine
import SwiftUI

struct AppInfoHeaderView : View {
    @EnvironmentObject var appState: AppState // Access AppState
    @State private var webSocketConnectionState: WebSocketState = .disconnected // New state for WebSocket status
    @State private var cancellables = Set<AnyCancellable>() // For managing subscriptions

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text("Solian").font(.headline)
                    Text("for Apple Watch").font(.system(size: 11))
                    
                    // Display WebSocket connection status
                    Text(webSocketStatusMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            setupWebSocketListeners()
        }
        .onDisappear {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
    }

    private var webSocketStatusMessage: String {
        switch webSocketConnectionState {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Disconnected"
        case .serverDown: return "Server Down"
        case .duplicateDevice: return "Duplicate Device"
        case .error(let msg): return "Error: \(msg)"
        }
    }

    private func setupWebSocketListeners() {
        appState.networkService.stateStream
            .receive(on: DispatchQueue.main)
            .sink { state in
                webSocketConnectionState = state
            }
            .store(in: &cancellables)
    }
}
