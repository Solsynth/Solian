//
//  Networking.swift
//  SolianWidgetExtensionExtension
//
//  Created by LittleSheep on 2026/1/4.
//

import Foundation

enum RemoteError: Error {
    case missingCredentials
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
}

extension RemoteError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Please open the app to sign in."
        case .invalidURL:
            return "Invalid server configuration."
        case .invalidResponse:
            return "Server returned an invalid response."
        case .httpError(let code):
            return "Server error (\(code))."
        case .decodingError:
            return "Failed to read server data."
        }
    }
}

struct TokenData: Codable {
    let token: String
}

class WidgetNetworkService {
    private let appGroup = "group.solsynth.solian"
    private let tokenKey = "flutter.dyn_user_tk"
    private let urlKey = "flutter.app_server_url"
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }
    
    var token: String? {
        guard let tokenString = userDefaults?.string(forKey: tokenKey) else {
            return nil
        }
        
        guard let data = tokenString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let tokenData = try JSONDecoder().decode(TokenData.self, from: data)
            return tokenData.token
        } catch {
            print("[WidgetKit] Failed to decode token: \(error)")
            return nil
        }
    }
    
    var baseURL: String {
        return userDefaults?.string(forKey: urlKey) ?? "https://api.solian.app"
    }
    
    func makeRequest<T: Codable>(
        path: String,
        method: String = "GET",
        headers: [String: String] = [:]
    ) async throws -> T? {
        guard let token = token else {
            throw RemoteError.missingCredentials
        }
        
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw RemoteError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.timeoutInterval = 10.0
        
        print("[WidgetKit] [Network] Requesting: \(baseURL)\(path)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteError.invalidResponse
        }
        
        print("[WidgetKit] [Network] Status: \(httpResponse.statusCode), Data length: \(data.count)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[WidgetKit] [Network] Response: \(jsonString.prefix(500))")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(T.self, from: data)
                print("[WidgetKit] [Network] Successfully decoded response")
                return result
            } catch {
                print("[WidgetKit] [Network] Decoding error: \(error.localizedDescription)")
                print("[WidgetKit] [Network] Expected type: \(String(describing: T.self))")
                throw RemoteError.decodingError
            }
        case 404:
            print("[WidgetKit] [Network] Resource not found (404)")
            return nil
        default:
            print("[WidgetKit] [Network] HTTP Error: \(httpResponse.statusCode)")
            throw RemoteError.httpError(httpResponse.statusCode)
        }
    }
}
