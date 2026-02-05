import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/network.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'credits.g.dart';

@riverpod
Future<double> socialCredits(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/pass/accounts/me/credits');
  if (response.statusCode != 200) {
    throw Exception('Failed to load social credits');
  }
  return response.data?.toDouble() ?? 0.0;
}

final socialCreditHistoryNotifierProvider = AsyncNotifierProvider.autoDispose(
  SocialCreditHistoryNotifier.new,
);

class SocialCreditHistoryNotifier
    extends AsyncNotifier<PaginationState<SnSocialCreditRecord>>
    with AsyncPaginationController<SnSocialCreditRecord> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnSocialCreditRecord>> build() async {
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
  Future<List<SnSocialCreditRecord>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/pass/accounts/me/credits/history',
      queryParameters: queryParams,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');

    final records = response.data
        .map((json) => SnSocialCreditRecord.fromJson(json))
        .cast<SnSocialCreditRecord>()
        .toList();

    return records;
  }
}

class SocialCreditsTab extends HookConsumerWidget {
  const SocialCreditsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialCredits = ref.watch(socialCreditsProvider);
    return Column(
      children: [
        const Gap(8),
        Card(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: socialCredits
              .when(
                data: (credits) => Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          credits < 100
                              ? 'socialCreditsLevelPoor'.tr()
                              : credits < 150
                              ? 'socialCreditsLevelNormal'.tr()
                              : credits < 200
                              ? 'socialCreditsLevelGood'.tr()
                              : 'socialCreditsLevelExcellent'.tr(),
                        ).tr().bold().fontSize(20),
                        Text('${credits.toStringAsFixed(2)} pts').fontSize(14),
                        const Gap(8),
                        LinearProgressIndicator(value: credits / 200),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Symbols.info),
                        tooltip: 'socialCreditsDescription'.tr(),
                      ),
                    ),
                  ],
                ),
                error: (_, _) => Text('Error loading credits'),
                loading: () => const LinearProgressIndicator(),
              )
              .padding(horizontal: 20, vertical: 16),
        ),
        Expanded(
          child: PaginationList(
            padding: EdgeInsets.zero,
            provider: socialCreditHistoryNotifierProvider,
            notifier: socialCreditHistoryNotifierProvider.notifier,
            itemBuilder: (context, idx, record) {
              final isExpired =
                  record.expiredAt != null &&
                  record.expiredAt!.isBefore(DateTime.now());
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  record.reason,
                  style: isExpired
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        )
                      : null,
                ),
                subtitle: Row(
                  spacing: 4,
                  children: [
                    Text(record.createdAt.formatSystem()),
                    Text('to'),
                    if (record.expiredAt != null)
                      Text(record.expiredAt!.formatSystem()),
                  ],
                ),
                trailing: Text(
                  record.delta > 0 ? '+${record.delta}' : '${record.delta}',
                  style: TextStyle(
                    color: record.delta > 0 ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
