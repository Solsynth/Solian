import Foundation
import SwiftUI

// Shared between iOS and macOS — no UIKit or AppKit imports.
final class CallState: ObservableObject {
    @Published var isConnected = false
    @Published var isReconnecting = false
    @Published var isMicrophoneEnabled = true
    @Published var isCameraEnabled = false
    @Published var isSpeakerphone = true
    @Published var duration: TimeInterval = 0
    @Published var viewMode: ViewMode = .grid
    @Published var participants: [ParticipantInfo] = []
    @Published var error: String?
    @Published var reconnectAttempt = 0
    @Published var roomId: String?
    @Published var roomName: String?
    @Published var isAdmin = false
    @Published var hasJoined = false

    enum ViewMode: String { case grid, stage }

    struct ParticipantInfo: Identifiable, Equatable {
        let id: String          // identity
        let name: String
        var isSpeaking = false
        var isMuted = true
        var isScreenSharing = false
        var hasVideo = false
        var audioLevel: Float = 0
        var avatarUrl: String? = nil
    }

    private var durationTimer: Timer?

    func startDurationTimer(from joinedAt: Date) {
        durationTimer?.invalidate()
        duration = 0
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.duration = Date().timeIntervalSince(joinedAt)
            }
        }
    }

    func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
        duration = 0
    }

    func reset() {
        isConnected = false
        isReconnecting = false
        isMicrophoneEnabled = true
        isCameraEnabled = false
        isSpeakerphone = true
        viewMode = .grid
        participants = []
        error = nil
        reconnectAttempt = 0
        roomId = nil
        roomName = nil
        isAdmin = false
        hasJoined = false
        stopDurationTimer()
    }

    func asDict() -> [String: Any] {
        [
            "isConnected": isConnected,
            "isReconnecting": isReconnecting,
            "isMicrophoneEnabled": isMicrophoneEnabled,
            "isCameraEnabled": isCameraEnabled,
            "isSpeakerphone": isSpeakerphone,
            "duration": duration,
            "viewMode": viewMode.rawValue,
            "reconnectAttempt": reconnectAttempt,
            "error": error as Any,
            "roomId": roomId as Any,
            "roomName": roomName as Any,
            "isAdmin": isAdmin,
            "hasJoined": hasJoined,
            "participantCount": participants.count,
        ]
    }
}

func formatDuration(_ seconds: TimeInterval) -> String {
    let s = Int(seconds)
    let h = s / 3600
    let m = (s % 3600) / 60
    let sec = s % 60
    return String(format: "%02d:%02d:%02d", h, m, sec)
}
