//
//  StandaloneAuthService.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  Lets the watch sign in on its own (no iPhone required) using the OAuth
//  2.0 device authorization flow against Stargate:
//
//    POST {server}/stargate/auth/open/device/code     (form: client_id, scope)
//      -> { device_code, user_code, verification_uri, expires_in, interval }
//    POST {server}/stargate/auth/open/token           (poll)
//      grant_type=urn:ietf:params:oauth:grant-type:device_code
//      -> 200 { access_token, refresh_token, expires_in, … } on approval
//      -> 400 { error: authorization_pending | slow_down | expired_token |
//                       access_denied } while pending / terminal
//    POST {server}/stargate/auth/open/token           (refresh)
//      grant_type=refresh_token -> { access_token, refresh_token, … }
//
// The token pair is kept in the Keychain and shared with the main app's
// serverUrl/refresh conventions so pairing remains an optional extra.
//

import Foundation
import Security
import Combine

enum StandaloneAuthError: LocalizedError {
    case invalidServerUrl
    case invalidDeviceResponse
    case missingRefreshToken
    case keychainError(OSStatus)
    case polling(DevicePollError)

    enum DevicePollError: String {
        case authorizationPending
        case slowDown
        case accessDenied
        case expiredToken
        case invalidGrant
        case other
    }

    var errorDescription: String? {
        switch self {
        case .invalidServerUrl: return "The server URL is invalid."
        case .invalidDeviceResponse: return "The server returned an unexpected device code response."
        case .missingRefreshToken: return "No refresh token is stored. Please sign in again."
        case .keychainError(let status): return "Could not save the session securely (\(status))."
        case .polling(let reason):
            switch reason {
            case .accessDenied: return "Sign-in was declined."
            case .expiredToken: return "The sign-in code expired. Please try again."
            case .authorizationPending: return "Waiting for approval…"
            case .slowDown: return "Slow down."
            case .invalidGrant: return "The sign-in request is no longer valid."
            case .other: return "Sign-in could not be completed."
            }
        }
    }
}

/// A stored standalone session.
struct StandaloneSession: Codable {
    let serverUrl: String
    let refreshToken: String
    let accountName: String?
    let accountNick: String?
}

@MainActor
final class StandaloneAuthService: ObservableObject {
    /// Shared instance so app state, sign-in view and reconnect logic all
    /// operate on the same session cache.
    static let shared = StandaloneAuthService()

    @Published private(set) var isSignedIn = false
    @Published private(set) var accountName: String?
    @Published private(set) var accountNick: String?

    /// The OIDC client this app authenticates as. Registered server-side with
    /// slug `solian-on-watch`, `isPublicClient = true` (no secret needed —
    /// the device code itself is the credential) and `allowedScopes = ["*"]`
    /// (server does exact-match validation, so `*` is requested verbatim).
    /// Overridable via the `SOLIAN_WATCH_CLIENT_ID` Info.plist key.
    static let clientId: String = {
        Bundle.main.object(forInfoDictionaryKey: "SOLIAN_WATCH_CLIENT_ID") as? String
            ?? "solian-on-watch"
    }()

    private static let serverKey = "solian.watch.serverUrl"
    private static let sessionKey = "solian.watch.standaloneSession"
    private static let accessTokenKey = "solian.watch.accessToken"
    private static let accessExpiryKey = "solian.watch.accessExpiry"
    private static let accountNameKey = "solian.watch.accountName"
    private static let accountNickKey = "solian.watch.accountNick"
    private static let defaults = UserDefaults.standard

    private var accessToken: String?
    private var accessExpiry: Date?
    private let session = URLSession(configuration: .ephemeral)
    private let decoder = JSONDecoder()

    init() {
        loadStoredSession()
    }

    // MARK: - Session state

    var hasStoredSession: Bool {
        Self.defaults.string(forKey: Self.sessionKey) != nil
    }

    var serverUrl: String? {
        Self.defaults.string(forKey: Self.serverKey)
    }

    /// A usable bearer token, refreshing (and persisting) if near expiry.
    func validAccessToken(serverUrl: String) async throws -> String {
        if let accessToken = accessToken, let expiry = accessExpiry,
           expiry.timeIntervalSinceNow > 60 {
            return accessToken
        }
        guard let refresh = Self.defaults.string(forKey: Self.sessionKey) else {
            throw StandaloneAuthError.missingRefreshToken
        }
        let pair = try await refreshTokens(refresh: refresh, serverUrl: serverUrl)
        try store(pair: pair, serverUrl: serverUrl)
        return pair.accessToken
    }

    // MARK: - Sign-in (device flow)

    struct DeviceCode {
        let deviceCode: String
        let userCode: String
        let verificationUri: String
        let expiresIn: Int
        let interval: Int
    }

    /// POST /stargate/auth/open/device/code
    func startDeviceFlow(serverUrl: String, scope: String = "*") async throws -> DeviceCode {
        guard let baseURL = URL(string: serverUrl) else {
            throw StandaloneAuthError.invalidServerUrl
        }
        let url = baseURL.appendingPathComponent("/stargate/auth/open/device/code")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("SolianWatch/1.0 (standalone)", forHTTPHeaderField: "User-Agent")
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "client_id", value: Self.clientId),
            URLQueryItem(name: "scope", value: scope),
        ]
        request.httpBody = body.query?.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw StandaloneAuthError.invalidDeviceResponse
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let deviceCode = json["device_code"] as? String,
              let userCode = json["user_code"] as? String,
              let verificationUri = json["verification_uri"] as? String else {
            throw StandaloneAuthError.invalidDeviceResponse
        }
        return DeviceCode(
            deviceCode: deviceCode,
            userCode: userCode,
            verificationUri: verificationUri,
            expiresIn: (json["expires_in"] as? Int) ?? 600,
            interval: (json["interval"] as? Int) ?? 5
        )
    }

    /// Polls the token endpoint until the user approves on another device.
    func pollForToken(deviceCode: String, interval: Int, serverUrl: String) async throws -> TokenPair {
        let deadline = Date().addingTimeInterval(TimeInterval(10 * 60))
        var currentInterval = max(interval, 1)
        while Date() < deadline {
            try? await Task.sleep(nanoseconds: UInt64(currentInterval) * 1_000_000_000)
            do {
                let pair = try await exchangeDeviceCode(deviceCode: deviceCode, serverUrl: serverUrl)
                try store(pair: pair, serverUrl: serverUrl)
                return pair
            } catch StandaloneAuthError.polling(let reason) {
                switch reason {
                case .authorizationPending:
                    continue
                case .slowDown:
                    currentInterval += 5
                    continue
                case .accessDenied, .expiredToken, .invalidGrant, .other:
                    throw StandaloneAuthError.polling(reason)
                }
            }
        }
        throw StandaloneAuthError.polling(.expiredToken)
    }

    /// POST /stargate/auth/open/token — device_code grant.
    func exchangeDeviceCode(deviceCode: String, serverUrl: String) async throws -> TokenPair {
        let body: [String: String] = [
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
            "client_id": Self.clientId,
            "device_code": deviceCode,
        ]
        return try await postToken(body: body, serverUrl: serverUrl)
    }

    /// POST /stargate/auth/open/token — refresh grant.
    func refreshTokens(refresh: String, serverUrl: String) async throws -> TokenPair {
        let body: [String: String] = [
            "grant_type": "refresh_token",
            "client_id": Self.clientId,
            "refresh_token": refresh,
        ]
        return try await postToken(body: body, serverUrl: serverUrl)
    }

    // MARK: - Token plumbing

    struct TokenPair {
        let accessToken: String
        let refreshToken: String?
        let expiresIn: Int
    }

    private func postToken(body: [String: String], serverUrl: String) async throws -> TokenPair {
        guard let baseURL = URL(string: serverUrl) else {
            throw StandaloneAuthError.invalidServerUrl
        }
        let url = baseURL.appendingPathComponent("/stargate/auth/open/token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("SolianWatch/1.0 (standalone)", forHTTPHeaderField: "User-Agent")
        var components = URLComponents()
        components.queryItems = body.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.httpBody = components.query?.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if http.statusCode == 400, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["error"] as? String {
            throw StandaloneAuthError.polling(pollError(error))
        }
        guard (200...299).contains(http.statusCode),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let access = json["access_token"] as? String else {
            throw StandaloneAuthError.polling(.other)
        }
        return TokenPair(
            accessToken: access,
            refreshToken: json["refresh_token"] as? String,
            expiresIn: (json["expires_in"] as? Int) ?? 300
        )
    }

    private func pollError(_ raw: String) -> StandaloneAuthError.DevicePollError {
        switch raw.lowercased() {
        case "authorization_pending": return .authorizationPending
        case "slow_down": return .slowDown
        case "access_denied": return .accessDenied
        case "expired_token": return .expiredToken
        case "invalid_grant": return .invalidGrant
        default: return .other
        }
    }

    // MARK: - Persistence

    private func store(pair: TokenPair, serverUrl: String) throws {
        accessToken = pair.accessToken
        accessExpiry = Date().addingTimeInterval(TimeInterval(pair.expiresIn))
        Self.defaults.set(serverUrl, forKey: Self.serverKey)
        if let refresh = pair.refreshToken {
            try writeKeychain(refresh, account: Self.sessionKey)
        }
    }

    private func loadStoredSession() {
        guard let server = Self.defaults.string(forKey: Self.serverKey),
              let refresh = try? readKeychain(account: Self.sessionKey) else {
            return
        }
        isSignedIn = true
        accountName = Self.defaults.string(forKey: Self.accountNameKey)
        accountNick = Self.defaults.string(forKey: Self.accountNickKey)
        // Access token is refreshed lazily on first use.
        _ = server
        _ = refresh
    }

    func setProfile(name: String?, nick: String?) {
        accountName = name
        accountNick = nick
        Self.defaults.set(name, forKey: Self.accountNameKey)
        Self.defaults.set(nick, forKey: Self.accountNickKey)
    }

    func signOut() {
        isSignedIn = false
        accountName = nil
        accountNick = nil
        accessToken = nil
        accessExpiry = nil
        Self.defaults.removeObject(forKey: Self.serverKey)
        Self.defaults.removeObject(forKey: Self.accountNameKey)
        Self.defaults.removeObject(forKey: Self.accountNickKey)
        Self.defaults.removeObject(forKey: Self.accessTokenKey)
        Self.defaults.removeObject(forKey: Self.accessExpiryKey)
        try? deleteKeychain(account: Self.sessionKey)
    }

    private func writeKeychain(_ value: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "dev.solsynth.solian.watchkitapp",
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(value.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw StandaloneAuthError.keychainError(status)
        }
    }

    private func readKeychain(account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "dev.solsynth.solian.watchkitapp",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw StandaloneAuthError.keychainError(status)
        }
        return String(data: data, encoding: .utf8)
    }

    private func deleteKeychain(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "dev.solsynth.solian.watchkitapp",
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StandaloneAuthError.keychainError(status)
        }
    }
}
