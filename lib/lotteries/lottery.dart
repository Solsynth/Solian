import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/wallet/wallet.dart';
import 'package:island/wallet/wallet_models/wallet.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/core/widgets/payment/payment_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'lottery.g.dart';

@riverpod
Future<List<SnLotteryTicket>> lotteryTickets(
  Ref ref, {
  int offset = 0,
  int take = 20,
}) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/wallet/lotteries?offset=$offset&take=$take');
  return (resp.data as List).map((e) => SnLotteryTicket.fromJson(e)).toList();
}

@riverpod
Future<List<SnLotteryRecord>> lotteryRecords(
  Ref ref, {
  int offset = 0,
  int take = 20,
}) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/wallet/lotteries/records?offset=$offset&take=$take',
  );
  return (resp.data as List).map((e) => SnLotteryRecord.fromJson(e)).toList();
}

class LotteryTab extends StatelessWidget {
  const LotteryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'myTickets'.tr()),
              Tab(text: 'drawHistory'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [LotteryTicketsList(), LotteryRecordsList()],
            ),
          ),
        ],
      ),
    );
  }
}

class LotteryTicketsList extends HookConsumerWidget {
  const LotteryTicketsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(lotteryTicketsProvider());

    return tickets.when(
      data: (ticketsList) {
        if (ticketsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.casino,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const Gap(16),
                Text(
                  'noLotteryTickets'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(8),
                Text(
                  'buyYourFirstTicket'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () => _showLotteryPurchaseSheet(context, ref),
                  icon: const Icon(Symbols.add),
                  label: Text('buyTicket'.tr()),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ticketsList.length,
                itemBuilder: (context, index) {
                  final ticket = ticketsList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.confirmation_number,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(ticket.createdAt.formatSystem()),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getLotteryStatusColor(
                                    context,
                                    ticket.drawStatus,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getLotteryStatusText(ticket.drawStatus),
                                  style: TextStyle(
                                    color: _getLotteryStatusColor(
                                      context,
                                      ticket.drawStatus,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          _buildTicketNumbersDisplay(context, ticket),
                          const Gap(8),
                          Row(
                            spacing: 6,
                            children: [
                              const Icon(Symbols.asterisk, size: 18),
                              Text('multiplier').tr().fontSize(13),
                              Text(
                                '·',
                              ).fontWeight(FontWeight.w900).fontSize(13),
                              Text(
                                '${ticket.multiplier}x',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ).fontSize(13),
                            ],
                          ).opacity(0.75),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => _showLotteryPurchaseSheet(context, ref),
                icon: const Icon(Symbols.add),
                label: Text('buyTicket'.tr()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _showLotteryPurchaseSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const LotteryPurchaseSheet(),
    );

    if (result != null && context.mounted) {
      await _handleLotteryPurchase(context, ref, result);
    }
  }

  Future<void> _handleLotteryPurchase(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> purchaseData,
  ) async {
    final client = ref.read(apiClientProvider);
    try {
      showLoadingModal(context);

      // The lottery API creates the order for us
      final orderResponse = await client.post(
        '/wallet/lotteries',
        data: purchaseData,
      );

      if (context.mounted) hideLoadingModal(context);

      final order = SnWalletOrder.fromJson(orderResponse.data);

      // Show payment overlay
      if (context.mounted) {
        final completedOrder = await PaymentOverlay.show(
          context: context,
          order: order,
        );

        if (completedOrder != null) {
          // Payment successful, refresh data
          ref.invalidate(lotteryTicketsProvider);
          ref.invalidate(walletCurrentProvider);
          if (context.mounted) {
            showSnackBar('ticketPurchasedSuccessfully'.tr());
          }
        }
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  String _getLotteryStatusText(int status) {
    switch (status) {
      case 0:
        return 'pending'.tr();
      case 1:
        return 'drawn'.tr();
      case 2:
        return 'won'.tr();
      case 3:
        return 'lost'.tr();
      default:
        return 'unknown'.tr();
    }
  }

  Color _getLotteryStatusColor(BuildContext context, int status) {
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

  Widget _buildTicketNumbersDisplay(
    BuildContext context,
    SnLotteryTicket ticket,
  ) {
    final numbers = <Widget>[];

    // Check if any numbers matched
    bool hasAnyMatch =
        ticket.matchedRegionOneNumbers != null &&
        ticket.matchedRegionOneNumbers!.isNotEmpty;

    // Add region one numbers
    for (final number in ticket.regionOneNumbers) {
      final isMatched =
          ticket.matchedRegionOneNumbers?.contains(number) ?? false;
      if (isMatched) hasAnyMatch = true;
      numbers.add(
        _buildNumberWidget(
          context,
          number,
          isMatched: isMatched,
          allUnmatched: !hasAnyMatch && ticket.drawStatus >= 1,
        ),
      );
    }

    // Add region two number
    final isSpecialMatched =
        ticket.matchedRegionTwoNumber == ticket.regionTwoNumber;
    if (isSpecialMatched) hasAnyMatch = true;
    numbers.add(
      _buildNumberWidget(
        context,
        ticket.regionTwoNumber,
        isMatched: isSpecialMatched,
        isSpecial: true,
        allUnmatched: !hasAnyMatch && ticket.drawStatus >= 1,
      ),
    );

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: numbers,
    );
  }

  Widget _buildNumberWidget(
    BuildContext context,
    int number, {
    bool isMatched = false,
    bool isSpecial = false,
    bool allUnmatched = false,
  }) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isMatched) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      borderColor = Colors.green;
    } else {
      backgroundColor = isSpecial
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.surface;
      textColor = isSpecial
          ? Theme.of(context).colorScheme.onSecondary
          : Theme.of(context).colorScheme.onSurface;
      borderColor = isSpecial
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.outline.withOpacity(0.3);

      // Blend with red if all numbers are unmatched
      if (allUnmatched) {
        backgroundColor = Color.alphaBlend(
          Colors.red.withOpacity(0.3),
          backgroundColor,
        );
        if (!isSpecial) {
          textColor = Color.alphaBlend(Colors.red.withOpacity(0.5), textColor);
        }
      }
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          number.toString().padLeft(2, '0'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class LotteryRecordsList extends HookConsumerWidget {
  const LotteryRecordsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(lotteryRecordsProvider());

    return records.when(
      data: (recordsList) {
        if (recordsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.history,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const Gap(16),
                Text(
                  'noDrawHistory'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recordsList.length,
          itemBuilder: (context, index) {
            final record = recordsList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.celebration,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(8),
                        Text(
                          DateFormat.yMd().format(record.drawDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      '${'winningNumbers'.tr()}: ${record.winningRegionOneNumbers.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(4),
                    Text(
                      '${'specialNumber'.tr()}: ${record.winningRegionTwoNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(8),
                    Text(
                      '${'totalTickets'.tr()}: ${record.totalTickets}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(4),
                    Text(
                      '${'totalWinners'.tr()}: ${record.totalPrizesAwarded}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(4),
                    Text(
                      '${'prizePool'.tr()}: ${record.totalPrizeAmount.toStringAsFixed(2)} ${'walletCurrencyShortPoints'.tr()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class LotteryPurchaseSheet extends StatefulWidget {
  const LotteryPurchaseSheet({super.key});

  @override
  State<LotteryPurchaseSheet> createState() => _LotteryPurchaseSheetState();
}

class _LotteryPurchaseSheetState extends State<LotteryPurchaseSheet> {
  final List<int> selectedNumbers = [];
  int multiplier = 1;

  @override
  Widget build(BuildContext context) {
    final totalCost = 10.0 * multiplier; // Base cost of 10 ISP per ticket

    return SheetScaffold(
      titleText: 'buyLotteryTicket'.tr(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number Selection Section
                  Text(
                    'selectNumbers'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'select5UniqueNumbers'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'lotteryLastNumberSpecial'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(16),

                  // Number Grid
                  _buildNumberGrid(),

                  const Gap(16),

                  // Multiplier Section
                  Text(
                    'selectMultiplier'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(16),
                  _buildMultiplierSelector(),

                  const Gap(16),

                  // Cost Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('baseCost'.tr()),
                              Text('10.00 ${'walletCurrencyShortPoints'.tr()}'),
                            ],
                          ),
                          if (multiplier > 1) ...[
                            const Gap(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'multiplier'.tr(
                                    args: [multiplier.toString()],
                                  ),
                                ),
                                Text(
                                  '+ ${(10.0 * (multiplier - 1)).toStringAsFixed(2)} ${'walletCurrencyShortPoints'.tr()}',
                                ),
                              ],
                            ),
                          ],
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'totalCost'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${totalCost.toStringAsFixed(2)} ${'walletCurrencyShortPoints'.tr()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(16),

                  // Prize Structure
                  Text(
                    'prizeStructure'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  _buildPrizeStructure(),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('cancel'.tr()),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: FilledButton(
                    onPressed: _canPurchase ? _purchaseTicket : null,
                    child: Text('purchase'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        final number = index;
        final isSelected = selectedNumbers.contains(number);
        final isSpecialNumber =
            selectedNumbers.isNotEmpty &&
            selectedNumbers.last == number &&
            selectedNumbers.length == 6;

        return GestureDetector(
          onTap: () => _toggleNumber(number),
          child: Container(
            decoration: BoxDecoration(
              color: isSpecialNumber
                  ? Theme.of(context).colorScheme.secondary
                  : isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isSpecialNumber
                    ? Theme.of(context).colorScheme.secondary
                    : isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isSpecialNumber
                      ? Theme.of(context).colorScheme.onSecondary
                      : isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiplierSelector() {
    return TextFormField(
      initialValue: multiplier.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'multiplierLabel'.tr(),
        prefixText: 'x',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed >= 1) {
          setState(() => multiplier = parsed);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'lotteryMultiplierRequired'.tr();
        }
        final parsed = int.tryParse(value);
        if (parsed == null || parsed < 1 || parsed > 10) {
          return 'lotteryMultiplierRange'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildPrizeStructure() {
    // Base rewards for matched numbers (0-5)
    final baseRewards = [0, 10, 100, 500, 1000, 10000];

    final prizeStructure = <String, String>{};

    // Generate prize structure for 0-5 matches with and without special
    for (int matches = 5; matches >= 0; matches--) {
      final baseReward = baseRewards[matches];

      // With special number match (x10 multiplier)
      final specialReward = baseReward * 10;
      prizeStructure['$matches+Special'] = specialReward.toStringAsFixed(2);

      // Without special number match
      if (matches > 0) {
        prizeStructure[matches.toString()] = baseReward.toStringAsFixed(2);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: prizeStructure.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key == '0+Special'
                        ? 'specialOnly'.tr()
                        : entry.key.tr(),
                  ),
                  Text('${entry.value} ${'walletCurrencyShortPoints'.tr()}'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleNumber(int number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else if (selectedNumbers.length < 6) {
        selectedNumbers.add(number);
      }
    });
  }

  bool get _canPurchase {
    return selectedNumbers.length == 6;
  }

  Future<void> _purchaseTicket() async {
    if (!_canPurchase) return;

    // Sort all numbers except the last one (special number)
    final regularNumbers = selectedNumbers.sublist(0, 5)..sort();
    final specialNumber = selectedNumbers.last;

    final purchaseData = {
      'region_one_numbers': regularNumbers,
      'region_two_number': specialNumber,
      'multiplier': multiplier,
    };

    if (mounted) Navigator.of(context).pop(purchaseData);
  }
}
