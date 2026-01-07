import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';

final activityListProvider = AsyncNotifierProvider.autoDispose(
  ActivityListNotifier.new,
);

class ActivityListNotifier
    extends AsyncNotifier<PaginationState<SnTimelineEvent>>
    with
        AsyncPaginationController<SnTimelineEvent>,
        AsyncPaginationFilter<String?, SnTimelineEvent> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnTimelineEvent>> build() async {
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
  String? currentFilter;

  @override
  Future<List<SnTimelineEvent>> fetch() async {
    final client = ref.read(apiClientProvider);
    final settings = ref.read(appSettingsProvider);

    final queryParameters = {
      if (cursor != null) 'cursor': cursor,
      'take': pageSize,
      if (currentFilter != null) 'filter': currentFilter,
      'showFediverse': settings.showFediverseContent,
    };

    final response = await client.get(
      '/sphere/timeline',
      queryParameters: queryParameters,
    );

    final List<SnTimelineEvent> items = (response.data as List)
        .map((e) => SnTimelineEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    hasMore = (items.firstOrNull?.type ?? 'empty') != 'empty';
    // Find the latest createdAt timestamp from all items for cursor-based pagination
    // This ensures we get items created before this timestamp, regardless of sort order
    if (items.isNotEmpty) {
      final newestCreatedAt = items
          .where((e) => e.type.startsWith('posts.'))
          .map((e) => e.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      if (cursor != null) {
        final prevCursor = DateTime.tryParse(cursor!);
        if (prevCursor != null && prevCursor.isAfter(newestCreatedAt)) {
          cursor = newestCreatedAt.toUtc().toIso8601String();
        }
      } else {
        cursor = newestCreatedAt.toUtc().toIso8601String();
      }
    }

    return items;
  }

  void updateOne(int index, SnTimelineEvent activity) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = [...currentState.items];
    updatedItems[index] = activity;

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }
}
