import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/restore_purchase_sheet.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/payment/payment_overlay.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'leveling.g.dart';

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

@riverpod
class LevelingHistoryNotifier extends _$LevelingHistoryNotifier
    with CursorPagingNotifierMixin<SnExperienceRecord> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnExperienceRecord>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnExperienceRecord>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/id/accounts/me/leveling',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final records =
        data.map((json) => SnExperienceRecord.fromJson(json)).toList();

    final hasMore = offset + records.length < total;
    final nextCursor = hasMore ? (offset + records.length).toString() : null;

    return CursorPagingData(
      items: records,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class LevelingScreen extends HookConsumerWidget {
  const LevelingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    if (user.value == null) {
      return AppScaffold(
        appBar: AppBar(title: Text('levelingProgress'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('levelingProgress'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'leveling'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor!,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'stellarProgram'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor!,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelingTab(context, ref, user.value!),
            _buildStellarProgramTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelingTab(
    BuildContext context,
    WidgetRef ref,
    SnAccount user,
  ) {
    final currentLevel = user.profile.level;
    final currentExp = user.profile.experience;
    final progress = user.profile.levelingProgress;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(maxWidth: 480),
        child: CustomScrollView(
          slivers: [
            const SliverGap(20),

            // Current Progress Card
            SliverToBoxAdapter(
              child: LevelingProgressCard(
                level: currentLevel,
                experience: currentExp,
                progress: progress,
              ),
            ),
            const SliverGap(24),

            // Level Stairs Graph
            SliverToBoxAdapter(
              child: Text(
                'levelProgress'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverGap(16),

            // Stairs visualization with fixed height and horizontal scroll
            SliverToBoxAdapter(child: _buildLevelStairs(context, currentLevel)),
            const SliverGap(24),

            // Leveling History
            SliverToBoxAdapter(
              child: Text(
                'levelingHistory'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverGap(8),
            PagingHelperSliverView(
              provider: levelingHistoryNotifierProvider,
              futureRefreshable: levelingHistoryNotifierProvider.future,
              notifierRefreshable: levelingHistoryNotifierProvider.notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => SliverList.builder(
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }
                      final record = data.items[index];
                      return ListTile(
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(record.reason),
                            Row(
                              spacing: 4,
                              children: [
                                Text(
                                  record.createdAt.formatRelative(context),
                                ).fontSize(13),
                                Text('·').fontSize(13).bold(),
                                Text(
                                  record.createdAt.formatSystem(),
                                ).fontSize(13),
                              ],
                            ).opacity(0.8),
                          ],
                        ),
                        subtitle: Row(
                          spacing: 8,
                          children: [
                            Text(
                              '${record.delta > 0 ? '+' : ''}${record.delta} EXP',
                            ),
                            if (record.bonusMultiplier != 1.0)
                              Text('x${record.bonusMultiplier}'),
                          ],
                        ),
                        minTileHeight: 56,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4),
                      );
                    },
                  ),
            ),

            SliverGap(getTabbedPadding(context, vertical: 20).vertical),
          ],
        ),
      ),
    );
  }

  Widget _buildStellarProgramTab(BuildContext context, WidgetRef ref) {
    final stellarSubscription = ref.watch(accountStellarSubscriptionProvider);

    return SingleChildScrollView(
      padding: getTabbedPadding(context, horizontal: 20, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMembershipSection(context, ref, stellarSubscription),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelStairs(BuildContext context, int currentLevel) {
    const totalLevels = 14;
    const stairHeight = 20.0;
    const stairWidth = 50.0;
    const containerHeight = 280.0;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: (totalLevels * (stairWidth + 8)) + 40,
          height: containerHeight,
          child: CustomPaint(
            painter: LevelStairsPainter(
              currentLevel: currentLevel,
              totalLevels: totalLevels,
              primaryColor: Theme.of(context).colorScheme.primary,
              surfaceColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              onSurfaceColor: Theme.of(context).colorScheme.onSurface,
              stairHeight: stairHeight,
              stairWidth: stairWidth,
            ),
            child: Stack(
              children: List.generate(totalLevels, (index) {
                final level = index + 1;
                final isCompleted = level <= currentLevel;
                final isCurrent = level == currentLevel;

                // Calculate position from bottom
                final bottomPosition = 0.0;
                final leftPosition = 20.0 + (index * (stairWidth + 8));

                // Make higher levels progressively taller
                final progressiveHeight =
                    40.0 + (index * 15.0); // Base height + progressive increase

                return Positioned(
                  left: leftPosition,
                  bottom: bottomPosition,
                  child: Container(
                    width: stairWidth,
                    height: progressiveHeight,
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      border:
                          isCurrent
                              ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : null,
                      boxShadow:
                          isCurrent
                              ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Text(
                            level.toString(),
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  isCompleted
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isCurrent) ...[
                            const Gap(4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
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

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.star : Icons.star_border,
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
      ),
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

class LevelStairsPainter extends CustomPainter {
  final int currentLevel;
  final int totalLevels;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double stairHeight;
  final double stairWidth;

  LevelStairsPainter({
    required this.currentLevel,
    required this.totalLevels,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.stairHeight,
    required this.stairWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = surfaceColor.withOpacity(0.2)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw connecting lines between stairs
    for (int i = 0; i < totalLevels - 1; i++) {
      final startX = 20.0 + (i * (stairWidth + 8)) + stairWidth;
      final startHeight =
          40.0 + (i * 15.0); // Progressive height for current stair
      final startY = size.height - (20.0 + startHeight);

      final endX = 20.0 + ((i + 1) * (stairWidth + 8));
      final endHeight =
          40.0 + ((i + 1) * 15.0); // Progressive height for next stair
      final endY = size.height - (20.0 + endHeight);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
