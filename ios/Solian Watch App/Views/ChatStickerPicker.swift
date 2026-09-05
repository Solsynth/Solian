//
//  ChatStickerPicker.swift
//  WatchRunner Watch App
//
//  Dedicated sticker-send surface. Presented from the chat's "Stickers"
//  button (below the compose button); owned sticker packs are browsed by
//  swiping horizontally (one page per pack). Each page shows the pack's info
//  (name, sticker count) above its sticker grid; tapping a sticker sends it
//  as a standalone message.
//

import SwiftUI
import WatchKit

/// Full-screen sticker picker: page-style horizontal swipe between owned
/// packs, each page a "pack info header + sticker grid". Tapping a sticker
/// sends it immediately. Reads the shared store so load failure/empty render
/// honestly.
struct StickerPickerView: View {
    @ObservedObject var store: StickerStore
    let onPick: (SnStickerPack, SnSticker) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0

    private var packs: [SnStickerPack] { store.packs }

    var body: some View {
        Group {
            if !packs.isEmpty {
                if packs.count == 1 {
                    packPage(packs[0])
                } else {
                    // One page per pack; swipe horizontally to switch packs.
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(packs.enumerated()), id: \.element.id) { index, pack in
                            packPage(pack)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                }
            } else if store.loadError != nil {
                errorState
            } else {
                emptyState
            }
        }
        .navigationTitle(L10n.stickersTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "face.smiling")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(L10n.stickersNoPacks)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorState: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(L10n.stickersUnavailable)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// One swipeable page: pack info header, then the sticker grid.
    @ViewBuilder
    private func packPage(_ pack: SnStickerPack) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                packHeader(pack)

                if pack.stickers.isEmpty {
                    Text(L10n.stickersNoStickersInPack)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 52), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(pack.stickers) { sticker in
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                onPick(pack, sticker)
                                dismiss()
                            } label: {
                                StickerImageView(file: sticker.image, dimension: 50)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(sticker.name ?? sticker.slug)
                        }
                    }
                }
            }
            .padding()
        }
    }

    /// Pack info shown above every sticker in the pack.
    private func packHeader(_ pack: SnStickerPack) -> some View {
        HStack(spacing: 8) {
            if let icon = pack.icon ?? pack.stickers.first?.image {
                StickerImageView(file: icon, dimension: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(pack.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                if let description = pack.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(String(format: L10n.stickersStickerCount, pack.stickers.count))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.bottom, 2)
    }
}
