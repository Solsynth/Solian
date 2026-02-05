import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';
import 'package:island/core/services/time.dart';
import 'package:material_symbols_icons/symbols.dart';

class WebArticleCard extends StatelessWidget {
  final SnWebArticle article;
  final double? maxWidth;
  final bool showDetails;

  const WebArticleCard({
    super.key,
    required this.article,
    this.maxWidth,
    this.showDetails = false,
  });

  void _onTap(BuildContext context) {
    context.pushNamed('articleDetail', pathParameters: {'id': article.id});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context),
          child: Column(
            children: [
              if (article.preview?.imageUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: article.preview!.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ListTile(
                isThreeLine: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                trailing: const Icon(Symbols.chevron_right),
                title: Text(article.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${article.createdAt.formatSystem()} · ${article.createdAt.formatRelative(context)}',
                    ),
                    Text(
                      article.feed?.title ?? 'Unknown Source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

class WebArticleDiscoveryCard extends StatelessWidget {
  final SnWebArticle article;
  final double? maxWidth;
  final bool showDetails;

  const WebArticleDiscoveryCard({
    super.key,
    required this.article,
    this.maxWidth,
    this.showDetails = false,
  });

  void _onTap(BuildContext context) {
    context.pushNamed('articleDetail', pathParameters: {'id': article.id});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context),
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
                        if (showDetails)
                          const SizedBox(height: 8)
                        else
                          Spacer(),
                        Text(
                          article.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: showDetails ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showDetails &&
                            article.author?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            article.author!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (showDetails) const Spacer(),
                        if (showDetails && article.publishedAt != null) ...[
                          Text(
                            '${article.publishedAt!.formatSystem()} · ${article.publishedAt!.formatRelative(context)}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          article.feed?.title ?? 'Unknown Source',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
