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
    @State private var statusType: Int
    @State private var clearedAt: Date?
    @State private var label: String
    @State private var symbol: String
    @State private var isSubmitting: Bool = false
    @State private var error: Error? = nil
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    private let networkService = NetworkService()
    
    init(initialStatus: SnAccountStatus? = nil) {
        self.initialStatus = initialStatus
        _attitude = State(initialValue: initialStatus?.attitude ?? 1)
        _statusType = State(initialValue: initialStatus?.type ?? 0)
        _clearedAt = State(initialValue: initialStatus?.clearedAt)
        _label = State(initialValue: initialStatus?.label ?? "")
        _symbol = State(initialValue: initialStatus?.symbol ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title
                Text(initialStatus == nil ? "Set Status" : "Update Status")
                    .font(.headline)
                    .padding(.top)
                
                // Label TextField
                TextField("Status label", text: $label)
                    .textFieldStyle(.automatic)
                    .padding(.horizontal)
                
                // Symbol TextField
                TextField("Status symbol", text: $symbol)
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
                
                // Status Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Visibility")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Status Type", selection: $statusType) {
                        Text("Online").tag(0)
                        Text("Busy").tag(1)
                        Text("Do Not Disturb").tag(2)
                        Text("Invisible").tag(3)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
                .padding(.horizontal)
                
                // Clear Time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auto-clear time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let clearedAt = clearedAt {
                        HStack {
                            Text(DateFormatter.localizedString(from: clearedAt, dateStyle: .medium, timeStyle: .short))
                            Spacer()
                            Button(action: { self.clearedAt = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Button("No auto-clear") {
                            showDatePickerSheet()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
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
                
                // Delete button for existing status
                if initialStatus != nil {
                    Button(role: .destructive) {
                        Task {
                            await clearStatus()
                        }
                    } label: {
                        Text("Delete Status")
                    }
                    .disabled(isSubmitting)
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle("Status")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func showDatePickerSheet() {
        let now = Date()
        let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: now) ?? now
        
        // For watchOS, we use a simple approach - just set a default future time
        // The actual date/time picker would be a separate sheet
        clearedAt = Calendar.current.date(byAdding: .hour, value: 24, to: now)
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
                statusType: statusType,
                clearedAt: clearedAt,
                label: label.isEmpty ? nil : label,
                symbol: symbol.isEmpty ? nil : symbol,
                token: token,
                serverUrl: serverUrl
            )
            dismiss()
        } catch {
            self.error = error
        }
        
        isSubmitting = false
    }
    
    private func clearStatus() async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            error = NSError(domain: "StatusCreationView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication not available"])
            return
        }
        
        isSubmitting = true
        error = nil
        
        do {
            try await networkService.clearStatus(token: token, serverUrl: serverUrl)
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