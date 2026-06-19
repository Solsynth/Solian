import SwiftUI
import Kingfisher
import LiveKitClient

private enum CallDesign {
    static let background = Color(red: 0.03, green: 0.03, blue: 0.05)
    static let backgroundSecondary = Color(red: 0.10, green: 0.10, blue: 0.13)
    static let panel = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let panelSoft = Color(red: 0.14, green: 0.14, blue: 0.18)
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
                backgroundView(size: geo.size)

                VStack(spacing: 0) {
                    if controlsVisible {
                        topBar
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer(minLength: 0)

                    contentBody
                        .padding(.horizontal, 24)
                        .scaleEffect(hasAppeared ? 1 : 0.97)
                        .opacity(hasAppeared ? 1 : 0)

                    Spacer(minLength: 18)

                    if controlsVisible {
                        lowerPanel
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
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

    private func backgroundView(size: CGSize) -> some View {
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
                .offset(y: -size.height * 0.43)

            Circle()
                .fill(Color(red: 0.42, green: 0.50, blue: 0.76).opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 100, y: 120)

            Circle()
                .fill(CallDesign.green.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: -120, y: 240)
        }
    }

    private var contentBody: some View {
        VStack(spacing: 18) {
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
        HStack(spacing: 12) {
            Button(action: onToggleViewMode) {
                Image(systemName: state.viewMode == .stage ? "square.grid.2x2.fill" : "rectangle.inset.filled.and.person.filled")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.32))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(state.roomName ?? "General")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(CallDesign.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(CallDesign.textMuted)
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(state.isConnected ? CallDesign.green : CallDesign.orange)
                        .frame(width: 7, height: 7)
                    Text(statusText)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(CallDesign.textSecondary)
                }
            }

            Spacer()

            Button(action: onToggleSpeaker) {
                Image(systemName: state.isSpeakerphone ? "speaker.wave.3.fill" : "speaker.slash.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.32))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.black.opacity(0.32))
                    .frame(width: 36, height: 36)

                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                if !state.participants.isEmpty {
                    Text("\(state.participants.count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(CallDesign.green)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -8)
                }
            }
            .frame(width: 36, height: 36)
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
            HStack(spacing: 12) {
                ForEach(secondaryParticipants.prefix(5)) { participant in
                    VStack(spacing: 8) {
                        SpeakingAvatarView(participant: participant, size: 52)
                        Text(participant.name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(CallDesign.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(width: 68)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 9) {
            Text("No one’s here yet!")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            Text("When you are ready to talk, just hop in.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CallDesign.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CallDesign.backgroundSecondary.opacity(0.88))
        )
    }

    private var lowerPanel: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.white.opacity(0.34))
                .frame(width: 68, height: 7)

            HStack(spacing: 12) {
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
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(CallDesign.panel.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
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
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
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
        VStack(spacing: 20) {
            Circle()
                .fill(CallDesign.panelSoft)
                .frame(width: 98, height: 98)
                .overlay(
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(.white.opacity(0.92))
                )

            VStack(spacing: 8) {
                Text(state.isReconnecting ? "Reconnecting..." : "Waiting for participants")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(state.isReconnecting ? "Your room is still active." : "Share the room and the stage will fill in here.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CallDesign.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 48)
    }
}

private struct ErrorStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 34))
                .foregroundColor(CallDesign.red)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CallDesign.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CallDesign.panel)
        )
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.material = material
        view.blendingMode = blendingMode
    }
}
