import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class EmbedLinkWidget extends ConsumerStatefulWidget {
  final SnScrappedLink link;
  final double? maxWidth;
  final EdgeInsetsGeometry? margin;
  final bool isCompact;

  const EmbedLinkWidget({
    super.key,
    required this.link,
    this.maxWidth,
    this.margin,
    this.isCompact = false,
  });

  @override
  ConsumerState<EmbedLinkWidget> createState() => _EmbedLinkWidgetState();
}

class _EmbedLinkWidgetState extends ConsumerState<EmbedLinkWidget> {
  bool? _isSquare;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _checkIfSquare();
  }

  @override
  void dispose() {
    _cancelImageStream();
    super.dispose();
  }

  void _cancelImageStream() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
      _imageStream = null;
      _listener = null;
    }
  }

  Future<void> _checkIfSquare() async {
    if (widget.link.imageUrl == null ||
        widget.link.imageUrl!.isEmpty ||
        widget.link.imageUrl == widget.link.faviconUrl) {
      return;
    }

    _cancelImageStream();

    if (!mounted) return;

    try {
      final image = CachedNetworkImageProvider(widget.link.imageUrl!);
      final ImageStream stream = image.resolve(ImageConfiguration.empty);

      void listenerCallback(ImageInfo info, bool synchronousCall) {
        if (!mounted) return;
        final aspectRatio = info.image.width / info.image.height;
        setState(() {
          _isSquare = aspectRatio >= 0.9 && aspectRatio <= 1.1;
        });
      }

      _listener = ImageStreamListener(listenerCallback);
      _imageStream = stream;
      stream.addListener(_listener!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSquare = false;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.link.url);
    final container = ProviderScope.containerOf(context);
    await openExternalLinkWithContainer(uri, container);
  }

  String _getBaseUrl(String url) {
    final uri = Uri.parse(url);
    final port = uri.port;
    final defaultPort = uri.scheme == 'https' ? 443 : 80;
    final portString = port != defaultPort ? ':$port' : '';
    return '${uri.scheme}://${uri.host}$portString';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isCompact) {
      return _buildCompactLayout(theme, colorScheme);
    }

    return _buildFullLayout(theme, colorScheme);
  }

  Widget _buildCompactLayout(ThemeData theme, ColorScheme colorScheme) {
    final hasImage =
        widget.link.imageUrl != null &&
        widget.link.imageUrl!.isNotEmpty &&
        widget.link.imageUrl != widget.link.faviconUrl;

    return Container(
      width: widget.maxWidth,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _launchUrl,
          child: Row(
            spacing: 4,
            children: [
              if (hasImage) ...[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: UniversalImage(
                    uri: widget.link.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.link.title?.isNotEmpty ?? false)
                        Text(
                          widget.link.title!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Gap(2),
                      Row(
                        children: [
                          if (widget.link.faviconUrl?.isNotEmpty ?? false) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: UniversalImage(
                                uri: widget.link.faviconUrl!.startsWith('//')
                                    ? 'https:${widget.link.faviconUrl!}'
                                    : widget.link.faviconUrl!.startsWith('/')
                                    ? _getBaseUrl(widget.link.url) +
                                          widget.link.faviconUrl!
                                    : widget.link.faviconUrl!,
                                width: 12,
                                height: 12,
                                fit: BoxFit.cover,
                                useFallbackImage: false,
                              ),
                            ),
                            const Gap(4),
                          ],
                          Expanded(
                            child: Text(
                              Uri.parse(widget.link.url).host,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullLayout(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: widget.maxWidth,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _launchUrl,
          child: Row(
            children: [
              if (_isSquare == true) ...[
                SizedBox(
                  width: 100,
                  height: 100,
                  child: UniversalImage(
                    height: 100,
                    uri: widget.link.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.link.imageUrl != null &&
                        widget.link.imageUrl!.isNotEmpty &&
                        widget.link.imageUrl != widget.link.faviconUrl &&
                        _isSquare != true)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final computedHeight =
                              constraints.maxWidth * 9 / 16;
                          final imageHeight =
                              computedHeight > 320 ? 320.0 : computedHeight;
                          return Container(
                            width: constraints.maxWidth,
                            height: imageHeight,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: UniversalImage(
                              uri: widget.link.imageUrl!,
                              fit: BoxFit.cover,
                              useFallbackImage: false,
                            ),
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (widget.link.faviconUrl?.isNotEmpty ??
                                  false) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: UniversalImage(
                                    uri:
                                        widget.link.faviconUrl!.startsWith('//')
                                        ? 'https:${widget.link.faviconUrl!}'
                                        : widget.link.faviconUrl!.startsWith(
                                            '/',
                                          )
                                        ? _getBaseUrl(widget.link.url) +
                                              widget.link.faviconUrl!
                                        : widget.link.faviconUrl!,
                                    width: 16,
                                    height: 16,
                                    fit: BoxFit.cover,
                                    useFallbackImage: false,
                                  ),
                                ),
                                const Gap(8),
                              ] else ...[
                                Icon(
                                  Symbols.link,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const Gap(8),
                              ],
                              Expanded(
                                child: Text(
                                  (widget.link.siteName?.isNotEmpty ?? false)
                                      ? widget.link.siteName!
                                      : Uri.parse(widget.link.url).host,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Symbols.open_in_new,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const Gap(10),
                          if (widget.link.title?.isNotEmpty ?? false) ...[
                            Text(
                              widget.link.title!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              maxLines: _isSquare == true ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(_isSquare == true ? 2 : 6),
                          ],
                          if (widget.link.description != null &&
                              widget.link.description!.isNotEmpty) ...[
                            Text(
                              widget.link.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: _isSquare == true ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(_isSquare == true ? 4 : 8),
                          ],
                          Text(
                            widget.link.url,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.primary.withOpacity(
                                0.7,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.link.author != null ||
                              widget.link.publishedDate != null) ...[
                            const Gap(6),
                            Row(
                              children: [
                                if (widget.link.author != null) ...[
                                  Icon(
                                    Symbols.person,
                                    size: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(4),
                                  Text(
                                    widget.link.author!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (widget.link.author != null &&
                                    widget.link.publishedDate != null)
                                  const Gap(12),
                                if (widget.link.publishedDate != null) ...[
                                  Icon(
                                    Symbols.schedule,
                                    size: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(4),
                                  Text(
                                    _formatDate(widget.link.publishedDate!),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return date.toString();
    }
  }
}
