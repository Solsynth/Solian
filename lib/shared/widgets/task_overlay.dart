import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'task_overlay_state.dart';
import 'unfold_reveal.dart';

/// The capsule's own height: the 36px status ring plus the 6px padding that
/// wraps it. Mirrors `_TaskOverlayPill._ringSize` and its inner padding.
const double _taskPillHeight = 48;

/// Clear space the capsule keeps from the window's bottom edge, so it never
/// sits flush against it. Widens past the system inset (home indicator,
/// gesture bar) when one is present.
const double _taskOverlayBottomMargin = 16;

/// Height of the lane the task pill floats in, above the system bottom inset.
///
/// The pill is narrower than the lane and centered horizontally, the way a
/// Live Activity floats over the content instead of spanning the window edge
/// to edge. Vertically it sits at least [_taskOverlayBottomMargin] above the
/// bottom edge, so the lane's top slack carries its elevation shadow while the
/// strip below it is that margin.
const double taskOverlayHeight =
    _taskPillHeight + _taskOverlayBottomMargin * 2;

/// Toggles the process-wide wakelock while an app task is running.
///
/// Best effort: platforms that cannot satisfy the request (or browsers without
/// a user gesture) must never break task bookkeeping.
Future<void> _setWakelock(bool enable) async {
  try {
    if (enable) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  } catch (_) {
    // Ignored on purpose.
  }
}

// --- Shared helpers ---

IconData _taskStatusIcon(AppTask? task) {
  if (task == null) return Symbols.sync;
  return switch (task.status) {
    AppTaskStatus.pending => Symbols.schedule,
    AppTaskStatus.inProgress => switch (task.type) {
      AppTaskType.driveDownload => Symbols.download,
      AppTaskType.accountCheckIn => Symbols.local_fire_department,
      _ => Symbols.upload,
    },
    AppTaskStatus.paused => Symbols.pause,
    AppTaskStatus.completed => Symbols.check,
    AppTaskStatus.failed => Symbols.error,
    AppTaskStatus.cancelled => Symbols.cancel,
    AppTaskStatus.expired => Symbols.timer_off,
  };
}

Color _taskStatusColor(ColorScheme colorScheme, AppTask? task) {
  if (task == null) return colorScheme.primary;
  return switch (task.status) {
    AppTaskStatus.completed => Colors.green,
    AppTaskStatus.failed ||
    AppTaskStatus.cancelled ||
    AppTaskStatus.expired => colorScheme.error,
    AppTaskStatus.paused => colorScheme.tertiary,
    AppTaskStatus.pending => colorScheme.secondary,
    AppTaskStatus.inProgress => colorScheme.primary,
  };
}

/// Progress for indicators. Returns null when the task is in a preparation
/// stage whose duration cannot be estimated.
double? _taskIndicatorProgress(AppTask task) {
  if (_taskHasIndeterminateProgress(task)) return null;
  if (task.status == AppTaskStatus.completed || task.progress >= 1) {
    return 1;
  }
  if (task.status == AppTaskStatus.pending) return 0;
  return task.progress.clamp(0.0, 1.0);
}

bool _taskHasIndeterminateProgress(AppTask? task) {
  if (task == null || !task.isActive || task.type != AppTaskType.driveUpload) {
    return false;
  }
  final stage = task.metadata?['stage']?.toString();
  return stage == DriveUploadStage.preparing ||
      stage == DriveUploadStage.hashing ||
      stage == DriveUploadStage.preparingMedia ||
      stage == DriveUploadStage.creatingUpload;
}

String _taskStatusLabel(AppTaskStatus status) {
  return switch (status) {
    AppTaskStatus.pending => 'taskStatusPending'.tr(),
    AppTaskStatus.inProgress => 'taskStatusInProgress'.tr(),
    AppTaskStatus.paused => 'taskStatusPaused'.tr(),
    AppTaskStatus.completed => 'taskStatusCompleted'.tr(),
    AppTaskStatus.failed => 'taskStatusFailed'.tr(),
    AppTaskStatus.cancelled => 'taskStatusCancelled'.tr(),
    AppTaskStatus.expired => 'taskStatusExpired'.tr(),
  };
}

String _taskTypeLabel(String type) {
  return switch (type) {
    AppTaskType.driveUpload => 'taskTypeDriveUpload'.tr(),
    AppTaskType.driveDownload => 'taskTypeDriveDownload'.tr(),
    AppTaskType.postPublish => 'taskTypePostPublish'.tr(),
    AppTaskType.accountCheckIn => 'checkInTemple'.tr(),
    _ => type,
  };
}

// --- Overlay ---

/// The floating task pill.
///
/// Shaped like a Live Activity: one centered capsule that slides up into its
/// lane, shows the state as a progress ring, and unfolds the sentence beside
/// that ring once it has landed. When nothing is left to report it withdraws
/// into the ring while the lane closes, so the settled pill never resizes
/// anything above it.
class TaskOverlay extends HookConsumerWidget {
  const TaskOverlay({super.key});

  /// Beat between the pill landing and the sentence unfolding, matching the
  /// status capsule so the widen starts after the drop rather than during it.
  static const Duration _unfoldDelay = Duration(milliseconds: 200);

  static const Duration _unfoldDuration = Duration(milliseconds: 300);

  /// Shorter than the lane's own slide, so the pill is a bare ring again
  /// before the lane has finished closing.
  static const Duration _retractDuration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(tasksProvider);
    final snapshot = buildTaskOverlaySnapshot(allTasks, now: DateTime.now());
    final isDesktop = DesktopWindowFrame.isPlatformDesktop;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // The lane keeps this widget mounted while it closes, so the last pill has
    // to survive the empty snapshot: without it the exit would clip a blank
    // lane instead of carrying the ring down out of sight.
    final retained = useRef<TaskOverlaySnapshot?>(null);
    if (snapshot.isVisible) retained.value = snapshot;
    final shown = snapshot.isVisible ? snapshot : retained.value;

    final unfold = useAnimationController(
      duration: reduceMotion ? Duration.zero : _unfoldDuration,
      reverseDuration: reduceMotion ? Duration.zero : _retractDuration,
      initialValue: reduceMotion ? 1 : 0,
    );

    // The lane owns the vertical flight; this owns the sentence. Leaving, the
    // sentence retracts first so the lane closes around a bare ring, the same
    // silhouette the entrance showed.
    useEffect(() {
      if (!snapshot.isVisible) {
        unfold.reverse();
        return null;
      }
      final timer = Timer(_unfoldDelay, () {
        if (unfold.status == AnimationStatus.dismissed) unfold.forward();
      });
      return timer.cancel;
    }, [snapshot.isVisible, unfold]);

    if (shown == null) return const SizedBox.shrink();

    // Pinned to the lane's lower edge rather than centered, so the capsule
    // keeps its clearance even when a large text scale makes it taller than
    // the nominal pill height. The lane already reserves the system inset, so
    // the margin stacks on top of it here.
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              _taskOverlayBottomMargin + MediaQuery.paddingOf(context).bottom,
        ),
        child: _TaskOverlayPill(
          snapshot: shown,
          unfold: CurvedAnimation(
            parent: unfold,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          isDesktop: isDesktop,
        ),
      ),
    );
  }
}

class TaskOverlayHost extends ConsumerStatefulWidget {
  const TaskOverlayHost({super.key});

  @override
  ConsumerState<TaskOverlayHost> createState() => _TaskOverlayHostState();
}

class _TaskOverlayHostState extends ConsumerState<TaskOverlayHost>
    with SingleTickerProviderStateMixin {
  static const Duration _laneDuration = Duration(milliseconds: 320);

  late final AnimationController _lane = AnimationController(
    vsync: this,
    duration: _laneDuration,
    reverseDuration: const Duration(milliseconds: 260),
  );
  late final CurvedAnimation _laneCurve = CurvedAnimation(
    parent: _lane,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  Timer? _clearTimer;
  bool _wakelockHeld = false;

  @override
  void dispose() {
    _clearTimer?.cancel();
    _lane.dispose();
    _laneCurve.dispose();
    _releaseWakelock();
    super.dispose();
  }

  /// Keeps the screen awake for exactly as long as a task is running.
  void _syncWakelock(List<AppTask> allTasks) {
    final shouldHold = allTasks.any(
      (task) =>
          task.status == AppTaskStatus.pending ||
          task.status == AppTaskStatus.inProgress,
    );
    if (shouldHold == _wakelockHeld) return;
    _wakelockHeld = shouldHold;
    _setWakelock(shouldHold);
  }

  void _releaseWakelock() {
    if (!_wakelockHeld) return;
    _wakelockHeld = false;
    _setWakelock(false);
  }

  void _syncAutoClear(List<AppTask> allTasks) {
    final staleCompletedIds = finishedTaskIdsToAutoClear(
      allTasks,
      now: DateTime.now(),
    );
    if (staleCompletedIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(tasksProvider.notifier);
        for (final id in staleCompletedIds) {
          notifier.removeTask(id);
        }
      });
    }

    final nextCompletedTask =
        allTasks
            .where((task) => task.isFinished)
            .where(
              (task) =>
                  DateTime.now().difference(task.updatedAt) <
                  kTaskOverlayCompletedRetention,
            )
            .toList()
          ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    _clearTimer?.cancel();
    if (nextCompletedTask.isNotEmpty) {
      final oldestVisibleCompleted = nextCompletedTask.first;
      final remaining =
          kTaskOverlayCompletedRetention -
          DateTime.now().difference(oldestVisibleCompleted.updatedAt);
      _clearTimer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
        final notifier = ref.read(tasksProvider.notifier);
        for (final id in finishedTaskIdsToAutoClear(
          ref.read(tasksProvider),
          now: DateTime.now(),
        )) {
          notifier.removeTask(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider);
    final snapshot = buildTaskOverlaySnapshot(allTasks, now: DateTime.now());
    final laneHeight =
        taskOverlayHeight + MediaQuery.paddingOf(context).bottom;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    _syncWakelock(allTasks);
    _syncAutoClear(allTasks);

    // Reduce motion skips the flight instead of racing it: the controller is
    // left alone and the lane simply is open or shut.
    if (!reduceMotion) {
      if (snapshot.isVisible) {
        if (!_lane.isAnimating && !_lane.isCompleted) _lane.forward();
      } else if (!_lane.isDismissed) {
        _lane.reverse();
      }
    }

    final shut = reduceMotion ? !snapshot.isVisible : _lane.isDismissed;
    if (!snapshot.isVisible && shut) return const SizedBox.shrink();

    // The lane is a full-width band pinned to the window's bottom edge, so
    // its height never moves anything above it; the clip lets the capsule
    // rise out of that edge as the lane opens, over the content.
    return AnimatedBuilder(
      animation: _laneCurve,
      builder: (context, child) {
        final t = reduceMotion
            ? (snapshot.isVisible ? 1.0 : 0.0)
            : _laneCurve.value;
        return SizedBox(
          height: laneHeight * t,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.bottomCenter,
              minHeight: laneHeight,
              maxHeight: laneHeight,
              child: Opacity(opacity: t, child: child),
            ),
          ),
        );
      },
      child: SizedBox(height: laneHeight, child: const TaskOverlay()),
    );
  }
}

/// The capsule itself: a progress ring that always shows, and the sentence
/// that unfolds beside it.
///
/// The ring is the pill's anchor. It carries the status glyph in its hole and
/// the task's progress on its stroke, so the collapsed pill still says what is
/// happening; the sentence only adds the name and the detail.
class _TaskOverlayPill extends ConsumerWidget {
  final TaskOverlaySnapshot snapshot;
  final Animation<double> unfold;
  final bool isDesktop;

  const _TaskOverlayPill({
    required this.snapshot,
    required this.unfold,
    required this.isDesktop,
  });

  static const double _ringSize = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTask = snapshot.primaryTask;
    final visibleCount = snapshot.visibleTasks.length;
    final completedCount = snapshot.visibleTasks
        .where((task) => task.status == AppTaskStatus.completed)
        .length;
    final title = _buildTitle(primaryTask);
    final subtitle = _buildSubtitle(primaryTask, visibleCount, completedCount);
    final double? progress = _taskHasIndeterminateProgress(primaryTask)
        ? null
        : snapshot.progress.clamp(0.0, 1.0);
    final statusColor = _taskStatusColor(colorScheme, primaryTask);
    final progressLabel = progress == null
        ? ''
        : ', ${(progress * 100).round()}% ${'taskProgress'.tr()}';
    final label = '$title, $subtitle$progressLabel';

    final fill = Color.alphaBlend(
      statusColor.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.20 : 0.12,
      ),
      colorScheme.surfaceContainerHigh,
    );

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: fill,
          elevation: 4,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
          surfaceTintColor: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showTaskSheet(context, ref),
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TaskRing(
                    task: primaryTask,
                    progress: progress,
                    color: statusColor,
                    size: _ringSize,
                  ),
                  UnfoldReveal(
                    animation: unfold,
                    inset: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 240 : 190,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (progress != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              '${(progress * 100).round()}%',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(width: 2),
                          Icon(
                            Symbols.expand_less,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildTitle(AppTask? task) {
    if (task == null) return 'tasks'.tr();
    if (task.title.isNotEmpty) return task.title;
    return task.status == AppTaskStatus.completed
        ? 'taskStatusCompleted'.tr()
        : 'taskWorking'.tr();
  }

  String _buildSubtitle(AppTask? task, int visibleCount, int completedCount) {
    final otherCount = visibleCount - 1;
    if (task == null) return 'tasksCount'.plural(visibleCount);

    if (task.status == AppTaskStatus.completed &&
        completedCount == visibleCount) {
      return completedCount == 1
          ? 'taskCompletedJustNow'.tr()
          : 'taskFinishedJustNow'.plural(completedCount);
    }

    final statusText = task.statusMessage?.trim();
    if (statusText != null && statusText.isNotEmpty) {
      return otherCount > 0
          ? '$statusText · ${'taskMoreCount'.tr(args: ['$otherCount'])}'
          : statusText;
    }

    final label = _taskStatusLabel(task.status);
    return otherCount > 0
        ? '$label · ${'taskMoreCount'.tr(args: ['$otherCount'])}'
        : label;
  }

  void _showTaskSheet(BuildContext context, WidgetRef ref) {
    final navigatorContext =
        ref.read(routerProvider).navigatorKey.currentContext ?? context;

    showModalBottomSheet<void>(
      context: navigatorContext,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => const _TasksSheet(),
    );
  }
}

/// The pill's anchor: a progress ring with the status glyph in its hole.
///
/// A determinate task burns its progress along the stroke; a preparation stage
/// spins instead of claiming a figure it cannot know yet.
class _TaskRing extends StatelessWidget {
  final AppTask? task;
  final double? progress;
  final Color color;
  final double size;

  const _TaskRing({
    required this.task,
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final glyph = _taskStatusIcon(task);
    final progress = this.progress;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: progress == null
                ? CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      );
                    },
                  ),
          ),
          Icon(glyph, size: size * 0.5, color: color),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _StatusIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(icon, color: color, size: size * 0.68),
      ),
    );
  }
}

// --- Live tasks sheet (watches provider) ---

class _TasksSheet extends ConsumerWidget {
  const _TasksSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final sortedTasks = [...tasks]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final notifier = ref.read(tasksProvider.notifier);
    final hasFinished = tasks.any((t) => t.isFinished);
    final scheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      titleText: 'tasks'.tr(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'taskTotalCount'.tr(args: ['${sortedTasks.length}']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'clearCompleted'.tr(),
                  onPressed: hasFinished ? notifier.clearCompleted : null,
                  icon: const Icon(Symbols.done_all),
                ),
                IconButton(
                  tooltip: 'clearAll'.tr(),
                  onPressed: sortedTasks.isEmpty ? null : notifier.clearAll,
                  icon: const Icon(Symbols.delete_sweep),
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedTasks.isEmpty
                ? _EmptyTasksState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    itemCount: sortedTasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = sortedTasks[index];
                      return AppTaskTile(key: ValueKey(task.id), task: task);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Symbols.inbox,
      title: 'taskNoTasks'.tr(),
      compact: true,
    );
  }
}

// --- Task tile ---

class AppTaskTile extends StatelessWidget {
  final AppTask task;

  const AppTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _taskStatusColor(scheme, task);
    final progress = _taskIndicatorProgress(task);

    return Semantics(
      container: true,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: _StatusIcon(
              icon: _taskStatusIcon(task),
              color: statusColor,
              size: 38,
            ),
            title: Text(
              task.title.isEmpty ? 'untitled'.tr() : task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              task.statusMessage?.trim().isNotEmpty == true
                  ? task.statusMessage!
                  : _taskTypeLabel(task.type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TaskProgressIndicator(progress: progress, color: statusColor),
                const SizedBox(width: 4),
                Icon(
                  Symbols.expand_more,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            shape: const RoundedRectangleBorder(),
            collapsedShape: const RoundedRectangleBorder(),
            children: [_TaskDetailsCard(task: task)],
          ),
        ),
      ),
    );
  }
}

class _TaskProgressIndicator extends StatelessWidget {
  final double? progress;
  final Color color;

  const _TaskProgressIndicator({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (progress == null) {
      return SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          backgroundColor: scheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress!.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${(value * 100).round()}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskProgressBar extends StatelessWidget {
  final double? progress;
  final Color color;

  const _TaskProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final indicator = progress == null
        ? LinearProgressIndicator(
            minHeight: 7,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          )
        : TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress!.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          );
    return ClipRRect(borderRadius: BorderRadius.circular(6), child: indicator);
  }
}

class _TaskDetailsCard extends StatelessWidget {
  final AppTask task;

  const _TaskDetailsCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: switch (task.type) {
        AppTaskType.driveUpload => _DriveUploadDetails(task: task),
        AppTaskType.driveDownload => _DriveDownloadDetails(task: task),
        AppTaskType.postPublish => _PostPublishDetails(task: task),
        _ => _GenericTaskDetails(task: task),
      },
    );
  }
}

class _DriveUploadDetails extends StatelessWidget {
  final AppTask task;

  const _DriveUploadDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meta = task.metadata;
    final transmissionProgress =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final uploadedChunks = (meta?['uploadedChunks'] as num?)?.toInt() ?? 0;
    final totalChunks = (meta?['totalChunks'] as num?)?.toInt() ?? 1;
    final fileSize = (meta?['fileSize'] as num?)?.toInt() ?? 0;
    final stage = meta?['stage']?.toString();
    final stageProgress =
        (meta?['stageProgress'] as num?)?.toDouble() ?? task.progress;
    final sourceProgress =
        (meta?['sourceProgress'] as num?)?.toDouble() ?? transmissionProgress;
    final thumbnailProgress =
        (meta?['thumbnailProgress'] as num?)?.toDouble() ?? 0.0;
    final compressionProgress =
        (meta?['compressionProgress'] as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(
          label:
              task.statusMessage ??
              (stage == null
                  ? 'taskProcessing'.tr()
                  : DriveUploadStage.label(stage)),
          color: scheme.primary,
        ),
        const SizedBox(height: 7),
        _ProgressRow(
          left: '${(stageProgress * 100).toStringAsFixed(1)}%',
          right: stage == null ? '' : DriveUploadStage.label(stage),
        ),
        const SizedBox(height: 5),
        _TaskProgressBar(
          progress: _taskIndicatorProgress(task),
          color: scheme.primary,
        ),
        const SizedBox(height: 14),
        _DetailSectionHeader(
          label: 'taskFileTransmission'.tr(),
          color: scheme.secondary,
        ),
        const SizedBox(height: 7),
        _ProgressRow(
          left: '${(transmissionProgress * 100).toStringAsFixed(1)}%',
          right:
              '${formatFileSize((transmissionProgress * fileSize).toInt())} / ${formatFileSize(fileSize)}',
        ),
        const SizedBox(height: 5),
        _TaskProgressBar(
          progress: transmissionProgress,
          color: scheme.secondary,
        ),
        const SizedBox(height: 6),
        Text(
          '${_formatBytesPerSecond(task)} · ${'taskChunksCount'.tr(namedArgs: {'current': '$uploadedChunks', 'total': '$totalChunks'})}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        _StageProgressBar(
          label: 'Source',
          progress: sourceProgress,
          color: scheme.tertiary,
        ),
        if (thumbnailProgress > 0 || meta?['thumbnailProgress'] != null) ...[
          const SizedBox(height: 8),
          _StageProgressBar(
            label: 'Thumbnail',
            progress: thumbnailProgress,
            color: scheme.tertiary,
          ),
        ],
        if (compressionProgress > 0 ||
            meta?['compressionProgress'] != null) ...[
          const SizedBox(height: 8),
          _StageProgressBar(
            label: 'Compression',
            progress: compressionProgress,
            color: scheme.tertiary,
          ),
        ],
        if (task.errorMessage != null) ...[
          const SizedBox(height: 12),
          _ErrorText(message: task.errorMessage!),
        ],
      ],
    );
  }

  String _formatBytesPerSecond(AppTask task) {
    final meta = task.metadata;
    final transmissionProgress =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final fileSize = (meta?['fileSize'] as num?)?.toInt() ?? 0;
    final bytes = (transmissionProgress * fileSize).toInt();
    if (bytes == 0) return '0 B/s';

    final elapsedSeconds = DateTime.now().difference(task.createdAt).inSeconds;
    if (elapsedSeconds <= 0) return '0 B/s';

    return '${formatFileSize((bytes / elapsedSeconds).toInt())}/s';
  }
}

class _DriveDownloadDetails extends StatelessWidget {
  final AppTask task;

  const _DriveDownloadDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    final meta = task.metadata;
    final totalBytes = (meta?['totalBytes'] as num?)?.toInt() ?? 0;
    final downloadedBytes = (meta?['downloadedBytes'] as num?)?.toInt() ?? 0;

    return _ProgressDetails(
      label: task.statusMessage ?? 'taskDownloading'.tr(),
      progress: task.progress,
      right:
          '${formatFileSize(downloadedBytes)} / ${formatFileSize(totalBytes)}',
      errorMessage: task.errorMessage,
    );
  }
}

class _PostPublishDetails extends StatelessWidget {
  final AppTask task;

  const _PostPublishDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    return _ProgressDetails(
      label: task.statusMessage ?? 'taskPostPublishPublishing'.tr(),
      progress: task.progress,
      right: _taskStatusLabel(task.status),
      errorMessage: task.errorMessage,
    );
  }
}

class _GenericTaskDetails extends StatelessWidget {
  final AppTask task;

  const _GenericTaskDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    return _ProgressDetails(
      label: 'taskProgress'.tr(),
      progress: task.progress,
      right: _taskStatusLabel(task.status),
      errorMessage: task.errorMessage,
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  final String label;
  final double progress;
  final String right;
  final String? errorMessage;

  const _ProgressDetails({
    required this.label,
    required this.progress,
    required this.right,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(label: label, color: scheme.primary),
        const SizedBox(height: 7),
        _ProgressRow(
          left: '${(progress * 100).toStringAsFixed(1)}%',
          right: right,
        ),
        const SizedBox(height: 5),
        _TaskProgressBar(progress: progress, color: scheme.primary),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _ErrorText(message: errorMessage!),
        ],
      ],
    );
  }
}

class _DetailSectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _DetailSectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _StageProgressBar({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressRow(
          left: label,
          right: '${(progress * 100).toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 5),
        _TaskProgressBar(progress: progress, color: color),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String left;
  final String right;

  const _ProgressRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: style?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.error, size: 16, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
