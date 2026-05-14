import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
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
    final contentController = useTextEditingController();
    final selectedType = useState<TicketType>(TicketType.support);
    final selectedPriority = useState<TicketPriority>(TicketPriority.medium);
    final isSubmitting = useState<bool>(false);
    final attachments = useState<List<SnCloudFile>>([]);

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
              content: contentController.text.trim().isEmpty
                  ? null
                  : contentController.text.trim(),
              type: selectedType.value.value,
              priority: selectedPriority.value.value,
              fileIds: attachments.value.isEmpty
                  ? null
                  : attachments.value.map((e) => e.id).toList(),
            );

        if (context.mounted) {
          Navigator.of(context).pop();
          showInfoAlert(
            'ticketCreated'.tr(),
            'ticketCreatedTitle'.tr(),
            icon: Symbols.check_circle,
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
                  controller: contentController,
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

            // Attachments section
            Text(
              'ticketAttachments'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).padding(horizontal: 24),
            const Gap(12),
            if (attachments.value.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: attachments.value.length,
                  itemBuilder: (context, index) {
                    final file = attachments.value[index];
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Symbols.attach_file, size: 24),
                              const Gap(4),
                              Text(
                                file.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              attachments.value = [
                                ...attachments.value.where(
                                  (e) => e.id != file.id,
                                ),
                              ];
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Symbols.close,
                                size: 14,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (_, _) => const Gap(8),
                ),
              ),
            const Gap(8),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          const CloudFilePicker(allowMultiple: true, usage: 'ticket'),
                    ).then((value) {
                      if (value != null && value.isNotEmpty) {
                        attachments.value = [...attachments.value, ...value];
                      }
                    });
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('addAttachment'.tr()),
                ),
              ),
            ),
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
