import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/punishment_service.dart';
import 'package:island/accounts/screens/punishment_create_sheet.dart';
import 'package:island/accounts/widgets/punishment_card.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final punishmentsNotifierProvider = AsyncNotifierProvider.autoDispose(
  PunishmentsNotifier.new,
);

final punishmentAdminModeProvider =
    NotifierProvider<PunishmentAdminModeNotifier, bool>(
      PunishmentAdminModeNotifier.new,
    );

class PunishmentAdminModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setAdminMode(bool value) => state = value;
}

class PunishmentsNotifier
    extends AsyncNotifier<PaginationState<SnAccountPunishment>>
    with AsyncPaginationController<SnAccountPunishment> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnAccountPunishment>> build() async {
    final user = ref.read(userInfoProvider).value;
    if (user == null) {
      return PaginationState(
        items: [],
        isLoading: false,
        isReloading: false,
        totalCount: 0,
        hasMore: false,
        cursor: null,
      );
    }

    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnAccountPunishment>> fetch() async {
    final user = ref.read(userInfoProvider).value;
    if (user == null) return [];

    final isAdminMode = ref.read(punishmentAdminModeProvider);
    final service = ref.read(punishmentServiceProvider);

    final result = isAdminMode
        ? await service.getAdminCreatedPunishments(
            offset: fetchedCount,
            take: pageSize,
          )
        : await service.getPunishments(
            user.name,
            offset: fetchedCount,
            take: pageSize,
          );

    totalCount = result.totalCount;
    return result.items;
  }

  Future<void> deletePunishment(String punishmentId, String accountId) async {
    final service = ref.read(punishmentServiceProvider);
    await service.deletePunishment(accountId, punishmentId);
    ref.invalidateSelf();
  }
}

@RoutePage()
class PunishmentsScreen extends HookConsumerWidget {
  const PunishmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider).value;
    final isSuperuser = user?.isSuperuser == true;
    final isAdminMode = ref.watch(punishmentAdminModeProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(isAdminMode ? 'adminPunishments'.tr() : 'punishments'.tr()),
        actions: isSuperuser
            ? [
                IconButton(
                  icon: Icon(
                    isAdminMode ? Symbols.person : Symbols.admin_panel_settings,
                  ),
                  onPressed: () {
                    ref.read(punishmentAdminModeProvider.notifier).toggle();
                    ref.invalidate(punishmentsNotifierProvider);
                  },
                  tooltip: isAdminMode
                      ? 'myPunishments'.tr()
                      : 'adminPunishments'.tr(),
                ),
                const Gap(8),
              ]
            : null,
      ),
      floatingActionButton: isSuperuser
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(context, ref),
              icon: const Icon(Symbols.add),
              label: Text('createPunishment'.tr()),
            )
          : null,
      body: PaginationList<SnAccountPunishment>(
        padding: const EdgeInsets.symmetric(vertical: 8),
        provider: punishmentsNotifierProvider,
        notifier: punishmentsNotifierProvider.notifier,
        itemBuilder: (context, idx, punishment) {
          return PunishmentCard(
            punishment: punishment,
            showAccount: true,
            showCreator: true,
            canDelete: isSuperuser && isAdminMode,
            onDelete: isSuperuser && isAdminMode
                ? () => _confirmDelete(context, ref, punishment)
                : null,
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const PunishmentCreateSheet(),
    ).then((_) {
      ref.invalidate(punishmentsNotifierProvider);
    });
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SnAccountPunishment punishment,
  ) async {
    final confirmed = await showConfirmAlert(
      'deletePunishmentConfirm'.tr(),
      'deletePunishment'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    await ref
        .read(punishmentsNotifierProvider.notifier)
        .deletePunishment(punishment.id, punishment.accountId);
    if (!context.mounted) return;
    showSnackBar('punishmentDeleted'.tr());
  }
}
