//
//  ComposePostViewModel.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation
import Combine

@MainActor
class ComposePostViewModel: ObservableObject {
    @Published var content = ""
    @Published var visibility = 0
    @Published var isPosting = false
    @Published var errorMessage: String?
    @Published var didPost = false
    
    /// The post being directly replied to (wire `replied_post_id`).
    var replyToPostId: String? = nil
    /// The post being quoted/forwarded (wire `forwarded_post_id`).
    var forwardPostId: String? = nil

    var mode: ComposeMode {
        if forwardPostId != nil { return .forward }
        if replyToPostId != nil { return .reply }
        return .newPost
    }
    
    private let networkService = NetworkService()
    
    func createPost(token: String, serverUrl: String) async {
        guard !isPosting else { return }
        guard !content.isEmpty else { return }
        isPosting = true
        errorMessage = nil
        
        do {
            try await networkService.createPost(
                content: content,
                visibility: visibility,
                replyTo: replyToPostId,
                forwardTo: forwardPostId,
                token: token,
                serverUrl: serverUrl
            )
            didPost = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isPosting = false
    }
}

/// What the compose flow is anchored to: a fresh post, a reply to an existing
/// post, or a quote/forward of an existing post.
enum ComposeMode {
    case newPost
    case reply
    case forward
}