import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

// Post Categories Notifier
final postCategoriesNotifierProvider = StateNotifierProvider.autoDispose<
  PostCategoriesNotifier,
  AsyncValue<CursorPagingData<SnPostCategory>>
>((ref) {
  return PostCategoriesNotifier(ref);
});

class PostCategoriesNotifier
    extends StateNotifier<AsyncValue<CursorPagingData<SnPostCategory>>> {
  final AutoDisposeRef ref;
  static const int _pageSize = 20;
  bool _isLoading = false;

  PostCategoriesNotifier(this.ref) : super(const AsyncValue.loading()) {
    state = const AsyncValue.data(
      CursorPagingData(items: [], hasMore: false, nextCursor: null),
    );
    fetch(cursor: null);
  }

  Future<void> fetch({String? cursor}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (cursor == null) {
      state = const AsyncValue.loading();
    }

    try {
      final client = ref.read(apiClientProvider);
      final offset = cursor == null ? 0 : int.parse(cursor);

      final response = await client.get(
        '/sphere/posts/categories',
        queryParameters: {
          'offset': offset,
          'take': _pageSize,
          'order': 'usage',
        },
      );

      final data = response.data as List;
      final categories =
          data.map((json) => SnPostCategory.fromJson(json)).toList();
      final hasMore = categories.length == _pageSize;
      final nextCursor =
          hasMore ? (offset + categories.length).toString() : null;

      state = AsyncValue.data(
        CursorPagingData(
          items: [...(state.value?.items ?? []), ...categories],
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoading = false;
    }
  }
}

// Post Tags Notifier
final postTagsNotifierProvider = StateNotifierProvider.autoDispose<
  PostTagsNotifier,
  AsyncValue<CursorPagingData<SnPostTag>>
>((ref) {
  return PostTagsNotifier(ref);
});

class PostTagsNotifier
    extends StateNotifier<AsyncValue<CursorPagingData<SnPostTag>>> {
  final AutoDisposeRef ref;
  static const int _pageSize = 20;
  bool _isLoading = false;

  PostTagsNotifier(this.ref) : super(const AsyncValue.loading()) {
    state = const AsyncValue.data(
      CursorPagingData(items: [], hasMore: false, nextCursor: null),
    );
    fetch(cursor: null);
  }

  Future<void> fetch({String? cursor}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (cursor == null) {
      state = const AsyncValue.loading();
    }

    try {
      final client = ref.read(apiClientProvider);
      final offset = cursor == null ? 0 : int.parse(cursor);

      final response = await client.get(
        '/sphere/posts/tags',
        queryParameters: {
          'offset': offset,
          'take': _pageSize,
          'order': 'usage',
        },
      );

      final data = response.data as List;
      final tags = data.map((json) => SnPostTag.fromJson(json)).toList();
      final hasMore = tags.length == _pageSize;
      final nextCursor = hasMore ? (offset + tags.length).toString() : null;

      state = AsyncValue.data(
        CursorPagingData(
          items: [...(state.value?.items ?? []), ...tags],
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoading = false;
    }
  }
}

class PostCategoriesListScreen extends ConsumerWidget {
  const PostCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(postCategoriesNotifierProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesState.when(
        data: (data) {
          if (data.items.isEmpty) {
            return const Center(child: Text('No categories found'));
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.items.length + (data.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= data.items.length) {
                ref
                    .read(postCategoriesNotifierProvider.notifier)
                    .fetch(cursor: data.nextCursor);
                return const Center(child: CircularProgressIndicator());
              }
              final category = data.items[index];
              return ListTile(
                leading: const Icon(Symbols.category),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(postCategoriesNotifierProvider),
            ),
      ),
    );
  }
}

class PostTagsListScreen extends ConsumerWidget {
  const PostTagsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsState = ref.watch(postTagsNotifierProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: tagsState.when(
        data: (data) {
          if (data.items.isEmpty) {
            return const Center(child: Text('No tags found'));
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.items.length + (data.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= data.items.length) {
                ref
                    .read(postTagsNotifierProvider.notifier)
                    .fetch(cursor: data.nextCursor);
                return const Center(child: CircularProgressIndicator());
              }
              final tag = data.items[index];
              return ListTile(
                title: Text(tag.name ?? '#${tag.slug}'),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(postTagsNotifierProvider),
            ),
      ),
    );
  }
}
