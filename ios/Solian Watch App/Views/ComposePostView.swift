//
//  ComposePostView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

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
                VStack(alignment: .leading, spacing: 16) {
                    if replyingTo != nil {
                        replyIndicator
                    }
                    
                    contentField
                    
                    visibilityField
                    
                    if viewModel.isPosting {
                        postingIndicator
                    }
                }
                .padding()
            }
            .navigationTitle(replyingTo != nil ? "Reply" : "New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.createPost(
                                token: appState.token ?? "",
                                serverUrl: appState.serverUrl ?? ""
                            )
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.content.isEmpty || viewModel.isPosting)
                }
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
            HStack {
                Text("Content")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    isContentFocused = true
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            
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
                    Text(visibilityOptions[viewModel.visibility])
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
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
}