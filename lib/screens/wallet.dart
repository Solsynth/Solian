import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/wallet.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isBusy = false;
  SnWallet? _wallet;

  Future<void> _fetchWallet() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/wa/wallets/me');
      _wallet = SnWallet.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWallet();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
          leading: PageBackButton(), title: Text('screenAccountWallet').tr()),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          if (_wallet == null)
            Expanded(
              child: _CreateWalletWidget(
                onCreate: () {
                  _fetchWallet();
                },
              ),
            )
          else
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: double.infinity),
                  Text(
                    NumberFormat.compactCurrency(
                      locale: EasyLocalization.of(context)!
                          .currentLocale
                          .toString(),
                      symbol: '${'walletCurrencyShort'.tr()} ',
                      decimalDigits: 2,
                    ).format(double.parse(_wallet!.balance)),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('walletCurrency'.plural(double.parse(_wallet!.balance))),
                  const Gap(16),
                  Text(
                    NumberFormat.compactCurrency(
                      locale: EasyLocalization.of(context)!
                          .currentLocale
                          .toString(),
                      symbol: '${'walletCurrencyGoldenShort'.tr()} ',
                      decimalDigits: 2,
                    ).format(double.parse(_wallet!.goldenBalance)),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('walletCurrencyGolden'
                      .plural(double.parse(_wallet!.goldenBalance))),
                ],
              ).padding(horizontal: 20, vertical: 24),
            ).padding(horizontal: 8, top: 16, bottom: 4),
          if (_wallet != null)
            Expanded(child: _WalletTransactionList(myself: _wallet!)),
        ],
      ),
    );
  }
}

class _WalletTransactionList extends StatefulWidget {
  final SnWallet myself;

  const _WalletTransactionList({required this.myself});

  @override
  State<_WalletTransactionList> createState() => _WalletTransactionListState();
}

class _WalletTransactionListState extends State<_WalletTransactionList> {
  bool _isBusy = false;
  int? _totalCount;
  final List<SnTransaction> _transactions = List.empty(growable: true);

  Future<void> _fetchTransactions() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/wa/transactions/me',
        queryParameters: {'take': 10, 'offset': _transactions.length},
      );
      _totalCount = resp.data['count'];
      _transactions.addAll(resp.data['data']
              ?.map((e) => SnTransaction.fromJson(e))
              .cast<SnTransaction>() ??
          []);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: InfiniteList(
          itemCount: _transactions.length,
          isLoading: _isBusy,
          hasReachedMax:
              _totalCount != null && _transactions.length >= _totalCount!,
          onFetchData: () {
            _fetchTransactions();
          },
          itemBuilder: (context, idx) {
            final ele = _transactions[idx];
            final isIncoming = ele.payeeId == widget.myself.id;
            return ListTile(
              leading: isIncoming
                  ? const Icon(Symbols.call_received)
                  : const Icon(Symbols.call_made),
              title: Text(
                '${isIncoming ? '+' : '-'}${ele.amount} ${'walletCurrencyShort'.tr()}',
                style: TextStyle(color: isIncoming ? Colors.green : Colors.red),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ele.remark),
                  const Gap(2),
                  Row(
                    children: [
                      Text(
                        'walletTransactionType${ele.currency.capitalize()}'
                            .tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(' · ')
                          .textStyle(Theme.of(context).textTheme.labelSmall!)
                          .padding(right: 4),
                      Text(
                        DateFormat(
                                null,
                                EasyLocalization.of(context)!
                                    .currentLocale
                                    .toString())
                            .format(ele.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            );
          },
        ),
      ),
    );
  }
}

class _CreateWalletWidget extends StatefulWidget {
  final Function()? onCreate;

  const _CreateWalletWidget({required this.onCreate});

  @override
  State<_CreateWalletWidget> createState() => _CreateWalletWidgetState();
}

class _CreateWalletWidgetState extends State<_CreateWalletWidget> {
  bool _isBusy = false;

  Future<void> _createWallet() async {
    final TextEditingController passwordController = TextEditingController();
    final password = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('walletCreate').tr(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('walletCreatePassword').tr(),
            const Gap(8),
            TextField(
              autofocus: true,
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(labelText: 'fieldPassword'.tr()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel').tr()),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(passwordController.text);
            },
            child: Text('next').tr(),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passwordController.dispose();
    });
    if (password == null || password.isEmpty) return;
    if (!mounted) return;

    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/wa/wallets/me', data: {'password': password});
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 28, child: Icon(Symbols.add, size: 28)),
              const Gap(12),
              Text('walletCreate',
                      style: Theme.of(context).textTheme.titleLarge)
                  .tr(),
              Text('walletCreateSubtitle',
                      style: Theme.of(context).textTheme.bodyMedium)
                  .tr(),
              const Gap(8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: _isBusy ? null : () => _createWallet(),
                    child: Text('next').tr()),
              ),
            ],
          ).padding(horizontal: 20, vertical: 24),
        ),
      ),
    );
  }
}
