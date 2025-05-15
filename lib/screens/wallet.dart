import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'wallet.g.dart';

@riverpod
Future<SnWallet> walletCurrent(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/wallets');
  return SnWallet.fromJson(resp.data);
}

const Map<String, IconData> kCurrencyIconData = {
  'points': Symbols.toll,
  'golds': Symbols.attach_money,
};

@RoutePage()
class WalletScreen extends HookConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletCurrentProvider);

    String getCurrencyTranslationKey(String currency, {bool isShort = false}) {
      return 'walletCurrency${isShort ? 'Short' : ''}${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}';
    }

    return AppScaffold(
      appBar: AppBar(title: Text('wallet').tr()),
      body: wallet.when(
        data: (data) {
          return Column(
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
                        Text(getCurrencyTranslationKey(pocket.currency)).tr(),
                    subtitle: Text(
                      '${pocket.amount.toStringAsFixed(2)} ${getCurrencyTranslationKey(pocket.currency, isShort: true).tr()}',
                    ),
                  ),
                ),
              ),
            ],
          ).padding(horizontal: 16, vertical: 16);
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
