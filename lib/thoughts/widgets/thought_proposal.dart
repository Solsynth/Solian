import "package:flutter/material.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:styled_widget/styled_widget.dart";
import "package:markdown/markdown.dart" as markdown;
import "package:markdown_widget/markdown_widget.dart";

class ProposalBlockSyntax extends markdown.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^<proposal', caseSensitive: false);

  @override
  bool canParse(markdown.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  bool canEndBlock(markdown.BlockParser parser) {
    return parser.current.content.contains('</proposal>');
  }

  @override
  markdown.Node parse(markdown.BlockParser parser) {
    final childLines = <String>[];

    // Extract type from opening tag
    final openingLine = parser.current.content;
    final attrsMatch = RegExp(
      r'<proposal(\s[^>]*)?>',
      caseSensitive: false,
    ).firstMatch(openingLine);
    final attrs = attrsMatch?.group(1) ?? '';
    final typeMatch = RegExp(r'type="([^"]*)"').firstMatch(attrs);
    final type = typeMatch?.group(1) ?? '';

    // Collect all lines until closing tag
    while (!parser.isDone) {
      childLines.add(parser.current.content);
      if (canEndBlock(parser)) {
        parser.advance();
        break;
      }
      parser.advance();
    }

    // Extract content between tags
    final fullContent = childLines.join('\n');
    final contentMatch = RegExp(
      r'<proposal[^>]*>(.*?)</proposal>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(fullContent);
    final content = contentMatch?.group(1)?.trim() ?? '';

    final element = markdown.Element('proposal', [markdown.Text(content)])
      ..attributes['type'] = type;

    return element;
  }
}

class ProposalGenerator extends SpanNodeGeneratorWithTag {
  ProposalGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
  }) : super(
         tag: 'proposal',
         generator: (
           markdown.Element element,
           MarkdownConfig config,
           WidgetVisitor visitor,
         ) {
           return ProposalSpanNode(
             text: element.textContent,
             type: element.attributes['type'] ?? '',
             backgroundColor: backgroundColor,
             foregroundColor: foregroundColor,
             borderColor: borderColor,
           );
         },
       );
}

class ProposalSpanNode extends SpanNode {
  final String text;
  final String type;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  ProposalSpanNode({
    required this.text,
    required this.type,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Row(
              spacing: 6,
              children: [
                Icon(Symbols.lightbulb, size: 16, color: foregroundColor),
                Text(
                  'SN-chan suggest you to ${type.split('_').reversed.join(' ')}',
                ).fontSize(13).opacity(0.8),
              ],
            ).padding(top: 3, bottom: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
