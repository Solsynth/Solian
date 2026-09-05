//
//  MarkdownText.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  Renders post body content as rich text with inline sticker support. The
//  main app renders post content as markdown (flutter_markdown_plus) with
//  `:prefix+slug:` sticker placeholders resolved inline; on watchOS we use
//  SwiftUI's AttributedString(markdown:) for the text (bold / italic / links
//  / code inline) and render sticker placeholders with the shared
//  StickerRenderView. HTML content (contentType == 1) is reduced to plain
//  markdown before rendering, since the watch target has no html-to-markdown
//  library.
//
//  - A body that is exactly one sticker renders as a single large image
//    (mirrors the main app's standalone-sticker size).
//  - Mixed bodies flow text (word by word, markdown attributes preserved) and
//    inline stickers together so long lines wrap on the watch face.
//  - Bodies without stickers render exactly as markdown, with the caller's
//    line limit.
//

import SwiftUI

/// A SwiftUI text view that renders markdown inline with sticker spans. Falls
/// back to plain text when the markdown source isn't valid.
struct MarkdownText: View {
    let content: String
    var lineLimit: Int? = nil
    var isHTML: Bool = false

    /// Standalone sticker size (main app: `large` = 96).
    private var standaloneDimension: CGFloat { 96 }
    /// Inline sticker size (main app: `medium` = 48, drawn tighter on watch).
    private var inlineDimension: CGFloat { 22 }

    private var source: String {
        isHTML ? MarkdownText.htmlToMarkdown(content) : content
    }

    var body: some View {
        let segments = parseStickerContent(source)
        if segments.count == 1, case .sticker(let identifier) = segments[0] {
            StickerRenderView(identifier: identifier, dimension: standaloneDimension)
        } else if segments.contains(where: { if case .sticker = $0 { return true }; return false }) {
            mixedContent(segments)
        } else {
            Text(markdownAttributed(source))
                .lineLimit(lineLimit)
        }
    }

    /// Flows text (word by word, markdown attributes preserved) and inline
    /// stickers together with the shared FlowLayout so long mixed lines wrap
    /// on the watch face.
    @ViewBuilder
    private func mixedContent(_ segments: [StickerContentSegment]) -> some View {
        FlowLayout(alignment: .leading, spacing: 3) {
            ForEach(segments) { segment in
                switch segment {
                case .text(let text):
                    // Whitespace between words becomes the flow spacing; each
                    // word wraps as its own unit while keeping its markdown
                    // attributes (bold / italic / links / code).
                    ForEach(Array(markdownWords(markdownAttributed(text)).enumerated()), id: \.offset) { _, word in
                        Text(word)
                            .lineLimit(1)
                            .fixedSize()
                    }
                case .sticker(let identifier):
                    StickerRenderView(identifier: identifier, dimension: inlineDimension)
                }
            }
        }
    }

    // MARK: Markdown parsing

    /// Parses markdown, falling back to plain text when the source isn't
    /// valid.
    private func markdownAttributed(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }

    /// Splits an `AttributedString` into whitespace-delimited runs, preserving
    /// each run's markdown attributes so bold / italic spans that cross word
    /// boundaries still render correctly inside a FlowLayout.
    private func markdownWords(_ attributed: AttributedString) -> [AttributedString] {
        var words: [AttributedString] = []
        var currentStart = attributed.startIndex
        var i = attributed.startIndex
        while i < attributed.endIndex {
            let ch = String(attributed[i..<attributed.index(afterCharacter: i)].characters)
            if ch == " " || ch == "\n" || ch == "\t" {
                if currentStart < i {
                    words.append(AttributedString(attributed[currentStart..<i]))
                }
                i = attributed.index(afterCharacter: i)
                currentStart = i
                continue
            }
            i = attributed.index(afterCharacter: i)
        }
        if currentStart < attributed.endIndex {
            words.append(AttributedString(attributed[currentStart..<attributed.endIndex]))
        }
        return words
    }

    /// Best-effort HTML → markdown/plain reduction for post bodies. Handles
    /// the common tags (paragraphs, breaks, emphasis, code, links, lists)
    /// and strips the rest, so rich HTML content degrades to readable text
    /// rather than raw markup. Not exhaustive — the watch can't afford a full
    /// HTML parser, and most bodies are already markdown or simple HTML.
    static func htmlToMarkdown(_ html: String) -> String {
        var text = html

        // Code blocks first (they contain escaped tags).
        text = text.replacingOccurrences(of: "<pre>", with: "```\n")
        text = text.replacingOccurrences(of: "</pre>", with: "\n```")
        text = text.replacingOccurrences(of: "<code>", with: "`")
        text = text.replacingOccurrences(of: "</code>", with: "`")

        // Paragraphs / line breaks become newlines.
        text = text.replacingOccurrences(of: "</p>", with: "\n\n")
        text = text.replacingOccurrences(of: "<p>", with: "")
        text = text.replacingOccurrences(of: "<br>", with: "\n")
        text = text.replacingOccurrences(of: "<br/>", with: "\n")
        text = text.replacingOccurrences(of: "<br />", with: "\n")
        text = text.replacingOccurrences(of: "\r\n", with: "\n")

        // Headings → bold paragraph.
        for level in 1...6 {
            text = text.replacingOccurrences(
                of: "</h\(level)>",
                with: "\n\n"
            )
            text = text.replacingOccurrences(
                of: "<h\(level)>",
                with: (1...level).map { _ in "#" }.joined() + " "
            )
        }

        // Inline emphasis.
        text = text.replacingOccurrences(of: "<strong>", with: "**")
        text = text.replacingOccurrences(of: "</strong>", with: "**")
        text = text.replacingOccurrences(of: "<b>", with: "**")
        text = text.replacingOccurrences(of: "</b>", with: "**")
        text = text.replacingOccurrences(of: "<i>", with: "*")
        text = text.replacingOccurrences(of: "</i>", with: "*")
        text = text.replacingOccurrences(of: "<em>", with: "*")
        text = text.replacingOccurrences(of: "</em>", with: "*")
        text = text.replacingOccurrences(of: "<u>", with: "")
        text = text.replacingOccurrences(of: "</u>", with: "")

        // Links: <a href="url">text</a> → [text](url).
        text = text.replacingOccurrences(
            of: #"<a\s+href="([^"]*)"[^>]*>([^<]*)</a>"#,
            with: "[$2]($1)",
            options: .regularExpression
        )

        // Blockquotes.
        text = text.replacingOccurrences(of: "<blockquote>", with: "> ")
        text = text.replacingOccurrences(of: "</blockquote>", with: "\n")

        // Lists.
        text = text.replacingOccurrences(of: "<li>", with: "- ")
        text = text.replacingOccurrences(of: "</li>", with: "\n")
        text = text.replacingOccurrences(of: "<ul>", with: "")
        text = text.replacingOccurrences(of: "</ul>", with: "")
        text = text.replacingOccurrences(of: "<ol>", with: "")
        text = text.replacingOccurrences(of: "</ol>", with: "")

        // Strip any remaining tags.
        text = text.replacingOccurrences(
            of: #"<[^>]+>"#,
            with: "",
            options: .regularExpression
        )

        // Collapse runs of 3+ newlines to 2.
        text = text.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )

        // Decode a few common entities.
        var decoded = text
        let entities: [(String, String)] = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#39;", "'"),
            ("&nbsp;", " "),
        ]
        for (entity, value) in entities {
            decoded = decoded.replacingOccurrences(of: entity, with: value)
        }
        return decoded.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
