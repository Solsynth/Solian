//
//  StatusCreationView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/30.
//

import SwiftUI

struct StatusCreationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let initialStatus: SnAccountStatus?
    
    @State private var attitude: Int
    @State private var isInvisible: Bool
    @State private var isNotDisturb: Bool
    @State private var label: String
    @State private var isSubmitting: Bool = false
    @State private var error: Error? = nil
    
    private let networkService = NetworkService()
    
    init(initialStatus: SnAccountStatus? = nil) {
        self.initialStatus = initialStatus
        _attitude = State(initialValue: initialStatus?.attitude ?? 1)
        _isInvisible = State(initialValue: initialStatus?.isInvisible ?? false)
        _isNotDisturb = State(initialValue: initialStatus?.isNotDisturb ?? false)
        _label = State(initialValue: initialStatus?.label ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title
                Text("Set Status")
                    .font(.headline)
                    .padding(.top)
                
                // Label TextField
                TextField("Status label", text: $label)
                    .textFieldStyle(.automatic)
                    .padding(.horizontal)
                
                // Attitude Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mood")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Attitude", selection: $attitude) {
                        Text("😊 Positive").tag(0)
                        Text("😐 Neutral").tag(1)
                        Text("😢 Negative").tag(2)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
                .padding(.horizontal)
                
                // Toggles
                VStack(spacing: 12) {
                    Toggle("Invisible", isOn: $isInvisible)
                        .padding(.horizontal)
                    
                    Toggle("Do Not Disturb", isOn: $isNotDisturb)
                        .padding(.horizontal)
                }
                
                // Error message
                if let error = error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.automatic)
                    
                    Button(isSubmitting ? "Saving..." : "Save") {
                        Task {
                            await submitStatus()
                        }
                    }
                    .buttonStyle(.automatic)
                    .disabled(isSubmitting)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Status")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func submitStatus() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            error = NSError(domain: "StatusCreationView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication not available"])
            return
        }
        
        isSubmitting = true
        error = nil
        
        do {
            _ = try await networkService.createOrUpdateStatus(
                attitude: attitude,
                isInvisible: isInvisible,
                isNotDisturb: isNotDisturb,
                label: label.isEmpty ? nil : label,
                token: token,
                serverUrl: serverUrl
            )
            dismiss()
        } catch {
            self.error = error
        }
        
        isSubmitting = false
    }
}

#Preview {
    StatusCreationView()
        .environmentObject(AppState())
}
