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
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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
            onTap: () => _showFitnessDetailSheet(context, ref, type, id),
            child: content,
          ),
        );
      },
    );
  }

  void _showFitnessDetailSheet(
    BuildContext context,
    WidgetRef ref,
    String type,
    String id,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FitnessDetailSheet(type: type, id: id),
    );
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
                _getWorkoutIcon(workout.type),
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
                _getMetricIcon(metric.metricType),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMetricTypeName(metric.metricType),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${metric.value} ${metric.unit}',
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

  IconData _getWorkoutIcon(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => Icons.fitness_center,
      WorkoutType.cardio => Icons.directions_run,
      WorkoutType.hiit => Icons.flash_on,
      WorkoutType.yoga => Icons.self_improvement,
      WorkoutType.other => Icons.sports,
    };
  }

  IconData _getMetricIcon(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => Icons.monitor_weight,
      FitnessMetricType.bodyFat => Icons.percent,
      FitnessMetricType.steps => Icons.directions_walk,
      FitnessMetricType.heartRate => Icons.monitor_heart,
      FitnessMetricType.sleep => Icons.bedtime,
      FitnessMetricType.calories => Icons.local_fire_department,
      FitnessMetricType.waterIntake => Icons.water_drop,
      FitnessMetricType.distance => Icons.straighten,
      FitnessMetricType.custom => Icons.show_chart,
    };
  }

  String _getMetricTypeName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'Weight',
      FitnessMetricType.bodyFat => 'Body Fat',
      FitnessMetricType.steps => 'Steps',
      FitnessMetricType.heartRate => 'Heart Rate',
      FitnessMetricType.sleep => 'Sleep',
      FitnessMetricType.calories => 'Calories',
      FitnessMetricType.waterIntake => 'Water',
      FitnessMetricType.distance => 'Distance',
      FitnessMetricType.custom => 'Custom',
    };
  }
}

class _FitnessDetailSheet extends ConsumerWidget {
  final String type;
  final String id;

  const _FitnessDetailSheet({required this.type, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (type) {
      'workout' => _buildWorkoutSheet(context, ref),
      'metric' => _buildMetricSheet(context, ref),
      'goal' => _buildGoalSheet(context, ref),
      _ => const Center(child: Text('Unknown fitness type')),
    };
  }

  Widget _buildWorkoutSheet(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutDetailProvider(id));

    return workoutAsync.when(
      data: (workout) {
        final duration = workout.endTime?.difference(workout.startTime);

        return SheetScaffold(
          titleText: workout.name,
          heightFactor: 0.6,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDetailRow(
                context,
                'workoutType'.tr(),
                _getWorkoutTypeName(workout.type),
                icon: _getWorkoutIcon(workout.type),
              ),
              _buildDetailRow(
                context,
                'startTime'.tr(),
                _formatDate(workout.startTime),
                icon: Icons.access_time,
              ),
              if (duration != null)
                _buildDetailRow(
                  context,
                  'duration'.tr(),
                  _formatDuration(duration),
                  icon: Icons.timer,
                ),
              if (workout.caloriesBurned != null)
                _buildDetailRow(
                  context,
                  'caloriesBurned'.tr(),
                  '${workout.caloriesBurned} kcal',
                  icon: Icons.local_fire_department,
                ),
              if (workout.description != null)
                _buildDetailRow(
                  context,
                  'description'.tr(),
                  workout.description!,
                  icon: Icons.description,
                ),
              if (workout.notes != null)
                _buildDetailRow(
                  context,
                  'notes'.tr(),
                  workout.notes!,
                  icon: Icons.note,
                ),
              if (workout.distance != null ||
                  workout.averageHeartRate != null ||
                  workout.maxHeartRate != null ||
                  workout.averageSpeed != null ||
                  workout.maxSpeed != null ||
                  workout.elevationGain != null ||
                  (workout.meta != null && workout.meta!['steps'] != null)) ...[
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'details'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                _buildMetaDetails(context, workout),
              ],
            ],
          ),
        );
      },
      loading: () => SheetScaffold(
        titleText: 'loading'.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SheetScaffold(
        titleText: 'errorGeneric'.tr(args: [e.toString()]),
        child: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMetricSheet(BuildContext context, WidgetRef ref) {
    final metricAsync = ref.watch(metricDetailProvider(id));

    return metricAsync.when(
      data: (metric) => SheetScaffold(
        titleText: _getMetricTypeName(metric.metricType),
        heightFactor: 0.5,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDetailRow(
              context,
              'metricValue'.tr(),
              '${metric.value} ${metric.unit}',
              icon: _getMetricIcon(metric.metricType),
            ),
            _buildDetailRow(
              context,
              'recordedAt'.tr(),
              _formatDate(metric.recordedAt),
              icon: Icons.calendar_today,
            ),
            if (metric.notes != null)
              _buildDetailRow(
                context,
                'notes'.tr(),
                metric.notes!,
                icon: Icons.note,
              ),
          ],
        ),
      ),
      loading: () => SheetScaffold(
        titleText: 'loading'.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SheetScaffold(
        titleText: 'errorGeneric'.tr(args: [e.toString()]),
        child: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildGoalSheet(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(id));

    return goalAsync.when(
      data: (goal) {
        final progress =
            goal.targetValue != null &&
                goal.currentValue != null &&
                goal.targetValue! > 0
            ? (goal.currentValue! / goal.targetValue! * 100).clamp(0.0, 100.0)
            : 0.0;

        return SheetScaffold(
          titleText: goal.title,
          heightFactor: 0.7,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 8,
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (goal.targetValue != null)
                _buildDetailRow(
                  context,
                  'progress'.tr(),
                  '${goal.currentValue?.toStringAsFixed(0) ?? 0} / ${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                  icon: Icons.trending_up,
                ),
              _buildDetailRow(
                context,
                'goalType'.tr(),
                _getGoalTypeName(goal.goalType),
                icon: Icons.flag,
              ),
              _buildDetailRow(
                context,
                'startDate'.tr(),
                _formatDate(goal.startDate),
                icon: Icons.calendar_today,
              ),
              _buildDetailRow(
                context,
                'endDate'.tr(),
                goal.endDate != null ? _formatDate(goal.endDate!) : 'none'.tr(),
                icon: Icons.event,
              ),
              _buildDetailRow(
                context,
                'visibility'.tr(),
                goal.visibility == FitnessVisibility.public
                    ? 'visibilityPublic'.tr()
                    : 'visibilityPrivate'.tr(),
                icon: Icons.visibility,
              ),
              if (goal.description != null)
                _buildDetailRow(
                  context,
                  'description'.tr(),
                  goal.description!,
                  icon: Icons.description,
                ),
            ],
          ),
        );
      },
      loading: () => SheetScaffold(
        titleText: 'loading'.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SheetScaffold(
        titleText: 'errorGeneric'.tr(args: [e.toString()]),
        child: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: icon != null ? 100 : 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDetails(BuildContext context, SnWorkout workout) {
    final items = <Widget>[];

    if (workout.distance != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.straighten,
          'Distance',
          '${workout.distance} ${workout.distanceUnit ?? 'km'}',
        ),
      );
    }
    if (workout.meta != null && workout.meta!['steps'] != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.directions_walk,
          'Steps',
          '${workout.meta!['steps']}',
        ),
      );
    }
    if (workout.averageHeartRate != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.monitor_heart,
          'Avg Heart Rate',
          '${workout.averageHeartRate} bpm',
        ),
      );
    }
    if (workout.maxHeartRate != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.favorite,
          'Max Heart Rate',
          '${workout.maxHeartRate} bpm',
        ),
      );
    }
    if (workout.averageSpeed != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.speed,
          'Avg Speed',
          '${workout.averageSpeed} km/h',
        ),
      );
    }
    if (workout.maxSpeed != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.bolt,
          'Max Speed',
          '${workout.maxSpeed} km/h',
        ),
      );
    }
    if (workout.elevationGain != null) {
      items.add(
        _buildMetaRow(
          context,
          Icons.terrain,
          'Elevation Gain',
          '+${workout.elevationGain}m',
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _getWorkoutTypeName(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => 'workoutTypeStrength'.tr(),
      WorkoutType.cardio => 'workoutTypeCardio'.tr(),
      WorkoutType.hiit => 'workoutTypeHiit'.tr(),
      WorkoutType.yoga => 'workoutTypeYoga'.tr(),
      WorkoutType.other => 'workoutTypeOther'.tr(),
    };
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => Icons.fitness_center,
      WorkoutType.cardio => Icons.directions_run,
      WorkoutType.hiit => Icons.flash_on,
      WorkoutType.yoga => Icons.self_improvement,
      WorkoutType.other => Icons.sports,
    };
  }

  String _getGoalTypeName(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => 'goalTypeWeightLoss'.tr(),
      FitnessGoalType.weightGain => 'goalTypeWeightGain'.tr(),
      FitnessGoalType.steps => 'goalTypeSteps'.tr(),
      FitnessGoalType.distance => 'goalTypeDistance'.tr(),
      FitnessGoalType.duration => 'goalTypeDuration'.tr(),
      FitnessGoalType.reps => 'goalTypeReps'.tr(),
      FitnessGoalType.strength => 'goalTypeStrength'.tr(),
      FitnessGoalType.cardio => 'goalTypeCardio'.tr(),
      FitnessGoalType.flexibility => 'goalTypeFlexibility'.tr(),
      FitnessGoalType.custom => 'goalTypeCustom'.tr(),
    };
  }

  String _getMetricTypeName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'metricTypeWeight'.tr(),
      FitnessMetricType.bodyFat => 'metricTypeBodyFat'.tr(),
      FitnessMetricType.steps => 'metricTypeSteps'.tr(),
      FitnessMetricType.heartRate => 'metricTypeHeartRate'.tr(),
      FitnessMetricType.sleep => 'metricTypeSleep'.tr(),
      FitnessMetricType.calories => 'metricTypeCalories'.tr(),
      FitnessMetricType.waterIntake => 'metricTypeWaterIntake'.tr(),
      FitnessMetricType.distance => 'metricTypeDistance'.tr(),
      FitnessMetricType.custom => 'metricTypeCustom'.tr(),
    };
  }

  IconData _getMetricIcon(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => Icons.monitor_weight,
      FitnessMetricType.bodyFat => Icons.percent,
      FitnessMetricType.steps => Icons.directions_walk,
      FitnessMetricType.heartRate => Icons.monitor_heart,
      FitnessMetricType.sleep => Icons.bedtime,
      FitnessMetricType.calories => Icons.local_fire_department,
      FitnessMetricType.waterIntake => Icons.water_drop,
      FitnessMetricType.distance => Icons.straighten,
      FitnessMetricType.custom => Icons.show_chart,
    };
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
