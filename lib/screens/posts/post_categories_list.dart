import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';

// Post Categories Notifier
final postCategoriesNotifierProvider = AsyncNotifierProvider.autoDispose<
  PostCategoriesNotifier,
  List<SnPostCategory>
>(PostCategoriesNotifier.new);

class PostCategoriesNotifier
    extends AutoDisposeAsyncNotifier<List<SnPostCategory>>
    with AutoDisposeAsyncPaginationController<SnPostCategory> {
  @override
  Future<List<SnPostCategory>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/categories',
      queryParameters: {'offset': fetchedCount, 'take': 20, 'order': 'usage'},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final data = response.data as List;
    return data.map((json) => SnPostCategory.fromJson(json)).toList();
  }
}

// Post Tags Notifier
final postTagsNotifierProvider =
    AsyncNotifierProvider.autoDispose<PostTagsNotifier, List<SnPostTag>>(
      PostTagsNotifier.new,
    );

class PostTagsNotifier extends AutoDisposeAsyncNotifier<List<SnPostTag>>
    with AutoDisposeAsyncPaginationController<SnPostTag> {
  @override
  Future<List<SnPostTag>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/tags',
      queryParameters: {'offset': fetchedCount, 'take': 20, 'order': 'usage'},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final data = response.data as List;
    return data.map((json) => SnPostTag.fromJson(json)).toList();
  }
}

class PostCategoriesListScreen extends ConsumerWidget {
  const PostCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: const Text('categories').tr()),
      body: PaginationList(
        provider: postCategoriesNotifierProvider,
        notifier: postCategoriesNotifierProvider.notifier,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index, category) {
          return ListTile(
            leading: const Icon(Symbols.category),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            trailing: const Icon(Symbols.chevron_right),
            title: Text(category.categoryDisplayTitle),
            subtitle: Text('postCount'.plural(category.usage)),
            onTap: () {
              context.pushNamed(
                'postCategoryDetail',
                pathParameters: {'slug': category.slug},
              );
            },
          );
        },
      ),
    );
  }
}

class PostTagsListScreen extends ConsumerWidget {
  const PostTagsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: const Text('tags').tr()),
      body: PaginationList(
        provider: postTagsNotifierProvider,
        notifier: postTagsNotifierProvider.notifier,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index, tag) {
          return ListTile(
            title: Text(tag.name ?? '#${tag.slug}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.label),
            trailing: const Icon(Symbols.chevron_right),
            subtitle: Text('postCount'.plural(tag.usage)),
            onTap: () {
              context.pushNamed(
                'postTagDetail',
                pathParameters: {'slug': tag.slug},
              );
            },
          );
        },
      ),
    );
  }
}
