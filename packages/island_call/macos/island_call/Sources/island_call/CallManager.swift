import Foundation
import LiveKitClient

// Shared between iOS and macOS.
// ponytail: All callers are main-thread (Flutter plugin + Task { @MainActor }),
// @MainActor annotation would cause isolation errors in nonisolated contexts.
final class CallManager: @unchecked Sendable {
    let state = CallState()
    var onStateChanged: (([String: Any]) -> Void)?
    var onParticipantsChanged: (([[String: Any]]) -> Void)?

    private var room: Room?
    private var localParticipant: LocalParticipant?

    // Auth
    private var serverUrl: String?
    private var authToken: String?

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

        // Enable microphone by default (matches Flutter behavior)
        _ = try? await localParticipant?.setMicrophone(enabled: true)

        state.hasJoined = true
        state.isConnected = true
        state.isReconnecting = false
        state.reconnectAttempt = 0
        state.error = nil
        state.startDurationTimer(from: Date())
        emitState()

        #if os(iOS)
        // ponytail: Hardware class removed in LiveKit 2.15.0
        // try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        #endif

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
        // ponytail: Hardware class removed in LiveKit 2.15.0, use AVAudioSession directly if needed
        #if os(iOS)
        // try? AVAudioSession.sharedInstance().overrideOutputAudioPort(target ? .speaker : .none)
        #endif
        emitState()
    }

    func toggleViewMode() {
        state.viewMode = state.viewMode == .grid ? .stage : .grid
        emitState()
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
                audioLevel: lp.audioLevel
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
                audioLevel: rp.audioLevel
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
                let urlString = "\(serverUrl)/passport/accounts/by-username/\(identity)"
                guard let url = URL(string: urlString) else { continue }
                var req = URLRequest(url: url)
                req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                req.timeoutInterval = 10

                do {
                    let (data, _) = try await URLSession.shared.data(for: req)
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let profile = json["profile"] as? [String: Any],
                          let picture = profile["picture"] as? [String: Any],
                          let pictureId = picture["id"] as? String else { continue }

                    let avatarUrl = "\(serverUrl)/drive/files/\(pictureId)"

                    // Update participant with avatar URL
                    if let idx = self.state.participants.firstIndex(where: { $0.id == identity }) {
                        self.state.participants[idx].avatarUrl = avatarUrl
                        self.emitParticipants()
                        self.emitState()
                    }
                } catch {
                    // ponytail: silently skip failed avatar fetches
                }
            }
        }
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
             "avatarUrl": p.avatarUrl as Any]
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
