//
//  AudioPlayerView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  In-place audio player for post and chat-message audio attachments. Mirrors
//  the in-bubble voice player: a play/pause button, the shared envelope
//  waveform tinted through the played portion, and a `position / total` label.
//  `isCompact` renders a lower-profile row (for chat bubbles / post cards);
//  otherwise it's the full card used in post detail. Playback observes the
//  asset's readiness + buffering so a spinner shows while audio loads.
//

import SwiftUI
import AVFoundation
import Combine

struct AudioPlayerView: View {
    let audioUrl: URL
    /// A compact, single-line row (chat bubble / post card) vs a roomier card.
    var isCompact: Bool = false

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var position: TimeInterval = 0
    @State private var didReachEnd = false
    @State private var isLoading = false
    @State private var statusSubscriptions: [AnyCancellable] = []
    @State private var timeObserver: Any?

    private var textColor: Color { .primary }
    private var secondaryColor: Color { .secondary }

    var body: some View {
        HStack(spacing: 10) {
            Button(action: togglePlayPause) {
                if isLoading {
                    ProgressView()
                        .frame(width: 28, height: 28)
                        .tint(textColor)
                } else {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: isCompact ? 24 : 28))
                        .foregroundColor(textColor)
                }
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel(isLoading
                ? L10n.audioPlayerLoading
                : (isPlaying ? L10n.voicePause : L10n.voicePlay))

            VoiceWaveformView(
                barCount: isCompact ? 18 : 22,
                seed: audioUrl.absoluteString,
                progress: progress,
                playedColor: textColor,
                idleColor: textColor.opacity(0.35)
            )
            .frame(height: isCompact ? 18 : 24)
            .frame(maxWidth: .infinity)
            .layoutPriority(0)

            Text(timeLabel)
                .font(.system(size: isCompact ? 10 : 11, weight: .medium))
                .monospacedDigit()
                .foregroundColor(secondaryColor)
                .frame(minWidth: 44, alignment: .trailing)
                .layoutPriority(1)
        }
        .padding(.vertical, isCompact ? 2 : 6)
        .padding(.horizontal, isCompact ? 4 : 8)
        .onAppear { preparePlayerIfNeeded() }
        .onDisappear { teardown() }
    }

    /// The player-reported duration once the asset is ready; 0 until then.
    @State private var lastKnownDuration: TimeInterval = 0

    private var progress: Double {
        if lastKnownDuration > 0 {
            return min(max(position / lastKnownDuration, 0), 1)
        }
        return position > 0 ? 1 : 0
    }

    private var timeLabel: String {
        "\(formatPlaybackTime(position)) / \(formatPlaybackTime(lastKnownDuration))"
    }

    // MARK: - Playback

    private func preparePlayerIfNeeded() {
        guard player == nil else { return }
        // Route playback through the speaker (recording leaves the session on
        // `.record`, which would otherwise mute or route to the receiver).
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        let player = AVPlayer(url: audioUrl)
        self.player = player

        // Observe the asset's readiness + buffering so a spinner shows while
        // audio loads. `AudioPlayerView` is a `View`, so capture
        // self by value (the @State storage is reference-backed); subscriptions
        // are cancelled in teardown.
        let itemStatus = player.currentItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .readyToPlay {
                    isLoading = false
                    if let item = player.currentItem, item.duration.seconds.isFinite, item.duration.seconds > 0 {
                        lastKnownDuration = item.duration.seconds
                    }
                } else if status == .failed {
                    isLoading = false
                }
            }
        let controlStatus = player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                isLoading = (status == .waitingToPlayAtSpecifiedRate)
            }
        statusSubscriptions = [itemStatus, controlStatus].compactMap { $0 }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [self] time in
            position = time.seconds
            if let item = player.currentItem, item.duration.seconds.isFinite {
                lastKnownDuration = item.duration.seconds
                didReachEnd = item.duration.seconds > 0 && time.seconds >= item.duration.seconds
            }
        }
    }

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
                position = 0
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
