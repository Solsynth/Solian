import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/punishment_service.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PunishmentCreateSheet extends HookConsumerWidget {
  const PunishmentCreateSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider).value;
    final isSuperuser = user?.isSuperuser == true;

    final selectedAccount = useState<SnAccount?>(null);
    final reasonController = useTextEditingController();
    final selectedType = useState<PunishmentType>(PunishmentType.strike);
    final expiredAt = useState<DateTime?>(null);
    final blockedPermissions = useState<List<String>>([]);
    final permissionController = useTextEditingController();
    final socialCreditReductionController = useTextEditingController();
    final isLoading = useState(false);

    if (!isSuperuser) {
      selectedAccount.value = user;
    }

    return SheetScaffold(
      showHeader: true,
      titleText: 'createPunishment'.tr(),
      actions: [
        TextButton(
          onPressed: () async {
            if (reasonController.text.isEmpty) {
              showSnackBar('punishmentReasonRequired'.tr());
              return;
            }
            if (selectedAccount.value == null) {
              showSnackBar('selectAccountRequired'.tr());
              return;
            }

            isLoading.value = true;
            try {
              final service = ref.read(punishmentServiceProvider);
              final socialCreditReduction = double.tryParse(
                socialCreditReductionController.text,
              );
              await service.createPunishment(
                username: selectedAccount.value!.name,
                reason: reasonController.text,
                type: selectedType.value,
                expiredAt: expiredAt.value,
                blockedPermissions:
                    selectedType.value == PunishmentType.permissionModification
                    ? blockedPermissions.value
                    : null,
                socialCreditReduction: socialCreditReduction,
              );
              if (!context.mounted) return;
              showSnackBar('punishmentCreated'.tr());
              Navigator.of(context).pop(true);
            } catch (e) {
              showErrorAlert(e);
            } finally {
              isLoading.value = false;
            }
          },
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('create'.tr()),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isSuperuser) ...[
            Text(
              'targetAccount'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  selectedAccount.value != null ? 6 : 0,
                ),
                leading: selectedAccount.value != null
                    ? ProfilePictureWidget(
                        file: selectedAccount.value!.profile.picture,
                        radius: 16,
                      )
                    : const Icon(Symbols.person_search),
                title: Text(
                  selectedAccount.value?.nick ?? 'selectAccount'.tr(),
                ),
                subtitle: selectedAccount.value != null
                    ? Text('@${selectedAccount.value!.name}')
                    : null,
                trailing: const Icon(Symbols.chevron_right),
                onTap: () async {
                  final account = await showModalBottomSheet<SnAccount>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (context) => const AccountPickerSheet(),
                  );
                  if (account != null) {
                    selectedAccount.value = account;
                  }
                },
              ),
            ),
            const Gap(8),
          ],
          Text(
            'punishmentReason'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          TextField(
            controller: reasonController,
            maxLines: 3,
            maxLength: 8192,
            decoration: InputDecoration(hintText: 'punishmentReasonHint'.tr()),
          ),
          const Gap(16),
          Text(
            'punishmentType'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          DropdownButtonFormField<PunishmentType>(
            value: selectedType.value,
            items: PunishmentType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getTypeName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                selectedType.value = value;
              }
            },
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'punishmentExpiresAt'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Gap(4),
                    Text(
                      'optionalField'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (expiredAt.value != null)
                TextButton(
                  onPressed: () => expiredAt.value = null,
                  child: Text('clear'.tr()),
                ),
            ],
          ),
          const Gap(8),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    expiredAt.value ??
                    DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 0, minute: 0),
              );
              if (time == null) return;
              expiredAt.value = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            },
            icon: const Icon(Symbols.event),
            label: Text(
              expiredAt.value != null
                  ? expiredAt.value!.toLocal().toString().split('.').first
                  : 'selectDate'.tr(),
            ),
          ),
          if (selectedType.value == PunishmentType.permissionModification) ...[
            const Gap(16),
            Text(
              'punishmentBlockedPermissions'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(4),
            Text(
              'punishmentBlockedPermissionsHint'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: permissionController,
                    decoration: InputDecoration(
                      hintText: 'e.g. chat.send, drive.*',
                    ),
                  ),
                ),
                const Gap(8),
                IconButton(
                  onPressed: () {
                    final perm = permissionController.text.trim();
                    if (perm.isNotEmpty &&
                        !blockedPermissions.value.contains(perm)) {
                      blockedPermissions.value = [
                        ...blockedPermissions.value,
                        perm,
                      ];
                      permissionController.clear();
                    }
                  },
                  icon: const Icon(Symbols.add),
                ),
              ],
            ),
            if (blockedPermissions.value.isNotEmpty) ...[
              const Gap(8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: blockedPermissions.value
                    .map(
                      (p) => Chip(
                        label: Text(p),
                        onDeleted: () {
                          blockedPermissions.value = blockedPermissions.value
                              .where((e) => e != p)
                              .toList();
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
          const Gap(16),
          Text(
            'socialCreditReduction'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(4),
          Text(
            'optionalField'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          TextField(
            controller: socialCreditReductionController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 100',
              suffixText: 'credits',
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(PunishmentType type) {
    switch (type) {
      case PunishmentType.permissionModification:
        return 'punishmentTypePermissionModification'.tr();
      case PunishmentType.blockLogin:
        return 'punishmentTypeBlockLogin'.tr();
      case PunishmentType.disableAccount:
        return 'punishmentTypeDisableAccount'.tr();
      case PunishmentType.strike:
        return 'punishmentTypeStrike'.tr();
    }
  }
}
