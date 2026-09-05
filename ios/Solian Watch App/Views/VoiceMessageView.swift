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
import Combine

struct VoiceMessageView: View {
    let message: SnChatMessage
    let isOwn: Bool
    @EnvironmentObject var appState: AppState

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var position: TimeInterval = 0
    @State private var timeObserver: Any?
    @State private var didReachEnd = false
    /// True while the audio is buffering/loading and not yet playing.
    @State private var isLoading = false

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
        HStack(spacing: 12) {
            Button(action: togglePlayPause) {
                if isLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                        .tint(textColor)
                } else {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(textColor)
                }
            }
            .buttonStyle(.plain)
            .disabled(mediaURL == nil || isLoading)
            .accessibilityLabel(isLoading ? L10n.voiceLoading : (isPlaying ? L10n.voicePause : L10n.voicePlay))

            VoiceWaveformView(
                barCount: 20,
                seed: message.id,
                progress: progress,
                playedColor: textColor,
                idleColor: textColor.opacity(0.35)
            )
            .frame(height: 20)
            .frame(maxWidth: .infinity)
            // The waveform absorbs extra space so the play button and time
            // label keep their natural widths instead of being crowded.
            .layoutPriority(0)

            Text(timeLabel)
                .font(.system(size: 10, weight: .medium))
                .monospacedDigit()
                .foregroundColor(secondaryColor)
                .frame(minWidth: 44, alignment: .trailing)
                .layoutPriority(1)
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
        "\(formatPlaybackTime(position)) / \(formatPlaybackTime(totalSeconds))"
    }

    // MARK: - Playback

    private func preparePlayerIfNeeded() {
        guard player == nil, let mediaURL else { return }
        // Route playback through the speaker (recording leaves the session on
        // `.record`, which would otherwise mute or route to the receiver).
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        let player = AVPlayer(url: mediaURL)
        self.player = player
        // Observe the current item's readiness + buffering so a spinner can
        // show while audio is loading (then clear once it's playable). KVO
        // status/timeControlStatus fire on the main queue.
        // `VoiceMessageView` is a struct, so `[weak self]` is invalid; the
        // `@State` storage is reference-backed, so writing through the captured
        // value copy still updates the live state. Cancelled in `teardown`.
        let itemStatus = player.currentItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                // The item fires `.unknown` at subscription (before a play
                // request), so it must never turn the spinner on by itself.
                // It only clears it once the asset is ready or failed — the
                // loading state itself is driven by the play request and the
                // `timeControlStatus` buffering observation below.
                if status == .readyToPlay { self.isLoading = false }
                else if status == .failed { self.isLoading = false }
            }
        let controlStatus = player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                // Playing or paused clears the spinner; waiting (buffering) keeps it.
                self.isLoading = (status == .waitingToPlayAtSpecifiedRate)
            }
        statusSubscriptions = [itemStatus, controlStatus].compactMap { $0 }
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

    /// Buffering-state observations to cancel on teardown.
    @State private var statusSubscriptions: [AnyCancellable] = []

    private func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            isLoading = false
        } else {
            if didReachEnd {
                player.seek(to: .zero)
                didReachEnd = false
            }
            isLoading = true
            player.play()
            isPlaying = true
        }
    }

    private func teardown() {
        player?.pause()
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        statusSubscriptions.forEach { $0.cancel() }
        statusSubscriptions = []
        player = nil
        isPlaying = false
        isLoading = false
    }
}
