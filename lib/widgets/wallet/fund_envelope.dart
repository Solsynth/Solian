import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/widgets/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:easy_localization/easy_localization.dart';

part 'fund_envelope.g.dart';

@riverpod
Future<SnWalletFund> walletFund(Ref ref, String fundId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/pass/wallets/funds/$fundId');
  return SnWalletFund.fromJson(resp.data);
}

class FundEnvelopeWidget extends HookConsumerWidget {
  const FundEnvelopeWidget({
    super.key,
    required this.fundId,
    this.maxWidth,
    this.margin,
  });

  final String fundId;
  final double? maxWidth;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundAsync = ref.watch(walletFundProvider(fundId));

    return Container(
      width: maxWidth,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: fundAsync.when(
        loading:
            () => Card(
              margin: EdgeInsets.zero,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        error:
            (error, stack) => Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'fundEnvelopeLoadFailed'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        data:
            (fund) => Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showClaimDialog(context, ref, fund),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fund title and status
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'fundEnvelope'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _buildStatusChips(context, fund),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Amount information
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${fund.totalAmount.toStringAsFixed(2)} ${fund.currency}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (fund.remainingAmount != fund.totalAmount)
                                Text(
                                  'fundEnvelopeRemaining'.tr(
                                    args: [
                                      fund.remainingAmount.toStringAsFixed(2),
                                      fund.currency,
                                    ],
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              Text(
                                'fundEnvelopeSplit'.tr(
                                  args: [
                                    fund.splitType == 0
                                        ? 'fundEnvelopeSplitEvenly'.tr()
                                        : 'fundEnvelopeSplitRandomly'.tr(),
                                  ],
                                ),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Recipients overview
                      if (fund.recipients.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRecipientsOverview(context, fund),
                      ],

                      // Message
                      if (fund.message != null && fund.message!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          '"${fund.message}"',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      // Creator info
                      if (fund.creatorAccount != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fund.creatorAccount!.nick,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Expiry info
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(fund.expiredAt),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _showClaimDialog(
    BuildContext context,
    WidgetRef ref,
    SnWalletFund fund,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => FundClaimDialog(
            fund: fund,
            onClaim: () async {
              try {
                final apiClient = ref.read(apiClientProvider);
                await apiClient.post('/pass/wallets/funds/${fund.id}/receive');

                // Refresh the fund data after claiming
                ref.invalidate(walletFundProvider(fund.id));

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  showSnackBar('fundEnvelopeClaimSuccess'.tr());
                }
              } catch (e) {
                showErrorAlert(e);
              }
            },
          ),
    );
  }

  Widget _buildStatusChip(BuildContext context, int status) {
    String text;
    Color color;

    switch (status) {
      case 0:
        text = 'fundEnvelopeStatusCreated'.tr();
        color = Colors.blue;
        break;
      case 1:
        text = 'fundEnvelopeStatusPartial'.tr();
        color = Colors.orange;
        break;
      case 2:
        text = 'fundEnvelopeStatusCompleted'.tr();
        color = Colors.green;
        break;
      case 3:
        text = 'fundEnvelopeStatusExpired'.tr();
        color = Colors.red;
        break;
      default:
        text = 'fundEnvelopeStatusUnknown'.tr();
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChips(BuildContext context, SnWalletFund fund) {
    return Row(
      children: [
        if (fund.isOpen) ...[
          _buildOpenFundBadge(context),
          const SizedBox(width: 6),
        ],
        _buildStatusChip(context, fund.status),
      ],
    );
  }

  Widget _buildOpenFundBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        'Open Fund'.tr(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.green,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecipientsOverview(BuildContext context, SnWalletFund fund) {
    final claimedCount = fund.recipients.where((r) => r.isReceived).length;
    final totalCount =
        fund.isOpen ? fund.amountOfSplits : fund.recipients.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'fundEnvelopeRecipients'.tr(
            args: [claimedCount.toString(), totalCount.toString()],
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: totalCount > 0 ? claimedCount / totalCount : 0,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.isNegative) {
        final days = difference.inDays.abs();
        return 'fundEnvelopeExpiredDaysAgo'.plural(
          days,
          args: [days.toString()],
        );
      } else if (difference.inDays == 0) {
        final hours = difference.inHours;
        if (hours == 0) {
          return 'fundEnvelopeExpiresSoon'.tr();
        }
        return 'fundEnvelopeExpiresInHours'.plural(
          hours,
          args: [hours.toString()],
        );
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return 'fundEnvelopeExpiresInDays'.plural(
          days,
          args: [days.toString()],
        );
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return date.toString();
    }
  }
}

class FundClaimDialog extends HookConsumerWidget {
  const FundClaimDialog({super.key, required this.fund, required this.onClaim});

  final SnWalletFund fund;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    // Check if user can claim
    final now = DateTime.now();
    final isExpired = fund.expiredAt.isBefore(now);
    final hasRemainingAmount = fund.remainingAmount > 0;
    final hasUserClaimed =
        userInfo.value != null &&
        fund.recipients.any(
          (recipient) =>
              recipient.recipientAccountId == userInfo.value!.id &&
              recipient.isReceived,
        );
    final userAbleToClaim =
        userInfo.value != null &&
        (fund.isOpen ||
            fund.recipients.any(
              (recipient) => recipient.recipientAccountId == userInfo.value!.id,
            ));

    final canClaim =
        !isExpired && hasRemainingAmount && !hasUserClaimed && userAbleToClaim;

    // Get claimed recipients for display
    final claimedRecipients =
        fund.recipients.where((r) => r.isReceived).toList();
    final unclaimedRecipients =
        fund.recipients.where((r) => !r.isReceived).toList();

    final remainingSplits =
        fund.isOpen
            ? fund.amountOfSplits - claimedRecipients.length
            : unclaimedRecipients.length;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text('Claim Fund'.tr()),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund info
            Text(
              '${fund.totalAmount.toStringAsFixed(2)} ${fund.currency}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Remaining amount
            Text(
              'fundEnvelopeRemainingWithSplits'.tr(
                args: [
                  fund.remainingAmount.toStringAsFixed(2),
                  fund.currency,
                  remainingSplits.toString(),
                ],
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    fund.isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      fund.isOpen
                          ? Colors.green.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Text(
                fund.isOpen ? 'Open Fund'.tr() : 'Invite Only'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: fund.isOpen ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Claimed recipients section
            if (claimedRecipients.isNotEmpty) ...[
              Text(
                'Already Claimed'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...claimedRecipients.map(
                (recipient) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recipient.recipientAccount?.nick ??
                              'fundEnvelopeUnknownUser'.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '${recipient.amount.toStringAsFixed(2)} ${fund.currency}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Unclaimed recipients section
            if (unclaimedRecipients.isNotEmpty) ...[
              Text(
                'Available to Claim'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...unclaimedRecipients.map(
                (recipient) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recipient.recipientAccount?.nick ??
                              'fundEnvelopeUnknownUser'.tr(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '${recipient.amount.toStringAsFixed(2)} ${fund.currency}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr()),
        ),
        if (canClaim)
          FilledButton.icon(
            icon: const Icon(Icons.account_balance_wallet),
            label: Text('Claim'.tr()),
            onPressed: onClaim,
          ),
      ],
    );
  }
}
