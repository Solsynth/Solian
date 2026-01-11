import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/embed.dart';
import 'package:island/widgets/content/image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbedLinkWidget extends StatefulWidget {
  final SnScrappedLink link;
  final double? maxWidth;
  final EdgeInsetsGeometry? margin;

  const EmbedLinkWidget({
    super.key,
    required this.link,
    this.maxWidth,
    this.margin,
  });

  @override
  State<EmbedLinkWidget> createState() => _EmbedLinkWidgetState();
}

class _EmbedLinkWidgetState extends State<EmbedLinkWidget> {
  bool? _isSquare;

  @override
  void initState() {
    super.initState();
    _checkIfSquare();
  }

  Future<void> _checkIfSquare() async {
    if (widget.link.imageUrl == null ||
        widget.link.imageUrl!.isEmpty ||
        widget.link.imageUrl == widget.link.faviconUrl) {
      return;
    }

    try {
      final image = CachedNetworkImageProvider(widget.link.imageUrl!);
      final ImageStream stream = image.resolve(ImageConfiguration.empty);
      final completer = Completer<ImageInfo>();
      final listener = ImageStreamListener((
        ImageInfo info,
        bool synchronousCall,
      ) {
        completer.complete(info);
      });
      stream.addListener(listener);
      final info = await completer.future;
      stream.removeListener(listener);

      final aspectRatio = info.image.width / info.image.height;
      if (mounted) {
        setState(() {
          _isSquare = aspectRatio >= 0.9 && aspectRatio <= 1.1;
        });
      }
    } catch (e) {
      // If error, assume not square
      if (mounted) {
        setState(() {
          _isSquare = false;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              // Sqaure open graph image
              if (_isSquare == true) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: UniversalImage(
                      uri: widget.link.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Gap(8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview Image
                    if (widget.link.imageUrl != null &&
                        widget.link.imageUrl!.isNotEmpty &&
                        widget.link.imageUrl != widget.link.faviconUrl &&
                        _isSquare != true)
                      Container(
                        width: double.infinity,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        child: IntrinsicHeight(
                          child: UniversalImage(
                            uri: widget.link.imageUrl!,
                            fit: BoxFit.cover,
                            useFallbackImage: false,
                          ),
                        ),
                      ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Site info row
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

                              // Site name
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

                              // External link icon
                              Icon(
                                Symbols.open_in_new,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),

                          const Gap(8),

                          // Title
                          if (widget.link.title?.isNotEmpty ?? false) ...[
                            Text(
                              widget.link.title!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: _isSquare == true ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(_isSquare == true ? 2 : 4),
                          ],

                          // Description
                          if (widget.link.description != null &&
                              widget.link.description!.isNotEmpty) ...[
                            Text(
                              widget.link.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: _isSquare == true ? 1 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(_isSquare == true ? 4 : 8),
                          ],

                          // URL
                          Text(
                            widget.link.url,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Author and publish date
                          if (widget.link.author != null ||
                              widget.link.publishedDate != null) ...[
                            const Gap(8),
                            Row(
                              children: [
                                if (widget.link.author != null) ...[
                                  Icon(
                                    Symbols.person,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(4),
                                  Text(
                                    widget.link.author!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (widget.link.author != null &&
                                    widget.link.publishedDate != null)
                                  const Gap(16),
                                if (widget.link.publishedDate != null) ...[
                                  Icon(
                                    Symbols.schedule,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(4),
                                  Text(
                                    _formatDate(widget.link.publishedDate!),
                                    style: theme.textTheme.bodySmall?.copyWith(
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
