import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class TicketCreateSheet extends HookConsumerWidget {
  final String? resourceIdentifier;
  final String? initialTitle;

  const TicketCreateSheet({
    super.key,
    this.resourceIdentifier,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(
      text: initialTitle ?? '',
    );
    final descriptionController = useTextEditingController();
    final selectedType = useState<TicketType>(TicketType.support);
    final selectedPriority = useState<TicketPriority>(TicketPriority.medium);
    final isSubmitting = useState<bool>(false);

    Future<void> submitTicket() async {
      if (titleController.text.trim().isEmpty) {
        showErrorAlert('Title is required');
        return;
      }

      isSubmitting.value = true;

      try {
        await ref.read(ticketServiceProvider).createTicket(
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          type: selectedType.value.value,
          priority: selectedPriority.value.value,
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
              title: Text('ticketCreatedTitle'.tr()),
              content: Text('ticketCreated'.tr()),
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
      titleText: 'createTicket'.tr(),
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
                      'ticketDescription'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Title text field
            Text(
              'ticketTitle'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'ticketTitleHint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const Gap(24),

            // Description text field
            Text(
              'ticketDescriptionField'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'ticketDescriptionHint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const Gap(24),

            // Ticket type selection
            Text(
              'ticketType'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            ...TicketType.values.map((type) {
              return RadioListTile<TicketType>(
                value: type,
                groupValue: selectedType.value,
                onChanged: (value) => selectedType.value = value!,
                title: Text(type.displayName),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }),
            const Gap(24),

            // Priority selection
            Text(
              'ticketPriority'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            ...TicketPriority.values.map((priority) {
              return RadioListTile<TicketPriority>(
                value: priority,
                groupValue: selectedPriority.value,
                onChanged: (value) => selectedPriority.value = value!,
                title: Text(priority.displayName),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }),
            const Gap(24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting.value ? null : submitTicket,
                child: isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('createTicketSubmit'.tr()),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility alias
class AbuseReportSheet extends TicketCreateSheet {
  const AbuseReportSheet({
    super.key,
    required String resourceIdentifier,
    String? initialReason,
  }) : super(
          resourceIdentifier: resourceIdentifier,
          initialTitle: initialReason,
        );
}
