import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/accounts/widgets/account/status_card.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// How the status expires. Presets are resolved against the moment of
/// submission, not against the moment they were tapped, so a sheet left open
/// does not publish a status that has already expired.
enum _ClearPreset { never, in30Minutes, inOneHour, inFourHours, custom }

class AccountStatusCreationSheet extends HookConsumerWidget {
  final SnAccountStatus? initialStatus;
  const AccountStatusCreationSheet({super.key, this.initialStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = initialStatus != null;

    final attitude = useState<int>(initialStatus?.attitude ?? 1);
    final statusType = useState<int>(
      initialStatus?.type ?? SnAccountStatusType.defaultType,
    );
    final clearPreset = useState<_ClearPreset>(
      initialStatus?.clearedAt == null
          ? _ClearPreset.never
          : _ClearPreset.custom,
    );
    final customClearedAt = useState<DateTime?>(initialStatus?.clearedAt);
    final labelController = useTextEditingController(
      text: initialStatus?.label ?? '',
    );
    final symbolController = useTextEditingController(
      text: initialStatus?.symbol ?? '',
    );
    // Listening to the controllers is what makes the card below live; reading
    // `.text` during build alone leaves it frozen at the initial value.
    final label = useValueListenable(labelController).text.trim();
    final symbol = useValueListenable(symbolController).text.trim();
    final icon = useState<IDisplayableCloudFile?>(initialStatus?.icon);
    final background = useState<IDisplayableCloudFile?>(
      initialStatus?.background,
    );

    final submitting = useState(false);

    DateTime? resolveClearedAt(DateTime now) => switch (clearPreset.value) {
      _ClearPreset.never => null,
      _ClearPreset.in30Minutes => now.add(const Duration(minutes: 30)),
      _ClearPreset.inOneHour => now.add(const Duration(hours: 1)),
      _ClearPreset.inFourHours => now.add(const Duration(hours: 4)),
      _ClearPreset.custom => customClearedAt.value,
    };

    String typeLabel() => switch (statusType.value) {
      SnAccountStatusType.busy => 'statusBusy'.tr(),
      SnAccountStatusType.doNotDisturb => 'statusNotDisturb'.tr(),
      SnAccountStatusType.invisible => 'statusInvisible'.tr(),
      _ => 'online'.tr(),
    };

    Future<void> pickImage({required bool forBackground}) async {
      final result = await showModalBottomSheet<SnCloudFile>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) =>
            const CloudFilePicker(allowedTypes: {UniversalFileType.image}),
      );
      if (result == null) return;
      if (forBackground) {
        background.value = result;
      } else {
        icon.value = result;
      }
    }

    Future<void> pickCustomClearTime() async {
      final now = DateTime.now();
      final current = customClearedAt.value;
      final seed = (current != null && current.isAfter(now))
          ? current
          : now.add(const Duration(hours: 1));

      final date = await showDatePicker(
        context: context,
        initialDate: seed,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (date == null || !context.mounted) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(seed),
      );
      if (time == null) return;

      final picked = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      // The pickers happily return "today, earlier". A clear time in the past
      // would publish a status that disappears instantly, so keep the nearest
      // usable moment — the resolved time is shown right next to the chips.
      customClearedAt.value = picked.isAfter(now)
          ? picked
          : now.add(const Duration(minutes: 5));
      clearPreset.value = _ClearPreset.custom;
    }

    Future<void> deleteStatus() async {
      final confirmed = await showConfirmAlert(
        'statusDeleteHint'.tr(),
        'delete'.tr(),
        isDanger: true,
      );
      if (!confirmed) return;

      final apiClient = ref.read(apiClientProvider);
      final name = ref.read(userInfoProvider).value?.name;
      try {
        submitting.value = true;
        await apiClient.delete('/stargate/accounts/me/statuses');
        ref.read(currentAccountStatusProvider.notifier).clearStatus();
        if (name != null) ref.invalidate(accountStatusProvider(name));
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    Future<void> submitStatus() async {
      if (submitting.value) return;
      final apiClient = ref.read(apiClientProvider);
      final name = ref.read(userInfoProvider).value?.name;
      final clearedAt = resolveClearedAt(DateTime.now());

      try {
        submitting.value = true;
        final response = await apiClient.request(
          '/stargate/accounts/me/statuses',
          data: {
            'attitude': attitude.value,
            'type': statusType.value,
            'cleared_at': clearedAt?.toUtc().toIso8601String(),
            'label': label,
            'symbol': symbol.isEmpty ? null : symbol,
            'icon_id': icon.value?.id,
            'background_id': background.value?.id,
          },
          options: Options(method: isEditing ? 'PATCH' : 'POST'),
        );
        final updated = _tryParseStatus(response.data);
        if (updated != null) {
          // Publish locally first so every surface updates without a refetch.
          ref.read(currentAccountStatusProvider.notifier).setStatus(updated);
        }
        if (name != null) ref.invalidate(accountStatusProvider(name));
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    final previewClearedAt = resolveClearedAt(DateTime.now());

    final sectionStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: SolSpace.md),
        child: Text(title, style: sectionStyle),
      );
    }

    Widget optionTile({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      IconData? icon,
      double height = 48,
    }) {
      return Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SolRadius.sm),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SolRadius.sm),
              color: selected
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
                  : Colors.transparent,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SolSpace.sm),
              child: icon == null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          fill: 1,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const Gap(SolSpace.xxs),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    final attitudeOptions = [
      (
        value: 0,
        icon: Symbols.sunny_rounded,
        label: 'attitudePositive'.tr(),
      ),
      (
        value: 1,
        icon: Symbols.circle_rounded,
        label: 'attitudeNeutral'.tr(),
      ),
      (
        value: 2,
        icon: Symbols.rainy_rounded,
        label: 'attitudeNegative'.tr(),
      ),
    ];

    final presenceOptions = [
      (type: SnAccountStatusType.defaultType, label: 'online'.tr()),
      (type: SnAccountStatusType.busy, label: 'statusBusy'.tr()),
      (type: SnAccountStatusType.doNotDisturb, label: 'statusNotDisturb'.tr()),
      (type: SnAccountStatusType.invisible, label: 'statusInvisible'.tr()),
    ];

    final clearOptions = [
      (preset: _ClearPreset.never, label: 'statusNoAutoClear'.tr()),
      (
        preset: _ClearPreset.in30Minutes,
        label: 'minutesAbbrev'.tr(args: ['30']),
      ),
      (preset: _ClearPreset.inOneHour, label: 'hoursAbbrev'.tr(args: ['1'])),
      (preset: _ClearPreset.inFourHours, label: 'hoursAbbrev'.tr(args: ['4'])),
      (
        preset: _ClearPreset.custom,
        label:
            clearPreset.value == _ClearPreset.custom &&
                customClearedAt.value != null
            ? DateFormat.MMMd().add_jm().format(customClearedAt.value!)
            : 'custom'.tr(),
      ),
    ];

    return SheetScaffold(
      heightFactor: 0.92,
      titleText: isEditing ? 'statusUpdate'.tr() : 'statusCreate'.tr(),
      actions: [
        TextButton.icon(
          onPressed: submitting.value ? null : submitStatus,
          icon: submitting.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.upload_rounded, size: 18, fill: 1),
          label: Text(isEditing ? 'update'.tr() : 'create'.tr()),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SolSpace.xl,
          SolSpace.sm,
          SolSpace.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Same widgets the profile renders, in the same order: a status
            // without artwork is a compact line, and only artwork earns the
            // full card. The preview can therefore never drift from reality.
            if (icon.value == null && background.value == null)
              AccountStatusInline(
                indicatorIcon: Symbols.circle_rounded,
                indicatorColor: colorScheme.primary,
                title: label.isNotEmpty ? label : typeLabel(),
                attitude: attitude.value,
                meta: previewClearedAt == null
                    ? null
                    : DateFormat.MMMd().add_jm().format(previewClearedAt),
                padding: EdgeInsets.zero,
              )
            else
              AccountStatusCard(
                title: label.isNotEmpty ? label : typeLabel(),
                subtitle: symbol,
                trailingText: previewClearedAt == null
                    ? null
                    : DateFormat.MMMd().add_jm().format(previewClearedAt),
                trailingIcon: previewClearedAt == null
                    ? null
                    : Symbols.schedule_rounded,
                icon: icon.value,
                background: background.value,
                indicatorIcon: Symbols.circle_rounded,
                attitude: attitude.value,
              ),
            const Gap(SolSpace.xl),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'statusLabel'.tr(),
                hintText: 'statusCreateHint'.tr(),
              ),
              minLines: 1,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(1024)],
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(SolSpace.md),
            TextField(
              controller: symbolController,
              decoration: InputDecoration(labelText: 'statusSymbol'.tr()),
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(128)],
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(SolSpace.xxl),

            sectionHeader('statusAppearance'.tr()),
            Row(
              children: [
                Expanded(
                  child: _StatusAssetTile(
                    label: 'statusIcon'.tr(),
                    icon: Symbols.image_rounded,
                    file: icon.value,
                    onTap: () => pickImage(forBackground: false),
                    onRemove: icon.value == null
                        ? null
                        : () => icon.value = null,
                  ),
                ),
                const Gap(SolSpace.md),
                Expanded(
                  child: _StatusAssetTile(
                    label: 'statusBackground'.tr(),
                    icon: Symbols.wallpaper_rounded,
                    file: background.value,
                    onTap: () => pickImage(forBackground: true),
                    onRemove: background.value == null
                        ? null
                        : () => background.value = null,
                  ),
                ),
              ],
            ),
            const Gap(SolSpace.xxl),

            sectionHeader('statusAttitude'.tr()),
            Row(
              spacing: SolSpace.md,
              children: [
                for (final option in attitudeOptions)
                  Expanded(
                    child: optionTile(
                      label: option.label,
                      icon: option.icon,
                      height: 64,
                      selected: attitude.value == option.value,
                      onTap: () => attitude.value = option.value,
                    ),
                  ),
              ],
            ),
            const Gap(SolSpace.xxl),

            sectionHeader('statusVisibility'.tr()),
            Row(
              children: [
                Expanded(
                  child: optionTile(
                    label: presenceOptions[0].label,
                    selected: statusType.value == presenceOptions[0].type,
                    onTap: () => statusType.value = presenceOptions[0].type,
                  ),
                ),
                const Gap(SolSpace.md),
                Expanded(
                  child: optionTile(
                    label: presenceOptions[1].label,
                    selected: statusType.value == presenceOptions[1].type,
                    onTap: () => statusType.value = presenceOptions[1].type,
                  ),
                ),
              ],
            ),
            const Gap(SolSpace.md),
            Row(
              children: [
                Expanded(
                  child: optionTile(
                    label: presenceOptions[2].label,
                    selected: statusType.value == presenceOptions[2].type,
                    onTap: () => statusType.value = presenceOptions[2].type,
                  ),
                ),
                const Gap(SolSpace.md),
                Expanded(
                  child: optionTile(
                    label: presenceOptions[3].label,
                    selected: statusType.value == presenceOptions[3].type,
                    onTap: () => statusType.value = presenceOptions[3].type,
                  ),
                ),
              ],
            ),
            const Gap(SolSpace.sm),
            Text(
              switch (statusType.value) {
                SnAccountStatusType.busy => 'statusBusyDescription'.tr(),
                SnAccountStatusType.doNotDisturb =>
                  'statusNotDisturbDescription'.tr(),
                SnAccountStatusType.invisible =>
                  'statusInvisibleDescription'.tr(),
                _ => 'statusVisibleDescription'.tr(),
              },
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(SolSpace.xxl),

            sectionHeader('statusClearTime'.tr()),
            Wrap(
              spacing: SolSpace.sm,
              runSpacing: SolSpace.sm,
              children: [
                for (final option in clearOptions)
                  ChoiceChip(
                    label: Text(option.label),
                    showCheckmark: false,
                    selected: clearPreset.value == option.preset,
                    onSelected: (_) {
                      if (option.preset == _ClearPreset.custom) {
                        pickCustomClearTime();
                      } else {
                        clearPreset.value = option.preset;
                      }
                    },
                  ),
              ],
            ),
            if (isEditing) ...[
              const Gap(SolSpace.xl),
              Center(
                child: TextButton.icon(
                  onPressed: submitting.value ? null : deleteStatus,
                  icon: const Icon(Symbols.delete_rounded, size: 18, fill: 1),
                  label: Text('delete'.tr()),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              ),
            ],
            Gap(MediaQuery.of(context).padding.bottom + SolSpace.xxl),
          ],
        ),
      ),
    );
  }
}

SnAccountStatus? _tryParseStatus(Object? data) {
  if (data is! Map) return null;
  try {
    return SnAccountStatus.fromJson(Map<String, dynamic>.from(data));
  } catch (_) {
    // The server answers with the new status, but an empty 204 body or a
    // changed envelope must not fail a write that already succeeded.
    return null;
  }
}

class _StatusAssetTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final IDisplayableCloudFile? file;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _StatusAssetTile({
    required this.label,
    required this.icon,
    required this.file,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = BorderRadius.all(Radius.circular(12));

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          height: 104,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colorScheme.outlineVariant),
            color: colorScheme.surfaceContainerLow,
          ),
          child: file == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: colorScheme.primary, fill: 1),
                    const Gap(SolSpace.xs),
                    Text(label, style: theme.textTheme.titleSmall),
                    const Gap(SolSpace.xxs),
                    Text(
                      'statusTapToUpload'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CloudFileWidget(
                        item: file!,
                        fit: BoxFit.cover,
                        useInternalGate: false,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      Positioned(
                        left: SolSpace.sm,
                        right: SolSpace.sm,
                        bottom: SolSpace.sm,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(
                          top: SolSpace.xs,
                          right: SolSpace.xs,
                          child: Material(
                            color: colorScheme.surface.withValues(alpha: 0.9),
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: onRemove,
                              child: Padding(
                                padding: const EdgeInsets.all(SolSpace.xs),
                                child: Icon(
                                  Symbols.close_rounded,
                                  size: 14,
                                  fill: 1,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
