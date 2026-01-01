import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/wallet.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/payment/payment_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

/// Bottom sheet for selecting or creating a fund. Returns SnWalletFund via Navigator.pop.
class ComposeFundSheet extends HookConsumerWidget {
  const ComposeFundSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPushing = useState(false);
    final errorText = useState<String?>(null);

    final fundsData = ref.watch(walletFundsProvider);

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'fund'.tr(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              tabs: [
                Tab(text: 'fundsRecent'.tr()),
                Tab(text: 'fundCreateNew'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Link/Select existing fund list
                  fundsData.when(
                    data: (funds) => funds.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.money_bag,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const Gap(16),
                                Text(
                                  'noFundsCreated'.tr(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: funds.items.length,
                            itemBuilder: (context, index) {
                              final fund = funds.items[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(fund),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Symbols.money_bag,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fill: 1,
                                            ),
                                            const Gap(8),
                                            Expanded(
                                              child: Text(
                                                '${fund.totalAmount.toStringAsFixed(2)} ${fund.currency}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getFundStatusColor(
                                                  context,
                                                  fund.status,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getFundStatusText(fund.status),
                                                style: TextStyle(
                                                  color: _getFundStatusColor(
                                                    context,
                                                    fund.status,
                                                  ),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (fund.message != null &&
                                            fund.message!.isNotEmpty) ...[
                                          const Gap(8),
                                          Text(
                                            fund.message!,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                        const Gap(8),
                                        Text(
                                          '${'recipients'.tr()}: ${fund.recipients.where((r) => r.isReceived).length}/${fund.recipients.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),

                  // Create new fund and return it
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'fundCreateNewHint',
                        ).tr().fontSize(13).opacity(0.85).padding(bottom: 8),
                        if (errorText.value != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 4,
                            ),
                            child: Text(
                              errorText.value!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        const Gap(16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            icon: isPushing.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Symbols.add_circle),
                            label: Text('create'.tr()),
                            onPressed: isPushing.value
                                ? null
                                : () async {
                                    errorText.value = null;

                                    isPushing.value = true;
                                    // Show modal bottom sheet with fund creation form and await result
                                    final result =
                                        await showModalBottomSheet<
                                          Map<String, dynamic>
                                        >(
                                          context: context,
                                          useRootNavigator: true,
                                          isScrollControlled: true,
                                          builder: (context) =>
                                              const CreateFundSheet(),
                                        );

                                    if (result == null) {
                                      isPushing.value = false;
                                      return;
                                    }

                                    try {
                                      if (!context.mounted) return;

                                      final client = ref.read(
                                        apiClientProvider,
                                      );
                                      showLoadingModal(context);

                                      final resp = await client.post(
                                        '/pass/wallets/funds',
                                        data: result,
                                        options: Options(
                                          headers: {'X-Noop': true},
                                        ),
                                      );

                                      final fund = SnWalletFund.fromJson(
                                        resp.data,
                                      );

                                      if (fund.status == 0) {
                                        // Return the fund that was just created (but not yet paid)
                                        if (context.mounted) {
                                          hideLoadingModal(context);
                                          Navigator.of(context).pop(fund);
                                        }
                                        return;
                                      }

                                      final orderResp = await client.post(
                                        '/pass/wallets/funds/${fund.id}/order',
                                      );
                                      final order = SnWalletOrder.fromJson(
                                        orderResp.data,
                                      );

                                      if (context.mounted) {
                                        hideLoadingModal(context);
                                      }

                                      // Show payment overlay to complete the payment
                                      if (!context.mounted) return;
                                      final paidOrder =
                                          await PaymentOverlay.show(
                                            context: context,
                                            order: order,
                                            enableBiometric: true,
                                          );

                                      if (paidOrder != null &&
                                          context.mounted) {
                                        showLoadingModal(context);

                                        // Wait for server to handle order
                                        await Future.delayed(
                                          const Duration(seconds: 1),
                                        );
                                        ref.invalidate(walletFundsProvider);

                                        // Return the created fund
                                        final updatedResp = await client.get(
                                          '/pass/wallets/funds/${fund.id}',
                                        );
                                        final updatedFund =
                                            SnWalletFund.fromJson(
                                              updatedResp.data,
                                            );

                                        if (context.mounted) {
                                          hideLoadingModal(context);
                                          Navigator.of(
                                            context,
                                          ).pop(updatedFund);
                                        }
                                      } else {
                                        isPushing.value = false;
                                      }
                                    } catch (err) {
                                      if (context.mounted) {
                                        hideLoadingModal(context);
                                      }
                                      errorText.value = err.toString();
                                      isPushing.value = false;
                                    }
                                  },
                          ),
                        ),
                      ],
                    ).padding(horizontal: 24, vertical: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFundStatusText(int status) {
    switch (status) {
      case 0:
        return 'fundStatusCreated'.tr();
      case 1:
        return 'fundStatusPartial'.tr();
      case 2:
        return 'fundStatusCompleted'.tr();
      case 3:
        return 'fundStatusExpired'.tr();
      default:
        return 'fundStatusUnknown'.tr();
    }
  }

  Color _getFundStatusColor(BuildContext context, int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
