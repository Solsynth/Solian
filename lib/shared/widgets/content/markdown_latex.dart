import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as markdown;

const latexTag = 'latex';

class LatexSyntax extends markdown.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[\s\S]+\$\$)|(\$.+?\$)');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final matchValue = match.input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;
    if (matchValue.startsWith(r'$$') &&
        matchValue.endsWith(r'$$') &&
        matchValue != r'$$') {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    } else if (matchValue.startsWith(r'$') &&
        matchValue.endsWith(r'$') &&
        matchValue != r'$') {
      content = matchValue.substring(1, matchValue.length - 1);
    }

    final element = markdown.Element.text(latexTag, matchValue)
      ..attributes['content'] = content
      ..attributes['isInline'] = '$isInline';
    parser.addNode(element);
    return true;
  }
}

class LatexBuilder extends MarkdownElementBuilder {
  LatexBuilder({required this.isDark});

  final bool isDark;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final content = element.attributes['content'] ?? '';
    final isInline = element.attributes['isInline'] == 'true';
    final style =
        parentStyle ?? preferredStyle ?? DefaultTextStyle.of(context).style;
    if (content.isEmpty) return Text(element.textContent, style: style);

    final latex = Math.tex(
      content,
      mathStyle: MathStyle.text,
      textStyle: style.copyWith(color: isDark ? Colors.white : Colors.black),
      textScaleFactor: 1,
      onErrorFallback: (error) =>
          Text(element.textContent, style: style.copyWith(color: Colors.red)),
    );
    if (isInline) return latex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: latex),
    );
  }
}
