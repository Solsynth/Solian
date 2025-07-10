import Flutter
import UIKit
import AVKit

// Factory to create the native video player view
class VideoPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return VideoPlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

    // This is required by the protocol, but we don't need to implement it for this case
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// The actual PlatformView that holds the AVPlayerViewController
class VideoPlayerView: NSObject, FlutterPlatformView {
    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private var activityIndicator: UIActivityIndicatorView!
    private var progressLabel: UILabel!
    private var progressStack: UIStackView!

    // KVO contexts
    private var playerStatusContext = 0
    private var playerLoadedTimeRangesContext = 0

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        super.init()

        // Ensure we have a valid URL from Flutter
        guard let args = args as? [String: Any],
              let videoUrlString = args["videoUrl"] as? String,
              let videoUrl = URL(string: videoUrlString) else {
            // Initialize playerViewController even if URL is invalid
            playerViewController = AVPlayerViewController()
            playerViewController!.showsPlaybackControls = false // Hide controls for invalid URL

            let label = UILabel()
            label.text = "Invalid video URL"
            label.textAlignment = .center
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            playerViewController!.contentOverlayView?.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: playerViewController!.contentOverlayView!.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: playerViewController!.contentOverlayView!.centerYAnchor)
            ])
            return
        }

        // --- Player ---
        player = AVPlayer(url: videoUrl)

        // --- PlayerViewController ---
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
        playerViewController!.view.frame = frame // Set the frame directly
        playerViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController!.showsPlaybackControls = true
        
        // --- Loading Indicator (spinner) ---
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false // Allow touches to pass through

        // --- Progress Percentage Label ---
        progressLabel = UILabel()
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.isUserInteractionEnabled = false // Allow touches to pass through

        playerViewController!.contentOverlayView?.addSubview(activityIndicator)
        playerViewController!.contentOverlayView?.addSubview(progressLabel)
        
        // Center the activity indicator and place the progress label below it
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: playerViewController!.contentOverlayView!.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: playerViewController!.contentOverlayView!.centerYAnchor),

            progressLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            progressLabel.centerXAnchor.constraint(equalTo: playerViewController!.contentOverlayView!.centerXAnchor),
        ])

        // Add Key-Value Observers
        addObservers()

        activityIndicator.startAnimating()
    }

    func view() -> UIView {
        return playerViewController!.view
    }

    private func addObservers() {
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: &playerStatusContext)
        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new], context: &playerLoadedTimeRangesContext)
    }

    private func removeObservers() {
        // Check if observers are registered before removing them to avoid crashes.
        // A simple way is to use a flag or check the player object, but for KVO,
        // it's often safer to just ensure they are added once and removed once.
        // Given the lifecycle here, direct removal in deinit is okay.
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: &playerStatusContext)
        player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &playerLoadedTimeRangesContext)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Dispatch to main queue to ensure thread safety
        DispatchQueue.main.async {
            guard self.player != nil else {
                return
            }

            if context == &self.playerStatusContext {
                self.handlePlayerStatusChange(change: change)
            } else if context == &self.playerLoadedTimeRangesContext {
                self.handleLoadedTimeRangesChange()
            }
        }
    }

    private func handlePlayerStatusChange(change: [NSKeyValueChangeKey : Any]?) {
        guard let statusValue = change?[.newKey] as? Int, let status = AVPlayer.Status(rawValue: statusValue) else { return }
        
        DispatchQueue.main.async {
            switch status {
            case .readyToPlay:
                self.activityIndicator.stopAnimating()
                self.progressLabel.isHidden = true
                self.player?.play()
            case .failed:
                self.activityIndicator.stopAnimating()
                // Optionally: show an error message to the user
                let label = UILabel()
                label.text = "Failed to load video"
                label.textColor = .white
                label.textAlignment = .center
                label.frame = self.playerViewController!.view.bounds
                self.playerViewController!.view.addSubview(label)
            case .unknown:
                self.activityIndicator.startAnimating()
            @unknown default:
                break
            }
        }
    }

    private func handleLoadedTimeRangesChange() {
        guard let playerItem = player?.currentItem,
              let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue,
              !CMTIME_IS_INDEFINITE(playerItem.duration) else {
            return
        }

        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let totalBuffer = startSeconds + durationSeconds
        let totalDuration = CMTimeGetSeconds(playerItem.duration)
        
        let progress = Float(totalBuffer / totalDuration)
        
        DispatchQueue.main.async {
            self.progressLabel.text = "\(Int(progress * 100))%"

            if progress >= 0.99 {
                self.progressLabel.isHidden = true
            }
        }
    }

    deinit {
        removeObservers()
    }
}
