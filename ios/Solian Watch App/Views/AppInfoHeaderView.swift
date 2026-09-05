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
        HStack(spacing: 10) {
            Image("Logo")
                .resizable()
                .frame(width: 30, height: 30)

            Text("Solian")
                .font(.headline)

            Spacer(minLength: 0)

            // Glanceable connection state: a dot with an accessibility label,
            // not a status sentence. Color is utility, not decoration.
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .accessibilityLabel("Connection: \(webSocketStatusMessage)")
        }
        .padding(.vertical, 4)
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
        case .connected: return L10n.connectionConnected
        case .connecting: return L10n.connectionConnecting
        case .disconnected: return L10n.connectionDisconnected
        case .serverDown: return L10n.connectionServerDown
        case .duplicateDevice: return L10n.connectionDuplicateDevice
        case .error(let msg): return String(format: L10n.connectionError, msg)
        }
    }

    private var statusColor: Color {
        switch webSocketConnectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected, .serverDown, .duplicateDevice, .error:
            return .red
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
