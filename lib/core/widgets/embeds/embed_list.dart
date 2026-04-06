import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/livestreams/livestream.dart';
import 'package:island/polls/polls_widgets/poll/poll_submit.dart';
import 'package:island/core/widgets/embeds/link.dart';
import 'package:island/wallets/widgets/fund_envelope.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class EmbedListWidget extends ConsumerStatefulWidget {
  final List<dynamic> embeds;
  final bool isInteractive;
  final bool isFullPost;
  final EdgeInsets renderingPadding;
  final double? maxWidth;

  const EmbedListWidget({
    super.key,
    required this.embeds,
    this.isInteractive = true,
    this.isFullPost = false,
    this.renderingPadding = EdgeInsets.zero,
    this.maxWidth,
  });

  @override
  ConsumerState<EmbedListWidget> createState() => _EmbedListWidgetState();
}

class _EmbedListWidgetState extends ConsumerState<EmbedListWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingsProvider);
      setState(() {
        _isExpanded = settings.linkCollapseMode == 'expand';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final linkEmbeds = widget.embeds.where((e) => e['type'] == 'link').toList();
    final otherEmbeds = widget.embeds
        .where((e) => e['type'] != 'link')
        .toList();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (linkEmbeds.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              top: 8,
              left: widget.renderingPadding.horizontal,
              right: widget.renderingPadding.horizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with expand/collapse
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.link,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const Gap(8),
                        Text(
                          'embedLinks'.plural(linkEmbeds.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _isExpanded ? 'collapse'.tr() : 'expand'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Animated content
                AnimatedCrossFade(
                  firstChild: _buildExpandedContent(linkEmbeds),
                  secondChild: _buildCollapsedContent(linkEmbeds),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ...otherEmbeds.map(
          (embedData) => switch (embedData['type']) {
            'poll' => Card(
              margin: EdgeInsets.symmetric(
                horizontal: widget.renderingPadding.horizontal,
                vertical: 8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: embedData['id'] == null
                    ? const Text('Poll was unavailable...')
                    : PollSubmit(
                        pollId: embedData['id'],
                        onSubmit: (_) {},
                        isReadonly: !widget.isInteractive,
                        isInitiallyExpanded: widget.isFullPost,
                      ),
              ),
            ),
            'fund' =>
              embedData['id'] == null
                  ? const Text('Fund envelope was unavailable...')
                  : FundEnvelopeWidget(
                      fundId: embedData['id'],
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),
            'livestream' =>
              embedData['id'] == null
                  ? const Text('Livestream was unavailable...')
                  : LivestreamEmbedWidget(
                      livestreamId: embedData['id'],
                      isInteractive: widget.isInteractive,
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),
            'fitness' => _fitnessEmbedWidget(
              type: embedData['fitness_type'] ?? 'goal',
              id: embedData['id'],
              margin: EdgeInsets.symmetric(
                horizontal: widget.renderingPadding.horizontal,
                vertical: 8,
              ),
            ),
            _ => Text('Unable show embed: ${embedData['type']}'),
          },
        ),
      ],
    );
  }

  Widget _buildExpandedContent(List<dynamic> linkEmbeds) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: linkEmbeds.length == 1
          ? EmbedLinkWidget(link: SnScrappedLink.fromJson(linkEmbeds.first))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: linkEmbeds
                    .map(
                      (embedData) => SizedBox(
                        width: 180,
                        child: EmbedLinkWidget(
                          link: SnScrappedLink.fromJson(embedData),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildCollapsedContent(List<dynamic> linkEmbeds) {
    if (linkEmbeds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: EmbedLinkWidget(
        link: SnScrappedLink.fromJson(linkEmbeds.first),
        isCompact: true,
      ),
    );
  }

  Widget _fitnessEmbedWidget({
    required String type,
    required String id,
    required EdgeInsets margin,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        Widget content = switch (type) {
          'workout' => _buildWorkoutContent(ref, id),
          'metric' => _buildMetricContent(ref, id),
          'goal' => _buildGoalContent(ref, id),
          _ => const Text('Unknown fitness type'),
        };

        return Card(
          margin: margin,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (type == 'goal') {
                context.router.push(GoalDetailRoute(id: id));
              } else if (type == 'metric') {
                final metricType = _parseMetricType(id);
                if (metricType != null) {
                  context.router.push(
                    MetricDetailRoute(metricType: metricType),
                  );
                }
              }
            },
            child: content,
          ),
        );
      },
    );
  }

  FitnessMetricType? _parseMetricType(String typeStr) {
    return switch (typeStr.toLowerCase()) {
      'weight' => FitnessMetricType.weight,
      'bodyfat' => FitnessMetricType.bodyFat,
      'steps' => FitnessMetricType.steps,
      'heartrate' => FitnessMetricType.heartRate,
      'sleep' => FitnessMetricType.sleep,
      'calories' => FitnessMetricType.calories,
      'waterintake' => FitnessMetricType.waterIntake,
      'distance' => FitnessMetricType.distance,
      'custom' => FitnessMetricType.custom,
      _ => null,
    };
  }

  Widget _buildWorkoutContent(WidgetRef ref, String id) {
    final workoutAsync = ref.watch(workoutDetailProvider(id));

    return workoutAsync.when(
      data: (workout) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.fitness_center,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (workout.caloriesBurned != null)
                    Text(
                      '${workout.caloriesBurned} kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Workout unavailable'),
      ),
    );
  }

  Widget _buildMetricContent(WidgetRef ref, String id) {
    final metricAsync = ref.watch(metricDetailProvider(id));

    return metricAsync.when(
      data: (metric) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.monitor_weight,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${metric.value} ${metric.unit}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _formatDate(metric.recordedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Metric unavailable'),
      ),
    );
  }

  Widget _buildGoalContent(WidgetRef ref, String id) {
    final goalAsync = ref.watch(goalDetailProvider(id));

    return goalAsync.when(
      data: (goal) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.flag,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (goal.targetValue != null)
                    Text(
                      '${goal.currentValue?.toStringAsFixed(0) ?? 0} / ${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Goal unavailable'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
