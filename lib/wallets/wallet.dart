import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'wallet.g.dart';

@riverpod
Future<SnWallet?> walletCurrent(Ref ref) async {
  try {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get('/wallet/wallets');
    return SnWallet.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnWalletStats> walletStats(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/wallet/wallets/stats');
  return SnWalletStats.fromJson(resp.data);
}

class CreateFundSheet extends StatefulWidget {
  const CreateFundSheet({super.key});

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
                  // Amount Section
                  Text(
                    'fundAmount'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
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
                      labelText: 'enterAmount'.tr(),
                      hintText: '0.00',
                      prefixIcon: Icon(kCurrencyIconData[selectedCurrency]),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),

                  const Gap(16),

                  // Currency Selection
                  Text(
                    'selectCurrency'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                    items: kCurrencyIconData.keys.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Row(
                          children: [
                            Icon(kCurrencyIconData[currency]),
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

                  const Gap(16),

                  // Amount of Splits Section
                  Text(
                    'amountOfSplits'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  TextField(
                    controller: splitsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'enterNumberOfSplits'.tr(),
                      hintText: selectedRecipients.isNotEmpty
                          ? selectedRecipients.length.toString()
                          : '1',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
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

                  const Gap(16),
                  Text(
                    'splitType'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: Text('evenSplit'.tr()),
                          subtitle: Text('equalAmountEach'.tr()),
                          value: 0,
                          groupValue: selectedSplitType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedSplitType = value);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: Text('randomSplit'.tr()),
                          subtitle: Text('randomAmountEach'.tr()),
                          value: 1,
                          groupValue: selectedSplitType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedSplitType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const Gap(16),

                  // Recipient Selection Section
                  Text(
                    'selectRecipients'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: selectedRecipients.isNotEmpty
                        ? Column(
                            children: [
                              ...selectedRecipients.map((recipient) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 20,
                                    right: 12,
                                  ),
                                  leading: ProfilePictureWidget(
                                    file: recipient.profile.picture,
                                  ),
                                  title: Text(
                                    recipient.nick,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'selectedRecipient'.tr(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          selectedRecipients.remove(recipient),
                                    ),
                                    icon: Icon(
                                      Icons.clear,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    tooltip: 'Remove recipient',
                                  ),
                                );
                              }),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const Gap(8),
                              Text(
                                'noRecipientsSelected'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Gap(4),
                              Text(
                                'selectRecipientsToSendFund'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ).padding(vertical: 32),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final recipient = await showModalBottomSheet<SnAccount>(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) => const AccountPickerSheet(),
                      );
                      if (recipient != null &&
                          !selectedRecipients.contains(recipient)) {
                        setState(() => selectedRecipients.add(recipient));
                      }
                    },
                    icon: const Icon(Icons.person_search),
                    label: Text(
                      selectedRecipients.isNotEmpty
                          ? 'addMoreRecipients'.tr()
                          : 'selectRecipients'.tr(),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const Gap(16),

                  // Message Section
                  Text(
                    'addMessage'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'personalMessage'.tr(),
                      hintText: 'addPersonalMessageForRecipients'.tr(),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
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
                        OtpTextField(
                          numberOfFields: 6,
                          borderColor: Theme.of(context).colorScheme.outline,
                          focusedBorderColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          showFieldAsBox: true,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          fieldWidth: 48,
                          fieldHeight: 56,
                          borderRadius: BorderRadius.circular(8),
                          borderWidth: 1,
                          textStyle: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          onSubmit: (pin) {
                            enteredPin = pin;
                            Navigator.of(context).pop(pin);
                          },
                          onCodeChanged: (String code) {
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
      'pin_code': '', // Will be filled by PIN verification
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
  const CreateTransferSheet({super.key});

  @override
  State<CreateTransferSheet> createState() => _CreateTransferSheetState();
}

class _CreateTransferSheetState extends State<CreateTransferSheet> {
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  String selectedCurrency = 'golds';
  SnAccount? selectedPayee;

  @override
  void dispose() {
    amountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Amount Section
                  Text(
                    'transferAmount'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
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
                      labelText: 'enterAmount'.tr(),
                      hintText: '0.00',
                      prefixIcon: Icon(kCurrencyIconData[selectedCurrency]),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),

                  const Gap(16),

                  // Currency Selection
                  Text(
                    'selectCurrency'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                    items: kCurrencyIconData.keys.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Row(
                          children: [
                            Icon(kCurrencyIconData[currency]),
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

                  const Gap(16),

                  // Payee Selection Section
                  Text(
                    'selectPayee'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: selectedPayee != null
                        ? ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 20,
                              right: 12,
                            ),
                            leading: ProfilePictureWidget(
                              file: selectedPayee!.profile.picture,
                            ),
                            title: Text(
                              selectedPayee!.nick,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'selectedPayee'.tr(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  setState(() => selectedPayee = null),
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Remove payee',
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const Gap(8),
                              Text(
                                'noPayeeSelected'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Gap(4),
                              Text(
                                'selectPayeeToTransfer'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ).padding(vertical: 32),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final payee = await showModalBottomSheet<SnAccount>(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) => const AccountPickerSheet(),
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

                  const Gap(16),

                  // Remark Section
                  Text(
                    'addRemark'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: 'transferRemark'.tr(),
                      hintText: 'addRemarkForTransfer'.tr(),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
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
                        OtpTextField(
                          numberOfFields: 6,
                          borderColor: Theme.of(context).colorScheme.outline,
                          focusedBorderColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          showFieldAsBox: true,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          fieldWidth: 48,
                          fieldHeight: 56,
                          borderRadius: BorderRadius.circular(8),
                          borderWidth: 1,
                          textStyle: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          onSubmit: (pin) {
                            enteredPin = pin;
                            Navigator.of(context).pop(pin);
                          },
                          onCodeChanged: (String code) {
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

    if (selectedPayee == null) {
      showErrorAlert('noPayeeSelected'.tr());
      return;
    }

    final data = {
      'amount': amount,
      'currency': selectedCurrency,
      'payee_account_id': selectedPayee!.id,
      'remark': remarkController.text.trim().isEmpty
          ? null
          : remarkController.text.trim(),
    };

    // Ask for PIN confirmation before creating transfer
    final enteredPin = await _showPinVerificationDialog(context);
    if (enteredPin == null || enteredPin.isEmpty) return;

    // Add PIN to the transfer data
    data['pin_code'] = enteredPin;

    if (mounted) Navigator.of(context).pop(data);
  }
}

final transactionListProvider = AsyncNotifierProvider.autoDispose(
  TransactionListNotifier.new,
);

class TransactionListNotifier
    extends AsyncNotifier<PaginationState<SnTransaction>>
    with AsyncPaginationController<SnTransaction> {
  static const int pageSize = 20;

  @override
  Future<List<SnTransaction>> fetch() async {
    final client = ref.read(apiClientProvider);
    final offset = fetchedCount;

    final queryParams = {'offset': offset, 'take': pageSize};

    final response = await client.get(
      '/wallet/wallets/transactions',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final transactions = data
        .map((json) => SnTransaction.fromJson(json))
        .toList();

    return transactions;
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
    final client = ref.read(apiClientProvider);
    final offset = fetchedCount;

    final response = await client.get(
      '/wallet/wallets/funds?offset=$offset&take=$pageSize',
    );
    // Assuming total count header is present or we just check if list is empty
    final list = (response.data as List)
        .map((e) => SnWalletFund.fromJson(e))
        .toList();
    if (list.length < pageSize) {
      totalCount = fetchedCount + list.length;
    }
    return list;
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
    final client = ref.read(apiClientProvider);
    final offset = fetchedCount;

    final response = await client.get(
      '/wallet/wallets/funds/recipients?offset=$offset&take=$_pageSize',
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
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/wallet/wallets/funds/$fundId');
  return SnWalletFund.fromJson(resp.data);
}

class TransactionDetailSheet extends StatelessWidget {
  final SnTransaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome =
        transaction.payeeWalletId == null ||
        transaction.payeeWallet?.accountId == null;

    return SheetScaffold(
      titleText: 'transactionDetails'.tr(),
      heightFactor: 0.75,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Text(
              'amount'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(4),
            Text(
              '${formatAmountWithSuffix(transaction.amount)} ${transaction.currency}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const Gap(16),

            // Remarks
            if (transaction.remarks != null &&
                transaction.remarks!.isNotEmpty) ...[
              Text(
                'remarks'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Gap(4),
              Text(
                transaction.remarks!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Gap(16),
            ],

            // Date
            Text(
              'date'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(4),
            Text(
              DateFormat.yMd().add_Hm().format(transaction.createdAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),

            // Payer
            Text(
              'payer'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(4),
            AccountPfcRegion(
              uname: transaction.payerWallet?.account?.name,
              child: Row(
                spacing: 8,
                children: [
                  if (transaction.payerWallet?.account != null)
                    ProfilePictureWidget(
                      file: transaction.payerWallet!.account!.profile.picture,
                      radius: 12,
                    ),
                  Text(
                    transaction.payerWallet?.account?.nick ??
                        'systemWallet'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Payee
            Text(
              'payee'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(4),
            AccountPfcRegion(
              uname: transaction.payeeWallet?.account?.name,
              child: Row(
                spacing: 8,
                children: [
                  if (transaction.payeeWallet?.account != null)
                    ProfilePictureWidget(
                      file: transaction.payeeWallet!.account!.profile.picture,
                      radius: 12,
                    ),
                  Text(
                    transaction.payeeWallet?.account?.nick ??
                        'systemWallet'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Transaction Type
            Text(
              'transactionType'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(4),
            Text(
              _getTransactionTypeText(transaction.type),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTypeText(int type) {
    // Assuming types: 0: transfer, 1: payment, etc. Adjust based on actual types
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

@RoutePage()
class WalletScreen extends HookConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletCurrentProvider);
    final tabController = useTabController(initialLength: 2);
    final currentTabIndex = useState(0);
    final selectedCurrency = useState<String>('points');
    final isBalanceVisible = useState<bool>(true);
    final transactionFilter = useState<int>(0); // 0: All, 1: Income, 2: Expense

    useEffect(() {
      void listener() {
        currentTabIndex.value = tabController.index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    Future<void> createWallet() async {
      final client = ref.read(apiClientProvider);
      try {
        await client.post('/wallet/wallets');
        ref.invalidate(walletCurrentProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> createFund() async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const CreateFundSheet(),
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
        builder: (context) => const CreateTransferSheet(),
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
        leading: const PageBackButton(backTo: '/account'),
      ),
      body: wallet.when(
        data: (data) {
          if (data == null) {
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

          final allPockets = getAllCurrencies(data.pockets);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // Balance Card with Currency Dropdown
              SliverToBoxAdapter(
                child: _buildBalanceCard(
                  context,
                  allPockets,
                  selectedCurrency,
                  isBalanceVisible,
                ).padding(horizontal: 16, top: 16, bottom: 12),
              ),

              // Quick Action Buttons
              SliverToBoxAdapter(
                child: _buildQuickActionsGrid(
                  context,
                  createTransfer,
                  createFund,
                ).padding(horizontal: 16, bottom: 8),
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
                // Transactions Tab with Filter
                _buildTransactionsList(context, ref, wallet, transactionFilter),

                // My Funds Tab
                _buildFundsList(context, ref),
              ],
            ),
          );
        },
        error: (error, stackTrace) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(walletCurrentProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    List<SnWalletPocket> pockets,
    ValueNotifier<String> selectedCurrency,
    ValueNotifier<bool> isBalanceVisible,
  ) {
    final selectedPocket = pockets.firstWhere(
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withBlue(200),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Label and Currency Dropdown
            Text(
              'balance'.tr(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Balance Amount
            Row(
              children: [
                Text(
                  '${isBalanceVisible.value ? formatAmountWithSuffix(selectedPocket.amount) : '••••••'} ${'walletCurrencyShort${selectedPocket.currency[0].toUpperCase()}${selectedPocket.currency.substring(1).toLowerCase()}'.tr()}',
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
                const Gap(8),
                IconButton(
                  icon: Icon(
                    isBalanceVisible.value
                        ? Symbols.visibility
                        : Symbols.visibility_off,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  onPressed: () {
                    isBalanceVisible.value = !isBalanceVisible.value;
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCurrency.value,
                      icon: Icon(
                        Symbols.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: const TextStyle(color: Colors.white),
                      items: pockets.map((pocket) {
                        return DropdownMenuItem(
                          value: pocket.currency,
                          child: Row(
                            children: [
                              Icon(
                                kCurrencyIconData[pocket.currency] ??
                                    Symbols.universal_currency_alt,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 2,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                'walletCurrency${pocket.currency[0].toUpperCase()}${pocket.currency.substring(1).toLowerCase()}'
                                    .tr(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ).padding(right: 4),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedCurrency.value = value;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<SnWallet?> wallet,
    ValueNotifier<int> filter,
  ) {
    return Column(
      children: [
        // Filter Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterTab(context, 'all'.tr(), 0, filter),
              const Gap(16),
              _buildFilterTab(context, 'income'.tr(), 1, filter),
              const Gap(16),
              _buildFilterTab(context, 'expense'.tr(), 2, filter),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Show all transactions
                },
                child: Text('seeAll'.tr()),
              ),
            ],
          ),
        ),
        // Transactions List
        Expanded(
          child: PaginationList(
            padding: EdgeInsets.zero,
            provider: transactionListProvider,
            notifier: transactionListProvider.notifier,
            itemBuilder: (context, index, transaction) {
              final isIncome = transaction.payeeWalletId == wallet.value?.id;

              // Apply filter
              if (filter.value == 1 && !isIncome) {
                return const SizedBox.shrink();
              }
              if (filter.value == 2 && isIncome) return const SizedBox.shrink();

              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (context) =>
                        TransactionDetailSheet(transaction: transaction),
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
  ) {
    final isSelected = filter.value == value;
    return GestureDetector(
      onTap: () => filter.value = value,
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
                            style: TextStyle(
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
    final client = ref.read(apiClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.post(
        '/wallet/wallets/funds',
        data: fundData,
        options: Options(headers: {'X-Noop': true}),
      );
      final fund = SnWalletFund.fromJson(resp.data);
      if (fund.status == 0) return; // Already created

      final orderResp = await client.post(
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
    final client = ref.read(apiClientProvider);
    try {
      showLoadingModal(context);
      await client.post('/wallet/wallets/transfer', data: transferData);

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
}

const Map<String, IconData> kCurrencyIconData = {
  'points': Symbols.save,
  'golds': Symbols.account_balance,
};

/// Formats a number with k (thousand) or m (million) suffix if >= 1000
/// e.g., 1500 -> "1.50k", 1500000 -> "1.50m"
String formatAmountWithSuffix(double amount) {
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(2)}m';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(2)}k';
  } else {
    return amount.toStringAsFixed(2);
  }
}
