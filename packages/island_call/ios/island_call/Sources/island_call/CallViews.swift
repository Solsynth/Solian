import SwiftUI
import Kingfisher
import UIKit
import LiveKitClient

private enum CallDesign {
    static let background = Color(red: 0.03, green: 0.03, blue: 0.05)
    static let backgroundSecondary = Color(red: 0.10, green: 0.10, blue: 0.13)
    static let panel = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let panelSoft = Color(red: 0.14, green: 0.14, blue: 0.18)
    static let chip = Color.white.opacity(0.12)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textMuted = Color.white.opacity(0.42)
    static let green = Color(red: 0.17, green: 0.68, blue: 0.35)
    static let red = Color(red: 0.89, green: 0.20, blue: 0.25)
    static let orange = Color(red: 0.98, green: 0.58, blue: 0.17)
}

struct CallExpandedView: View {
    @ObservedObject var state: CallState
    var onToggleMic: () -> Void
    var onToggleCamera: () -> Void
    var onToggleSpeaker: () -> Void
    var onToggleViewMode: () -> Void
    var onLeave: () -> Void

    @State private var controlsVisible = true
    @State private var hasAppeared = false

    private var featuredParticipant: CallState.ParticipantInfo? {
        state.participants.first(where: { $0.isSpeaking })
            ?? state.participants.first(where: { $0.hasVideo })
            ?? state.participants.first
    }

    private var secondaryParticipants: [CallState.ParticipantInfo] {
        guard let featuredParticipant else { return state.participants }
        return state.participants.filter { $0.id != featuredParticipant.id }
    }

    private var statusText: String {
        if state.isConnected { return formatDuration(state.duration) }
        if state.isReconnecting { return "Reconnecting" }
        return "Connecting"
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundView

                VStack(spacing: 0) {
                    if controlsVisible {
                        topBar
                            .padding(.horizontal, 28)
                            .padding(.top, max(geo.safeAreaInsets.top, 16))
                            .padding(.bottom, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer(minLength: 0)

                    contentBody
                        .padding(.horizontal, 28)
                        .scaleEffect(hasAppeared ? 1 : 0.97)
                        .opacity(hasAppeared ? 1 : 0)

                    Spacer(minLength: 24)

                    if controlsVisible {
                        lowerPanel
                            .padding(.horizontal, 28)
                            .padding(.bottom, max(geo.safeAreaInsets.bottom, 18))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                    controlsVisible.toggle()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.86)) {
                    hasAppeared = true
                }
            }
            .animation(.spring(response: 0.36, dampingFraction: 0.86), value: controlsVisible)
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [CallDesign.background, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(CallDesign.orange.opacity(0.12))
                .frame(width: 10, height: 10)
                .offset(y: -UIScreen.main.bounds.height * 0.42)

            Circle()
                .fill(Color(red: 0.42, green: 0.50, blue: 0.76).opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 120, y: 140)

            Circle()
                .fill(CallDesign.green.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: -150, y: 280)
        }
    }

    private var contentBody: some View {
        VStack(spacing: 22) {
            if let error = state.error {
                ErrorStateView(message: error)
            } else {
                stagePanel

                if state.participants.isEmpty {
                    emptyStateCard
                } else {
                    if !secondaryParticipants.isEmpty {
                        participantStrip
                    }
                }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button(action: onToggleViewMode) {
                Image(systemName: state.viewMode == .stage ? "square.grid.2x2.fill" : "rectangle.inset.filled.and.person.filled")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.34))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state.viewMode == .stage ? "Switch to grid view" : "Switch to stage view")

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(state.roomName ?? "General")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(CallDesign.textPrimary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(CallDesign.textMuted)
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(state.isConnected ? CallDesign.green : CallDesign.orange)
                        .frame(width: 8, height: 8)
                    Text(statusText)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(CallDesign.textSecondary)
                }
            }

            Spacer()

            Button(action: onToggleSpeaker) {
                Image(systemName: state.isSpeakerphone ? "speaker.wave.3.fill" : "speaker.slash.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.34))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state.isSpeakerphone ? "Disable speaker" : "Enable speaker")

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.black.opacity(0.34))
                    .frame(width: 40, height: 40)

                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                if !state.participants.isEmpty {
                    Text("\(state.participants.count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(CallDesign.green)
                        .clipShape(Capsule())
                        .offset(x: 9, y: -8)
                }
            }
            .frame(width: 40, height: 40)
            .accessibilityHidden(true)
        }
    }

    private var stagePanel: some View {
        Group {
            if let featuredParticipant {
                ParticipantTileView(participant: featuredParticipant, large: true)
            } else {
                waitingStage
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.black.opacity(0.26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.34), radius: 28, y: 16)
    }

    private var participantStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(secondaryParticipants.prefix(6)) { participant in
                    VStack(spacing: 8) {
                        SpeakingAvatarView(participant: participant, size: 58)
                        Text(participant.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(CallDesign.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(width: 74)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Text("No one’s here yet!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("When you are ready to talk, just hop in.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(CallDesign.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CallDesign.backgroundSecondary.opacity(0.88))
        )
    }

    private var lowerPanel: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.white.opacity(0.34))
                .frame(width: 74, height: 8)

            HStack(spacing: 16) {
                dockButton(
                    icon: state.isCameraEnabled ? "video.fill" : "video.slash.fill",
                    isDestructive: !state.isCameraEnabled,
                    action: onToggleCamera
                )

                dockButton(
                    icon: state.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill",
                    isDestructive: !state.isMicrophoneEnabled,
                    action: onToggleMic
                )

                dockButton(
                    icon: state.isSpeakerphone ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    isDestructive: !state.isSpeakerphone,
                    action: onToggleSpeaker
                )

                dockButton(
                    icon: state.viewMode == .stage ? "square.grid.2x2.fill" : "rectangle.inset.filled.and.person.filled",
                    isDestructive: false,
                    action: onToggleViewMode
                )

                dockButton(icon: "phone.down.fill", isDestructive: true, isHangup: true, action: onLeave)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(CallDesign.panel.opacity(0.97))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func dockButton(
        icon: String,
        isDestructive: Bool,
        isHangup: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(buttonBackground(isDestructive: isDestructive, isHangup: isHangup))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func buttonBackground(isDestructive: Bool, isHangup: Bool) -> Color {
        if isHangup { return CallDesign.red }
        if isDestructive { return Color.white.opacity(0.10) }
        return Color.white.opacity(0.14)
    }

    private var waitingStage: some View {
        VStack(spacing: 22) {
            Circle()
                .fill(CallDesign.panelSoft)
                .frame(width: 112, height: 112)
                .overlay(
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white.opacity(0.92))
                )

            VStack(spacing: 8) {
                Text(state.isReconnecting ? "Reconnecting..." : "Waiting for participants")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(state.isReconnecting ? "Your room is still active." : "Share the room and the stage will fill in here.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CallDesign.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 54)
    }
}

private struct ErrorStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(CallDesign.red)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(CallDesign.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 54)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(CallDesign.panel)
        )
    }
}

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
