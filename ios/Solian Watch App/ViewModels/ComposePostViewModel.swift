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
    /// Cloud-file attachments staged for the post (uploaded or already-cloud).
    /// Uploading happens on-demand when a local file is added; the id is the
    /// wire `attachments` array element.
    @Published private(set) var attachments: [SnCloudFile] = []
    /// True while a local file is being uploaded to Drive (`usage: "post"`).
    @Published var isUploading = false
    /// One-line upload/attachment message shown under the toolbar.
    @Published var uploadMessage: String?

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

    /// Whether the composer has anything worth sending: text or attachments.
    var canSend: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty
    }

    /// Adds an already-cloud file (the "link a cloud image" path) without
    /// re-uploading.
    func addCloudAttachment(_ file: SnCloudFile) {
        guard !attachments.contains(where: { $0.id == file.id }) else { return }
        attachments.append(file)
        uploadMessage = file.name.isEmpty ? nil : file.name
    }

    /// Uploads a local file to Drive with `usage: "post"`, then stages the
    /// returned cloud file. Mirrors Flutter's compose upload loop.
    func uploadAndAdd(_ fileURL: URL, contentType: String, token: String, serverUrl: String) async {
        guard !isUploading else { return }
        isUploading = true
        uploadMessage = nil
        defer { isUploading = false }

        do {
            let cloudFile = try await networkService.uploadCloudFile(
                fileURL: fileURL,
                contentType: contentType,
                usage: "post",
                token: token,
                serverUrl: serverUrl
            )
            addCloudAttachment(cloudFile)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Removes a staged attachment (also by id, for newly-uploaded ones).
    func removeAttachment(_ id: String) {
        attachments.removeAll { $0.id == id }
    }

    func createPost(token: String, serverUrl: String) async {
        guard !isPosting else { return }
        guard !content.isEmpty || !attachments.isEmpty else { return }
        isPosting = true
        errorMessage = nil

        do {
            try await networkService.createPost(
                content: content,
                visibility: visibility,
                attachments: attachments.map(\.id),
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
