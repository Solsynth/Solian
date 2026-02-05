import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account/profile.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/posts/posts_models/publisher.dart';
import 'package:island/core/config.dart';
import 'package:island/posts/publisher_profile.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/core/widgets/content/markdown_latex.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';

import 'image.dart';

class MarkdownTextContent extends HookConsumerWidget {
  static const String stickerRegex = r':([-\w]*\+[-\w]*):';

  final String content;
  final bool isAutoWarp;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final EdgeInsets? linesMargin;
  final bool isSelectable;
  final List<SnCloudFile>? attachments;
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
    final doesEnlargeSticker = useMemoized(() {
      // Check if content only contains one sticker by matching the sticker pattern
      final stickerPattern = RegExp(stickerRegex);
      final matches = stickerPattern.allMatches(content);

      // Content should only contain one sticker and nothing else (except whitespace)
      final contentWithoutStickers = content
          .replaceAll(stickerPattern, '')
          .trim();
      return matches.length == 1 && contentWithoutStickers.isEmpty;
    }, [content]);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    final onMentionTap = useCallback((String type, String id) {
      final fullPath = '/$type/$id';
      context.push(fullPath);
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
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      foregroundColor: Theme.of(context).colorScheme.onTertiary,
      outlineColor: Theme.of(context).colorScheme.outline,
      revealed: spoilerRevealed.value,
      onToggle: () => spoilerRevealed.value = !spoilerRevealed.value,
    );

    final baseUrl = ref.watch(serverUrlProvider);
    final stickerGenerator = StickerGenerator(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      isEnlarged: doesEnlargeSticker,
      baseUrl: baseUrl,
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
                  context.push(fullPath);
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

                    final heroTag = 'cloud-file-markdown#${const Uuid().v4()}';
                    return InkWell(
                      onTap: () {
                        context.pushTransparentRoute(
                          CloudFileLightbox(item: file, heroTag: heroTag),
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
                            heroTag: heroTag,
                            fit: BoxFit.cover,
                          ).clipRRect(all: 8),
                        ),
                      ),
                    );
                }
              }
              final content = ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360),
                  child: UniversalImage(
                    uri: uri.toString(),
                    fit: BoxFit.contain,
                  ),
                ),
              );
              return content;
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
      generators: [latexGenerator, ...generators],
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
  _MentionInlineSyntax() : super(r'(^|[^A-Za-z0-9._%+\-])(@[-A-Za-z0-9_./]+)');

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
  SpoilerGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color outlineColor,
    required bool revealed,
    required VoidCallback onToggle,
  }) : super(
         tag: 'spoiler',
         generator:
             (
               markdown.Element element,
               MarkdownConfig config,
               WidgetVisitor visitor,
             ) {
               return SpoilerSpanNode(
                 text: element.textContent,
                 backgroundColor: backgroundColor,
                 foregroundColor: foregroundColor,
                 outlineColor: outlineColor,
                 revealed: revealed,
                 onToggle: onToggle,
               );
             },
       );
}

class SpoilerSpanNode extends SpanNode {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color outlineColor;
  final bool revealed;
  final VoidCallback onToggle;

  SpoilerSpanNode({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.outlineColor,
    required this.revealed,
    required this.onToggle,
  });

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: InkWell(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: revealed ? Colors.transparent : backgroundColor,
            border: revealed ? Border.all(color: outlineColor, width: 1) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: revealed
              ? Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Symbols.visibility, size: 18).padding(top: 1),
                    Flexible(child: Text(text)),
                  ],
                )
              : Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.visibility_off,
                      color: foregroundColor,
                      size: 18,
                    ),
                    Flexible(
                      child: Text(
                        'spoiler',
                        style: TextStyle(color: foregroundColor),
                      ).tr(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class StickerGenerator extends SpanNodeGeneratorWithTag {
  StickerGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isEnlarged,
    required String baseUrl,
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
                 isEnlarged: isEnlarged,
                 baseUrl: baseUrl,
               );
             },
       );
}

class StickerSpanNode extends SpanNode {
  final String placeholder;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isEnlarged;
  final String baseUrl;

  StickerSpanNode({
    required this.placeholder,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isEnlarged,
    required this.baseUrl,
  });

  @override
  InlineSpan build() {
    final size = isEnlarged ? 96.0 : 24.0;
    final stickerUri = '$baseUrl/sphere/stickers/lookup/$placeholder/open';
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: UniversalImage(
            uri: stickerUri,
            width: size,
            height: size,
            fit: BoxFit.contain,
            noCacheOptimization: true,
          ),
        ),
      ),
    );
  }
}
