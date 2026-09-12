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
    /// App-wide singleton. Owned by the root; created once via `shared`.
    static let shared = AppState()

    @Published var token: String? = nil
    @Published var serverUrl: String? = nil
    @Published var isReady = false
    @Published var errorMessage: String? = nil
    @Published var requiresSignIn = false
    /// The current user's account id, resolved from the profile once signed in.
    /// Used to distinguish own vs other chat messages.
    @Published var currentAccountId: String?

    let networkService = NetworkService()
    let standaloneAuth = StandaloneAuthService.shared

    private var hasAttemptedConnection = false

    init() {
        // Keep the published copy in step with the session. Views hand
        // `appState.token` to every API call, and `ImageLoader` / `StickerImage`
        // read it directly, so a token minted at launch would go stale on screen
        // the moment the transport refreshed past it.
        standaloneAuth.onAccessTokenChanged = { [weak self] token in
            self?.token = token
        }
        // A revoked session must land on the sign-in flow rather than 401
        // every call forever.
        networkService.onSessionExpired = { [weak self] in
            Task { @MainActor in self?.handleExpiredSession() }
        }
        // The watch authenticates entirely on its own through the OAuth device
        // flow (see SignInView / StandaloneAuthService). It never borrows
        // credentials from the paired iPhone, so a stored standalone session is
        // the only credential source.
        if standaloneAuth.hasStoredSession, let url = standaloneAuth.serverUrl {
            serverUrl = url
            requiresSignIn = false
            // The stored access token is refreshed lazily; resolving it is
            // async, so views that need `token` wait for it.
            Task { [weak self] in
                await self?.activateStandaloneSession(serverUrl: url)
            }
        } else {
            requiresSignIn = true
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
            self.currentAccountId = profile.id
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
                self.currentAccountId = profile.id
            }
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch let error as StandaloneAuthError where error.isTerminalSession {
            // The stored refresh token is gone or the server rejected it
            // (revoked/expired): drop the session and require a fresh
            // device-flow sign-in rather than leaving a half-authenticated
            // app with no usable token.
            standaloneAuth.signOut()
            token = nil
            self.serverUrl = nil
            requiresSignIn = true
            errorMessage = error.localizedDescription
        } catch let error as StandaloneAuthError {
            // Keychain briefly unavailable (device still locked) or a
            // server-side hiccup: keep the stored session so the next
            // launch or reconnect can use it.
            isReady = false
            errorMessage = error.localizedDescription
        } catch {
            // Transient failure (e.g. network): keep the session for retry on
            // the next launch, but don't pretend to be signed in.
            isReady = false
            errorMessage = error.localizedDescription
        }
    }

    /// The stored session can no longer be refreshed — the refresh token is
    /// gone or the server rejected it, e.g. the session was revoked from
    /// another device's session list. Matches what `activateStandaloneSession`
    /// does on the same failure at launch: drop the credentials and require a
    /// fresh sign-in, keeping the local cache so the same account finds its
    /// chats again on the way back in.
    private func handleExpiredSession() {
        guard !requiresSignIn else { return }
        print("[AppState] Stored session is no longer refreshable; requiring sign-in.")
        standaloneAuth.signOut()
        token = nil
        serverUrl = nil
        isReady = false
        hasAttemptedConnection = false
        networkService.disconnectWebSocket()
        requiresSignIn = true
    }

    /// Signs the watch out. Mirrors the phone app's logout: end the session
    /// server-side (best effort), then drop every trace of the account locally
    /// so the next sign-in starts from a clean slate.
    func signOutStandalone() {
        revokeSessionOnServer()
        purgeLocalData()
        standaloneAuth.signOut()
        token = nil
        serverUrl = nil
        isReady = false
        hasAttemptedConnection = false
        networkService.disconnectWebSocket()
        requiresSignIn = true
    }

    /// Ends this device's session server-side. Fire-and-forget: signing out must
    /// not block on the network, and a failure only means the session has to be
    /// revoked from another device.
    private func revokeSessionOnServer() {
        guard let token, let serverUrl else { return }
        Task {
            try? await networkService.revokeCurrentSession(token: token, serverUrl: serverUrl)
        }
    }

    /// Every piece of locally stored account state: the SwiftData chat cache,
    /// the in-memory summary/sticker stores, and the image cache.
    ///
    /// Keeps the session, so it doubles as the user-facing "clear local data"
    /// reset for a wedged client — stale cached chats or a broken image cache
    /// shouldn't cost a re-login. `signOutStandalone()` calls it too, then
    /// clears the credentials on top.
    func purgeLocalData() {
        ChatCache.shared.clear()
        ChatSummaryStore.shared.clear()
        StickerStore.shared.clear()
        ImageLoader.clearCache()
    }

    // MARK: - Connection

    private func connectOnce(token: String, serverUrl: String, fromPhone: Bool) {
        if !hasAttemptedConnection {
            hasAttemptedConnection = true
            print("[AppState] Connecting WebSocket to server: \(serverUrl)")
            networkService.connectWebSocket(token: token, serverUrl: serverUrl)
        }
    }
}
