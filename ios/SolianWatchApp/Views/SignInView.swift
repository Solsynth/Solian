//
//  SignInView.swift
//  Watch Runner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  Standalone onboarding + sign-in via the OAuth device authorization flow.
//  The server URL is never typed: it defaults to the public instance and is
//  overridden by the companion app's shared group when one is configured.
//
//  Flow:  welcome → (start) → approve here in the watch's web sheet, on the
//  paired iPhone, or by entering the code on another device → done.
//

import SwiftUI
import WatchKit
import WatchConnectivity

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var phase: Phase = .welcome
    @State private var serverUrl = ""
    @State private var device: StandaloneAuthService.DeviceCode?
    @State private var statusText = ""
    @State private var isBusy = false
    @State private var errorText: String?

    /// Presents the device-approval page in the watch's own web sheet.
    @StateObject private var webPresenter = InAppWebPresenter()
    /// The device-flow polling loop; cancelled when the user backs out.
    @State private var pollTask: Task<Void, Never>?

    private let auth = StandaloneAuthService.shared
    private let defaultServerUrl = "https://api.solian.app"

    enum Phase {
        case welcome
        case starting
        case awaitingApproval
        case signingIn
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    switch phase {
                    case .welcome:
                        welcomeView
                    case .starting, .signingIn:
                        HStack {
                            Spacer()
                            ProgressView(phase == .signingIn ? L10n.signInSigningIn : L10n.signInStarting)
                            Spacer()
                        }
                        .padding(.vertical, 24)
                    case .awaitingApproval:
                        approvalView
                    }
                }
                .padding()
                .id(Self.PhaseTopID)
            }
            // A phase change replaces the whole stack; without this the scroll
            // offset from the previous phase carries over and pushes the new
            // content under the navigation bar.
            .onChange(of: phase) { _, _ in
                proxy.scrollTo(Self.PhaseTopID, anchor: .top)
            }
            // The web sheet's status line only describes the sheet; once the
            // user closes it, fall back to the neutral prompt.
            .onChange(of: webPresenter.isPresenting) { _, presenting in
                if !presenting, phase == .awaitingApproval, statusText == L10n.signInApproveInBrowser {
                    statusText = ""
                }
            }
        }
        .navigationTitle(phase == .awaitingApproval ? L10n.signInApprovePrompt : L10n.signInTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resolveServerUrl()
        }
        .onDisappear {
            // Leaving the screen ends both the polling loop and any web sheet
            // it opened.
            pollTask?.cancel()
            pollTask = nil
            webPresenter.cancel()
        }
    }

    /// Scroll anchor for the phase container.
    private static let PhaseTopID = "signin.phase.top"

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "applewatch")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .padding(.top, 8)
                .accessibilityHidden(true)

            Text(L10n.signInWelcomeTitle)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)

            Text(L10n.signInWelcomeSubtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)

            if !serverUrl.isEmpty {
                Text(serverUrl.replacingOccurrences(of: "https://", with: ""))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                WKInterfaceDevice.current().play(.click)
                Task { await beginFlow() }
            } label: {
                Text(L10n.signInGetStarted)
                    .font(.body)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isBusy)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Approval

    private var approvalView: some View {
        VStack(alignment: .center, spacing: 8) {
            if let device {
                // The instruction lives in the navigation title, so this line
                // appears only when it has something to report (approved on
                // phone, sheet opened, error). On a 40mm screen that reclaimed
                // space is what keeps the actions above the fold.
                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // The code must read as one unbroken token — wrap it and the
                // user can no longer copy it across in one glance.
                Text(device.userCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.gray.opacity(0.18))
                    )
                    .accessibilityLabel(L10n.signInUserCode(device.userCode))

                Button {
                    WKInterfaceDevice.current().play(.click)
                    approveHere()
                } label: {
                    Label(L10n.signInApproveHere, systemImage: "globe")
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(webPresenter.isPresenting)

                if let errorText {
                    Text(errorText)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Secondary actions share one row: on a 40mm screen the full
                // stack of code + three buttons would not fit above the fold.
                HStack(spacing: 8) {
                    if let url = URL(string: device.verificationUri) {
                        Button {
                            WKInterfaceDevice.current().play(.click)
                            // Hands the verification page to the paired iPhone,
                            // where the user can approve with an existing
                            // session.
                            WKExtension.shared().openSystemURL(url)
                        } label: {
                            Label(L10n.signInPhoneButton, systemImage: "iphone")
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel(L10n.signInApproveOnPhoneButton)
                    }

                    Button(L10n.signInCancel) {
                        WKInterfaceDevice.current().play(.click)
                        resetToWelcome()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Opens the device-approval page in the watch's own web sheet. The polling
    /// loop is already running, so approval on the page completes sign-in
    /// without any further interaction here.
    private func approveHere() {
        guard let device else { return }
        let urlString = device.verificationUriComplete ?? device.verificationUri
        guard let url = URL(string: urlString) else { return }
        statusText = L10n.signInApproveInBrowser
        // Not ephemeral: a sign-in should join the existing web session so
        // already-signed-in cookies are reused.
        if !webPresenter.present(url: url, ephemeral: false) {
            statusText = L10n.signInApproveOnPhone
        }
    }

    // MARK: - Server resolution

    private func resolveServerUrl() {
        guard serverUrl.isEmpty else { return }
        // Prefer the companion app's configured instance; fall back to the
        // public default. Never a manual field.
        if let shared = UserDefaults(suiteName: "group.solsynth.solian"),
           let stored = shared.string(forKey: "flutter.app_server_url"),
           !stored.isEmpty {
            serverUrl = stored
        } else {
            serverUrl = defaultServerUrl
        }
    }

    // MARK: - Flow

    private func beginFlow() async {
        isBusy = true
        errorText = nil
        do {
            let deviceCode = try await auth.startDeviceFlow(serverUrl: serverUrl)
            device = deviceCode
            phase = .awaitingApproval

            // Phone reachable? Hand the code over so it can approve directly
            // (or open the verification page) and say so. Otherwise the code
            // stands on its own: the user can approve from this watch's web
            // sheet, or type the code on any other signed-in device.
            statusText = ""
            await askPhoneToApprove(deviceCode)

            // Poll in the background so the approval buttons stay live while a
            // web sheet is on screen.
            pollTask?.cancel()
            pollTask = Task { @MainActor in
                await poll(deviceCode)
            }
        } catch {
            errorText = error.localizedDescription
            phase = .welcome
        }
        isBusy = false
    }

    // MARK: - Phone assist (Watch Connectivity)

    /// Sends the device code to the paired iPhone, which approves it directly
    /// when it holds a session, or opens the verification page otherwise. Does
    /// nothing when no phone is reachable — the watch's own approval path then
    /// takes over. Updates `statusText` with the outcome.
    @MainActor
    private func askPhoneToApprove(_ device: StandaloneAuthService.DeviceCode) async {
        let wc = WCSession.default
        guard wc.isReachable else { return }
        do {
            let reply = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[String: Any], Error>) in
                wc.sendMessage([
                    "request": "deviceAuth",
                    "verification_uri": device.verificationUri,
                    "user_code": device.userCode,
                ]) { response in
                    cont.resume(returning: response)
                } errorHandler: { error in
                    cont.resume(throwing: error)
                }
            }
            if reply["approved"] as? Bool == true {
                statusText = L10n.signInApprovedOnPhone
            } else {
                statusText = L10n.signInApproveOnPhone
            }
        } catch {
            print("[watchOS] deviceAuth to phone failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func poll(_ deviceCode: StandaloneAuthService.DeviceCode) async {
        defer { pollTask = nil }
        do {
            let pair = try await auth.pollForToken(
                deviceCode: deviceCode.deviceCode,
                interval: deviceCode.interval,
                serverUrl: serverUrl
            )
            guard !pair.accessToken.isEmpty else { return }
            phase = .signingIn
            // Approval may have happened in the watch's own web sheet: close it.
            webPresenter.cancel()
            await appState.finishStandaloneSignIn(auth: auth, serverUrl: serverUrl)
        } catch is CancellationError {
            return
        } catch StandaloneAuthError.polling(.expiredToken) {
            errorText = L10n.signInTimedOut
            phase = .welcome
        } catch {
            errorText = error.localizedDescription
            phase = .welcome
        }
    }

    private func resetToWelcome() {
        pollTask?.cancel()
        pollTask = nil
        webPresenter.cancel()
        device = nil
        phase = .welcome
        statusText = ""
        errorText = nil
    }
}
