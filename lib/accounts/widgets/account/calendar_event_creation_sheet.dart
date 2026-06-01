import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CalendarEventCreationSheet extends HookConsumerWidget {
  final SnUserCalendarEvent? initialEvent;
  final DateTime? initialDate;

  const CalendarEventCreationSheet({
    super.key,
    this.initialEvent,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = initialEvent != null;
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Form controllers
    final titleController = useTextEditingController(
      text: initialEvent?.title ?? '',
    );
    final descriptionController = useTextEditingController(
      text: initialEvent?.description ?? '',
    );
    final locationController = useTextEditingController(
      text: initialEvent?.location ?? '',
    );

    // Date/time states
    final startTime = useState<DateTime>(
      initialEvent?.startTime ??
          (initialDate ?? now).copyWith(
            hour: 9,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
    );
    final endTime = useState<DateTime>(
      initialEvent?.endTime ??
          (initialDate ?? now).copyWith(
            hour: 10,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
    );
    final isAllDay = useState<bool>(initialEvent?.isAllDay ?? false);
    final visibility = useState<int>(
      initialEvent?.visibility ?? SnEventVisibility.private,
    );

    // Icon and background states
    final icon = useState<IDisplayableCloudFile?>(initialEvent?.icon);
    final background = useState<IDisplayableCloudFile?>(
      initialEvent?.background,
    );

    // Recurrence states
    final recurrenceFrequency = useState<int>(
      initialEvent?.recurrence?.frequency ?? SnRecurrenceFrequency.none,
    );
    final recurrenceInterval = useState<int>(
      initialEvent?.recurrence?.interval ?? 1,
    );
    final recurrenceEndDate = useState<DateTime?>(
      initialEvent?.recurrence?.endDate,
    );
    final selectedDaysOfWeek = useState<Set<String>>(
      initialEvent?.recurrence?.daysOfWeek?.toSet() ?? {},
    );

    final submitting = useState(false);

    Future<void> pickImage(String type) async {
      final result = await showImagePickerEditor(
        context,
        config: type == 'background'
            ? const ImageEditorConfig(
                allowedAspectRatios: [ImageAspectRatio(width: 16, height: 9)],
                allowMultiple: false,
                allowCompression: true,
                defaultCompressionQuality: 85,
              )
            : const ImageEditorConfig(
                allowedAspectRatios: [ImageAspectRatio.square],
                allowMultiple: false,
                allowCompression: true,
                defaultCompressionQuality: 90,
              ),
        title: type == 'background'
            ? 'eventBackground'.tr()
            : 'eventIcon'.tr(),
      );
      if (result == null) return;
      final cloudFile = result as SnCloudFile;
      if (type == 'icon') {
        icon.value = cloudFile;
      } else {
        background.value = cloudFile;
      }
    }

    Future<void> deleteEvent() async {
      if (initialEvent == null) return;

      final confirmed = await showConfirmAlert(
        'calendarEventDeleteConfirm'.tr(),
        'calendarEventDelete'.tr(),
        isDanger: true,
      );
      if (!confirmed) return;

      try {
        submitting.value = true;
        final client = ref.read(solarNetworkClientProvider);
        await client.accounts.deleteCalendarEvent(initialEvent!.id);

        ref.invalidate(eventCalendarProvider);

        if (!context.mounted) return;
        Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    Future<void> submitEvent() async {
      if (titleController.text.trim().isEmpty) {
        showErrorAlert('calendarEventTitleRequired'.tr());
        return;
      }

      if (endTime.value.isBefore(startTime.value)) {
        showErrorAlert('calendarEventEndTimeError'.tr());
        return;
      }

      try {
        submitting.value = true;
        final client = ref.read(solarNetworkClientProvider);

        SnRecurrencePattern? recurrence;
        if (recurrenceFrequency.value != SnRecurrenceFrequency.none) {
          recurrence = SnRecurrencePattern(
            frequency: recurrenceFrequency.value,
            interval: recurrenceInterval.value,
            endDate: recurrenceEndDate.value,
            daysOfWeek: selectedDaysOfWeek.value.isNotEmpty
                ? selectedDaysOfWeek.value.toList()
                : null,
          );
        }

        if (isEditing) {
          await client.accounts.updateCalendarEvent(
            id: initialEvent!.id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isNotEmpty
                ? descriptionController.text.trim()
                : null,
            location: locationController.text.trim().isNotEmpty
                ? locationController.text.trim()
                : null,
            startTime: startTime.value,
            endTime: endTime.value,
            isAllDay: isAllDay.value,
            visibility: visibility.value,
            recurrence: recurrence,
            iconId: icon.value?.id,
            backgroundId: background.value?.id,
          );
        } else {
          await client.accounts.createCalendarEvent(
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isNotEmpty
                ? descriptionController.text.trim()
                : null,
            location: locationController.text.trim().isNotEmpty
                ? locationController.text.trim()
                : null,
            startTime: startTime.value,
            endTime: endTime.value,
            isAllDay: isAllDay.value,
            visibility: visibility.value,
            recurrence: recurrence,
            iconId: icon.value?.id,
            backgroundId: background.value?.id,
          );
        }

        ref.invalidate(eventCalendarProvider);

        if (!context.mounted) return;
        Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    Future<void> pickDateTime(
      BuildContext context,
      ValueNotifier<DateTime> dateTime,
      bool isStart,
    ) async {
      final date = await showDatePicker(
        context: context,
        initialDate: dateTime.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null) return;

      if (!context.mounted) return;

      if (isAllDay.value) {
        dateTime.value = date.copyWith(
          hour: isStart ? 0 : 23,
          minute: isStart ? 0 : 59,
        );
        return;
      }

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dateTime.value),
      );
      if (time == null) return;

      dateTime.value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    Future<void> pickRecurrenceEndDate() async {
      final date = await showDatePicker(
        context: context,
        initialDate: recurrenceEndDate.value ?? startTime.value,
        firstDate: startTime.value,
        lastDate: DateTime(2100),
      );
      if (date != null) {
        recurrenceEndDate.value = date;
      }
    }

    Widget buildSectionTitle(String title, IconData icon) {
      return Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary, fill: 1),
          const Gap(8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return SheetScaffold(
      heightFactor: 0.9,
      titleText: isEditing
          ? 'calendarEventUpdate'.tr()
          : 'calendarEventCreate'.tr(),
      actions: [
        TextButton.icon(
          onPressed: submitting.value ? null : submitEvent,
          icon: const Icon(Symbols.upload),
          label: Text(isEditing ? 'update'.tr() : 'create'.tr()),
          style: ButtonStyle(
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
            ),
          ),
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Symbols.delete),
            onPressed: submitting.value ? null : deleteEvent,
            style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(24),

            // Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'eventTitle'.tr(),
                hintText: 'eventTitleHint'.tr(),
                prefixIcon: const Icon(Symbols.title),
              ),
              maxLength: 256,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(16),

            // Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'eventLocation'.tr(),
                hintText: 'eventLocationHint'.tr(),
                prefixIcon: const Icon(Symbols.location_on),
              ),
              maxLength: 512,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(16),

            // Description
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'eventDescription'.tr(),
                hintText: 'eventDescriptionHint'.tr(),
                prefixIcon: const Icon(Symbols.notes),
                alignLabelWithHint: true,
              ),
              maxLength: 4096,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(24),

            // Icon & Background Section
            buildSectionTitle('eventAppearance'.tr(), Symbols.palette),
            const Gap(12),
            Row(
              children: [
                // Icon picker
                Expanded(
                  child: _ImagePickerTile(
                    label: 'eventIcon'.tr(),
                    icon: Symbols.image,
                    file: icon.value,
                    onTap: () => pickImage('icon'),
                    onRemove:
                        icon.value != null ? () => icon.value = null : null,
                  ),
                ),
                const Gap(12),
                // Background picker
                Expanded(
                  child: _ImagePickerTile(
                    label: 'eventBackground'.tr(),
                    icon: Symbols.wallpaper,
                    file: background.value,
                    onTap: () => pickImage('background'),
                    onRemove: background.value != null
                        ? () => background.value = null
                        : null,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // All Day Toggle
            SwitchListTile(
              title: Text(
                'eventAllDay'.tr(),
                style: theme.textTheme.titleSmall,
              ),
              subtitle: Text(
                'eventAllDayDescription'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: isAllDay.value,
              onChanged: (value) => isAllDay.value = value,
              secondary: Icon(Symbols.today, color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            const Gap(24),

            // Date & Time Section
            buildSectionTitle('eventDateTime'.tr(), Symbols.schedule),
            const Gap(12),

            // Start Time
            ListTile(
              title: Text(
                'eventStartTime'.tr(),
                style: theme.textTheme.labelLarge,
              ),
              subtitle: Text(
                isAllDay.value
                    ? DateFormat.yMd().format(startTime.value)
                    : DateFormat.yMd().add_jm().format(startTime.value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Symbols.play_arrow,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              trailing: Icon(
                Symbols.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              onTap: () => pickDateTime(context, startTime, true),
            ),
            const Gap(12),

            // End Time
            ListTile(
              title: Text(
                'eventEndTime'.tr(),
                style: theme.textTheme.labelLarge,
              ),
              subtitle: Text(
                isAllDay.value
                    ? DateFormat.yMd().format(endTime.value)
                    : DateFormat.yMd().add_jm().format(endTime.value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Symbols.stop,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              trailing: Icon(
                Symbols.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              onTap: () => pickDateTime(context, endTime, false),
            ),
            const Gap(24),

            // Visibility
            buildSectionTitle('eventVisibility'.tr(), Symbols.visibility),
            const Gap(12),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: SnEventVisibility.private,
                  icon: const Icon(Symbols.lock),
                  label: Text('visibilityPrivate'.tr()),
                ),
                ButtonSegment(
                  value: SnEventVisibility.friends,
                  icon: const Icon(Symbols.group),
                  label: Text('visibilityFriends'.tr()),
                ),
                ButtonSegment(
                  value: SnEventVisibility.public,
                  icon: const Icon(Symbols.public),
                  label: Text('visibilityPublic'.tr()),
                ),
              ],
              selected: {visibility.value},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  visibility.value = selection.first;
                }
              },
            ),
            const Gap(8),
            Text(
              switch (visibility.value) {
                SnEventVisibility.public => 'visibilityPublicDescription'.tr(),
                SnEventVisibility.friends =>
                  'visibilityFriendsDescription'.tr(),
                _ => 'visibilityPrivateDescription'.tr(),
              },
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),

            // Recurrence
            buildSectionTitle('eventRecurrence'.tr(), Symbols.repeat),
            const Gap(12),
            DropdownButtonFormField<int>(
              value: recurrenceFrequency.value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Symbols.repeat),
              ),
              items: [
                DropdownMenuItem(
                  value: SnRecurrenceFrequency.none,
                  child: Text('recurrenceNone'.tr()),
                ),
                DropdownMenuItem(
                  value: SnRecurrenceFrequency.daily,
                  child: Text('recurrenceDaily'.tr()),
                ),
                DropdownMenuItem(
                  value: SnRecurrenceFrequency.weekly,
                  child: Text('recurrenceWeekly'.tr()),
                ),
                DropdownMenuItem(
                  value: SnRecurrenceFrequency.monthly,
                  child: Text('recurrenceMonthly'.tr()),
                ),
                DropdownMenuItem(
                  value: SnRecurrenceFrequency.yearly,
                  child: Text('recurrenceYearly'.tr()),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  recurrenceFrequency.value = value;
                }
              },
            ),

            // Weekly recurrence - days of week selector
            if (recurrenceFrequency.value == SnRecurrenceFrequency.weekly) ...[
              const Gap(16),
              Text(
                'recurrenceDaysOfWeek'.tr(),
                style: theme.textTheme.labelLarge,
              ),
              const Gap(8),
              Wrap(
                spacing: 8,
                children:
                    [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                    ].map((day) {
                      final isSelected = selectedDaysOfWeek.value.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSelected,
                        onSelected: (selected) {
                          final newSet = Set<String>.from(
                            selectedDaysOfWeek.value,
                          );
                          if (selected) {
                            newSet.add(day);
                          } else {
                            newSet.remove(day);
                          }
                          selectedDaysOfWeek.value = newSet;
                        },
                        showCheckmark: false,
                        avatar: null,
                      );
                    }).toList(),
              ),
            ],

            // Recurrence interval
            if (recurrenceFrequency.value != SnRecurrenceFrequency.none) ...[
              const Gap(16),
              Card(
                margin: EdgeInsets.zero,
                color: colorScheme.surfaceContainerHighest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'recurrenceEvery'.tr(),
                            style: theme.textTheme.labelLarge,
                          ),
                          const Gap(12),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                text: recurrenceInterval.value.toString(),
                              ),
                              onChanged: (value) {
                                final interval = int.tryParse(value);
                                if (interval != null && interval > 0) {
                                  recurrenceInterval.value = interval;
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                filled: true,
                              ),
                            ),
                          ),
                          const Gap(12),
                          Text(switch (recurrenceFrequency.value) {
                            SnRecurrenceFrequency.daily =>
                              'recurrenceDays'.tr(),
                            SnRecurrenceFrequency.weekly =>
                              'recurrenceWeeks'.tr(),
                            SnRecurrenceFrequency.monthly =>
                              'recurrenceMonths'.tr(),
                            SnRecurrenceFrequency.yearly =>
                              'recurrenceYears'.tr(),
                            _ => '',
                          }, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const Gap(16),
                      ListTile(
                        title: Text(
                          'recurrenceEndDate'.tr(),
                          style: theme.textTheme.labelLarge,
                        ),
                        subtitle: Text(
                          recurrenceEndDate.value != null
                              ? DateFormat.yMd().format(
                                  recurrenceEndDate.value!,
                                )
                              : 'recurrenceNoEndDate'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Symbols.event,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                        trailing: recurrenceEndDate.value != null
                            ? IconButton(
                                icon: const Icon(Symbols.clear),
                                onPressed: () => recurrenceEndDate.value = null,
                              )
                            : Icon(
                                Symbols.chevron_right,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        onTap: pickRecurrenceEndDate,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            Gap(MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final IDisplayableCloudFile? file;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ImagePickerTile({
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (file != null)
              Positioned.fill(
                child: CloudFileWidget(
                  item: file!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
                    const Gap(4),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  icon: const Icon(Symbols.close, size: 16),
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface.withOpacity(0.8),
                    foregroundColor: colorScheme.onSurface,
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows the calendar event creation sheet
Future<bool?> showCalendarEventSheet(
  BuildContext context, {
  SnUserCalendarEvent? initialEvent,
  DateTime? initialDate,
}) async {
  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => CalendarEventCreationSheet(
      initialEvent: initialEvent,
      initialDate: initialDate,
    ),
  );
}
