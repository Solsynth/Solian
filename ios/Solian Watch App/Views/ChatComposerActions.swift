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

    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
                label: "Stickers"
            ) {
                WKInterfaceDevice.current().play(.click)
                onPickStickers()
                dismiss()
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
