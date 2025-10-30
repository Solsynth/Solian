//
//  WatchConnectivityService.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation
import WatchConnectivity
import Combine

// MARK: - Watch Connectivity

class WatchConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    @Published var token: String?
    @Published var serverUrl: String?
    @Published var isFetched: Bool?

    private let session: WCSession
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "token"
    private let serverUrlKey = "serverUrl"

    override init() {
        self.session = .default
        super.init()
        print("[watchOS] Activating WCSession")
        self.session.delegate = self
        self.session.activate()
        
        // Load cached data
        self.token = userDefaults.string(forKey: tokenKey)
        self.serverUrl = userDefaults.string(forKey: serverUrlKey)
        self.isFetched = false
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[watchOS] WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("[watchOS] WCSession activated with state: \(activationState.rawValue)")
        if activationState == .activated {
            requestDataFromPhone()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[watchOS] Received message: \(message)")
        DispatchQueue.main.async {
            if let token = message["token"] as? String {
                self.token = token
                self.userDefaults.set(token, forKey: self.tokenKey)
            }
            if let serverUrl = message["serverUrl"] as? String {
                self.serverUrl = serverUrl
                self.userDefaults.set(serverUrl, forKey: self.serverUrlKey)
            }
        }
    }

    func requestDataFromPhone() {
        if self.isFetched == true {
            print("[watchOS] Skipped fetch from phone due to tried.")
            return
        }
        
        guard session.isReachable else {
            self.isFetched = true
            print("[watchOS] Phone is not reachable")
            return
        }
        
        print("[watchOS] Requesting data from phone")
        session.sendMessage(["request": "data"]) { [weak self] response in
            guard let self = self else { return }
            print("[watchOS] Received reply: \(response)")
            DispatchQueue.main.async {
                self.isFetched = true
                if let token = response["token"] as? String {
                    self.token = token
                    self.userDefaults.set(token, forKey: self.tokenKey)
                }
                if let serverUrl = response["serverUrl"] as? String {
                    self.serverUrl = serverUrl
                    self.userDefaults.set(serverUrl, forKey: self.serverUrlKey)
                }
            }
        } errorHandler: { error in
            print("[watchOS] sendMessage failed with error: \(error.localizedDescription)")
        }
    }
}
