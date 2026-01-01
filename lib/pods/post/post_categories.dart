// Post Categories Notifier
import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';

final postCategoriesProvider =
    AsyncNotifierProvider.autoDispose<
      PostCategoriesNotifier,
      PaginationState<SnPostCategory>
    >(PostCategoriesNotifier.new);

class PostCategoriesNotifier
    extends AsyncNotifier<PaginationState<SnPostCategory>>
    with AsyncPaginationController<SnPostCategory> {
  @override
  FutureOr<PaginationState<SnPostCategory>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

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
final postTagsProvider =
    AsyncNotifierProvider.autoDispose<
      PostTagsNotifier,
      PaginationState<SnPostTag>
    >(PostTagsNotifier.new);

class PostTagsNotifier extends AsyncNotifier<PaginationState<SnPostTag>>
    with AsyncPaginationController<SnPostTag> {
  @override
  FutureOr<PaginationState<SnPostTag>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

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
