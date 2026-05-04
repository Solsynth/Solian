import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/network.dart';
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

part 'wallet.g.dart';

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

class CreateFundSheet extends StatefulWidget {
  final String? payerWalletId;

  const CreateFundSheet({super.key, this.payerWalletId});

  @override
  State<CreateFundSheet> createState() => _CreateFundSheetState();
}

class _CreateFundSheetState extends State<CreateFundSheet> {
  final amountController = TextEditingController();
  final splitsController = TextEditingController(text: '1');
  final messageController = TextEditingController();
  String selectedCurrency = 'golds';
  int selectedSplitType = 0; // 0: even, 1: random
  List<SnAccount> selectedRecipients = [];

  @override
  void dispose() {
    amountController.dispose();
    messageController.dispose();
    splitsController.dispose();
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
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.attach_money,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'fundDetails'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
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
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          const Gap(12),
                          DropdownButtonFormField<String>(
                            value: selectedCurrency,
                            decoration: InputDecoration(
                              labelText: 'currency'.tr(),
                            ),
                            items: kCurrencyIconData.keys.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Row(
                                  children: [
                                    Icon(kCurrencyIconData[currency], size: 18),
                                    const Gap(8),
                                    Text(
                                      'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                                          .tr(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedCurrency = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.call_split,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'splitSettings'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          TextField(
                            controller: splitsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'amountOfSplits'.tr(),
                              hintText: '1',
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onChanged: (value) {
                              if (value.isEmpty &&
                                  selectedRecipients.isNotEmpty) {
                                splitsController.text = selectedRecipients
                                    .length
                                    .toString();
                              }
                            },
                          ),
                          const Gap(16),
                          SegmentedButton<int>(
                            segments: [
                              ButtonSegment(
                                value: 0,
                                label: Text('evenSplit'.tr()),
                              ),
                              ButtonSegment(
                                value: 1,
                                label: Text('randomSplit'.tr()),
                              ),
                            ],
                            selected: {selectedSplitType},
                            onSelectionChanged: (values) {
                              setState(() => selectedSplitType = values.first);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.group,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'recipients'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
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
                          const Gap(12),
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
                                setState(
                                  () => selectedRecipients.add(recipient),
                                );
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
                  ),
                  const Gap(16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.message,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'message'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              labelText: 'personalMessage'.tr(),
                              hintText: 'addPersonalMessageForRecipients'.tr(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        ],
                      ),
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                          onSubmitted: (pin) {
                            enteredPin = pin;
                            Navigator.of(context).pop(pin);
                          },
                          onChanged: (String code) {
                            enteredPin = code;
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
      ),
    );

    return enteredPin.isNotEmpty ? enteredPin : null;
  }

  Future<void> _createFund() async {
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
      'total_amount': amount,
      'split_type': selectedSplitType,
      'amount_of_splits': splits,
      'recipient_account_ids': selectedRecipients.map((r) => r.id).toList(),
      'message': messageController.text.trim().isEmpty
          ? null
          : messageController.text.trim(),
      'pin_code': '',
      if (widget.payerWalletId != null) 'payer_wallet_id': widget.payerWalletId,
    };

    // Ask for PIN confirmation before creating fund
    final enteredPin = await _showPinVerificationDialog(context);
    if (enteredPin == null || enteredPin.isEmpty) return;

    // Add PIN to the fund data
    data['pin_code'] = enteredPin;

    if (mounted) Navigator.of(context).pop(data);
  }
}

class CreateTransferSheet extends StatefulWidget {
  final String? payerWalletId;

  const CreateTransferSheet({super.key, this.payerWalletId});

  @override
  State<CreateTransferSheet> createState() => _CreateTransferSheetState();
}

class _CreateTransferSheetState extends State<CreateTransferSheet> {
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  final publicIdController = TextEditingController();
  String selectedCurrency = 'golds';
  SnAccount? selectedPayee;
  int payeeType = 0;

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
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.attach_money,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'transferDetails'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
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
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          const Gap(12),
                          DropdownButtonFormField<String>(
                            value: selectedCurrency,
                            decoration: InputDecoration(
                              labelText: 'currency'.tr(),
                            ),
                            items: kCurrencyIconData.keys.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Row(
                                  children: [
                                    Icon(kCurrencyIconData[currency], size: 18),
                                    const Gap(8),
                                    Text(
                                      'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                                          .tr(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedCurrency = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.person,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'payee'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
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
                            onSelectionChanged: (values) {
                              setState(() => payeeType = values.first);
                            },
                          ),
                          const Gap(16),
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
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
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
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            const Gap(12),
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
                          if (payeeType == 1) ...[
                            TextField(
                              controller: publicIdController,
                              decoration: InputDecoration(
                                labelText: 'walletPublicId'.tr(),
                                hintText: 'DNW-XXXX-XXXX-XXXX',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.notes,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'remark'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          TextField(
                            controller: remarkController,
                            decoration: InputDecoration(
                              labelText: 'transferRemark'.tr(),
                              hintText: 'addRemarkForTransfer'.tr(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        ],
                      ),
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                          onSubmitted: (pin) {
                            enteredPin = pin;
                            Navigator.of(context).pop(pin);
                          },
                          onChanged: (String code) {
                            enteredPin = code;
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
      ),
    );

    return enteredPin.isNotEmpty ? enteredPin : null;
  }

  Future<void> _createTransfer() async {
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
      'remark': remarkController.text.trim().isEmpty
          ? null
          : remarkController.text.trim(),
    };

    if (widget.payerWalletId != null) {
      data['payer_wallet_id'] = widget.payerWalletId;
    }

    if (payeeType == 0) {
      data['payee_account_id'] = selectedPayee!.id;
    } else {
      data['payee_public_id'] = publicIdController.text.trim().toUpperCase();
    }

    final enteredPin = await _showPinVerificationDialog(context);
    if (enteredPin == null || enteredPin.isEmpty) return;

    data['pin_code'] = enteredPin;

    if (mounted) Navigator.of(context).pop(data);
  }
}

final transactionListProvider = AsyncNotifierProvider.autoDispose.family(
  TransactionListNotifier.new,
);

class TransactionListNotifier extends AsyncNotifier<PaginationState<SnTransaction>>
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

class TransactionDetailSheet extends StatelessWidget {
  final SnTransaction transaction;
  final String? currentWalletId;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    this.currentWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = currentWalletId == transaction.payeeWalletId;
    final amountColor = isIncome ? Colors.green : Colors.red;

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
          const Gap(1),
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
    final tabController = useTabController(initialLength: 2);
    final currentTabIndex = useState(0);
    final selectedCurrency = useState<String>('points');
    final isBalanceVisible = useState<bool>(true);
    final isFullAmountVisible = useState<bool>(false);
    final transactionFilter = useState<int>(0);
    final selectedWalletId = useState<String?>(null);

    final balanceAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final animatedBalance = useState<double>(0.0);

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
              titleText: 'walletCreateNew'.tr(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
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
                        isExpanded: true,
                        hint: Text('selectWalletOwner'.tr()),
                        valueListenable: selected,
                        items: [
                          DropdownItem<SnRealm?>(
                            value: null,
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Symbols.person, fill: 1),
                                ),
                                const SizedBox(width: 12),
                                Text('personalWallet'.tr()),
                              ],
                            ),
                          ),
                          ...realms.map(
                            (realm) => DropdownItem<SnRealm?>(
                              value: realm,
                              child: Row(
                                children: [
                                  ProfilePictureWidget(
                                    file: realm.picture,
                                    fallbackIcon: Symbols.workspaces,
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 12),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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

    return AppScaffold(
      appBar: AppBar(
        title: Text('wallet').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: createWallet,
            tooltip: 'walletCreateNew'.tr(),
          ),
        ],
      ),
      body: wallets.when(
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
                    _buildBalanceStats(context, ref, selectedCurrency),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: _buildQuickActionsGrid(
                  context,
                  createTransfer,
                  createFund,
                ).padding(horizontal: 16, bottom: 8, top: 8),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(text: 'transactions'.tr()),
                    Tab(text: 'myFunds'.tr()),
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
                ),
                _buildFundsList(context, ref),
              ],
            ),
          );
        },
        error: (error, stackTrace) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(walletListProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildBalanceStats(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String> selectedCurrency,
  ) {
    final stats = ref.watch(walletStatsProvider);

    return stats.when(
      data: (data) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
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
      ),
      loading: () => const SizedBox(height: 64),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _currencyChip({
    required ValueNotifier<String> selectedCurrency,
    required List<SnWalletPocket> pockets,
    required ThemeData theme,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
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
                Text(
                  'walletCurrency${pocket.currency[0].toUpperCase()}${pocket.currency.substring(1).toLowerCase()}'
                      .tr(),
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
                  '${formatAmountWithSuffix(amount)} $currency',
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
                                      ? 'showCompact'.tr()
                                      : 'showFullAmount'.tr(),
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
                                      ? 'showCompact'.tr()
                                      : 'showFullAmount'.tr(),
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
                  Row(
                    children: [
                      Icon(
                        Symbols.tag,
                        size: 14,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.7,
                        ),
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
                    ],
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
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'transfer'.tr(),
                Symbols.arrow_outward,
                Theme.of(context).colorScheme.primary,
                onAddMoney,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildActionButton(
                context,
                'createFund'.tr(),
                Symbols.money_bag,
                Theme.of(context).colorScheme.primary,
                onSendMoney,
              ),
            ),
          ],
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
  ) {
    final direction = switch (filter.value) {
      1 => 'income',
      2 => 'outcome',
      _ => null,
    };
    
    final provider = transactionListProvider((walletId: wallet?.id, direction: direction, type: null));
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterTab(context, 'all'.tr(), 0, filter, ref, provider),
              const Gap(16),
              _buildFilterTab(context, 'income'.tr(), 1, filter, ref, provider),
              const Gap(16),
              _buildFilterTab(context, 'expense'.tr(), 2, filter, ref, provider),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Show all
                },
                child: Text('seeAll'.tr()),
              ),
            ],
          ),
        ),
        Expanded(
          child: PaginationList(
            padding: EdgeInsets.zero,
            provider: provider,
            notifier: provider.notifier,
            itemBuilder: (context, index, transaction) {
              final isIncome = wallet?.id == transaction.payeeWalletId;

              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (context) => TransactionDetailSheet(
                      transaction: transaction,
                      currentWalletId: wallet?.id,
                    ),
                  );
                },
                child: _buildTransactionItem(context, transaction, isIncome),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label,
    int value,
    ValueNotifier<int> filter,
    WidgetRef ref,
    dynamic provider,
  ) {
    final isSelected = filter.value == value;
    return GestureDetector(
      onTap: () {
        filter.value = value;
        ref.invalidate(provider);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    SnTransaction transaction,
    bool isIncome,
  ) {
    // Determine category and icon based on transaction type
    IconData categoryIcon;
    String categoryName;
    Color categoryColor;

    if (transaction.remarks?.toLowerCase().contains('food') ?? false) {
      categoryIcon = Symbols.restaurant;
      categoryName = 'food'.tr();
      categoryColor = Colors.orange;
    } else if (transaction.remarks?.toLowerCase().contains('shopping') ??
        false) {
      categoryIcon = Symbols.shopping_bag;
      categoryName = 'shopping'.tr();
      categoryColor = Colors.purple;
    } else if (transaction.remarks?.toLowerCase().contains('transport') ??
        false) {
      categoryIcon = Symbols.directions_car;
      categoryName = 'transport'.tr();
      categoryColor = Colors.blue;
    } else if (isIncome) {
      categoryIcon = Symbols.arrow_circle_down;
      categoryName = 'income'.tr();
      categoryColor = Colors.green;
    } else {
      categoryIcon = Symbols.payments;
      categoryName = 'payment'.tr();
      categoryColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 24),
          ),
          const Gap(12),
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                Text(
                  transaction.remarks ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isIncome ? '+' : '-'}${formatAmountWithSuffix(transaction.amount)} ${transaction.currency}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
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
                            '${formatAmountWithSuffix(fund.totalAmount)} ${fund.currency}',
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
                    Text(
                      '${'recipients'.tr()}: $claimedCount/$totalRecipients',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
    final client = ref.read(solarNetworkClientProvider);
    try {
      showLoadingModal(context);
      await client.dio.post('/wallet/wallets/transfer', data: transferData);

      if (context.mounted) hideLoadingModal(context);

      // Invalidate providers to refresh data
      ref.invalidate(transactionListProvider);
      ref.invalidate(walletCurrentProvider);
      if (context.mounted) {
        showSnackBar('transferCreatedSuccessfully'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
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
                        '${formatAmountWithSuffix(pocket.amount)} ${pocket.currency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                                  '${formatAmountWithSuffix(wPocket.amount)} ${wPocket.currency}',
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
