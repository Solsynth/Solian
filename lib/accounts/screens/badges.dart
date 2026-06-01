import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/badge.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final badgesProvider = FutureProvider.autoDispose<List<SnAccountBadge>>((
  ref,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getMyBadges();
});

@RoutePage()
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('badges').tr()),
      body: badgesAsync.when(
        data: (badges) {
          if (badges.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _badgeInfoBanner(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _BadgeCard(
                      badge: badge,
                      isLoading: false,
                      onActivate: () => _activateBadge(context, ref, badge.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.stars,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const Gap(16),
          Text('noBadges'.tr(), style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.error,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const Gap(16),
          Text(
            'failedToLoadBadges'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          FilledButton(
            onPressed: () => ref.invalidate(badgesProvider),
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _badgeInfoBanner(BuildContext context) {
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.info).padding(top: 4),
          Expanded(child: Text('badgeInfoDescription'.tr())),
        ],
      ),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withOpacity(0.3),
      actions: const [SizedBox.shrink()],
    );
  }

  Future<void> _activateBadge(
    BuildContext context,
    WidgetRef ref,
    String badgeId,
  ) async {
    try {
      showLoadingModal(context);
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.accounts.activateBadge(badgeId);
        ref.invalidate(badgesProvider);
      } catch (e) {
        showErrorAlert(e);
      } finally {
        if (context.mounted) {
          hideLoadingModal(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingModal(context);
        showOverlayDialog<bool>(
          builder: (context, close) => AlertDialog(
            title: Text('activationFailed'.tr()),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => close(false),
                child: Text('okay'.tr()),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _BadgeCard extends ConsumerWidget {
  final SnAccountBadge badge;
  final bool isLoading;
  final VoidCallback onActivate;

  const _BadgeCard({
    required this.badge,
    required this.isLoading,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = badge.activatedAt != null;
    final manifest = ref.watch(badgeManifestMapProvider);
    final name = getBadgeName(badge, manifest: manifest).tr();
    final description = getBadgeDescription(badge, manifest: manifest);
    final badgeColor = getBadgeColor(badge, manifest: manifest);
    final iconUrl = getBadgeIconUrl(badge, manifest: manifest);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isActive ? null : onActivate,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _BadgeCardIcon(
                  iconUrl: iconUrl,
                  color: badgeColor,
                  fallbackIcon: kBadgeTemplates[badge.type]?.icon ?? Symbols.stars,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(12),
              _buildBadgeStatus(context, isActive, badgeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeStatus(
    BuildContext context,
    bool isActive,
    Color badgeColor,
  ) {
    final theme = Theme.of(context);

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.check_circle, size: 16, color: badgeColor),
            const Gap(4),
            Text(
              'active'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return FilledButton.tonal(
      onPressed: onActivate,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.add, size: 18),
          const Gap(4),
          Text('activate'.tr()),
        ],
      ),
    );
  }
}

class _BadgeCardIcon extends ConsumerWidget {
  final String? iconUrl;
  final Color color;
  final IconData fallbackIcon;

  const _BadgeCardIcon({
    required this.iconUrl,
    required this.color,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      final serverUrl = ref.watch(serverUrlProvider);
      final fullUrl = iconUrl!.startsWith('http')
          ? iconUrl!
          : '$serverUrl$iconUrl';

      return SvgPicture.network(
        fullUrl,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (_) =>
            Icon(fallbackIcon, color: color, size: 28),
      );
    }

    return Icon(fallbackIcon, color: color, size: 28);
  }
}
