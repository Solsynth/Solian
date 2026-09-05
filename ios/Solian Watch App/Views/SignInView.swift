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
//  Flow:  welcome → (start) → phone-assisted approval / on-watch code → done.
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

    private let auth = StandaloneAuthService.shared
    private let defaultServerUrl = "https://api.solian.app"

    enum Phase {
        case welcome
        case starting
        case awaitingApproval
        case signingIn
    }

    var body: some View {
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
        }
        .navigationTitle(L10n.signInTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resolveServerUrl()
        }
    }

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
        VStack(alignment: .leading, spacing: 12) {
            if let device {
                VStack(spacing: 4) {
                    Text(statusText.isEmpty
                         ? L10n.signInEnterCode
                         : statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Text(device.userCode)
                        .font(.system(.title, design: .monospaced))
                        .bold()
                        .accessibilityLabel("User code \(device.userCode)")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                if let url = URL(string: device.verificationUri) {
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        // Opens the verification page in the paired iPhone's
                        // browser.
                        WKExtension.shared().openSystemURL(url)
                    } label: {
                        Label(L10n.signInOpenVerification, systemImage: "safari")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if let errorText {
                    Text(errorText)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Button(L10n.signInCancel) {
                    WKInterfaceDevice.current().play(.click)
                    resetToWelcome()
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
            }
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
            // (or open the verification page). Otherwise show the code here.
            if await askPhoneToApprove(deviceCode) {
                statusText = ""
            } else {
                statusText = L10n.signInEnterCode
            }

            await poll(deviceCode)
        } catch {
            errorText = error.localizedDescription
            phase = .welcome
        }
        isBusy = false
    }

    // MARK: - Phone assist (Watch Connectivity)

    /// Sends the device code to the paired iPhone. Returns true when the phone
    /// handled the request; false when no phone is reachable.
    private func askPhoneToApprove(_ device: StandaloneAuthService.DeviceCode) async -> Bool {
        let wc = WCSession.default
        guard wc.isReachable else { return false }
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
            return true
        } catch {
            print("[watchOS] deviceAuth to phone failed: \(error.localizedDescription)")
            return false
        }
    }

    private func poll(_ deviceCode: StandaloneAuthService.DeviceCode) async {
        do {
            let pair = try await auth.pollForToken(
                deviceCode: deviceCode.deviceCode,
                interval: deviceCode.interval,
                serverUrl: serverUrl
            )
            guard !pair.accessToken.isEmpty else { return }
            phase = .signingIn
            try await appState.finishStandaloneSignIn(auth: auth, serverUrl: serverUrl)
        } catch StandaloneAuthError.polling(.authorizationPending) {
            statusText = L10n.signInTimedOut
        } catch {
            errorText = error.localizedDescription
            phase = .welcome
        }
    }

    private func resetToWelcome() {
        device = nil
        phase = .welcome
        statusText = ""
        errorText = nil
    }
}
