import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:island/discovery/discovery/article_pod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/loading_indicator.dart';
import 'package:html2md/html2md.dart' as html2md;

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
              if (article.preview?.imageUrl != null)
                Image.network(
                  article.preview!.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (article.feed?.title != null)
                      Text(
                        article.feed!.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const Divider(height: 32),
                    if (article.content != null)
                      ...MarkdownTextContent.buildGenerator(
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ).buildWidgets(markdownContent)
                    else if (article.preview?.description != null)
                      Text(article.preview!.description!),
                    const Gap(24),
                    FilledButton(
                      onPressed: () => launchUrlString(
                        article.url,
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('Read Full Article'),
                    ),
                    Gap(MediaQuery.of(context).padding.bottom),
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
