import SwiftUI
import LiveKitClient
import Kingfisher

// MARK: - Avatar image loader (shared)

struct AvatarImage: View {
    let urlString: String?
    let size: CGFloat
    let authToken: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            avatarImage(url: url)
        } else {
            fallback
        }
    }

    @ViewBuilder
    private func avatarImage(url: URL) -> some View {
        if let authToken {
            KFImage.url(url)
                .requestModifier(AnyModifier { request in
                    var request = request
                    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                    return request
                })
                .resizable()
                .placeholder {
                    ProgressView().tint(.white.opacity(0.45))
                }
                .onFailure { _ in /* ponytail: silent */ }
                .fade(duration: 0.2)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            KFImage(url)
                .resizable()
                .placeholder {
                    ProgressView().tint(.white.opacity(0.45))
                }
                .onFailure { _ in /* ponytail: silent */ }
                .fade(duration: 0.2)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }

    private var fallback: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.32, green: 0.36, blue: 0.49),
                        Color(red: 0.18, green: 0.20, blue: 0.27)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Discord-inspired voice participant

struct VoiceParticipantView: View {
    let participant: CallState.ParticipantInfo
    let size: CGFloat

    private var highlightScale: CGFloat {
        participant.isSpeaking ? 1.06 + CGFloat(participant.audioLevel) * 0.16 : 0.92
    }

    private var ringOpacity: Double {
        participant.isSpeaking ? 0.25 + Double(participant.audioLevel) * 0.45 : 0
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.20, green: 0.76, blue: 0.48).opacity(ringOpacity))
                    .frame(width: size + 26, height: size + 26)
                    .scaleEffect(highlightScale)
                    .blur(radius: participant.isSpeaking ? 14 : 0)

                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: size + 18, height: size + 18)

                AvatarImage(urlString: participant.avatarUrl, size: size, authToken: participant.avatarAuthToken)
                    .overlay(
                        Circle()
                            .stroke(
                                participant.isSpeaking
                                    ? Color(red: 0.22, green: 0.80, blue: 0.53)
                                    : Color.white.opacity(0.14),
                                lineWidth: participant.isSpeaking ? 3 : 1
                            )
                    )
                    .shadow(
                        color: participant.isSpeaking
                            ? Color(red: 0.16, green: 0.64, blue: 0.44).opacity(0.35)
                            : .clear,
                        radius: 20
                    )

                if participant.isMuted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mic.slash.fill")
                                .font(.system(size: size * 0.15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(size * 0.09)
                                .background(Color(red: 0.88, green: 0.23, blue: 0.26))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.6), lineWidth: 3)
                                )
                        }
                    }
                    .frame(width: size, height: size)
                }
            }
            .frame(width: size + 26, height: size + 26)

            VStack(spacing: 3) {
                Text(participant.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.96))
                    .lineLimit(1)

                Text(participant.isMuted ? "Muted" : (participant.isSpeaking ? "Speaking" : "Listening"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(participant.isSpeaking ? 0.7 : 0.42))
            }
            .frame(width: size + 28)
            .multilineTextAlignment(.center)
        }
        .animation(.spring(response: 0.26, dampingFraction: 0.74), value: participant.isSpeaking)
        .animation(.easeOut(duration: 0.18), value: participant.audioLevel)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(participant.name), \(participant.isMuted ? "muted" : participant.isSpeaking ? "speaking" : "listening")")
    }
}

// MARK: - Large participant stage tile

struct ParticipantTileView: View {
    let participant: CallState.ParticipantInfo
    let large: Bool

    private var cornerRadius: CGFloat { large ? 30 : 22 }
    private var avatarSize: CGFloat { large ? 108 : 62 }
    private var outerPadding: CGFloat { large ? 22 : 14 }
    private var statusText: String {
        if participant.isScreenSharing { return "Screen sharing" }
        if participant.hasVideo { return "Video on" }
        if participant.isMuted { return "Muted" }
        if participant.isSpeaking { return "Speaking" }
        return "Listening"
    }

    private var tileGlow: Color {
        participant.isSpeaking
            ? Color(red: 0.21, green: 0.78, blue: 0.51)
            : Color(red: 0.38, green: 0.42, blue: 0.56)
    }

    private var borderOpacity: Double {
        participant.isSpeaking ? 0.95 : 0.18
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: participant.hasVideo
                            ? [
                                Color(red: 0.69, green: 0.74, blue: 0.88),
                                Color(red: 0.60, green: 0.66, blue: 0.82)
                              ]
                            : [
                                Color(red: 0.16, green: 0.18, blue: 0.23),
                                Color(red: 0.08, green: 0.09, blue: 0.12)
                              ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(tileGlow.opacity(participant.isSpeaking ? 0.22 : 0.08))
                .frame(width: large ? 280 : 120, height: large ? 280 : 120)
                .blur(radius: large ? 90 : 36)
                .offset(y: large ? 44 : 18)

            if participant.isScreenSharing {
                RoundedRectangle(cornerRadius: cornerRadius - 4, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1.5)
                    .padding(6)
            }

            VStack(spacing: large ? 18 : 12) {
                Spacer(minLength: outerPadding)

                AvatarImage(urlString: participant.avatarUrl, size: avatarSize, authToken: participant.avatarAuthToken)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(participant.isSpeaking ? 0.9 : 0.16), lineWidth: participant.isSpeaking ? 3 : 1)
                    )
                    .shadow(color: tileGlow.opacity(participant.isSpeaking ? 0.36 : 0.12), radius: large ? 34 : 18)
                    .scaleEffect(participant.isSpeaking ? 1.02 : 1)

                Spacer()

                VStack(spacing: 10) {
                    if large {
                        HStack(spacing: 8) {
                            if participant.isSpeaking {
                                Circle()
                                    .fill(Color(red: 0.19, green: 0.78, blue: 0.48))
                                    .frame(width: 8, height: 8)
                            }

                            Text(participant.name)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.34))
                        .clipShape(Capsule())
                    }

                    HStack(spacing: 8) {
                        if participant.isMuted {
                            statusBadge(icon: "mic.slash.fill", color: Color(red: 0.88, green: 0.23, blue: 0.26))
                        }

                        if participant.hasVideo {
                            statusBadge(icon: "video.fill", color: Color.white.opacity(0.16))
                        }

                        if participant.isScreenSharing {
                            statusBadge(icon: "rectangle.on.rectangle.fill", color: Color.white.opacity(0.16))
                        }

                        if !large {
                            Text(participant.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)

                        Text(statusText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.88))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.42))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, outerPadding)
                .padding(.bottom, outerPadding)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(tileGlow.opacity(borderOpacity), lineWidth: participant.isSpeaking ? 3 : 1.25)
        )
        .shadow(color: tileGlow.opacity(participant.isSpeaking ? 0.24 : 0.08), radius: large ? 28 : 16)
        .aspectRatio(large ? 0.84 : 1.0, contentMode: .fit)
        .animation(.spring(response: 0.26, dampingFraction: 0.74), value: participant.isSpeaking)
        .animation(.easeOut(duration: 0.18), value: participant.audioLevel)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(participant.name), \(statusText)")
    }

    private func statusBadge(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(Circle())
    }
}

// MARK: - Speaking avatar (compact, for strips)

struct SpeakingAvatarView: View {
    let participant: CallState.ParticipantInfo
    var size: CGFloat = 84

    private var pulseScale: CGFloat {
        participant.isSpeaking ? 1.03 + CGFloat(participant.audioLevel) * 0.18 : 0.9
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.19, green: 0.74, blue: 0.47).opacity(participant.isSpeaking ? 0.28 : 0))
                .frame(width: size + 18, height: size + 18)
                .scaleEffect(pulseScale)
                .blur(radius: participant.isSpeaking ? 10 : 0)

            AvatarImage(urlString: participant.avatarUrl, size: size, authToken: participant.avatarAuthToken)
                .overlay(
                    Circle()
                        .stroke(
                            participant.isSpeaking
                                ? Color(red: 0.22, green: 0.80, blue: 0.53)
                                : Color.white.opacity(0.14),
                            lineWidth: participant.isSpeaking ? 3 : 1
                        )
                )

            if participant.isMuted {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "mic.slash.fill")
                            .font(.system(size: size * 0.16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(size * 0.07)
                            .background(Color(red: 0.88, green: 0.23, blue: 0.26))
                            .clipShape(Circle())
                    }
                }
                .frame(width: size, height: size)
            }
        }
        .animation(.spring(response: 0.26, dampingFraction: 0.74), value: participant.isSpeaking)
        .animation(.easeOut(duration: 0.18), value: participant.audioLevel)
        .accessibilityHidden(true)
    }
}
