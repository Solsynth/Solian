import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/services/responsive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/restore_purchase_sheet.dart';
import 'package:island/wallets/wallet.dart';
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
import 'package:url_launcher/url_launcher_string.dart';
part 'stellar_program_tab.g.dart';

const _goldResupplyCatalogKey = 'golds_resupply_pack';
const _goldResupplyFallbackAppleProductId = 'GDP';
const _goldResupplyFallbackPointsPerUnit = 10;

const _storePurchaseChannel = MethodChannel(
  'dev.solsynth.solian/store_purchase',
);

Future<bool> _detectSandboxPurchaseEnvironment() async {
  if (kDebugMode) return true;
  if (kIsWeb || (!Platform.isIOS && !Platform.isMacOS)) return false;

  try {
    return await _storePurchaseChannel.invokeMethod<bool>(
          'isSandboxPurchaseEnvironment',
        ) ??
        false;
  } catch (_) {
    return false;
  }
}

bool get _offerAfdianInDebug => kDebugMode;

String get _stellarPricingUrl => !kIsWeb && Platform.isAndroid
    ? 'https://www.solian.app/pricing'
    : 'https://solian.app/pricing';

enum PaymentMethodTab { wallet, appleIap, afdian }

List<PaymentMethodTab> _resolvePaymentMethods({
  required SnSubscriptionGroup? group,
  required bool supportsIap,
}) {
  if (group == null) return const [];

  final items = group.catalog.items;
  final hasWallet = items.any(
    (c) => c.allowedPaymentMethods.contains('solian.wallet'),
  );
  final hasAfdian = items.any(
    (c) => c.allowedPaymentMethods.contains('afdian'),
  );
  final hasApple = items.any(
    (c) => c.allowedPaymentMethods.contains('apple_store'),
  );

  final methods = <PaymentMethodTab>[];
  if (supportsIap && hasApple) {
    methods.add(PaymentMethodTab.appleIap);
  }
  if (hasAfdian && (!supportsIap || _offerAfdianInDebug)) {
    methods.add(PaymentMethodTab.afdian);
  }
  if (hasWallet) {
    methods.add(PaymentMethodTab.wallet);
  }
  return methods;
}

int _paymentMethodCode(PaymentMethodTab method) {
  return switch (method) {
    PaymentMethodTab.wallet => 0,
    PaymentMethodTab.appleIap => 1,
    PaymentMethodTab.afdian => 2,
  };
}

String _paymentMethodLabel(PaymentMethodTab method) {
  return switch (method) {
    PaymentMethodTab.wallet => 'sourcePoints'.tr(),
    PaymentMethodTab.appleIap => 'appleIap'.tr(),
    PaymentMethodTab.afdian => 'afdian'.tr(),
  };
}

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

/// Flexible catalog product.
///
/// `providerMappings` is:
/// `{ paymentMethod: { providerProductId: pointsAmount } }`
/// and keys may change over time, so lookups use a map + aliases.
class WalletProductCatalogItem {
  final String key;
  final String identifier;
  final String displayName;
  final String currency;
  final Map<String, Map<String, int>> providerMappings;

  const WalletProductCatalogItem({
    required this.key,
    required this.identifier,
    required this.displayName,
    required this.currency,
    required this.providerMappings,
  });

  factory WalletProductCatalogItem.fromJson(Map<String, dynamic> json) {
    final mappings = <String, Map<String, int>>{};
    final rawMappings = json['provider_mappings'];
    if (rawMappings is Map) {
      for (final methodEntry in rawMappings.entries) {
        final method = methodEntry.key.toString();
        final productsRaw = methodEntry.value;
        if (productsRaw is! Map) continue;

        final products = <String, int>{};
        for (final productEntry in productsRaw.entries) {
          final amount = productEntry.value;
          if (amount is num) {
            products[productEntry.key.toString()] = amount.toInt();
          }
        }
        if (products.isNotEmpty) {
          mappings[method] = products;
        }
      }
    }

    return WalletProductCatalogItem(
      key: json['key']?.toString() ?? '',
      identifier: json['identifier']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'golds',
      providerMappings: mappings,
    );
  }

  /// First `{productId: points}` for any matching payment method.
  MapEntry<String, int>? productOfferFor(Iterable<String> methodAliases) {
    final aliases = methodAliases.map((e) => e.toLowerCase()).toSet();
    for (final entry in providerMappings.entries) {
      if (!aliases.contains(entry.key.toLowerCase())) continue;
      if (entry.value.isEmpty) continue;
      return entry.value.entries.first;
    }
    return null;
  }
}

class GoldResupplyOffer {
  final String appleProductId;
  final int applePointsPerUnit;
  final Map<String, Map<String, int>> providerMappings;
  final String displayName;

  const GoldResupplyOffer({
    required this.appleProductId,
    required this.applePointsPerUnit,
    required this.providerMappings,
    required this.displayName,
  });

  static const fallback = GoldResupplyOffer(
    appleProductId: _goldResupplyFallbackAppleProductId,
    applePointsPerUnit: _goldResupplyFallbackPointsPerUnit,
    providerMappings: {
      'AppleStore': {
        _goldResupplyFallbackAppleProductId: _goldResupplyFallbackPointsPerUnit,
      },
    },
    displayName: 'Golds Resupply Pack',
  );

  MapEntry<String, int>? offerFor(Iterable<String> methodAliases) {
    final aliases = methodAliases.map((e) => e.toLowerCase()).toSet();
    for (final entry in providerMappings.entries) {
      if (!aliases.contains(entry.key.toLowerCase())) continue;
      if (entry.value.isEmpty) continue;
      return entry.value.entries.first;
    }
    return null;
  }

  List<PaymentMethodTab> availablePaymentMethods({
    required bool supportsIap,
  }) {
    final methods = <PaymentMethodTab>[];
    if (supportsIap &&
        offerFor(const ['AppleStore', 'apple_store', 'apple']) != null) {
      methods.add(PaymentMethodTab.appleIap);
    }
    if (offerFor(const ['Afdian', 'afdian']) != null &&
        (!supportsIap || _offerAfdianInDebug)) {
      methods.add(PaymentMethodTab.afdian);
    }
    return methods;
  }

  int pointsFor(PaymentMethodTab method) {
    return switch (method) {
      PaymentMethodTab.appleIap =>
        offerFor(const ['AppleStore', 'apple_store', 'apple'])?.value ??
            applePointsPerUnit,
      PaymentMethodTab.afdian =>
        offerFor(const ['Afdian', 'afdian'])?.value ?? applePointsPerUnit,
      PaymentMethodTab.wallet => applePointsPerUnit,
    };
  }
}

final walletProductCatalogProvider =
    FutureProvider<List<WalletProductCatalogItem>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final resp = await client.get('/wallet/wallet-products/catalog');
      final data = resp.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => WalletProductCatalogItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      // Some gateways may return a single object.
      if (data is Map) {
        return [
          WalletProductCatalogItem.fromJson(Map<String, dynamic>.from(data)),
        ];
      }

      return const [];
    });

final goldResupplyOfferProvider = Provider<GoldResupplyOffer>((ref) {
  final catalog = ref.watch(walletProductCatalogProvider).asData?.value;
  if (catalog == null || catalog.isEmpty) {
    return GoldResupplyOffer.fallback;
  }

  final product = catalog.firstWhere(
    (item) =>
        item.key == _goldResupplyCatalogKey ||
        item.identifier == 'wallet.golds_resupply_pack',
    orElse: () => catalog.first,
  );

  final apple = product.productOfferFor(const [
    'AppleStore',
    'apple_store',
    'apple',
  ]);

  return GoldResupplyOffer(
    appleProductId: apple?.key ?? _goldResupplyFallbackAppleProductId,
    applePointsPerUnit: apple?.value ?? _goldResupplyFallbackPointsPerUnit,
    providerMappings: product.providerMappings,
    displayName: product.displayName.isEmpty
        ? GoldResupplyOffer.fallback.displayName
        : product.displayName,
  );
});

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

class StellarProgramView extends HookConsumerWidget {
  final bool showStoreHeader;

  const StellarProgramView({super.key, this.showStoreHeader = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stellarSubscription = ref.watch(accountStellarSubscriptionProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final iapProducts = ref.watch(iapProductsProvider);
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
    final sandboxPurchaseEnvironment = useState<bool?>(null);

    useEffect(() {
      var disposed = false;
      _detectSandboxPurchaseEnvironment().then((value) {
        if (!disposed) sandboxPurchaseEnvironment.value = value;
      });
      return () => disposed = true;
    }, const []);

    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    final paymentMethods = _resolvePaymentMethods(
      group: groupAsync.asData?.value,
      supportsIap: supportsIap,
    );
    final tabCount = paymentMethods.isEmpty ? 1 : paymentMethods.length;
    final safeSelectedTab = selectedTab.clamp(0, tabCount - 1);
    final tabController = useMaterialTabController(
      initialLength: tabCount,
      initialIndex: safeSelectedTab,
      keys: [tabCount],
    );

    useEffect(() {
      if (selectedTab >= tabCount) {
        ref.read(selectedTabProvider.notifier).setTab(0);
      }
      return;
    }, [tabCount, selectedTab]);
    useEffect(() {
      if (!tabController.indexIsChanging &&
          tabController.index != safeSelectedTab) {
        tabController.animateTo(safeSelectedTab);
      }
      return;
    }, [safeSelectedTab, tabController]);

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
    final goldOffer = ref.watch(goldResupplyOfferProvider);
    if (showStoreHeader) {
      ref.watch(walletProductCatalogProvider);
    }

    if (supportsIap && iapProducts.isEmpty && groupAsync.hasValue) {
      final group = groupAsync.value!;
      final appleProductIds = group.catalog.items
          .expand((c) => c.providerMappings.appleStore)
          .toSet();
      if (showStoreHeader) {
        appleProductIds.add(goldOffer.appleProductId);
      }
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showStoreHeader && sandboxPurchaseEnvironment.value == true) ...[
            _buildSandboxPurchaseWarning(context),
            const Gap(16),
          ],
          if (showStoreHeader) ...[
            _buildStoreIntro(context),
            const Gap(18),
            _buildGoldenPointsStoreCard(
              context,
              ref,
              supportsIap,
              iapProducts,
            ),
            const Gap(12),
          ],
          _buildMembershipSection(
            context,
            tabController,
            ref,
            stellarSubscription,
            safeSelectedTab,
            iapProducts,
            paymentMethods,
            compactPurchase: showStoreHeader,
          ),
          if (showStoreHeader) ...[
            const Gap(28),
            _buildStoreUtilitiesHeader(context),
            const Gap(12),
          ] else ...[
            const Gap(16),
          ],
          _buildPricingGuideCard(context),
          const Gap(12),
          _buildSubscriptionQueueSummary(context, ref),
          if (!supportsIap || kDebugMode) ...[
            const Gap(12),
            _buildGiftEntryTile(context, ref),
          ],
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
    List<PaymentMethodTab> paymentMethods, {
    required bool compactPurchase,
  }) {
    return stellarSubscriptionAsync.when(
      data: (membership) => _buildMembershipContent(
        context,
        tabController,
        ref,
        membership,
        selectedTab,
        iapProducts,
        paymentMethods,
        compactPurchase: compactPurchase,
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
    List<PaymentMethodTab> paymentMethods, {
    required bool compactPurchase,
  }) {
    final isActive = membership?.isActive ?? false;
    final isWalletSubscription = membership?.paymentMethod == 'solian.wallet';
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
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

    void openPurchaseSheet() {
      _showStellarPurchaseSheet(context, membership);
    }

    if (compactPurchase) {
      final tierName = isActive && currentSubscription != null
          ? _getMembershipTierName(currentSubscription.identifier)
          : null;
      final tierColor = isActive && currentSubscription != null
          ? _getMembershipTierColor(context, currentSubscription.identifier)
          : scheme.secondary;

      return _StoreProductCard(
        accent: tierColor,
        icon: isActive ? Icons.auto_awesome : Icons.star_border_rounded,
        eyebrow: 'stellarProgram'.tr().toUpperCase(),
        title: 'stellarMembership'.tr(),
        description: isActive
            ? 'currentMembership'.tr(args: [tierName!])
            : 'stellarProgramAbout'.tr(),
        meta: isActive && currentSubscription?.endedAt != null
            ? 'membershipExpires'.tr(
                args: [currentSubscription!.endedAt!.formatSystem()],
              )
            : isActive
            ? null
            : 'stellarDurationNote'.tr(),
        trailingAction: IconButton.filledTonal(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) {
                return SheetScaffold(
                  titleText: 'stellarProgram'.tr(),
                  child: Column(
                    spacing: 12,
                    children: [
                      Text('stellarProgramAbout'.tr()),
                      Text('stellarProgramAboutPricing'.tr()),
                    ],
                  ).padding(horizontal: 24, vertical: 16),
                );
              },
            );
          },
          icon: const Icon(Symbols.help, size: 18),
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isActive && isWalletSubscription) ...[
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: scheme.error,
                ),
                onPressed: membershipCancel,
                icon: const Icon(Symbols.cancel),
                label: Text('membershipCancel'.tr()),
              ),
              const Gap(8),
            ],
            FilledButton.icon(
              onPressed: openPurchaseSheet,
              icon: Icon(
                isActive ? Symbols.swap_horiz : Symbols.shopping_bag,
              ),
              label: Text(
                isActive ? 'chooseYourPlan'.tr() : 'subscribeNow'.tr(),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      );
    }

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
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (context) {
                      return SheetScaffold(
                        titleText: 'stellarProgram'.tr(),
                        child: Column(
                          spacing: 12,
                          children: [
                            Text('stellarProgramAbout'.tr()),
                            Text('stellarProgramAboutPricing'.tr()),
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
          _buildStellarPurchaseControls(
            context,
            tabController,
            ref,
            membership,
            selectedTab,
            iapProducts,
            paymentMethods,
          ),
        ],
      ),
    );
  }

  Future<void> _showStellarPurchaseSheet(
    BuildContext context,
    SnWalletSubscription? membership,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return _StellarPurchaseSheet(membership: membership);
      },
    );
  }

  Widget _buildStellarPurchaseControls(
    BuildContext context,
    TabController tabController,
    WidgetRef ref,
    SnWalletSubscription? membership,
    int selectedTab,
    Map<String, String> iapProducts,
    List<PaymentMethodTab> paymentMethods, {
    bool includePlanHeader = true,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final showPaymentTabs = paymentMethods.length > 1;
    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    final footerActions = <Widget>[
      if (supportsIap)
        _buildFooterActionButton(
          context,
          icon: Symbols.restore,
          label: 'restorePurchase'.tr(),
          onPressed: () => _restorePurchaseIap(context, ref),
        ),
      if (!supportsIap || kDebugMode)
        _buildFooterActionButton(
          context,
          icon: Symbols.restore,
          label: supportsIap && kDebugMode
              ? '${'restorePurchase'.tr()} (3rd party)'
              : 'restorePurchase'.tr(),
          onPressed: () => _showRestorePurchaseSheet(context, ref),
        ),
      _buildFooterActionButton(
        context,
        label: 'termsLink'.tr(),
        onPressed: () => launchUrlString(
          'https://solsynth.dev/terms/user-agreement',
          mode: LaunchMode.externalApplication,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includePlanHeader) ...[
          Text(
            'chooseYourPlan'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(4),
          Text(
            'stellarDurationNote'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(16),
        ],
        if (showPaymentTabs) ...[
          _buildPaymentMethodTabBar(
            context,
            tabController,
            paymentMethods,
          ),
          const Gap(16),
        ],
        _buildMembershipTiers(
          context,
          ref,
          membership,
          selectedTab,
          iapProducts,
          paymentMethods,
        ),
        const Gap(20),
        Divider(
          height: 1,
          thickness: 1,
          color: scheme.outlineVariant.withOpacity(0.6),
        ),
        const Gap(16),
        // One subscription = one 30-day orbit around the Solar Network.
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.orbit_rounded,
                size: 17,
                color: scheme.primary,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                'stellarDurationNote'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ).padding(horizontal: 24),
        const Gap(12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: [
            for (var i = 0; i < footerActions.length; i++) ...[
              if (i > 0) _buildFooterDot(context),
              footerActions[i],
            ],
          ],
        ),
      ],
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

  Widget _buildStoreIntro(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOLAR NETWORK',
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const Gap(6),
        Text(
          'store'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const Gap(8),
        Text(
          'stellarProgramAbout'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreUtilitiesHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'More',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          'Manage purchases & gifts',
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildSandboxPurchaseWarning(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.error.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.error.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Symbols.warning, color: scheme.onErrorContainer),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'storeSandboxWarningTitle'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(4),
                Text(
                  'storeSandboxWarning'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer.withOpacity(0.92),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenPointsStoreCard(
    BuildContext context,
    WidgetRef ref,
    bool supportsIap,
    Map<String, String> iapProducts,
  ) {
    final goldOffer = ref.watch(goldResupplyOfferProvider);
    final price = iapProducts[goldOffer.appleProductId];
    final pointsLabel =
        '${goldOffer.applePointsPerUnit} Golden Points / unit';

    return _StoreProductCard(
      accent: const Color(0xFFE8B84A),
      icon: Symbols.account_balance_wallet,
      eyebrow: 'GOLDEN POINTS',
      title: 'storeGoldenPointsTitle'.tr(),
      description: 'storeGoldenPointsDescription'.tr(),
      meta: price == null ? pointsLabel : '$price · $pointsLabel',
      footer: FilledButton.icon(
        onPressed: () => _showGoldPurchaseSheet(context, ref),
        icon: const Icon(Symbols.shopping_bag),
        label: Text('purchase'.tr()),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: const Color(0xFFE8B84A),
          foregroundColor: const Color(0xFF2A1B00),
        ),
      ),
    );
  }

  Widget _buildUtilityActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingGuideCard(BuildContext context) {
    return _buildUtilityActionTile(
      context,
      icon: Icons.currency_exchange_rounded,
      title: 'stellarPricingTitle'.tr(),
      description: 'stellarPricingDescription'.tr(),
      onTap: () => launchUrlString(
        _stellarPricingUrl,
        mode: LaunchMode.externalApplication,
      ),
      trailing: Icon(
        Icons.open_in_new,
        size: 18,
        color: Theme.of(context).colorScheme.outline,
      ),
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

    return _buildUtilityActionTile(
      context,
      icon: Icons.schedule,
      title: 'subscriptionRecordsTitle'.tr(),
      description: 'subscriptionRecordsSubtitle'.tr(
        args: [queuedSubscriptions.length.toString()],
      ),
      onTap: () => _showSubscriptionQueueSheet(
        context,
        ref,
        group,
        queuedSubscriptions,
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

  Widget _buildFooterActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: icon == null
          ? Text(label, style: theme.textTheme.labelLarge)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const Gap(6),
                Text(label, style: theme.textTheme.labelLarge),
              ],
            ),
    );
  }

  Widget _buildFooterDot(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPaymentMethodTabBar(
    BuildContext context,
    TabController controller,
    List<PaymentMethodTab> paymentMethods,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest.withOpacity(0.55),
      borderRadius: BorderRadius.circular(16),
      child: TabBar(
        controller: controller,
        isScrollable: paymentMethods.length > 3,
        tabAlignment: paymentMethods.length > 3
            ? TabAlignment.start
            : TabAlignment.fill,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
        padding: const EdgeInsets.all(4),
        tabs: [
          for (final method in paymentMethods)
            Tab(text: _paymentMethodLabel(method)),
        ],
      ),
    );
  }

  Widget _buildMembershipTiers(
    BuildContext context,
    WidgetRef ref,
    SnWalletSubscription? currentMembership,
    int selectedTab,
    Map<String, String> iapProducts,
    List<PaymentMethodTab> paymentMethods,
  ) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    return groupAsync.when(
      data: (group) {
        if (group == null) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final method = paymentMethods.isEmpty
            ? PaymentMethodTab.wallet
            : paymentMethods[selectedTab.clamp(0, paymentMethods.length - 1)];
        final effectiveMethod = _paymentMethodCode(method);

        final tiers =
            group.catalog.items.where((tier) {
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
            }).toList()
              ..sort((a, b) => a.perkLevel.compareTo(b.perkLevel));

        if (tiers.isEmpty) {
          return Center(child: Text('noTiersAvailable'.tr()));
        }

        final initialIndex = () {
          final currentId = currentMembership?.identifier;
          if (currentId == null) return 0;
          final idx = tiers.indexWhere((t) => t.identifier == currentId);
          return idx >= 0 ? idx : 0;
        }();

        return _PlanCarousel(
          tiers: tiers,
          initialIndex: initialIndex,
          currentMembership: currentMembership,
          effectiveMethod: effectiveMethod,
          iapProducts: iapProducts,
          onPurchase: (tier) async {
            var quantity = 1;
            if (effectiveMethod == 0) {
              final selectedQuantity = await _showWalletQuantitySheet(context);
              if (selectedQuantity == null || !context.mounted) return;
              quantity = selectedQuantity;
            }
            if (!context.mounted) return;
            await _purchaseMembership(
              context,
              ref,
              tier,
              effectiveMethod,
              quantity: quantity,
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 360,
        child: Center(child: CircularProgressIndicator()),
      ),
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

  Future<int?> _showWalletQuantitySheet(
    BuildContext context, {
    String descriptionKey = 'storeQuantityDescription',
    String limitKey = 'storeQuantityLimit',
    int maxQuantity = 12,
  }) async {
    final controller = TextEditingController(text: '1');
    var quantity = 1;

    final result = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void updateQuantity(int value) {
            quantity = value.clamp(1, maxQuantity);
            controller.text = quantity.toString();
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
            setState(() {});
          }

          return SheetScaffold(
            titleText: 'storeQuantityTitle'.tr(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    descriptionKey.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: quantity > 1
                            ? () => updateQuantity(quantity - 1)
                            : null,
                        icon: const Icon(Symbols.remove),
                      ),
                      const Gap(12),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'quantity'.tr(),
                            helperText: limitKey.tr(),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              quantity = parsed.clamp(1, maxQuantity);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      const Gap(12),
                      IconButton.filledTonal(
                        onPressed: quantity < maxQuantity
                            ? () => updateQuantity(quantity + 1)
                            : null,
                        icon: const Icon(Symbols.add),
                      ),
                    ],
                  ),
                  const Gap(20),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(quantity),
                    child: Text('confirm'.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showGoldPurchaseSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showModalBottomSheet<({PaymentMethodTab method, int quantity})>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const _GoldPurchaseSheet(),
    );
    if (result == null || !context.mounted) return;

    if (result.method == PaymentMethodTab.appleIap) {
      await _purchaseGoldsWithIap(context, ref, result.quantity);
    } else if (result.method == PaymentMethodTab.afdian) {
      await _purchaseGoldsWithAfdian(context, ref);
    }
  }

  Future<void> _purchaseMembership(
    BuildContext context,
    WidgetRef ref,
    SnSubscriptionCatalog tier,
    int method, {
    int quantity = 1,
  }) async {
    if (method == 1) {
      final appleStoreProductIds = tier.providerMappings.appleStore;
      if (appleStoreProductIds.isNotEmpty) {
        await _purchaseWithIap(context, ref, appleStoreProductIds.first);
        return;
      }
    }
    if (method == 2) {
      await _purchaseWithAfdian(context, ref, tier);
      return;
    }

    await _purchaseWithWallet(
      context,
      ref,
      tier.identifier,
      quantity: quantity,
    );
  }

  Future<void> _purchaseWithIap(
    BuildContext context,
    WidgetRef ref,
    String productId, {
    String successMessage = 'membershipPurchaseSuccess',
    bool consumable = false,
    int quantity = 1,
  }) async {
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

      final result = await iapService.purchaseProduct(
        productId,
        consumable: consumable,
        quantity: quantity,
      );

      if (context.mounted) hideLoadingModal(context);

      if (result == null) {
        showSnackBar('Purchase has been cancelled.');
      } else if (result.error != null) {
        showErrorAlert(result.error);
      } else if (result.success) {
        showSnackBar('paymentVerification'.tr());
        await Future.delayed(const Duration(seconds: 2));
        await _refreshSubscriptionState(ref);
        if (context.mounted) {
          showSnackBar(successMessage.tr());
        }
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }

  Future<void> _purchaseGoldsWithIap(
    BuildContext context,
    WidgetRef ref,
    int quantity,
  ) async {
    await _purchaseWithIap(
      context,
      ref,
      ref.read(goldResupplyOfferProvider).appleProductId,
      successMessage: 'storeGoldPurchaseSuccess',
      consumable: true,
      quantity: quantity,
    );
  }

  Future<void> _purchaseGoldsWithAfdian(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      final response = await client.post(
        '/wallet/wallet-products/golds-resupply-pack/checkout/afdian',
      );
      final checkoutUrl = response.data['checkout_url'] as String?;
      if (context.mounted) hideLoadingModal(context);

      if (checkoutUrl == null) {
        if (context.mounted) {
          showErrorAlert('Failed to get checkout URL');
        }
        return;
      }

      await launchUrlString(checkoutUrl, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        showSnackBar('storeGoldPurchaseExternalHint'.tr());
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
    String tierId, {
    int quantity = 1,
  }) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.post(
        '/wallet/subscriptions',
        data: {
          'identifier': tierId,
          'cycle_duration_days': 30 * quantity.clamp(1, 12),
          'payment_details': {'currency': 'points'},
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
    ref.invalidate(walletCurrentProvider);
    ref.invalidate(walletListProvider);
    ref.invalidate(walletStatsProvider);
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

  Widget _buildGiftEntryTile(BuildContext context, WidgetRef ref) {
    return _buildUtilityActionTile(
      context,
      icon: Icons.card_giftcard,
      title: 'giftSubscriptions'.tr(),
      description: 'purchaseAGift'.tr(),
      onTap: () => _showGiftPlanSheet(context, ref),
    );
  }

  Future<void> _showGiftPlanSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return _GiftPlanSheet(
          onPurchaseTier: (tier) async {
            await _showPurchaseGiftDialog(context, ref, tier.identifier);
          },
        );
      },
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

class _GoldPurchaseSheet extends HookConsumerWidget {
  const _GoldPurchaseSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldOffer = ref.watch(goldResupplyOfferProvider);
    final iapProducts = ref.watch(iapProductsProvider);
    ref.watch(walletProductCatalogProvider);

    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    final paymentMethods = goldOffer.availablePaymentMethods(
      supportsIap: supportsIap,
    );
    final selectedMethod = useState<PaymentMethodTab>(
      paymentMethods.isNotEmpty
          ? paymentMethods.first
          : (supportsIap ? PaymentMethodTab.appleIap : PaymentMethodTab.afdian),
    );
    final quantity = useState(1);
    final controller = useTextEditingController(text: '1');
    const maxQuantity = 99;

    useEffect(() {
      if (paymentMethods.isEmpty) return null;
      if (!paymentMethods.contains(selectedMethod.value)) {
        selectedMethod.value = paymentMethods.first;
      }
      return null;
    }, [paymentMethods.map((m) => m.name).join('|')]);

    final method = selectedMethod.value;
    final pointsPerUnit = goldOffer.pointsFor(method);
    final receivedPoints = quantity.value * pointsPerUnit;
    final unitPriceLabel = method == PaymentMethodTab.appleIap
        ? iapProducts[goldOffer.appleProductId]
        : null;
    final isApple = method == PaymentMethodTab.appleIap;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    void updateQuantity(int value) {
      quantity.value = value.clamp(1, maxQuantity);
      controller.text = quantity.value.toString();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }

    void confirmPurchase() {
      if (!context.mounted || paymentMethods.isEmpty) return;
      Navigator.of(context).pop((
        method: method,
        quantity: quantity.value,
      ));
    }

    return SheetScaffold(
      titleText: 'storeGoldenPointsTitle'.tr(),
      heightFactor: 0.82,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'storeGoldQuantityDescription'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (paymentMethods.length > 1) ...[
              const Gap(16),
              Text(
                'Payment method',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              SegmentedButton<PaymentMethodTab>(
                segments: [
                  for (final m in paymentMethods)
                    ButtonSegment<PaymentMethodTab>(
                      value: m,
                      label: Text(_paymentMethodLabel(m)),
                    ),
                ],
                selected: {method},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  selectedMethod.value = selection.first;
                },
              ),
            ] else if (paymentMethods.length == 1) ...[
              const Gap(12),
              Text(
                _paymentMethodLabel(paymentMethods.first),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Gap(18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B84A).withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE8B84A).withOpacity(0.35),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'You will spend',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        isApple
                            ? (unitPriceLabel == null
                                  ? '×${quantity.value}'
                                  : '$unitPriceLabel × ${quantity.value}')
                            : 'Afdian checkout',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  const Divider(height: 1),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'You will receive',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        isApple
                            ? '$receivedPoints Golden Points'
                            : '${goldOffer.pointsFor(PaymentMethodTab.afdian)} Golden Points / pack',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB8860B),
                        ),
                      ),
                    ],
                  ),
                  if (isApple && unitPriceLabel != null) ...[
                    const Gap(8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$pointsPerUnit points per unit · $unitPriceLabel each',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isApple) ...[
              const Gap(20),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: quantity.value > 1
                        ? () => updateQuantity(quantity.value - 1)
                        : null,
                    icon: const Icon(Symbols.remove),
                  ),
                  const Gap(12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'quantity'.tr(),
                        helperText: 'storeGoldQuantityLimit'.tr(),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          quantity.value = parsed.clamp(1, maxQuantity);
                        }
                      },
                    ),
                  ),
                  const Gap(12),
                  IconButton.filledTonal(
                    onPressed: quantity.value < maxQuantity
                        ? () => updateQuantity(quantity.value + 1)
                        : null,
                    icon: const Icon(Symbols.add),
                  ),
                ],
              ),
            ] else ...[
              const Gap(12),
              Text(
                'Complete the purchase in your browser. Quantity is handled on Afdian.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const Gap(20),
            FilledButton.icon(
              onPressed: paymentMethods.isEmpty ? null : confirmPurchase,
              icon: Icon(
                isApple ? Symbols.shopping_bag : Symbols.open_in_new,
              ),
              label: Text(
                isApple
                    ? (unitPriceLabel == null
                          ? 'purchase'.tr()
                          : '${'purchase'.tr()} · $unitPriceLabel × ${quantity.value}')
                    : 'purchase'.tr(),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFFE8B84A),
                foregroundColor: const Color(0xFF2A1B00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftPlanSheet extends HookConsumerWidget {
  final Future<void> Function(SnSubscriptionCatalog tier) onPurchaseTier;

  const _GiftPlanSheet({required this.onPurchaseTier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);
    final sentGifts = ref.watch(accountSentGiftsProvider());
    final receivedGifts = ref.watch(accountReceivedGiftsProvider());
    const view = StellarProgramView(showStoreHeader: true);

    return SheetScaffold(
      titleText: 'giftSubscriptions'.tr(),
      heightFactor: 0.92,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(16),
            groupAsync.when(
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

                return _PlanCarousel(
                  tiers: tiers,
                  initialIndex: 0,
                  currentMembership: null,
                  effectiveMethod: 0,
                  iapProducts: const {},
                  onPurchase: onPurchaseTier,
                );
              },
              loading: () => const SizedBox(
                height: 360,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) =>
                  Center(child: Text('Error loading gift options: $error')),
            ),
            const Gap(24),
            view._buildSectionHeader(context, title: 'redeemAGift'.tr()).padding(horizontal: 24),
            const Gap(8),
            view._buildGiftRedeemSection(context, ref).padding(horizontal: 24),
            const Gap(16),
            view._buildSectionHeader(context, title: 'giftHistory'.tr()).padding(horizontal: 24),
            const Gap(8),
            view._buildGiftHistory(context, ref, sentGifts, receivedGifts).padding(horizontal: 24),
          ],
        ),
      ),
    );
  }
}

class _StellarPurchaseSheet extends HookConsumerWidget {
  final SnWalletSubscription? membership;

  const _StellarPurchaseSheet({this.membership});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final iapProducts = ref.watch(iapProductsProvider);
    final groupAsync = ref.watch(accountSubscriptionGroupProvider);

    final supportsIap = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    final paymentMethods = _resolvePaymentMethods(
      group: groupAsync.asData?.value,
      supportsIap: supportsIap,
    );
    final tabCount = paymentMethods.isEmpty ? 1 : paymentMethods.length;
    final safeSelectedTab = selectedTab.clamp(0, tabCount - 1);
    final tabController = useMaterialTabController(
      initialLength: tabCount,
      initialIndex: safeSelectedTab,
      keys: [tabCount],
    );

    useEffect(() {
      if (selectedTab >= tabCount) {
        ref.read(selectedTabProvider.notifier).setTab(0);
      }
      return;
    }, [tabCount, selectedTab]);

    useEffect(() {
      if (!tabController.indexIsChanging &&
          tabController.index != safeSelectedTab) {
        tabController.animateTo(safeSelectedTab);
      }
      return;
    }, [safeSelectedTab, tabController]);

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

    if (supportsIap && iapProducts.isEmpty && groupAsync.hasValue) {
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

    const view = StellarProgramView(showStoreHeader: true);

    return SheetScaffold(
      titleText: 'chooseYourPlan'.tr(),
      heightFactor: 0.92,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        child: view._buildStellarPurchaseControls(
          context,
          tabController,
          ref,
          membership,
          safeSelectedTab,
          iapProducts,
          paymentMethods,
          includePlanHeader: false,
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String? meta;
  final Widget? trailingAction;
  final Widget footer;

  const _StoreProductCard({
    required this.accent,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.footer,
    this.meta,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onAccent = ThemeData.estimateBrightnessForColor(accent) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1200);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accent.withOpacity(0.22), scheme.surface),
            Color.alphaBlend(accent.withOpacity(0.08), scheme.surfaceContainerLow),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                ?trailingAction,
              ],
            ),
            const Gap(12),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.78),
                height: 1.4,
              ),
            ),
            if (meta != null && meta!.isNotEmpty) ...[
              const Gap(12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meta!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: onAccent == Colors.white
                          ? accent
                          : const Color(0xFF5A4200),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            const Gap(16),
            footer,
          ],
        ),
      ),
    );
  }
}

class _PlanCarousel extends HookWidget {
  final List<SnSubscriptionCatalog> tiers;
  final int initialIndex;
  final SnWalletSubscription? currentMembership;
  final int effectiveMethod;
  final Map<String, String> iapProducts;
  final Future<void> Function(SnSubscriptionCatalog tier) onPurchase;

  const _PlanCarousel({
    required this.tiers,
    required this.initialIndex,
    required this.currentMembership,
    required this.effectiveMethod,
    required this.iapProducts,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(
      initialPage: initialIndex.clamp(0, tiers.length - 1),
      viewportFraction: isWideScreen(context) ? 0.6 : 0.8,
    );
    final currentPage = useState(initialIndex.clamp(0, tiers.length - 1));
    final isHovered = useState(false);
    final scheme = Theme.of(context).colorScheme;

    Future<void> scrollBy(int delta) async {
      final target = (currentPage.value + delta).clamp(0, tiers.length - 1);
      if (target == currentPage.value) return;
      await pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      currentPage.value = target;
    }

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: SizedBox(
            height: 430,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: tiers.length,
                  onPageChanged: (index) => currentPage.value = index,
                  itemBuilder: (context, index) {
                    final tier = tiers[index];
                    final selected = currentPage.value == index;
                    return AnimatedScale(
                      scale: selected ? 1 : 0.94,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0.72,
                        duration: const Duration(milliseconds: 220),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _MembershipTierCard(
                            tier: tier,
                            isCurrentTier:
                                currentMembership?.identifier ==
                                tier.identifier,
                            effectiveMethod: effectiveMethod,
                            iapProducts: iapProducts,
                            onPurchase: () => onPurchase(tier),
                            compact: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _PlanHoverArrowButton(
                      icon: Symbols.chevron_left,
                      isVisible: isHovered.value && currentPage.value > 0,
                      hiddenOffset: const Offset(-0.4, 0),
                      onTap: () => scrollBy(-1),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _PlanHoverArrowButton(
                      icon: Symbols.chevron_right,
                      isVisible:
                          isHovered.value &&
                          currentPage.value < tiers.length - 1,
                      hiddenOffset: const Offset(0.4, 0),
                      onTap: () => scrollBy(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < tiers.length; i++) ...[
              if (i > 0) const Gap(6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: currentPage.value == i ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentPage.value == i
                      ? scheme.primary
                      : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ],
        ),
        const Gap(8),
        Text(
          '${currentPage.value + 1} / ${tiers.length}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanHoverArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _PlanHoverArrowButton({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _MembershipTierCard extends StatelessWidget {
  final SnSubscriptionCatalog tier;
  final bool isCurrentTier;
  final int effectiveMethod;
  final Map<String, String> iapProducts;
  final VoidCallback onPurchase;
  final bool compact;

  const _MembershipTierCard({
    required this.tier,
    required this.isCurrentTier,
    required this.effectiveMethod,
    required this.iapProducts,
    required this.onPurchase,
    this.compact = false,
  });

  static final _defaultColor = Color(0xFF6C8CFF);

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

  String get _priceDisplay {
    if (effectiveMethod == 1 && tier.providerMappings.appleStore.isNotEmpty) {
      final productId = tier.providerMappings.appleStore.first;
      final applePrice = iapProducts[productId] ?? '...';
      return '$applePrice/mo';
    }
    if (effectiveMethod == 2 && tier.providerMappings.afdian.isNotEmpty) {
      return '${tier.basePrice} ${tier.currency}/mo';
    }
    if (effectiveMethod == 0) {
      return '${tier.basePrice} ${tier.currency}/mo';
    }
    return 'pricingAtCheckout'.tr();
  }

  List<String> get _benefits => _getTierBenefits(tier.identifier);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tierColor = _parseColor(tier.displayConfig?.color);
    final benefits = _benefits.take(compact ? 4 : _benefits.length).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 28 : 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(tierColor.withOpacity(0.22), scheme.surface),
            Color.alphaBlend(
              tierColor.withOpacity(0.06),
              scheme.surfaceContainerHighest,
            ),
          ],
        ),
        border: Border.all(
          color: isCurrentTier ? tierColor : tierColor.withOpacity(0.28),
          width: isCurrentTier ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 56 : 48,
                height: compact ? 56 : 48,
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: tierColor,
                  size: compact ? 28 : 24,
                ),
              ),
              const Spacer(),
              if (isCurrentTier)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'membershipCurrentBadge'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(18),
          Text(
            tier.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isCurrentTier ? tierColor : null,
            ),
          ),
          const Gap(6),
          Text(
            _priceDisplay,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Gap(16),
          Text(
            'stellarBenefitsTitle'.tr().toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(10),
          if (compact)
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  for (final benefit in benefits)
                    _buildBenefitItem(context, benefit, tierColor),
                  if (effectiveMethod == 1 || effectiveMethod == 2)
                    _buildBenefitItem(
                      context,
                      'stellarBenefitSpecialPrivilege'.tr(),
                      tierColor,
                    ),
                ],
              ),
            )
          else ...[
            for (final benefit in benefits)
              _buildBenefitItem(context, benefit, tierColor),
            if (effectiveMethod == 1 || effectiveMethod == 2)
              _buildBenefitItem(
                context,
                'stellarBenefitSpecialPrivilege'.tr(),
                tierColor,
              ),
          ],
          InkWell(
            onTap: () => launchUrlString(
              _stellarPricingUrl,
              mode: LaunchMode.externalApplication,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 14, color: scheme.primary),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'stellarFullBenefitsHint'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCurrentTier) ...[
            const Gap(14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPurchase,
                style: FilledButton.styleFrom(
                  backgroundColor: tierColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('subscribeNow'.tr()),
              ),
            ),
            if (effectiveMethod == 1) ...[
              const Gap(8),
              Text(
                'subscriptionAutoRenewDisclaimer'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ] else ...[
            const Gap(14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'membershipCurrentBadge'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: tierColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String benefit,
    Color tierColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: tierColor),
          const Gap(8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.3,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.88),
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
          'stellarBenefitLevelingBoost15'.tr(),
          'stellarBenefitLimitedUsernameColors'.tr(),
          'stellarBenefitTranslationService'.tr(),
          'stellarBenefitVerificationEligible'.tr(),
        ];
      case 'solian.stellar.nova':
        return [
          'stellarBenefitLevelingBoost2'.tr(),
          'stellarBenefitUnlimitedUsernameColors'.tr(),
          'stellarBenefitCustomLabels'.tr(),
          'stellarBenefitRealmBotQuota'.tr(),
          'stellarBenefitTranslationService'.tr(),
          'stellarBenefitVerificationEligible'.tr(),
        ];
      case 'solian.stellar.supernova':
        return [
          'stellarBenefitLevelingBoost25'.tr(),
          'stellarBenefitGradientUsernameColors'.tr(),
          'membershipFeatureAllNova'.tr(),
          'membershipFeaturePrioritySupport'.tr(),
          'stellarBenefitExclusiveBadges'.tr(),
        ];
      default:
        return [];
    }
  }
}
