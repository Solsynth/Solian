//
//  VoiceWaveformView.swift
//  WatchRunner Watch App
//
//  Shared decorative waveform used by every audio surface — the in-bubble
//  voice message player and post/attachment audio players. Models a voice
//  pulse train rather than random noise: the envelope rises smoothly from the
//  edges to a full-swing center, with a gentle per-bar ripple so the shape
//  reads organic and ever-so-slightly asymmetrical (iMessage-style) instead of
//  flat or random. Heights are a pure function of the bar's position within
//  the waveform, so a given `seed` renders identically every time; `progress`
//  fills the played portion left-to-right.
//

import SwiftUI

/// A rectangular (not repeating) waveform of centered bars, tinted through the
/// played portion. `playedColor` marks bars at-or-before the `progress` fill
/// edge; `idleColor` is the unplayed rest.
struct VoiceWaveformView: View {
    let barCount: Int
    let seed: String
    let progress: Double
    let playedColor: Color
    let idleColor: Color

    var body: some View {
        GeometryReader { geo in
            let playedWidth = CGFloat(progress) * geo.size.width
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    let fraction = barHeight(index) // 0...1 envelope
                    let x = barCenterX(index, width: geo.size.width)
                    // A bar is "played" once its center passes the fill edge;
                    // width-based (not count-based) so the fill advances
                    // smoothly with `progress`.
                    let isPlayed = x <= playedWidth
                    Capsule()
                        .fill(isPlayed ? playedColor : idleColor)
                        .frame(width: max(2, geo.size.width / CGFloat(barCount) - 2), height: max(3, fraction * geo.size.height))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }

    /// The horizontal center of bar `index`, used to compare against the fill
    /// edge so the played boundary tracks `progress` continuously.
    private func barCenterX(_ index: Int, width: CGFloat) -> CGFloat {
        let slot = width / CGFloat(barCount)
        return slot * CGFloat(index) + slot / 2
    }

    /// Stable 0...1 height from the bar's position in the waveform. A raised-
    /// cosine envelope peaks at the center and tapers to the edges, with a
    /// position-derived ripple for a lively, non-repeating shape. Deterministic
    /// on `seed`+`index`.
    private func barHeight(_ index: Int) -> CGFloat {
        guard barCount > 1 else { return 1 }
        // Position within the waveform, 0 at the left edge, 1 at the right.
        let t = CGFloat(index) / CGFloat(barCount - 1)
        // Raised-cosine envelope: 0 at the edges, 1 at the center.
        let envelope: CGFloat = 0.35 + 0.65 * sin(.pi * t)
        // A small position-based ripple (a couple of gentle humps), so bars
        // aren't a monotone ramp or a flat row.
        var hash = UInt64(bitPattern: Int64(seed.hashValue))
        hash = hash &+ UInt64(index) &* 0x9E3779B9
        hash ^= hash >> 13
        hash = hash &* 0x5bd1e995
        hash ^= hash >> 15
        let rippleBase = Double(hash % 100) / 100.0
        let ripple = 0.75 + 0.25 * CGFloat(rippleBase)
        return min(1, envelope * ripple)
    }
}

/// Formats a playback position/total as `mm:ss`.
func formatPlaybackTime(_ seconds: TimeInterval) -> String {
    let total = Int(max(0, seconds.rounded()))
    let minutes = total / 60
    let secs = total % 60
    return String(format: "%02d:%02d", minutes, secs)
}
