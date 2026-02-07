import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class AbuseReportSheet extends HookConsumerWidget {
  final String resourceIdentifier;
  final String? initialReason;

  const AbuseReportSheet({
    super.key,
    required this.resourceIdentifier,
    this.initialReason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reasonController = useTextEditingController(
      text: initialReason ?? '',
    );
    final selectedType = useState<int>(0);
    final isSubmitting = useState<bool>(false);

    final reportTypes = [
      {'value': 0, 'label': 'abuseReportTypeCopyright'.tr()},
      {'value': 1, 'label': 'abuseReportTypeHarassment'.tr()},
      {'value': 2, 'label': 'abuseReportTypeImpersonation'.tr()},
      {'value': 3, 'label': 'abuseReportTypeOffensiveContent'.tr()},
      {'value': 4, 'label': 'abuseReportTypeSpam'.tr()},
      {'value': 5, 'label': 'abuseReportTypePrivacyViolation'.tr()},
      {'value': 6, 'label': 'abuseReportTypeIllegalContent'.tr()},
      {'value': 7, 'label': 'abuseReportTypeOther'.tr()},
    ];

    Future<void> submitReport() async {
      isSubmitting.value = true;

      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/pass/safety/reports',
          data: {
            'resource_identifier': resourceIdentifier,
            'type': selectedType.value,
            'reason': reasonController.text.trim(),
          },
        );

        if (context.mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (contextDialog) => AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 36,
              ),
              title: Text('abuseReportSuccessTitle'.tr()),
              content: Text('abuseReportSuccess'.tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(contextDialog).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSubmitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'abuseReportTitle'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.info,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'abuseReportDescription'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Report type selection
            Text(
              'abuseReportType'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            ...reportTypes.map((type) {
              return RadioListTile<int>(
                value: type['value'] as int,
                groupValue: selectedType.value,
                onChanged: (value) => selectedType.value = value!,
                title: Text(type['label'] as String),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }),
            const Gap(24),

            // Reason text field
            Text(
              'abuseReportReason'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'abuseReportReasonHint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const Gap(24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting.value ? null : submitReport,
                child: isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('abuseReportSubmit'.tr()),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
