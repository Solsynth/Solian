import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:island/widgets/response.dart';
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
    final postCategory =
        isCategory ? ref.watch(postCategoryProvider(slug)) : null;
    final postTag = isCategory ? null : ref.watch(postTagProvider(slug));

    final postFilterTitle =
        isCategory
            ? postCategory?.value?.categoryDisplayTitle ?? 'loading'
            : postTag?.value?.name ?? postTag?.value?.slug ?? 'loading';

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text(postFilterTitle).tr()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCategory)
            postCategory!.when(
              data:
                  (category) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.categoryDisplayTitle).bold().fontSize(15),
                      Text('A category'),
                    ],
                  ).padding(horizontal: 24, vertical: 16),
              error:
                  (error, _) => ResponseErrorWidget(
                    error: error,
                    onRetry: () => ref.invalidate(postCategoryProvider(slug)),
                  ),
              loading: () => ResponseLoadingWidget(),
            )
          else
            postTag!.when(
              data:
                  (tag) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tag.name ?? '#${tag.slug}').bold().fontSize(15),
                      Text('A tag'),
                    ],
                  ).padding(horizontal: 24, vertical: 16),
              error:
                  (error, _) => ResponseErrorWidget(
                    error: error,
                    onRetry: () => ref.invalidate(postTagProvider(slug)),
                  ),
              loading: () => ResponseLoadingWidget(),
            ),
          const Divider(height: 1),
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverGap(4),
                SliverPostList(
                  categories: isCategory ? [slug] : null,
                  tags: isCategory ? null : [slug],
                ),
                SliverGap(MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
