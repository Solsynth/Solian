import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AccountStatusCreationSheet extends HookConsumerWidget {
  final SnAccountStatus? initialStatus;
  const AccountStatusCreationSheet({super.key, this.initialStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attitude = useState<int>(initialStatus?.attitude ?? 1);
    final statusType = useState<int>(
      initialStatus?.type ?? SnAccountStatusType.defaultType,
    );
    final clearedAt = useState<DateTime?>(initialStatus?.clearedAt);
    final labelController = useTextEditingController(
      text: initialStatus?.label ?? '',
    );
    final symbolController = useTextEditingController(
      text: initialStatus?.symbol ?? '',
    );
    final icon = useState<IDisplayableCloudFile?>(initialStatus?.icon);
    final background = useState<IDisplayableCloudFile?>(
      initialStatus?.background,
    );

    final submitting = useState(false);

    Future<void> pickImage(String target) async {
      final result = await showModalBottomSheet<SnCloudFile>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) =>
            const CloudFilePicker(allowedTypes: {UniversalFileType.image}),
      );
      if (result == null) return;
      if (target == 'icon') {
        icon.value = result;
      } else {
        background.value = result;
      }
    }

    Future<void> clearStatus() async {
      try {
        submitting.value = true;
        final user = ref.watch(userInfoProvider);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete('/passport/accounts/me/statuses');
        if (!context.mounted) return;
        ref.invalidate(accountStatusProvider(user.value!.name));
        Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    Future<void> submitStatus() async {
      try {
        submitting.value = true;
        final user = ref.watch(userInfoProvider);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.request(
          '/passport/accounts/me/statuses',
          data: {
            'attitude': attitude.value,
            'type': statusType.value,
            'cleared_at': clearedAt.value?.toUtc().toIso8601String(),
            if (labelController.text.isNotEmpty) 'label': labelController.text,
            if (symbolController.text.isNotEmpty)
              'symbol': symbolController.text,
            if (icon.value?.id != null) 'icon_id': icon.value!.id,
            if (background.value?.id != null)
              'background_id': background.value!.id,
          },
          options: Options(method: initialStatus == null ? 'POST' : 'PATCH'),
        );
        if (user.value != null) {
          ref.invalidate(accountStatusProvider(user.value!.name));
        }
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: initialStatus == null
          ? 'statusCreate'.tr()
          : 'statusUpdate'.tr(),
      actions: [
        TextButton.icon(
          onPressed: submitting.value
              ? null
              : () {
                  submitStatus();
                },
          icon: const Icon(Symbols.upload),
          label: Text(initialStatus == null ? 'create' : 'update').tr(),
          style: ButtonStyle(
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
            ),
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (initialStatus != null)
          IconButton(
            icon: const Icon(Symbols.delete),
            onPressed: submitting.value ? null : () => clearStatus(),
            style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(24),
            TextField(
              controller: labelController,
              decoration: InputDecoration(labelText: 'statusLabel'.tr()),
              maxLength: 1024,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(16),
            TextField(
              controller: symbolController,
              decoration: InputDecoration(labelText: 'statusSymbol'.tr()),
              maxLength: 128,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(8),
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: _StatusAssetPickerTile(
                    label: 'Icon',
                    icon: Symbols.image,
                    file: icon.value,
                    onTap: () => pickImage('icon'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _StatusAssetPickerTile(
                    label: 'Background',
                    icon: Symbols.wallpaper,
                    file: background.value,
                    onTap: () => pickImage('background'),
                  ),
                ),
              ],
            ),
            const Gap(12),
            _StatusPreviewCard(
              label: labelController.text.trim(),
              symbol: symbolController.text.trim(),
              icon: icon.value,
              background: background.value,
              attitude: attitude.value,
            ),
            const SizedBox(height: 24),
            Text(
              'statusAttitude'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton(
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Symbols.sentiment_satisfied),
                  label: Text('attitudePositive'.tr()),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Symbols.sentiment_stressed),
                  label: Text('attitudeNeutral'.tr()),
                ),
                ButtonSegment(
                  value: 2,
                  icon: const Icon(Symbols.sentiment_sad),
                  label: Text('attitudeNegative'.tr()),
                ),
              ],
              selected: {attitude.value},
              onSelectionChanged: (Set<int> newSelection) {
                attitude.value = newSelection.first;
              },
            ),
            const Gap(12),
            Text(
              'statusVisibility'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: SnAccountStatusType.defaultType,
                  icon: const Icon(Symbols.circle),
                  label: Text('online'.tr()),
                ),
                ButtonSegment<int>(
                  value: SnAccountStatusType.busy,
                  icon: const Icon(Symbols.schedule),
                  label: Text('statusBusy'.tr()),
                ),
                ButtonSegment<int>(
                  value: SnAccountStatusType.doNotDisturb,
                  icon: const Icon(Symbols.do_not_disturb_on),
                  label: Text('statusNotDisturb'.tr()),
                ),
                ButtonSegment<int>(
                  value: SnAccountStatusType.invisible,
                  icon: const Icon(Symbols.visibility_off),
                  label: Text('statusInvisible'.tr()),
                ),
              ],
              selected: {statusType.value},
              onSelectionChanged: (Set<int> newSelection) {
                statusType.value = newSelection.first;
              },
            ),
            const Gap(8),
            Text(switch (statusType.value) {
              SnAccountStatusType.busy => 'statusBusyDescription'.tr(),
              SnAccountStatusType.doNotDisturb =>
                'statusNotDisturbDescription'.tr(),
              SnAccountStatusType.invisible =>
                'statusInvisibleDescription'.tr(),
              _ => 'statusVisibleDescription'.tr(),
            }).opacity(0.75),
            const SizedBox(height: 24),
            Text(
              'statusClearTime'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                clearedAt.value == null
                    ? 'statusNoAutoClear'.tr()
                    : DateFormat.yMMMd().add_jm().format(clearedAt.value!),
              ),
              trailing: const Icon(Symbols.schedule),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (date == null) return;
                if (!context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;
                clearedAt.value = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              },
            ),
            Gap(MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }
}

class _StatusAssetPickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final IDisplayableCloudFile? file;
  final VoidCallback onTap;

  const _StatusAssetPickerTile({
    required this.label,
    required this.icon,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasBackground = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
          color: colorScheme.surfaceContainerLow,
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CloudFileWidget(
                      item: file!,
                      fit: BoxFit.cover,
                      useInternalGate: false,
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colorScheme.primary),
                  const Gap(8),
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  const Gap(4),
                  Text(
                    'Tap to upload',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasBackground
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusPreviewCard extends StatelessWidget {
  final String label;
  final String symbol;
  final IDisplayableCloudFile? icon;
  final IDisplayableCloudFile? background;
  final int attitude;

  const _StatusPreviewCard({
    required this.label,
    required this.symbol,
    required this.icon,
    required this.background,
    required this.attitude,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewLabel = label.isNotEmpty ? label : 'Status preview';
    final hasMedia = icon != null || background != null;
    final hasBackground = background != null;
    final textShadow = hasBackground
        ? const [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ]
        : null;
    final statusIcon = switch (attitude) {
      0 => Symbols.sentiment_satisfied,
      2 => Symbols.sentiment_sad,
      _ => Symbols.sentiment_stressed,
    };

    if (!hasMedia) {
      return Container(
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: colorScheme.onPrimaryContainer),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (symbol.isNotEmpty)
                    Text(
                      symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final card = Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              CloudImageWidget(
                file: background,
                aspectRatio: 16 / 9,
                noBlurhash: true,
              ),
            if (background != null)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.38),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (icon != null)
                    ProfilePictureWidget(
                      file: icon,
                      radius: hasBackground ? 24 : 20,
                      borderRadius: hasBackground ? 14 : 12,
                      fallbackIcon: statusIcon,
                      fallbackColor: hasBackground ? Colors.white : null,
                    )
                  else
                    Container(
                      width: hasBackground ? 48 : 40,
                      height: hasBackground ? 48 : 40,
                      decoration: BoxDecoration(
                        color: hasBackground
                            ? Colors.white24
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          hasBackground ? 14 : 12,
                        ),
                      ),
                      child: Icon(
                        statusIcon,
                        color: hasBackground
                            ? Colors.white
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          previewLabel,
                          maxLines: hasBackground ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: hasBackground
                                    ? Colors.white
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                shadows: textShadow,
                              ),
                        ),
                        if (symbol.isNotEmpty)
                          Text(
                            symbol,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: hasBackground
                                      ? Colors.white.withOpacity(0.9)
                                      : colorScheme.onSurfaceVariant,
                                  shadows: textShadow,
                                ),
                          ),
                        Text(
                          'This is how your status will appear',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: hasBackground
                                    ? Colors.white.withOpacity(0.82)
                                    : colorScheme.onSurfaceVariant,
                                shadows: textShadow,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (hasBackground) {
      return AspectRatio(aspectRatio: 16 / 9, child: card);
    }

    return SizedBox(height: 88, child: card);
  }
}
