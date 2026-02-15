import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final titleController = useTextEditingController(text: initialTitle ?? '');
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
        await ref
            .read(ticketServiceProvider)
            .createTicket(
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
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title text field
                Text(
                  'ticketTitle'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'ticketTitleHint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Gap(24),
                // Description text field
                Text(
                  'ticketDescriptionField'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'ticketDescriptionHint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ).padding(horizontal: 24),
            const Gap(24),

            // Ticket type selection
            Text(
              'ticketType'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).padding(horizontal: 24),
            const Gap(12),
            ...TicketType.values.map((type) {
              return RadioListTile<TicketType>(
                value: type,
                groupValue: selectedType.value,
                onChanged: (value) => selectedType.value = value!,
                title: Text(type.displayName),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
            ).padding(horizontal: 24),
            const Gap(12),
            ...TicketPriority.values.map((priority) {
              return RadioListTile<TicketPriority>(
                value: priority,
                groupValue: selectedPriority.value,
                onChanged: (value) => selectedPriority.value = value!,
                title: Text(priority.displayName),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
            ).padding(horizontal: 24),
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
