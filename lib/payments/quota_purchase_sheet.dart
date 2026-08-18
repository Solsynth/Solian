import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/screens/file_list.dart' show billingQuotaProvider;
import 'package:island/payments/payment_overlay.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Quota purchase pricing, from `GET /drive/billing/quota/purchase`.
final quotaPurchaseConfigProvider = FutureProvider<SnQuotaPurchaseConfig>((
  ref,
) {
  return ref.read(solarNetworkClientProvider).drive.getQuotaPurchaseConfig();
});

/// The user's quota purchase records from `GET /drive/billing/quota/records`.
final quotaPurchaseRecordsProvider = FutureProvider<List<QuotaPurchaseRecord>>((
  ref,
) async {
  final result = await ref
      .read(solarNetworkClientProvider)
      .drive
      .getQuotaRecords();
  return result.items.map(QuotaPurchaseRecord.fromJson).toList();
});

/// A single quota purchase record (raw shape from the drive billing API).
class QuotaPurchaseRecord {
  final String id;

  /// Display name of the granted quota, e.g. "1 GB Extra Quota".
  final String name;
  final String? description;
  final int quotaMb;
  final String? orderId;
  final DateTime? createdAt;
  final DateTime? expiredAt;

  const QuotaPurchaseRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.quotaMb,
    required this.orderId,
    required this.createdAt,
    required this.expiredAt,
  });

  factory QuotaPurchaseRecord.fromJson(Map<String, dynamic> json) {
    return QuotaPurchaseRecord(
      id: json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['product_identifier']?.toString() ??
          '',
      description: json['description']?.toString(),
      quotaMb:
          (json['quota'] as num?)?.toInt() ??
          (json['quota_mb'] as num?)?.toInt() ??
          0,
      orderId: json['order_id']?.toString(),
      createdAt: _parseDate(json['created_at']),
      expiredAt: _parseDate(json['expired_at']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
  }
  return null;
}

/// Bottom sheet for buying extra storage quota by the gigabyte.
///
/// Shows the unit price, the remaining allowance
/// (`max_gb − extra_quota / 1024`), a quantity selector, and purchase
/// records. Creates the Wallet order and hands it to [PaymentOverlay] for
/// PIN/biometric confirmation; the granted quota lands automatically once
/// the Wallet payment event is consumed by DysonFS.
class QuotaPurchaseSheet extends ConsumerStatefulWidget {
  const QuotaPurchaseSheet({super.key});

  @override
  ConsumerState<QuotaPurchaseSheet> createState() => _QuotaPurchaseSheetState();
}

class _QuotaPurchaseSheetState extends ConsumerState<QuotaPurchaseSheet> {
  int? _quantity;
  bool _purchasing = false;

  Future<void> _purchase(SnQuotaPurchaseConfig config, int quantityGb) async {
    final total = quantityGb * config.pricePerGb;
    final confirm = await showConfirmAlert(
      'quotaPurchaseConfirmMessage'.tr(
        namedArgs: {
          'quantity': '$quantityGb',
          'price': _formatAmount(total),
          'currency': config.currency,
        },
      ),
      'quotaPurchaseConfirmTitle'.tr(),
    );
    if (!confirm || !mounted) return;

    setState(() => _purchasing = true);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final created = await client.drive.createQuotaPurchaseOrder(
        quantityGb: quantityGb,
      );
      if (!mounted) return;

      SnWalletOrder order;
      try {
        final orderResp = await client.dio.get(
          '/wallet/orders/${created.orderId}',
        );
        order = SnWalletOrder.fromJson(
          orderResp.data,
        ).copyWith(amount: double.parse(created.amount));
      } catch (_) {
        // Order not yet visible in Wallet; synthesize from the creation
        // response so payment can still proceed. Unpaid orders expire in
        // Wallet after 24h, matching the server-side default.
        final now = DateTime.now();
        order = SnWalletOrder(
          id: created.orderId,
          status: 0,
          currency: created.currency,
          remarks: null,
          appIdentifier: '',
          meta: const {},
          amount: double.parse(created.amount),
          expiredAt: now.add(const Duration(hours: 24)),
          payerWalletId: null,
          payeeWalletId: null,
          transactionId: null,
          issuerAppId: null,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        );
      }

      if (!mounted) return;
      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        payerWalletId: order.payerWalletId,
        enableBiometric: true,
      );
      if (!mounted) return;
      if (paidOrder != null) {
        showSnackBar('quotaPurchaseSuccess'.tr());
        // Quota lands within seconds of the payment event; refresh a bit
        // later so the display reflects the granted pack.
        unawaited(() async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          ref.invalidate(billingQuotaProvider);
          ref.invalidate(quotaPurchaseRecordsProvider);
          ref.invalidate(quotaPurchaseConfigProvider);
        }());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (mounted) {
        setState(() => _purchasing = false);
      }
    }
  }

  String _formatAmount(double amount) => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(quotaPurchaseConfigProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);
    final recordsAsync = ref.watch(quotaPurchaseRecordsProvider);

    return SheetScaffold(
      titleText: 'quotaPurchase'.tr(),
      heightFactor: 0.9,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          configAsync.when(
            data: (config) => _buildPurchaseContent(config, quotaAsync),
            error: (_, _) => _buildErrorState(),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          const Gap(16),
          _buildSectionHeader(Symbols.receipt_long, 'quotaPurchaseRecords'),
          const Gap(8),
          recordsAsync.when(
            data: (records) => records.isEmpty
                ? _buildEmptyState(
                    Symbols.receipt_long,
                    'quotaPurchaseRecordsEmpty',
                  )
                : Column(
                    children: [
                      for (final record in records) ...[
                        _buildRecordCard(record),
                        const Gap(8),
                      ],
                    ],
                  ),
            error: (_, _) => _buildErrorState(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseContent(
    SnQuotaPurchaseConfig config,
    AsyncValue<Map<String, dynamic>?> quotaAsync,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final extraMb = (quotaAsync.value?['extra_quota'] as num?)?.toInt() ?? 0;
    final remainingGb = config.maxGb - extraMb / 1024.0;
    final canPurchase = remainingGb >= config.minGb;
    final effectiveMax = canPurchase ? remainingGb : config.minGb.toDouble();

    int quantity;
    if (_quantity == null) {
      quantity = config.minGb;
    } else {
      quantity = _quantity!.clamp(config.minGb, effectiveMax.floor()).toInt();
    }

    final total = quantity * config.pricePerGb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildExtraQuotaCard(quotaAsync),
        const Gap(8),
        _buildPriceCard(config),
        const Gap(8),
        Card(
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.tune,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'quotaPurchaseQuantity'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _formatAmount(remainingGb),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'quotaPurchaseRemaining'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$quantity GB',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatAmount(total)} ${config.currency}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'quotaPurchaseMin'.tr(namedArgs: {'gb': '${config.minGb}'}),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    _buildStepButton(
                      context,
                      icon: Symbols.remove,
                      enabled: canPurchase && quantity > config.minGb,
                      onTap: () => setState(() => _quantity = quantity - 1),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Slider(
                        value: quantity.toDouble().clamp(
                          config.minGb.toDouble(),
                          effectiveMax,
                        ),
                        min: config.minGb.toDouble(),
                        max: effectiveMax,
                        onChanged: canPurchase
                            ? (value) => setState(() {
                                _quantity = value
                                    .floor()
                                    .clamp(config.minGb, effectiveMax.floor())
                                    .toInt();
                              })
                            : null,
                      ),
                    ),
                    const Gap(12),
                    _buildStepButton(
                      context,
                      icon: Symbols.add,
                      enabled: canPurchase && quantity < effectiveMax.floor(),
                      onTap: () => setState(() => _quantity = quantity + 1),
                    ),
                  ],
                ),
                if (!canPurchase)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.error_outline,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            'quotaPurchaseCapReached'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canPurchase && !_purchasing
                        ? () => _purchase(config, quantity)
                        : null,
                    icon: _purchasing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.add_card, size: 18),
                    label: Text(
                      _purchasing ? 'processing'.tr() : 'purchase'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraQuotaCard(AsyncValue<Map<String, dynamic>?> quotaAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Symbols.storage,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                'quotaPurchaseExtraQuota'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            quotaAsync.when(
              data: (quota) {
                final extraMb = (quota?['extra_quota'] as num?)?.toInt() ?? 0;
                return Text(
                  formatFileSize(extraMb * 1024 * 1024),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
              error: (_, _) => Text(
                'unknown'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              loading: () => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(SnQuotaPurchaseConfig config) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      child: ListTile(
        minLeadingWidth: 48,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Symbols.payments, size: 20, color: colorScheme.primary),
        ),
        title: Text(
          'quotaPurchaseUnitPrice'.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'quotaPurchaseRange'.tr(
            namedArgs: {'min': '${config.minGb}', 'max': '${config.maxGb}'},
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          '${_formatAmount(config.pricePerGb)} ${config.currency}/GB',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// A precise step control: an outlined card with a tappable icon,
  /// disabled when the bound is unreachable.
  Widget _buildStepButton(
    BuildContext context, {
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card.outlined(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? colorScheme.onSurface : colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String titleKey) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const Gap(8),
        Text(
          titleKey,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).tr(),
      ],
    );
  }

  Widget _buildRecordCard(QuotaPurchaseRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    final expired =
        record.expiredAt != null && record.expiredAt!.isBefore(DateTime.now());
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      child: ListTile(
        minLeadingWidth: 48,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            expired ? Symbols.timer_off : Symbols.cloud_done,
            size: 20,
            color: expired ? colorScheme.onSurfaceVariant : colorScheme.primary,
          ),
        ),
        title: Text(
          record.name.trim().isNotEmpty
              ? record.name
              : formatFileSize(record.quotaMb * 1024 * 1024),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (record.description?.trim().isNotEmpty ?? false)
              record.description!,
            if (record.expiredAt != null)
              DateFormat.yMd().add_Hm().format(record.expiredAt!),
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          formatFileSize(record.quotaMb * 1024 * 1024),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String messageKey) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colorScheme.outline),
          const Gap(8),
          Text(
            messageKey,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          ref.invalidate(quotaPurchaseConfigProvider);
          ref.invalidate(quotaPurchaseRecordsProvider);
        },
        icon: const Icon(Symbols.refresh, size: 18),
        label: Text('retry'.tr()),
      ),
    );
  }
}
