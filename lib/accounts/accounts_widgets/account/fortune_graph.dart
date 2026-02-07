import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_widgets/account/event_calendar_content.dart';
import 'package:island/core/models/activity.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

/// A widget that displays a graph of fortune levels over time
/// This can be used alongside the EventCalendarWidget to provide a different visualization
class FortuneGraphWidget extends HookConsumerWidget {
  /// The list of calendar entries to display
  final AsyncValue<List<SnEventCalendarEntry>> events;

  /// Whether to constrain the width of the graph
  final bool constrainWidth;

  /// Maximum width constraint when constrainWidth is true
  final double maxWidth;

  /// Height of the graph
  final double height;

  /// Callback when a point is selected
  final void Function(DateTime)? onPointSelected;

  final String? eventCalandarUser;

  final EdgeInsets? margin;

  const FortuneGraphWidget({
    super.key,
    required this.events,
    this.constrainWidth = false,
    this.maxWidth = double.infinity,
    this.height = 180,
    this.onPointSelected,
    this.eventCalandarUser,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter events to only include those with check-in results
    final filteredEvents = events.whenData(
      (data) =>
          data
              .where((event) => event.checkInResult != null)
              .toList()
              .cast<SnEventCalendarEntry>()
            // Sort by date
            ..sort((a, b) => a.date.compareTo(b.date)),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('fortuneGraph').tr().fontSize(18).bold(),
            if (eventCalandarUser != null)
              IconButton(
                icon: const Icon(Icons.calendar_month, size: 20),
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SheetScaffold(
                      titleText: 'eventCalendar'.tr(),
                      child: EventCalendarContent(
                        name: eventCalandarUser!,
                        isSheet: true,
                      ),
                    ),
                  );
                },
              ),
          ],
        ).padding(all: 16, bottom: 24),
        SizedBox(
          height: height,
          child: filteredEvents.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(child: Text('noFortuneData').tr());
              }

              // Create spots for the line chart
              final spots = data
                  .map(
                    (e) => FlSpot(
                      e.date.millisecondsSinceEpoch.toDouble(),
                      e.checkInResult!.level.toDouble(),
                    ),
                  )
                  .toList();

              // Get min and max dates for the x-axis
              final minDate = data.first.date;
              final maxDate = data.last.date;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 1,
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _calculateDateInterval(minDate, maxDate),
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt(),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat.MMMd().format(date),
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final level = value.toInt();
                            if (level < 0 || level > 4) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                'checkInResultT$level'.tr(),
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                        left: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    minX: minDate.millisecondsSinceEpoch.toDouble(),
                    maxX: maxDate.millisecondsSinceEpoch.toDouble(),
                    minY: 0,
                    maxY: 4,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              spot.x.toInt(),
                            );
                            final level = spot.y.toInt();
                            return LineTooltipItem(
                              '${DateFormat.yMMMd().format(date)}\n',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'checkInResultLevel$level'.tr(),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                            if (event is FlTapUpEvent &&
                                response != null &&
                                response.lineBarSpots != null &&
                                response.lineBarSpots!.isNotEmpty) {
                              final spot = response.lineBarSpots!.first;
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                spot.x.toInt(),
                              );
                              onPointSelected?.call(date);
                            }
                          },
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );

    if (constrainWidth) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(margin: margin ?? EdgeInsets.all(16), child: content),
      ).center();
    }

    return content;
  }

  /// Calculate an appropriate interval for date labels based on the date range
  double _calculateDateInterval(DateTime minDate, DateTime maxDate) {
    final difference = maxDate.difference(minDate).inDays;

    // If less than 7 days, show all days
    if (difference <= 7) {
      return 24 * 60 * 60 * 1000; // One day in milliseconds
    }

    // If less than a month, show every 3 days
    if (difference <= 30) {
      return 3 * 24 * 60 * 60 * 1000; // Three days in milliseconds
    }

    // If less than 3 months, show weekly
    if (difference <= 90) {
      return 7 * 24 * 60 * 60 * 1000; // One week in milliseconds
    }

    // Otherwise show every 2 weeks
    return 14 * 24 * 60 * 60 * 1000; // Two weeks in milliseconds
  }
}
