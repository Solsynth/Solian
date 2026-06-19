import SwiftUI
import Kingfisher
import LiveKitClient

// MARK: - Design tokens

private enum CallDesign {
    // Colors
    static let bg = Color(red: 0.055, green: 0.067, blue: 0.09)       // #0E1117
    static let surface = Color(red: 0.082, green: 0.094, blue: 0.114) // #151719
    static let surfaceHover = Color(red: 0.11, green: 0.13, blue: 0.16)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textMuted = Color.white.opacity(0.35)
    static let accent = Color(red: 0.35, green: 0.61, blue: 0.96)     // #599AFF
    static let green = Color(red: 0.25, green: 0.81, blue: 0.56)      // #3FCF8E
    static let greenSoft = Color(red: 0.18, green: 0.55, blue: 0.40)
    static let red = Color(red: 0.90, green: 0.24, blue: 0.24)
    static let redSoft = Color(red: 0.55, green: 0.18, blue: 0.18)
    static let overlay = Color.black.opacity(0.45)

    // Typography
    static let titleFont = Font.system(size: 14, weight: .semibold)
    static let bodyFont = Font.system(size: 12, weight: .regular)
    static let captionFont = Font.system(size: 11, weight: .medium)
    static let monoFont = Font.system(size: 12, design: .monospaced)

    // Spacing
    static let cornerSm: CGFloat = 8
    static let cornerMd: CGFloat = 12
    static let cornerLg: CGFloat = 16
}

// MARK: - macOS Call View

struct CallExpandedView: View {
    @ObservedObject var state: CallState
    var onToggleMic: () -> Void
    var onToggleCamera: () -> Void
    var onToggleSpeaker: () -> Void
    var onToggleViewMode: () -> Void
    var onLeave: () -> Void

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
                Spacer()
                controlsBar
            }
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerBar
            if allVoiceOnly {
                voiceChannelView
            } else if state.viewMode == .stage {
                stageView
            } else {
                videoGridView
            }
        }
    }

    // MARK: - Header (Discord voice channel style)

    private var headerBar: some View {
        HStack(spacing: 8) {
            // Green phone icon
            Image(systemName: "phone.connection.fill")
                .font(.system(size: 13))
                .foregroundColor(CallDesign.green)

            Text(state.roomName ?? "Voice Channel")
                .font(CallDesign.titleFont)
                .foregroundColor(CallDesign.text)

            // Duration pill
            HStack(spacing: 4) {
                Circle()
                    .fill(state.isConnected ? CallDesign.green : CallDesign.textMuted)
                    .frame(width: 6, height: 6)
                Text(state.isConnected ? formatDuration(state.duration) : state.isReconnecting ? "Reconnecting" : "Connecting")
                    .font(CallDesign.monoFont)
                    .foregroundColor(CallDesign.textSecondary)
            }

            Spacer()

            // Participant count badge
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 10))
                Text("\(state.participants.count)")
                    .font(CallDesign.captionFont)
            }
            .foregroundColor(CallDesign.textMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CallDesign.surface)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .overlay(CallDesign.bg.opacity(0.6))
        )
    }

    // MARK: - Voice channel (Discord-style centered circles)

    private var voiceChannelView: some View {
        GeometryReader { geo in
            let result = avatarLayout(for: geo.size)
            let avatarSize = result.size
            let columns = result.columns
            let spacing: CGFloat = geo.size.width > 600 ? 36 : 24

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(avatarSize + 20), spacing: spacing), count: columns),
                    spacing: spacing + 8
                ) {
                    ForEach(state.participants) { p in
                        VoiceParticipantView(participant: p, size: avatarSize)
                    }
                }
                .padding(.horizontal, max(24, (geo.size.width - CGFloat(columns) * (avatarSize + 20 + spacing)) / 2))
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity, minHeight: geo.size.height - 80)
            }
        }
    }

    private func avatarLayout(for size: CGSize) -> (size: CGFloat, columns: Int) {
        let available = size.width - 48
        let count = state.participants.count
        // Try to fit in reasonable columns
        for cols in stride(from: count, through: 1, by: -1) {
            let maxPerCol = ceil(Double(count) / Double(cols))
            let neededHeight = maxPerCol * 140.0 // avatar + name + spacing
            if neededHeight < Double(size.height - 100) {
                let avatarSize = min(96.0, (available / Double(cols)) - 20)
                if avatarSize >= 56 {
                    return (CGFloat(avatarSize), cols)
                }
            }
        }
        return (72, max(1, Int(available / 100)))
    }

    // MARK: - Video grid

    private var videoGridView: some View {
        let count = state.participants.count
        let columns: Int = switch count {
        case ...1: 1
        case ...4: 2
        case ...6: 3
        default: 4
        }

        return ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(state.participants) { p in
                    ParticipantTileView(participant: p, large: false)
                }
            }
            .padding(12)
            .padding(.bottom, 72)
        }
    }

    // MARK: - Stage view

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
            }

            ParticipantTileView(participant: focused, large: true)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Controls bar (Discord-style)

    private var controlsBar: some View {
        HStack(spacing: 6) {
            controlPill(
                icon: state.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill",
                label: state.isMicrophoneEnabled ? "Mute" : "Unmute",
                isActive: state.isMicrophoneEnabled,
                activeColor: CallDesign.surface,
                inactiveColor: CallDesign.red,
                action: onToggleMic
            )

            controlPill(
                icon: state.isCameraEnabled ? "video.fill" : "video.slash.fill",
                label: state.isCameraEnabled ? "Stop Video" : "Start Video",
                isActive: state.isCameraEnabled,
                activeColor: CallDesign.surface,
                inactiveColor: CallDesign.red,
                action: onToggleCamera
            )

            Spacer()

            // Disconnect
            Button(action: onLeave) {
                HStack(spacing: 6) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 13, weight: .medium))
                    Text("Disconnect")
                        .font(CallDesign.captionFont)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(CallDesign.red)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .padding(.bottom, 6)
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .overlay(CallDesign.bg.opacity(0.5))
        )
    }

    private func controlPill(
        icon: String,
        label: String,
        isActive: Bool,
        activeColor: Color,
        inactiveColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(CallDesign.captionFont)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? activeColor : inactiveColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared state views

struct WaitingStateView: View {
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

struct ErrorStateView: View {
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

// MARK: - NSVisualEffectView bridge

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = .active
        return v
    }

    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material = material
        v.blendingMode = blendingMode
    }
}
