//
//  InAppWebView.swift
//  WatchRunner Watch App
//
//  Presents a web page on watchOS using `ASWebAuthenticationSession` — the one
//  sanctioned in-app web presenter on watch (the watchOS SDK ships
//  `AuthenticationServices` but not `WKWebView` / `SafariServices`). It drives
//  the same signed web session with an opaque callback; the user can browse and
//  dismiss via the sheet's cancel control.
//
//  Also used by `SignInView` to approve an OAuth device-flow sign-in on the
//  watch itself instead of on the paired iPhone.
//

import SwiftUI
import Combine
import AuthenticationServices

/// A thin observable wrapper around `ASWebAuthenticationSession` so SwiftUI
/// views can launch it and observe whether the sheet is active. A single
/// session is presented at a time; presenting again replaces it.
@MainActor
final class InAppWebPresenter: NSObject, ObservableObject {
    @Published private(set) var isPresenting = false

    private var session: ASWebAuthenticationSession?
    /// Bumped whenever a session is replaced or cancelled, so a stale session's
    /// completion handler can't clear the state of a newer one.
    private var generation = 0

    /// Presents `url` in the system web sheet. Returns `false` when the sheet
    /// can't be started (non-http(s) URL, or the system refused to present it).
    ///
    /// - Parameter ephemeral: `true` (the default) gives the sheet a throwaway
    ///   cookie jar — right for merely reading a page. Pass `false` for a
    ///   sign-in so the sheet joins the watch's web session and can reuse any
    ///   cookies the user already has.
    @discardableResult
    func present(url: URL, ephemeral: Bool = true) -> Bool {
        let http = url.scheme == "http" || url.scheme == "https"
        guard http else {
            print("[watchOS] ASWebAuthenticationSession only supports http(s) URLs")
            return false
        }
        // A callback scheme is required by the API. It only matters when the
        // page redirects to it (e.g. an OAuth callback); a plain page — and the
        // device-approval flow, which completes by polling — simply ends when
        // the user dismisses the sheet.
        cancel()
        generation += 1
        let gen = generation
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "solian",
            completionHandler: { [weak self] _, error in
                Task { @MainActor in
                    guard let self, self.generation == gen else { return }
                    self.isPresenting = false
                    self.session = nil
                    if let error {
                        print("[watchOS] Web session ended: \(error.localizedDescription)")
                    }
                }
            }
        )
        // Ephemeral sessions avoid the "this app wants to use your Apple ID"
        // privacy re-auth prompt when merely viewing a page.
        session.prefersEphemeralWebBrowserSession = ephemeral
        self.session = session
        let ok = session.start()
        isPresenting = ok
        return ok
    }

    /// Dismisses an active sheet — e.g. once the sign-in it was opened for has
    /// completed through another path. Safe to call when nothing is presented.
    func cancel() {
        guard let session else { return }
        self.session = nil
        isPresenting = false
        generation += 1
        session.cancel()
    }
}
