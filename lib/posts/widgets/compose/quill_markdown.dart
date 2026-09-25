/// Markdown <-> Quill Delta conversion for compose content.
///
/// Compose content is stored as markdown ([ComposeState.contentController]) and
/// edited through a WYSIWYG [QuillEditor]. These helpers convert between the
/// two formats.
///
/// `markdown_quill`'s default markdown serializer escapes a broad character
/// set (`+`, `!`, `.`, `>`, `<`, `-` …) even where markdown never interprets
/// them. That corrupts Solian's own inline syntax (`:realm+tech:`,
/// `:sticker+fire:` became `:realm\+tech:`), so a context-aware escaper is
/// used instead: it only escapes characters that would otherwise be parsed as
/// markdown structure, keeping round trips stable.
library;

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

final md.Document _mdDocument = md.Document(encodeHtml: false);

final MarkdownToDelta _mdToDelta =
    MarkdownToDelta(markdownDocument: _mdDocument);

final DeltaToMarkdown _deltaToMd =
    DeltaToMarkdown(customContentHandler: _escapeMarkdownSpecial);

/// Converts markdown text to a Quill [Delta].
///
/// Empty markdown produces an empty delta, which `Document` rejects; the
/// minimal valid document (a single newline) is returned instead so an empty
/// post still round-trips to empty markdown.
Delta markdownToQuillDelta(String markdown) {
  final delta = _mdToDelta.convert(markdown);
  if (delta.isEmpty) {
    return Delta()..insert('\n');
  }
  return delta;
}

/// Converts a Quill [Delta] to markdown text.
String quillDeltaToMarkdown(Delta delta) => _deltaToMd.convert(delta);

/// Matches markdown block markers at the start of a line (optionally
/// indented up to 3 spaces, beyond which markdown treats content as code).
final RegExp _lineStartBlockMarker = RegExp(r'^\s{0,3}([-+>#])');

/// Matches an ordered-list start (`1. `) at the start of a line.
final RegExp _lineStartOrderedList = RegExp(r'^\s{0,3}\d+\.');

/// Escapes markdown special characters in a plain-text run, but only where
/// markdown would actually interpret them.
///
/// - Always escaped: `\`, `` ` ``, `*`, `_`, `{`, `}`, `[`, `]`, `(`, `)`,
///   `<`. These start markdown constructs anywhere in a line.
/// - Line-start only: `-`, `+`, `>` (lists/quotes) and `#` (headings), plus
///   the `.` in an ordered-list start (`1.`). Mid-word `-`, `+`, `.`, `!`
///   (e.g. `:realm+tech:`) stay untouched.
/// - Code runs (inline or block) are written verbatim.
void _escapeMarkdownSpecial(QuillText text, StringSink out) {
  final style = text.style;
  final isCode = style.containsKey(Attribute.codeBlock.key) ||
      style.containsKey(Attribute.inlineCode.key) ||
      (text.parent?.style.containsKey(Attribute.codeBlock.key) ?? false);
  if (isCode) {
    out.write(text.value);
    return;
  }

  final buffer = StringBuffer();
  for (final rune in text.value.runes) {
    final char = String.fromCharCode(rune);
    switch (char) {
      case '\\':
      case '`':
      case '*':
      case '_':
      case '{':
      case '}':
      case '[':
      case ']':
      case '(':
      case ')':
      case '<':
        buffer
          ..write('\\')
          ..write(char);
      default:
        buffer.write(char);
    }
  }

  var escaped = buffer.toString();
  // The first leaf of a line opens the line; only then are block markers live.
  if (text.previous == null) {
    final blockMarker = _lineStartBlockMarker.firstMatch(escaped);
    if (blockMarker != null) {
      final marker = blockMarker.group(1);
      final index = marker == null
          ? blockMarker.start
          : blockMarker.start + (blockMarker.group(0)!.length - marker.length);
      escaped = escaped.replaceRange(index, index + 1, '\\${escaped[index]}');
    } else {
      final ordered = _lineStartOrderedList.firstMatch(escaped);
      if (ordered != null) {
        final dotIndex = escaped.indexOf('.', ordered.start);
        escaped = escaped.replaceRange(dotIndex, dotIndex + 1, r'\.');
      }
    }
  }
  out.write(escaped);
}
