import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/database.dart';
import 'package:island/shared/widgets/content/markdown_remote_image.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/shared/widgets/content/markdown_latex.dart';
import 'package:island/shared/widgets/content/sticker_sheet.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/stickers/models/sticker.dart';

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
  final List<dynamic> extraGenerators;
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
    this.extraGenerators = const [],
    this.noMentionChip = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    final onMentionTap = useCallback((String type, String id) {
      final fullPath = '/$type/$id';
      context.router.pushPath(fullPath);
    }, [context]);

    final mentionGenerator = MentionChipGenerator(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      onTap: onMentionTap,
    );

    final highlightGenerator = HighlightGenerator(
      highlightColor: Theme.of(context).colorScheme.primaryContainer,
    );

    final spoilerRevealed = useState(false);

    final spoilerGenerator = SpoilerGenerator(
      revealed: spoilerRevealed.value,
      onToggle: () => spoilerRevealed.value = !spoilerRevealed.value,
    );

    final stickerGenerator = StickerGenerator(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      content: content,
    );

    return MarkdownBlock(
      data: content,
      selectable: isSelectable,
      config: config.copy(
        configs: [
          isDark
              ? PreConfig.darkConfig.copy(textStyle: textStyle)
              : PreConfig().copy(textStyle: textStyle),
          PConfig(
            textStyle: (textStyle ?? Theme.of(context).textTheme.bodyMedium!),
          ),
          Heading1Config(),
          Heading2Config(),
          Heading3Config(),
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
            wrapper: (child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
          LinkConfig(
            style:
                linkStyle ??
                TextStyle(color: Theme.of(context).colorScheme.primary),
            onTap: (href) async {
              final url = Uri.tryParse(href);
              if (url != null) {
                if (url.scheme == 'solian') {
                  final fullPath = ['/', url.host, url.path].join('');
                  context.router.pushPath(fullPath);
                  return;
                }
                await openExternalLink(url, ref);
              } else {
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
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
              }
              return MarkdownRemoteImage(uri: uri);
            },
          ),
        ],
      ),
      generator: MarkdownTextContent.buildGenerator(
        isDark: isDark,
        linesMargin: linesMargin,
        generators: [
          if (!noMentionChip) mentionGenerator,
          highlightGenerator,
          spoilerGenerator,
          stickerGenerator,
          ...extraGenerators,
        ],
        extraInlineSyntaxList: extraInlineSyntaxList,
        extraBlockSyntaxList: extraBlockSyntaxList,
      ),
    );
  }

  static MarkdownGenerator buildGenerator({
    bool isDark = false,
    EdgeInsets? linesMargin,
    List<dynamic> generators = const [],
    List<markdown.InlineSyntax> extraInlineSyntaxList = const [],
    List<markdown.BlockSyntax> extraBlockSyntaxList = const [],
  }) {
    return MarkdownGenerator(
      generators: [
        latexGenerator,
        ...generators,
        SpanNodeGeneratorWithTag(
          tag: MarkdownTag.hr.name,
          generator: (e, config, visitor) => DividerNode(),
        ),
      ],
      inlineSyntaxList: [
        _MentionInlineSyntax(),
        _HighlightInlineSyntax(),
        _SpoilerInlineSyntax(),
        _StickerInlineSyntax(),
        LatexSyntax(isDark),
        ...extraInlineSyntaxList,
      ],
      blockSyntaxList: extraBlockSyntaxList,
      linesMargin: linesMargin ?? EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class _MentionInlineSyntax extends markdown.InlineSyntax {
  _MentionInlineSyntax()
    : super(r'(^|[^A-Za-z0-9._%+\-/\[])(@[-A-Za-z0-9_./]+)');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final prefix = match[1] ?? '';
    final alias = match[2]!;

    if (prefix.isNotEmpty) {
      parser.addNode(markdown.Text(prefix));
    }

    final parts = alias.substring(1).split('/');
    final typeShortcut = parts.length == 1 ? 'u' : parts.first;
    final type = switch (typeShortcut) {
      'u' => 'accounts',
      'r' => 'realms',
      'p' => 'publishers',
      _ => '',
    };
    final element = markdown.Element('mention-chip', [markdown.Text(alias)])
      ..attributes['alias'] = alias
      ..attributes['type'] = type
      ..attributes['id'] = parts.last;
    parser.addNode(element);

    return true;
  }
}

class _StickerInlineSyntax extends markdown.InlineSyntax {
  _StickerInlineSyntax() : super(MarkdownTextContent.stickerRegex);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final placeholder = match[1]!;
    final element = markdown.Element('sticker', [markdown.Text(placeholder)]);
    parser.addNode(element);

    return true;
  }
}

class _HighlightInlineSyntax extends markdown.InlineSyntax {
  _HighlightInlineSyntax() : super(r'==([^=]+)==');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final text = match[1]!;
    final element = markdown.Element('highlight', [markdown.Text(text)]);
    parser.addNode(element);

    return true;
  }
}

class _SpoilerInlineSyntax extends markdown.InlineSyntax {
  _SpoilerInlineSyntax() : super(r'=!([^!]+)!=');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final text = match[1]!;
    final element = markdown.Element('spoiler', [markdown.Text(text)]);
    parser.addNode(element);

    return true;
  }
}

class MentionSpanNodeGenerator {
  final Color backgroundColor;
  final Color foregroundColor;
  final void Function(String type, String id) onTap;

  MentionSpanNodeGenerator({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  SpanNode? call(
    String tag,
    Map<String, String> attributes,
    List<SpanNode> children,
  ) {
    if (tag == 'mention-chip') {
      return MentionChipSpanNode(
        attributes: attributes,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
      );
    }
    return null;
  }
}

class MentionChipGenerator extends SpanNodeGeneratorWithTag {
  MentionChipGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required void Function(String type, String id) onTap,
  }) : super(
         tag: 'mention-chip',
         generator:
             (
               markdown.Element element,
               MarkdownConfig config,
               WidgetVisitor visitor,
             ) {
               return MentionChipSpanNode(
                 attributes: element.attributes,
                 backgroundColor: backgroundColor,
                 foregroundColor: foregroundColor,
                 onTap: onTap,
               );
             },
       );
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
        error: (_, _) => Text(
          alias,
          style: TextStyle(
            color: backgroundColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        loading: () => Text(
          alias,
          style: TextStyle(
            color: backgroundColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return _buildStaticChip(mentionType, id);
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

  Widget _buildStaticChip(String type, String id) {
    final icon = switch (type) {
      'chat' => Symbols.forum_rounded,
      'realms' => Symbols.group_rounded,
      _ => Symbols.person_rounded,
    };

    return _buildChip(
      Icon(icon, size: 14, color: foregroundColor, fill: 1).padding(all: 2),
      id,
      useState(false),
    );
  }
}

class MentionChipSpanNode extends SpanNode {
  final Map<String, String> attributes;
  final Color backgroundColor;
  final Color foregroundColor;
  final void Function(String type, String id) onTap;

  MentionChipSpanNode({
    required this.attributes,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  InlineSpan build() {
    final alias = attributes['alias'] ?? '';
    final type = attributes['type'] ?? '';
    final id = attributes['id'] ?? '';

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _MentionChipContent(
        mentionType: type,
        id: id,
        alias: alias,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: () => onTap(type, id),
      ),
    );
  }
}

class HighlightGenerator extends SpanNodeGeneratorWithTag {
  HighlightGenerator({required Color highlightColor})
    : super(
        tag: 'highlight',
        generator:
            (
              markdown.Element element,
              MarkdownConfig config,
              WidgetVisitor visitor,
            ) {
              return HighlightSpanNode(
                text: element.textContent,
                highlightColor: highlightColor,
              );
            },
      );
}

class HighlightSpanNode extends SpanNode {
  final String text;
  final Color highlightColor;

  HighlightSpanNode({required this.text, required this.highlightColor});

  @override
  InlineSpan build() {
    return TextSpan(
      text: text,
      style: TextStyle(backgroundColor: highlightColor),
    );
  }
}

class SpoilerGenerator extends SpanNodeGeneratorWithTag {
  SpoilerGenerator({required bool revealed, required VoidCallback onToggle})
    : super(
        tag: 'spoiler',
        generator:
            (
              markdown.Element element,
              MarkdownConfig config,
              WidgetVisitor visitor,
            ) {
              return SpoilerSpanNode(
                text: element.textContent,
                revealed: revealed,
                onToggle: onToggle,
              );
            },
      );
}

class SpoilerSpanNode extends SpanNode {
  final String text;
  final bool revealed;
  final VoidCallback onToggle;

  SpoilerSpanNode({
    required this.text,
    required this.revealed,
    required this.onToggle,
  });

  @override
  InlineSpan build() {
    final recognizer = TapGestureRecognizer()..onTap = onToggle;

    return TextSpan(
      children: _buildSpoilerSegments(recognizer),
    );
  }

  List<InlineSpan> _buildSpoilerSegments(TapGestureRecognizer recognizer) {
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
                    ? Text(part, key: ValueKey('revealed-$part'), style: baseStyle)
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

class StickerGenerator extends SpanNodeGeneratorWithTag {
  StickerGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required String content,
  }) : super(
         tag: 'sticker',
         generator:
             (
               markdown.Element element,
               MarkdownConfig config,
               WidgetVisitor visitor,
             ) {
               return StickerSpanNode(
                 placeholder: element.textContent,
                 backgroundColor: backgroundColor,
                 foregroundColor: foregroundColor,
                 isStandalone: _isStandaloneStickerInContent(
                   content,
                   element.textContent,
                 ),
               );
             },
       );
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

class StickerSpanNode extends SpanNode {
  final String placeholder;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isStandalone;

  StickerSpanNode({
    required this.placeholder,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isStandalone,
  });

  @override
  InlineSpan build() {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Builder(
        builder: (context) {
          return _StickerInlineContent(
            placeholder: placeholder,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            isStandalone: isStandalone,
          );
        },
      ),
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

    return stickerAsync.when(
      data: (sticker) {
        final parts = placeholder.split('+');
        final packPrefix =
            sticker?.pack?.prefix ?? (parts.isNotEmpty ? parts[0] : '');
        final stickerCode = ':$placeholder:';
        final renderSticker = sticker;
        final renderSize = renderSticker == null
            ? _StickerRenderSize.medium
            : _resolveStickerRenderSize(renderSticker, isStandalone);
        final dimension = _stickerRenderDimension(renderSize);
        final label = renderSticker?.name?.trim().isNotEmpty == true
            ? renderSticker!.name!
            : renderSticker?.slug ?? placeholder;

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
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                  width: dimension,
                  height: dimension,
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: renderSticker == null
                      ? Icon(
                          Symbols.emoji_symbols,
                          size: dimension * 0.45,
                          color: foregroundColor,
                        )
                      : CloudImageWidget(
                          file: renderSticker.image,
                          fit: BoxFit.contain,
                          noBlurhash: true,
                        ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _StickerLoadingPlaceholder(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        dimension: _stickerRenderDimension(_StickerRenderSize.medium),
      ),
      error: (_, _) => _StickerLoadingPlaceholder(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        dimension: _stickerRenderDimension(_StickerRenderSize.medium),
      ),
    );
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
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Icon(
          Symbols.emoji_symbols,
          size: dimension * 0.45,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class DividerNode extends SpanNode {
  DividerNode();

  @override
  InlineSpan build() {
    return WidgetSpan(child: const Divider());
  }
}

class Heading1Config extends HeadingConfig {
  @override
  final TextStyle style;

  const Heading1Config({
    this.style = const TextStyle(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  String get tag => MarkdownTag.h1.name;

  static Heading1Config get darkConfig => const Heading1Config(
    style: TextStyle(
      fontSize: 32,
      height: 40 / 32,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

class Heading2Config extends HeadingConfig {
  @override
  final TextStyle style;

  const Heading2Config({
    this.style = const TextStyle(
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  String get tag => MarkdownTag.h2.name;

  static Heading2Config get darkConfig => const Heading2Config(
    style: TextStyle(
      fontSize: 24,
      height: 30 / 24,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

class Heading3Config extends HeadingConfig {
  @override
  final TextStyle style;

  const Heading3Config({
    this.style = const TextStyle(
      fontSize: 20,
      height: 25 / 20,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  String get tag => MarkdownTag.h3.name;

  static Heading3Config get darkConfig => const Heading3Config(
    style: TextStyle(
      fontSize: 20,
      height: 25 / 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}
