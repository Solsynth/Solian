import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/realms/realms_models/realm.dart';
import 'package:island/core/network.dart';
import 'package:island/realms/realms_widgets/realm/realm_list_tile.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';

final realmListNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  RealmListNotifier.new,
);

class RealmListNotifier extends AsyncNotifier<PaginationState<SnRealm>>
    with AsyncPaginationController<SnRealm> {
  String? arg;
  RealmListNotifier(this.arg);

  static const int _pageSize = 20;

  @override
  FutureOr<PaginationState<SnRealm>> build() async {
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
  Future<List<SnRealm>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': _pageSize,
      if (arg != null && arg!.isNotEmpty) 'query': arg,
    };

    final response = await client.get(
      '/pass/realms/public',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnRealm.fromJson(json)).toList();
  }
}

class SliverRealmList extends HookConsumerWidget {
  const SliverRealmList({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = realmListNotifierProvider(query);
    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isSliver: true,
      isRefreshable: false,
      spacing: 8,
      itemBuilder: (context, index, realm) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: RealmListTile(realm: realm).padding(horizontal: 8),
        ).center();
      },
    );
  }
}
