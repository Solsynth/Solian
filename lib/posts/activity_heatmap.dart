import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/heatmap.dart';
import 'package:island/core/services/responsive.dart';

/// Custom data class for selected heatmap item
class SelectedHeatmapItem {
  final double value;
  final String unit;
  final String dateString;
  final String dayLabel;

  SelectedHeatmapItem({
    required this.value,
    required this.unit,
    required this.dateString,
    required this.dayLabel,
  });
}

/// A reusable heatmap widget for displaying activity data in GitHub-style layout.
/// Shows exactly 365 days (wide screen) or 90 days (non-wide screen) of data ending at the current date.
class ActivityHeatmapWidget extends HookConsumerWidget {
  final SnHeatmap heatmap;
  final bool forceDense;

  const ActivityHeatmapWidget({
    super.key,
    required this.heatmap,
    this.forceDense = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = useState<SelectedHeatmapItem?>(null);

    final now = DateTime.now();

    final isWide = isWideScreen(context);
    final days = (isWide && !forceDense) ? 365 : 90;

    // Start from exactly the selected days ago
    final startDate = now.subtract(Duration(days: days));
    // End at current date
    final endDate = now;

    // Find monday of the week containing start date
    final startMonday = startDate.subtract(
      Duration(days: startDate.weekday - 1),
    );
    // Find sunday of the week containing end date
    final endSunday = endDate.add(Duration(days: 7 - endDate.weekday));

    // Generate weeks to cover the selected date range
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
        // Only include dates within our selected range
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

    // Find maximum value for color scaling
    final maxValue =
        dataMap.values.isNotEmpty
            ? dataMap.values.reduce((a, b) => a > b ? a : b)
            : 1.0;

    // Helper function to get color based on activity level
    Color getActivityColor(double value) {
      if (value == 0) return Colors.grey.withOpacity(0.1);
      final intensity = value / maxValue;
      return Colors.green.withOpacity(0.2 + (intensity * 0.8));
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month labels row - aligned with month start positions
            Row(
              children: [
                const SizedBox(width: 30), // Space for day labels
                ...List.generate(weeks.length, (weekIndex) {
                  // Check if this week is the start of a month
                  final monthIndex = monthPositions.indexOf(weekIndex);
                  final monthText =
                      monthIndex != -1 ? monthLabels[monthIndex] : null;

                  return monthText != null
                      ? Expanded(
                        child: Text(
                          monthText,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                      : SizedBox.shrink();
                }),
              ],
            ),
            const Gap(4),
            // Custom heatmap grid
            Column(
              children: List.generate(7, (dayIndex) {
                final dayLabels = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                final dayLabel = dayLabels[dayIndex];

                return Row(
                  children: [
                    // Day label
                    SizedBox(
                      width: 30,
                      child: Text(
                        dayLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Activity squares for each week - evenly distributed
                    Expanded(
                      child: Row(
                        children: List.generate(weeks.length, (weekIndex) {
                          final week = weeks[weekIndex];
                          final date = week.add(Duration(days: dayIndex));
                          final value = dataMap[date] ?? 0.0;
                          final dateString =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                selectedItem.value = SelectedHeatmapItem(
                                  value: value,
                                  unit: heatmap.unit,
                                  dateString: dateString,
                                  dayLabel: dayLabel,
                                );
                              },
                              child: Container(
                                height: 12,
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: getActivityColor(value),
                                  borderRadius: BorderRadius.circular(2),
                                  border:
                                      selectedItem.value != null &&
                                              selectedItem.value!.dateString ==
                                                  dateString &&
                                              selectedItem.value!.dayLabel ==
                                                  dayLabel
                                          ? Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              }),
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
                          text: _formatDate(selectedItem.value!.dateString),
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
