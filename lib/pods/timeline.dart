import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';

final activityListProvider =
    AsyncNotifierProvider<ActivityListNotifier, List<SnTimelineEvent>>(
      ActivityListNotifier.new,
    );

class ActivityListNotifier extends AsyncNotifier<List<SnTimelineEvent>>
    with
        AsyncPaginationController<SnTimelineEvent>,
        AsyncPaginationFilter<String?, SnTimelineEvent> {
  static const int pageSize = 20;

  @override
  String? currentFilter;

  @override
  Future<List<SnTimelineEvent>> fetch() async {
    final client = ref.read(apiClientProvider);

    final cursor = state.value?.lastOrNull?.createdAt.toUtc().toIso8601String();

    final queryParameters = {
      if (cursor != null) 'cursor': cursor,
      'take': pageSize,
      if (currentFilter != null) 'filter': currentFilter,
      if (kDebugMode)
        'debugInclude': 'realms,publishers,articles,shuffledPosts',
    };

    final response = await client.get(
      '/sphere/timeline',
      queryParameters: queryParameters,
    );

    final List<SnTimelineEvent> items =
        (response.data as List)
            .map((e) => SnTimelineEvent.fromJson(e as Map<String, dynamic>))
            .toList();

    final hasMore = (items.firstOrNull?.type ?? 'empty') != 'empty';

    totalCount =
        (state.value?.length ?? 0) + items.length + (hasMore ? pageSize : 0);

    return items;
  }

  void updateOne(int index, SnTimelineEvent activity) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = [...currentState];
    updatedItems[index] = activity;

    state = AsyncData(updatedItems);
  }
}
