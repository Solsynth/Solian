import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'realm_list.g.dart';

@riverpod
class RealmListNotifier extends _$RealmListNotifier
    with CursorPagingNotifierMixin<SnRealm> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnRealm>> build(String? query) {
    return fetch(cursor: null, query: query);
  }

  @override
  Future<CursorPagingData<SnRealm>> fetch({
    required String? cursor,
    String? query,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {
      'offset': offset,
      'take': _pageSize,
      if (query != null && query.isNotEmpty) 'query': query,
    };

    final response = await client.get(
      '/sphere/discovery/realms',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final realms = data.map((json) => SnRealm.fromJson(json)).toList();

    final hasMore = offset + realms.length < total;
    final nextCursor = hasMore ? (offset + realms.length).toString() : null;

    return CursorPagingData(
      items: realms,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class SliverRealmList extends HookConsumerWidget {
  const SliverRealmList({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagingHelperSliverView(
      provider: realmListNotifierProvider(query),
      futureRefreshable: realmListNotifierProvider(query).future,
      notifierRefreshable: realmListNotifierProvider(query).notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => SliverList.separated(
            itemCount: widgetCount,
            itemBuilder: (context, index) {
              if (index == widgetCount - 1) {
                return endItemView;
              }

              final realm = data.items[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: RealmCard(realm: realm),
              );
            },
            separatorBuilder: (_, _) => const Gap(8),
          ),
    );
  }
}
