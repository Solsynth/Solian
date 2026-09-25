/// Markdown <-> Quill Delta conversion for compose content.
///
/// Compose content is stored as markdown ([ComposeState.contentController]) and
/// edited through a WYSIWYG [QuillEditor]. These helpers convert between the
/// two formats.
///
/// Line breaks follow markdown's own model: consecutive lines are soft breaks
/// (an Enter in the editor), while a blank line separates paragraphs. Solian's
/// markdown renderer runs with `softLineBreak: true`, so a lone newline is a
/// line break there too — the editor and the published post agree.
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

/// Imports with soft line breaks preserved as line breaks instead of being
/// joined with spaces, matching how the renderer displays them.
final MarkdownToDelta _mdToDelta = MarkdownToDelta(
  markdownDocument: _mdDocument,
  softLineBreak: true,
);

/// Converts markdown text to a Quill [Delta].
///
/// Blocks separated by blank lines are imported individually and joined with
/// an empty line, so a paragraph break stays a paragraph break (rather than
/// collapsing into the line break a soft break produces). Empty markdown
/// produces the minimal valid document (a single newline), which `Document`
/// requires so an empty post still round-trips to empty markdown.
Delta markdownToQuillDelta(String markdown) {
  final blocks = _markdownBlocks(markdown);
  if (blocks.isEmpty) {
    return Delta()..insert('\n');
  }
  final delta = Delta();
  for (var i = 0; i < blocks.length; i++) {
    if (i > 0) delta.insert('\n');
    for (final operation in _mdToDelta.convert(blocks[i]).toList()) {
      delta.push(operation);
    }
  }
  if (delta.isEmpty) {
    return Delta()..insert('\n');
  }
  return delta;
}

/// Splits [markdown] into top-level blocks on blank lines, keeping fenced code
/// blocks (whose blank lines are content) intact.
List<String> _markdownBlocks(String markdown) {
  final blocks = <String>[];
  final current = <String>[];
  var inFence = false;
  for (final line in markdown.split('\n')) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inFence = !inFence;
      current.add(line);
      continue;
    }
    if (!inFence && line.trim().isEmpty) {
      if (current.isNotEmpty) {
        blocks.add(current.join('\n'));
        current.clear();
      }
      continue;
    }
    current.add(line);
  }
  if (current.isNotEmpty) blocks.add(current.join('\n'));
  return blocks;
}

/// Converts a Quill [Delta] to markdown text.
///
/// Consecutive lines stay on consecutive markdown lines (a soft break) and an
/// empty line becomes a blank line (a paragraph break), so an Enter in the
/// editor never turns into a new paragraph on its own.
String quillDeltaToMarkdown(Delta delta) {
  final separators = _lineSeparators(delta);
  var index = 0;
  return DeltaToMarkdown(
    customContentHandler: _escapeMarkdownSpecial,
    visitLineHandleNewLine: (_, out) {
      out.write(index < separators.length ? separators[index] : '\n');
      index++;
    },
  ).convert(delta);
}

bool _isPlainLine(Style style) =>
    style.isEmpty ||
    style.values.every((item) => item.scope != AttributeScope.block);

bool _isListLine(Style style) => style.containsKey(Attribute.list.key);

bool _isCodeLine(Style style) => style.containsKey(Attribute.codeBlock.key);

/// Newline text written after each line's content, in document order.
///
/// Mirrors `markdown_quill`'s default separation rules, except that plain text
/// lines are only separated by a blank line when a blank line or a block
/// follows them — elsewhere a single newline keeps the lines in one paragraph.
List<String> _lineSeparators(Delta delta) {
  final lines = _documentLines(Document.fromDelta(delta));
  final separators = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final style = lines[i].style;
    final next = i + 1 < lines.length ? lines[i + 1] : null;
    final nextStyle = next?.style;
    if (_isListLine(style)) {
      // A blank line closes the list — but not when one already follows.
      separators.add(
        next == null || _isEmptyLine(next) || _isListLine(next.style)
            ? '\n'
            : '\n\n',
      );
      continue;
    }
    if (_isCodeLine(style)) {
      separators.add('\n');
      continue;
    }
    if (!_isPlainLine(style)) {
      // Headings and quotes: terminate the block, and keep a following plain
      // line out of it (markdown lazy continuation).
      separators.add(
        next != null && !_isEmptyLine(next) && _isPlainLine(next.style)
            ? '\n\n'
            : '\n',
      );
      continue;
    }
    if (_isEmptyLine(lines[i])) {
      separators.add('\n');
      continue;
    }
    // Plain text: stay on the next line, unless a block follows.
    separators.add(
      nextStyle != null && !_isPlainLine(nextStyle) ? '\n\n' : '\n',
    );
  }
  return separators;
}

/// Lines in the same depth-first order the markdown visitor walks them,
/// including lines nested inside blocks (quotes, code blocks).
List<Line> _documentLines(Document document) {
  final lines = <Line>[];
  void collect(Node node) {
    if (node is Line) {
      lines.add(node);
      return;
    }
    if (node is Root) {
      for (final child in node.children) {
        collect(child);
      }
    } else if (node is Block) {
      for (final child in node.children) {
        collect(child);
      }
    }
  }

  collect(document.root);
  return lines;
}

/// [Line.toPlainText] keeps the terminating newline, so compare the content.
bool _isEmptyLine(Line line) => line.toPlainText().trim().isEmpty;


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
