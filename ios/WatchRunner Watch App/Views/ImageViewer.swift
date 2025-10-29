import SwiftUI

struct ImageViewer: View {
    let imageUrl: URL
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if imageLoader.isLoading {
                ProgressView()
            } else if let image = imageLoader.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaledToFit()
            } else if let errorMessage = imageLoader.errorMessage {
                Text("Failed to load image: \(errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("Failed to load image.")
            }
        }
        .task(id: imageUrl) {
            if let token = appState.token {
                await imageLoader.loadImage(from: imageUrl, token: token)
            }
        }
        .navigationTitle("Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}
