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

class SolarSpoilerSpanNode extends StatefulWidget {
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
  State<SolarSpoilerSpanNode> createState() => _SolarSpoilerSpanNodeState();
}

class _SolarSpoilerSpanNodeState extends State<SolarSpoilerSpanNode> {
  late bool _revealed = widget.revealed;

  @override
  void didUpdateWidget(covariant SolarSpoilerSpanNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed != oldWidget.revealed) {
      _revealed = widget.revealed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final hiddenStyle = baseStyle.copyWith(
      color: Colors.transparent,
      backgroundColor: Colors.black,
    );
    final textStyle = _revealed ? baseStyle : hiddenStyle;
    final fontSize = baseStyle.fontSize ?? 14;
    return Baseline(
      baseline: fontSize * 0.82,
      baselineType: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () {
          setState(() => _revealed = !_revealed);
          widget.onToggle();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Text(
            widget.text,
            key: ValueKey(
              '${_revealed ? 'revealed' : 'hidden'}-${widget.text}',
            ),
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
