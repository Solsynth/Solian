//
//  ComposePostView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import WatchKit

struct ComposePostView: View {
    /// The post being replied to (shown in the composer header).
    let replyingTo: SnPost?
    /// The post being quoted/forwarded (shown in the composer header).
    let forwardingTo: SnPost?

    @StateObject private var viewModel = ComposePostViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isContentFocused: Bool
    @State private var showVisibilityPicker = false

    private let visibilityOptions = [L10n.composeVisibilityPublic, L10n.composeVisibilityFriends, L10n.composeVisibilityUnlisted, L10n.composeVisibilityPrivate]

    init(
        replyingTo: SnPost? = nil,
        forwardingTo: SnPost? = nil
    ) {
        self.replyingTo = replyingTo
        self.forwardingTo = forwardingTo
        // Seed the anchors before the first render so the composer knows its
        // mode (reply vs forward) from the start.
        let vm = ComposePostViewModel()
        vm.replyToPostId = replyingTo?.id
        vm.forwardPostId = forwardingTo?.id
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.mode == .forward, let forwardingTo {
                        forwardIndicator(for: forwardingTo)
                    } else if replyingTo != nil {
                        replyIndicator
                    }

                    contentField

                    // Quote-forwards are anchored posts; visibility stays the
                    // default for them (main app keeps quotes public).
                    if viewModel.mode == .reply || viewModel.mode == .newPost {
                        visibilityField
                    }

                    if viewModel.isPosting {
                        postingIndicator
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                // Send lives top-right (one-handed reach, mirrors the explore
                // compose toggle). No bottom action bar.
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await post() }
                    } label: {
                        if viewModel.isPosting {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .disabled(!canSend)
                }
            }
            .onChange(of: viewModel.didPost) { _, didPost in
                if didPost {
                    dismiss()
                }
            }
            .alert(L10n.composeError, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .confirmationDialog(L10n.composeSelectVisibility, isPresented: $showVisibilityPicker) {
                Button(L10n.composeVisibilityPublic) { viewModel.visibility = 0 }
                Button(L10n.composeVisibilityFriends) { viewModel.visibility = 1 }
                Button(L10n.composeVisibilityUnlisted) { viewModel.visibility = 2 }
                Button(L10n.composeVisibilityPrivate) { viewModel.visibility = 3 }
                Button(L10n.composeCancel, role: .cancel) {}
            }
        }
    }

    private var navigationTitle: String {
        switch viewModel.mode {
        case .forward: return L10n.composeForward
        case .reply: return L10n.composeReply
        case .newPost: return L10n.composeNewPost
        }
    }

    private var canSend: Bool {
        !viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isPosting
    }

    private var visibilitySymbol: String {
        switch viewModel.visibility {
        case 0: return "globe"
        case 1: return "person.2"
        case 2: return "eye.slash"
        default: return "lock"
        }
    }

    private var replyIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.turn.up.left")
                .font(.caption)
            Text(L10n.composeReplyingTo)
                .font(.caption)
            if let nick = replyingTo?.publisher?.nick ?? replyingTo?.publisher?.name {
                Text("@\(nick)")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }

    /// Quote header for the forwarded post — the quoted post's author plus a
    /// short preview. Tapping loads the full detail of the quoted post.
    private func forwardIndicator(for context: SnPost) -> some View {
        NavigationLink(
            destination: PostDetailView(post: context)
                .environmentObject(appState)
        ) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.caption)
                    Text(L10n.composeForwarding)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 4)
                    Text("@\(context.publisher?.nick ?? context.publisher?.name ?? "post")")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                }
                if let title = context.title, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .bold()
                        .lineLimit(2)
                } else if let content = context.content, !content.isEmpty {
                    Text(content)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.08))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var contentField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.composeContent)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(L10n.composeContentPlaceholder, text: $viewModel.content, axis: .vertical)
                .font(.body)
                .focused($isContentFocused)
                .lineLimit(3...6)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }

    private var visibilityField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.composeVisibility)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                showVisibilityPicker = true
            } label: {
                HStack {
                    Image(systemName: visibilitySymbol)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text(visibilityOptions[viewModel.visibility])
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }

    private var postingIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
            Text(L10n.composePosting)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }

    @MainActor
    private func post() async {
        WKInterfaceDevice.current().play(.click)
        await viewModel.createPost(
            token: appState.token ?? "",
            serverUrl: appState.serverUrl ?? ""
        )
        if viewModel.didPost {
            WKInterfaceDevice.current().play(.success)
        } else if viewModel.errorMessage != nil {
            WKInterfaceDevice.current().play(.failure)
        }
    }
}
