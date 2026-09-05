//
//  VoiceMessageView.swift
//  WatchRunner Watch App
//
//  In-bubble voice message player. A `voice` message carries its media URL in
//  `meta.voice_url` (absolute, or relative to the server) and its length in
//  `meta.duration_ms`. Mirrors Flutter's `_VoiceMessageContent`: a play/pause
//  button, a small waveform of pseudo-random bars (tinted for the played
//  portion), and a `position / total` time label.
//
//  Playback uses AVPlayer; the waveform is decorative (computed deterministically
//  from the message id), matching the watch-appropriate simplification while
//  still giving the message dimension for its duration.
//

import SwiftUI
import AVFoundation

struct VoiceMessageView: View {
    let message: SnChatMessage
    let isOwn: Bool
    @EnvironmentObject var appState: AppState

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var position: TimeInterval = 0
    @State private var timeObserver: Any?
    @State private var didReachEnd = false

    init(message: SnChatMessage, isOwn: Bool) {
        self.message = message
        self.isOwn = isOwn
    }

    /// Resolved absolute media URL: an absolute `voice_url` as-is, otherwise
    /// prefixed with the server URL (Flutter's `_resolveVoiceMediaUrlFromMeta`).
    private var mediaURL: URL? {
        guard let raw = message.meta["voice_url"]?.value as? String, !raw.isEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") { return URL(string: raw) }
        guard let serverUrl = appState.serverUrl, let base = URL(string: serverUrl) else { return nil }
        return URL(string: raw, relativeTo: base)
    }

    private var totalMs: Int {
        if let raw = message.meta["duration_ms"]?.value as? Int { return raw }
        if let raw = message.meta["duration_ms"]?.value as? Double { return Int(raw) }
        if let raw = message.meta["duration_ms"]?.value as? String { return Int(raw) ?? 0 }
        return 0
    }

    private var totalSeconds: TimeInterval { TimeInterval(totalMs) / 1000 }

    private var textColor: Color { isOwn ? .white : .primary }
    private var secondaryColor: Color { isOwn ? .white.opacity(0.8) : .secondary }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(textColor)
            }
            .buttonStyle(.plain)
            .disabled(mediaURL == nil)
            .accessibilityLabel(isPlaying ? "Pause voice message" : "Play voice message")

            WaveformView(
                barCount: 24,
                seed: message.id,
                progress: progress,
                playedColor: textColor,
                idleColor: textColor.opacity(0.35)
            )
            .frame(height: 20)

            Text(timeLabel)
                .font(.system(size: 10, weight: .medium))
                .monospacedDigit()
                .foregroundColor(secondaryColor)
        }
        .onAppear { preparePlayerIfNeeded() }
        .onDisappear { teardown() }
    }

    /// Fraction played (0...1), respecting the known total duration.
    private var progress: Double {
        if totalSeconds > 0 {
            return min(max(position / totalSeconds, 0), 1)
        }
        return position > 0 ? 1 : 0
    }

    private var timeLabel: String {
        "\(format(position)) / \(format(totalSeconds))"
    }

    private func format(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // MARK: - Playback

    private func preparePlayerIfNeeded() {
        guard player == nil, let mediaURL else { return }
        // Route playback through the speaker (recording leaves the session on
        // `.record`, which would otherwise mute or route to the receiver).
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        let player = AVPlayer(url: mediaURL)
        self.player = player
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [self] time in
            position = time.seconds
            if let item = player.currentItem, item.duration.seconds.isFinite {
                didReachEnd = item.duration.seconds > 0 && time.seconds >= item.duration.seconds
            }
        }
    }

    private func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if didReachEnd {
                player.seek(to: .zero)
                didReachEnd = false
            }
            player.play()
            isPlaying = true
        }
    }

    private func teardown() {
        player?.pause()
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        player = nil
        isPlaying = false
    }
}

/// A decorative waveform of deterministic bars, tinted through the played
/// portion. Bars are pseudo-random but stable for a given seed, so a message
/// keeps the same shape across renders (Flutter uses real audio peaks; a
/// stable pseudo-waveform is the watch-appropriate simplification).
private struct WaveformView: View {
    let barCount: Int
    let seed: String
    let progress: Double
    let playedColor: Color
    let idleColor: Color

    var body: some View {
        GeometryReader { geo in
            let playedCount = Int(CGFloat(progress) * CGFloat(barCount))
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    let height = barHeight(index)
                    Capsule()
                        .fill(index < playedCount ? playedColor : idleColor)
                        .frame(width: max(2, geo.size.width / CGFloat(barCount) - 2), height: height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }

    /// Stable pseudo-random height (6...18pt) from the seed + index.
    private func barHeight(_ index: Int) -> CGFloat {
        var hash = UInt64(bitPattern: Int64(seed.hashValue))
        hash = hash &+ UInt64(index) &* 0x9E3779B9
        hash ^= hash >> 13
        hash = hash &* 0x5bd1e995
        hash ^= hash >> 15
        let normalized = Double(hash % 1000) / 1000.0
        return 6 + CGFloat(normalized) * 12
    }
}
