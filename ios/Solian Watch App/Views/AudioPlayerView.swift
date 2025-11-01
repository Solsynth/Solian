
//
//  AudioPlayerView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioUrl: URL
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            if player != nil {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.largeTitle)
                }
                .buttonStyle(.plain)
            } else {
                Text("Loading audio...")
            }
        }
        .onAppear {
            player = AVPlayer(url: audioUrl)
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}
