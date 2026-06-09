import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/response.dart';
import 'package:island/wallets/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'transaction_detail.g.dart';

@riverpod
Future<SnTransaction> transactionDetail(Ref ref, String id) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.wallet.getTransaction(id);
}

@RoutePage()
class TransactionDetailScreen extends HookConsumerWidget {
  final String transactionId;
  final String? currentWalletId;

  const TransactionDetailScreen({
    super.key,
    @PathParam('id') required this.transactionId,
    this.currentWalletId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionDetailProvider(transactionId));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('transactionDetails'.tr()),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: transactionAsync.when(
        data: (transaction) => _TransactionDetailContent(
          transaction: transaction,
          currentWalletId: currentWalletId,
          onStatusChanged: () {
            ref.invalidate(transactionDetailProvider(transactionId));
            ref.invalidate(walletCurrentProvider);
            ref.invalidate(walletListProvider);
            ref.invalidate(transactionListProvider);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(transactionDetailProvider(transactionId)),
        ),
      ),
    );
  }
}

/// Embedded version for two-column layout (no AppBar/Scaffold)
class TransactionDetailEmbedded extends HookConsumerWidget {
  final String transactionId;
  final String? currentWalletId;

  const TransactionDetailEmbedded({
    super.key,
    required this.transactionId,
    this.currentWalletId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionDetailProvider(transactionId));

    return transactionAsync.when(
      data: (transaction) => _TransactionDetailContent(
        transaction: transaction,
        currentWalletId: currentWalletId,
        onStatusChanged: () {
          ref.invalidate(transactionDetailProvider(transactionId));
          ref.invalidate(walletCurrentProvider);
          ref.invalidate(walletListProvider);
          ref.invalidate(transactionListProvider);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ResponseErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(transactionDetailProvider(transactionId)),
      ),
    );
  }
}

class _TransactionDetailContent extends ConsumerWidget {
  final SnTransaction transaction;
  final String? currentWalletId;
  final VoidCallback? onStatusChanged;

  const _TransactionDetailContent({
    required this.transaction,
    this.currentWalletId,
    this.onStatusChanged,
  });

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'transactionStatusPending'.tr();
      case 1:
        return 'transactionStatusFrozen'.tr();
      case 2:
        return 'transactionStatusConfirmed'.tr();
      case 3:
        return 'transactionStatusRefunded'.tr();
      case 4:
        return 'transactionStatusCancelled'.tr();
      default:
        return 'unknown'.tr();
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Symbols.hourglass_empty;
      case 1:
        return Symbols.ac_unit;
      case 2:
        return Symbols.check_circle;
      case 3:
        return Symbols.undo;
      case 4:
        return Symbols.cancel;
      default:
        return Symbols.help;
    }
  }

  String _getTransactionTypeText(int type) {
    switch (type) {
      case 0:
        return 'transfer'.tr();
      case 1:
        return 'payment'.tr();
      default:
        return 'unknown'.tr();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isWide = isWideScreen(context);
    final isIncome = currentWalletId == transaction.payeeWalletId;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final isPending = transaction.status == 0 || transaction.status == 1;
    final isPayee = currentWalletId == transaction.payeeWalletId;

    final content = SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount header
          _buildAmountHeader(context, theme, isIncome, amountColor),
          const Gap(32),

          // Status badge
          _buildStatusBadge(context, theme),
          const Gap(24),

          // Transaction info section
          _buildInfoSection(context, theme),
          const Gap(24),

          // Lifecycle info (if applicable)
          if (transaction.isFrozen || transaction.requireConfirmation || 
              transaction.frozenAt != null || transaction.expiresAt != null ||
              transaction.confirmedAt != null)
            _buildLifecycleSection(context, theme),
          if (transaction.isFrozen || transaction.requireConfirmation || 
              transaction.frozenAt != null || transaction.expiresAt != null ||
              transaction.confirmedAt != null)
            const Gap(24),

          // Participants section
          _buildParticipantsSection(context, theme),
          const Gap(24),

          // Remarks section
          if (transaction.remarks != null && transaction.remarks!.isNotEmpty)
            _buildRemarksSection(context, theme),
          if (transaction.remarks != null && transaction.remarks!.isNotEmpty)
            const Gap(24),

          // Confirm/Reject actions for pending transactions
          if (isPending && isPayee) ...[
            _buildActionButtons(context, ref, theme),
            const Gap(24),
          ],

          // Technical details section
          _buildTechnicalSection(context, theme),
          const Gap(32),
        ],
      ),
    );

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildAmountHeader(
    BuildContext context,
    ThemeData theme,
    bool isIncome,
    Color amountColor,
  ) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isIncome ? Symbols.arrow_circle_down : Symbols.arrow_circle_up,
              color: amountColor,
              size: 32,
            ),
          ),
          const Gap(16),
          Text(
            isIncome ? 'income'.tr() : 'expense'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Text(
            '${isIncome ? '+' : '-'}${formatAmountWithSuffix(transaction.amount)} ${transaction.currency}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          const Gap(8),
          Text(
            DateFormat.yMMMd().add_Hm().format(transaction.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme) {
    final statusColor = _getStatusColor(transaction.status);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(transaction.status),
              size: 18,
              color: statusColor,
            ),
            const Gap(8),
            Text(
              _getStatusText(transaction.status),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return _SectionCard(
      title: 'transactionInfo'.tr(),
      children: [
        _DetailRow(
          label: 'date'.tr(),
          value: DateFormat.yMMMd().add_Hm().format(transaction.createdAt),
          theme: theme,
        ),
        const Gap(12),
        _DetailRow(
          label: 'transactionType'.tr(),
          value: _getTransactionTypeText(transaction.type),
          theme: theme,
        ),
        const Gap(12),
        _DetailRow(
          label: 'currency'.tr(),
          value: transaction.currency,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildLifecycleSection(BuildContext context, ThemeData theme) {
    return _SectionCard(
      title: 'lifecycleDetails'.tr(),
      children: [
        if (transaction.isFrozen) ...[
          _DetailRow(
            label: 'frozenTransfer'.tr(),
            value: 'yes'.tr(),
            theme: theme,
          ),
          const Gap(12),
        ],
        if (transaction.requireConfirmation) ...[
          _DetailRow(
            label: 'confirmationRequired'.tr(),
            value: 'yes'.tr(),
            theme: theme,
          ),
          const Gap(12),
        ],
        if (transaction.frozenAt != null) ...[
          _DetailRow(
            label: 'frozenAt'.tr(),
            value: DateFormat.yMMMd().add_Hm().format(transaction.frozenAt!),
            theme: theme,
          ),
          const Gap(12),
        ],
        if (transaction.expiresAt != null) ...[
          _DetailRow(
            label: 'expiresAt'.tr(),
            value: DateFormat.yMMMd().add_Hm().format(transaction.expiresAt!),
            theme: theme,
            isExpired: transaction.expiresAt!.isBefore(DateTime.now()),
          ),
          const Gap(12),
        ],
        if (transaction.confirmedAt != null) ...[
          _DetailRow(
            label: 'confirmedAt'.tr(),
            value: DateFormat.yMMMd().add_Hm().format(transaction.confirmedAt!),
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildParticipantsSection(BuildContext context, ThemeData theme) {
    return _SectionCard(
      title: 'participants'.tr(),
      children: [
        _ParticipantRow(
          label: 'from'.tr(),
          account: transaction.payerWallet?.account,
          icon: Symbols.arrow_outward,
          theme: theme,
        ),
        const Gap(12),
        _ParticipantRow(
          label: 'to'.tr(),
          account: transaction.payeeWallet?.account,
          icon: Symbols.call_received,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildRemarksSection(BuildContext context, ThemeData theme) {
    return _SectionCard(
      title: 'remarks'.tr(),
      children: [
        Text(
          transaction.remarks!,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _rejectTransaction(context, ref),
            icon: Icon(Symbols.close, color: theme.colorScheme.error),
            label: Text('reject'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _confirmTransaction(context, ref),
            icon: const Icon(Symbols.check),
            label: Text('confirm'.tr()),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmTransaction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final client = ref.read(solarNetworkClientProvider);
    try {
      showLoadingModal(context);
      await client.wallet.confirmTransaction(transaction.id);
      if (context.mounted) {
        hideLoadingModal(context);
        onStatusChanged?.call();
        showSnackBar('transactionConfirmed'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  Future<void> _rejectTransaction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final client = ref.read(solarNetworkClientProvider);
    try {
      showLoadingModal(context);
      await client.wallet.rejectTransaction(transaction.id);
      if (context.mounted) {
        hideLoadingModal(context);
        onStatusChanged?.call();
        showSnackBar('transactionRejected'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  Widget _buildTechnicalSection(BuildContext context, ThemeData theme) {
    return _SectionCard(
      title: 'technicalDetails'.tr(),
      children: [
        _DetailRow(
          label: 'transactionId'.tr(),
          value: transaction.id,
          theme: theme,
          copyable: true,
        ),
        const Gap(12),
        _DetailRow(
          label: 'payerWalletId'.tr(),
          value: transaction.payerWalletId ?? '-',
          theme: theme,
          copyable: true,
        ),
        const Gap(12),
        _DetailRow(
          label: 'payeeWalletId'.tr(),
          value: transaction.payeeWalletId ?? '-',
          theme: theme,
          copyable: true,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          ...children,
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  final String label;
  final SnAccount? account;
  final IconData icon;
  final ThemeData theme;

  const _ParticipantRow({
    required this.label,
    required this.account,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const Gap(12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(12),
        if (account != null) ...[
          ProfilePictureWidget(file: account!.profile.picture, radius: 16),
          const Gap(8),
          Expanded(
            child: Text(
              account!.nick,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          Expanded(
            child: Text(
              'systemWallet'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool copyable;
  final bool isExpired;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.copyable = false,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: copyable && value != '-'
              ? InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    showSnackBar('copiedToClipboard'.tr());
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(4),
                      Icon(
                        Symbols.content_copy,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isExpired ? theme.colorScheme.error : null,
                  ),
                ),
        ),
      ],
    );
  }
}
