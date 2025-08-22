import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'credits.g.dart';

@riverpod
Future<double> socialCredits(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/id/accounts/me/credits');
  if (response.statusCode != 200) {
    throw Exception('Failed to load social credits');
  }
  return response.data?.toDouble() ?? 0.0;
}

@riverpod
class SocialCreditHistoryNotifier extends _$SocialCreditHistoryNotifier
    with CursorPagingNotifierMixin<SnSocialCreditRecord> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnSocialCreditRecord>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnSocialCreditRecord>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/id/accounts/me/credits/history',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final records =
        data.map((json) => SnSocialCreditRecord.fromJson(json)).toList();

    final hasMore = offset + records.length < total;
    final nextCursor = hasMore ? (offset + records.length).toString() : null;

    return CursorPagingData(
      items: records,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class SocialCreditsScreen extends HookConsumerWidget {
  const SocialCreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialCredits = ref.watch(socialCreditsProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('socialCredits').tr()),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: socialCredits
                .when(
                  data:
                      (credits) => Stack(
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
                              Text(
                                '${credits.toStringAsFixed(2)} pts',
                              ).fontSize(14),
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
            child: PagingHelperView(
              provider: socialCreditHistoryNotifierProvider,
              futureRefreshable: socialCreditHistoryNotifierProvider.future,
              notifierRefreshable: socialCreditHistoryNotifierProvider.notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }
                      final record = data.items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        title: Text(record.reason),
                        subtitle: Text(
                          DateFormat.yMMMd().format(record.createdAt),
                        ),
                        trailing: Text(
                          record.delta > 0
                              ? '+${record.delta}'
                              : '${record.delta}',
                          style: TextStyle(
                            color: record.delta > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
