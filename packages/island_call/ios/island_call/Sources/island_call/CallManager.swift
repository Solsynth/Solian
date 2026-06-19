import Foundation
import LiveKitClient
import CallKit
import PushKit
import AVFoundation

final class CallManager: NSObject, @unchecked Sendable {
    let state = CallState()
    var onStateChanged: (([String: Any]) -> Void)?
    var onParticipantsChanged: (([[String: Any]]) -> Void)?

    // CallKit/CallUI callbacks
    var onCallKitCallConnected: (() -> Void)?
    var onCallKitCallEnded: (() -> Void)?

    private var room: Room?
    private var localParticipant: LocalParticipant?

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

    // Reconnection
    private var reconnectAttempts = 0
    private static let maxReconnectAttempts = 10
    private static let baseReconnectDelay: TimeInterval = 1
    private static let maxReconnectDelay: TimeInterval = 30
    private var isReconnecting = false
    private var shouldAutoReconnect = true
    private var isManualDisconnect = false
    private var reconnectTimer: Timer?
    private var healthTimer: Timer?
    private var reconnectGraceTimer: Timer?

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

    func initialize(serverUrl: String, authToken: String) {
        self.serverUrl = serverUrl
        self.authToken = authToken
    }

    // MARK: - Join

    func joinRoom(_ roomId: String) async throws {
        guard let serverUrl, let authToken else {
            throw CallError.notInitialized
        }

        if state.roomId == roomId,
           let room, room.connectionState == .connected {
            return
        }

        if let room {
            isManualDisconnect = true
            await room.disconnect()
            self.room = nil
            localParticipant = nil
            isManualDisconnect = false
        }

        shouldAutoReconnect = true
        reconnectAttempts = 0
        isReconnecting = false
        reconnectGraceTimer?.invalidate()

        let joinInfo = try await fetchJoinToken(serverUrl: serverUrl, token: authToken, roomId: roomId)

        state.roomId = roomId
        state.roomName = joinInfo.roomName
        state.isAdmin = joinInfo.isAdmin
        emitState()

        let newRoom = Room()
        self.room = newRoom

        try await newRoom.connect(
            url: joinInfo.endpoint,
            token: joinInfo.token,
            connectOptions: ConnectOptions(autoSubscribe: true),
            roomOptions: RoomOptions(adaptiveStream: true, dynacast: true)
        )

        localParticipant = newRoom.localParticipant
        newRoom.delegates.add(delegate: self)

        _ = try? await localParticipant?.setMicrophone(enabled: true)

        state.hasJoined = true
        state.isConnected = true
        state.isReconnecting = false
        state.reconnectAttempt = 0
        state.error = nil
        state.startDurationTimer(from: Date()) { [weak self] in
            self?.emitState()
        }
        emitState()

        startHealthMonitor()
        refreshParticipants()
        fetchParticipantAvatars()
    }

    // MARK: - Leave

    func leaveRoom() async {
        shouldAutoReconnect = false
        reconnectGraceTimer?.invalidate()
        reconnectTimer?.invalidate()
        healthTimer?.invalidate()

        isManualDisconnect = true
        if let room { await room.disconnect() }
        room = nil
        localParticipant = nil

        state.reset()
        isManualDisconnect = false
        emitState()
        emitParticipants()
    }

    // MARK: - Controls

    func toggleMic() async {
        guard let lp = localParticipant else { return }
        let target = !state.isMicrophoneEnabled
        state.isMicrophoneEnabled = target
        _ = try? await lp.setMicrophone(enabled: target)
        emitState()
    }

    func toggleCamera() async {
        guard let lp = localParticipant else { return }
        let target = !state.isCameraEnabled
        state.isCameraEnabled = target
        _ = try? await lp.setCamera(enabled: target)
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

    func startCall(handle: String) async {
        let callUUID = UUID()
        let cxHandle = CXHandle(type: .generic, value: handle)
        let action = CXStartCallAction(call: callUUID, handle: cxHandle)
        do {
            try await callController.request(CXTransaction(action: action))
            activeCallUUID = callUUID
            activeRoomId = handle
        } catch {
            // ponytail: failed to start CallKit call
        }
    }

    func endCall() async {
        guard let callUUID = activeCallUUID else { return }
        let action = CXEndCallAction(call: callUUID)
        try? await callController.request(CXTransaction(action: action))
        activeRoomId = nil
    }

    func reportIncomingCall(from callerId: String, callerName: String, roomId: String) {
        let callUUID = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: roomId)
        update.localizedCallerName = callerName
        update.hasVideo = false

        provider.reportNewIncomingCall(with: callUUID, update: update) { [weak self] error in
            guard error == nil else { return }
            self?.activeCallUUID = callUUID
            self?.activeRoomId = roomId
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

    // MARK: - Participant refresh

    private func refreshParticipants() {
        guard let room else { return }
        var list: [CallState.ParticipantInfo] = []

        if let lp = localParticipant {
            list.append(.init(
                id: lp.identity?.stringValue ?? "",
                name: lp.name ?? lp.identity?.stringValue ?? "",
                isSpeaking: lp.isSpeaking,
                isMuted: !lp.isMicrophoneEnabled(),
                isScreenSharing: lp.isScreenShareEnabled(),
                hasVideo: !lp.videoTracks.isEmpty,
                audioLevel: lp.audioLevel,
                avatarAuthToken: authToken
            ))
        }

        for (_, rp) in room.remoteParticipants {
            list.append(.init(
                id: rp.identity?.stringValue ?? "",
                name: rp.name ?? rp.identity?.stringValue ?? "",
                isSpeaking: rp.isSpeaking,
                isMuted: !rp.isMicrophoneEnabled(),
                isScreenSharing: rp.isScreenShareEnabled(),
                hasVideo: !rp.videoTracks.isEmpty,
                audioLevel: rp.audioLevel,
                avatarAuthToken: authToken
            ))
        }

        state.participants = list
        emitParticipants()
    }

    // MARK: - Avatar fetching

    private func fetchParticipantAvatars() {
        guard let serverUrl, let authToken else { return }
        let identities = state.participants.map { $0.id }

        Task {
            for identity in identities {
                guard !identity.isEmpty else { continue }
                guard let encodedIdentity = identity.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                    continue
                }
                let urlString = "\(serverUrl)/passport/accounts/by-username/\(encodedIdentity)"
                guard let url = URL(string: urlString) else { continue }
                var req = URLRequest(url: url)
                req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                req.timeoutInterval = 10

                do {
                    let (data, _) = try await URLSession.shared.data(for: req)
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let profile = json["profile"] as? [String: Any],
                          let picture = profile["picture"] as? [String: Any],
                          let avatarUrl = resolveAvatarUrl(from: picture, serverUrl: serverUrl) else { continue }

                    if let idx = self.state.participants.firstIndex(where: { $0.id == identity }) {
                        self.state.participants[idx].avatarUrl = avatarUrl
                        self.state.participants[idx].avatarAuthToken = authToken
                        self.emitParticipants()
                        self.emitState()
                    }
                } catch {
                    // ponytail: silently skip failed avatar fetches
                }
            }
        }
    }

    private func resolveAvatarUrl(from picture: [String: Any], serverUrl: String) -> String? {
        if let storageUrl = picture["storage_url"] as? String, !storageUrl.isEmpty {
            return storageUrl
        }
        if let directUrl = picture["url"] as? String, !directUrl.isEmpty {
            if directUrl.hasPrefix("http://") || directUrl.hasPrefix("https://") {
                return directUrl
            }
            return "\(serverUrl)\(directUrl.hasPrefix("/") ? "" : "/")\(directUrl)"
        }
        if let pictureId = picture["id"] as? String, !pictureId.isEmpty {
            return "\(serverUrl)/drive/files/\(pictureId)"
        }
        return nil
    }

    // MARK: - Connection state

    func onConnectionStateChanged(_ newState: ConnectionState) {
        let isNowConnected = newState == .connected
        let isNowReconnecting = newState == .reconnecting || newState == .connecting

        state.isConnected = isNowConnected
        state.isReconnecting = isNowReconnecting || isReconnecting
        state.isMicrophoneEnabled = localParticipant?.isMicrophoneEnabled() ?? false
        state.isCameraEnabled = localParticipant?.isCameraEnabled() ?? false

        if isNowConnected {
            reconnectAttempts = 0
            isReconnecting = false
            reconnectGraceTimer?.invalidate()
            state.isReconnecting = false
            state.reconnectAttempt = 0
            emitState()
            return
        }

        if isNowReconnecting || (!isManualDisconnect && newState == .disconnected) {
            scheduleReconnect(force: newState == .disconnected)
        }
        emitState()
    }

    // MARK: - Reconnection

    private func scheduleReconnect(force: Bool) {
        guard !isManualDisconnect, shouldAutoReconnect, state.roomId != nil else { return }

        state.isConnected = false
        state.isReconnecting = true
        state.reconnectAttempt = reconnectAttempts
        emitState()

        if !force {
            guard !(reconnectGraceTimer?.isValid ?? false) else { return }
            reconnectGraceTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in self?.attemptReconnect() }
            }
            return
        }

        reconnectGraceTimer?.invalidate()
        attemptReconnect()
    }

    private func attemptReconnect() {
        guard !isReconnecting, shouldAutoReconnect, let roomId = state.roomId else { return }

        if reconnectAttempts >= Self.maxReconnectAttempts {
            state.isReconnecting = false
            state.error = "Connection lost. Please rejoin the call."
            emitState()
            return
        }

        isReconnecting = true
        reconnectAttempts += 1
        state.isConnected = false
        state.isReconnecting = true
        state.reconnectAttempt = reconnectAttempts
        emitState()

        let delay = min(
            Self.baseReconnectDelay * pow(2, Double(reconnectAttempts - 1)),
            Self.maxReconnectDelay
        )

        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let room = self.room {
                    await room.disconnect()
                }
                self.room = nil
                self.localParticipant = nil

                do {
                    try await self.joinRoom(roomId)
                    self.reconnectAttempts = 0
                    self.isReconnecting = false
                } catch {
                    self.isReconnecting = false
                    self.state.isReconnecting = true
                    self.scheduleReconnect(force: true)
                }
            }
        }
    }

    // MARK: - Health monitor

    private func startHealthMonitor() {
        healthTimer?.invalidate()
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.checkHealth() }
        }
    }

    private func checkHealth() {
        guard let room else { return }
        let cs = room.connectionState
        if cs == .connected || cs == .reconnecting || cs == .connecting { return }
        if !isManualDisconnect { scheduleReconnect(force: true) }
    }

    // MARK: - Emit to Flutter

    private func emitState() {
        onStateChanged?(state.asDict())
    }

    private func emitParticipants() {
        let arr = state.participants.map { p -> [String: Any] in
            ["id": p.id, "name": p.name, "isSpeaking": p.isSpeaking,
             "isMuted": p.isMuted, "hasVideo": p.hasVideo, "audioLevel": p.audioLevel,
             "avatarUrl": p.avatarUrl as Any,
             "avatarAuthToken": p.avatarAuthToken as Any]
        }
        onParticipantsChanged?(arr)
    }

    // MARK: - API helpers

    private func fetchJoinToken(serverUrl: String, token: String, roomId: String) async throws -> JoinInfo {
        let url = URL(string: "\(serverUrl)/messager/chat/realtime/\(roomId)/join")!
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CallError.apiFailed
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        guard let endpoint = json["endpoint"] as? String,
              let joinToken = json["token"] as? String else {
            throw CallError.apiFailed
        }

        return JoinInfo(
            endpoint: endpoint,
            token: joinToken,
            roomName: json["roomName"] as? String,
            isAdmin: json["isAdmin"] as? Bool ?? false
        )
    }
}

// MARK: - RoomDelegate

extension CallManager: RoomDelegate {
    nonisolated func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState, from oldConnectionState: ConnectionState) {
        Task { @MainActor [weak self] in
            self?.onConnectionStateChanged(connectionState)
        }
    }

    nonisolated func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        Task { @MainActor [weak self] in self?.refreshParticipants() }
    }

    nonisolated func room(_ room: Room, participantDidDisconnect participant: RemoteParticipant) {
        Task { @MainActor [weak self] in self?.refreshParticipants() }
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
            do {
                provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
                try await joinRoom(action.handle.value)
                action.fulfill()
                Task { @MainActor in self.onCallKitCallConnected?() }
            } catch {
                action.fail()
                activeCallUUID = nil
                activeRoomId = nil
            }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        Task {
            do {
                guard let roomId = activeRoomId else {
                    action.fail()
                    return
                }
                try await joinRoom(roomId)
                action.fulfill()
                Task { @MainActor in self.onCallKitCallConnected?() }
            } catch {
                action.fail()
                Task { @MainActor in self.state.error = error.localizedDescription }
            }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        Task {
            await leaveRoom()
            action.fulfill()
            activeCallUUID = nil
            activeRoomId = nil
            Task { @MainActor in self.onCallKitCallEnded?() }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        Task {
            if let lp = localParticipant {
                _ = try? await lp.setMicrophone(enabled: !action.isMuted)
                Task { @MainActor in self.state.isMicrophoneEnabled = !action.isMuted }
            }
            action.fulfill()
        }
    }

    func provider(_ provider: CXProvider, didActivate session: AVAudioSession) {
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // ponytail: swallow audio session errors
        }
    }

    func provider(_ provider: CXProvider, didDeactivate session: AVAudioSession) {
        try? session.setActive(false)
    }
}

// MARK: - PKPushRegistryDelegate

extension CallManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        voipToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        voipToken = nil
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        guard type == .voIP else { completion(); return }

        // Backend sends call info nested in "meta"
        let rawPayload = payload.dictionaryPayload as? [String: Any] ?? [:]
        let meta = rawPayload["meta"] as? [String: Any] ?? rawPayload
        let callerId = meta["caller_id"] as? String ?? "Unknown"
        let callerName = meta["caller_name"] as? String ?? "Unknown"
        let roomId = meta["room_id"] as? String ?? ""

        reportIncomingCall(from: callerId, callerName: callerName, roomId: roomId)
        completion()
    }
}

// MARK: - Types

struct JoinInfo {
    let endpoint: String
    let token: String
    let roomName: String?
    let isAdmin: Bool
}

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
