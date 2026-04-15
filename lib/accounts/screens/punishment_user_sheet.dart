import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/punishment_service.dart';
import 'package:island/accounts/widgets/punishment_card.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final userPunishmentsProvider = FutureProvider.autoDispose
    .family<List<SnAccountPunishment>, String>((ref, username) async {
      final service = ref.read(punishmentServiceProvider);
      final result = await service.getPunishments(username);
      return result.items;
    });

String _getOverviewTitle(PunishmentType type) {
  return switch (type) {
    PunishmentType.permissionModification =>
      'punishmentOverviewPermissionModification'.tr(),
    PunishmentType.blockLogin => 'punishmentOverviewBlockLogin'.tr(),
    PunishmentType.disableAccount => 'punishmentOverviewDisableAccount'.tr(),
    PunishmentType.strike => 'punishmentOverviewStrike'.tr(),
  };
}

class UserPunishmentsSheet extends ConsumerWidget {
  final String username;
  final SnAccountPunishment? initialOverview;

  const UserPunishmentsSheet({
    super.key,
    required this.username,
    this.initialOverview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final punishments = ref.watch(userPunishmentsProvider(username));

    return SheetScaffold(
      showHeader: true,
      titleText: 'punishments'.tr(),
      heightFactor: 0.9,
      child: punishments.when(
        data: (list) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (initialOverview != null) ...[
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.lock,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const Gap(8),
                          Text(
                            _getOverviewTitle(initialOverview!.type),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                      if (initialOverview!.reason.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          initialOverview!.reason,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                      if (initialOverview!.expiredAt != null) ...[
                        const Gap(8),
                        Text(
                          'punishmentOverviewExpires'.tr(
                            args: [
                              DateFormat.yMd().add_Hm().format(
                                initialOverview!.expiredAt!,
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(8),
              ],
              if (list.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.verified_user,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const Gap(16),
                      Text(
                        'noPunishmentsFound',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ).tr(),
                    ],
                  ),
                )
              else
                ...list.map(
                  (p) => PunishmentCard(
                    punishment: p,
                    showAccount: false,
                    showCreator: false,
                    canDelete: false,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
