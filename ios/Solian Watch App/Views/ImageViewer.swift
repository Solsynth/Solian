import SwiftUI

struct ImageViewer: View {
    let imageUrl: URL
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var imageLoader = ImageLoader()

    @State private var scale: CGFloat = 1.0
    /// Base scale captured when a pinch gesture begins (the value the current
    /// magnification is applied to).
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    /// The clamped offset committed when the previous pan ended.
    @State private var lastOffset: CGSize = .zero
    /// The displayed viewport, captured from the GeometryReader so pan/zoom
    /// clamping knows how far an image can travel.
    @State private var viewportSize: CGSize = .zero
    /// Whether the control overlay is on screen. It auto-hides after a few
    /// seconds of no interaction and reappears on any tap / crown / zoom.
    @State private var controlsVisible = true
    /// The pending auto-hide task, cancelled and rescheduled on interaction.
    @State private var hideTask: Task<Void, Never>?

    private let hideDelayNanoseconds: UInt64 = 3_000_000_000

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if imageLoader.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text(L10n.imageViewerLoading)
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
                        .onAppear { viewportSize = geometry.size }
                        .onChange(of: geometry.size) { _, newSize in
                            viewportSize = newSize
                            offset = clampedOffset(offset, viewport: newSize)
                        }
                        // Pan only when zoomed; the offset is clamped so the
                        // image can't be dragged entirely off-screen.
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    guard scale > 1.0 else { return }
                                    offset = clampedOffset(
                                        CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        ),
                                        viewport: viewportSize
                                    )
                                    scheduleAutoHide()
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    scheduleAutoHide()
                                }
                        )
                        // Single tap toggles the control overlay; double tap
                        // toggles zoom. Both keep the controls visible.
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.3)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                    lastScale = 1.0
                                } else {
                                    scale = 2.5
                                    lastScale = 2.5
                                }
                            }
                            scheduleAutoHide()
                        }
                        .onTapGesture(count: 1) {
                            toggleControls()
                        }
                        .focusable()
                        .digitalCrownRotation(
                            Binding(
                                get: { scale },
                                set: { newValue in
                                    scale = min(max(newValue, 0.5), 4.0)
                                    lastScale = scale
                                    offset = clampedOffset(offset, viewport: viewportSize)
                                    if scale <= 1.0 {
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                    scheduleAutoHide()
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
                    Text(L10n.imageViewerFailedToLoad)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Button(L10n.imageViewerTryAgain) {
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

            // Control overlay: close button (top-right) and zoom bar (bottom).
            // Fades out on inactivity; reappears on any interaction.
            if controlsVisible, imageLoader.image != nil {
                controlOverlay
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .task(id: imageUrl) {
            if let token = appState.token {
                await imageLoader.loadImage(from: imageUrl, token: token)
            }
            scheduleAutoHide()
        }
        .onDisappear { hideTask?.cancel() }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 && scale <= 1.0 {
                        dismiss()
                    }
                }
        )
    }

    // MARK: Control overlay

    private var controlOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
                .background(.regularMaterial)
                .clipShape(Circle())
            }
            .padding(.horizontal, 10)
            .padding(.top, 6)

            Spacer()

            HStack(spacing: 8) {
                zoomButton(systemName: "minus.magnifyingglass") {
                    withAnimation(.spring(response: 0.3)) {
                        scale = max(scale - 0.5, 0.5)
                        lastScale = scale
                        offset = clampedOffset(offset, viewport: viewportSize)
                        if scale < 1.0 {
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                    scheduleAutoHide()
                }

                Text("\(Int(scale * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(minWidth: 34)
                    .padding(.horizontal, 6)
                    .background(.regularMaterial)
                    .clipShape(Capsule())

                zoomButton(systemName: "plus.magnifyingglass") {
                    withAnimation(.spring(response: 0.3)) {
                        scale = min(scale + 0.5, 4.0)
                        lastScale = scale
                        offset = clampedOffset(offset, viewport: viewportSize)
                    }
                    scheduleAutoHide()
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, 8)
        }
    }

    private func zoomButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.footnote)
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .frame(width: 30, height: 30)
        .background(.regularMaterial)
        .clipShape(Circle())
    }

    // MARK: Control visibility

    /// Reveals the controls (if hidden) and reschedules the auto-hide timer.
    private func scheduleAutoHide() {
        hideTask?.cancel()
        if !controlsVisible {
            withAnimation(.easeOut(duration: 0.2)) { controlsVisible = true }
        }
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: hideDelayNanoseconds)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) { controlsVisible = false }
        }
    }

    /// Toggles the control overlay on a single tap.
    private func toggleControls() {
        if controlsVisible {
            hideTask?.cancel()
            withAnimation(.easeOut(duration: 0.2)) { controlsVisible = false }
        } else {
            scheduleAutoHide()
        }
    }

    /// Clamps a proposed pan offset so the zoomed image can't be dragged
    /// entirely off-screen. At or below 1x there is no panning; above 1x the
    /// image may travel at most half its (scaled) overshoot in each axis.
    private func clampedOffset(_ proposed: CGSize, viewport: CGSize) -> CGSize {
        guard scale > 1.0 else { return .zero }
        let maxX = max(0, (viewport.width * scale - viewport.width) / 2)
        let maxY = max(0, (viewport.height * scale - viewport.height) / 2)
        return CGSize(
            width: min(max(proposed.width, -maxX), maxX),
            height: min(max(proposed.height, -maxY), maxY)
        )
    }
}
