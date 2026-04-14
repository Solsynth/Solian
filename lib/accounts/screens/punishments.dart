import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/punishment_service.dart';
import 'package:island/accounts/screens/punishment_create_sheet.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final punishmentsNotifierProvider = AsyncNotifierProvider.autoDispose(
  PunishmentsNotifier.new,
);

class PunishmentsNotifier extends AsyncNotifier<List<SnAccountPunishment>> {
  @override
  FutureOr<List<SnAccountPunishment>> build() async {
    final user = ref.read(userInfoProvider).value;
    if (user == null) return [];

    final service = ref.read(punishmentServiceProvider);
    return service.getPunishments(user.name);
  }

  Future<void> deletePunishment(String punishmentId) async {
    final user = ref.read(userInfoProvider).value;
    if (user == null) return;

    final service = ref.read(punishmentServiceProvider);
    await service.deletePunishment(user.name, punishmentId);
    ref.invalidateSelf();
  }
}

@RoutePage()
class PunishmentsScreen extends HookConsumerWidget {
  const PunishmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final punishments = ref.watch(punishmentsNotifierProvider);
    final user = ref.watch(userInfoProvider).value;
    final isSuperuser = user?.isSuperuser == true;

    return AppScaffold(
      appBar: AppBar(title: Text('punishments').tr()),
      floatingActionButton: isSuperuser
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Symbols.add),
              label: Text('createPunishment'.tr()),
            )
          : null,
      body: punishments.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.verified_user,
                    size: 64,
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final punishment = list[index];
              return _PunishmentCard(
                punishment: punishment,
                isSuperuser: isSuperuser,
                onDelete: isSuperuser
                    ? () => _confirmDelete(context, ref, punishment.id)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(punishmentsNotifierProvider),
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const PunishmentCreateSheet(),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String punishmentId,
  ) async {
    final confirmed = await showConfirmAlert(
      'deletePunishmentConfirm'.tr(),
      'deletePunishment'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    await ref
        .read(punishmentsNotifierProvider.notifier)
        .deletePunishment(punishmentId);
    if (!context.mounted) return;
    showSnackBar('punishmentDeleted'.tr());
  }
}

class _PunishmentCard extends HookWidget {
  final SnAccountPunishment punishment;
  final bool isSuperuser;
  final VoidCallback? onDelete;

  const _PunishmentCard({
    required this.punishment,
    required this.isSuperuser,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getTypeInfo(punishment.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeInfo.$1.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeInfo.$2, color: typeInfo.$1, size: 20),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeInfo.$3,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        punishment.createdAt.toLocal().formatSystem(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSuperuser && onDelete != null)
                  IconButton(
                    icon: const Icon(Symbols.delete),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            const Gap(12),
            Text(
              punishment.reason,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (punishment.blockedPermissions?.isNotEmpty == true) ...[
              const Gap(8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: punishment.blockedPermissions!
                    .map(
                      (p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (punishment.expiredAt != null) ...[
              const Gap(8),
              Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    size: 14,
                    color: punishment.expiredAt!.isBefore(DateTime.now())
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Gap(4),
                  Text(
                    punishment.expiredAt!.isBefore(DateTime.now())
                        ? 'expiredAt'.tr(
                            args: [
                              punishment.expiredAt!.toLocal().formatSystem(),
                            ],
                          )
                        : 'expiresAt'.tr(
                            args: [
                              punishment.expiredAt!.toLocal().formatSystem(),
                            ],
                          ),
                    style: TextStyle(
                      fontSize: 12,
                      color: punishment.expiredAt!.isBefore(DateTime.now())
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _getTypeInfo(PunishmentType type) {
    switch (type) {
      case PunishmentType.permissionModification:
        return (
          Colors.orange,
          Symbols.block,
          'punishmentTypePermissionModification'.tr(),
        );
      case PunishmentType.blockLogin:
        return (Colors.red, Symbols.lock, 'punishmentTypeBlockLogin'.tr());
      case PunishmentType.disableAccount:
        return (
          Colors.deepPurple,
          Symbols.person_off,
          'punishmentTypeDisableAccount'.tr(),
        );
      case PunishmentType.strike:
        return (Colors.amber, Symbols.warning, 'punishmentTypeStrike'.tr());
    }
  }
}
