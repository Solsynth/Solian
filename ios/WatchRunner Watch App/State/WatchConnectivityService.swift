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

    private let session: WCSession

    override init() {
        self.session = .default
        super.init()
        print("[watchOS] Activating WCSession")
        self.session.delegate = self
        self.session.activate()
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
            }
            if let serverUrl = message["serverUrl"] as? String {
                self.serverUrl = serverUrl
            }
        }
    }

    func requestDataFromPhone() {
        guard session.isReachable else {
            print("[watchOS] Phone is not reachable")
            return
        }
        
        print("[watchOS] Requesting data from phone")
        session.sendMessage(["request": "data"]) { [weak self] response in
            print("[watchOS] Received reply: \(response)")
            DispatchQueue.main.async {
                if let token = response["token"] as? String {
                    self?.token = token
                }
                if let serverUrl = response["serverUrl"] as? String {
                    self?.serverUrl = serverUrl
                }
            }
        } errorHandler: { error in
            print("[watchOS] sendMessage failed with error: \(error.localizedDescription)")
        }
    }
}
