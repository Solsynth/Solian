import SwiftUI

struct ImageViewer: View {
    let imageUrl: URL
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var imageLoader = ImageLoader()
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if imageLoader.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Loading...")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else if let image = imageLoader.image {
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.3)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                }
                            }
                        }
                        .onTapGesture(count: 1) {
                            // Tap to toggle zoom between 1x and 2.5x
                            withAnimation(.spring(response: 0.3)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                }
                            }
                        }
                        .focusable()
                        .digitalCrownRotation(
                            Binding(
                                get: { scale },
                                set: { newValue in
                                    scale = min(max(newValue, 0.5), 4.0)
                                }
                            ),
                            from: 0.5,
                            through: 4.0,
                            by: 0.25,
                            sensitivity: .medium
                        )
                }
            } else if let errorMessage = imageLoader.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text("Failed to load")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            if let token = appState.token {
                                await imageLoader.loadImage(from: imageUrl, token: token)
                            }
                        }
                    }
                    .font(.caption)
                    .padding(.top, 8)
                }
                .padding()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            scale = max(scale - 0.5, 0.5)
                            if scale < 1.0 {
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 36, height: 36)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    
                    Text("\(Int(scale * 100))%")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(minWidth: 50)
                        .padding(.horizontal, 8)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            scale = min(scale + 0.5, 4.0)
                        }
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 36, height: 36)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .task(id: imageUrl) {
            if let token = appState.token {
                await imageLoader.loadImage(from: imageUrl, token: token)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 && scale <= 1.0 {
                        dismiss()
                    }
                }
        )
    }
}