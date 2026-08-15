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

/// Purchasable extra-quota packs from `GET /drive/billing/quota/products`.
final quotaProductsProvider = FutureProvider<List<SnQuotaProduct>>((ref) {
  return ref.read(solarNetworkClientProvider).drive.getQuotaProducts();
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
  final String productIdentifier;
  final int quotaMb;
  final String? orderId;
  final DateTime? createdAt;
  final DateTime? expiredAt;

  const QuotaPurchaseRecord({
    required this.id,
    required this.productIdentifier,
    required this.quotaMb,
    required this.orderId,
    required this.createdAt,
    required this.expiredAt,
  });

  factory QuotaPurchaseRecord.fromJson(Map<String, dynamic> json) {
    return QuotaPurchaseRecord(
      id: json['id']?.toString() ?? '',
      productIdentifier: json['product_identifier']?.toString() ?? '',
      quotaMb: (json['quota_mb'] as num?)?.toInt() ?? 0,
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

/// Bottom sheet for browsing and buying extra storage quota.
///
/// Lists purchasable packs, shows the current extra quota and purchase
/// records, creates the Wallet order and hands it to [PaymentOverlay] for
/// PIN/biometric confirmation. The granted quota lands automatically once
/// the Wallet payment event is consumed by DysonFS.
class QuotaPurchaseSheet extends ConsumerStatefulWidget {
  const QuotaPurchaseSheet({super.key});

  @override
  ConsumerState<QuotaPurchaseSheet> createState() => _QuotaPurchaseSheetState();
}

class _QuotaPurchaseSheetState extends ConsumerState<QuotaPurchaseSheet> {
  String? _purchasingProductId;

  Future<void> _purchase(SnQuotaProduct product) async {
    final confirm = await showConfirmAlert(
      'quotaPurchaseConfirmMessage'.tr(
        namedArgs: {
          'name': product.displayName,
          'price': product.price,
          'currency': product.currency,
        },
      ),
      'quotaPurchaseConfirmTitle'.tr(),
    );
    if (!confirm || !mounted) return;

    setState(() => _purchasingProductId = product.productIdentifier);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final created = await client.drive.createQuotaPurchaseOrder(
        product.productIdentifier,
      );
      if (!mounted) return;

      SnWalletOrder order;
      try {
        final orderResp = await client.dio.get(
          '/wallet/orders/${created.orderId}',
        );
        order = SnWalletOrder.fromJson(orderResp.data);
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
          amount: int.tryParse(created.amount) ?? 0,
          expiredAt: now.add(const Duration(hours: 24)),
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
          ref.invalidate(quotaProductsProvider);
        }());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (mounted) {
        setState(() => _purchasingProductId = null);
      }
    }
  }

  String _formatExpiresIn(String? expiresIn) {
    if (expiresIn == null || expiresIn.isEmpty) {
      return 'quotaPurchasePermanent'.tr();
    }
    final match = RegExp(r'^(\d+)([smhdw])$').firstMatch(expiresIn.trim());
    if (match == null) return expiresIn;
    final amount = int.parse(match.group(1)!);
    final unit = match.group(2)!;
    final hours = switch (unit) {
      's' => amount / 3600,
      'm' => amount / 60,
      'h' => amount,
      'd' => amount * 24,
      'w' => amount * 168,
      _ => 0,
    };
    final duration = hours >= 24 && hours % 24 == 0
        ? 'quotaPurchaseDays'.tr(namedArgs: {'days': (hours ~/ 24).toString()})
        : 'quotaPurchaseHours'.tr(
            namedArgs: {'hours': hours.round().toString()},
          );
    return 'quotaPurchaseValidFor'.tr(namedArgs: {'duration': duration});
  }

  @override
  Widget build(BuildContext context) {
    final quotaAsync = ref.watch(billingQuotaProvider);
    final productsAsync = ref.watch(quotaProductsProvider);
    final recordsAsync = ref.watch(quotaPurchaseRecordsProvider);

    return SheetScaffold(
      titleText: 'quotaPurchase'.tr(),
      heightFactor: 0.9,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildExtraQuotaCard(quotaAsync),
          const Gap(16),
          _buildSectionHeader(Symbols.inventory_2, 'quotaPurchaseProducts'),
          const Gap(8),
          productsAsync.when(
            data: (products) => products.isEmpty
                ? _buildEmptyState(Symbols.inventory_2, 'quotaPurchaseEmpty')
                : Column(
                    children: [
                      for (final product in products) ...[
                        _buildProductCard(product),
                        const Gap(8),
                      ],
                    ],
                  ),
            error: (err, _) => _buildErrorState(err),
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
            error: (err, _) => _buildErrorState(err),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
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
            Icon(Symbols.storage, color: colorScheme.onPrimaryContainer),
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

  Widget _buildProductCard(SnQuotaProduct product) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPurchasing = _purchasingProductId == product.productIdentifier;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Symbols.cloud_upload,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '${formatFileSize(product.quotaMb * 1024 * 1024)} · ${_formatExpiresIn(product.expiresIn)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (product.description?.trim().isNotEmpty ?? false) ...[
                        const Gap(2),
                        Text(
                          product.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(12),
                Text(
                  '${product.price} ${product.currency}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: isPurchasing ? null : () => _purchase(product),
                icon: isPurchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.add_card, size: 18),
                label: Text(isPurchasing ? 'processing'.tr() : 'purchase'.tr()),
              ),
            ),
          ],
        ),
      ),
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
          record.productIdentifier.isNotEmpty
              ? record.productIdentifier
              : formatFileSize(record.quotaMb * 1024 * 1024),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (record.orderId != null && record.orderId!.isNotEmpty)
              record.orderId!,
            if (record.expiredAt != null)
              DateFormat.yMd().add_Hm().format(record.expiredAt!),
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: record.orderId?.isNotEmpty ?? false
                ? 'monospace'
                : null,
          ),
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

  Widget _buildErrorState(Object err) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          ref.invalidate(quotaProductsProvider);
          ref.invalidate(quotaPurchaseRecordsProvider);
        },
        icon: const Icon(Symbols.refresh, size: 18),
        label: Text('retry'.tr()),
      ),
    );
  }
}
