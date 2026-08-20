import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/wallets/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WalletOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const WalletOrderDetailScreen({
    super.key,
    @PathParam('id') required this.orderId,
  });

  @override
  ConsumerState<WalletOrderDetailScreen> createState() =>
      _WalletOrderDetailScreenState();
}

class _WalletOrderDetailScreenState
    extends ConsumerState<WalletOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('walletOrder'.tr()),
        leading: const AutoLeadingButton(),
      ),
      body: WalletOrderDetailView(orderId: widget.orderId),
    );
  }
}

/// Order detail content shared by the full-screen route and the wallet's
/// wide-screen detail pane.
class WalletOrderDetailView extends ConsumerStatefulWidget {
  final String orderId;

  const WalletOrderDetailView({super.key, required this.orderId});

  @override
  ConsumerState<WalletOrderDetailView> createState() =>
      _WalletOrderDetailViewState();
}

class _WalletOrderDetailViewState extends ConsumerState<WalletOrderDetailView> {
  SnWalletOrder? _order;
  PaymentOverlayOrderInfo? _orderInfo;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(WalletOrderDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/wallet/orders/mine/${widget.orderId}',
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _order = SnWalletOrder.fromJson(data);
        _orderInfo = PaymentOverlayOrderInfo.fromJson(data);
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err;
        _loading = false;
      });
    }
  }

  bool get _isPayable {
    final order = _order;
    if (order == null || order.status != 0) return false;
    return order.expiredAt == null ||
        order.expiredAt!.isAfter(DateTime.now());
  }

  Future<void> _pay() async {
    final order = _order;
    final orderInfo = _orderInfo;
    if (order == null) return;
    try {
      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        orderInfo: orderInfo,
        payerWalletId: order.payerWalletId,
        enableBiometric: true,
      );
      if (paidOrder != null) {
        ref.invalidate(walletMyOrdersProvider);
        ref.invalidate(walletCurrentProvider);
        ref.invalidate(walletListProvider);
        ref.invalidate(walletStatsProvider);
        if (mounted) {
          showSnackBar('paymentSuccess'.tr());
          _load();
        }
      }
    } catch (err) {
      if (mounted) showErrorAlert(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return ResponseErrorWidget(error: error, onRetry: _load);
    }
    final order = _order;
    if (order == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildDetail(context, order);
  }

  Widget _buildDetail(BuildContext context, SnWalletOrder order) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final info = _orderInfo;
    final app = info?.app;
    final appName = app?.name.isNotEmpty == true ? app!.name : null;
    final productIdentifier =
        info?.productIdentifier?.isNotEmpty == true
            ? info!.productIdentifier
            : order.meta['product_identifier']?.toString() ??
                  order.meta['productIdentifier']?.toString();
    final developerName = info?.developer?.publisherName;
    final statusText = _statusText(order.status);
    final statusColor = _statusColor(order.status);

    final appIcon = app?.picture != null
        ? ProfilePictureWidget(
            file: app!.picture,
            radius: 24,
            fallbackIcon: Symbols.apps,
          )
        : WalletCurrencyMedallion(
            currency: order.currency,
            size: 48,
            iconSize: 26,
            emphasized: true,
          );

    final title = [
      if (appName != null && appName.isNotEmpty) appName,
      if (productIdentifier != null && productIdentifier.isNotEmpty)
        productIdentifier,
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Solar Core hero: the order's value as a core of light.
        WalletGlow(
          color: scheme.primary,
          intensity: 0.16,
          breathing: !MediaQuery.of(context).disableAnimations,
          borderRadius: BorderRadius.circular(kSolarRadius),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kSolarRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      appIcon,
                      const Gap(12),
                      Expanded(
                        child: Text(
                          title.isEmpty ? 'walletOrder'.tr() : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(8),
                      _StatusChip(text: statusText, color: statusColor),
                    ],
                  ),
                  const Gap(16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          formatAmountWithSuffix(order.amount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        walletCurrencyShort(order.currency),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(16),
        // Details ledger.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(kSolarRadiusSm),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'details'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              _DetailRow(label: 'status'.tr(), value: statusText, color: statusColor),
              _DetailRow(
                label: 'orderId'.tr(),
                value: order.id,
                copyable: true,
              ),
              if (order.transactionId != null &&
                  order.transactionId!.isNotEmpty)
                _DetailRow(
                  label: 'transactionId'.tr(),
                  value: order.transactionId!,
                  copyable: true,
                ),
              _DetailRow(
                label: 'date'.tr(),
                value: DateFormat.yMMMd().add_Hm().format(order.createdAt),
              ),
              if (order.expiredAt != null)
                _DetailRow(
                  label: 'expiresAt'.tr(),
                  value: DateFormat.yMMMd()
                      .add_Hm()
                      .format(order.expiredAt!),
                ),
              if (developerName != null && developerName.isNotEmpty)
                _DetailRow(label: 'developerBadgeName'.tr(), value: developerName),
              _DetailRow(
                label: 'payerWalletId'.tr(),
                value: order.payerWalletId ?? '-',
                copyable: order.payerWalletId != null,
              ),
              _DetailRow(
                label: 'payeeWalletId'.tr(),
                value: order.payeeWalletId ?? '-',
                copyable: order.payeeWalletId != null,
              ),
              if (order.remarks?.isNotEmpty ?? false)
                _DetailRow(label: 'remarks'.tr(), value: order.remarks!),
              if (info != null && info.items.isNotEmpty) ...[
                const Gap(10),
                Text(
                  'paymentSummary'.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(6),
                ...info.items.map((item) => _buildItemRow(context, item)),
              ],
            ],
          ),
        ),
        if (_isPayable) ...[
          const Gap(20),
          FilledButton.icon(
            onPressed: _pay,
            icon: const Icon(Symbols.shopping_bag),
            label: Text('complete'.tr()),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, PaymentOverlayOrderItem item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currency = item.currency.isEmpty
        ? (_order?.currency ?? item.currency)
        : item.currency;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productIdentifier,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(8),
          Text(
            '${item.quantity} × ${item.unitPrice} ${walletCurrencyShort(currency)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(int status) {
    return switch (status) {
      0 => 'pending'.tr(),
      1 => 'paymentSuccess'.tr(),
      2 => 'cancel'.tr(),
      3 => 'done'.tr(),
      4 => 'expired'.tr(),
      _ => 'order'.tr(),
    };
  }

  Color _statusColor(int status) {
    return switch (status) {
      0 => Colors.orange,
      1 => Colors.green,
      2 => Colors.grey,
      3 => Colors.blue,
      4 => Colors.red,
      _ => Colors.grey,
    };
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const Gap(5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: copyable
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
                              color: scheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(4),
                        Icon(
                          Symbols.content_copy,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: color),
                  ),
          ),
        ],
      ),
    );
  }
}
