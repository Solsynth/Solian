import SwiftUI
import Kingfisher
import UIKit
import LiveKitClient

// MARK: - Design tokens (shared with macOS via same values)

private enum CallDesign {
    static let bg = Color(red: 0.055, green: 0.067, blue: 0.09)
    static let surface = Color(red: 0.082, green: 0.094, blue: 0.114)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textMuted = Color.white.opacity(0.35)
    static let green = Color(red: 0.25, green: 0.81, blue: 0.56)
    static let red = Color(red: 0.90, green: 0.24, blue: 0.24)
    static let titleFont = Font.system(size: 15, weight: .semibold)
    static let bodyFont = Font.system(size: 12, weight: .regular)
    static let captionFont = Font.system(size: 11, weight: .medium)
    static let monoFont = Font.system(size: 12, design: .monospaced)
}

// MARK: - Expanded Call View (iOS sheet)

struct CallExpandedView: View {
    @ObservedObject var state: CallState
    var onToggleMic: () -> Void
    var onToggleCamera: () -> Void
    var onToggleSpeaker: () -> Void
    var onToggleViewMode: () -> Void
    var onLeave: () -> Void

    @State private var controlsVisible = true

    private var allVoiceOnly: Bool {
        !state.participants.contains { $0.hasVideo }
    }

    var body: some View {
        ZStack {
            CallDesign.bg.ignoresSafeArea()

            if let error = state.error {
                ErrorStateView(message: error)
            } else if state.participants.isEmpty {
                WaitingStateView(isReconnecting: state.isReconnecting)
            } else {
                mainContent
            }

            VStack {
                if controlsVisible { headerBar }
                Spacer()
                if controlsVisible { controlsBar }
            }
        }
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { controlsVisible.toggle() } }
    }

    // MARK: - Main content

    @ViewBuilder
    private var mainContent: some View {
        if allVoiceOnly {
            voiceChannelView
        } else if state.viewMode == .stage {
            stageView
        } else {
            videoGridView
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "phone.connection.fill")
                .font(.system(size: 12))
                .foregroundColor(CallDesign.green)

            Text(state.roomName ?? "Voice Channel")
                .font(CallDesign.titleFont)
                .foregroundColor(CallDesign.text)

            HStack(spacing: 4) {
                Circle()
                    .fill(state.isConnected ? CallDesign.green : CallDesign.textMuted)
                    .frame(width: 5, height: 5)
                Text(state.isConnected ? formatDuration(state.duration) : state.isReconnecting ? "Reconnecting" : "Connecting")
                    .font(CallDesign.monoFont)
                    .foregroundColor(CallDesign.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 9))
                Text("\(state.participants.count)")
                    .font(CallDesign.captionFont)
            }
            .foregroundColor(CallDesign.textMuted)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(CallDesign.surface)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            LinearGradient(colors: [CallDesign.bg.opacity(0.95), CallDesign.bg.opacity(0)], startPoint: .top, endPoint: .bottom)
        )
    }

    // MARK: - Voice channel (Discord-style)

    private var voiceChannelView: some View {
        GeometryReader { geo in
            let avatarSize: CGFloat = geo.size.width > 400 ? 84 : 64
            let spacing: CGFloat = geo.size.width > 400 ? 28 : 20

            ScrollView(.vertical, showsIndicators: false) {
                let columns = max(1, Int((geo.size.width - 32) / (avatarSize + spacing + 16)))
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(avatarSize + 16), spacing: spacing), count: columns),
                    spacing: spacing + 4
                ) {
                    ForEach(state.participants) { p in
                        VoiceParticipantView(participant: p, size: avatarSize)
                    }
                }
                .padding(.horizontal, max(16, (geo.size.width - CGFloat(columns) * (avatarSize + 16 + spacing)) / 2))
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, minHeight: geo.size.height - 140)
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Video grid

    private var videoGridView: some View {
        let count = state.participants.count
        let columns: Int = switch count {
        case ...1: 1
        case ...4: 2
        case ...9: 3
        default: 4
        }

        return ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(state.participants) { p in
                    ParticipantTileView(participant: p, large: false)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 56)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Stage

    private var stageView: some View {
        let participants = state.participants
        let focused = participants.first(where: { $0.isSpeaking }) ?? participants.first!
        let strip = participants.filter { $0.id != focused.id }

        return VStack(spacing: 0) {
            if !strip.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(strip) { p in
                            ParticipantTileView(participant: p, large: false)
                                .frame(width: 160)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(height: 108)
                .padding(.top, 56)
            }

            ParticipantTileView(participant: focused, large: true)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Controls bar (iOS, Discord-style pills)

    private var controlsBar: some View {
        HStack(spacing: 6) {
            controlPill(
                icon: state.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill",
                isActive: state.isMicrophoneEnabled,
                activeColor: CallDesign.surface,
                inactiveColor: CallDesign.red,
                action: onToggleMic
            )

            controlPill(
                icon: state.isCameraEnabled ? "video.fill" : "video.slash.fill",
                isActive: state.isCameraEnabled,
                activeColor: CallDesign.surface,
                inactiveColor: CallDesign.red,
                action: onToggleCamera
            )

            controlPill(
                icon: state.isSpeakerphone ? "speaker.wave.2.fill" : "speaker.slash.fill",
                isActive: state.isSpeakerphone,
                activeColor: CallDesign.surface,
                inactiveColor: CallDesign.red,
                action: onToggleSpeaker
            )

            Spacer()

            Button(action: onLeave) {
                HStack(spacing: 5) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 12, weight: .medium))
                    Text("Leave")
                        .font(CallDesign.captionFont)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(CallDesign.red)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .padding(.bottom, 8)
        .background(
            LinearGradient(colors: [CallDesign.bg.opacity(0), CallDesign.bg.opacity(0.95)], startPoint: .top, endPoint: .bottom)
        )
    }

    private func controlPill(
        icon: String,
        isActive: Bool,
        activeColor: Color,
        inactiveColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 42, height: 38)
                .background(isActive ? activeColor : inactiveColor)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Shared state views (iOS)

private struct WaitingStateView: View {
    let isReconnecting: Bool
    var body: some View {
        VStack(spacing: 16) {
            if isReconnecting {
                ProgressView()
                    .tint(CallDesign.textSecondary)
                Text("Reconnecting...")
                    .font(CallDesign.bodyFont)
                    .foregroundColor(CallDesign.textSecondary)
            } else {
                Image(systemName: "phone.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(CallDesign.textMuted)
                Text("Waiting for participants")
                    .font(CallDesign.bodyFont)
                    .foregroundColor(CallDesign.textSecondary)
            }
        }
    }
}

private struct ErrorStateView: View {
    let message: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(CallDesign.red.opacity(0.7))
            Text(message)
                .font(CallDesign.bodyFont)
                .foregroundColor(CallDesign.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - CallHostingController

class CallHostingController: UIHostingController<CallExpandedView> {
    init(manager: CallManager, onDismiss: @escaping () -> Void) {
        let view = CallExpandedView(
            state: manager.state,
            onToggleMic: { Task { @MainActor in await manager.toggleMic() } },
            onToggleCamera: { Task { @MainActor in await manager.toggleCamera() } },
            onToggleSpeaker: { Task { @MainActor in await manager.toggleSpeaker() } },
            onToggleViewMode: { Task { @MainActor in manager.toggleViewMode() } },
            onLeave: {
                Task { @MainActor in
                    await manager.leaveRoom()
                    onDismiss()
                }
            }
        )
        super.init(rootView: view)
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
