//
//  VoiceRecorderView.swift
//  WatchRunner Watch App
//
//  Voice message recording sheet, walked-style: tap the mic to start, tap to
//  stop, then confirm Send or Cancel (or re-record). Records to a temp .m4a
//  (AAC) and hands the file + millisecond duration back to the caller for
//  upload via `POST /messager/chat/{room}/messages/voice`.
//
//  Mirror of Flutter's `chat_input.dart` voice flow (`startVoiceRecording` /
//  `finishVoiceRecording`), adapted to the watch's tap-toggle interaction.
//  While recording the sheet shows a LIVE waveform driven by real mic metering
//  (`isMeteringEnabled` + `averagePower`), so the user sees the voice they are
//  capturing in the moment; after stopping, the preview is the recorded shape.
//

import SwiftUI
import AVFoundation
import WatchKit

struct VoiceRecorderView: View {
    /// Called with the recorded file URL and its duration in milliseconds
    /// once the user confirms.
    let onSend: (URL, Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var recorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var hasRecordedClip = false
    @State private var recordedURL: URL?
    /// Rolling buffer of the latest mic levels (0...1), newest last, so the
    /// waveform moves with the voice while recording.
    @State private var liveLevels: [Float] = []
    /// Snapshot of the live meters taken at stop — the preview waveform shows
    /// the actual recorded shape rather than a static decoration.
    @State private var recordedLevels: [Float] = []
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var errorMessage: String?

    /// Number of bars in the waveform (keep under the watch's small width).
    private static let maxBars = 28
    /// A take shorter than this is discarded (it's an accidental tap).
    private static let minClipDuration: TimeInterval = 0.5

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            // The signal element: a real-time waveform of the mic level while
            // recording, or the recorded shape once stopped.
            if isRecording {
                RecorderWaveformView(levels: liveLevels, color: .red)
                    .frame(height: 56)
            } else if hasRecordedClip {
                RecorderWaveformView(levels: recordedLevels, color: .accentColor)
                    .frame(height: 56)
            }

            if isRecording || hasRecordedClip {
                Text(formatSeconds(elapsed))
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(isRecording ? .red : .primary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            controls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            configureSession()
            requestPermission()
        }
        .onDisappear {
            teardown()
        }
    }

    private var title: String {
        if isRecording { return L10n.voiceRecording }
        return L10n.voiceVoiceMessage
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        if isRecording {
            Button {
                stopRecording()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.voiceStopRecording)
        } else if hasRecordedClip {
            HStack(spacing: 22) {
                Button {
                    cancel()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 38))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.voiceCancelVoice)

                // Re-record: discard the take and start a fresh one, so a bad
                // recording never dead-ends the flow.
                Button {
                    startRecording()
                } label: {
                    Image(systemName: "mic.circle")
                        .font(.system(size: 34))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.voiceStartRecording)

                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.voiceSendVoice)
            }
        } else {
            Button {
                startRecording()
            } label: {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.voiceStartRecording)
            .accessibilityHint(L10n.voiceStartRecordingHint)

            Text(L10n.voiceStartRecordingHint)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Recording

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            errorMessage = L10n.voiceAudioUnavailable
        }
    }

    private func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    errorMessage = L10n.voiceEnableMicrophone
                }
            }
        }
    }

    private func startRecording() {
        guard !isRecording else { return }
        // Drop any prior take before starting a fresh one.
        if let old = recordedURL {
            try? FileManager.default.removeItem(at: old)
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default, options: [])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("chat-voice-\(UUID().uuidString.lowercased()).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            // Enable metering so `averagePower` drives the live waveform.
            recorder.isMeteringEnabled = true
            guard recorder.record() else {
                errorMessage = L10n.voiceCouldNotStartRecording
                return
            }
            self.recorder = recorder
            recordedURL = nil
            hasRecordedClip = false
            recordedLevels = []
            liveLevels = []
            elapsed = 0
            isRecording = true
            errorMessage = nil
            startTimer()
            WKInterfaceDevice.current().play(.click)
        } catch {
            errorMessage = L10n.voiceCouldNotStartRecording
        }
    }

    private func stopRecording() {
        guard let recorder else { return }
        // Capture the duration BEFORE stopping: on watchOS reading
        // `currentTime` after `stop()` can collapse to 0, which made
        // `hasRecordedClip` false and left the sheet stuck on the mic button —
        // Send/Cancel never appeared. Fall back to the timer-tracked `elapsed`.
        let duration = recorder.currentTime > 0 ? recorder.currentTime : elapsed
        recorder.stop()
        self.elapsed = duration
        self.recordedURL = recorder.url
        // Freeze the live meters so the preview waveform is this take's shape.
        self.recordedLevels = liveLevels
        self.liveLevels = []
        self.recorder = nil
        self.isRecording = false
        self.hasRecordedClip = duration >= Self.minClipDuration
        timer?.invalidate()
        timer = nil
        // Release the mic and route subsequent playback through the speaker.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        WKInterfaceDevice.current().play(.click)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let recorder = recorder, recorder.isRecording else { return }
            recorder.updateMeters()
            elapsed = recorder.currentTime
            var levels = liveLevels
            levels.append(normalizedLevel(recorder.averagePower(forChannel: 0)))
            if levels.count > Self.maxBars {
                levels.removeFirst(levels.count - Self.maxBars)
            }
            liveLevels = levels
        }
    }

    /// Maps the recorder's `averagePower` (dB, -160...0) to a bar height 0...1,
    /// lifting silence to a small visible baseline and curving so loud segments
    /// stay lively.
    private func normalizedLevel(_ db: Float) -> Float {
        let clamped = max(-60, min(0, db))
        let linear = (clamped + 60) / 60
        let curved = Float(pow(Double(linear), 1.3))
        return max(0.06, min(1, curved))
    }

    // MARK: - Actions

    private func send() {
        guard let recordedURL, hasRecordedClip else { return }
        WKInterfaceDevice.current().play(.click)
        let durationMs = Int(elapsed * 1000)
        onSend(recordedURL, durationMs)
        dismiss()
    }

    private func cancel() {
        WKInterfaceDevice.current().play(.click)
        if isRecording {
            recorder?.stop()
            recorder = nil
        }
        if let recordedURL {
            try? FileManager.default.removeItem(at: recordedURL)
        }
        timer?.invalidate()
        timer = nil
        dismiss()
    }

    private func teardown() {
        timer?.invalidate()
        timer = nil
        if isRecording {
            recorder?.stop()
            recorder = nil
        }
    }

    private func formatSeconds(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

/// A horizontal waveform of centered bars, one per normalized mic level. Bars
/// grow symmetrically from the middle (Voice Memos style). While recording the
/// same bar count scrolls with `levels`; the frozen `recordedLevels` shows the
/// captured take after stopping.
private struct RecorderWaveformView: View {
    let levels: [Float]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let count = max(levels.count, 1)
            let spacing: CGFloat = 2
            let barWidth = max(2, (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count))
            HStack(alignment: .center, spacing: spacing) {
                ForEach(0..<count, id: \.self) { index in
                    let level = index < levels.count ? CGFloat(levels[index]) : 0.12
                    let height = max(4, level * (geo.size.height - 4))
                    Capsule()
                        .fill(color.opacity(0.35 + 0.65 * Double(level)))
                        .frame(width: barWidth, height: height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .animation(.easeOut(duration: 0.1), value: levels)
    }
}
