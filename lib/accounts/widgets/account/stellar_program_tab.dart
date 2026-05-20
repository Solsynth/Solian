import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/restore_purchase_sheet.dart';
import 'package:island/accounts/widgets/account/stellar_benefits_table.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
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
import 'package:url_launcher/url_launcher_string.dart';

part 'stellar_program_tab.g.dart';

const kDebugShowAfdian = false;

enum PaymentMethodTab { wallet, appleIap, afdian }

final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);

class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int value) {
    state = value;
  }
}

final iapProductsProvider =
    NotifierProvider<IapProductsNotifier, Map<String, String>>(
      IapProductsNotifier.new,
    );

class IapProductsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setProducts(Map<String, String> products) {
    state = products;
  }
}

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
    final tabController = useTabController(initialLength: 2);
    final stellarSubscription = ref.watch(accountStellarSubscriptionProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final iapProducts = ref.watch(iapProductsProvider);
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    final useAfdianCheckout =
        groupAsync.hasValue &&
        groupAsync.value!.catalog.items.any(
          (c) => c.allowedPaymentMethods.contains('afdian'),
        ) &&
        !supportsIap;
    final hasExternalCheckout = supportsIap || useAfdianCheckout;

    useEffect(() {
      if (!tabController.indexIsChanging &&
          tabController.index != selectedTab) {
        tabController.animateTo(selectedTab);
      }
      return;
    }, [selectedTab]);

    useEffect(() {
      void listener() {
        final newTab = tabController.index;
        if (ref.read(selectedTabProvider) != newTab) {
          ref.read(selectedTabProvider.notifier).setTab(newTab);
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    if (selectedTab == 0 &&
        supportsIap &&
        iapProducts.isEmpty &&
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
          ref.read(iapProductsProvider.notifier).setProducts(products);
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
            tabController,
            ref,
            stellarSubscription,
            selectedTab,
            iapProducts,
            useAfdianCheckout,
            hasExternalCheckout,
          ),
          const Gap(16),
          const StellarBenefitsTable(),
          const Gap(16),
          _buildSubscriptionQueueSummary(context, ref),
          const Gap(16),
          _buildGiftingSection(context, ref),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildMembershipSection(
    BuildContext context,
    TabController tabController,
    WidgetRef ref,
    AsyncValue<SnWalletSubscription?> stellarSubscriptionAsync,
    int selectedTab,
    Map<String, String> iapProducts,
    bool useAfdianCheckout,
    bool hasExternalCheckout,
  ) {
    return stellarSubscriptionAsync.when(
      data: (membership) => _buildMembershipContent(
        context,
        tabController,
        ref,
        membership,
        selectedTab,
        iapProducts,
        useAfdianCheckout,
        hasExternalCheckout,
      ),
      loading: () => _buildSectionCard(
        context,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => _buildSectionCard(
        context,
        child: Text('Error loading membership: $error'),
      ),
    );
  }

  Widget _buildMembershipContent(
    BuildContext context,
    TabController tabController,
    WidgetRef ref,
    SnWalletSubscription? membership,
    int selectedTab,
    Map<String, String> iapProducts,
    bool useAfdianCheckout,
    bool hasExternalCheckout,
  ) {
    final isActive = membership?.isActive ?? false;
    final isWalletSubscription = membership?.paymentMethod == 'solian.wallet';
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
    final supportsWallet =
        groupAsync.hasValue &&
        groupAsync.value!.catalog.items.any(
          (c) => c.allowedPaymentMethods.contains('solian.wallet'),
        );
    final group = groupAsync.value;
    final currentSubscription = group?.current?.subscription ?? membership;

    Future<void> membershipCancel() async {
      if (!isActive || currentSubscription == null) return;

      final confirm = await showConfirmAlert(
        'membershipCancelHint'.tr(),
        'membershipCancelConfirm'.tr(),
      );
      if (!confirm || !context.mounted) return;

      try {
        showLoadingModal(context);
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/wallet/subscriptions/${currentSubscription.id}/cancel',
        );
        await _refreshSubscriptionState(ref);
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar('membershipCancelSuccess'.tr());
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSectionCard(
      context,
      color: scheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isActive
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isActive
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'stellarMembership'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SheetScaffold(
                        titleText: 'About Stellar Program',
                        child: Column(
                          spacing: 12,
                          children: [
                            Text(
                              'Stellar Program allows your unlocks more personalization settings on the Solar Network. And most imporantly, it helps support the development of the Solian and the Solar Network!',
                            ),
                            Text(
                              'To learn more about the Stellar Program benefits, scroll the page to see the comparison table.',
                            ),
                          ],
                        ).padding(horizontal: 24, vertical: 16),
                      );
                    },
                  );
                },
                icon: const Icon(Symbols.help, size: 20),
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ],
          ),
          const Gap(12),

          if (isActive) ...[
            _buildCurrentMembershipCard(context, currentSubscription!),
            const Gap(12),
            if (isWalletSubscription)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                onPressed: membershipCancel,
                icon: const Icon(Symbols.cancel),
                label: Text('membershipCancel'.tr()),
              ),
            const Gap(12),
          ],

          _buildSectionHeader(
            context,
            title: 'chooseYourPlan'.tr(),
            subtitle: 'Every subscription lasts 30 days',
          ),
          const Gap(12),

          if (supportsWallet && hasExternalCheckout) ...[
            _buildPaymentMethodTabBar(
              context,
              tabController,
              ref,
              selectedTab,
              useAfdianCheckout,
            ),
            const Gap(12),
          ] else if (hasExternalCheckout && !supportsWallet) ...[
            _buildPaymentMethodTabBar(
              context,
              tabController,
              ref,
              selectedTab,
              useAfdianCheckout,
            ),
            const Gap(12),
          ],

          _buildMembershipTiers(
            context,
            tabController,
            ref,
            membership,
            selectedTab,
            iapProducts,
            useAfdianCheckout,
            hasExternalCheckout,
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
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Every subscription lasts 30 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                InkWell(
                  onTap: () => launchUrlString(
                    'https://solsynth.dev/terms/user-agreement',
                    mode: LaunchMode.externalApplication,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      'termsLink'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMembershipCard(
    BuildContext context,
    SnWalletSubscription membership,
  ) {
    final theme = Theme.of(context);
    final tierName = _getMembershipTierName(membership.identifier);
    final tierColor = _getMembershipTierColor(context, membership.identifier);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor.withOpacity(0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.verified_rounded, color: tierColor, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'currentMembership'.tr(args: [tierName]),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tierColor,
                  ),
                ),
                if (membership.endedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'membershipExpires'.tr(
                        args: [membership.endedAt!.formatSystem()],
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Text('This membership will not expire.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required Widget child,
    Color? color,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Card(
      color: color,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...switch (trailing) {
          final widget? => [widget],
          null => const <Widget>[],
        },
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    Widget? avatar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (avatar != null) ...[const Gap(6), avatar],
        ],
      ),
    );
  }

  Widget _buildSubscriptionQueueSection(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionGroup group,
  ) {
    final queuedSubscriptions =
        group.subscriptions
            .where(
              (item) =>
                  item.subscription.isPendingActivation ||
                  !item.subscription.isAvailable ||
                  item.subscription.begunAt.isAfter(DateTime.now()),
            )
            .toList()
          ..sort(
            (a, b) => a.subscription.begunAt.compareTo(b.subscription.begunAt),
          );

    if (queuedSubscriptions.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      context,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.schedule,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'subscriptionRecordsTitle'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'subscriptionRecordsSubtitle'.tr(
            args: [queuedSubscriptions.length.toString()],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _showSubscriptionQueueSheet(
          context,
          ref,
          group,
          queuedSubscriptions,
        ),
      ),
    );
  }

  Widget _buildSubscriptionQueueSummary(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) return const SizedBox.shrink();
        return _buildSubscriptionQueueSection(context, ref, group);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Future<void> _showSubscriptionQueueSheet(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionGroup group,
    List<SnActiveSubscription> queuedSubscriptions,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => SheetScaffold(
        titleText: 'subscriptionRecordsSheetTitle'.tr(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: queuedSubscriptions.length,
          itemBuilder: (context, index) => _buildQueuedSubscriptionItem(
            context,
            ref,
            group,
            queuedSubscriptions[index],
          ),
        ),
      ),
    );
  }

  Widget _buildQueuedSubscriptionItem(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionGroup group,
    SnActiveSubscription item,
  ) {
    final subscription = item.subscription;
    final isPending =
        subscription.isPendingActivation ||
        subscription.begunAt.isAfter(DateTime.now());

    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.definition.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (isPending)
                _buildStatusChip(
                  context,
                  label: 'subscriptionRecordPendingActivation'.tr(),
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
            ],
          ),
          const Gap(4),
          Text(
            'Starts ${subscription.begunAt.formatSystem()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (subscription.endedAt != null)
            Text(
              'Ends ${subscription.endedAt!.formatSystem()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const Gap(8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: isPending
                  ? () => _switchSubscription(
                      context,
                      ref,
                      group.groupIdentifier,
                      subscription.id,
                    )
                  : null,
              child: Text('switchNow'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTabBar(
    BuildContext context,
    TabController controller,
    WidgetRef ref,
    int selectedTab,
    bool useAfdianCheckout,
  ) {
    final items = useAfdianCheckout
        ? <ButtonSegment<int>>[
            ButtonSegment<int>(value: 0, label: Text('afdian'.tr())),
            ButtonSegment<int>(value: 1, label: Text('walletExchange'.tr())),
          ]
        : <ButtonSegment<int>>[
            ButtonSegment<int>(value: 0, label: Text('appleIap'.tr())),
            ButtonSegment<int>(value: 1, label: Text('walletExchange'.tr())),
          ];

    return SegmentedButton<int>(
      segments: items,
      selected: {selectedTab},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        final value = selection.first;
        ref.read(selectedTabProvider.notifier).setTab(value);
        if (controller.index != value) {
          controller.animateTo(value);
        }
      },
    );
  }

  Widget _buildMembershipTiers(
    BuildContext context,
    TabController tabController,
    WidgetRef ref,
    SnWalletSubscription? currentMembership,
    int selectedTab,
    Map<String, String> iapProducts,
    bool useAfdianCheckout,
    bool hasExternalCheckout,
  ) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final effectiveMethod = selectedTab == 0
            ? (hasExternalCheckout ? (useAfdianCheckout ? 2 : 1) : 0)
            : 0;

        final tiers = group.catalog.items.where((tier) {
          if (effectiveMethod == 0) {
            return tier.allowedPaymentMethods.contains('solian.wallet');
          }
          if (effectiveMethod == 1) {
            return tier.allowedPaymentMethods.contains('apple_store');
          }
          if (effectiveMethod == 2) {
            return tier.allowedPaymentMethods.contains('afdian');
          }
          return false;
        }).toList()..sort((a, b) => a.perkLevel.compareTo(b.perkLevel));

        if (tiers.isEmpty) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        return _MembershipTierCarousel(
          tiers: tiers,
          currentMembership: currentMembership,
          selectedTab: selectedTab,
          showAfdianTab: useAfdianCheckout,
          tabController: tabController,
          iapProducts: iapProducts,
          onPurchase: (tier, method) =>
              _purchaseMembership(context, ref, tier, method),
        );
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
    final colorScheme = Theme.of(context).colorScheme;
    switch (identifier) {
      case 'solian.stellar.primary':
        return colorScheme.primary;
      case 'solian.stellar.nova':
        return colorScheme.secondary;
      case 'solian.stellar.tertiary':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }

  static final _defaultColor = Color(0xFF2196F3);

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return _defaultColor;
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
      return _defaultColor;
    } catch (e) {
      return _defaultColor;
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

      await _refreshSubscriptionState(ref);

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
    int method,
  ) async {
    if (method == 1) {
      final appleStoreProductIds = tier.providerMappings.appleStore;
      if (appleStoreProductIds.isNotEmpty) {
        await _purchaseWithIap(context, ref, tier, appleStoreProductIds.first);
        return;
      }
    }

    if (method == 2) {
      await _purchaseWithAfdian(context, ref, tier);
      return;
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
        await _refreshSubscriptionState(ref);
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
      if (subscription.status == 1) {
        await _refreshSubscriptionState(ref);
        return;
      }
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
        await _refreshSubscriptionState(ref);
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

  Future<void> _purchaseWithAfdian(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionCatalog tier,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);

      final resp = await client.post(
        '/wallet/subscriptions/${tier.identifier}/checkout/afdian',
      );

      if (context.mounted) hideLoadingModal(context);

      final checkoutUrl = resp.data['checkout_url'] as String?;
      // These may be used for future tracking
      resp.data['provider_reference_id'] as String?;
      resp.data['plan_id'] as String?;

      if (checkoutUrl == null) {
        if (context.mounted) {
          showErrorAlert('Failed to get checkout URL');
        }
        return;
      }

      await launchUrlString(checkoutUrl, mode: LaunchMode.externalApplication);

      if (context.mounted) {
        showSnackBar('请在 Afdian 页面完成支付，支付完成后会自动恢复订阅');
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  Future<void> _refreshSubscriptionState(WidgetRef ref) async {
    ref.invalidate(accountSubscriptionGroupProvider);
    ref.invalidate(accountStellarSubscriptionProvider);
    await ref.read(userInfoProvider.notifier).fetchUser();
  }

  Future<void> _switchSubscription(
    BuildContext context,
    WidgetRef ref,
    String groupIdentifier,
    String subscriptionId,
  ) async {
    try {
      showLoadingModal(context);
      final client = ref.read(apiClientProvider);
      await client.post(
        '/wallet/subscriptions/groups/$groupIdentifier/activate',
        data: {'subscription_id': subscriptionId},
      );
      await _refreshSubscriptionState(ref);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('Subscription switched successfully');
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }

  Widget _buildGiftingSection(BuildContext context, WidgetRef ref) {
    final sentGifts = ref.watch(accountSentGiftsProvider());
    final receivedGifts = ref.watch(accountReceivedGiftsProvider());

    return _buildSectionCard(
      context,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Gap(12),

          _buildSectionHeader(context, title: 'purchaseAGift'.tr()),
          const Gap(8),
          _buildGiftPurchaseOptions(context, ref),
          const Gap(16),

          _buildSectionHeader(context, title: 'redeemAGift'.tr()),
          const Gap(8),
          _buildGiftRedeemSection(context, ref),
          const Gap(16),

          _buildSectionHeader(context, title: 'giftHistory'.tr()),
          const Gap(8),
          _buildGiftHistory(context, ref, sentGifts, receivedGifts),
        ],
      ),
    );
  }

  Widget _buildGiftPurchaseOptions(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }
        final tiers =
            group.catalog.items
                .where((a) => a.allowedPaymentMethods.contains('gift'))
                .toList()
              ..sort((a, b) => a.perkLevel.compareTo(b.perkLevel));

        if (tiers.isEmpty) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final tierWidgets = <Widget>[];
        for (final tier in tiers) {
          final tierColor = _parseColor(tier.displayConfig?.color);

          tierWidgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showPurchaseGiftDialog(context, ref, tier.identifier),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
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

    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
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
              _buildStatusChip(
                context,
                label: statusText,
                backgroundColor: statusColor.withOpacity(0.12),
                foregroundColor: statusColor,
                avatar: gift.status == 2 && gift.redeemer != null
                    ? AccountPfcRegion(
                        uname: gift.redeemer!.name,
                        child: ProfilePictureWidget(
                          file: gift.redeemer!.profile.picture,
                          radius: 8,
                        ),
                      )
                    : null,
              ),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetadataChip(
                context,
                icon: Icons.workspace_premium_outlined,
                label: _getMembershipTierName(gift.subscriptionIdentifier),
              ),
              if (gift.recipient != null && isSent)
                _buildMetadataChip(
                  context,
                  icon: Icons.north_east_rounded,
                  label: gift.recipient!.name,
                ),
              if (gift.gifter != null && !isSent)
                _buildMetadataChip(
                  context,
                  icon: Icons.south_west_rounded,
                  label: gift.gifter!.name,
                ),
            ],
          ),
          if (gift.message != null && gift.message!.isNotEmpty) ...[
            const Gap(10),
            Text(
              gift.message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const Gap(12),
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

  Widget _buildMetadataChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const Gap(6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 0:
        return colorScheme.outline;
      case 1:
        return colorScheme.primary;
      case 2:
        return colorScheme.tertiary;
      case 3:
        return colorScheme.error;
      case 4:
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
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
          'recipient_id': recipientId,
          'payment_method': 'solian.wallet',
          'payment_details': {'currency': 'golds'},
          'message': message,
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
      await _refreshSubscriptionState(ref);
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

class _MembershipTierCarousel extends StatefulWidget {
  final List<SnSubscriptionCatalog> tiers;
  final SnWalletSubscription? currentMembership;
  final int selectedTab;
  final bool showAfdianTab;
  final TabController tabController;
  final Map<String, String> iapProducts;
  final void Function(SnSubscriptionCatalog tier, int method) onPurchase;

  const _MembershipTierCarousel({
    required this.tiers,
    required this.currentMembership,
    required this.selectedTab,
    required this.showAfdianTab,
    required this.tabController,
    required this.iapProducts,
    required this.onPurchase,
  });

  @override
  State<_MembershipTierCarousel> createState() =>
      _MembershipTierCarouselState();
}

class _MembershipTierCarouselState extends State<_MembershipTierCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  double _viewportFraction = 0.72;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncViewportFraction();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncViewportFraction() {
    final nextFraction = isWideScreen(context) ? 0.72 : 0.9;
    if (nextFraction == _viewportFraction) return;

    final currentPage = _pageController.hasClients
        ? (_pageController.page?.round() ?? _currentPage)
        : _currentPage;

    _pageController.dispose();
    _viewportFraction = nextFraction;
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: currentPage,
    );
  }

  static final _defaultColor = Color(0xFF2196F3);

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return _defaultColor;
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
      return _defaultColor;
    } catch (e) {
      return _defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.tiers.length,
            itemBuilder: (context, index) {
              final tier = widget.tiers[index];
              return _buildTierCard(context, tier, index);
            },
          ),
        ),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.tiers.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    SnSubscriptionCatalog tier,
    int index,
  ) {
    final isCurrentTier =
        widget.currentMembership?.identifier == tier.identifier;
    final tierColor = _parseColor(tier.displayConfig?.color);

    final effectiveMethod = widget.selectedTab == 0
        ? (widget.showAfdianTab ? 2 : 1)
        : 0;

    String priceDisplay;
    if (effectiveMethod == 1 && tier.providerMappings.appleStore.isNotEmpty) {
      final productId = tier.providerMappings.appleStore.first;
      final applePrice = widget.iapProducts[productId] ?? '...';
      priceDisplay = '$applePrice/month';
    } else if (effectiveMethod == 2 &&
        tier.providerMappings.afdian.isNotEmpty) {
      priceDisplay = '${tier.basePrice} ${tier.currency}/month';
    } else if (effectiveMethod == 0) {
      priceDisplay = '${tier.basePrice} ${tier.currency}/month';
    } else {
      priceDisplay = 'pricingAtCheckout'.tr();
    }

    final benefits = _getTierBenefits(tier.identifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: isCurrentTier
              ? null
              : () => widget.onPurchase(tier, effectiveMethod),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentTier
                  ? tierColor.withOpacity(0.08)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentTier
                    ? tierColor
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: isCurrentTier ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tierColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: tierColor,
                        size: 28,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tier.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentTier ? tierColor : null,
                                  ),
                                ),
                              ),
                              if (isCurrentTier) ...[
                                const Gap(8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tierColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'membershipCurrentBadge'.tr(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            priceDisplay,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                const Divider(height: 1),
                const Gap(12),
                Text(
                  'Benefits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: benefits
                          .map(
                            (benefit) =>
                                _buildBenefitItem(context, benefit, tierColor),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (!isCurrentTier) ...[
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => widget.onPurchase(tier, effectiveMethod),
                      style: FilledButton.styleFrom(
                        backgroundColor: tierColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('subscribeNow'.tr()),
                    ),
                  ),
                  if (effectiveMethod == 1) ...[
                    const Gap(8),
                    Text(
                      'subscriptionAutoRenewDisclaimer'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String benefit,
    Color tierColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: tierColor),
          const Gap(8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTierBenefits(String tierIdentifier) {
    switch (tierIdentifier) {
      case 'solian.stellar.primary':
        return [
          '5GB Cloud Storage',
          '1.5x Leveling Boost',
          'Limited Username Colors',
          'Translation Service',
          'Verification Eligible',
        ];
      case 'solian.stellar.nova':
        return [
          '10GB Cloud Storage',
          '2x Leveling Boost',
          'Unlimited Username Colors',
          'Custom Labels',
          'Realm & Bot Quota (0-3)',
          'Translation Service',
          'Verification Eligible',
        ];
      case 'solian.stellar.supernova':
        return [
          '15GB Cloud Storage',
          '2.5x Leveling Boost',
          'Gradient Username Colors',
          'All Nova Features',
          'Priority Support',
          'Exclusive Badges',
        ];
      default:
        return [];
    }
  }
}
