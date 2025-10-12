import 'package:easy_localization/easy_localization.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/heatmap.dart';

/// A reusable heatmap widget for displaying activity data in GitHub-style layout.
/// Shows exactly 365 days of data ending at the current date.
class ActivityHeatmapWidget extends HookConsumerWidget {
  final SnHeatmap heatmap;

  const ActivityHeatmapWidget({super.key, required this.heatmap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = useState<HeatmapItem?>(null);

    // Generate exactly 365 days ending at current date
    final now = DateTime.now();

    // Start from exactly 365 days ago
    final startDate = now.subtract(const Duration(days: 365));
    // End at current date
    final endDate = now;

    // Find monday of the week containing start date
    final startMonday = startDate.subtract(
      Duration(days: startDate.weekday - 1),
    );
    // Find sunday of the week containing end date
    final endSunday = endDate.add(Duration(days: 7 - endDate.weekday));

    // Generate weeks to cover exactly 365 days
    final weeks = <DateTime>[];
    var current = startMonday;
    while (current.isBefore(endSunday) || current.isAtSameMomentAs(endSunday)) {
      weeks.add(current);
      current = current.add(const Duration(days: 7));
    }

    // Create data map for all dates in the range
    final dataMap = <DateTime, double>{};
    for (final week in weeks) {
      for (var i = 0; i < 7; i++) {
        final date = week.add(Duration(days: i));
        // Only include dates within our 365-day range
        if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          final item = heatmap.items.firstWhere(
            (e) =>
                e.date.year == date.year &&
                e.date.month == date.month &&
                e.date.day == date.day,
            orElse: () => SnHeatmapItem(date: date, count: 0),
          );
          dataMap[date] = item.count.toDouble();
        }
      }
    }

    // Generate month labels for the top
    final monthLabels = <String>[];
    final monthPositions = <int>[];
    final processedMonths =
        <String>{}; // Track processed months to avoid duplicates

    for (final week in weeks) {
      final monthKey = '${week.year}-${week.month.toString().padLeft(2, '0')}';

      // Only process each month once
      if (!processedMonths.contains(monthKey)) {
        processedMonths.add(monthKey);

        // Find which week this month starts in
        final firstDayOfMonth = DateTime(week.year, week.month, 1);
        final monthStartMonday = firstDayOfMonth.subtract(
          Duration(days: firstDayOfMonth.weekday - 1),
        );

        final monthStartWeekIndex = weeks.indexWhere(
          (w) =>
              w.year == monthStartMonday.year &&
              w.month == monthStartMonday.month &&
              w.day == monthStartMonday.day,
        );

        if (monthStartWeekIndex != -1) {
          monthLabels.add(_getMonthAbbreviation(week.month));
          monthPositions.add(monthStartWeekIndex);
        }
      }
    }

    final heatmapData = HeatmapData(
      rows: [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ], // Days of week vertically
      columns:
          weeks
              .map(
                (w) =>
                    '${w.year}-${w.month.toString().padLeft(2, '0')}-${w.day.toString().padLeft(2, '0')}',
              )
              .toList(), // Weeks horizontally
      items: [
        for (int day = 0; day < 7; day++) // For each day of week (Mon-Sun)
          for (final week in weeks) // For each week
            HeatmapItem(
              value: dataMap[week.add(Duration(days: day))] ?? 0.0,
              unit: heatmap.unit,
              xAxisLabel:
                  '${week.year}-${week.month.toString().padLeft(2, '0')}-${week.day.toString().padLeft(2, '0')}',
              yAxisLabel:
                  day == 0
                      ? 'Mon'
                      : day == 1
                      ? 'Tue'
                      : day == 2
                      ? 'Wed'
                      : day == 3
                      ? 'Thu'
                      : day == 4
                      ? 'Fri'
                      : day == 5
                      ? 'Sat'
                      : 'Sun',
            ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'activityHeatmap',
              style: Theme.of(context).textTheme.titleMedium,
            ).tr(),
            const Gap(8),
            // Month labels row
            Row(
              children: [
                const SizedBox(width: 30), // Space for day labels
                ...monthLabels.asMap().entries.map((entry) {
                  final month = entry.value;

                  return Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        month,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const Gap(4),
            Heatmap(
              heatmapData: heatmapData,
              rowsVisible: 7,
              showXAxisLabels: false,
              onItemSelectedListener: (item) {
                selectedItem.value = item;
              },
            ),
            const Gap(8),
            // Legend
            Row(
              children: [
                if (selectedItem.value != null)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: selectedItem.value!.value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' activities on ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextSpan(
                          text: _formatDate(
                            selectedItem.value!.xAxisLabel ?? '',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(4),
                // Color indicators (light to dark green)
                ...[
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.4),
                  Colors.green.withOpacity(0.6),
                  Colors.green.withOpacity(0.8),
                  Colors.green,
                ].map(
                  (color) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  'More',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final monthAbbrev = _getMonthAbbreviation(date.month);
      return '$monthAbbrev ${date.day}, ${date.year}';
    } catch (e) {
      return dateString; // Fallback to original string if parsing fails
    }
  }
}
