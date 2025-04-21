import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:url_launcher/url_launcher_string.dart';

class MarkdownTextContent extends StatelessWidget {
  final String content;
  final bool isAutoWarp;
  final bool isEnlargeSticker;
  final TextScaler? textScaler;
  final Color? textColor;

  const MarkdownTextContent({
    super.key,
    required this.content,
    this.isAutoWarp = false,
    this.isEnlargeSticker = false,
    this.textScaler,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Markdown(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      data: content,
      padding: EdgeInsets.zero,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        textScaler: textScaler,
        p:
            textColor != null
                ? Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: textColor)
                : null,
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Theme.of(context).dividerColor),
          ),
        ),
        codeblockDecoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.3),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        ),
        code: GoogleFonts.robotoMono(height: 1),
      ),
      builders: {'latex': LatexElementBuilder(), 'code': HighlightBuilder()},
      softLineBreak: true,
      extensionSet: markdown.ExtensionSet(
        <markdown.BlockSyntax>[
          ...markdown.ExtensionSet.gitHubFlavored.blockSyntaxes,
          markdown.CodeBlockSyntax(),
          markdown.FencedCodeBlockSyntax(),
          LatexBlockSyntax(),
        ],
        <markdown.InlineSyntax>[
          ...markdown.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          if (isAutoWarp) markdown.LineBreakSyntax(),
          _UserNameCardInlineSyntax(),
          markdown.AutolinkSyntax(),
          markdown.AutolinkExtensionSyntax(),
          markdown.CodeSyntax(),
          LatexInlineSyntax(),
        ],
      ),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        await launchUrlString(href, mode: LaunchMode.externalApplication);
      },
    );
  }
}

class _UserNameCardInlineSyntax extends markdown.InlineSyntax {
  _UserNameCardInlineSyntax() : super(r'@[a-zA-Z0-9_]+');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final alias = match[0]!;
    final anchor = markdown.Element.text('a', alias)
      ..attributes['href'] = Uri.encodeFull(
        'solink://accounts/${alias.substring(1)}',
      );
    parser.addNode(anchor);

    return true;
  }
}

class HighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (element.attributes['class'] == null &&
        !element.textContent.trim().contains('\n')) {
      return Container(
        padding: EdgeInsets.only(top: 0.0, right: 4.0, bottom: 1.75, left: 4.0),
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        color: Colors.black12,
        child: Text(
          element.textContent,
          style: GoogleFonts.robotoMono(textStyle: preferredStyle),
        ),
      );
    } else {
      var language = 'plaintext';
      final pattern = RegExp(r'^language-(.+)$');
      if (element.attributes['class'] != null &&
          pattern.hasMatch(element.attributes['class'] ?? '')) {
        language =
            pattern.firstMatch(element.attributes['class'] ?? '')?.group(1) ??
            'plaintext';
      }
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: HighlightView(
          element.textContent.trim(),
          language: language,
          theme: {
            ...(isDark ? themeMap['a11y-dark']! : themeMap['a11y-light']!),
            'root':
                (isDark
                    ? TextStyle(
                      backgroundColor: Colors.transparent,
                      color: Color(0xfff8f8f2),
                    )
                    : TextStyle(
                      backgroundColor: Colors.transparent,
                      color: Color(0xff545454),
                    )),
          },
          padding: EdgeInsets.all(12),
          textStyle: GoogleFonts.robotoMono(textStyle: preferredStyle),
        ),
      );
    }
  }
}
