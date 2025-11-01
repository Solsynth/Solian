//
//  ComposePostView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

struct ComposePostView: View {
    @StateObject private var viewModel = ComposePostViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $viewModel.title)
                TextField("Content", text: $viewModel.content)
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post", systemImage: "square.and.arrow.up") {
                        Task {
                            if let token = appState.token, let serverUrl = appState.serverUrl {
                                await viewModel.createPost(token: token, serverUrl: serverUrl)
                            }
                        }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(viewModel.isPosting)
                }
            }
            .onChange(of: viewModel.didPost) {
                if viewModel.didPost {
                    dismiss()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}
