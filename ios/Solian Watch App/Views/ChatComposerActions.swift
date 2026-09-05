//
//  ChatComposerActions.swift
//  WatchRunner Watch App
//
//  The watch's "more" compose menu, styled after Apple Messages' "+"
//  attachment picker: a stack of circular tinted actions on a dark surface.
//  The sheet is dismissed by watchOS' own system close button (it's presented
//  inside a NavigationStack), so no custom close affordance is drawn. Each
//  action is an alternate message content-type the app actually supports, so
//  the menu stays honest — today that's Stickers (text composes via the pill
//  in the compose bar).
//

import SwiftUI
import WatchKit

/// Full-screen "more" menu presented from the compose bar's "+" button.
/// Rows follow Apple's attachment menu: circular tinted icon + label, on a
/// dark surface. The system presents a dismiss affordance; the caller owns
/// dismissing this sheet and presenting the resulting surface.
struct ChatComposerActionsView: View {
    /// Called when a content-type row is chosen (e.g. Stickers). The caller
    /// owns dismissing this sheet and presenting the resulting surface.
    let onPickStickers: () -> Void
    let onPickVoice: () -> Void
    let onPickPhoto: () -> Void
    let onPickLinkedCloud: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Top inset so the first row clears the sheet's system close button.
                Spacer().frame(height: 32)

                ChatComposerActionRow(
                    icon: "face.smiling",
                    iconStyle: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.36, green: 0.60, blue: 1.0),
                                Color(red: 0.58, green: 0.42, blue: 0.96),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ),
                    label: L10n.composerStickers
                ) {
                    WKInterfaceDevice.current().play(.click)
                    onPickStickers()
                    dismiss()
                }

                ChatComposerActionRow(
                    icon: "mic",
                    iconStyle: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.35, blue: 0.40),
                                Color(red: 0.75, green: 0.20, blue: 0.45),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ),
                    label: L10n.composerVoice
                ) {
                    WKInterfaceDevice.current().play(.click)
                    onPickVoice()
                    dismiss()
                }

                ChatComposerActionRow(
                    icon: "photo",
                    iconStyle: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.30, green: 0.75, blue: 0.55),
                                Color(red: 0.20, green: 0.55, blue: 0.45),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ),
                    label: L10n.composerPhoto
                ) {
                    WKInterfaceDevice.current().play(.click)
                    onPickPhoto()
                    dismiss()
                }

                ChatComposerActionRow(
                    icon: "link",
                    iconStyle: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.45, blue: 0.90),
                                Color(red: 0.40, green: 0.30, blue: 0.75),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ),
                    label: L10n.composerLinkCloud
                ) {
                    WKInterfaceDevice.current().play(.click)
                    onPickLinkedCloud()
                    dismiss()
                }

                Spacer().frame(minHeight: 24)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.black)
    }
}

/// One action row: circular tinted icon beside a label, top-aligned like the
/// Messages attachment menu.
private struct ChatComposerActionRow: View {
    let icon: String
    let iconStyle: AnyShapeStyle
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconStyle)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .padding(.vertical, 10)
    }
}
