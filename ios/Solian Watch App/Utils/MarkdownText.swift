//
//  MarkdownText.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//
//  Renders post body content as rich text. The main app renders post content
//  as markdown (flutter_markdown_plus); on watchOS we use SwiftUI's
//  AttributedString(markdown:), which supports bold / italic / links / code
//  inline. HTML content (contentType == 1) is reduced to plain markdown
//  before rendering, since the watch target has no html-to-markdown library.
//

import SwiftUI

/// A SwiftUI text view that renders markdown inline. Falls back to plain
/// text when the source isn't valid markdown.
struct MarkdownText: View {
    let content: String
    var lineLimit: Int? = nil
    var isHTML: Bool = false

    private var source: String {
        isHTML ? MarkdownText.htmlToMarkdown(content) : content
    }

    private var attributed: AttributedString {
        (try? AttributedString(markdown: source)) ?? AttributedString(source)
    }

    var body: some View {
        Text(attributed)
            .lineLimit(lineLimit)
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
