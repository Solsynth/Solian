//
//  ChatStickerContent.swift
//  WatchRunner Watch App
//
//  Sticker rendering for chat messages. Message bodies carry stickers as
//  `:prefix+slug:` placeholders (the main app's sticker syntax). This splits
//  a content string into text runs and sticker spans, resolving each
//  placeholder through the shared StickerStore.
//
//  - A body that is exactly one sticker renders as a single large image
//    (Flutter's standalone-sticker `large` size).
//  - Mixed bodies render text and small inline stickers wrapping together
//    (Flutter's per-paragraph inline emote handling), flowing at word
//    granularity so long lines wrap naturally on the watch face.
//

import SwiftUI

/// The sticker placeholder regex, mirroring the main app's
/// `MarkdownTextContent.stickerRegex` (`:([-\w]*\+[-\w]*):`).
let kStickerPlaceholderRegex = try! NSRegularExpression(
    pattern: #":([-\w]*\+[-\w]*):"#
)

/// Whether a chat message body is a single standalone sticker (possibly with
/// surrounding whitespace) — Flutter's `_isStandaloneStickerInContent` when
/// the paragraph contains exactly one sticker and nothing else.
func isStandaloneStickerContent(_ content: String) -> Bool {
    let ns = content as NSString
    let matches = kStickerPlaceholderRegex.matches(in: content, range: NSRange(location: 0, length: ns.length))
    guard matches.count == 1 else { return false }
    let match = matches[0]
    let before = ns.substring(to: match.range.location)
    let after = ns.substring(from: match.range.location + match.range.length)
    return before.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && after.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

/// One parsed run of a message body: either literal text or a sticker
/// placeholder (identifier without the surrounding colons).
enum StickerContentSegment: Identifiable, Equatable {
    case text(String)
    case sticker(identifier: String)

    var id: String {
        switch self {
        case .text(let text): return "text-\(text)"
        case .sticker(let identifier): return "sticker-\(identifier)"
        }
    }
}

/// Splits `content` into alternating text / sticker segments.
func parseStickerContent(_ content: String) -> [StickerContentSegment] {
    let ns = content as NSString
    let matches = kStickerPlaceholderRegex.matches(in: content, range: NSRange(location: 0, length: ns.length))
    guard !matches.isEmpty else {
        return content.isEmpty ? [] : [.text(content)]
    }

    var segments: [StickerContentSegment] = []
    var cursor = 0
    for match in matches {
        if match.range.location > cursor {
            let text = ns.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
            // Whitespace-only runs (e.g. around a standalone sticker) carry no
            // visual content; drop them so `:pack+wave:` with surrounding
            // spaces still parses as a single standalone sticker.
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                segments.append(.text(text))
            }
        }
        segments.append(.sticker(identifier: ns.substring(with: match.range(at: 1))))
        cursor = match.range.location + match.range.length
    }
    if cursor < ns.length {
        let text = ns.substring(from: cursor)
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            segments.append(.text(text))
        }
    }
    return segments
}

/// A SwiftUI view rendering one message body with sticker spans.
struct ChatStickerContent: View {
    let content: String
    var isOwn: Bool = false

    @EnvironmentObject var appState: AppState

    private var textColor: Color { isOwn ? .white : .primary }
    private var standaloneDimension: CGFloat { 110 }
    private var inlineDimension: CGFloat { 24 }

    var body: some View {
        let segments = parseStickerContent(content)
        if segments.count == 1, case .sticker(let identifier) = segments[0] {
            StickerRenderView(identifier: identifier, dimension: standaloneDimension)
        } else if segments.contains(where: { if case .sticker = $0 { return true }; return false }) {
            mixedContent(segments)
        } else {
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(textColor)
        }
    }

    /// Flows text (word by word) and inline stickers together with the shared
    /// FlowLayout so long mixed lines wrap on the watch face.
    @ViewBuilder
    private func mixedContent(_ segments: [StickerContentSegment]) -> some View {
        FlowLayout(alignment: .leading, spacing: 3) {
            ForEach(segments) { segment in
                switch segment {
                case .text(let text):
                    // Whitespace between words becomes the flow spacing; each
                    // word wraps as its own unit.
                    ForEach(Array(text.split(separator: " ").enumerated()), id: \.offset) { _, word in
                        Text(String(word))
                            .font(.system(size: 14))
                            .foregroundColor(textColor)
                            .fixedSize()
                    }
                case .sticker(let identifier):
                    StickerRenderView(identifier: identifier, dimension: inlineDimension)
                }
            }
        }
    }
}

/// Resolves one sticker identifier and renders its image at `dimension`,
/// showing a placeholder while loading.
private struct StickerRenderView: View {
    let identifier: String
    var dimension: CGFloat

    @EnvironmentObject var appState: AppState
    @StateObject private var store = StickerStore.shared

    @State private var sticker: SnSticker?

    var body: some View {
        Group {
            if let sticker {
                StickerImageView(file: sticker.image, dimension: dimension)
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: dimension, height: dimension)
                    .overlay(ProgressView())
            }
        }
        .task(id: identifier) {
            guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
            sticker = await store.resolve(identifier: identifier, token: token, serverUrl: serverUrl)
        }
    }
}
