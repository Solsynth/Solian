//
//  AccountSessionsView.swift
//  Solian Watch App
//
//  The account's active auth sessions: where the user is signed in, with
//  per-session sign-out and a "sign out all other sessions" action. Mirrors the
//  app's session manager (`lib/accounts/widgets/account/account_devices.dart`)
//  against `GET /stargate/sessions` and `DELETE /stargate/sessions/{id}`.
//

import SwiftUI
import WatchKit

struct AccountSessionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var sessions: [SnAuthSession] = []
    @State private var isLoading = true
    @State private var error: Error?
    @State private var statusText: String?
    @State private var actionError: String?
    @State private var sessionToRevoke: SnAuthSession?
    @State private var isConfirmingSignOutOthers = false
    @State private var isRevoking = false

    private let networkService = NetworkService()

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding()
            } else if let error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(L10n.accountSessionsLoadFailed)
                        .font(.caption)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button(L10n.accountSessionsRetry) {
                        Task { await load() }
                    }
                    .font(.caption)
                }
                .padding()
            } else if sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "key.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(L10n.accountSessionsEmpty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if let statusText {
                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    // A failed revoke must not hide the list — the user needs to
                    // see which sessions are still live.
                    if let actionError {
                        Text(actionError)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    Text(L10n.accountSessionsDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ForEach(orderedSessions) { session in
                        sessionRow(session)
                    }

                    // Only meaningful when another session exists to end.
                    if sessions.contains(where: { !$0.isCurrent }) {
                        Button(role: .destructive) {
                            WKInterfaceDevice.current().play(.click)
                            isConfirmingSignOutOthers = true
                        } label: {
                            Label(L10n.accountSessionsSignOutOthers, systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(isRevoking)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(L10n.accountSessionsTitle)
        .confirmationDialog(
            L10n.accountSessionsRevokeTitle,
            isPresented: Binding(
                get: { sessionToRevoke != nil },
                set: { if !$0 { sessionToRevoke = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.accountSessionsSignOut, role: .destructive) {
                if let session = sessionToRevoke {
                    sessionToRevoke = nil
                    Task { await revoke(session) }
                }
            }
            Button(L10n.accountCancel, role: .cancel) {
                sessionToRevoke = nil
            }
        } message: {
            Text(sessionToRevoke?.displayName ?? L10n.accountSessionsUnknownDevice)
        }
        .confirmationDialog(
            L10n.accountSessionsSignOutOthers,
            isPresented: $isConfirmingSignOutOthers,
            titleVisibility: .visible
        ) {
            Button(L10n.accountSessionsSignOut, role: .destructive) {
                Task { await revokeOthers() }
            }
            Button(L10n.accountCancel, role: .cancel) {}
        } message: {
            Text(L10n.accountSessionsSignOutOthersMessage)
        }
        .task { await load() }
    }

    // MARK: - Rows

    /// Current session first, then most recently active — the user's own
    /// session is the one they are most likely looking for.
    private var orderedSessions: [SnAuthSession] {
        sessions.sorted { lhs, rhs in
            if lhs.isCurrent != rhs.isCurrent { return lhs.isCurrent }
            return (lhs.lastGrantedAt ?? .distantPast) > (rhs.lastGrantedAt ?? .distantPast)
        }
    }

    @ViewBuilder
    private func sessionRow(_ session: SnAuthSession) -> some View {
        if session.isCurrent {
            // Not revocable: ending this session is a sign-out, which the
            // account page owns.
            sessionCard(session)
        } else {
            Button {
                WKInterfaceDevice.current().play(.click)
                sessionToRevoke = session
            } label: {
                sessionCard(session)
            }
            .buttonStyle(.plain)
            .disabled(isRevoking)
        }
    }

    private func sessionCard(_ session: SnAuthSession) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(session.isCurrent ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: Self.icon(for: session.type))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(session.isCurrent ? Color.accentColor : Color.secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(session.displayName ?? L10n.accountSessionsUnknownDevice)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    if session.isCurrent {
                        Text(L10n.accountSessionsCurrent)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.accentColor, in: Capsule())
                    } else if session.trusted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.green)
                            .accessibilityLabel(L10n.accountSessionsTrusted)
                    }
                    Spacer(minLength: 0)
                }

                if let lastActive = session.lastGrantedAt {
                    Text(String(format: L10n.accountSessionsLastActive, lastActive.formatted(.relative(presentation: .named))))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let location = session.displayLocation {
                    Text(location)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if let ip = session.ipAddress, !ip.isEmpty {
                    Text(ip)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
        .opacity(isRevoking ? 0.5 : 1)
        .accessibilityElement(children: .combine)
    }

    /// Session type → SF Symbol. Mirrors the app's `_getSessionTypeIcon`.
    private static func icon(for type: Int) -> String {
        switch type {
        case 0: return "key.fill"          // Login
        case 1: return "link"              // OAuth
        case 2: return "person.crop.circle" // OIDC
        default: return "key.fill"
        }
    }

    // MARK: - Actions

    private func load() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        error = nil
        do {
            sessions = try await networkService.fetchSessions(token: token, serverUrl: serverUrl)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    private func revoke(_ session: SnAuthSession) async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isRevoking = true
        statusText = nil
        actionError = nil
        defer { isRevoking = false }
        do {
            try await networkService.revokeSession(id: session.id, token: token, serverUrl: serverUrl)
            sessions.removeAll { $0.id == session.id }
            statusText = L10n.accountSessionsRevoked
            WKInterfaceDevice.current().play(.success)
        } catch {
            actionError = error.localizedDescription
            WKInterfaceDevice.current().play(.failure)
        }
    }

    private func revokeOthers() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isRevoking = true
        statusText = nil
        actionError = nil
        defer { isRevoking = false }
        do {
            try await networkService.revokeOtherSessions(token: token, serverUrl: serverUrl)
            sessions = try await networkService.fetchSessions(token: token, serverUrl: serverUrl)
            statusText = L10n.accountSessionsOthersRevoked
            WKInterfaceDevice.current().play(.success)
        } catch {
            actionError = error.localizedDescription
            WKInterfaceDevice.current().play(.failure)
        }
    }
}

#Preview {
    AccountSessionsView()
        .environmentObject(AppState())
}
