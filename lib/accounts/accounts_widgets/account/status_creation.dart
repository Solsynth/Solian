import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/accounts/accounts_widgets/account/status.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountStatusCreationSheet extends HookConsumerWidget {
  final SnAccountStatus? initialStatus;
  const AccountStatusCreationSheet({super.key, this.initialStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attitude = useState<int>(initialStatus?.attitude ?? 1);
    final isInvisible = useState(initialStatus?.isInvisible ?? false);
    final isNotDisturb = useState(initialStatus?.isNotDisturb ?? false);
    final clearedAt = useState<DateTime?>(initialStatus?.clearedAt);
    final labelController = useTextEditingController(
      text: initialStatus?.label ?? '',
    );

    final submitting = useState(false);

    Future<void> clearStatus() async {
      try {
        submitting.value = true;
        final user = ref.watch(userInfoProvider);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete('/pass/accounts/me/statuses');
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
          '/pass/accounts/me/statuses',
          data: {
            'attitude': attitude.value,
            'is_invisible': isInvisible.value,
            'is_not_disturb': isNotDisturb.value,
            'cleared_at': clearedAt.value?.toUtc().toIso8601String(),
            if (labelController.text.isNotEmpty) 'label': labelController.text,
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
              decoration: InputDecoration(
                labelText: 'statusLabel'.tr(),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
            SwitchListTile(
              title: Text('statusInvisible'.tr()),
              subtitle: Text('statusInvisibleDescription'.tr()),
              value: isInvisible.value,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              onChanged: (bool value) {
                isInvisible.value = value;
              },
            ),
            SwitchListTile(
              title: Text('statusNotDisturb'.tr()),
              subtitle: Text('statusNotDisturbDescription'.tr()),
              value: isNotDisturb.value,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              onChanged: (bool value) {
                isNotDisturb.value = value;
              },
            ),
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
                borderRadius: BorderRadius.circular(8),
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
