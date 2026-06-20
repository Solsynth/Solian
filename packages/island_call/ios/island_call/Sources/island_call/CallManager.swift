import Foundation
import CallKit
import PushKit
import AVFoundation
import Kingfisher

final class CallManager: NSObject, @unchecked Sendable {
    let state = CallState()
    var onStateChanged: (([String: Any]) -> Void)?
    var onParticipantsChanged: (([[String: Any]]) -> Void)?

    // CallKit/CallUI callbacks
    var onCallKitCallConnected: ((String) -> Void)?
    var onCallKitCallEnded: (() -> Void)?
    var onCallKitMuteChanged: ((Bool) -> Void)?
    var onCallKitHoldChanged: ((Bool) -> Void)?
    var onCallKitAudioSessionActivated: (() -> Void)?
    var onCallKitAudioSessionDeactivated: (() -> Void)?
    
    // Pending answer action (fulfilled when Flutter connects)
    private var pendingAnswerAction: CXAnswerCallAction?

    // Auth
    private var serverUrl: String?
    private var authToken: String?

    // CallKit
    private let callController = CXCallController()
    private let provider: CXProvider

    // PushKit
    private let pushRegistry = PKPushRegistry(queue: nil)

    // CallKit state
    var activeCallUUID: UUID? {
        didSet {
            Task { @MainActor [weak self] in
                self?.state.activeCallUuid = self?.activeCallUUID?.uuidString
            }
        }
    }
    var activeRoomId: String?
    var voipToken: String?

    // MARK: - Initialize

    override init() {
        let config = CXProviderConfiguration()
        config.supportedHandleTypes = [.generic]
        config.maximumCallsPerCallGroup = 1
        config.maximumCallGroups = 1
        config.supportsVideo = false
        provider = CXProvider(configuration: config)

        super.init()

        provider.setDelegate(self, queue: nil)
        pushRegistry.desiredPushTypes = [.voIP]
        pushRegistry.delegate = self
    }

    private let appGroup = "group.solsynth.solian"
    
    func initialize(serverUrl: String, authToken: String) {
        self.serverUrl = serverUrl
        self.authToken = authToken
        
        // Persist for VoIP push when app is terminated
        if let shared = UserDefaults(suiteName: appGroup) {
            shared.set(serverUrl, forKey: "island_call.serverUrl")
            shared.set(authToken, forKey: "island_call.authToken")
        }
    }
    
    private func loadPersistedCredentials() {
        guard serverUrl == nil || authToken == nil else { return }
        if let shared = UserDefaults(suiteName: appGroup) {
            if serverUrl == nil { serverUrl = shared.string(forKey: "island_call.serverUrl") }
            if authToken == nil { authToken = shared.string(forKey: "island_call.authToken") }
        }
    }

    // MARK: - Controls

    func toggleMic() async {
        state.isMicrophoneEnabled = !state.isMicrophoneEnabled
        emitState()
    }

    func toggleCamera() async {
        state.isCameraEnabled = !state.isCameraEnabled
        emitState()
    }

    func toggleSpeaker() async {
        let target = !state.isSpeakerphone
        state.isSpeakerphone = target
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(target ? .speaker : .none)
        emitState()
    }

    func toggleViewMode() {
        state.viewMode = state.viewMode == .grid ? .stage : .grid
        emitState()
    }

    // MARK: - CallKit

    func startCall(handle: String, isVideo: Bool = false) async {
        let callUUID = UUID()
        let cxHandle = CXHandle(type: .generic, value: handle)
        let action = CXStartCallAction(call: callUUID, handle: cxHandle)
        action.isVideo = isVideo
        do {
            try await callController.request(CXTransaction(action: action))
            activeCallUUID = callUUID
            activeRoomId = handle
        } catch {
            print("[CallKit] Failed to start call: \(error)")
        }
    }

    func endCall() async {
        guard let callUUID = activeCallUUID else { return }
        let action = CXEndCallAction(call: callUUID)
        try? await callController.request(CXTransaction(action: action))
        activeRoomId = nil
    }
    
    /// Report call ended with reason (remote ended, failed, etc.)
    func reportCallEnded(reason: CXCallEndedReason) {
        guard let callUUID = activeCallUUID else { return }
        provider.reportCall(with: callUUID, endedAt: Date(), reason: reason)
        activeCallUUID = nil
        activeRoomId = nil
        print("[CallKit] Call reported ended with reason: \(reason.rawValue)")
    }
    
    /// Report connection failed
    func reportConnectionFailed() {
        reportCallEnded(reason: .failed)
    }
    
    /// Report remote party ended the call
    func reportRemoteEnded() {
        reportCallEnded(reason: .remoteEnded)
    }

    func reportIncomingCall(from callerId: String, callerName: String, roomId: String, completion: (() -> Void)? = nil) {
        let callUUID = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: roomId)
        update.localizedCallerName = callerName
        update.hasVideo = false

        print("[CallKit] Reporting incoming call with UUID: \(callUUID)")
        
        provider.reportNewIncomingCall(with: callUUID, update: update) { [weak self] error in
            if let error {
                print("[CallKit] Failed to report incoming call: \(error)")
            } else {
                print("[CallKit] Incoming call reported successfully")
                self?.activeCallUUID = callUUID
                self?.activeRoomId = roomId
            }
            completion?()
        }
    }

    // MARK: - Invite

    func inviteToCall(roomId: String, targetAccountId: String) async throws {
        guard let serverUrl, let authToken else {
            throw CallError.notInitialized
        }

        let urlString = "\(serverUrl)/messager/chat/realtime/\(roomId)/invite/\(targetAccountId)"
        guard let url = URL(string: urlString) else {
            throw CallError.apiFailed
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 10

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CallError.apiFailed
        }
    }

    // MARK: - Emit to Flutter

    private func emitState() {
        onStateChanged?(state.asDict())
    }
}

// MARK: - CXProviderDelegate

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCallUUID = nil
        activeRoomId = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        Task {
            // Report outgoing call as connected immediately
            provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
            activeCallUUID = action.callUUID
            activeRoomId = action.handle.value
            action.fulfill()
            Task { @MainActor in self.onCallKitCallConnected?(action.handle.value) }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let roomId = activeRoomId else {
            print("[CallKit] Answer failed: no activeRoomId")
            action.fail()
            return
        }
        print("[CallKit] Answering call for room: \(roomId) - waiting for Flutter to connect")
        // Store the action - will be fulfilled when Flutter reports connection
        pendingAnswerAction = action
        Task { @MainActor in self.onCallKitCallConnected?(roomId) }
    }
    
    /// Called by Flutter when the LiveKit connection is established
    func fulfillPendingAnswer() {
        guard let action = pendingAnswerAction else { return }
        print("[CallKit] Fulfilling pending answer action")
        action.fulfill()
        pendingAnswerAction = nil
    }
    
    /// Called by Flutter when connection fails
    func failPendingAnswer() {
        guard let action = pendingAnswerAction else { return }
        print("[CallKit] Failing pending answer action")
        action.fail()
        pendingAnswerAction = nil
        reportConnectionFailed()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        activeCallUUID = nil
        activeRoomId = nil
        Task { @MainActor in self.onCallKitCallEnded?() }
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        state.isMicrophoneEnabled = !action.isMuted
        emitState()
        Task { @MainActor in self.onCallKitMuteChanged?(action.isMuted) }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // CallKit hold is not used for our calls, just fulfill
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate session: AVAudioSession) {
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.mixWithOthers])
            try session.setActive(true)
            Task { @MainActor in self.onCallKitAudioSessionActivated?() }
        } catch {
            // ponytail: swallow audio session errors
        }
    }

    func provider(_ provider: CXProvider, didDeactivate session: AVAudioSession) {
        try? session.setActive(false)
        Task { @MainActor in self.onCallKitAudioSessionDeactivated?() }
    }
}

// MARK: - PKPushRegistryDelegate

extension CallManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        voipToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("[PushKit] VoIP token updated: \(voipToken ?? "nil")")
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        voipToken = nil
        print("[PushKit] VoIP token invalidated")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        guard type == .voIP else { completion(); return }

        print("[PushKit] VoIP push received: \(payload.dictionaryPayload)")
        
        // Load persisted credentials for when app is terminated
        loadPersistedCredentials()
        print("[PushKit] Credentials loaded - serverUrl: \(serverUrl ?? "nil"), authToken: \(authToken != nil ? "exists" : "nil")")
        
        // Backend sends call info nested in "meta"
        let rawPayload = payload.dictionaryPayload as? [String: Any] ?? [:]
        let meta = rawPayload["meta"] as? [String: Any] ?? rawPayload
        let callerId = meta["caller_id"] as? String ?? "Unknown"
        let callerName = meta["caller_name"] as? String ?? "Unknown"
        let roomId = meta["room_id"] as? String ?? ""
        let pfpIdentifier = meta["pfp"] as? String

        print("[PushKit] Reporting incoming call - callerId: \(callerId), callerName: \(callerName), roomId: \(roomId), pfp: \(pfpIdentifier ?? "nil")")
        
        // Download avatar if available
        Task { [weak self] in
            if let pfpId = pfpIdentifier, let urlStr = self?.resolveAvatarUrl(for: pfpId), let url = URL(string: urlStr) {
                self?.state.callerAvatarUrl = urlStr
                print("[PushKit] Avatar URL resolved: \(urlStr)")
                
                // Pre-download the image for later use
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(_):
                        print("[PushKit] Avatar image downloaded successfully")
                    case .failure(let error):
                        print("[PushKit] Avatar download failed: \(error)")
                    }
                }
            }
            
            // ponytail: Wait for CXProvider to be ready after app launch from terminated state
            // 2 seconds is usually enough; if it fails, the second push will work
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self?.reportIncomingCall(from: callerId, callerName: callerName, roomId: roomId, completion: completion)
        }
    }
    
    // MARK: - Avatar URL Resolution
    
    private func resolveAvatarUrl(for identifier: String) -> String? {
        guard let serverUrl else { return nil }
        
        // If it's already a full URL
        if identifier.hasPrefix("http://") || identifier.hasPrefix("https://") {
            return identifier
        }
        
        // Otherwise treat as storage ID
        return "\(serverUrl)/drive/files/\(identifier)"
    }
}

// MARK: - Types

enum CallError: LocalizedError {
    case notInitialized
    case apiFailed

    var errorDescription: String? {
        switch self {
        case .notInitialized: return "Call not initialized. Call initialize() first."
        case .apiFailed: return "Failed to join call. Server returned an error."
        }
    }
}
