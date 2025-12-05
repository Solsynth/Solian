import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:styled_widget/styled_widget.dart';

final realmListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<RealmListNotifier, List<SnRealm>, String?>(RealmListNotifier.new);

class RealmListNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<SnRealm>, String?>
    with FamilyAsyncPaginationController<SnRealm, String?> {
  static const int _pageSize = 20;

  @override
  Future<List<SnRealm>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': _pageSize,
      if (arg != null && arg!.isNotEmpty) 'query': arg,
    };

    final response = await client.get(
      '/sphere/discovery/realms',
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
      itemBuilder: (context, index, realm) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child:
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: RealmCard(realm: realm),
                  ).center(),
            ),
            if (index <
                (ref.read(provider).valueOrNull?.length ?? 0) -
                    1) // Add gap except for last item? Actually PaginationList handles loading indicator which might look like last item.
              // Wait, ref.read(provider).valueOrNull?.length might change.
              // Simpler to just add bottom padding to all, or Gap.
              const Gap(8),
          ],
        );
      },
    );
  }
}
