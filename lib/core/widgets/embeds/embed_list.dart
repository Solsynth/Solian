import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/livestreams/livestream.dart';
import 'package:island/polls/polls_widgets/poll/poll_submit.dart';
import 'package:island/core/widgets/embeds/link.dart';
import 'package:island/wallets/widgets/fund_envelope.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:latlong2/latlong.dart';
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
                  : _LivestreamPreviewCard(
                      livestreamId: embedData['id'],
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
            'location' => _LocationEmbedCard(
              name: embedData['name']?.toString(),
              address: embedData['address']?.toString(),
              wkt: embedData['wkt']?.toString(),
              margin: EdgeInsets.symmetric(
                horizontal: widget.renderingPadding.horizontal,
                vertical: 8,
              ),
            ),
            'meet' =>
              embedData['id'] == null
                  ? const Text('Meet was unavailable...')
                  : _MeetEmbedCard(
                      meetId: embedData['id'],
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
      data: (workout) {
        final duration = workout.endTime?.difference(workout.startTime);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(workout.startTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (workout.caloriesBurned != null || duration != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (duration != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(duration),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                          if (duration != null &&
                              workout.caloriesBurned != null)
                            const SizedBox(width: 12),
                          if (workout.caloriesBurned != null) ...[
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.caloriesBurned} ${'calories'.tr()}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (workout.distance != null ||
                        workout.averageHeartRate != null ||
                        workout.averageSpeed != null ||
                        workout.elevationGain != null ||
                        (workout.meta != null &&
                            workout.meta!['steps'] != null)) ...[
                      const SizedBox(height: 8),
                      _buildWorkoutMetaChips(context, workout),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildWorkoutMetaChips(BuildContext context, SnWorkout workout) {
    final chips = <Widget>[];

    if (workout.distance != null) {
      chips.add(
        _buildMetaChip(
          context,
          Icons.straighten,
          '${workout.distance} ${workout.distanceUnit ?? 'km'}',
        ),
      );
    }

    if (workout.meta != null && workout.meta!['steps'] != null) {
      chips.add(
        _buildMetaChip(
          context,
          Icons.directions_walk,
          '${workout.meta!['steps']}',
        ),
      );
    }

    if (workout.averageHeartRate != null) {
      chips.add(
        _buildMetaChip(
          context,
          Icons.monitor_heart,
          '~${workout.averageHeartRate} bpm',
        ),
      );
    }

    if (workout.averageSpeed != null) {
      chips.add(
        _buildMetaChip(context, Icons.speed, '${workout.averageSpeed} km/h'),
      );
    }

    if (workout.elevationGain != null) {
      chips.add(
        _buildMetaChip(context, Icons.terrain, '+${workout.elevationGain}m'),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricContent(WidgetRef ref, String id) {
    final metricAsync = ref.watch(metricDetailProvider(id));

    return metricAsync.when(
      data: (metric) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${metric.value} ${metric.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(metric.recordedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
      data: (goal) {
        final progress =
            goal.targetValue != null &&
                goal.currentValue != null &&
                goal.targetValue! > 0
            ? (goal.currentValue! / goal.targetValue! * 100).clamp(0.0, 100.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (goal.targetValue != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.currentValue?.toStringAsFixed(0) ?? 0} ${goal.unit ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '${progress.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _LivestreamPreviewCard extends ConsumerWidget {
  final String livestreamId;
  final EdgeInsets margin;

  const _LivestreamPreviewCard({
    required this.livestreamId,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final theme = Theme.of(context);

    return Card(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.router.push(LivestreamWatchRoute(livestreamId: livestreamId)),
        child: detailAsync.when(
          data: (stream) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (stream.thumbnail?.id != null)
                        CloudImageWidget(
                          fileId: stream.thumbnail!.id,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: theme.colorScheme.surfaceContainerHigh,
                          child: Center(
                            child: Icon(
                              Symbols.live_tv,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: stream.status == SnLiveStreamStatus.active
                                    ? Colors.red
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (stream.status == SnLiveStreamStatus.active) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Gap(4),
                                  ],
                                  Text(
                                    stream.status == SnLiveStreamStatus.active
                                        ? 'live'.tr()
                                        : 'ended'.tr(),
                                    style: TextStyle(
                                      color: stream.status == SnLiveStreamStatus.active
                                          ? Colors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title ?? 'untitledLivestream'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (stream.description?.isNotEmpty ?? false) ...[
                      const Gap(4),
                      Text(
                        stream.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          loading: () => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('livestreamUnavailable'.tr()),
          ),
        ),
      ),
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return workoutAsync.when(
      data: (workout) {
        final duration = workout.endTime?.difference(workout.startTime);

        return SheetScaffold(
          titleText: workout.name,
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card with Key Stats
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _getWorkoutIcon(workout.type),
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getWorkoutTypeName(workout.type),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(workout.startTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats Row
              if (duration != null ||
                  workout.caloriesBurned != null ||
                  workout.distance != null)
                Row(
                  children: [
                    if (duration != null)
                      Expanded(
                        child: _buildStatCard(
                          context,
                          Icons.timer_outlined,
                          _formatDuration(duration),
                          'duration'.tr(),
                          colorScheme.primary,
                        ),
                      ),
                    if (duration != null &&
                        (workout.caloriesBurned != null ||
                            workout.distance != null))
                      const SizedBox(width: 12),
                    if (workout.caloriesBurned != null)
                      Expanded(
                        child: _buildStatCard(
                          context,
                          Icons.local_fire_department_outlined,
                          '${workout.caloriesBurned}',
                          'calories'.tr(),
                          colorScheme.error,
                        ),
                      ),
                    if (workout.caloriesBurned != null &&
                        workout.distance != null)
                      const SizedBox(width: 12),
                    if (workout.distance != null)
                      Expanded(
                        child: _buildStatCard(
                          context,
                          Icons.straighten,
                          '${workout.distance}',
                          workout.distanceUnit ?? 'km',
                          colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              if (duration != null ||
                  workout.caloriesBurned != null ||
                  workout.distance != null)
                const SizedBox(height: 16),

              // Details Section
              Text(
                'details'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                color: colorScheme.surface,
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.access_time,
                      title: 'startTime'.tr(),
                      subtitle: _formatDateTime(workout.startTime),
                    ),
                    if (workout.endTime != null)
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                    if (workout.endTime != null)
                      _buildListTile(
                        context,
                        icon: Icons.schedule,
                        title: 'endTime'.tr(),
                        subtitle: _formatDateTime(workout.endTime!),
                      ),
                  ],
                ),
              ),

              // Description & Notes
              if (workout.description != null || workout.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'notes'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (workout.description != null)
                          _buildNoteRow(
                            context,
                            Icons.description_outlined,
                            workout.description!,
                          ),
                        if (workout.description != null &&
                            workout.notes != null)
                          Divider(
                            height: 24,
                            color: colorScheme.outlineVariant,
                          ),
                        if (workout.notes != null)
                          _buildNoteRow(
                            context,
                            Icons.note_outlined,
                            workout.notes!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Activity Details Chips
              if (workout.distance != null ||
                  workout.averageHeartRate != null ||
                  workout.maxHeartRate != null ||
                  workout.averageSpeed != null ||
                  workout.maxSpeed != null ||
                  workout.elevationGain != null ||
                  (workout.meta != null && workout.meta!['steps'] != null)) ...[
                const SizedBox(height: 16),
                Text(
                  'activityData'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActivityChips(context, workout),
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

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoteRow(BuildContext context, IconData icon, String content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChips(BuildContext context, SnWorkout workout) {
    final chips = <Widget>[];

    if (workout.distance != null) {
      chips.add(
        _buildAssistChip(
          context,
          Icons.straighten,
          '${workout.distance} ${workout.distanceUnit ?? 'km'}',
        ),
      );
    }

    if (workout.meta != null && workout.meta!['steps'] != null) {
      chips.add(
        _buildAssistChip(
          context,
          Icons.directions_walk,
          '${workout.meta!['steps']} steps',
        ),
      );
    }

    if (workout.averageHeartRate != null) {
      chips.add(
        _buildAssistChip(
          context,
          Icons.monitor_heart,
          'Avg ${workout.averageHeartRate} bpm',
        ),
      );
    }

    if (workout.maxHeartRate != null) {
      chips.add(
        _buildAssistChip(
          context,
          Icons.favorite,
          'Max ${workout.maxHeartRate} bpm',
        ),
      );
    }

    if (workout.averageSpeed != null) {
      chips.add(
        _buildAssistChip(
          context,
          Icons.speed,
          'Avg ${workout.averageSpeed} km/h',
        ),
      );
    }

    if (workout.maxSpeed != null) {
      chips.add(
        _buildAssistChip(context, Icons.bolt, 'Max ${workout.maxSpeed} km/h'),
      );
    }

    if (workout.elevationGain != null) {
      chips.add(
        _buildAssistChip(context, Icons.terrain, '+${workout.elevationGain}m'),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildAssistChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.primary),
      label: Text(label),
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildMetricSheet(BuildContext context, WidgetRef ref) {
    final metricAsync = ref.watch(metricDetailProvider(id));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return metricAsync.when(
      data: (metric) => SheetScaffold(
        titleText: _getMetricTypeName(metric.metricType),
        heightFactor: 0.6,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Value Card
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      _getMetricIcon(metric.metricType),
                      size: 48,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${metric.value}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric.unit,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details
            Text(
              'details'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              color: colorScheme.surface,
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.calendar_today,
                    title: 'recordedAt'.tr(),
                    subtitle: _formatDateTime(metric.recordedAt),
                  ),
                  if (metric.metricType == FitnessMetricType.weight ||
                      metric.metricType == FitnessMetricType.bodyFat) ...[
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: colorScheme.outlineVariant,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.monitor_weight,
                      title: 'metricType'.tr(),
                      subtitle: _getMetricTypeName(metric.metricType),
                    ),
                  ],
                ],
              ),
            ),

            // Notes
            if (metric.notes != null) ...[
              const SizedBox(height: 16),
              Text(
                'notes'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildNoteRow(
                    context,
                    Icons.note_outlined,
                    metric.notes!,
                  ),
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return goalAsync.when(
      data: (goal) {
        final progress =
            goal.targetValue != null &&
                goal.currentValue != null &&
                goal.targetValue! > 0
            ? (goal.currentValue! / goal.targetValue! * 100).clamp(0.0, 100.0)
            : 0.0;
        final isCompleted = progress >= 100;

        return SheetScaffold(
          titleText: goal.title,
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Progress Card
              Card(
                elevation: 0,
                color: isCompleted
                    ? colorScheme.tertiaryContainer
                    : colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: progress / 100,
                              strokeWidth: 10,
                              backgroundColor:
                                  (isCompleted
                                          ? colorScheme.onTertiaryContainer
                                          : colorScheme.onPrimaryContainer)
                                      .withOpacity(0.2),
                              color: isCompleted
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${progress.toStringAsFixed(0)}%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted
                                      ? colorScheme.onTertiaryContainer
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                isCompleted
                                    ? 'completed'.tr()
                                    : 'inProgress'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      (isCompleted
                                              ? colorScheme.onTertiaryContainer
                                              : colorScheme.onPrimaryContainer)
                                          .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (goal.targetValue != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${goal.currentValue?.toStringAsFixed(0) ?? 0} / ${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isCompleted
                                ? colorScheme.onTertiaryContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Goal Details
              Text(
                'goalDetails'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                color: colorScheme.surface,
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      icon: _getGoalIcon(goal.goalType),
                      title: 'goalType'.tr(),
                      subtitle: _getGoalTypeName(goal.goalType),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: colorScheme.outlineVariant,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.calendar_today,
                      title: 'startDate'.tr(),
                      subtitle: _formatDate(goal.startDate),
                    ),
                    if (goal.endDate != null)
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                    if (goal.endDate != null)
                      _buildListTile(
                        context,
                        icon: Icons.event,
                        title: 'endDate'.tr(),
                        subtitle: _formatDate(goal.endDate!),
                      ),
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: colorScheme.outlineVariant,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.visibility,
                      title: 'visibility'.tr(),
                      subtitle: goal.visibility == FitnessVisibility.public
                          ? 'visibilityPublic'.tr()
                          : 'visibilityPrivate'.tr(),
                    ),
                  ],
                ),
              ),

              // Description
              if (goal.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  'description'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildNoteRow(
                      context,
                      Icons.description_outlined,
                      goal.description!,
                    ),
                  ),
                ),
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

  IconData _getWorkoutIcon(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => Icons.fitness_center,
      WorkoutType.cardio => Icons.directions_run,
      WorkoutType.hiit => Icons.flash_on,
      WorkoutType.yoga => Icons.self_improvement,
      WorkoutType.other => Icons.sports,
    };
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

  IconData _getGoalIcon(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => Icons.trending_down,
      FitnessGoalType.weightGain => Icons.trending_up,
      FitnessGoalType.steps => Icons.directions_walk,
      FitnessGoalType.distance => Icons.straighten,
      FitnessGoalType.duration => Icons.timer,
      FitnessGoalType.reps => Icons.fitness_center,
      FitnessGoalType.strength => Icons.fitness_center,
      FitnessGoalType.cardio => Icons.directions_run,
      FitnessGoalType.flexibility => Icons.self_improvement,
      FitnessGoalType.custom => Icons.flag,
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

  String _formatDateTime(DateTime date) {
    final timeFormat = DateFormat.jm();
    return '${_formatDate(date)} · ${timeFormat.format(date)}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

final meetDetailProvider =
    FutureProvider.autoDispose.family<SnMeet, String>((ref, meetId) async {
  final service = ref.watch(meetServiceProvider);
  return service.getMeet(meetId);
});

class _LocationEmbedCard extends ConsumerWidget {
  final String? name;
  final String? address;
  final String? wkt;
  final EdgeInsets margin;

  const _LocationEmbedCard({
    this.name,
    this.address,
    this.wkt,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLocationDetailSheet(
          context,
          name: name,
          address: address,
          wkt: wkt,
        ),
        child: _LocationEmbedContent(
          name: name,
          address: address,
          wkt: wkt,
          theme: theme,
          colorScheme: colorScheme,
        ),
      ),
    );
  }
}

void _showLocationDetailSheet(
  BuildContext context, {
  String? name,
  String? address,
  String? wkt,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _LocationDetailSheet(
      name: name,
      address: address,
      wkt: wkt,
    ),
  );
}

class _LocationDetailSheet extends StatelessWidget {
  final String? name;
  final String? address;
  final String? wkt;

  const _LocationDetailSheet({this.name, this.address, this.wkt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    LatLng? point;
    if (wkt != null) {
      final match = RegExp(r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)')
          .firstMatch(wkt!);
      if (match != null) {
        final lon = double.tryParse(match.group(1)!);
        final lat = double.tryParse(match.group(2)!);
        if (lat != null && lon != null) {
          point = LatLng(lat, lon);
        }
      }
    }

    return SheetScaffold(
      titleText: name ?? 'location'.tr(),
      heightFactor: 0.75,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (point != null)
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.island.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (name != null)
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Symbols.location_on,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (address != null)
                            Text(
                              address!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (point != null) ...[
            const SizedBox(height: 16),
            Text(
              'coordinates'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              color: colorScheme.surface,
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    icon: Icons.arrow_upward,
                    title: 'latitude'.tr(),
                    subtitle: point.latitude.toStringAsFixed(6),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: colorScheme.outlineVariant,
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.arrow_forward,
                    title: 'longitude'.tr(),
                    subtitle: point.longitude.toStringAsFixed(6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LocationEmbedContent extends StatelessWidget {
  final String? name;
  final String? address;
  final String? wkt;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _LocationEmbedContent({
    this.name,
    this.address,
    this.wkt,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    LatLng? point;
    if (wkt != null) {
      final match = RegExp(r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)')
          .firstMatch(wkt!);
      if (match != null) {
        final lon = double.tryParse(match.group(1)!);
        final lat = double.tryParse(match.group(2)!);
        if (lat != null && lon != null) {
          point = LatLng(lat, lon);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (point != null)
          SizedBox(
            height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.island.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Symbols.location_on,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null)
                      Text(
                        name!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (address != null) ...[
                      if (name != null) const SizedBox(height: 4),
                      Text(
                        address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (point != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeetEmbedCard extends ConsumerWidget {
  final String meetId;
  final EdgeInsets margin;

  const _MeetEmbedCard({
    required this.meetId,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetDetailProvider(meetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMeetDetailSheet(context, ref, meetId),
        child: meetAsync.when(
          data: (meet) => Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Symbols.groups,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meet.notes ?? 'untitledMeet'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MeetStatusChip(status: meet.status),
                        ],
                      ),
                      if (meet.host != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'hostedBy'.tr(args: [meet.host!.nick]),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (meet.locationName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Symbols.location_on,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                meet.locationName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('meetUnavailable'.tr()),
          ),
        ),
      ),
    );
  }
}

void _showMeetDetailSheet(
  BuildContext context,
  WidgetRef ref,
  String meetId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _MeetDetailSheet(meetId: meetId),
  );
}

class _MeetDetailSheet extends ConsumerWidget {
  final String meetId;

  const _MeetDetailSheet({required this.meetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetDetailProvider(meetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return meetAsync.when(
      data: (meet) {
        return SheetScaffold(
          titleText: meet.notes ?? 'untitledMeet'.tr(),
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Host and Status header
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.onPrimaryContainer
                            .withOpacity(0.1),
                        child: Icon(
                          Symbols.groups,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (meet.host != null)
                              Text(
                                meet.host!.nick,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              meet.notes ?? 'untitledMeet'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MeetStatusChip(status: meet.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Location info
              if (meet.locationName != null ||
                  meet.locationAddress != null) ...[
                Text(
                  'location'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      if (meet.locationName != null)
                        _buildDetailTile(
                          context,
                          icon: Symbols.location_on,
                          title: 'locationName'.tr(),
                          subtitle: meet.locationName!,
                        ),
                      if (meet.locationName != null &&
                          meet.locationAddress != null)
                        Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: colorScheme.outlineVariant,
                        ),
                      if (meet.locationAddress != null)
                        _buildDetailTile(
                          context,
                          icon: Symbols.map,
                          title: 'locationAddress'.tr(),
                          subtitle: meet.locationAddress!,
                        ),
                    ],
                  ),
                ),
              ],
              // Participants
              if (meet.participants.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'participants'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      _buildDetailTile(
                        context,
                        icon: Symbols.person,
                        title: 'totalParticipants'.tr(),
                        subtitle: '${meet.participants.length}',
                      ),
                    ],
                  ),
                ),
              ],
              // Meet notes
              if (meet.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'notes'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Symbols.description,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            meet.notes!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => SheetScaffold(
        titleText: 'loading'.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => SheetScaffold(
        titleText: 'errorGeneric'.tr(),
        child: Center(child: Text('meetUnavailable'.tr())),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MeetStatusChip extends StatelessWidget {
  final SnMeetStatus status;

  const _MeetStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg, String label) = switch (status) {
      SnMeetStatus.active => (
        Colors.green.withOpacity(0.15),
        Colors.green,
        'active'.tr(),
      ),
      SnMeetStatus.completed => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        'completed'.tr(),
      ),
      SnMeetStatus.expired => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        'expired'.tr(),
      ),
      SnMeetStatus.cancelled => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        'cancelled'.tr(),
      ),
      SnMeetStatus.unknown => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        'unknown'.tr(),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
