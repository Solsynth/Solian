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
    @Published var errorMessage: String? = nil
    @Published var requiresSignIn = false

    let networkService = NetworkService()
    let standaloneAuth = StandaloneAuthService.shared

    private var wcService = WatchConnectivityService()
    private var cancellables = Set<AnyCancellable>()
    private var hasAttemptedConnection = false

    init() {
        // If a standalone (device-flow) session exists it wins: the watch is
        // usable with no iPhone nearby.
        if standaloneAuth.hasStoredSession, let url = standaloneAuth.serverUrl {
            token = "" // placeholder; real token fetched via refresh below
            serverUrl = url
            requiresSignIn = false
        } else {
            requiresSignIn = true
        }

        wcService.$token
            .combineLatest(wcService.$serverUrl, wcService.$isFetched, wcService.$errorMessage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (token: String?, serverUrl: String?, isFetched: Bool?, errorMessage: String?) in
                guard let self = self else { return }

                // Phone credentials only fill the gap when there is no
                // standalone session.
                if self.standaloneAuth.hasStoredSession {
                    return
                }

                self.token = token
                self.serverUrl = serverUrl
                self.errorMessage = errorMessage

                if let token = token, let serverUrl = serverUrl, !token.isEmpty, !serverUrl.isEmpty {
                    self.isReady = true
                    self.requiresSignIn = false
                    self.connectOnce(token: token, serverUrl: serverUrl, fromPhone: isFetched == true)
                } else {
                    self.isReady = false
                    self.disconnectIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Standalone session present: obtain a fresh access token and connect.
        if standaloneAuth.hasStoredSession, let url = standaloneAuth.serverUrl {
            Task { [weak self] in
                await self?.activateStandaloneSession(serverUrl: url)
            }
        }
    }

    // MARK: - Standalone session

    func finishStandaloneSignIn(auth: StandaloneAuthService, serverUrl: String) async {
        self.serverUrl = serverUrl
        self.requiresSignIn = false
        // Fetch the profile now to store display name (best effort).
        do {
            let access = try await auth.validAccessToken(serverUrl: serverUrl)
            self.token = access
            let profile = try await networkService.fetchUserProfile(token: access, serverUrl: serverUrl)
            auth.setProfile(name: profile.name, nick: profile.nick)
            self.isReady = true
            self.connectOnce(token: access, serverUrl: serverUrl, fromPhone: false)
        } catch {
            // Token is stored; connection retries on next launch / refresh.
            self.errorMessage = error.localizedDescription
        }
    }

    private func activateStandaloneSession(serverUrl: String) async {
        do {
            let access = try await standaloneAuth.validAccessToken(serverUrl: serverUrl)
            self.token = access
            self.isReady = true
            self.requiresSignIn = false
            self.connectOnce(token: access, serverUrl: serverUrl, fromPhone: false)
            // Warm the account profile for display (best effort).
            if let profile = try? await networkService.fetchUserProfile(token: access, serverUrl: serverUrl) {
                standaloneAuth.setProfile(name: profile.name, nick: profile.nick)
            }
        } catch {
            // Refresh failed (e.g. revoked). Fall back to the phone if paired;
            // otherwise require re-auth.
            self.isReady = false
            if !standaloneAuth.hasStoredSession {
                self.requiresSignIn = true
            }
            self.errorMessage = error.localizedDescription
        }
    }

    func signOutStandalone() {
        standaloneAuth.signOut()
        token = nil
        serverUrl = nil
        isReady = false
        hasAttemptedConnection = false
        networkService.disconnectWebSocket()
        requiresSignIn = true
        // If a phone is paired it can supply credentials again.
        wcService.requestDataFromPhone()
    }

    // MARK: - Connection

    private func connectOnce(token: String, serverUrl: String, fromPhone: Bool) {
        if !hasAttemptedConnection {
            hasAttemptedConnection = true
            print("[AppState] Connecting WebSocket to server: \(serverUrl)")
            networkService.connectWebSocket(token: token, serverUrl: serverUrl)
        }
    }

    private func disconnectIfNeeded() {
        if hasAttemptedConnection {
            hasAttemptedConnection = false
            networkService.disconnectWebSocket()
        }
    }

    func requestData() {
        wcService.requestDataFromPhone()
    }
}
