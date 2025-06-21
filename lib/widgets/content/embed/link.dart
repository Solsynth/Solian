import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/embed.dart';
import 'package:island/widgets/content/image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbedLinkWidget extends StatelessWidget {
  final SnEmbedLink link;
  final double? maxWidth;
  final EdgeInsetsGeometry? margin;

  const EmbedLinkWidget({
    super.key,
    required this.link,
    this.maxWidth,
    this.margin,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: maxWidth,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _launchUrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Image
              if (link.imageUrl.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: UniversalImage(uri: link.imageUrl, fit: BoxFit.cover),
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
                        // Favicon
                        if (link.faviconUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: UniversalImage(
                              uri: link.faviconUrl,
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
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
                            link.siteName.isNotEmpty
                                ? link.siteName
                                : Uri.parse(link.url).host,
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
                    if (link.title.isNotEmpty) ...[
                      Text(
                        link.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                    ],

                    // Description
                    if (link.description.isNotEmpty) ...[
                      Text(
                        link.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(8),
                    ],

                    // URL
                    Text(
                      link.url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Author and publish date
                    if (link.author != null || link.publishedDate != null) ...[
                      const Gap(8),
                      Row(
                        children: [
                          if (link.author != null) ...[
                            Icon(
                              Symbols.person,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const Gap(4),
                            Text(
                              link.author.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (link.author != null && link.publishedDate != null)
                            const Gap(16),
                          if (link.publishedDate != null) ...[
                            Icon(
                              Symbols.schedule,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const Gap(4),
                            Text(
                              _formatDate(link.publishedDate),
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
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return date.toString();
      }

      return DateFormat.yMMMd().format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }
}
