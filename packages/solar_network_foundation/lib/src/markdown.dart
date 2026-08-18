import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as markdown;

/// Parses Solar Network-style mentions into a `mention-chip` element.
class SolarMentionInlineSyntax extends markdown.InlineSyntax {
  SolarMentionInlineSyntax()
    : super(r'(^|[^A-Za-z0-9._%+\-/\[])(@[-A-Za-z0-9_./]+)');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final prefix = match[1] ?? '';
    final alias = match[2]!;
    if (prefix.isNotEmpty) parser.addNode(markdown.Text(prefix));

    final parts = alias.substring(1).split('/');
    final type = switch (parts.length == 1 ? 'u' : parts.first) {
      'u' => 'accounts',
      'r' => 'realms',
      'p' => 'publishers',
      _ => '',
    };
    final element = markdown.Element('mention-chip', [markdown.Text(alias)])
      ..attributes.addAll({'alias': alias, 'type': type, 'id': parts.last});
    parser.addNode(element);
    return true;
  }
}

/// Parses `==highlighted text==` into a `highlight` element.
class SolarHighlightInlineSyntax extends markdown.InlineSyntax {
  SolarHighlightInlineSyntax() : super(r'==([^=]+)==');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    parser.addNode(markdown.Element('highlight', [markdown.Text(match[1]!)]));
    return true;
  }
}

/// Parses `=!spoiler text!=` into a `spoiler` element.
class SolarSpoilerInlineSyntax extends markdown.InlineSyntax {
  SolarSpoilerInlineSyntax() : super(r'=!([^!]+)!=');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    parser.addNode(markdown.Element('spoiler', [markdown.Text(match[1]!)]));
    return true;
  }
}

/// Builds widgets for [SolarHighlightInlineSyntax].
class SolarHighlightGenerator extends MarkdownElementBuilder {
  SolarHighlightGenerator({required this.highlightColor});

  final Color highlightColor;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return SolarHighlightSpanNode(
      text: element.textContent,
      highlightColor: highlightColor,
      style: parentStyle ?? preferredStyle,
    );
  }
}

class SolarHighlightSpanNode extends StatelessWidget {
  const SolarHighlightSpanNode({
    super.key,
    required this.text,
    required this.highlightColor,
    this.style,
  });

  final String text;
  final Color highlightColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style?.copyWith(backgroundColor: highlightColor));
  }
}

/// Builds tappable widgets for [SolarSpoilerInlineSyntax].
class SolarSpoilerGenerator extends MarkdownElementBuilder {
  SolarSpoilerGenerator({required this.revealed, required this.onToggle});

  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return SolarSpoilerSpanNode(
      text: element.textContent,
      revealed: revealed,
      onToggle: onToggle,
      style: parentStyle ?? preferredStyle,
    );
  }
}

class SolarSpoilerSpanNode extends StatelessWidget {
  const SolarSpoilerSpanNode({
    super.key,
    required this.text,
    required this.revealed,
    required this.onToggle,
    this.style,
  });

  final String text;
  final bool revealed;
  final VoidCallback onToggle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final hiddenStyle = style?.copyWith(
      color: Colors.transparent,
      backgroundColor: Colors.black,
    );
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Text(
          text,
          key: ValueKey('${revealed ? 'revealed' : 'hidden'}-$text'),
          style: revealed ? style : hiddenStyle,
        ),
      ),
    );
  }
}
