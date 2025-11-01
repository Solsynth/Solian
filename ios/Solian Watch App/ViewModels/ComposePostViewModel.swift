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
    @Published var title = ""
    @Published var content = ""
    @Published var isPosting = false
    @Published var errorMessage: String?
    @Published var didPost = false

    private let networkService = NetworkService()

    func createPost(token: String, serverUrl: String) async {
        guard !isPosting else { return }
        isPosting = true
        errorMessage = nil

        do {
            try await networkService.createPost(title: title, content: content, token: token, serverUrl: serverUrl)
            didPost = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isPosting = false
    }
}
