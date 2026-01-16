//
//  DeepLinkHandler.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import Foundation
import UIKit

final class DeepLinkHandler {
    static let shared = DeepLinkHandler()

    private init() {}

    func handle(url: URL) -> Bool {
        guard url.scheme == SharedConstants.urlScheme else {
            return false
        }

        let host = url.host ?? ""
        let path = url.path
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

        switch host {
        case "chat":
            if let channelId = url.pathComponents.count > 1 ? url.pathComponents[1] : nil {
                openUrl("solian://chat/\(channelId)")
                return true
            }

        case "posts":
            if let postId = url.pathComponents.count > 1 ? url.pathComponents[1] : nil {
                openUrl("solian://posts/\(postId)")
                return true
            }

        case "search":
            if let query = queryItems?.first(where: { $0.name == "query" })?.value {
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
                openUrl("solian://search?q=\(encodedQuery)")
                return true
            }

        case "notifications":
            openUrl("solian://notifications")
            return true

        case "compose":
            openUrl("solian://compose")
            return true

        default:
            if path.hasPrefix("/chat/") {
                let channelId = path.replacingOccurrences(of: "/chat/", with: "")
                openUrl("solian://chat/\(channelId)")
                return true
            }
            if path.hasPrefix("/posts/") {
                let postId = path.replacingOccurrences(of: "/posts/", with: "")
                openUrl("solian://posts/\(postId)")
                return true
            }
            if path.hasPrefix("/search") {
                let query = queryItems?.first(where: { $0.name == "q" })?.value ?? ""
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
                openUrl("solian://search?q=\(encodedQuery)")
                return true
            }
            if path == "/notifications" {
                openUrl("solian://notifications")
                return true
            }
            if path.hasPrefix("/compose") || path == "/compose" {
                openUrl("solian://compose")
                return true
            }
            if path.hasPrefix("/dashboard") {
                openUrl("solian://dashboard")
                return true
            }
        }

        return false
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("[DeepLinkHandler] Invalid URL: \(urlString)")
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                if success {
                    print("[DeepLinkHandler] Opened URL: \(urlString)")
                } else {
                    print("[DeepLinkHandler] Failed to open URL: \(urlString)")
                }
            }
        }
    }
}
