//
//  DataExchange.swift
//  Runner
//
//  Created by LittleSheep on 2025/6/2.
//

import Foundation

private let tokenRefreshSkew: TimeInterval = 30

private struct StoredTokenPair {
    let token: String
    let refreshToken: String?
    let expiresAt: Date?
    let refreshExpiresAt: Date?
}

extension UserDefaults {
    func getFlutterValue<T>(forKey key: String) -> T? {
        let prefixedKey = "flutter.\(key)"
        return self.object(forKey: prefixedKey) as? T
    }

    func getFlutterToken(forKey key: String = "dyn_user_tk") -> String? {
        let prefixedKey = "flutter.\(key)"
        guard let jsonString = self.string(forKey: prefixedKey),
              let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any],
              let token = jsonDict["token"] as? String else {
            return nil
        }
        return token
    }

    func getValidFlutterToken(forKey key: String = "dyn_user_tk") async -> String? {
        guard var tokenPair = getStoredTokenPair(forKey: key) else {
            return nil
        }

        if shouldRefreshToken(tokenPair) {
            tokenPair = await refreshTokenPair(tokenPair, forKey: key) ?? tokenPair
        }

        return tokenPair.token
    }
    
    func getServerUrl(forKey key: String = "app_server_url") -> String {
        return self.getFlutterValue(forKey: key) ?? "https://api.solian.app"
    }

    private func getStoredTokenPair(forKey key: String) -> StoredTokenPair? {
        let prefixedKey = "flutter.\(key)"
        guard let rawValue = self.string(forKey: prefixedKey), !rawValue.isEmpty else {
            return nil
        }

        guard let data = rawValue.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return StoredTokenPair(
                token: rawValue,
                refreshToken: nil,
                expiresAt: decodeJwtExpiry(rawValue),
                refreshExpiresAt: nil
            )
        }

        if let token = jsonObject as? String, !token.isEmpty {
            return StoredTokenPair(
                token: token,
                refreshToken: nil,
                expiresAt: decodeJwtExpiry(token),
                refreshExpiresAt: nil
            )
        }

        guard let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }

        guard let token = (jsonDict["token"] as? String) ?? (jsonDict["access_token"] as? String),
              !token.isEmpty else {
            return nil
        }

        let refreshToken = jsonDict["refresh_token"] as? String
        let now = Date()
        let expiresAt = parseDate(jsonDict["expires_at"])
            ?? parseDuration(jsonDict["expires_in"]).map { now.addingTimeInterval(TimeInterval($0)) }
            ?? decodeJwtExpiry(token)
        let refreshExpiresAt = parseDate(jsonDict["refresh_expires_at"])
            ?? parseDuration(jsonDict["refresh_expires_in"]).map { now.addingTimeInterval(TimeInterval($0)) }
            ?? refreshToken.flatMap(decodeJwtExpiry)

        return StoredTokenPair(
            token: token,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            refreshExpiresAt: refreshExpiresAt
        )
    }

    private func shouldRefreshToken(_ tokenPair: StoredTokenPair) -> Bool {
        guard !isNotExpired(tokenPair.expiresAt) else {
            return false
        }
        guard let refreshToken = tokenPair.refreshToken, !refreshToken.isEmpty else {
            return false
        }
        return isNotExpired(tokenPair.refreshExpiresAt)
    }

    private func refreshTokenPair(
        _ current: StoredTokenPair,
        forKey key: String
    ) async -> StoredTokenPair? {
        guard let refreshToken = current.refreshToken, !refreshToken.isEmpty else {
            return current
        }

        guard let url = URL(string: getServerUrl(forKey: "app_server_url") + "/padlock/auth/token") else {
            return current
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let nextToken = jsonObject["token"] as? String,
                  !nextToken.isEmpty else {
                return current
            }

            let now = Date()
            let nextRefreshToken = (jsonObject["refresh_token"] as? String) ?? current.refreshToken
            let refreshed = StoredTokenPair(
                token: nextToken,
                refreshToken: nextRefreshToken,
                expiresAt: parseDuration(jsonObject["expires_in"]).map { now.addingTimeInterval(TimeInterval($0)) }
                    ?? decodeJwtExpiry(nextToken),
                refreshExpiresAt: parseDuration(jsonObject["refresh_expires_in"]).map { now.addingTimeInterval(TimeInterval($0)) }
                    ?? nextRefreshToken.flatMap(decodeJwtExpiry)
            )

            saveTokenPair(refreshed, forKey: key)
            return refreshed
        } catch {
            print("[iOS] Token refresh failed: \(error.localizedDescription)")
            return current
        }
    }

    private func saveTokenPair(_ tokenPair: StoredTokenPair, forKey key: String) {
        let prefixedKey = "flutter.\(key)"
        var payload: [String: Any] = [
            "token": tokenPair.token
        ]
        if let refreshToken = tokenPair.refreshToken {
            payload["refresh_token"] = refreshToken
        }
        if let expiresAt = tokenPair.expiresAt {
            payload["expires_at"] = ISO8601DateFormatter().string(from: expiresAt)
        }
        if let refreshExpiresAt = tokenPair.refreshExpiresAt {
            payload["refresh_expires_at"] = ISO8601DateFormatter().string(from: refreshExpiresAt)
        }

        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        self.set(jsonString, forKey: prefixedKey)
        self.synchronize()
    }

    private func parseDuration(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let stringValue = value as? String {
            return Int(stringValue)
        }
        return nil
    }

    private func parseDate(_ value: Any?) -> Date? {
        guard let stringValue = value as? String, !stringValue.isEmpty else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: stringValue) ?? ISO8601DateFormatter().date(from: stringValue)
    }

    private func isNotExpired(_ date: Date?) -> Bool {
        guard let date else { return false }
        return date.timeIntervalSinceNow > tokenRefreshSkew
    }

    private func decodeJwtExpiry(_ token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding = payload.count % 4
        if padding > 0 {
            payload += String(repeating: "=", count: 4 - padding)
        }

        guard let data = Data(base64Encoded: payload),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let exp = jsonObject["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: exp)
        }
        if let exp = jsonObject["exp"] as? Int {
            return Date(timeIntervalSince1970: TimeInterval(exp))
        }
        return nil
    }
}
