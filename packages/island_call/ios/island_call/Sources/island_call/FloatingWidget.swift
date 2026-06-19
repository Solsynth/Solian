import SwiftUI
import Kingfisher
import UIKit

// MARK: - Floating Widget (iOS)

struct FloatingWidgetView: View {
    @ObservedObject var state: CallState
    var onTap: () -> Void
    var onLeave: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isDragging = false

    private let bg = Color(red: 0.082, green: 0.094, blue: 0.114)
    private let green = Color(red: 0.25, green: 0.81, blue: 0.56)
    private let red = Color(red: 0.90, green: 0.24, blue: 0.24)

    var body: some View {
        HStack(spacing: 10) {
            // Avatar with speaking ring
            ZStack {
                if let first = state.participants.first, first.isSpeaking {
                    Circle()
                        .fill(green.opacity(0.3))
                        .frame(width: 42, height: 42)
                }
                if let first = state.participants.first {
                    SpeakingAvatarView(participant: first, size: 36)
                } else {
                    Circle()
                        .fill(Color(white: 0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.4))
                        )
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(state.roomName ?? "Voice Channel")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Connection status dot + duration
                    HStack(spacing: 3) {
                        Circle()
                            .fill(state.isConnected ? green : .white.opacity(0.3))
                            .frame(width: 5, height: 5)
                        Text(formatDuration(state.duration))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Participant count
                    HStack(spacing: 2) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 8))
                        Text("\(state.participants.count)")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white.opacity(0.35))

                    // Mic status
                    Image(systemName: state.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 9))
                        .foregroundColor(state.isMicrophoneEnabled ? green : red)
                }
            }

            Spacer(minLength: 0)

            // Leave button
            Button(action: onLeave) {
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(red)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(bg.opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
        )
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    offset = value.translation
                }
                .onEnded { _ in
                    isDragging = false
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            if !isDragging { onTap() }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Floating Widget Controller

class FloatingWidgetController: UIHostingController<FloatingWidgetView> {
    init(manager: CallManager, onTap: @escaping () -> Void) {
        let view = FloatingWidgetView(
            state: manager.state,
            onTap: onTap,
            onLeave: {
                Task { @MainActor in
                    await manager.leaveRoom()
                    if let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.rootViewController is FloatingWidgetController }) {
                        window.isHidden = true
                    }
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
    }
}
