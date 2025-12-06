import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/services/time.dart';
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
