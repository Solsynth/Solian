import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

class PunishmentCard extends HookWidget {
  final SnAccountPunishment punishment;
  final bool showAccount;
  final bool showCreator;
  final bool canDelete;
  final VoidCallback? onDelete;

  const PunishmentCard({
    super.key,
    required this.punishment,
    this.showAccount = false,
    this.showCreator = false,
    this.canDelete = false,
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
                if (canDelete && onDelete != null)
                  IconButton(
                    icon: const Icon(Symbols.delete),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            if (showCreator && punishment.creator != null) ...[
              const Gap(8),
              AccountPfcRegion(
                uname: punishment.creator!.name,
                child: Row(
                  children: [
                    ProfilePictureWidget(
                      file: punishment.creator!.profile.picture,
                      radius: 8,
                    ),
                    const Gap(8),
                    Text('from')
                        .fontSize(12)
                        .textColor(Theme.of(context).colorScheme.primary),
                    const Gap(4),
                    AccountName(
                      account: punishment.creator!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showAccount && punishment.account != null) ...[
              const Gap(8),
              AccountPfcRegion(
                uname: punishment.account!.name,
                child: Row(
                  children: [
                    ProfilePictureWidget(
                      file: punishment.account!.profile.picture,
                      radius: 8,
                    ),
                    const Gap(8),
                    Text('to')
                        .fontSize(12)
                        .textColor(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    const Gap(4),
                    AccountName(
                      account: punishment.account!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                        ? 'Expired: ${punishment.expiredAt!.toLocal().formatSystem()}'
                        : 'Expires: ${punishment.expiredAt!.toLocal().formatSystem()}',
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
