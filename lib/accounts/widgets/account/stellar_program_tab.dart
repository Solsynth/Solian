import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/restore_purchase_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/payments/iap_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'stellar_program_tab.g.dart';

enum PaymentMethod { wallet, appleIap }

@riverpod
Future<SnWalletSubscription?> accountStellarSubscription(Ref ref) async {
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get(
      '/wallet/subscriptions/groups/solian.stellar/active',
    );
    return SnWalletSubscription.fromJson(resp.data);
  } catch (err) {
    return null;
  }
}

@riverpod
Future<List<SnWalletGift>> accountSentGifts(
  Ref ref, {
  int offset = 0,
  int take = 20,
}) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/wallet/subscriptions/gifts/sent?offset=$offset&take=$take',
  );
  return (resp.data as List).map((e) => SnWalletGift.fromJson(e)).toList();
}

@riverpod
Future<List<SnWalletGift>> accountReceivedGifts(
  Ref ref, {
  int offset = 0,
  int take = 20,
}) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/wallet/subscriptions/gifts/received?offset=$offset&take=$take',
  );
  return (resp.data as List).map((e) => SnWalletGift.fromJson(e)).toList();
}

@riverpod
Future<SnWalletGift> accountGift(Ref ref, String giftId) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/wallet/subscriptions/gifts/$giftId');
  return SnWalletGift.fromJson(resp.data);
}

@riverpod
Future<SnSubscriptionGroup?> accountSubscriptionGroup(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/wallet/subscriptions/groups/solian.stellar');
  return SnSubscriptionGroup.fromJson(resp.data);
}

class PurchaseGiftSheet extends StatefulWidget {
  const PurchaseGiftSheet({super.key});

  @override
  State<PurchaseGiftSheet> createState() => _PurchaseGiftSheetState();
}

class _PurchaseGiftSheetState extends State<PurchaseGiftSheet> {
  SnAccount? selectedRecipient;
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'purchaseGift'.tr(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Recipient Selection Section
                  Text(
                    'selectRecipient'.tr(),
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
                    child: selectedRecipient != null
                        ? ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 20,
                              right: 12,
                            ),
                            leading: ProfilePictureWidget(
                              file: selectedRecipient!.profile.picture,
                            ),
                            title: Text(
                              selectedRecipient!.nick,
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
                              onPressed: () =>
                                  setState(() => selectedRecipient = null),
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Clear selection',
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
                                'noRecipientSelected'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Gap(4),
                              Text(
                                'thisWillBeAnOpenGift'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
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
                      if (recipient != null) {
                        setState(() => selectedRecipient = recipient);
                      }
                    },
                    icon: const Icon(Icons.person_search),
                    label: Text(
                      selectedRecipient != null
                          ? 'changeRecipient'.tr()
                          : 'selectRecipient'.tr(),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const Gap(24),

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
                      hintText: 'addPersonalMessageForRecipient'.tr(),
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
                    onPressed: () =>
                        Navigator.of(context).pop(<String, dynamic>{
                          'recipient': null,
                          'message': messageController.text.trim().isEmpty
                              ? null
                              : messageController.text.trim(),
                        }),
                    child: Text('skipRecipient'.tr()),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(<String, dynamic>{
                          'recipient': selectedRecipient,
                          'message': messageController.text.trim().isEmpty
                              ? null
                              : messageController.text.trim(),
                        }),
                    child: Text('purchaseGift'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StellarProgramTab extends HookConsumerWidget {
  const StellarProgramTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stellarSubscription = ref.watch(accountStellarSubscriptionProvider);
    final paymentMethod = useState(PaymentMethod.wallet);
    final iapProducts = useState<Map<String, String>>({});
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    if (paymentMethod.value == PaymentMethod.appleIap &&
        iapProducts.value.isEmpty &&
        groupAsync.hasValue) {
      final group = groupAsync.value!;
      final appleProductIds = group.catalog.items
          .expand((c) => c.providerMappings.appleStore)
          .toSet();

      if (appleProductIds.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final iapService = ref.read(iapServiceProvider);
          await iapService.initialize();
          await iapService.loadProducts(appleProductIds);
          final products = <String, String>{};
          for (final product in iapService.products) {
            products[product.id] = product.price;
          }
          iapProducts.value = products;
        });
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMembershipSection(
            context,
            ref,
            stellarSubscription,
            paymentMethod,
            iapProducts,
          ),
          const Gap(16),
          _buildGiftingSection(context, ref),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildMembershipSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<SnWalletSubscription?> stellarSubscriptionAsync,
    ValueNotifier<PaymentMethod> paymentMethod,
    ValueNotifier<Map<String, String>> iapProducts,
  ) {
    return stellarSubscriptionAsync.when(
      data: (membership) => _buildMembershipContent(
        context,
        ref,
        membership,
        paymentMethod,
        iapProducts,
      ),
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Error loading membership: $error'),
      ),
    );
  }

  Widget _buildMembershipContent(
    BuildContext context,
    WidgetRef ref,
    SnWalletSubscription? membership,
    ValueNotifier<PaymentMethod> paymentMethod,
    ValueNotifier<Map<String, String>> iapProducts,
  ) {
    final isActive = membership?.isActive ?? false;
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
    final supportsWallet =
        groupAsync.hasValue &&
        groupAsync.value!.catalog.items.any(
          (c) => c.allowedPaymentMethods.contains('solian.wallet'),
        );
    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    Future<void> membershipCancel() async {
      if (!isActive || membership == null) return;

      final confirm = await showConfirmAlert(
        'membershipCancelHint'.tr(),
        'membershipCancelConfirm'.tr(),
      );
      if (!confirm || !context.mounted) return;

      try {
        showLoadingModal(context);
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/wallet/subscriptions/${membership.identifier}/cancel',
        );
        ref.invalidate(accountStellarSubscriptionProvider);
        ref.read(userInfoProvider.notifier).fetchUser();
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar('membershipCancelSuccess'.tr());
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.star_rounded : Icons.star_border_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const Gap(8),
              Text(
                'stellarMembership'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(12),

          if (isActive) ...[
            _buildCurrentMembershipCard(context, membership!),
            const Gap(12),
            FilledButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.error,
                ),
                foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onError,
                ),
              ),
              onPressed: membershipCancel,
              icon: const Icon(Symbols.cancel),
              label: Text('membershipCancel'.tr()),
            ),
            const Gap(12),
          ],

          Text(
            'chooseYourPlan'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(12),

          if (supportsWallet && supportsIap) ...[
            _buildPaymentMethodTabs(context, paymentMethod),
            const Gap(12),
          ],

          _buildMembershipTiers(
            context,
            ref,
            membership,
            paymentMethod,
            iapProducts,
          ),

          // Restore Purchase Button
          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
            OutlinedButton.icon(
              onPressed: () => _restorePurchaseIap(context, ref),
              icon: const Icon(Icons.restore),
              label: Text('restorePurchase'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ).padding(top: 12)
          else
            OutlinedButton.icon(
              onPressed: () => _showRestorePurchaseSheet(context, ref),
              icon: const Icon(Icons.restore),
              label: Text('restorePurchase'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ).padding(top: 12),
        ],
      ).padding(all: 16),
    );
  }

  Widget _buildCurrentMembershipCard(
    BuildContext context,
    SnWalletSubscription membership,
  ) {
    final tierName = _getMembershipTierName(membership.identifier);
    final tierColor = _getMembershipTierColor(context, membership.identifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tierColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: tierColor, size: 20),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'currentMembership'.tr(args: [tierName]),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tierColor,
                  ),
                ),
                if (membership.endedAt != null)
                  Text(
                    'membershipExpires'.tr(
                      args: [membership.endedAt!.formatSystem()],
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTabs(
    BuildContext context,
    ValueNotifier<PaymentMethod> paymentMethod,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => paymentMethod.value = PaymentMethod.wallet,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: paymentMethod.value == PaymentMethod.wallet
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'walletExchange'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: paymentMethod.value == PaymentMethod.wallet
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => paymentMethod.value = PaymentMethod.appleIap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: paymentMethod.value == PaymentMethod.appleIap
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'appleIap'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: paymentMethod.value == PaymentMethod.appleIap
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTiers(
    BuildContext context,
    WidgetRef ref,
    SnWalletSubscription? currentMembership,
    ValueNotifier<PaymentMethod> paymentMethod,
    ValueNotifier<Map<String, String>> iapProducts,
  ) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }
        final tiers = group.catalog.items.toList()
          ..sort((a, b) => a.perkLevel.compareTo(b.perkLevel));

        if (tiers.isEmpty) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final tierWidgets = <Widget>[];
        for (final tier in tiers) {
          final isCurrentTier =
              currentMembership?.identifier == tier.identifier;
          final tierColor = _parseColor(tier.displayConfig?.color);

          final supportsWallet = tier.allowedPaymentMethods.contains(
            'solian.wallet',
          );
          final supportsIap = tier.allowedPaymentMethods.contains(
            'apple_store',
          );
          final selectedMethod = paymentMethod.value;
          final isSupported =
              (selectedMethod == PaymentMethod.wallet && supportsWallet) ||
              (selectedMethod == PaymentMethod.appleIap && supportsIap);

          String priceDisplay;
          if (selectedMethod == PaymentMethod.appleIap &&
              tier.providerMappings.appleStore.isNotEmpty) {
            final productId = tier.providerMappings.appleStore.first;
            final applePrice = iapProducts.value[productId] ?? '...';
            priceDisplay = '$applePrice/month';
          } else {
            priceDisplay = '${tier.basePrice} ${tier.currency}/month';
          }

          tierWidgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isCurrentTier || !isSupported
                      ? null
                      : () => _purchaseMembership(
                          context,
                          ref,
                          tier,
                          selectedMethod,
                        ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentTier
                          ? tierColor.withOpacity(0.1)
                          : !isSupported
                          ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentTier
                            ? tierColor
                            : !isSupported
                            ? Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                        width: isCurrentTier ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tierColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Text(
                                    tier.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentTier ? tierColor : null,
                                    ),
                                  ),
                                  if (isCurrentTier)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tierColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'membershipCurrentBadge'.tr(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (!isSupported)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'paymentMethodNotSupported'.tr(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                priceDisplay,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (!isCurrentTier)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(children: tierWidgets);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading tiers: $error')),
    );
  }

  String _getMembershipTierName(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return 'membershipTierStellar'.tr();
      case 'solian.stellar.nova':
        return 'membershipTierNova'.tr();
      case 'solian.stellar.supernova':
        return 'membershipTierSupernova'.tr();
      default:
        return 'membershipTierUnknown'.tr();
    }
  }

  Color _getMembershipTierColor(BuildContext context, String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return Colors.blue;
      case 'solian.stellar.nova':
        return Colors.purple;
      case 'solian.stellar.supernova':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue;
    }
    try {
      if (colorString.startsWith('#')) {
        final hexColor = colorString.substring(1);
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  Future<void> _showRestorePurchaseSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => const RestorePurchaseSheet(),
    );
  }

  Future<void> _restorePurchaseIap(BuildContext context, WidgetRef ref) async {
    final iapService = ref.read(iapServiceProvider);
    final client = ref.read(apiClientProvider);
    final userAsync = ref.read(userInfoProvider);

    try {
      showLoadingModal(context);

      if (userAsync.hasValue && userAsync.value != null) {
        iapService.setUserId(userAsync.value!.id);
      }

      await iapService.initialize();
      if (!iapService.isAvailable) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert('IAP is not available on this platform');
        }
        return;
      }

      final restoredProductIds = <String>[];

      final subscription = iapService.purchaseResultStream.listen((
        result,
      ) async {
        if (result.isRestored && result.signedTransactionInfo != null) {
          restoredProductIds.add(result.productId ?? '');

          try {
            await client.post(
              '/wallet/subscriptions/order/restore/apple',
              data: {'signed_transaction_info': result.signedTransactionInfo},
            );
          } catch (e) {
            debugPrint('Failed to restore purchase: $e');
          }
        } else if (!result.success && result.error != null) {
          if (context.mounted) {
            showSnackBar(result.error!);
          }
        }
      });

      await iapService.restorePurchases();

      await Future.delayed(const Duration(seconds: 3));

      await subscription.cancel();

      ref.invalidate(accountStellarSubscriptionProvider);
      ref.read(userInfoProvider.notifier).fetchUser();

      if (context.mounted) {
        hideLoadingModal(context);
        if (restoredProductIds.isNotEmpty) {
          showSnackBar('membershipRestoreSuccess'.tr());
        } else {
          showSnackBar('noPurchasesToRestore'.tr());
        }
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }

  Future<void> _purchaseMembership(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionCatalog tier,
    PaymentMethod paymentMethod,
  ) async {
    if (paymentMethod == PaymentMethod.appleIap) {
      final appleStoreProductIds = tier.providerMappings.appleStore;
      if (appleStoreProductIds.isNotEmpty) {
        await _purchaseWithIap(context, ref, tier, appleStoreProductIds.first);
        return;
      }
    }

    await _purchaseWithWallet(context, ref, tier.identifier);
  }

  Future<void> _purchaseWithIap(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionCatalog tier,
    String productId,
  ) async {
    final iapService = ref.read(iapServiceProvider);
    final userAsync = ref.read(userInfoProvider);

    try {
      showLoadingModal(context);

      if (userAsync.hasValue && userAsync.value != null) {
        iapService.setUserId(userAsync.value!.id);
      }

      await iapService.initialize();
      if (!iapService.isAvailable) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert('IAP is not available on this platform');
        }
        return;
      }

      final loaded = await iapService.loadProducts({productId});
      if (!loaded) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert('Failed to load products');
        }
        return;
      }

      final result = await iapService.purchaseProduct(productId);

      if (context.mounted) hideLoadingModal(context);

      if (result == null) {
        showSnackBar('Purchase has been cancelled.');
      } else if (result.error != null) {
        showErrorAlert(result.error);
      } else if (result.success) {
        // Wait for a while to let the backend process the purchase and update the subscription status
        showSnackBar('坐与放宽，我们正在处理您的购买...');
        await Future.delayed(const Duration(seconds: 2));
        // Invalidate subscription to refresh status
        ref.invalidate(accountStellarSubscriptionProvider);
        ref.read(userInfoProvider.notifier).fetchUser();
        if (context.mounted) {
          showSnackBar('membershipPurchaseSuccess'.tr());
        }
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }

  Future<void> _purchaseWithWallet(
    BuildContext context,
    WidgetRef ref,
    String tierId,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.post(
        '/wallet/subscriptions',
        data: {
          'identifier': tierId,
          'payment_method': 'solian.wallet',
          'payment_details': {'currency': 'golds'},
          'cycle_duration_days': 30,
        },
        options: Options(headers: {'X-Noop': true}),
      );
      final subscription = SnWalletSubscription.fromJson(resp.data);
      if (subscription.status == 1) return;
      final orderResp = await client.post(
        '/wallet/subscriptions/${subscription.identifier}/order',
      );
      final order = SnWalletOrder.fromJson(orderResp.data);

      if (context.mounted) hideLoadingModal(context);

      if (!context.mounted) return;
      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        enableBiometric: true,
      );

      if (context.mounted) showLoadingModal(context);

      if (paidOrder != null) {
        await Future.delayed(const Duration(seconds: 1));
        ref.invalidate(accountStellarSubscriptionProvider);
        ref.read(userInfoProvider.notifier).fetchUser();
        if (context.mounted) {
          showSnackBar('membershipPurchaseSuccess'.tr());
        }
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Widget _buildGiftingSection(BuildContext context, WidgetRef ref) {
    final sentGifts = ref.watch(accountSentGiftsProvider());
    final receivedGifts = ref.watch(accountReceivedGiftsProvider());

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const Gap(8),
              Text(
                'giftSubscriptions'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(12),

          // Purchase Gift Section
          Text(
            'purchaseAGift'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          _buildGiftPurchaseOptions(context, ref),
          const Gap(16),

          // Redeem Gift Section
          Text(
            'redeemAGift'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          _buildGiftRedeemSection(context, ref),
          const Gap(16),

          // Gift History
          Text(
            'giftHistory'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          _buildGiftHistory(context, ref, sentGifts, receivedGifts),
        ],
      ).padding(all: 16),
    );
  }

  Widget _buildGiftPurchaseOptions(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }
        final tiers = group.catalog.items.toList()
          ..sort((a, b) => a.perkLevel.compareTo(b.perkLevel));

        if (tiers.isEmpty) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final tierWidgets = <Widget>[];
        for (final tier in tiers) {
          final tierColor = _parseColor(tier.displayConfig?.color);

          tierWidgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showPurchaseGiftDialog(context, ref, tier.identifier),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tierColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tier.displayName} Gift',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${tier.basePrice} ${tier.currency}/month',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(children: tierWidgets);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading gift options: $error')),
    );
  }

  Widget _buildGiftRedeemSection(BuildContext context, WidgetRef ref) {
    final codeController = useTextEditingController();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'enterGiftCodeToRedeem'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(8),
          TextField(
            controller: codeController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'enterGiftCode'.tr(),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.redeem),
                onPressed: () =>
                    _redeemGift(context, ref, codeController.text.trim()),
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onSubmitted: (code) => _redeemGift(context, ref, code.trim()),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SnWalletGift>> sentGifts,
    AsyncValue<List<SnWalletGift>> receivedGifts,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                _showGiftHistorySheet(context, ref, sentGifts, true),
            child: Text('sentGifts'.tr()),
          ),
        ),
        const Gap(8),
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                _showGiftHistorySheet(context, ref, receivedGifts, false),
            child: Text('receivedGifts'.tr()),
          ),
        ),
      ],
    );
  }

  Future<void> _showGiftHistorySheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SnWalletGift>> giftsAsync,
    bool isSent,
  ) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: context,
      builder: (context) => SheetScaffold(
        titleText: isSent ? 'sentGifts'.tr() : 'receivedGifts'.tr(),
        child: giftsAsync.when(
          data: (gifts) => gifts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isSent ? 'noSentGifts'.tr() : 'noReceivedGifts'.tr(),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) =>
                      _buildGiftItem(context, ref, gifts[index], isSent),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildGiftItem(
    BuildContext context,
    WidgetRef ref,
    SnWalletGift gift,
    bool isSent,
  ) {
    final statusText = _getGiftStatusText(gift.status);
    final statusColor = _getGiftStatusColor(context, gift.status);
    final canCancel = isSent && (gift.status == 0 || gift.status == 1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'codeLabel'.tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        gift.giftCode,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 6,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (gift.status == 2 && gift.redeemer != null)
                      AccountPfcRegion(
                        uname: gift.redeemer!.name,
                        child: ProfilePictureWidget(
                          file: gift.redeemer!.profile.picture,
                          radius: 8,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            '${'subscriptionLabel'.tr()} ${_getMembershipTierName(gift.subscriptionIdentifier)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (gift.recipient != null && isSent) ...[
            const Gap(4),
            Text(
              '${'toLabel'.tr()} ${gift.recipient!.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (gift.gifter != null && !isSent) ...[
            const Gap(4),
            Text(
              '${'fromLabel'.tr()} ${gift.gifter!.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (gift.message != null && gift.message!.isNotEmpty) ...[
            const Gap(4),
            Text(
              '${'messageLabel'.tr()} ${gift.message}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: gift.giftCode));
                  if (context.mounted) {
                    showSnackBar('giftCodeCopiedToClipboard'.tr());
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text('copy'.tr()),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (canCancel) ...[
                OutlinedButton.icon(
                  onPressed: () => _cancelGift(context, ref, gift),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: Text('cancel'.tr()),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getGiftStatusText(int status) {
    switch (status) {
      case 0:
        return 'giftStatusCreated'.tr();
      case 1:
        return 'giftStatusSent'.tr();
      case 2:
        return 'giftStatusRedeemed'.tr();
      case 3:
        return 'giftStatusCancelled'.tr();
      case 4:
        return 'giftStatusExpired'.tr();
      default:
        return 'giftStatusUnknown'.tr();
    }
  }

  Color _getGiftStatusColor(BuildContext context, int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _showPurchaseGiftDialog(
    BuildContext context,
    WidgetRef ref,
    String subscriptionId,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      isScrollControlled: true,
      useRootNavigator: true,
      context: context,
      builder: (context) => const PurchaseGiftSheet(),
    );

    if (result != null && context.mounted) {
      final recipient = result['recipient'] as SnAccount?;
      final message = result['message'] as String?;
      await _purchaseGift(context, ref, subscriptionId, recipient?.id, message);
    }
  }

  Future<void> _purchaseGift(
    BuildContext context,
    WidgetRef ref,
    String subscriptionId,
    String? recipientId,
    String? message,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.post(
        '/wallet/subscriptions/gifts/purchase',
        data: {
          'subscription_identifier': subscriptionId,
          'recipient_id': ?recipientId,
          'payment_method': 'solian.wallet',
          'payment_details': {'currency': 'golds'},
          'message': ?message,
          'gift_duration_days': 30,
          'subscription_duration_days': 30,
        },
        options: Options(headers: {'X-Noop': true}),
      );
      final gift = SnWalletGift.fromJson(resp.data);
      if (gift.status == 1) return; // Already paid

      final orderResp = await client.post(
        '/wallet/subscriptions/gifts/${gift.id}/order',
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

        // Get the updated gift
        final giftResp = await client.get(
          '/wallet/subscriptions/gifts/${gift.id}',
        );
        final updatedGift = SnWalletGift.fromJson(giftResp.data);

        if (context.mounted) hideLoadingModal(context);

        // Show gift code bottom sheet
        if (context.mounted) {
          await showModalBottomSheet(
            context: context,
            builder: (context) => SheetScaffold(
              titleText: 'giftPurchased'.tr(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              updatedGift.giftCode,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: updatedGift.giftCode),
                              );
                              if (context.mounted) {
                                showSnackBar('giftCodeCopiedToClipboard'.tr());
                              }
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'copyGiftCode'.tr(),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'shareCodeWithRecipient'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (updatedGift.recipientId == null) ...[
                      const Gap(8),
                      Text(
                        'openGiftAnyoneCanRedeem'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Gap(24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('ok'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }

      ref.invalidate(accountSentGiftsProvider);
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _redeemGift(
    BuildContext context,
    WidgetRef ref,
    String giftCode,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);

      // First check if gift can be redeemed
      final checkResp = await client.get(
        '/wallet/subscriptions/gifts/check/$giftCode',
      );
      final checkData = checkResp.data as Map<String, dynamic>;

      if (!checkData['can_redeem']) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(checkData['error'] ?? 'Gift cannot be redeemed');
        return;
      }

      // Redeem the gift
      await client.post(
        '/wallet/subscriptions/gifts/redeem',
        data: {'gift_code': giftCode},
      );

      if (context.mounted) {
        hideLoadingModal(context);
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('giftRedeemed'.tr()),
            content: Text('giftRedeemedSuccessfully'.tr()),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'.tr()),
              ),
            ],
          ),
        );
      }

      ref.invalidate(accountReceivedGiftsProvider);
      ref.invalidate(accountStellarSubscriptionProvider);
      ref.read(userInfoProvider.notifier).fetchUser();
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  Future<void> _cancelGift(
    BuildContext context,
    WidgetRef ref,
    SnWalletGift gift,
  ) async {
    final confirm = await showConfirmAlert(
      'cancelGift'.tr(),
      'cancelGiftConfirm'.tr(),
    );
    if (!confirm || !context.mounted) return;

    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      await client.post('/wallet/subscriptions/gifts/${gift.id}/cancel');
      ref.invalidate(accountSentGiftsProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('giftCancelledSuccessfully'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }
}
