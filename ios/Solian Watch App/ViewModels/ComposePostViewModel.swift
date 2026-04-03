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
    
    var replyToPostId: String? = nil
    
    private let networkService = NetworkService()
    
    func createPost(token: String, serverUrl: String) async {
        guard !isPosting else { return }
        guard !content.isEmpty else { return }
        isPosting = true
        errorMessage = nil
        
        do {
            if let replyToId = replyToPostId {
                try await networkService.replyToPost(
                    postId: replyToId,
                    content: content,
                    visibility: visibility,
                    token: token,
                    serverUrl: serverUrl
                )
            } else {
                try await networkService.createPost(
                    content: content,
                    visibility: visibility,
                    token: token,
                    serverUrl: serverUrl
                )
            }
            didPost = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isPosting = false
    }
}