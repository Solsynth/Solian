//
//  VoiceRecorderView.swift
//  WatchRunner Watch App
//
//  Voice message recording sheet, walked-style: tap the mic to start, tap to
//  stop, then confirm Send or Cancel. Records to a temp .m4a (AAC) and hands
//  the file + millisecond duration back to the caller for upload via
//  `POST /messager/chat/{room}/messages/voice`.
//
//  Mirror of Flutter's `chat_input.dart` voice flow (`startVoiceRecording` /
//  `finishVoiceRecording`), adapted to the watch's tap-toggle interaction.
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
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            if isRecording {
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                Text(formatSeconds(elapsed))
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            } else if hasRecordedClip {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
                Text(formatSeconds(elapsed))
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

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
                HStack(spacing: 28) {
                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.voiceSendVoice)

                    Button {
                        cancel()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.voiceCancelVoice)
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            configureSession()
            requestPermission()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            recorder?.stop()
            recorder = nil
        }
    }

    private var title: String {
        if isRecording { return L10n.voiceRecording }
        if hasRecordedClip { return L10n.voiceVoiceMessage }
        return L10n.voiceVoiceMessage
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
        guard recorder == nil else { return }
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
            guard recorder.record() else {
                errorMessage = L10n.voiceCouldNotStartRecording
                return
            }
            self.recorder = recorder
            recordedURL = nil
            hasRecordedClip = false
            elapsed = 0
            isRecording = true
            errorMessage = nil
            startTimer()
        } catch {
            errorMessage = L10n.voiceCouldNotStartRecording
        }
    }

    private func stopRecording() {
        guard let recorder else { return }
        recorder.stop()
        elapsed = recorder.currentTime
        recordedURL = recorder.url
        isRecording = false
        hasRecordedClip = elapsed >= 0.5
        timer?.invalidate()
        timer = nil
        // Release the mic and route subsequent playback through the speaker.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let recorder = recorder, recorder.isRecording else { return }
            elapsed = recorder.currentTime
        }
    }

    // MARK: - Actions

    private func send() {
        guard let recordedURL, hasRecordedClip else { return }
        WKInterfaceDevice.current().play(.click)
        let durationMs = Int(elapsed * 1000)
        recorder?.stop()
        recorder = nil
        onSend(recordedURL, durationMs)
        dismiss()
    }

    private func cancel() {
        WKInterfaceDevice.current().play(.click)
        if let recordedURL {
            try? FileManager.default.removeItem(at: recordedURL)
        }
        recorder?.stop()
        recorder = nil
        dismiss()
    }

    private func formatSeconds(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
