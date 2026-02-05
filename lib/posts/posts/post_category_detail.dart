import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/post/post_list.dart';
import 'package:island/posts/posts_models/post_category.dart';
import 'package:island/posts/posts_models/post_tag.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/posts_widgets/post/post_list.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_category_detail.g.dart';

@riverpod
Future<SnPostCategory> postCategory(Ref ref, String slug) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/posts/categories/$slug');
  return SnPostCategory.fromJson(resp.data);
}

@riverpod
Future<SnPostTag> postTag(Ref ref, String slug) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/posts/tags/$slug');
  return SnPostTag.fromJson(resp.data);
}

@riverpod
Future<SnCategorySubscription?> postCategorySubscription(
  Ref ref,
  String slug,
  bool isCategory,
) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get(
      '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/subscription',
    );
    if (resp.data == 200) return SnCategorySubscription.fromJson(resp.data);
    return null;
  } catch (_) {
    return null;
  }
}

Future<void> _subscribeToCategoryOrTag(
  WidgetRef ref, {
  required String slug,
  required bool isCategory,
}) async {
  final apiClient = ref.read(apiClientProvider);
  await apiClient.post(
    '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/subscribe',
  );
  // Invalidate the subscription status to refresh it
  ref.invalidate(postCategorySubscriptionProvider(slug, isCategory));
}

Future<void> _unsubscribeFromCategoryOrTag(
  WidgetRef ref, {
  required String slug,
  required bool isCategory,
}) async {
  final apiClient = ref.read(apiClientProvider);
  await apiClient.post(
    '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/unsubscribe',
  );
  // Invalidate the subscription status to refresh it
  ref.invalidate(postCategorySubscriptionProvider(slug, isCategory));
}

class PostCategoryDetailScreen extends HookConsumerWidget {
  final String slug;
  final bool isCategory;
  const PostCategoryDetailScreen({
    super.key,
    required this.slug,
    required this.isCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCategory = isCategory
        ? ref.watch(postCategoryProvider(slug))
        : null;
    final postTag = isCategory ? null : ref.watch(postTagProvider(slug));
    final subscriptionStatus = ref.watch(
      postCategorySubscriptionProvider(slug, isCategory),
    );

    final postFilterTitle = isCategory
        ? postCategory?.value?.categoryDisplayTitle ?? 'loading'
        : postTag?.value?.name ?? postTag?.value?.slug ?? 'loading';

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text(postFilterTitle).tr()),
      body: Expanded(
        child: CustomScrollView(
          slivers: [
            if (isCategory)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      margin: EdgeInsets.only(top: 8),
                      child: postCategory!.when(
                        data: (category) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              category.categoryDisplayTitle,
                            ).bold().fontSize(15),
                            Text('A category'),
                            const Gap(8),
                            subscriptionStatus.when(
                              data: (subscription) => subscription != null
                                  ? FilledButton.icon(
                                      onPressed: () async {
                                        await _unsubscribeFromCategoryOrTag(
                                          ref,
                                          slug: slug,
                                          isCategory: isCategory,
                                        );
                                      },
                                      icon: const Icon(Symbols.remove_circle),
                                      label: Text('unsubscribe'.tr()),
                                    )
                                  : FilledButton.icon(
                                      onPressed: () async {
                                        await _subscribeToCategoryOrTag(
                                          ref,
                                          slug: slug,
                                          isCategory: isCategory,
                                        );
                                      },
                                      icon: const Icon(Symbols.add_circle),
                                      label: Text('subscribe'.tr()),
                                    ),
                              error: (error, _) =>
                                  Text('Error loading subscription status'),
                              loading: () =>
                                  CircularProgressIndicator().center(),
                            ),
                          ],
                        ).padding(horizontal: 24, vertical: 16),
                        error: (error, _) => ResponseErrorWidget(
                          error: error,
                          onRetry: () =>
                              ref.invalidate(postCategoryProvider(slug)),
                        ),
                        loading: () => ResponseLoadingWidget(),
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      margin: EdgeInsets.only(top: 8),
                      child: postTag!.when(
                        data: (tag) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tag.name ?? '#${tag.slug}',
                            ).bold().fontSize(15),
                            Text('A tag'),
                            const Gap(8),
                            subscriptionStatus.when(
                              data: (subscription) => subscription != null
                                  ? FilledButton.icon(
                                      onPressed: () async {
                                        await _unsubscribeFromCategoryOrTag(
                                          ref,
                                          slug: slug,
                                          isCategory: isCategory,
                                        );
                                      },
                                      icon: const Icon(Symbols.remove_circle),
                                      label: Text('unsubscribe'.tr()),
                                    )
                                  : FilledButton.icon(
                                      onPressed: () async {
                                        await _subscribeToCategoryOrTag(
                                          ref,
                                          slug: slug,
                                          isCategory: isCategory,
                                        );
                                      },
                                      icon: const Icon(Symbols.add_circle),
                                      label: Text('subscribe'.tr()),
                                    ),
                              error: (error, _) =>
                                  Text('Error loading subscription status'),
                              loading: () =>
                                  CircularProgressIndicator().center(),
                            ),
                          ],
                        ).padding(horizontal: 24, vertical: 16),
                        error: (error, _) => ResponseErrorWidget(
                          error: error,
                          onRetry: () => ref.invalidate(postTagProvider(slug)),
                        ),
                        loading: () => ResponseLoadingWidget(),
                      ),
                    ),
                  ).padding(horizontal: 8),
                ),
              ),
            const SliverGap(4),
            SliverPostList(
              query: PostListQuery(
                categories: isCategory ? [slug] : null,
                tags: isCategory ? null : [slug],
              ),
              maxWidth: 540 + 16,
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
