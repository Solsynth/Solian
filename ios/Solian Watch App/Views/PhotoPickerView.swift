//
//  PhotoPickerView.swift
//  WatchRunner Watch App
//
//  Watch photo picker for sending an image as a chat message. Wraps SwiftUI's
//  `.photosPicker(isPresented:selection:)` modifier, which auto-presents the
//  photo library as soon as the sheet appears — no intermediate "Choose Photo"
//  button. Once the user picks a photo it is loaded as JPEG data, written to a
//  temp file, and handed back for upload via `POST /drive/files/upload/direct`
//  + a message send carrying the file id.
//
//  Mirror of Flutter's `pickImages` → upload-then-send attachment flow.
//

import SwiftUI
import PhotosUI
import WatchKit

struct PhotoPickerView: View {
    /// Called with the picked image's temp-file URL once loading succeeds.
    let onSend: (URL) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var isPresented = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var isSending = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 18) {
            if isLoading || isSending {
                ProgressView()
                Text(isSending ? L10n.photoPickerSending : L10n.photoPickerLoading)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(L10n.photoPickerTryAgain) {
                        pickerItem = nil
                        isPresented = true
                    }
                    .font(.caption)
                }
            } else {
                // The picker auto-presents from `.onAppear`; this fallback only
                // shows transiently before presentation.
                Text(L10n.photoPickerChoosePhoto)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        // Auto-present the photo library as soon as the sheet appears.
        .photosPicker(isPresented: $isPresented, selection: $pickerItem, matching: .images)
        .onAppear {
            isPresented = true
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadAndSend(newItem) }
        }
    }

    /// Loads the picked photo as JPEG data, writes it to a temp file, and
    /// hands it back for upload. The picker sheet dismisses itself on pick.
    private func loadAndSend(_ item: PhotosPickerItem) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let data = try? await item.loadTransferable(type: Data.self) else {
            errorMessage = L10n.photoPickerCouldNotRead
            return
        }
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.85) else {
            errorMessage = L10n.photoPickerCouldNotProcess
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("chat-photo-\(UUID().uuidString.lowercased()).jpg")
        do {
            try jpegData.write(to: url)
        } catch {
            errorMessage = L10n.photoPickerCouldNotSave
            return
        }

        isSending = true
        onSend(url)
        // Let the send task (upload + chat POST) proceed; dismiss the sheet so
        // the optimistic bubble is visible while the upload finishes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            dismiss()
        }
    }
}
