import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:markdown_widget/markdown_widget.dart';

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

/// Builds highlight nodes for [SolarHighlightInlineSyntax].
class SolarHighlightGenerator extends SpanNodeGeneratorWithTag {
  SolarHighlightGenerator({required Color highlightColor})
    : super(
        tag: 'highlight',
        generator: (element, config, visitor) => SolarHighlightSpanNode(
          text: element.textContent,
          highlightColor: highlightColor,
        ),
      );
}

class SolarHighlightSpanNode extends SpanNode {
  SolarHighlightSpanNode({required this.text, required this.highlightColor});

  final String text;
  final Color highlightColor;

  @override
  InlineSpan build() => TextSpan(
    text: text,
    style: TextStyle(backgroundColor: highlightColor),
  );
}

/// Builds tappable spoiler nodes for [SolarSpoilerInlineSyntax].
class SolarSpoilerGenerator extends SpanNodeGeneratorWithTag {
  SolarSpoilerGenerator({
    required bool revealed,
    required VoidCallback onToggle,
  }) : super(
         tag: 'spoiler',
         generator: (element, config, visitor) => SolarSpoilerSpanNode(
           text: element.textContent,
           revealed: revealed,
           onToggle: onToggle,
         ),
       );
}

class SolarSpoilerSpanNode extends SpanNode {
  SolarSpoilerSpanNode({
    required this.text,
    required this.revealed,
    required this.onToggle,
  });

  final String text;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  InlineSpan build() {
    final recognizer = TapGestureRecognizer()..onTap = onToggle;
    return TextSpan(children: _buildSegments(recognizer));
  }

  List<InlineSpan> _buildSegments(TapGestureRecognizer recognizer) {
    final parts = text.split(RegExp(r'(\s+)'));
    return parts.where((part) => part.isNotEmpty).map((part) {
      if (part.trim().isEmpty) {
        return TextSpan(
          text: part,
          recognizer: recognizer,
          style: revealed
              ? null
              : const TextStyle(
                  color: Colors.transparent,
                  backgroundColor: Colors.black,
                ),
        );
      }

      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Builder(
          builder: (context) {
            final baseStyle = DefaultTextStyle.of(context).style;
            final hiddenStyle = baseStyle.copyWith(
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
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: revealed
                    ? Text(
                        part,
                        key: ValueKey('revealed-$part'),
                        style: baseStyle,
                      )
                    : Text(
                        part,
                        key: ValueKey('hidden-$part'),
                        style: hiddenStyle,
                      ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}
