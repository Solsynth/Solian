import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleController = useTextEditingController(text: initialTitle ?? '');
    final contentController = useTextEditingController();
    final selectedType = useState<TicketType>(TicketType.support);
    final selectedPriority = useState<TicketPriority>(TicketPriority.medium);
    final isSubmitting = useState<bool>(false);
    final attachments = useState<List<SnCloudFile>>([]);
    final resource = resourceIdentifier?.trim();
    final resources = (resource == null || resource.isEmpty)
        ? null
        : <String?>[resource];

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
              resources: resources,
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

    Future<void> pickAttachments() async {
      final value = await showModalBottomSheet<List<SnCloudFile>>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            const CloudFilePicker(allowMultiple: true, usage: 'ticket'),
      );
      if (value != null && value.isNotEmpty) {
        attachments.value = [...attachments.value, ...value];
      }
    }

    return SheetScaffold(
      titleText: 'createTicket'.tr(),
      heightFactor: 0.92,
      actions: [
        TextButton(
          onPressed: isSubmitting.value ? null : submitTicket,
          child: isSubmitting.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : Text('createTicketSubmit'.tr()),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'ticketDescription'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (resource != null && resource.isNotEmpty) ...[
            const Gap(16),
            _LinkedResourceBanner(resource: resource),
          ],
          const Gap(20),
          _SectionLabel(label: 'ticketTitle'.tr(), required: true),
          const Gap(8),
          TextField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'ticketTitleHint'.tr(),
              prefixIcon: const Icon(Symbols.title, size: 20),
            ),
          ),
          const Gap(20),
          _SectionLabel(label: 'ticketDescriptionField'.tr()),
          const Gap(8),
          TextField(
            controller: contentController,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'ticketDescriptionHint'.tr(),
              alignLabelWithHint: true,
            ),
          ),
          const Gap(24),
          _SectionLabel(label: 'ticketType'.tr()),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketType.values.map((type) {
              final selected = selectedType.value == type;
              return FilterChip(
                selected: selected,
                showCheckmark: false,
                avatar: Icon(
                  _typeIcon(type),
                  size: 16,
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : _typeColor(colorScheme, type),
                ),
                label: Text(type.displayName),
                onSelected: (_) => selectedType.value = type,
              );
            }).toList(),
          ),
          const Gap(24),
          _SectionLabel(label: 'ticketPriority'.tr()),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketPriority.values.map((priority) {
              final selected = selectedPriority.value == priority;
              final accent = _priorityColor(colorScheme, priority);
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                label: Text(priority.displayName),
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? accent : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                selectedColor: accent.withValues(alpha: 0.16),
                side: BorderSide(
                  color: selected
                      ? accent.withValues(alpha: 0.55)
                      : colorScheme.outlineVariant,
                ),
                onSelected: (_) => selectedPriority.value = priority,
              );
            }).toList(),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(child: _SectionLabel(label: 'ticketAttachments'.tr())),
              if (attachments.value.isNotEmpty)
                Text(
                  '${attachments.value.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const Gap(10),
          if (attachments.value.isNotEmpty) ...[
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.value.length,
                separatorBuilder: (_, _) => const Gap(10),
                itemBuilder: (context, index) {
                  final file = attachments.value[index];
                  return _AttachmentTile(
                    name: file.name,
                    onRemove: () {
                      attachments.value = [
                        ...attachments.value.where((e) => e.id != file.id),
                      ];
                    },
                  );
                },
              ),
            ),
            const Gap(12),
          ],
          Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: pickAttachments,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Symbols.attach_file,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'addAttachment'.tr(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            'Screenshots, logs, or related files',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Symbols.add,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(28),
          FilledButton.icon(
            onPressed: isSubmitting.value ? null : submitTicket,
            icon: isSubmitting.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Symbols.send),
            label: Text('createTicketSubmit'.tr()),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        if (required) ...[
          const Gap(4),
          Text(
            '*',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _LinkedResourceBanner extends StatelessWidget {
  final String resource;

  const _LinkedResourceBanner({required this.resource});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.link,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linked resource',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  resource,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.9,
                    ),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _AttachmentTile({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.insert_drive_file,
                size: 22,
                color: colorScheme.primary,
              ),
              const Gap(6),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Material(
            color: colorScheme.error,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Symbols.close,
                  size: 14,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

IconData _typeIcon(TicketType type) {
  switch (type.value) {
    case 0:
      return Symbols.support_agent;
    case 1:
      return Symbols.bug_report;
    case 2:
      return Symbols.lightbulb;
    case 3:
      return Symbols.payments;
    default:
      return Symbols.help;
  }
}

Color _typeColor(ColorScheme colorScheme, TicketType type) {
  switch (type.value) {
    case 0:
      return colorScheme.primary;
    case 1:
      return colorScheme.error;
    case 2:
      return Colors.purple;
    case 3:
      return Colors.orange;
    default:
      return colorScheme.outline;
  }
}

Color _priorityColor(ColorScheme colorScheme, TicketPriority priority) {
  switch (priority.value) {
    case 0:
      return colorScheme.outline;
    case 1:
      return colorScheme.primary;
    case 2:
      return Colors.orange;
    case 3:
      return colorScheme.error;
    default:
      return colorScheme.outline;
  }
}

/// Backward compatibility alias
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
