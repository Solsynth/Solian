import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/core/services/time.dart';
import 'package:island/route.gr.dart';
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
    context.router.push(ArticleDetailRoute(articleId: article.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  horizontal: 16,
                  vertical: 8,
                ),
                trailing: Icon(
                  Symbols.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  article.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${article.createdAt.formatSystem()} · ${article.createdAt.formatRelative(context)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      article.feed?.title ?? 'Unknown Source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
}

class WebArticleDiscoveryCard extends ConsumerWidget {
  final SnWebArticle article;
  final double? maxWidth;
  final bool showDetails;
  final bool showFeedback;

  const WebArticleDiscoveryCard({
    super.key,
    required this.article,
    this.maxWidth,
    this.showDetails = false,
    this.showFeedback = true,
  });

  void _onTap(BuildContext context) {
    context.router.push(ArticleDetailRoute(articleId: article.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.zero,
        ),
        child: InkWell(
          onTap: () => _onTap(context),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                if (showFeedback)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DiscoveryFeedbackWidget(
                      kind: 'article',
                      referenceId: article.id,
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
