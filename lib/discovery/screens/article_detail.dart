import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/discovery/screens/article_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/loading_indicator.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return AppScaffold(
      isNoBackground: false,
      body: articleAsync.when(
        data: (article) => AppScaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(article.title),
          ),
          body: _ArticleDetailContent(article: article),
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load article: $error')),
      ),
    );
  }
}

class _ArticleDetailContent extends HookConsumerWidget {
  final SnWebArticle article;

  const _ArticleDetailContent({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final markdownContent = useMemoized(
      () => html2md.convert(article.content ?? ''),
      [article],
    );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Article header card
              Card.filled(
                margin: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (article.preview?.imageUrl != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          article.preview!.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            article.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Metadata chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (article.feed?.title != null)
                                _ArticleMetadataChip(
                                  icon: Symbols.rss_feed,
                                  label: article.feed!.title,
                                ),
                              if (article.author?.isNotEmpty == true)
                                _ArticleMetadataChip(
                                  icon: Symbols.person,
                                  label: article.author!,
                                ),
                              _ArticleMetadataChip(
                                icon: Symbols.schedule,
                                label:
                                    article.publishedAt?.formatSystem() ??
                                    article.createdAt.formatSystem(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Article content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.content != null)
                      ...MarkdownTextContent.buildGenerator(
                        isDark: theme.brightness == Brightness.dark,
                      ).buildWidgets(markdownContent)
                    else if (article.preview?.description != null)
                      Text(
                        article.preview!.description!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    const Gap(24),
                    FilledButton.icon(
                      onPressed: () => launchUrlString(
                        article.url,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Symbols.open_in_new),
                      label: const Text('Read Full Article'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                    ),
                    Gap(MediaQuery.of(context).padding.bottom + 16),
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

class _ArticleMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ArticleMetadataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
