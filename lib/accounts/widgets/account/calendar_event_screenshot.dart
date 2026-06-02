import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

class CalendarEventScreenshot extends StatelessWidget {
  final SnUserCalendarEvent event;

  const CalendarEventScreenshot({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event.background != null)
            AspectRatio(
              aspectRatio: event.background!.ratio ?? (16 / 9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CloudFileWidget(
                    item: event.background!,
                    fit: BoxFit.cover,
                    useInternalGate: false,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.icon != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.background != null
                            ? Colors.white.withOpacity(0.2)
                            : colorScheme.primaryContainer,
                      ),
                      child: ClipOval(
                        child: CloudFileWidget(
                          item: event.icon!,
                          fit: BoxFit.cover,
                          useInternalGate: false,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                ] else if (event.background == null) ...[
                  Row(
                    children: [
                      Icon(Symbols.calendar_month, color: colorScheme.primary),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'calendarEvent'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                ],
                Text(
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const Gap(8),
                  Text(
                    event.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(16),
                _buildDateSection(context, theme, colorScheme),
                const Gap(16),
                _buildPropertiesSection(context, theme, colorScheme),
                if (event.account != null) ...[
                  const Gap(16),
                  _buildAccountSection(context, theme, colorScheme),
                ],
              ],
            ),
          ),
          const Gap(12),
          _ScreenshotFooter(event: event),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final start = event.startTime.toLocal();
    final end = event.endTime.toLocal();
    final isSameDay = DateUtils.isSameDay(start, end);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.MMM().format(start),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat.d().format(start),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSameDay)
                  Text(
                    DateFormat.yMMMMEEEEd().format(start),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    '${DateFormat.yMMMd().format(start)} – ${DateFormat.yMMMd().format(end)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const Gap(4),
                if (!event.isAllDay)
                  Text(
                    '${DateFormat.Hm().format(start)} – ${DateFormat.Hm().format(end)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    'eventAllDay'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildPropertiesSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final items = <_PropertyData>[];
    if (event.location != null && event.location!.isNotEmpty) {
      items.add(
        _PropertyData(icon: Symbols.location_on, text: event.location!),
      );
    }
    if (event.recurrence != null) {
      items.add(
        _PropertyData(
          icon: Symbols.repeat,
          text: _getRecurrenceText(event.recurrence!),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 14, color: colorScheme.primary),
                  const Gap(6),
                  Flexible(
                    child: Text(
                      item.text,
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final account = event.account!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ProfilePictureWidget(file: account.profile.picture, radius: 18),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountName(
                  account: account,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  hideOverlay: true,
                ),
                const Gap(2),
                HandleChip(
                  handle: account.name,
                  allowCopy: false,
                  textStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecurrenceText(SnRecurrencePattern recurrence) {
    final frequency = switch (recurrence.frequency) {
      1 => 'recurrenceDaily'.tr(),
      2 => 'recurrenceWeekly'.tr(),
      3 => 'recurrenceMonthly'.tr(),
      4 => 'recurrenceYearly'.tr(),
      _ => 'recurrenceNone'.tr(),
    };
    if (recurrence.interval > 1) {
      return '$frequency (every ${recurrence.interval})';
    }
    return frequency;
  }
}

class _PropertyData {
  final IconData icon;
  final String text;
  const _PropertyData({required this.icon, required this.text});
}

class _ScreenshotFooter extends StatelessWidget {
  final SnUserCalendarEvent event;
  const _ScreenshotFooter({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final account = event.account;

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/icons/icon${isDark ? '-dark' : ''}.webp',
              width: 36,
              height: 36,
            ),
          ).padding(right: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solar Network',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'shareEventSlogan'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          if (account != null)
            QrImageView(
              data: 'https://solian.app/accounts/${account.name}',
              version: QrVersions.auto,
              size: 52,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              backgroundColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onSurface,
              padding: const EdgeInsets.all(6),
            ),
        ],
      ),
    );
  }
}
