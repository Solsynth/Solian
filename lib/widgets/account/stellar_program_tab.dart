import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/restore_purchase_sheet.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/payment/payment_overlay.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'stellar_program_tab.g.dart';

@riverpod
Future<SnWalletSubscription?> accountStellarSubscription(Ref ref) async {
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/id/subscriptions/fuzzy/solian.stellar');
    return SnWalletSubscription.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) return null;
    rethrow;
  }
}

class StellarProgramTab extends HookConsumerWidget {
  const StellarProgramTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stellarSubscription = ref.watch(accountStellarSubscriptionProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMembershipSection(context, ref, stellarSubscription),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildMembershipSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<SnWalletSubscription?> stellarSubscriptionAsync,
  ) {
    return stellarSubscriptionAsync.when(
      data: (membership) => _buildMembershipContent(context, ref, membership),
      loading:
          () => Container(
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
      error:
          (error, stack) => Container(
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
  ) {
    final isActive = membership?.isActive ?? false;

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
        await client.post('/id/subscriptions/${membership.identifier}/cancel');
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
          ],

          if (!isActive) ...[
            Text(
              'chooseYourPlan'.tr(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            _buildMembershipTiers(context, ref, membership),
          ],

          // Restore Purchase Button
          // As you know Apple platform need IAP
          if (kIsWeb || !(Platform.isIOS || Platform.isMacOS))
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

  Widget _buildMembershipTiers(
    BuildContext context,
    WidgetRef ref,
    SnWalletSubscription? currentMembership,
  ) {
    final tiers = [
      {
        'id': 'solian.stellar.primary',
        'name': 'membershipTierStellar'.tr(),
        'price': 'membershipPriceStellar'.tr(),
        'color': Colors.blue,
      },
      {
        'id': 'solian.stellar.nova',
        'name': 'membershipTierNova'.tr(),
        'price': 'membershipPriceNova'.tr(),
        'color': Color.fromRGBO(57, 197, 187, 1),
      },
      {
        'id': 'solian.stellar.supernova',
        'name': 'membershipTierSupernova'.tr(),
        'price': 'membershipPriceSupernova'.tr(),
        'color': Colors.orange,
      },
    ];

    return Column(
      children:
          tiers.map((tier) {
            final isCurrentTier = currentMembership?.identifier == tier['id'];
            final tierColor = tier['color'] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      isCurrentTier
                          ? null
                          : () => _purchaseMembership(
                            context,
                            ref,
                            tier['id'] as String,
                          ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isCurrentTier
                              ? tierColor.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isCurrentTier
                                ? tierColor
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
                                children: [
                                  Text(
                                    tier['name'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentTier ? tierColor : null,
                                    ),
                                  ),
                                  const Gap(8),
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
                                ],
                              ),
                              Text(
                                tier['price'] as String,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Theme.of(
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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

  Future<void> _showRestorePurchaseSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => const RestorePurchaseSheet(),
    );
  }

  Future<void> _purchaseMembership(
    BuildContext context,
    WidgetRef ref,
    String tierId,
  ) async {
    final client = ref.watch(apiClientProvider);
    try {
      showLoadingModal(context);
      final resp = await client.post(
        '/id/subscriptions',
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
        '/id/subscriptions/${subscription.identifier}/order',
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
}
