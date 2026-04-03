import Foundation
import Combine

#if os(watchOS)
import WatchConnectivity

class WatchConnectivityService: NSObject, ObservableObject, WCSessionDelegate {
    @Published var token: String?
    @Published var serverUrl: String?
    @Published var isFetched: Bool?
    @Published var errorMessage: String?

    private let session: WCSession
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "token"
    private let serverUrlKey = "serverUrl"
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 300 // 5 minutes

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

    @objc func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[watchOS] WCSession activation failed with error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "WCSession activation failed: \(error.localizedDescription)"
            }
            return
        }
        print("[watchOS] WCSession activated with state: \(activationState.rawValue)")
        if activationState == .activated {
            requestDataFromPhone()
            startPeriodicSync()
        }
    }

    @objc func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("[watchOS] Received application context: \(applicationContext)")
        DispatchQueue.main.async {
            if let token = applicationContext["token"] as? String {
                self.token = token
                self.userDefaults.set(token, forKey: self.tokenKey)
            }
            if let serverUrl = applicationContext["serverUrl"] as? String {
                self.serverUrl = serverUrl
                self.userDefaults.set(serverUrl, forKey: self.serverUrlKey)
            }
            self.isFetched = true
            self.errorMessage = nil
        }
    }

    @objc func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
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

    private func startPeriodicSync() {
        stopPeriodicSync()
        
        print("[watchOS] Starting periodic sync every \(Int(syncInterval)) seconds")
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            self?.requestDataFromPhone()
        }
    }

    private func stopPeriodicSync() {
        if let timer = syncTimer {
            timer.invalidate()
            syncTimer = nil
            print("[watchOS] Stopped periodic sync")
        }
    }

    func requestDataFromPhone() {
        guard session.activationState == .activated else {
            print("[watchOS] Session not activated yet, state: \(session.activationState.rawValue)")
            DispatchQueue.main.async {
                self.errorMessage = "Session not ready yet"
            }
            return
        }
        
        print("[watchOS] Requesting data from phone")
        session.sendMessage(["request": "data"]) { [weak self] response in
            guard let self = self else { return }
            print("[watchOS] Received reply: \(response)")
            DispatchQueue.main.async {
                self.isFetched = true
                if let token = response["token"] as? String, !token.isEmpty {
                    print("[watchOS] Updating token: \(String(token.prefix(20)))...")
                    self.token = token
                    self.userDefaults.set(token, forKey: self.tokenKey)
                }
                if let serverUrl = response["serverUrl"] as? String, !serverUrl.isEmpty {
                    print("[watchOS] Updating serverUrl: \(serverUrl)")
                    self.serverUrl = serverUrl
                    self.userDefaults.set(serverUrl, forKey: self.serverUrlKey)
                }
                self.errorMessage = nil
            }
        } errorHandler: { error in
            print("[watchOS] sendMessage failed with error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to get data from phone: \(error.localizedDescription)"
            }
        }
    }

    deinit {
        stopPeriodicSync()
    }
}

#else

class WatchConnectivityService: NSObject, ObservableObject {
    @Published var token: String? = nil
    @Published var serverUrl: String? = nil
    @Published var isFetched: Bool? = false
    @Published var errorMessage: String? = nil
    
    override init() {
        super.init()
    }
    
    func requestDataFromPhone() {}
}

#endif