import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'wallet.g.dart';

@riverpod
Future<SnWallet?> walletCurrent(Ref ref) async {
  try {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get('/id/wallets');
    return SnWallet.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

const Map<String, IconData> kCurrencyIconData = {
  'points': Symbols.toll,
  'golds': Symbols.attach_money,
};

@riverpod
class TransactionListNotifier extends _$TransactionListNotifier
    with CursorPagingNotifierMixin<SnTransaction> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnTransaction>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnTransaction>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/id/wallets/transactions',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final transactions =
        data.map((json) => SnTransaction.fromJson(json)).toList();

    final hasMore = offset + transactions.length < total;
    final nextCursor =
        hasMore ? (offset + transactions.length).toString() : null;

    return CursorPagingData(
      items: transactions,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class WalletScreen extends HookConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletCurrentProvider);

    Future<void> createWallet() async {
      final client = ref.read(apiClientProvider);
      try {
        await client.post('/id/wallets');
        ref.invalidate(walletCurrentProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    String getCurrencyTranslationKey(String currency, {bool isShort = false}) {
      return 'walletCurrency${isShort ? 'Short' : ''}${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}';
    }

    return AppScaffold(
      appBar: AppBar(title: Text('wallet').tr()),
      body: wallet.when(
        data: (data) {
          if (data == null) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('walletNotFound').tr().fontSize(16).bold(),
                  Text('walletCreateHint', textAlign: TextAlign.center).tr(),
                  TextButton(
                    onPressed: createWallet,
                    child: Text('walletCreate').tr(),
                  ),
                ],
              ),
            ).center();
          }

          return Column(
            children: [
              Column(
                spacing: 8,
                children: [
                  ...data.pockets.map(
                    (pocket) => Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Icon(
                          kCurrencyIconData[pocket.currency] ??
                              Symbols.universal_currency_alt,
                        ),
                        title:
                            Text(
                              getCurrencyTranslationKey(pocket.currency),
                            ).tr(),
                        subtitle: Text(
                          '${pocket.amount.toStringAsFixed(2)} ${getCurrencyTranslationKey(pocket.currency, isShort: true).tr()}',
                        ),
                      ),
                    ),
                  ),
                ],
              ).padding(horizontal: 16, vertical: 16),
              const Divider(height: 1),
              Expanded(
                child: PagingHelperView(
                  provider: transactionListNotifierProvider,
                  futureRefreshable: transactionListNotifierProvider.future,
                  notifierRefreshable: transactionListNotifierProvider.notifier,
                  contentBuilder:
                      (data, widgetCount, endItemView) => ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widgetCount,
                        itemBuilder: (context, index) {
                          if (index == widgetCount - 1) {
                            return endItemView;
                          }

                          final transaction = data.items[index];
                          final isIncome =
                              transaction.payeeWalletId == wallet.value?.id;

                          return ListTile(
                            key: ValueKey(transaction.id),
                            leading: Icon(
                              isIncome
                                  ? Symbols.arrow_upward
                                  : Symbols.arrow_downward,
                            ),
                            title: Text(transaction.remarks ?? ''),
                            subtitle: Text(
                              DateFormat.yMd().add_Hm().format(
                                transaction.createdAt,
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                              style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            ],
          );
        },
        error:
            (error, stackTrace) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(walletCurrentProvider),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
