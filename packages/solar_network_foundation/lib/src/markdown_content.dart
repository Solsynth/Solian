import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

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
    final config = theme.brightness == Brightness.dark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    return MarkdownBlock(
      data: content,
      selectable: selectable,
      config: config.copy(
        configs: [
          PConfig(textStyle: textStyle ?? theme.textTheme.bodyMedium!),
          PreConfig(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          TableConfig(
            wrapper: (child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
          LinkConfig(
            style: TextStyle(color: scheme.primary),
            onTap: (href) async {
              final uri = Uri.tryParse(href);
              if (uri != null) await onLinkTap?.call(uri);
            },
          ),
          ImgConfig(
            builder: (url, attributes) {
              final width = double.tryParse(attributes['width'] ?? '');
              final height = double.tryParse(attributes['height'] ?? '');
              final isNetworkImage =
                  url.startsWith('https://') || url.startsWith('http://');
              if (!isNetworkImage) {
                return _MarkdownImageFallback(
                  alt: attributes['alt'] ?? 'Image unavailable',
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: Image.network(
                    url,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _MarkdownImageFallback(
                      alt: attributes['alt'] ?? 'Image unavailable',
                    ),
                  ),
                ),
              );
            },
          ),
          CheckBoxConfig(
            builder: (checked) => Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: checked ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ],
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
