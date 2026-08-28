import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/markdown_latex.dart';
import 'package:island/shared/widgets/content/markdown_remote_image.dart';
import 'package:island/shared/widgets/content/sticker_sheet.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final _stickerLookupCache = <String, SnSticker>{};

final stickerLookupProvider = FutureProvider.family<SnSticker?, String>((
  ref,
  identifier,
) async {
  final key = identifier.trim();
  if (key.isEmpty) return null;

  final cached = _stickerLookupCache[key];
  if (cached != null) return cached;

  final db = ref.read(databaseProvider);
  try {
    final dbSticker = await db.getStickerLookup(key);
    if (dbSticker != null) {
      _stickerLookupCache[key] = dbSticker;
      _stickerLookupCache[dbSticker.id] = dbSticker;
      return dbSticker;
    }
  } catch (_) {}

  try {
    final client = ref.watch(apiClientProvider);
    final response = await client.get(
      '/sphere/stickers/lookup/${Uri.encodeComponent(key)}',
    );
    final sticker = SnSticker.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
    _stickerLookupCache[key] = sticker;
    _stickerLookupCache[sticker.id] = sticker;
    try {
      await db.setStickerLookup(key, sticker);
      await db.setStickerLookup(sticker.id, sticker);
    } catch (_) {}
    return sticker;
  } catch (_) {
    return null;
  }
});

final _stickerParagraphCache = <String, bool>{};

bool _isStandaloneStickerInContent(String content, String placeholder) {
  final cached = _stickerParagraphCache['$content::$placeholder'];
  if (cached != null) return cached;

  final paragraphMatches = RegExp(
    r'(?:^|\n\s*\n)(.*?)(?=\n\s*\n|$)',
    dotAll: true,
  ).allMatches(content);
  for (final match in paragraphMatches) {
    final paragraph = match.group(1)?.trim() ?? '';
    if (paragraph.isEmpty) continue;

    final stickers = RegExp(
      MarkdownTextContent.stickerRegex,
    ).allMatches(paragraph).map((m) => m.group(1)!).toList();
    if (stickers.contains(placeholder)) {
      final nonSticker = paragraph
          .replaceAll(RegExp(MarkdownTextContent.stickerRegex), '')
          .trim();
      final standalone = stickers.length == 1 && nonSticker.isEmpty;
      _stickerParagraphCache['$content::$placeholder'] = standalone;
      return standalone;
    }
  }

  _stickerParagraphCache['$content::$placeholder'] = false;
  return false;
}

class MarkdownTextContent extends HookConsumerWidget {
  static const String stickerRegex = r':([-\w]*\+[-\w]*):';

  final String content;
  final bool isAutoWarp;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final EdgeInsets? linesMargin;
  final bool isSelectable;
  final List<IDisplayableCloudFile>? attachments;
  final List<markdown.InlineSyntax> extraInlineSyntaxList;
  final List<markdown.BlockSyntax> extraBlockSyntaxList;
  final Map<String, MarkdownElementBuilder> extraBuilders;
  final bool noMentionChip;

  const MarkdownTextContent({
    super.key,
    required this.content,
    this.isAutoWarp = false,
    this.textStyle,
    this.linkStyle,
    this.isSelectable = false,
    this.linesMargin,
    this.attachments,
    this.extraInlineSyntaxList = const [],
    this.extraBlockSyntaxList = const [],
    this.extraBuilders = const {},
    this.noMentionChip = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = flutter.Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);
    final bodyStyle = textStyle ?? baseStyle.p;
    final codeStyle = GoogleFonts.robotoMono(
      fontSize: 14,
      color: bodyStyle?.color,
    );
    final blockSpacing = linesMargin?.vertical ?? 4;

    final onMentionTap = useCallback((String type, String id) {
      if (type == 'accounts') {
        showAccountProfileAttentionModal(id);
        return;
      }
      if (type == 'publishers') {
        showPublisherProfileAttentionModal(id);
        return;
      }
      context.router.navigatePath('/$type/$id');
    }, [context]);

    final spoilerRevealed = useState(false);
    final builders = <String, MarkdownElementBuilder>{
      'markdown-line-break': _MarkdownLineBreakBuilder(),
      if (!noMentionChip)
        'mention-chip': MentionChipGenerator(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          onTap: onMentionTap,
        ),
      'highlight': SolarHighlightGenerator(
        highlightColor: scheme.primaryContainer,
      ),
      'spoiler': SolarSpoilerGenerator(
        revealed: spoilerRevealed.value,
        onToggle: () => spoilerRevealed.value = !spoilerRevealed.value,
      ),
      'sticker': StickerGenerator(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        content: content,
      ),
      latexTag: LatexBuilder(isDark: isDark),
      ...extraBuilders,
    };

    return MarkdownBody(
      data: content,
      selectable: isSelectable,
      softLineBreak: true,
      styleSheet: baseStyle.copyWith(
        a: linkStyle ?? baseStyle.a?.copyWith(color: scheme.primary),
        p: bodyStyle,
        pPadding: EdgeInsets.zero,
        h1Padding: EdgeInsets.zero,
        h2Padding: EdgeInsets.zero,
        h3Padding: EdgeInsets.zero,
        h4Padding: EdgeInsets.zero,
        h5Padding: EdgeInsets.zero,
        h6Padding: EdgeInsets.zero,
        blockSpacing: blockSpacing,
        code: codeStyle,
        codeblockDecoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        codeblockPadding: const EdgeInsets.all(8),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1 / MediaQuery.devicePixelRatioOf(context),
            ),
          ),
        ),
      ),
      inlineSyntaxes: [
        _MarkdownLineBreakSyntax(),
        SolarMentionInlineSyntax(),
        SolarHighlightInlineSyntax(),
        SolarSpoilerInlineSyntax(),
        _StickerInlineSyntax(),
        LatexSyntax(),
        ...extraInlineSyntaxList,
      ],
      blockSyntaxes: extraBlockSyntaxList,
      builders: builders,
      onTapLink: (text, href, title) async {
        if (href == null) {
          _showBrokenLinkSnackBar(context, text);
          return;
        }
        final url = Uri.tryParse(href);
        if (url == null) {
          _showBrokenLinkSnackBar(context, href);
          return;
        }
        if (openPostDetailAttentionModalForUri(url)) return;

        final routePath = solianLinkToRoutePath(url);
        if (routePath != null &&
            tryNavigateToRoutePath(ref.read(routerProvider), routePath)) {
          return;
        }
        await openExternalLink(url, ref);
      },
      imageBuilder: (uri, title, alt) {
        if (uri.scheme == 'solian' &&
            uri.host == 'files' &&
            uri.pathSegments.isNotEmpty) {
          final file = attachments?.firstWhereOrNull(
            (file) => file.id == uri.pathSegments.first,
          );
          if (file == null) return const SizedBox.shrink();

          return InkWell(
            onTap: () {
              context.pushTransparentRoute(
                CloudFileLightbox(
                  items: [file],
                  initialIndex: 0,
                  heroTag: 'cloud-file-markdown-${file.id}',
                ),
                rootNavigator: true,
              );
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: CloudFileWidget(
                  item: file,
                  heroTag: 'cloud-file-markdown-${file.id}',
                  fit: BoxFit.cover,
                ).clipRRect(all: 8),
              ),
            ),
          );
        }
        return MarkdownRemoteImage(uri: uri);
      },
    );
  }

  void _showBrokenLinkSnackBar(BuildContext context, String href) {
    showSnackBar(
      'brokenLink'.tr(args: [href]),
      action: SnackBarAction(
        label: 'copyToClipboard'.tr(),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: href));
        },
      ),
    );
  }
}

class _MarkdownLineBreakSyntax extends markdown.InlineSyntax {
  _MarkdownLineBreakSyntax() : super(r'\n');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    parser.addNode(markdown.Element('markdown-line-break', const []));
    return true;
  }
}

class _MarkdownLineBreakBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return const SizedBox(width: double.infinity, height: 0);
  }
}

class _StickerInlineSyntax extends markdown.InlineSyntax {
  _StickerInlineSyntax() : super(MarkdownTextContent.stickerRegex);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    parser.addNode(markdown.Element('sticker', [markdown.Text(match[1]!)]));
    return true;
  }
}

class MentionChipGenerator extends MarkdownElementBuilder {
  MentionChipGenerator({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final void Function(String type, String id) onTap;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final attributes = element.attributes;
    final type = attributes['type'] ?? '';
    final id = attributes['id'] ?? '';
    return _MentionChipContent(
      mentionType: type,
      id: id,
      alias: attributes['alias'] ?? '',
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onTap: () => onTap(type, id),
    );
  }
}

class _MentionChipContent extends HookConsumerWidget {
  final String mentionType;
  final String id;
  final String alias;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _MentionChipContent({
    required this.mentionType,
    required this.id,
    required this.alias,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);

    if (mentionType == 'accounts' || mentionType == 'publishers') {
      final data = mentionType == 'accounts'
          ? ref.watch(accountProvider(id))
          : ref.watch(publisherProvider(id));

      return data.when(
        data: (profile) {
          final picture = mentionType == 'accounts'
              ? (profile as SnAccount).profile.picture
              : (profile as SnPublisher).picture;
          final icon = mentionType == 'accounts'
              ? Symbols.person_rounded
              : Symbols.design_services_rounded;
          return _buildChip(
            ProfilePictureWidget(file: picture, fallbackIcon: icon, radius: 9),
            id,
            isHovered,
          );
        },
        error: (_, _) => _buildFallback(),
        loading: _buildFallback,
      );
    }

    final icon = switch (mentionType) {
      'chat' => Symbols.forum_rounded,
      'realms' => Symbols.group_rounded,
      _ => Symbols.person_rounded,
    };
    return _buildChip(
      Icon(icon, size: 14, color: foregroundColor, fill: 1).padding(all: 2),
      id,
      isHovered,
    );
  }

  Widget _buildFallback() {
    return Text(
      alias,
      style: TextStyle(
        color: backgroundColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChip(
    Widget avatar,
    String displayName,
    ValueNotifier<bool> isHovered,
  ) {
    return InkWell(
      onTap: onTap,
      onHover: (value) => isHovered.value = value,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.only(
          left: 5,
          right: 7,
          top: 2.5,
          bottom: 2.5,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(32)),
              ),
              child: avatar,
            ),
            Text(
              displayName,
              style: TextStyle(
                color: backgroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StickerGenerator extends MarkdownElementBuilder {
  StickerGenerator({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.content,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final String content;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return StickerSpanNode(
      placeholder: element.textContent,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isStandalone: _isStandaloneStickerInContent(content, element.textContent),
    );
  }
}

enum _StickerRenderSize { small, medium, large }

double _stickerRenderDimension(_StickerRenderSize size) => switch (size) {
  _StickerRenderSize.small => 24,
  _StickerRenderSize.medium => 48,
  _StickerRenderSize.large => 96,
};

_StickerRenderSize _resolveStickerRenderSize(
  SnSticker sticker,
  bool isStandalone,
) {
  if (sticker.size != 0) {
    return switch (sticker.size) {
      1 => _StickerRenderSize.small,
      2 => _StickerRenderSize.medium,
      3 => _StickerRenderSize.large,
      _ => _StickerRenderSize.medium,
    };
  }

  if (sticker.mode == 1) {
    return isStandalone ? _StickerRenderSize.medium : _StickerRenderSize.small;
  }

  return isStandalone ? _StickerRenderSize.large : _StickerRenderSize.medium;
}

class StickerSpanNode extends StatelessWidget {
  final String placeholder;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isStandalone;

  const StickerSpanNode({
    super.key,
    required this.placeholder,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isStandalone,
  });

  @override
  Widget build(BuildContext context) {
    return _StickerInlineContent(
      placeholder: placeholder,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isStandalone: isStandalone,
    );
  }
}

class _StickerInlineContent extends ConsumerWidget {
  final String placeholder;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isStandalone;

  const _StickerInlineContent({
    required this.placeholder,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isStandalone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickerAsync = ref.watch(stickerLookupProvider(placeholder));

    return stickerAsync
        .when(
          data: (sticker) {
            final parts = placeholder.split('+');
            final packPrefix =
                sticker?.pack?.prefix ?? (parts.isNotEmpty ? parts[0] : '');
            final stickerCode = ':$placeholder:';
            final renderSize = sticker == null
                ? _StickerRenderSize.medium
                : _resolveStickerRenderSize(sticker, isStandalone);
            final dimension = _stickerRenderDimension(renderSize);
            final label = sticker?.name?.trim().isNotEmpty == true
                ? sticker!.name!
                : sticker?.slug ?? placeholder;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isStandalone ? 0 : 3),
              child: Tooltip(
                message: label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      showStickerPackSheet(context, packPrefix, stickerCode),
                  onSecondaryTap: () {
                    Clipboard.setData(ClipboardData(text: stickerCode));
                  },
                  child: SizedBox(
                    width: dimension,
                    height: dimension,
                    child: sticker == null
                        ? Icon(
                            Symbols.emoji_symbols,
                            size: dimension * 0.45,
                            color: foregroundColor,
                          )
                        : CloudImageWidget(
                            file: sticker.image,
                            fit: BoxFit.contain,
                            noBlurhash: true,
                          ),
                  ),
                ),
              ),
            );
          },
          loading: () => _StickerLoadingPlaceholder(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            dimension: 48,
          ),
          error: (_, _) => _StickerLoadingPlaceholder(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            dimension: 48,
          ),
        )
        .clipRRect(all: 8);
  }
}

class _StickerLoadingPlaceholder extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double dimension;

  const _StickerLoadingPlaceholder({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: flutter.Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Icon(
        Symbols.emoji_symbols,
        size: dimension * 0.45,
        color: foregroundColor,
      ),
    );
  }
}
