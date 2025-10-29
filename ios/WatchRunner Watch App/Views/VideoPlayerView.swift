import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    let videoUrl: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoUrl))
            .edgesIgnoringSafeArea(.all) // Make it full screen
    }
}
