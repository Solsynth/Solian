import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/wallets/pin_status.dart';
import 'package:island/wallets/realtime_wallet.dart';
import 'package:island/wallets/transaction_detail.dart';
import 'package:island/route.gr.dart';

part 'wallet.g.dart';

PinTheme buildOutlinedPinTheme(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return PinTheme(
    width: 48,
    height: 56,
    textStyle: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colorScheme.outline),
    ),
  );
}

@riverpod
Future<SnWallet?> walletCurrent(Ref ref) async {
  try {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.wallet.getWallet();
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<List<SnWallet>> walletList(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final wallets = await client.wallet.getWallets();
  // Deduplicate by ID in case server returns duplicates
  final uniqueWallets = <String, SnWallet>{};
  for (final wallet in wallets) {
    uniqueWallets.putIfAbsent(wallet.id, () => wallet);
  }
  return uniqueWallets.values.toList();
}

@riverpod
Future<SnWallet> walletById(Ref ref, String id) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.wallet.getWalletById(id);
}

@riverpod
Future<SnWalletStats> walletStats(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.wallet.getWalletStats();
}

@riverpod
Future<List<SnWalletExchangeOption>> walletExchangeOptions(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.wallet.getCurrencyExchanges();
}

class ExchangeCurrencySheet extends ConsumerStatefulWidget {
  final String? walletId;

  const ExchangeCurrencySheet({super.key, this.walletId});

  @override
  ConsumerState<ExchangeCurrencySheet> createState() =>
      _ExchangeCurrencySheetState();
}

class _ExchangeCurrencySheetState extends ConsumerState<ExchangeCurrencySheet> {
  final amountController = TextEditingController();
  late final ValueNotifier<String?> selectedSourceCurrencyNotifier;
  String? selectedSourceCurrency;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedSourceCurrencyNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    amountController.dispose();
    selectedSourceCurrencyNotifier.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) return null;
    return amount;
  }

  double _calculateTargetAmount(double amount, SnWalletExchangeOption option) {
    final targetAmount = amount * option.targetAmount / option.sourceAmount;
    return (targetAmount * 1000).truncateToDouble() / 1000;
  }

  String _formatAmount(double amount) => amount.toStringAsFixed(3);

  Widget _buildCurrencyBadge({
    required BuildContext context,
    required String currency,
    required String amount,
    required bool emphasize,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = emphasize
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasize
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            kCurrencyIconData[currency] ?? Symbols.monetization_on,
            size: 22,
            color: foregroundColor,
          ),
          const Gap(10),
          Text(
            walletCurrencyShort(currency),
            style: theme.textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(2),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSelector({
    required ThemeData theme,
    required List<SnWalletExchangeOption> options,
    required String effectiveSourceCurrency,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'walletExchangeRate'.tr(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            underline: const SizedBox.shrink(),
            valueListenable: selectedSourceCurrencyNotifier,
            items: options.map((option) {
              return DropdownItem(
                value: option.sourceCurrency,
                child: Text(
                  '${option.sourceAmount} ${walletCurrencyShort(option.sourceCurrency)} → '
                  '${option.targetAmount} ${walletCurrencyShort(option.targetCurrency)}',
                ).padding(left: 16, right: 8),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedSourceCurrency = value);
              }
            },
            selectedItemBuilder: (context) {
              return options.map((option) {
                return Text(
                  '${option.sourceAmount} ${walletCurrencyShort(option.sourceCurrency)} → '
                  '${option.targetAmount} ${walletCurrencyShort(option.targetCurrency)}',
                  overflow: TextOverflow.ellipsis,
                );
              }).toList();
            },
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(left: 16, right: 8),
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Symbols.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview({
    required ThemeData theme,
    required SnWalletExchangeOption option,
    required double? amount,
    required double? targetAmount,
  }) {
    final colorScheme = theme.colorScheme;
    final hasAmount = amount != null && targetAmount != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Symbols.swap_horiz,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  'walletExchangePreview'.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${option.sourceAmount} ${walletCurrencyShort(option.sourceCurrency)} = '
                '${option.targetAmount} ${walletCurrencyShort(option.targetCurrency)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.72),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  hasAmount ? _formatAmount(targetAmount) : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const Gap(8),
              Text(
                walletCurrencyShort(option.targetCurrency),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            hasAmount
                ? '${_formatAmount(amount)} ${option.sourceCurrency}'
                : 'amount'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExchange(SnWalletExchangeOption option) async {
    final amount = _parseAmount();
    if (amount == null) {
      showSnackBar('invalidAmount'.tr());
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final result = await client.wallet.exchangeCurrency(
        amount: amount,
        currency: option.sourceCurrency,
        walletId: widget.walletId,
      );
      ref.invalidate(walletListProvider);
      ref.invalidate(walletCurrentProvider);
      ref.invalidate(walletStatsProvider);
      if (mounted) Navigator.of(context).pop(result);
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exchanges = ref.watch(walletExchangeOptionsProvider);

    return SheetScaffold(
      titleText: 'walletExchangeTitle'.tr(),
      child: exchanges.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (options) {
          if (options.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'walletExchangeUnavailable'.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final effectiveSourceCurrency =
              options.any(
                (option) => option.sourceCurrency == selectedSourceCurrency,
              )
              ? selectedSourceCurrency!
              : options.first.sourceCurrency;
          final selectedOption = options.firstWhere(
            (option) => option.sourceCurrency == effectiveSourceCurrency,
          );
          final amount = _parseAmount();
          final targetAmount = amount == null
              ? null
              : _calculateTargetAmount(amount, selectedOption);
          final canSubmit = amount != null && !isSubmitting;
          if (selectedSourceCurrencyNotifier.value != effectiveSourceCurrency) {
            selectedSourceCurrencyNotifier.value = effectiveSourceCurrency;
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCurrencyBadge(
                                    context: context,
                                    currency: selectedOption.sourceCurrency,
                                    amount:
                                        '${selectedOption.sourceAmount} ${selectedOption.sourceCurrency}',
                                    emphasize: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Icon(
                                    Symbols.arrow_forward,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: _buildCurrencyBadge(
                                    context: context,
                                    currency: selectedOption.targetCurrency,
                                    amount:
                                        '${selectedOption.targetAmount} ${selectedOption.targetCurrency}',
                                    emphasize: true,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            _buildRateSelector(
                              theme: theme,
                              options: options,
                              effectiveSourceCurrency: effectiveSourceCurrency,
                            ),
                          ],
                        ),
                      ),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,3}'),
                          ),
                        ],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'amount'.tr(),
                          hintText: '0.000',
                          suffixText: walletCurrencyShort(
                            selectedOption.sourceCurrency,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) {
                          if (canSubmit) _submitExchange(selectedOption);
                        },
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      _buildPreview(
                        theme: theme,
                        option: selectedOption,
                        amount: amount,
                        targetAmount: targetAmount,
                      ),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('cancel'.tr()),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: canSubmit
                              ? () => _submitExchange(selectedOption)
                              : null,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Symbols.swap_horiz),
                          label: Text('walletExchangeSubmit'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final walletStatsFilteredProvider = FutureProvider.autoDispose
    .family<SnWalletStats, ({String walletId, String currency, int period})>((
      ref,
      filter,
    ) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get<Map<String, dynamic>>(
        '/wallet/wallets/stats',
        options: Options(listFormat: ListFormat.multi),
        queryParameters: {
          'period': filter.period,
          'wallets': [filter.walletId],
          'currencies': [filter.currency],
        },
      );

      return SnWalletStats.fromJson(response.data!);
    });

class WalletTransferQrPayload {
  final String publicId;
  final String? displayName;
  final String? currency;
  final double? amount;
  final String? remark;

  const WalletTransferQrPayload({
    required this.publicId,
    this.displayName,
    this.currency,
    this.amount,
    this.remark,
  });
}

class WalletTransferRequestData {
  final String id;
  final String currency;
  final double amount;
  final String? remark;
  final bool freeze;
  final bool requireConfirmation;
  final DateTime expiresAt;
  final String payeeWalletId;
  final String? payeePublicId;
  final String? transactionId;

  const WalletTransferRequestData({
    required this.id,
    required this.currency,
    required this.amount,
    required this.freeze,
    required this.requireConfirmation,
    required this.expiresAt,
    required this.payeeWalletId,
    this.remark,
    this.payeePublicId,
    this.transactionId,
  });

  factory WalletTransferRequestData.fromJson(Map<String, dynamic> json) {
    return WalletTransferRequestData(
      id: json['id'].toString(),
      currency: json['currency'].toString(),
      amount: (json['amount'] as num).toDouble(),
      remark: json['remark']?.toString(),
      freeze: json['freeze'] as bool? ?? false,
      requireConfirmation:
          json['require_confirmation'] as bool? ??
          json['requireConfirmation'] as bool? ??
          false,
      expiresAt: DateTime.parse(json['expires_at'].toString()).toLocal(),
      payeeWalletId: json['payee_wallet_id'].toString(),
      payeePublicId: json['payee_public_id']?.toString(),
      transactionId: json['transaction_id']?.toString(),
    );
  }
}

String buildWalletTransferQrData({
  required String publicId,
  String? displayName,
  String? currency,
  double? amount,
  String? remark,
}) {
  final query = <String, String>{
    'publicId': publicId,
    if (displayName != null && displayName.trim().isNotEmpty)
      'name': displayName.trim(),
    if (currency != null && currency.trim().isNotEmpty) 'currency': currency,
    if (amount != null && amount > 0) 'amount': amount.toString(),
    if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
  };

  return Uri(
    scheme: 'solian',
    host: 'wallet',
    path: '/transfer',
    queryParameters: query,
  ).toString();
}

String buildWalletTransferRequestDeepLink(String id) {
  return Uri(
    scheme: 'solian',
    host: 'wallet',
    path: '/transfer/requests/$id',
  ).toString();
}

String buildWalletTransferRequestShareUrl(String id) {
  return Uri(
    scheme: 'https',
    host: 'solian.app',
    path: '/wallet/transfer/requests/$id',
  ).toString();
}

WalletTransferQrPayload? parseWalletTransferQrPayload(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final pathSegments = uri.pathSegments;
  final isCustomWalletTransfer =
      uri.scheme == 'solian' &&
      uri.host == 'wallet' &&
      pathSegments.length == 1 &&
      pathSegments.first == 'transfer';
  final isWebWalletTransfer =
      (uri.host == 'solian.app' || uri.host.endsWith('.solian.app')) &&
      pathSegments.length >= 2 &&
      pathSegments[0] == 'wallet' &&
      pathSegments[1] == 'transfer';

  if (!isCustomWalletTransfer && !isWebWalletTransfer) return null;

  final publicId = (uri.queryParameters['publicId'] ?? '').trim().toUpperCase();
  if (publicId.isEmpty) return null;

  final currency = uri.queryParameters['currency']?.trim();
  final normalizedCurrency = (currency != null && currency.isNotEmpty)
      ? currency
      : null;
  final amount = double.tryParse(uri.queryParameters['amount'] ?? '');
  final remark = uri.queryParameters['remark']?.trim();
  final name = uri.queryParameters['name']?.trim();

  return WalletTransferQrPayload(
    publicId: publicId,
    displayName: name?.isNotEmpty == true ? name : null,
    currency: normalizedCurrency,
    amount: amount != null && amount > 0 ? amount : null,
    remark: remark?.isNotEmpty == true ? remark : null,
  );
}

Future<WalletTransferRequestData> createWalletTransferRequest(
  WidgetRef ref, {
  required double amount,
  required String currency,
  String? walletId,
  String? remark,
  int expirationHours = 24,
  bool freeze = false,
  bool requireConfirmation = false,
}) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.post<Map<String, dynamic>>(
    '/wallet/wallets/transfer/requests',
    data: {
      'amount': amount,
      'currency': currency,
      'wallet_id': walletId,
      'remark': remark,
      'expiration_hours': expirationHours,
      'freeze': freeze,
      'require_confirmation': requireConfirmation,
    },
  );
  return WalletTransferRequestData.fromJson(response.data!);
}

Future<WalletTransferRequestData> getWalletTransferRequest(
  WidgetRef ref,
  String id,
) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.get<Map<String, dynamic>>(
    '/wallet/wallets/transfer/requests/$id',
  );
  return WalletTransferRequestData.fromJson(response.data!);
}

Future<void> submitWalletTransfer(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> transferData,
) async {
  final client = ref.read(solarNetworkClientProvider);
  try {
    showLoadingModal(context);
    await client.dio.post('/wallet/wallets/transfer', data: transferData);

    if (context.mounted) hideLoadingModal(context);

    ref.invalidate(transactionListProvider);
    ref.invalidate(walletCurrentProvider);
    ref.invalidate(walletListProvider);

    if (context.mounted) {
      showSnackBar('transferCreatedSuccessfully'.tr());
    }
  } catch (err) {
    showErrorAlert(err);
  } finally {
    if (context.mounted) hideLoadingModal(context);
  }
}

class CreateFundSheet extends ConsumerStatefulWidget {
  final String? payerWalletId;

  const CreateFundSheet({super.key, this.payerWalletId});

  @override
  ConsumerState<CreateFundSheet> createState() => _CreateFundSheetState();
}

class _CreateFundSheetState extends ConsumerState<CreateFundSheet> {
  final amountController = TextEditingController();
  final splitsController = TextEditingController(text: '1');
  final messageController = TextEditingController();
  final targetAmountController = TextEditingController();
  final contributionAmountController = TextEditingController();
  String selectedCurrency = 'golds';
  int selectedSplitType = 0; // 0: even, 1: random
  List<SnAccount> selectedRecipients = [];
  // Raising mode
  bool isRaising = false;
  int contributionType = 0; // 0: free, 1: fixed
  bool isOpen = true;
  DateTime? deadlineAt;

  @override
  void dispose() {
    amountController.dispose();
    messageController.dispose();
    splitsController.dispose();
    targetAmountController.dispose();
    contributionAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'createFund'.tr(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'fundAmount'.tr(),
                      hintText: '0.00',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    valueListenable: ValueNotifier(selectedCurrency),
                    decoration: legacy_material.InputDecoration(
                      labelText: 'currency'.tr(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      border: legacy_material.OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: kCurrencyIconData.keys.map((currency) {
                      return DropdownItem(
                        value: currency,
                        child: Text(
                          'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                              .tr(),
                        ).padding(left: 16, right: 8),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCurrency = value);
                      }
                    },
                    selectedItemBuilder: (context) {
                      return kCurrencyIconData.keys.map((currency) {
                        return Text(
                          'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                              .tr(),
                        );
                      }).toList();
                    },
                    buttonStyleData: const FormFieldButtonStyleData(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      height: 40,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  TextField(
                    controller: splitsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'amountOfSplits'.tr(),
                      hintText: '1',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onChanged: (value) {
                      if (value.isEmpty && selectedRecipients.isNotEmpty) {
                        splitsController.text = selectedRecipients.length
                            .toString();
                      }
                    },
                  ),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text('evenSplit'.tr())),
                      ButtonSegment(value: 1, label: Text('randomSplit'.tr())),
                    ],
                    selected: {selectedSplitType},
                    onSelectionChanged: (values) {
                      setState(() => selectedSplitType = values.first);
                    },
                  ),
                  // Raising mode toggle
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('raisingMode'.tr()),
                          subtitle: Text('raisingModeHint'.tr()),
                          value: isRaising,
                          onChanged: (value) {
                            setState(() => isRaising = value);
                          },
                        ),
                        if (isRaising) ...[
                          TextField(
                            controller: targetAmountController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: 'targetAmount'.tr(),
                              hintText: '0.00 (unlimited)',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          SegmentedButton<int>(
                            segments: [
                              ButtonSegment(
                                value: 0,
                                label: Text('freeContribution'.tr()),
                              ),
                              ButtonSegment(
                                value: 1,
                                label: Text('fixedContribution'.tr()),
                              ),
                            ],
                            selected: {contributionType},
                            onSelectionChanged: (values) {
                              setState(() => contributionType = values.first);
                            },
                          ),
                          if (contributionType == 1)
                            TextField(
                              controller: contributionAmountController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'contributionAmount'.tr(),
                                hintText: '0.00',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onTapOutside: (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                            ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('openToAll'.tr()),
                            subtitle: Text('openToAllHint'.tr()),
                            value: isOpen,
                            onChanged: (value) {
                              setState(() => isOpen = value);
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('deadline'.tr()),
                            subtitle: Text(
                              deadlineAt != null
                                  ? DateFormat.yMMMd().add_Hm().format(
                                      deadlineAt!,
                                    )
                                  : 'noDeadline'.tr(),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (deadlineAt != null)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() => deadlineAt = null);
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          deadlineAt ??
                                          DateTime.now().add(
                                            const Duration(days: 7),
                                          ),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null && context.mounted) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                          deadlineAt ??
                                              DateTime.now().add(
                                                const Duration(hours: 1),
                                              ),
                                        ),
                                      );
                                      if (time != null && mounted) {
                                        setState(() {
                                          deadlineAt = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          isRaising && isOpen
                              ? 'contributors'.tr()
                              : 'recipients'.tr(),
                          style: theme.textTheme.labelLarge,
                        ),
                        if (selectedRecipients.isNotEmpty)
                          ...selectedRecipients.map(
                            (recipient) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ProfilePictureWidget(
                                file: recipient.profile.picture,
                              ),
                              title: Text(
                                recipient.nick,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => setState(
                                  () => selectedRecipients.remove(recipient),
                                ),
                              ),
                            ),
                          ),
                        if (selectedRecipients.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const Gap(8),
                                Text(
                                  'noRecipientsSelected'.tr(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Gap(4),
                                Text(
                                  'selectRecipientsToSendFund'.tr(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final recipient =
                                await showModalBottomSheet<SnAccount>(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      const AccountPickerSheet(),
                                );
                            if (recipient != null &&
                                !selectedRecipients.contains(recipient)) {
                              setState(() => selectedRecipients.add(recipient));
                            }
                          },
                          icon: const Icon(Icons.person_add),
                          label: Text(
                            selectedRecipients.isNotEmpty
                                ? 'addMoreRecipients'.tr()
                                : 'selectRecipients'.tr(),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'personalMessage'.tr(),
                      hintText: 'addPersonalMessageForRecipients'.tr(),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ],
              ),
            ),
          ),
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
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _createFund,
                    child: Text('createFund'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPinVerificationDialog(BuildContext context) async {
    String enteredPin = '';

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final colorScheme = Theme.of(context).colorScheme;
          final defaultPinTheme = buildOutlinedPinTheme(context);

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SheetScaffold(
                titleText: 'enterPin'.tr(),
                heightFactor: 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'enterPinToConfirmPayment'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(24),
                            Pinput(
                              length: 6,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme
                                  .copyDecorationWith(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                              submittedPinTheme: defaultPinTheme
                                  .copyDecorationWith(
                                    color: colorScheme.surfaceContainerHighest,
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                              onSubmitted: (pin) {
                                Navigator.of(context).pop(pin);
                              },
                              onChanged: (String code) {
                                setModalState(() {
                                  enteredPin = code;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('cancel'.tr()),
                            ),
                          ),
                          if (enteredPin.length == 6) ...[
                            const Gap(12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop(enteredPin);
                                },
                                child: Text('confirm'.tr()),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createFund() async {
    try {
      final amount = double.tryParse(amountController.text);
      final splits = int.tryParse(splitsController.text);

      if (amount == null || amount <= 0) {
        showErrorAlert('invalidAmount'.tr());
        return;
      }

      if (splits == null || splits <= 0) {
        showErrorAlert('invalidNumberOfSplits'.tr());
        return;
      }

      final data = {
        'currency': selectedCurrency,
        'total_amount': isRaising ? 0 : amount,
        'split_type': selectedSplitType,
        'amount_of_splits': splits,
        'recipient_account_ids': selectedRecipients.map((r) => r.id).toList(),
        'message': messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
        'pin_code': null,
        'is_raising': isRaising,
        'is_open': isOpen,
        if (widget.payerWalletId != null)
          'payer_wallet_id': widget.payerWalletId,
        if (isRaising) ...{
          'target_amount': double.tryParse(targetAmountController.text) ?? 0,
          'contribution_type': contributionType,
          if (contributionType == 1)
            'contribution_amount':
                double.tryParse(contributionAmountController.text) ?? 0,
          if (deadlineAt != null)
            'deadline_at': deadlineAt!.toUtc().toIso8601String(),
        },
      };

      final pinStatus = await fetchWalletPinStatus(ref);
      if (pinStatus.validationRequired) {
        if (!mounted) return;
        final enteredPin = await _showPinVerificationDialog(context);
        if (enteredPin == null || enteredPin.isEmpty) return;
        data['pin_code'] = enteredPin;
      }

      if (mounted) Navigator.of(context).pop(data);
    } catch (err) {
      showErrorAlert(err);
    }
  }
}

class CreateTransferSheet extends ConsumerStatefulWidget {
  final String? payerWalletId;
  final String? initialTransferRequestId;
  final String? initialPayeePublicId;
  final String? initialPayeeName;
  final String? initialCurrency;
  final double? initialAmount;
  final String? initialRemark;
  final bool lockPayee;
  final bool lockAmount;
  final bool lockCurrency;
  final bool lockRemark;
  final bool initialFreezeTransfer;
  final bool initialRequireConfirmation;
  final bool hideTransferOptions;

  const CreateTransferSheet({
    super.key,
    this.payerWalletId,
    this.initialTransferRequestId,
    this.initialPayeePublicId,
    this.initialPayeeName,
    this.initialCurrency,
    this.initialAmount,
    this.initialRemark,
    this.lockPayee = false,
    this.lockAmount = false,
    this.lockCurrency = false,
    this.lockRemark = false,
    this.initialFreezeTransfer = false,
    this.initialRequireConfirmation = false,
    this.hideTransferOptions = false,
  });

  @override
  ConsumerState<CreateTransferSheet> createState() =>
      _CreateTransferSheetState();
}

class _CreateTransferSheetState extends ConsumerState<CreateTransferSheet> {
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  final publicIdController = TextEditingController();
  String selectedCurrency = 'golds';
  SnAccount? selectedPayee;
  int payeeType = 0;
  bool freezeTransfer = false;
  bool requireConfirmation = false;

  bool get hasLockedPublicId =>
      widget.lockPayee &&
      widget.initialPayeePublicId != null &&
      widget.initialPayeePublicId!.trim().isNotEmpty;

  bool get hasLockedAmount => widget.lockAmount && widget.initialAmount != null;

  bool get hasLockedCurrency =>
      widget.lockCurrency &&
      widget.initialCurrency != null &&
      widget.initialCurrency!.trim().isNotEmpty;

  bool get hasLockedRemark =>
      widget.lockRemark &&
      widget.initialRemark != null &&
      widget.initialRemark!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final initialPublicId = widget.initialPayeePublicId?.trim();
    if (initialPublicId != null && initialPublicId.isNotEmpty) {
      payeeType = 1;
      publicIdController.text = initialPublicId.toUpperCase();
    }

    final initialCurrency = widget.initialCurrency?.trim();
    if (initialCurrency != null &&
        kCurrencyIconData.containsKey(initialCurrency)) {
      selectedCurrency = initialCurrency;
    }

    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      amountController.text = widget.initialAmount!.toString();
    }

    final initialRemark = widget.initialRemark?.trim();
    if (initialRemark != null && initialRemark.isNotEmpty) {
      remarkController.text = initialRemark;
    }

    freezeTransfer = widget.initialFreezeTransfer;
    requireConfirmation = widget.initialRequireConfirmation;
  }

  @override
  void dispose() {
    amountController.dispose();
    remarkController.dispose();
    publicIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'createTransfer'.tr(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'transferAmount'.tr(),
                      hintText: '0.00',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    valueListenable: ValueNotifier(selectedCurrency),
                    decoration: legacy_material.InputDecoration(
                      labelText: 'currency'.tr(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      border: legacy_material.OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: kCurrencyIconData.keys.map((currency) {
                      return DropdownItem(
                        value: currency,
                        child: Text(
                          'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                              .tr(),
                        ).padding(left: 16, right: 8),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCurrency = value);
                      }
                    },
                    selectedItemBuilder: (context) {
                      return kCurrencyIconData.keys.map((currency) {
                        return Text(
                          'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                              .tr(),
                        );
                      }).toList();
                    },
                    buttonStyleData: const FormFieldButtonStyleData(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      height: 40,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        Text('payee'.tr(), style: theme.textTheme.labelLarge),
                        SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              label: Text('account'.tr()),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('walletPublicId'.tr()),
                            ),
                          ],
                          selected: {payeeType},
                          onSelectionChanged: hasLockedPublicId
                              ? null
                              : (values) {
                                  setState(() => payeeType = values.first);
                                },
                        ),
                        if (payeeType == 0) ...[
                          if (selectedPayee != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ProfilePictureWidget(
                                file: selectedPayee!.profile.picture,
                              ),
                              title: Text(
                                selectedPayee!.nick,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('selectedPayee'.tr()),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () =>
                                    setState(() => selectedPayee = null),
                              ),
                            ),
                          if (selectedPayee == null)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_add_outlined,
                                    size: 40,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'noPayeeSelected'.tr(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'selectPayeeToTransfer'.tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final payee =
                                  await showModalBottomSheet<SnAccount>(
                                    context: context,
                                    useRootNavigator: true,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        const AccountPickerSheet(),
                                  );
                              if (payee != null) {
                                setState(() => selectedPayee = payee);
                              }
                            },
                            icon: const Icon(Icons.person_search),
                            label: Text('selectPayee'.tr()),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                        if (payeeType == 1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              TextField(
                                controller: publicIdController,
                                decoration: InputDecoration(
                                  labelText: 'walletPublicId'.tr(),
                                  hintText: 'DNW-XXXX-XXXX-XXXX',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                readOnly: hasLockedPublicId,
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                              if (widget.initialPayeeName != null &&
                                  widget.initialPayeeName!.trim().isNotEmpty)
                                Text(
                                  widget.initialPayeeName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: remarkController,
                    readOnly: hasLockedRemark,
                    decoration: InputDecoration(
                      labelText: 'transferRemark'.tr(),
                      hintText: 'addRemarkForTransfer'.tr(),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  if (!widget.hideTransferOptions)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            'transferOptions'.tr(),
                            style: theme.textTheme.labelLarge,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('freezeTransfer'.tr()),
                            subtitle: Text('freezeTransferHint'.tr()),
                            value: freezeTransfer,
                            onChanged: (value) {
                              setState(() => freezeTransfer = value);
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('requireConfirmation'.tr()),
                            subtitle: Text('requireConfirmationHint'.tr()),
                            value: requireConfirmation,
                            onChanged: (value) {
                              setState(() => requireConfirmation = value);
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
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
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _createTransfer,
                    child: Text('createTransfer'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPinVerificationDialog(BuildContext context) async {
    String enteredPin = '';

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final colorScheme = Theme.of(context).colorScheme;
          final defaultPinTheme = buildOutlinedPinTheme(context);

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SheetScaffold(
                titleText: 'enterPin'.tr(),
                heightFactor: 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'enterPinToConfirmTransfer'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(24),
                            Pinput(
                              length: 6,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme
                                  .copyDecorationWith(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                              submittedPinTheme: defaultPinTheme
                                  .copyDecorationWith(
                                    color: colorScheme.surfaceContainerHighest,
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                              onSubmitted: (pin) {
                                Navigator.of(context).pop(pin);
                              },
                              onChanged: (String code) {
                                setModalState(() {
                                  enteredPin = code;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('cancel'.tr()),
                            ),
                          ),
                          if (enteredPin.length == 6) ...[
                            const Gap(12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop(enteredPin);
                                },
                                child: Text('confirm'.tr()),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createTransfer() async {
    try {
      final amount = double.tryParse(amountController.text);

      if (amount == null || amount <= 0) {
        showErrorAlert('invalidAmount'.tr());
        return;
      }

      if (payeeType == 0 && selectedPayee == null) {
        showErrorAlert('noPayeeSelected'.tr());
        return;
      }

      if (payeeType == 1 && publicIdController.text.trim().isEmpty) {
        showErrorAlert('enterPublicId'.tr());
        return;
      }

      final data = <String, dynamic>{
        'amount': amount,
        'currency': selectedCurrency,
        'pin_code': null,
        'remark': remarkController.text.trim().isEmpty
            ? null
            : remarkController.text.trim(),
        'freeze': freezeTransfer,
        'require_confirmation': requireConfirmation,
      };

      if (widget.initialTransferRequestId != null) {
        data['transfer_request_id'] = widget.initialTransferRequestId;
      }

      if (widget.payerWalletId != null) {
        data['payer_wallet_id'] = widget.payerWalletId;
      }

      if (payeeType == 0) {
        data['payee_account_id'] = selectedPayee!.id;
      } else {
        data['payee_public_id'] = publicIdController.text.trim().toUpperCase();
      }

      final pinStatus = await fetchWalletPinStatus(ref);
      if (pinStatus.validationRequired) {
        if (!mounted) return;
        final enteredPin = await _showPinVerificationDialog(context);
        if (enteredPin == null || enteredPin.isEmpty) return;
        data['pin_code'] = enteredPin;
      }

      if (mounted) Navigator.of(context).pop(data);
    } catch (err) {
      showErrorAlert(err);
    }
  }
}

final transactionListProvider = AsyncNotifierProvider.autoDispose.family(
  TransactionListNotifier.new,
);

class TransactionListNotifier
    extends AsyncNotifier<PaginationState<SnTransaction>>
    with AsyncPaginationController<SnTransaction> {
  static const int pageSize = 20;

  final ({String? walletId, String? direction, String? type}) arg;
  TransactionListNotifier(this.arg);

  @override
  Future<List<SnTransaction>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final offset = fetchedCount;

    final result = await client.wallet.getTransactions(
      offset: offset,
      take: pageSize,
      wallet: arg.walletId,
      direction: arg.direction,
      type: arg.type,
    );
    totalCount = result.totalCount;
    return result.items;
  }
}

final walletBillingRecordsProvider = AsyncNotifierProvider.autoDispose(
  WalletBillingRecordsNotifier.new,
);

class WalletBillingRecordsNotifier
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

final walletFundsProvider = AsyncNotifierProvider.autoDispose(
  WalletFundsNotifier.new,
);

class WalletFundsNotifier extends AsyncNotifier<PaginationState<SnWalletFund>>
    with AsyncPaginationController<SnWalletFund> {
  static const int pageSize = 20;

  @override
  Future<List<SnWalletFund>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final offset = fetchedCount;

    final result = await client.wallet.getFunds(offset: offset, take: pageSize);
    totalCount = result.totalCount;
    return result.items;
  }
}

final walletFundRecipientsProvider = AsyncNotifierProvider.autoDispose(
  WalletFundRecipientsNotifier.new,
);

class WalletFundRecipientsNotifier
    extends AsyncNotifier<PaginationState<SnWalletFundRecipient>>
    with AsyncPaginationController<SnWalletFundRecipient> {
  static const int _pageSize = 20;

  @override
  Future<List<SnWalletFundRecipient>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final offset = fetchedCount;

    final response = await client.dio.get(
      '/wallet/wallets/funds/recipients',
      queryParameters: {'offset': offset, 'take': _pageSize},
    );
    final list = (response.data as List)
        .map((e) => SnWalletFundRecipient.fromJson(e))
        .toList();

    if (list.length < _pageSize) {
      totalCount = fetchedCount + list.length;
    }
    return list;
  }
}

@riverpod
Future<SnWalletFund> walletFund(Ref ref, String fundId) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.wallet.getFund(fundId);
}

class TransactionDetailSheet extends ConsumerWidget {
  final SnTransaction transaction;
  final String? currentWalletId;
  final VoidCallback? onStatusChanged;

  const TransactionDetailSheet({
    super.key,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isIncome = currentWalletId == transaction.payeeWalletId;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final isPending = transaction.status == 0 || transaction.status == 1;
    final isPayee = currentWalletId == transaction.payeeWalletId;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome
                      ? Symbols.arrow_circle_down
                      : Symbols.arrow_circle_up,
                  color: amountColor,
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncome ? 'income'.tr() : 'expense'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      '${isIncome ? '+' : '-'}${formatAmountWithSuffix(transaction.amount)} ${transaction.currency}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(24),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  transaction.status == 0
                      ? Symbols.hourglass_empty
                      : transaction.status == 1
                      ? Symbols.ac_unit
                      : transaction.status == 2
                      ? Symbols.check_circle
                      : transaction.status == 3
                      ? Symbols.undo
                      : Symbols.cancel,
                  size: 16,
                  color: _getStatusColor(transaction.status),
                ),
                const Gap(6),
                Text(
                  _getStatusText(transaction.status),
                  style: TextStyle(
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
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
          if (transaction.isFrozen) ...[
            const Gap(12),
            _DetailRow(
              label: 'frozenTransfer'.tr(),
              value: 'yes'.tr(),
              theme: theme,
            ),
          ],
          if (transaction.requireConfirmation) ...[
            const Gap(12),
            _DetailRow(
              label: 'confirmationRequired'.tr(),
              value: 'yes'.tr(),
              theme: theme,
            ),
          ],
          if (transaction.frozenAt != null) ...[
            const Gap(12),
            _DetailRow(
              label: 'frozenAt'.tr(),
              value: DateFormat.yMMMd().add_Hm().format(transaction.frozenAt!),
              theme: theme,
            ),
          ],
          if (transaction.expiresAt != null) ...[
            const Gap(12),
            _DetailRow(
              label: 'expiresAt'.tr(),
              value: DateFormat.yMMMd().add_Hm().format(transaction.expiresAt!),
              theme: theme,
            ),
          ],
          if (transaction.confirmedAt != null) ...[
            const Gap(12),
            _DetailRow(
              label: 'confirmedAt'.tr(),
              value: DateFormat.yMMMd().add_Hm().format(
                transaction.confirmedAt!,
              ),
              theme: theme,
            ),
          ],
          const Gap(24),
          Text(
            'participants'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          _ParticipantRow(
            label: 'from'.tr(),
            account: transaction.payerWallet?.account,
            icon: Symbols.arrow_outward,
            theme: theme,
          ),
          const Gap(8),
          _ParticipantRow(
            label: 'to'.tr(),
            account: transaction.payeeWallet?.account,
            icon: Symbols.call_received,
            theme: theme,
          ),
          if (transaction.remarks != null &&
              transaction.remarks!.isNotEmpty) ...[
            const Gap(24),
            Text(
              'remarks'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Text(transaction.remarks!, style: theme.textTheme.bodyMedium),
          ],
          // Confirm/Reject actions for pending transactions
          if (isPending && isPayee) ...[
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final client = ref.read(solarNetworkClientProvider);
                      try {
                        showLoadingModal(context);
                        await client.wallet.rejectTransaction(transaction.id);
                        if (context.mounted) {
                          hideLoadingModal(context);
                          Navigator.of(context).pop();
                          onStatusChanged?.call();
                          showSnackBar('transactionRejected'.tr());
                        }
                      } catch (err) {
                        if (context.mounted) hideLoadingModal(context);
                        showErrorAlert(err);
                      }
                    },
                    icon: Icon(Symbols.close, color: theme.colorScheme.error),
                    label: Text('reject'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final client = ref.read(solarNetworkClientProvider);
                      try {
                        showLoadingModal(context);
                        await client.wallet.confirmTransaction(transaction.id);
                        if (context.mounted) {
                          hideLoadingModal(context);
                          Navigator.of(context).pop();
                          onStatusChanged?.call();
                          showSnackBar('transactionConfirmed'.tr());
                        }
                      } catch (err) {
                        if (context.mounted) hideLoadingModal(context);
                        showErrorAlert(err);
                      }
                    },
                    icon: Icon(Symbols.check),
                    label: Text('confirm'.tr()),
                  ),
                ),
              ],
            ),
          ],
          const Gap(24),
          const Gap(1),
          const Gap(16),
          Text(
            'technicalDetails'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          _DetailRow(
            label: 'transactionId'.tr(),
            value: transaction.id,
            theme: theme,
            copyable: true,
          ),
          const Gap(8),
          _DetailRow(
            label: 'payerWalletId'.tr(),
            value: transaction.payerWalletId ?? '-',
            theme: theme,
            copyable: true,
          ),
          const Gap(8),
          _DetailRow(
            label: 'payeeWalletId'.tr(),
            value: transaction.payeeWalletId ?? '-',
            theme: theme,
            copyable: true,
          ),
          const Gap(24),
        ],
      ),
    );
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
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const Gap(8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(8),
        if (account != null) ...[
          ProfilePictureWidget(file: account!.profile.picture, radius: 12),
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

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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
              : Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

@RoutePage()
class WalletScreen extends HookConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletListProvider);
    final realmsAsync = ref.watch(realmsJoinedProvider);
    final tabController = useMaterialTabController(initialLength: 3);
    final currentTabIndex = useState(0);
    final selectedCurrency = useState<String>('points');
    final isBalanceVisible = useState<bool>(true);
    final isFullAmountVisible = useState<bool>(false);
    final transactionFilter = useState<int>(0);
    final selectedWalletId = useState<String?>(null);
    final selectedTransactionId = useState<String?>(null);

    final balanceAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final animatedBalance = useState<double>(0.0);

    // Start listening to real-time wallet events
    useEffect(() {
      final realtimeHandler = ref.read(realtimeWalletProvider);
      realtimeHandler.startListening();
      return () => realtimeHandler.stopListening();
    }, []);

    // Listen for wallet events and show notifications
    useEffect(() {
      void handleTransactionConfirmed(WalletTransactionConfirmedEvent event) {
        if (context.mounted) {
          showSnackBar(
            'transactionConfirmedNotification'.tr(
              namedArgs: {
                'amount': formatAmountWithSuffix(event.transaction.amount),
                'currency': event.transaction.currency,
              },
            ),
          );
        }
      }

      void handleTransactionRefunded(WalletTransactionRefundedEvent event) {
        if (context.mounted) {
          showSnackBar(
            'transactionRefundedNotification'.tr(
              namedArgs: {
                'amount': formatAmountWithSuffix(event.transaction.amount),
                'currency': event.transaction.currency,
              },
            ),
          );
        }
      }

      void handleFundContributed(WalletFundContributedEvent event) {
        if (context.mounted) {
          showSnackBar(
            'fundContributedNotification'.tr(
              namedArgs: {
                'amount': formatAmountWithSuffix(event.amount),
                'currency': event.currency,
              },
            ),
          );
        }
      }

      void handleFundCompleted(WalletFundCompletedEvent event) {
        if (context.mounted) {
          showSnackBar('fundCompletedNotification'.tr());
        }
      }

      final subscriptions = [
        eventBus.on<WalletTransactionConfirmedEvent>().listen(
          handleTransactionConfirmed,
        ),
        eventBus.on<WalletTransactionRefundedEvent>().listen(
          handleTransactionRefunded,
        ),
        eventBus.on<WalletFundContributedEvent>().listen(handleFundContributed),
        eventBus.on<WalletFundCompletedEvent>().listen(handleFundCompleted),
      ];

      return () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
      };
    }, []);

    useEffect(() {
      void listener() {
        currentTabIndex.value = tabController.index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    useEffect(() {
      wallets.whenData((data) {
        if (data.isNotEmpty && selectedWalletId.value == null) {
          final primaryWallet = data.firstWhere(
            (w) => w.isPrimary,
            orElse: () => data.first,
          );
          selectedWalletId.value = primaryWallet.id;
        }
      });
      return null;
    }, [wallets]);

    final selectedWallet = useMemoized(() {
      if (!wallets.hasValue || wallets.value == null) return null;
      final walletList = wallets.value!;
      if (selectedWalletId.value == null) return null;
      return walletList
          .where((w) => w.id == selectedWalletId.value)
          .firstOrNull;
    }, [wallets, selectedWalletId.value]);

    useEffect(() {
      if (selectedWallet != null) {
        final pocket = selectedWallet.pockets.firstWhere(
          (p) => p.currency == selectedCurrency.value,
          orElse: () => SnWalletPocket(
            id: '',
            currency: selectedCurrency.value,
            amount: 0.0,
            walletId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
          ),
        );
        animatedBalance.value = pocket.amount;
        balanceAnimationController.forward(from: 0);
      }
      return null;
    }, [selectedWallet]);

    useEffect(() {
      if (selectedWallet != null) {
        final pocket = selectedWallet.pockets.firstWhere(
          (p) => p.currency == selectedCurrency.value,
          orElse: () => SnWalletPocket(
            id: '',
            currency: selectedCurrency.value,
            amount: 0.0,
            walletId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
          ),
        );
        animatedBalance.value = pocket.amount;
      }
      return null;
    }, [selectedCurrency.value]);

    Future<void> createWallet() async {
      final nameController = TextEditingController();
      final realms = realmsAsync.value ?? [];

      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => HookBuilder(
          builder: (context) {
            final selected = useState<SnRealm?>(null);
            final theme = Theme.of(context);

            return SheetScaffold(
              heightFactor: 0.7,
              titleText: 'walletCreateNew'.tr(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'walletName'.tr(),
                        hintText: 'walletNameHint'.tr(),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Text(
                          'walletOwner'.tr(),
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const Gap(8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<SnRealm?>(
                        underline: const SizedBox.shrink(),
                        isExpanded: true,
                        hint: Text('selectWalletOwner'.tr()),
                        valueListenable: selected,
                        items: [
                          DropdownItem<SnRealm?>(
                            value: null,
                            child: Row(children: [Text('personalWallet'.tr())]),
                          ),
                          ...realms.map(
                            (realm) => DropdownItem<SnRealm?>(
                              value: realm,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      realm.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          selected.value = value;
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      selected.value != null
                          ? 'realmWalletHint'.tr()
                          : 'personalWalletHint'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, {
                        'name': nameController.text,
                        'realm_id': selected.value?.id,
                      }),
                      child: Text('create'.tr()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      if (result == null) return;
      if ((result['name'] as String?)?.isEmpty ?? true) return;

      final client = ref.read(solarNetworkClientProvider);
      try {
        if (!context.mounted) return;
        showLoadingModal(context);
        await client.wallet.createWallet(
          name: result['name'],
          realmId: result['realm_id'],
        );
        ref.invalidate(walletListProvider);
        ref.invalidate(walletCurrentProvider);
        if (context.mounted) hideLoadingModal(context);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> setDefaultWallet(String walletId) async {
      final client = ref.read(solarNetworkClientProvider);
      try {
        showLoadingModal(context);
        await client.wallet.setDefaultWallet(walletId);
        ref.invalidate(walletListProvider);
        ref.invalidate(walletCurrentProvider);
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar('walletSetDefaultSuccess'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> togglePublicId(String walletId, bool enable) async {
      final client = ref.read(solarNetworkClientProvider);
      try {
        showLoadingModal(context);
        if (enable) {
          await client.wallet.enablePublicId(walletId);
        } else {
          await client.wallet.disablePublicId(walletId);
        }
        ref.invalidate(walletListProvider);
        ref.invalidate(walletCurrentProvider);
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar(
            enable
                ? 'walletPublicIdEnabled'.tr()
                : 'walletPublicIdDisabled'.tr(),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> createFund() async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) =>
            CreateFundSheet(payerWalletId: selectedWalletId.value),
      );

      if (result != null && context.mounted) {
        await _handleFundCreation(context, ref, result);
      }
    }

    Future<void> createTransfer() async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) =>
            CreateTransferSheet(payerWalletId: selectedWalletId.value),
      );

      if (result != null && context.mounted) {
        await _handleTransferCreation(context, ref, result);
      }
    }

    Future<void> exchangeCurrency() async {
      final result = await showModalBottomSheet<SnWalletExchangeResponse>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) =>
            ExchangeCurrencySheet(walletId: selectedWalletId.value),
      );

      if (result == null || !context.mounted) return;
      showSnackBar(
        'walletExchangeSuccess'.tr(
          namedArgs: {
            'sourceAmount': result.sourceAmount.toStringAsFixed(3),
            'sourceCurrency': result.sourceCurrency,
            'targetAmount': result.targetAmount.toStringAsFixed(3),
            'targetCurrency': result.targetCurrency,
          },
        ),
      );
    }

    List<SnWalletPocket> getAllCurrencies(List<SnWalletPocket> pockets) {
      final allCurrencies = <String>{};
      allCurrencies.addAll(kCurrencyIconData.keys);
      allCurrencies.addAll(pockets.map((p) => p.currency));

      return allCurrencies.map((currency) {
        final existingPocket = pockets.firstWhere(
          (p) => p.currency == currency,
          orElse: () => SnWalletPocket(
            id: '',
            currency: currency,
            amount: 0.0,
            walletId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
          ),
        );
        return existingPocket;
      }).toList();
    }

    final isWide = isWideScreen(context);
    const walletContentMaxWidth = 600.0;

    Widget buildBody() {
      return wallets.when(
        data: (walletList) {
          if (walletList.isEmpty) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('walletNotFound').tr().fontSize(16).bold(),
                  Text('walletCreateHint', textAlign: TextAlign.center).tr(),
                  TextButton(
                    onPressed: createWallet,
                    child: Text('walletCreate').tr(),
                  ),
                ],
              ),
            ).center();
          }

          if (selectedWallet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final allPockets = getAllCurrencies(selectedWallet.pockets);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildWalletSwitcher(
                      context,
                      ref,
                      walletList,
                      selectedWalletId,
                      selectedCurrency.value,
                      isBalanceVisible,
                      setDefaultWallet,
                      togglePublicId,
                    ).padding(horizontal: 16, top: 16),
                    _buildBalanceCard(
                      context,
                      allPockets,
                      selectedCurrency,
                      isBalanceVisible,
                      isFullAmountVisible,
                      balanceAnimationController,
                      animatedBalance,
                      selectedWallet,
                    ).padding(horizontal: 16, top: 8),
                    _buildBalanceStats(
                      context,
                      ref,
                      selectedWallet,
                      selectedCurrency,
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: _buildQuickActionsGrid(
                  context,
                  createTransfer,
                  createFund,
                  exchangeCurrency,
                ).padding(horizontal: 16, bottom: 8, top: 8),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(text: 'transactions'.tr()),
                    Tab(text: 'myFunds'.tr()),
                    Tab(text: 'order'.tr()),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: tabController,
              children: [
                _buildTransactionsList(
                  context,
                  ref,
                  selectedWallet,
                  transactionFilter,
                  selectedTransactionId,
                  createTransfer,
                ),
                _buildFundsList(context, ref),
                _buildBillingRecordsList(context, ref),
              ],
            ),
          );
        },
        error: (error, stackTrace) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(walletListProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('wallet').tr(),
        leading: !isWideScreen(context)
            ? IconButton(
                icon: const Icon(Symbols.menu),
                onPressed: () {
                  rootScaffoldKey.currentState?.openDrawer();
                },
              )
            : const AutoLeadingButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: createWallet,
            tooltip: 'walletCreateNew'.tr(),
          ),
          const Gap(8),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                // Left column - Wallet content
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: walletContentMaxWidth,
                    minWidth: 360,
                  ),
                  child: buildBody(),
                ),
                const VerticalDivider(width: 1),
                // Right column - Transaction detail or placeholder
                Expanded(
                  child: selectedTransactionId.value != null
                      ? TransactionDetailEmbedded(
                          transactionId: selectedTransactionId.value!,
                          currentWalletId: selectedWalletId.value,
                        )
                      : _buildEmptyDetailPlaceholder(context),
                ),
              ],
            )
          : buildBody(),
    );
  }

  Widget _buildBalanceStats(
    BuildContext context,
    WidgetRef ref,
    SnWallet selectedWallet,
    ValueNotifier<String> selectedCurrency,
  ) {
    final stats = ref.watch(
      walletStatsFilteredProvider((
        period: 30,
        walletId: selectedWallet.id,
        currency: selectedCurrency.value,
      )),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: stats.when(
        data: (data) => Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'income'.tr(),
                amount: data.totalIncome,
                currency: selectedCurrency.value,
                icon: Symbols.arrow_circle_down,
                color: Colors.green,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _statCard(
                label: 'expense'.tr(),
                amount: data.totalOutgoing,
                currency: selectedCurrency.value,
                icon: Symbols.arrow_circle_up,
                color: Colors.red,
              ),
            ),
          ],
        ),
        loading: () => Row(
          children: [
            Expanded(child: _statCardSkeleton(context)),
            const Gap(12),
            Expanded(child: _statCardSkeleton(context)),
          ],
        ),
        error: (error, stack) => _StatsErrorCard(
          error: error,
          onRetry: () => ref.invalidate(
            walletStatsFilteredProvider((
              period: 30,
              walletId: selectedWallet.id,
              currency: selectedCurrency.value,
            )),
          ),
        ),
      ),
    );
  }

  Widget _statCardSkeleton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 10,
                  width: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Gap(8),
                Container(
                  height: 12,
                  width: 88,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyChip({
    required ValueNotifier<String> selectedCurrency,
    required List<SnWalletPocket> pockets,
    required ThemeData theme,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        underline: const SizedBox.shrink(),
        valueListenable: selectedCurrency,
        onChanged: (value) {
          if (value != null) {
            selectedCurrency.value = value;
          }
        },
        customButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                kCurrencyIconData[selectedCurrency.value] ??
                    Symbols.monetization_on,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const Gap(4),
              Text(
                'walletCurrency${selectedCurrency.value[0].toUpperCase()}${selectedCurrency.value.substring(1).toLowerCase()}'
                    .tr(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, -4),
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        items: pockets.map((pocket) {
          return DropdownItem<String>(
            value: pocket.currency,
            child: Row(
              children: [
                Icon(
                  kCurrencyIconData[pocket.currency] ?? Symbols.monetization_on,
                  size: 18,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'walletCurrency${pocket.currency[0].toUpperCase()}${pocket.currency.substring(1).toLowerCase()}'
                        .tr(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required double amount,
    required String currency,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(2),
                Text(
                  '${formatAmountWithSuffix(amount)} ${walletCurrencyShort(currency)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    List<SnWalletPocket> pockets,
    ValueNotifier<String> selectedCurrency,
    ValueNotifier<bool> isBalanceVisible,
    ValueNotifier<bool> isFullAmountVisible,
    AnimationController balanceAnimationController,
    ValueNotifier<double> animatedBalance,
    SnWallet wallet,
  ) {
    final theme = Theme.of(context);
    final isWide = isWideScreen(context);

    String formatDisplayAmount(double amount) {
      if (!isBalanceVisible.value) {
        return '••••••';
      }
      if (isFullAmountVisible.value) {
        return amount.toStringAsFixed(2);
      }
      return formatAmountWithSuffix(amount);
    }

    final displayAmount = isBalanceVisible.value ? animatedBalance.value : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: displayAmount),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: EdgeInsets.all(isWide ? 20.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.account_balance_wallet,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        wallet.name.isNotEmpty ? wallet.name : 'balance'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (wallet.isPrimary) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'walletIsDefault'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Gap(8),
                    ],
                    PopupMenuButton<String>(
                      icon: Icon(
                        Symbols.more_horiz,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      iconSize: 20,
                      style: ButtonStyle(
                        visualDensity: VisualDensity(
                          vertical: -4,
                          horizontal: -2,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'visibility') {
                          isBalanceVisible.value = !isBalanceVisible.value;
                        } else if (value == 'full_amount') {
                          isFullAmountVisible.value =
                              !isFullAmountVisible.value;
                        } else if (value == 'copy_wallet_id') {
                          Clipboard.setData(ClipboardData(text: wallet.id));
                          showSnackBar('walletIdCopied'.tr());
                        } else if (value == 'copy_public_id' &&
                            wallet.publicId != null) {
                          Clipboard.setData(
                            ClipboardData(text: wallet.publicId!),
                          );
                          showSnackBar('walletPublicIdCopied'.tr());
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'visibility',
                          child: Row(
                            children: [
                              Icon(
                                isBalanceVisible.value
                                    ? Symbols.visibility_off
                                    : Symbols.visibility,
                                size: 18,
                              ),
                              const Gap(8),
                              Text(
                                isBalanceVisible.value
                                    ? 'hideBalance'.tr()
                                    : 'showBalance'.tr(),
                              ),
                            ],
                          ),
                        ),
                        if (isBalanceVisible.value)
                          PopupMenuItem(
                            value: 'full_amount',
                            child: Row(
                              children: [
                                Icon(
                                  isFullAmountVisible.value
                                      ? Symbols.unfold_less
                                      : Symbols.unfold_more,
                                  size: 18,
                                ),
                                const Gap(8),
                                Text(
                                  isFullAmountVisible.value
                                      ? 'collapseAmount'.tr()
                                      : 'expandAmount'.tr(),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'copy_wallet_id',
                          child: Row(
                            children: [
                              const Icon(Symbols.key, size: 18),
                              const Gap(8),
                              Text('walletCopyId'.tr()),
                            ],
                          ),
                        ),
                        if (wallet.publicId != null)
                          PopupMenuItem(
                            value: 'copy_public_id',
                            child: Row(
                              children: [
                                const Icon(Symbols.content_copy, size: 18),
                                const Gap(8),
                                Text('walletCopyPublicId'.tr()),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (wallet.publicId != null) ...[
                  const Gap(8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: wallet.publicId!));
                      showSnackBar('walletPublicIdCopied'.tr());
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.tag,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                        const Gap(4),
                        Text(
                          wallet.publicId!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.7),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Gap(4),
                        Icon(
                          Symbols.content_copy,
                          size: 12,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
                const Gap(12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatDisplayAmount(animatedValue),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 40 : 32,
                      ),
                    ),
                    const Gap(8),
                    _currencyChip(
                      selectedCurrency: selectedCurrency,
                      pockets: pockets,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context,
    Future<void> Function() onAddMoney,
    Future<void> Function() onSendMoney,
    Future<void> Function() onExchange,
  ) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      spacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'transfer'.tr(),
                Symbols.arrow_outward,
                color,
                onAddMoney,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildActionButton(
                context,
                'createFund'.tr(),
                Symbols.money_bag,
                color,
                onSendMoney,
              ),
            ),
          ],
        ),
        _buildActionButton(
          context,
          'walletExchangeTitle'.tr(),
          Symbols.currency_exchange,
          color,
          onExchange,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    SnWallet? wallet,
    ValueNotifier<int> filter,
    ValueNotifier<String?> selectedTransactionId,
    Future<void> Function() onCreateTransfer,
  ) {
    final direction = switch (filter.value) {
      1 => 'income',
      2 => 'outcome',
      _ => null,
    };

    final provider = transactionListProvider((
      walletId: wallet?.id,
      direction: direction,
      type: null,
    ));
    final data = ref.watch(provider);
    final items = data.value?.items ?? const <SnTransaction>[];
    final dayHeaders = groupTransactionsByDay(items, wallet?.id);
    final isEmptyState =
        items.isEmpty && data.hasValue && !data.isLoading && !data.hasError;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text('all'.tr())),
                ButtonSegment(value: 1, label: Text('income'.tr())),
                ButtonSegment(value: 2, label: Text('expense'.tr())),
              ],
              selected: {filter.value},
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                textStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              onSelectionChanged: (values) {
                final value = values.first;
                if (value != filter.value) {
                  filter.value = value;
                  ref.invalidate(provider);
                }
              },
            ),
          ),
        ),
        Expanded(
          child: isEmptyState
              ? _buildEmptyTransactions(context, onCreateTransfer)
              : PaginationList(
                  padding: EdgeInsets.zero,
                  provider: provider,
                  notifier: provider.notifier,
                  itemBuilder: (context, index, transaction) {
                    final item = InkWell(
                      onTap: () {
                        if (isWideScreen(context)) {
                          // On wide screens, update selected transaction for two-column layout
                          selectedTransactionId.value = transaction.id;
                        } else {
                          // On narrow screens, navigate to detail page
                          context.router.push(
                            TransactionDetailRoute(
                              transactionId: transaction.id,
                              currentWalletId: wallet?.id,
                            ),
                          );
                        }
                      },
                      child: _buildTransactionItem(
                        context,
                        transaction,
                        wallet?.id == transaction.payeeWalletId,
                      ),
                    );
                    final day = dayHeaders[index];
                    if (day == null) return item;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_buildDayHeader(context, day), item],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context, TransactionDayGroup day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final figures = <Widget>[];
    day.byCurrency.forEach((currency, amounts) {
      if (amounts.inAmount > 0) {
        figures.add(_buildNetFigure(context, '+', amounts.inAmount, currency));
      }
      if (amounts.outAmount > 0) {
        figures.add(_buildNetFigure(context, '-', amounts.outAmount, currency));
      }
    });

    final netRow = <Widget>[];
    for (var i = 0; i < figures.length; i++) {
      if (i > 0) {
        netRow.add(
          Text(
            ' · ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        );
      }
      netRow.add(figures[i]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                DateFormat.MMMd().format(day.date).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: netRow,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(6),
          Container(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.55),
          ),
        ],
      ),
    );
  }

  Widget _buildNetFigure(
    BuildContext context,
    String sign,
    double amount,
    String currency,
  ) {
    final theme = Theme.of(context);
    final color = sign == '+' ? incomeColor(context) : expenseColor(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$sign${formatAmountWithSuffix(amount)} ',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          TextSpan(
            text: walletCurrencyShort(currency),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(
    BuildContext context,
    Future<void> Function() onCreateTransfer,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.receipt_long,
              size: 48,
              color: colorScheme.outline.withOpacity(0.6),
            ),
            const Gap(16),
            Text(
              'noTransactions'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            Text(
              'noTransactionsHint'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            FilledButton.tonalIcon(
              onPressed: onCreateTransfer,
              icon: const Icon(Symbols.arrow_outward, size: 18),
              label: Text('createTransfer'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    SnTransaction transaction,
    bool isIncome,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final amountColor = isIncome ? incomeColor(context) : expenseColor(context);
    final description = (transaction.remarks?.isNotEmpty ?? false)
        ? transaction.remarks!
        : (transaction.type == 0 ? 'transfer'.tr() : 'payment'.tr());
    final statusLabel = _buildTransactionStatusLabel(context, transaction);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Direction marker
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Symbols.arrow_downward_alt : Symbols.arrow_upward_alt,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          // Counterparty and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionCounterparty(transaction, isIncome),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  '$description · ${DateFormat.Hm().format(transaction.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Gap(12),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${isIncome ? '+' : '-'}${formatAmountWithSuffix(transaction.amount)} ',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: walletCurrencyShort(transaction.currency),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusLabel != null) ...[const Gap(3), statusLabel],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetailPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.receipt_long,
            size: 64,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            'selectTransaction'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          Text(
            'selectTransactionHint'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRecordsList(BuildContext context, WidgetRef ref) {
    final provider = walletBillingRecordsProvider;
    final records = ref.watch(provider);
    final items = records.value?.items ?? const <SnWalletBillingRecord>[];

    if (items.isEmpty &&
        records.hasValue &&
        !records.isLoading &&
        !records.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.receipt_long,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const Gap(16),
            Text(
              'noPurchasesToRestore'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return PaginationList(
      padding: const EdgeInsets.symmetric(vertical: 8),
      provider: provider,
      notifier: provider.notifier,
      itemBuilder: (context, index, record) {
        final order = record.orders.firstOrNull;
        final subscription = record.subscriptions.firstOrNull;
        final title =
            subscription?.identifier ??
            order?.productIdentifier ??
            record.productIdentifier ??
            record.provider;
        final detail = [
          record.provider.toUpperCase(),
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
              Symbols.receipt_long,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (order != null)
                Text(
                  '${formatAmountWithSuffix(order.amount)} ${walletCurrencyShort(order.currency)}',
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
        );
      },
    );
  }

  Widget _buildFundsList(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(walletFundsProvider);

    return funds.when(
      data: (fundList) {
        if (fundList.items.isEmpty) {
          return Center(
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(8),
                Text(
                  'createYourFirstFund'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fundList.items.length,
          itemBuilder: (context, index) {
            final fund = fundList.items[index];
            final claimedCount = fund.recipients
                .where((r) => r.isReceived)
                .length;
            final totalRecipients = fund.recipients.length;

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
                          Symbols.money_bag,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            '${formatAmountWithSuffix(fund.totalAmount)} ${walletCurrencyShort(fund.currency)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getFundStatusColor(
                              context,
                              fund.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getFundStatusText(fund.status),
                            style: TextStyle(
                              color: _getFundStatusColor(context, fund.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    if (fund.isRaising) ...[
                      // Raising mode progress
                      Text(
                        '${'raised'.tr()}: ${formatAmountWithSuffix(fund.raisedAmount)} / ${fund.targetAmount > 0 ? formatAmountWithSuffix(fund.targetAmount) : '∞'} ${walletCurrencyShort(fund.currency)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (fund.targetAmount > 0) ...[
                        const Gap(4),
                        LinearProgressIndicator(
                          value: (fund.raisedAmount / fund.targetAmount).clamp(
                            0.0,
                            1.0,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      const Gap(4),
                      Text(
                        '${'contributors'.tr()}: $claimedCount/$totalRecipients',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (fund.deadlineAt != null) ...[
                        const Gap(4),
                        Text(
                          '${'deadline'.tr()}: ${DateFormat.yMd().add_Hm().format(fund.deadlineAt!)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: fund.deadlineAt!.isBefore(DateTime.now())
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        '${'recipients'.tr()}: $claimedCount/$totalRecipients',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (fund.message != null && fund.message!.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        fund.message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Gap(8),
                    Text(
                      DateFormat.yMd().add_Hm().format(fund.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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

  Future<void> _handleFundCreation(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> fundData,
  ) async {
    final client = ref.read(solarNetworkClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.dio.post(
        '/wallet/wallets/funds',
        data: fundData,
        options: Options(headers: {'X-Noop': true}),
      );
      final fund = SnWalletFund.fromJson(resp.data);
      if (fund.status == 0) return; // Already created

      final orderResp = await client.dio.post(
        '/wallet/wallets/funds/${fund.id}/order',
      );
      final order = SnWalletOrder.fromJson(orderResp.data);

      if (context.mounted) hideLoadingModal(context);

      // Show payment overlay to complete the payment
      if (!context.mounted) return;
      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        enableBiometric: true,
      );

      if (context.mounted) showLoadingModal(context);

      if (paidOrder != null) {
        // Wait for server to handle order
        await Future.delayed(const Duration(seconds: 1));
        ref.invalidate(walletFundsProvider);
        ref.invalidate(walletCurrentProvider);
        if (context.mounted) {
          showSnackBar('fundCreatedSuccessfully'.tr());
        }
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _handleTransferCreation(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> transferData,
  ) async {
    await submitWalletTransfer(context, ref, transferData);
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

  Widget _buildWalletSwitcher(
    BuildContext context,
    WidgetRef ref,
    List<SnWallet> wallets,
    ValueNotifier<String?> selectedWalletId,
    String selectedCurrency,
    ValueNotifier<bool> isBalanceVisible,
    Future<void> Function(String) setDefaultWallet,
    Future<void> Function(String, bool) togglePublicId,
  ) {
    final theme = Theme.of(context);
    final selectedWallet = wallets.firstWhere(
      (w) => w.id == selectedWalletId.value,
      orElse: () => wallets.first,
    );
    final pocket = selectedWallet.pockets.firstWhere(
      (p) => p.currency == selectedCurrency,
      orElse: () => SnWalletPocket(
        id: '',
        currency: selectedCurrency,
        amount: 0.0,
        walletId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      ),
    );
    final hasMultipleWallets = wallets.length > 1;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          underline: const SizedBox.shrink(),
          valueListenable: selectedWalletId,
          onChanged: (value) {
            if (value != null) {
              selectedWalletId.value = value;
            }
          },
          customButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedWallet.realmId != null
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    selectedWallet.realmId != null
                        ? Symbols.workspaces
                        : (selectedWallet.isPrimary
                              ? Symbols.star
                              : Symbols.wallet),
                    color: selectedWallet.realmId != null
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              selectedWallet.name.isNotEmpty
                                  ? selectedWallet.name
                                  : 'Default Wallet',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selectedWallet.isPrimary) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                selectedWallet.realmId != null
                                    ? 'realmWallet'.tr()
                                    : 'walletIsDefault'.tr(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(2),
                      Text(
                        isBalanceVisible.value
                            ? '${formatAmountWithSuffix(pocket.amount)} ${walletCurrencyShort(pocket.currency)}'
                            : '••••••',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (pocket.heldAmount > 0 && isBalanceVisible.value)
                        Text(
                          '${'held'.tr()}: ${formatAmountWithSuffix(pocket.heldAmount)} ${walletCurrencyShort(pocket.currency)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasMultipleWallets)
                  Icon(
                    Symbols.unfold_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, -4),
            width: 300,
          ),
          menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.zero),
          items: [
            ...wallets.map((wallet) {
              final wPocket = wallet.pockets.firstWhere(
                (p) => p.currency == selectedCurrency,
                orElse: () => SnWalletPocket(
                  id: '',
                  currency: selectedCurrency,
                  amount: 0.0,
                  walletId: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  deletedAt: null,
                ),
              );
              return DropdownItem<String>(
                value: wallet.id,
                height: 54,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: wallet.realmId != null
                                  ? theme.colorScheme.secondaryContainer
                                  : theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              wallet.realmId != null
                                  ? Symbols.workspaces
                                  : (wallet.isPrimary
                                        ? Symbols.star
                                        : Symbols.wallet),
                              color: wallet.realmId != null
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        wallet.name.isNotEmpty
                                            ? wallet.name
                                            : 'Default Wallet',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (wallet.isPrimary) ...[
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          wallet.realmId != null
                                              ? 'realmWallet'.tr()
                                              : 'walletIsDefault'.tr(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onTertiaryContainer,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const Gap(2),
                                Text(
                                  isBalanceVisible.value
                                      ? '${formatAmountWithSuffix(wPocket.amount)} ${walletCurrencyShort(wPocket.currency)}'
                                      : '••••••',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Symbols.more_vert,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onSelected: (value) {
                              if (value == 'set_default' && !wallet.isPrimary) {
                                setDefaultWallet(wallet.id);
                              } else if (value == 'enable_public_id') {
                                togglePublicId(wallet.id, true);
                              } else if (value == 'disable_public_id') {
                                togglePublicId(wallet.id, false);
                              }
                            },
                            itemBuilder: (context) => [
                              if (!wallet.isPrimary && wallet.realmId == null)
                                PopupMenuItem(
                                  value: 'set_default',
                                  child: Row(
                                    children: [
                                      const Icon(Symbols.star, size: 18),
                                      const Gap(8),
                                      Text('walletSetDefault'.tr()),
                                    ],
                                  ),
                                ),
                              if (wallet.publicId == null)
                                PopupMenuItem(
                                  value: 'enable_public_id',
                                  child: Row(
                                    children: [
                                      const Icon(Symbols.tag, size: 18),
                                      const Gap(8),
                                      Text('walletEnablePublicId'.tr()),
                                    ],
                                  ),
                                ),
                              if (wallet.publicId != null)
                                PopupMenuItem(
                                  value: 'disable_public_id',
                                  child: Row(
                                    children: [
                                      const Icon(Symbols.tag, size: 18),
                                      const Gap(8),
                                      Text('walletDisablePublicId'.tr()),
                                    ],
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
            }),
          ],
        ),
      ),
    );
  }
}

class _StatsErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _StatsErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const Gap(12),
          Expanded(
            child: Text(
              'Unable to load wallet stats.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

const Map<String, IconData> kCurrencyIconData = {
  'points': Symbols.save,
  'golds': Symbols.account_balance,
};

String formatAmountWithSuffix(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(2)}m';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(2)}k';
  } else {
    return amount.toStringAsFixed(2);
  }
}

/// Short localized currency name (e.g. "Gold", "Bits"), falling back to the
/// raw currency code when no translation exists.
String walletCurrencyShort(String currency) {
  if (currency.isEmpty) return currency;
  final key =
      'walletCurrencyShort${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}';
  final localized = key.tr();
  return localized == key ? currency : localized;
}

/// A single day in the transaction ledger, with per-currency in/out sums.
class TransactionDayGroup {
  final DateTime date;
  final Map<String, ({double inAmount, double outAmount})> byCurrency;

  const TransactionDayGroup({required this.date, required this.byCurrency});
}

/// Groups consecutive same-day transactions and computes each day's
/// per-currency income/outcome sums. Returns a map from the list index where
/// a day begins to that day's header data. Income is determined by [walletId]
/// being the payee, matching the row-level direction logic.
Map<int, TransactionDayGroup> groupTransactionsByDay(
  List<SnTransaction> items,
  String? walletId,
) {
  final days = <DateTime, List<int>>{};
  for (var i = 0; i < items.length; i++) {
    final createdAt = items[i].createdAt;
    final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
    days.putIfAbsent(date, () => []).add(i);
  }

  return {
    for (final entry in days.entries)
      entry.value.first: TransactionDayGroup(
        date: entry.key,
        byCurrency: _sumDay(items, entry.value, walletId),
      ),
  };
}

Map<String, ({double inAmount, double outAmount})> _sumDay(
  List<SnTransaction> items,
  List<int> indexes,
  String? walletId,
) {
  final sums = <String, ({double inAmount, double outAmount})>{};
  for (final i in indexes) {
    final transaction = items[i];
    final acc = sums[transaction.currency] ?? (inAmount: 0.0, outAmount: 0.0);
    final isIncome = walletId == transaction.payeeWalletId;
    sums[transaction.currency] = isIncome
        ? (
            inAmount: acc.inAmount + transaction.amount,
            outAmount: acc.outAmount,
          )
        : (
            inAmount: acc.inAmount,
            outAmount: acc.outAmount + transaction.amount,
          );
  }
  return sums;
}

/// Green used for money coming in (income amounts, confirmed states).
Color incomeColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF81C784)
    : const Color(0xFF2E7D32);

/// Red used for money going out (expense amounts, refunded states).
Color expenseColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFE57373)
    : const Color(0xFFC62828);

/// Amber used for pending states.
Color pendingColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFFFB74D)
    : const Color(0xFFEF6C00);

/// Blue used for frozen/escrow states.
Color frozenColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF64B5F6)
    : const Color(0xFF1565C0);

/// Grey used for cancelled states.
Color cancelledColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFBDBDBD)
    : const Color(0xFF757575);

String _transactionCounterparty(SnTransaction transaction, bool isIncome) {
  final wallet = isIncome ? transaction.payerWallet : transaction.payeeWallet;
  final account = wallet?.account;
  if (account != null && account.nick.isNotEmpty) return account.nick;
  if (wallet != null && wallet.name.isNotEmpty) return wallet.name;
  return 'systemWallet'.tr();
}

Widget? _buildTransactionStatusLabel(BuildContext context, SnTransaction t) {
  String? text;
  Color color;
  switch (t.status) {
    case TransactionStatus.pending:
      text = 'pendingShort'.tr();
      color = pendingColor(context);
    case TransactionStatus.frozen:
      text = 'frozenShort'.tr();
      color = frozenColor(context);
    case TransactionStatus.refunded:
      text = 'refundedShort'.tr();
      color = expenseColor(context);
    case TransactionStatus.cancelled:
      text = 'cancelledShort'.tr();
      color = cancelledColor(context);
    default:
      text = t.requireConfirmation ? 'confirmationRequired'.tr() : null;
      color = frozenColor(context);
  }
  if (text == null) return null;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const Gap(4),
      Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    ],
  );
}
