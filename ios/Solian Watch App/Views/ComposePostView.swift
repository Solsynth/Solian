//
//  ComposePostView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
import WatchKit

struct ComposePostView: View {
    let replyingTo: SnPost?
    @StateObject private var viewModel = ComposePostViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isContentFocused: Bool
    @State private var showVisibilityPicker = false

    private let visibilityOptions = ["Public", "Friends", "Unlisted", "Private"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if replyingTo != nil {
                        replyIndicator
                    }

                    contentField

                    visibilityField

                    if viewModel.isPosting {
                        postingIndicator
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .navigationTitle(replyingTo != nil ? "Reply" : "New Post")
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
                // Bottom-of-detail action button is the discoverable send on
                // watchOS; keep the top-right icon too for one-handed reach.
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await post() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isPosting)
                }
            }
            .safeAreaInset(edge: .bottom) {
                sendBar
            }
            .onChange(of: viewModel.didPost) { _, didPost in
                if didPost {
                    dismiss()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .confirmationDialog("Select Visibility", isPresented: $showVisibilityPicker) {
                Button("Public") { viewModel.visibility = 0 }
                Button("Friends") { viewModel.visibility = 1 }
                Button("Unlisted") { viewModel.visibility = 2 }
                Button("Private") { viewModel.visibility = 3 }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    /// Bottom action bar: the primary "Post" button + a visibility shortcut.
    private var sendBar: some View {
        HStack(spacing: 10) {
            Button {
                showVisibilityPicker = true
            } label: {
                Image(systemName: visibilitySymbol)
                    .font(.body)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .accessibilityLabel("Visibility \(visibilityOptions[viewModel.visibility])")

            Button {
                Task { await post() }
            } label: {
                if viewModel.isPosting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Post", systemImage: "paperplane.fill")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(
                viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || viewModel.isPosting
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
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
            Text("Replying to")
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

    private var contentField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Content")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("What's on your mind?", text: $viewModel.content, axis: .vertical)
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
            Text("Visibility")
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
            Text("Posting...")
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
