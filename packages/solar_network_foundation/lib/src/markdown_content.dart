import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Portable renderer for user-authored Markdown.
///
/// Hosts own navigation by supplying [onLinkTap], keeping this widget free of
/// application routers and external-browser dependencies.
class SolarMarkdownContent extends StatelessWidget {
  const SolarMarkdownContent({
    super.key,
    required this.content,
    this.selectable = true,
    this.textStyle,
    this.onLinkTap,
  });

  final String content;
  final bool selectable;
  final TextStyle? textStyle;
  final Future<void> Function(Uri uri)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);

    return MarkdownBody(
      data: content,
      selectable: selectable,
      styleSheet: baseStyle.copyWith(
        p: textStyle ?? baseStyle.p,
        a: baseStyle.a?.copyWith(color: scheme.primary),
        code: baseStyle.code?.copyWith(fontFamily: 'monospace'),
        codeblockDecoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(8),
      ),
      onTapLink: (text, href, title) async {
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri != null) await onLinkTap?.call(uri);
      },
      imageBuilder: (uri, title, alt) {
        final isNetworkImage = uri.scheme == 'https' || uri.scheme == 'http';
        if (!isNetworkImage) {
          return _MarkdownImageFallback(alt: alt ?? 'Image unavailable');
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: Image.network(
              uri.toString(),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  _MarkdownImageFallback(alt: alt ?? 'Image unavailable'),
            ),
          ),
        );
      },
      checkboxBuilder: (checked) => Icon(
        checked ? Icons.check_box : Icons.check_box_outline_blank,
        size: 20,
        color: checked ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }
}

class _MarkdownImageFallback extends StatelessWidget {
  const _MarkdownImageFallback({required this.alt});

  final String alt;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Text(alt),
    ],
  );
}
