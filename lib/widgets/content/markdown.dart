import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown_latex.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'image.dart';

class MarkdownTextContent extends HookConsumerWidget {
  final String content;
  final bool isAutoWarp;
  final TextScaler? textScaler;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final EdgeInsets? linesMargin;
  final bool isSelectable;
  final List<SnCloudFile>? attachments;

  const MarkdownTextContent({
    super.key,
    required this.content,
    this.isAutoWarp = false,
    this.textScaler,
    this.textStyle,
    this.linkStyle,
    this.isSelectable = false,
    this.linesMargin,
    this.attachments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(serverUrlProvider);
    final doesEnlargeSticker = useMemoized(() {
      // Check if content only contains one sticker by matching the sticker pattern
      final stickerPattern = RegExp(r':([-\w]+):');
      final matches = stickerPattern.allMatches(content);

      // Content should only contain one sticker and nothing else (except whitespace)
      final contentWithoutStickers =
          content.replaceAll(stickerPattern, '').trim();
      return matches.length == 1 && contentWithoutStickers.isEmpty;
    }, [content]);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;

    return MarkdownBlock(
      data: content,
      selectable: isSelectable,
      config: config.copy(
        configs: [
          isDark
              ? PreConfig.darkConfig.copy(textStyle: textStyle)
              : PreConfig().copy(textStyle: textStyle),
          PConfig(
            textStyle: textStyle ?? Theme.of(context).textTheme.bodyMedium!,
          ),
          HrConfig(height: 1, color: Theme.of(context).dividerColor),
          PreConfig(
            theme: isDark ? a11yDarkTheme : a11yLightTheme,
            textStyle: GoogleFonts.robotoMono(fontSize: 14),
            styleNotMatched: GoogleFonts.robotoMono(fontSize: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          TableConfig(
            wrapper:
                (child) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: child,
                ),
          ),
          LinkConfig(
            style:
                linkStyle ??
                TextStyle(color: Theme.of(context).colorScheme.primary),
            onTap: (href) {
              final url = Uri.tryParse(href);
              if (url != null) {
                if (url.scheme == 'solian') {
                  if (url.host == 'account') {
                    context.pushNamed(
                      'accountProfile',
                      pathParameters: {'name': url.pathSegments[0]},
                    );
                  }
                  return;
                }
                final whitelistDomains = ['solian.app', 'solsynth.dev'];
                if (whitelistDomains.contains(url.host)) {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                  return;
                }
                showConfirmAlert(
                  'openLinkConfirmDescription'.tr(args: [url.toString()]),
                  'openLinkConfirm'.tr(),
                ).then((value) {
                  if (value) {
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                });
              } else {
                showSnackBar(
                  'brokenLink'.tr(args: [href]),
                  action: SnackBarAction(
                    label: 'copyToClipboard'.tr(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: href));
                      clearSnackBar(context);
                    },
                  ),
                );
              }
            },
          ),
          ImgConfig(
            builder: (url, attributes) {
              final uri = Uri.parse(url);
              if (uri.scheme == 'solian') {
                switch (uri.host) {
                  case 'files':
                    final file = attachments?.firstWhereOrNull(
                      (file) => file.id == uri.pathSegments[0],
                    );
                    if (file == null) {
                      return const SizedBox.shrink();
                    }

                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: CloudFileWidget(
                          item: file,
                          fit: BoxFit.cover,
                        ).clipRRect(all: 8),
                      ),
                    );
                  case 'stickers':
                    final size = doesEnlargeSticker ? 96.0 : 24.0;
                    final stickerUri =
                        '$baseUrl/sphere/stickers/lookup/${uri.pathSegments[0]}/open';
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: UniversalImage(
                          uri: stickerUri,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          noCacheOptimization: true,
                        ),
                      ),
                    );
                }
              }
              final content = ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 360),
                child: UniversalImage(uri: uri.toString(), fit: BoxFit.contain),
              );
              return content;
            },
          ),
        ],
      ),
      generator: MarkdownTextContent.buildGenerator(
        isDark: isDark,
        linesMargin: linesMargin,
      ),
    );
  }

  static MarkdownGenerator buildGenerator({
    bool isDark = false,
    EdgeInsets? linesMargin,
  }) {
    return MarkdownGenerator(
      generators: [latexGenerator],
      inlineSyntaxList: [
        _UserNameCardInlineSyntax(),
        _StickerInlineSyntax(),
        LatexSyntax(isDark),
      ],
      linesMargin: linesMargin ?? EdgeInsets.symmetric(vertical: 4),
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
        'solian://account/${alias.substring(1)}',
      );
    parser.addNode(anchor);

    return true;
  }
}

class _StickerInlineSyntax extends markdown.InlineSyntax {
  _StickerInlineSyntax() : super(r':([-\w]+):');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final placeholder = match[1]!;
    final image = markdown.Element.text('img', '')
      ..attributes['src'] = Uri.encodeFull('solian://stickers/$placeholder');
    parser.addNode(image);

    return true;
  }
}
