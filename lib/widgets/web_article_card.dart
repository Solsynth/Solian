import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:island/models/webfeed.dart';

class WebArticleCard extends StatelessWidget {
  final SnWebArticle article;
  final double? maxWidth;

  const WebArticleCard({super.key, required this.article, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            if (await canLaunchUrlString(article.url)) {
              await launchUrlString(
                article.url,
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image or fallback
                article.preview?.imageUrl != null
                    ? CachedNetworkImage(
                      imageUrl: article.preview!.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                    : ColoredBox(
                      color: colorScheme.secondaryContainer,
                      child: const Center(
                        child: Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Title
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          article.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          article.feed?.title ?? 'Unknown Source',
                        ).fontSize(9).opacity(0.75).padding(top: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
