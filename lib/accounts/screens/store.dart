import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum _BillingCopyOption { providerOrderId, internalOrderId, date }

final storeBillingRecordsProvider = AsyncNotifierProvider.autoDispose(
  StoreBillingRecordsNotifier.new,
);

class StoreBillingRecordsNotifier
    extends AsyncNotifier<PaginationState<SnWalletBillingRecord>>
    with AsyncPaginationController<SnWalletBillingRecord> {
  static const int pageSize = 20;

  @override
  Future<List<SnWalletBillingRecord>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.wallet.getBillingRecords(
      offset: fetchedCount,
      take: pageSize,
    );
    totalCount = result.totalCount;
    return result.items;
  }
}

@RoutePage()
class StoreScreen extends StellarProgramView {
  const StoreScreen({super.key}) : super(showStoreHeader: true);

  @override
  Widget? buildStoreUtilities(BuildContext context, WidgetRef ref) {
    return buildUtilityActionTile(
      context,
      icon: Symbols.receipt_long,
      title: 'storeBillingTitle'.tr(),
      description: 'storeBillingDescription'.tr(),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const StoreBillingSheet(),
        );
      },
    );
  }
}

class StoreBillingSheet extends ConsumerWidget {
  const StoreBillingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = storeBillingRecordsProvider;
    final records = ref.watch(provider);
    final items = records.value?.items ?? const <SnWalletBillingRecord>[];

    if (items.isEmpty &&
        records.hasValue &&
        records.isLoading == false &&
        records.hasError == false) {
      return SheetScaffold(
        titleText: 'storeBillingTitle'.tr(),
        heightFactor: 0.8,
        child: Center(
          child: Text(
            'noPurchasesToRestore'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return SheetScaffold(
      titleText: 'storeBillingTitle'.tr(),
      heightFactor: 0.8,
      child: PaginationList(
        padding: const EdgeInsets.symmetric(vertical: 8),
        provider: provider,
        notifier: provider.notifier,
        itemBuilder: (context, index, record) {
          final order = record.orders.firstOrNull;
          final subscription = record.subscriptions.firstOrNull;
          final providerName = _billingProviderName(record.provider);
          final rawTitle =
              subscription?.identifier ??
              order?.productIdentifier ??
              record.productIdentifier;
          final title = rawTitle == null
              ? providerName
              : _billingProviderName(rawTitle);
          final detail = [
            providerName,
            if (record.externalId.isNotEmpty) record.externalId,
            DateFormat.yMMMd().format(record.begunAt),
          ].join(' · ');
          final status = order?.status;
          final statusText = switch (status) {
            0 => 'pending'.tr(),
            1 => 'paymentSuccess'.tr(),
            2 => 'cancel'.tr(),
            3 => 'done'.tr(),
            4 => 'expired'.tr(),
            _ =>
              subscription != null
                  ? (subscription.isActive ? 'active'.tr() : 'inactive'.tr())
                  : null,
          };
          final statusColor = switch (status) {
            0 => Colors.orange,
            1 => Colors.green,
            2 => Colors.grey,
            3 => Colors.blue,
            4 => Colors.red,
            _ => Theme.of(context).colorScheme.onSurfaceVariant,
          };

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _billingProductIcon(record),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (record.isTesting) ...[
                  const SizedBox(width: 8),
                  _testingPurchaseBadge(context),
                ],
              ],
            ),
            subtitle: Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'copyToClipboardTooltip'.tr(),
                  icon: const Icon(Symbols.content_copy),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showBillingCopySheet(context, record),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (order != null)
                      Text(
                        '${order.amount.toStringAsFixed(2)} ${order.currency.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    if (statusText != null)
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _showBillingCopySheet(
  BuildContext context,
  SnWalletBillingRecord record,
) async {
  final option = await showModalBottomSheet<_BillingCopyOption>(
    context: context,
    builder: (context) => _BillingCopySheet(record: record),
  );
  if (option == null || !context.mounted) return;

  final order = record.orders.firstOrNull;
  final providerOrderId = _providerOrderId(record);
  final value = switch (option) {
    _BillingCopyOption.providerOrderId => providerOrderId,
    _BillingCopyOption.internalOrderId => order?.id ?? record.id,
    _BillingCopyOption.date => DateFormat.yMMMd().add_Hm().format(
      record.begunAt.toLocal(),
    ),
  };
  if (value == null || value.isEmpty) return;

  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) showSnackBar('copiedToClipboard'.tr());
}

String? _providerOrderId(SnWalletBillingRecord record) {
  if (record.externalId.isNotEmpty) return record.externalId;
  return record.providerReferenceId;
}

class _BillingCopySheet extends StatelessWidget {
  final SnWalletBillingRecord record;

  const _BillingCopySheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final providerOrderId = _providerOrderId(record);
    final internalOrderId = record.orders.firstOrNull?.id ?? record.id;
    final date = DateFormat.yMMMd().add_Hm().format(record.begunAt.toLocal());

    return SheetScaffold(
      titleText: 'billingCopyTitle'.tr(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (providerOrderId != null && providerOrderId.isNotEmpty)
            _buildCopyOption(
              context,
              icon: Symbols.receipt_long,
              title: 'billingCopyProviderOrderId'.tr(),
              value: providerOrderId,
              option: _BillingCopyOption.providerOrderId,
            ),
          _buildCopyOption(
            context,
            icon: Symbols.tag,
            title: 'billingCopyInternalOrderId'.tr(),
            value: internalOrderId,
            option: _BillingCopyOption.internalOrderId,
          ),
          _buildCopyOption(
            context,
            icon: Symbols.calendar_today,
            title: 'billingCopyDate'.tr(),
            value: date,
            option: _BillingCopyOption.date,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required _BillingCopyOption option,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Symbols.content_copy),
      onTap: () => Navigator.of(context).pop(option),
    );
  }
}

String _billingProviderName(String provider) {
  switch (provider.trim().toLowerCase()) {
    case 'gdp':
      return 'walletBillingProviderGdp'.tr();
    case 'apple_store':
    case 'apple-store':
    case 'applestore':
      return 'walletBillingProviderAppleStore'.tr();
    case 'order':
      return 'walletBillingProviderOrder'.tr();
    default:
      return provider;
  }
}

IconData _billingProductIcon(SnWalletBillingRecord record) {
  final product = [
    record.productIdentifier,
    record.orders.firstOrNull?.productIdentifier,
    record.subscriptions.firstOrNull?.identifier,
  ].whereType<String>().join(' ').toLowerCase();

  if (product.contains('stellar')) return Symbols.stars;
  if (product.contains('gold') || product.contains('gdp')) {
    return Symbols.account_balance_wallet;
  }
  if (product.contains('name') && product.contains('change')) {
    return Symbols.badge;
  }
  if (product.contains('quota') || product.contains('storage')) {
    return Symbols.cloud_sync;
  }
  return record.orders.isNotEmpty ? Symbols.shopping_bag : Symbols.receipt_long;
}

Widget _testingPurchaseBadge(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return Tooltip(
    message: 'storeTestingPurchaseDescription'.tr(),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          'storeTestingPurchase'.tr(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
