import 'package:flutter/material.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PollStatsWidget extends StatelessWidget {
  const PollStatsWidget({
    super.key,
    required this.question,
    required this.stats,
  });

  final SnPollQuestion question;
  final Map<String, dynamic>? stats;

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox.shrink();
    final raw = stats![question.id];
    if (raw == null) return const SizedBox.shrink();

    Widget? body;

    switch (question.type) {
      case SnPollQuestionType.rating:
        // rating: avg score (double or int)
        final avg = (raw['rating'] as num?)?.toDouble();
        if (avg == null) break;
        final theme = Theme.of(context);
        body = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.star, color: Colors.amber.shade600, size: 18),
            const SizedBox(width: 6),
            Text(
              avg.toStringAsFixed(1),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
        break;

      case SnPollQuestionType.yesNo:
        // yes/no: map {true: count, false: count}
        if (raw is Map) {
          final int yes = (raw['true'] is int)
              ? raw['true'] as int
              : int.tryParse('${raw['true']}') ?? 0;
          final int no = (raw['false'] is int)
              ? raw['false'] as int
              : int.tryParse('${raw['false']}') ?? 0;
          final total = (yes + no).clamp(0, 1 << 31);
          final yesPct = total == 0 ? 0.0 : yes / total;
          final noPct = total == 0 ? 0.0 : no / total;
          final theme = Theme.of(context);
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BarStatRow(
                label: 'yes',
                count: yes,
                fraction: yesPct,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 6),
              _BarStatRow(
                label: 'No',
                count: no,
                fraction: noPct,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                'Total: $total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }
        break;

      case SnPollQuestionType.singleChoice:
      case SnPollQuestionType.multipleChoice:
        // map optionId -> count
        if (raw is Map) {
          final options = [...?question.options]
            ..sort((a, b) => a.order.compareTo(b.order));
          final List<_OptionCount> items = [];
          int total = 0;
          for (final opt in options) {
            final dynamic v = raw[opt.id];
            final int count = v is int ? v : int.tryParse('$v') ?? 0;
            total += count;
            items.add(_OptionCount(id: opt.id, label: opt.label, count: count));
          }
          if (items.isNotEmpty) {
            items.sort(
              (a, b) => b.count.compareTo(a.count),
            ); // show highest first
          }
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _BarStatRow(
                    label: it.label,
                    count: it.count,
                    fraction: total == 0 ? 0 : it.count / total,
                  ),
                ),
              if (items.isNotEmpty)
                Text(
                  'Total: $total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          );
        }
        break;

      case SnPollQuestionType.freeText:
        // No stats
        break;
    }

    if (body == null) return Text('No stats available');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCount {
  final String id;
  final String label;
  final int count;
  const _OptionCount({
    required this.id,
    required this.label,
    required this.count,
  });
}

class _BarStatRow extends StatelessWidget {
  const _BarStatRow({
    required this.label,
    required this.count,
    required this.fraction,
    this.color,
  });

  final String label;
  final int count;
  final double fraction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(
      context,
    ).colorScheme.surfaceVariant.withOpacity(0.6);
    final fg = (fraction.isNaN || fraction.isInfinite)
        ? 0.0
        : fraction.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label · $count', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final filled = width * fg;
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: width,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  height: 8,
                  width: filled,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
