import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/badge.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final badgesProvider = FutureProvider.autoDispose<List<SnAccountBadge>>((
  ref,
) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/passport/accounts/me/badges');
  final data = response.data;
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => SnAccountBadge.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return const [];
});

class ActivateBadgeNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> activate(String badgeId) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/passport/accounts/me/badges/$badgeId/active');
      ref.invalidate(badgesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final activateBadgeProvider =
    AsyncNotifierProvider<ActivateBadgeNotifier, void>(
      ActivateBadgeNotifier.new,
    );

@RoutePage()
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);
    final activateState = ref.watch(activateBadgeProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('badges').tr()),
      body: badgesAsync.when(
        data: (badges) {
          if (badges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, size: 64, color: Colors.grey),
                  const Gap(16),
                  Text('noBadges'.tr()),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isActive = badge.activatedAt != null;
              final template = kBadgeTemplates[badge.type];
              final name = template?.name.tr() ?? badge.label ?? 'unknown'.tr();
              final templateDesc = template?.description.tr();
              final badgeCaption = badge.caption;
              final description = [
                if (templateDesc != null && templateDesc.isNotEmpty)
                  templateDesc,
                if (badgeCaption != null && badgeCaption.isNotEmpty)
                  badgeCaption,
              ].join('\n');

              Color badgeColor;
              if (badge.type == 'sponsor') {
                final levelStr = badge.meta['level']?.toString() ?? '0';
                final level = int.tryParse(levelStr) ?? 0;
                badgeColor = _getSponsorColor(level);
              } else {
                badgeColor = template?.color ?? Colors.blue;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      template?.icon ?? Icons.stars,
                      color: badgeColor,
                    ),
                  ),
                  title: Text(name),
                  subtitle: description.isNotEmpty ? Text(description) : null,
                  trailing: isActive
                      ? Chip(
                          label: Text('active'.tr()),
                          backgroundColor: badgeColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: badgeColor,
                            fontSize: 12,
                          ),
                        )
                      : activateState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: () =>
                              _activateBadge(context, ref, badge.id),
                          child: Text('activate'.tr()),
                        ),
                  onTap: isActive
                      ? null
                      : () => _activateBadge(context, ref, badge.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('failedToLoadBadges'.tr()),
              const Gap(8),
              TextButton(
                onPressed: () => ref.invalidate(badgesProvider),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _activateBadge(
    BuildContext context,
    WidgetRef ref,
    String badgeId,
  ) async {
    try {
      showLoadingModal(context);
      await ref.read(activateBadgeProvider.notifier).activate(badgeId);
      if (context.mounted) {
        hideLoadingModal(context);
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

Color _getSponsorColor(int level) {
  final clampedLevel = level.clamp(0, 36);
  final t = clampedLevel / 36.0;
  const redColor = Colors.red;
  const goldenColor = Color(0xFFDAA520);
  return Color.lerp(redColor, goldenColor, t)!;
}
