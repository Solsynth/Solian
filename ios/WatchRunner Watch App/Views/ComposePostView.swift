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
                    .frame(height: 100)
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            if let token = appState.token, let serverUrl = appState.serverUrl {
                                await viewModel.createPost(token: token, serverUrl: serverUrl)
                            }
                        }
                    }
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
