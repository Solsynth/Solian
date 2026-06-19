import SwiftUI
import LiveKitClient
import Kingfisher

// MARK: - Avatar image loader (shared)

struct AvatarImage: View {
    let urlString: String?
    let size: CGFloat

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder {
                    ProgressView().tint(.white.opacity(0.4))
                }
                .onFailure { _ in /* ponytail: silent */ }
                .fade(duration: 0.2)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Circle()
            .fill(Color(red: 0.15, green: 0.17, blue: 0.20))
            .frame(width: size, height: size)
    }
}

// MARK: - Discord-style voice participant (circle + speaking ring + name)

struct VoiceParticipantView: View {
    let participant: CallState.ParticipantInfo
    let size: CGFloat

    private var rippleSize: CGFloat {
        size + CGFloat(participant.audioLevel) * size * 0.333
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Speaking ring
                if participant.isSpeaking {
                    Circle()
                        .fill(Color(red: 0.25, green: 0.81, blue: 0.56)) // #3FCF8E
                        .frame(width: rippleSize + 6, height: rippleSize + 6)
                }

                // Avatar
                AvatarImage(urlString: participant.avatarUrl, size: size)
                    .overlay(
                        Circle().stroke(
                            participant.isSpeaking
                                ? Color(red: 0.25, green: 0.81, blue: 0.56)
                                : Color.white.opacity(0.12),
                            lineWidth: participant.isSpeaking ? 3 : 1
                        )
                    )

                // Muted badge
                if participant.isMuted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mic.slash")
                                .font(.system(size: size * 0.17, weight: .medium))
                                .foregroundColor(.white)
                                .padding(size * 0.07)
                                .background(Color(white: 0.2))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(red: 0.055, green: 0.067, blue: 0.09), lineWidth: 2))
                        }
                    }
                    .frame(width: size, height: size)
                }
            }

            // Name
            Text(participant.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .frame(width: size + 16)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Video tile (16:9, for when camera is on)

struct ParticipantTileView: View {
    let participant: CallState.ParticipantInfo
    let large: Bool

    private var borderColor: Color {
        if participant.isSpeaking {
            return Color(red: 0.25, green: 0.81, blue: 0.56)
        }
        return Color.white.opacity(0.12)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: large ? 18 : 14)
                .fill(Color(red: 0.09, green: 0.10, blue: 0.12))

            if participant.hasVideo {
                // ponytail: VideoTrackRenderer not accessible from SwiftUI without UIKit bridge
                // Show avatar as placeholder until video track wiring is complete
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.13, green: 0.15, blue: 0.19), Color(red: 0.08, green: 0.10, blue: 0.13)],
                        startPoint: .top, endPoint: .bottom
                    )
                    AvatarImage(urlString: participant.avatarUrl, size: large ? 96 : 64)
                }
                .clipShape(RoundedRectangle(cornerRadius: large ? 16 : 12))
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.13, green: 0.15, blue: 0.19), Color(red: 0.08, green: 0.10, blue: 0.13)],
                        startPoint: .top, endPoint: .bottom
                    )
                    AvatarImage(urlString: participant.avatarUrl, size: large ? 96 : 64)
                }
                .clipShape(RoundedRectangle(cornerRadius: large ? 16 : 12))
            }

            // Bottom name bar
            VStack {
                Spacer()
                HStack {
                    Text(participant.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    if participant.isMuted {
                        Image(systemName: "mic.slash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.62))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(8)
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: large ? 18 : 14)
                .stroke(borderColor, lineWidth: participant.isSpeaking ? 2.4 : 1)
        )
        .animation(.easeOut(duration: 0.18), value: participant.isSpeaking)
    }
}

// MARK: - Speaking Avatar (compact, used in iOS floating widget / headers)

struct SpeakingAvatarView: View {
    let participant: CallState.ParticipantInfo
    var size: CGFloat = 84

    private var rippleSize: CGFloat {
        size + CGFloat(participant.audioLevel) * size * 0.333
    }

    var body: some View {
        ZStack {
            if participant.isSpeaking {
                Circle()
                    .fill(Color.green.opacity(0.75 + 0.25 * Double(participant.audioLevel)))
                    .frame(width: rippleSize, height: rippleSize)
            }

            AvatarImage(urlString: participant.avatarUrl, size: size)

            if participant.isMuted {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "mic.slash")
                            .font(.system(size: size * 0.17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(size * 0.06)
                            .background(Color.red)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                .frame(width: size, height: size)
            }
        }
    }
}
