// Post Categories Notifier
import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final postCategoriesProvider =
    AsyncNotifierProvider.autoDispose<
      PostCategoriesNotifier,
      PaginationState<SnPostCategory>
    >(PostCategoriesNotifier.new);

final popularPostCategoriesProvider =
    AsyncNotifierProvider.autoDispose<
      PopularPostCategoriesNotifier,
      PaginationState<SnPostCategory>
    >(PopularPostCategoriesNotifier.new);

class PostCategoriesNotifier
    extends AsyncNotifier<PaginationState<SnPostCategory>>
    with AsyncPaginationController<SnPostCategory> {
  String get order => 'usage';
  int get pageSize => 20;

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
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/posts/categories',
      queryParameters: {
        'offset': fetchedCount,
        'take': pageSize,
        'order': order,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final data = response.data as List;
    return data.map((json) => SnPostCategory.fromJson(json)).toList();
  }
}

class PopularPostCategoriesNotifier extends PostCategoriesNotifier {
  @override
  String get order => 'popularity';

  @override
  int get pageSize => 5;
}

// Post Tags Notifier
final postTagsProvider =
    AsyncNotifierProvider.autoDispose<
      PostTagsNotifier,
      PaginationState<SnPostTag>
    >(PostTagsNotifier.new);

final popularPostTagsProvider =
    AsyncNotifierProvider.autoDispose<
      PopularPostTagsNotifier,
      PaginationState<SnPostTag>
    >(PopularPostTagsNotifier.new);

class PostTagsNotifier extends AsyncNotifier<PaginationState<SnPostTag>>
    with AsyncPaginationController<SnPostTag> {
  String get order => 'usage';
  int get pageSize => 20;

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
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/posts/tags',
      queryParameters: {
        'offset': fetchedCount,
        'take': pageSize,
        'order': order,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final data = response.data as List;
    return data.map((json) => SnPostTag.fromJson(json)).toList();
  }
}

class PopularPostTagsNotifier extends PostTagsNotifier {
  @override
  String get order => 'popularity';

  @override
  int get pageSize => 5;
}
