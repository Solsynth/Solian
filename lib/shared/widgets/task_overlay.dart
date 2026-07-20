import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/route.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'task_overlay_state.dart';

double taskOverlayHeight(bool isDesktop) => isDesktop ? 32 : 56;

// --- Shared helpers ---

IconData _taskStatusIcon(AppTask? task) {
  if (task == null) return Symbols.sync;
  return switch (task.status) {
    AppTaskStatus.pending => Symbols.schedule,
    AppTaskStatus.inProgress =>
      task.type == AppTaskType.driveDownload
          ? Symbols.download
          : Symbols.upload,
    AppTaskStatus.paused => Symbols.pause_circle,
    AppTaskStatus.completed => Symbols.check_circle,
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

Color _taskStatusFillColor(ColorScheme colorScheme, AppTask? task) {
  if (task == null) return colorScheme.primary;
  return switch (task.status) {
    AppTaskStatus.completed => Colors.green,
    AppTaskStatus.failed ||
    AppTaskStatus.cancelled ||
    AppTaskStatus.expired => Colors.red,
    _ => colorScheme.primary,
  };
}

/// Determinate progress for indicators. Returns 1 when finished/complete.
double _taskIndicatorProgress(AppTask task) {
  if (task.status == AppTaskStatus.completed || task.progress >= 1) {
    return 1;
  }
  if (task.status == AppTaskStatus.pending) return 0;
  return task.progress.clamp(0.0, 1.0);
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
    _ => type,
  };
}

// --- Overlay ---

class TaskOverlay extends HookConsumerWidget {
  const TaskOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(tasksProvider);
    final snapshot = buildTaskOverlaySnapshot(allTasks, now: DateTime.now());
    final isDesktop = DesktopWindowFrame.isPlatformDesktop;
    final overlayHeight = taskOverlayHeight(isDesktop);
    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 320),
    );

    useEffect(() {
      if (snapshot.isVisible) {
        slideController.forward();
      } else {
        slideController.reverse();
      }
      return null;
    }, [snapshot.isVisible]);

    if (!snapshot.isVisible &&
        slideController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring:
          !snapshot.isVisible &&
          slideController.status == AnimationStatus.dismissed,
      child: AnimatedBuilder(
        animation: slideController,
        builder: (context, child) {
          final offset =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).evaluate(
                CurvedAnimation(
                  parent: slideController,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );
          return FractionalTranslation(translation: offset, child: child);
        },
        child: _TaskOverlayBar(
          snapshot: snapshot,
          height: overlayHeight,
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

class _TaskOverlayHostState extends ConsumerState<TaskOverlayHost> {
  Timer? _clearTimer;

  @override
  void dispose() {
    _clearTimer?.cancel();
    super.dispose();
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
    final isDesktop = DesktopWindowFrame.isPlatformDesktop;

    _syncAutoClear(allTasks);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      height: snapshot.isVisible ? taskOverlayHeight(isDesktop) : 0,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: taskOverlayHeight(isDesktop),
            child: const TaskOverlay(),
          ),
        ),
      ),
    );
  }
}

class _TaskOverlayBar extends ConsumerWidget {
  final TaskOverlaySnapshot snapshot;
  final double height;
  final bool isDesktop;

  const _TaskOverlayBar({
    required this.snapshot,
    required this.height,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTask = snapshot.primaryTask;
    final completedCount = snapshot.visibleTasks
        .where((task) => task.status == AppTaskStatus.completed)
        .length;
    final title = _buildTitle(primaryTask);
    final subtitle = _buildSubtitle(
      primaryTask,
      snapshot.visibleTasks.length,
      completedCount,
    );
    final fillColor = _taskStatusFillColor(colorScheme, primaryTask);
    final trackColor = colorScheme.surfaceContainerHighest;
    final label = '$title · $subtitle';
    final progress = snapshot.progress.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showTaskSheet(context, ref),
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: trackColor,
                        border: Border(
                          top: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    _buildForeground(
                      context,
                      theme,
                      color: Colors.white,
                      text: label,
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: _buildForeground(
                            context,
                            theme,
                            color: Colors.white,
                            text: label,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForeground(
    BuildContext context,
    ThemeData theme, {
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _contentHorizontalPadding(context),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 22 : 36,
            height: isDesktop ? 22 : 36,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(isDesktop ? 7 : 12),
            ),
            child: Icon(
              _taskStatusIcon(snapshot.primaryTask),
              color: color,
              size: isDesktop ? 14 : 20,
            ),
          ),
          Gap(isDesktop ? 8 : 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: isDesktop ? 13 : null,
                height: 1,
              ),
            ),
          ),
          Gap(isDesktop ? 8 : 12),
          Text(
            '${(snapshot.progress * 100).round()}%',
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: isDesktop ? 12 : null,
            ),
          ),
          Gap(isDesktop ? 6 : 8),
          Icon(
            Symbols.expand_less,
            color: color.withValues(alpha: 0.9),
            size: isDesktop ? 14 : 18,
          ),
        ],
      ),
    );
  }

  double _contentHorizontalPadding(BuildContext context) {
    if (isDesktop) return 16;
    final mediaQuery = MediaQuery.of(context);
    return 16 + math.max(mediaQuery.padding.left, mediaQuery.padding.right);
  }

  String _buildTitle(AppTask? task) {
    if (task == null) return 'Tasks';
    if (task.title.isNotEmpty) return task.title;
    return task.status == AppTaskStatus.completed ? 'Completed' : 'Working';
  }

  String _buildSubtitle(AppTask? task, int visibleCount, int completedCount) {
    final otherCount = visibleCount - 1;
    if (task == null) return '$visibleCount tasks';

    if (task.status == AppTaskStatus.completed &&
        completedCount == visibleCount) {
      return completedCount == 1
          ? 'Completed just now'
          : '$completedCount tasks finished just now';
    }

    final statusText = task.statusMessage?.trim();
    if (statusText != null && statusText.isNotEmpty) {
      return otherCount > 0 ? '$statusText · +$otherCount more' : statusText;
    }

    final label = switch (task.status) {
      AppTaskStatus.pending => 'Queued',
      AppTaskStatus.inProgress => 'In progress',
      AppTaskStatus.paused => 'Paused',
      AppTaskStatus.completed => 'Completed',
      AppTaskStatus.failed => 'Failed',
      AppTaskStatus.cancelled => 'Cancelled',
      AppTaskStatus.expired => 'Expired',
    };
    return otherCount > 0 ? '$label · +$otherCount more' : label;
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

    return SheetScaffold(
      titleText: 'Tasks',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  '${sortedTasks.length} total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: hasFinished ? notifier.clearCompleted : null,
                  icon: const Icon(Symbols.done_all, size: 18),
                  label: const Text('Clear done'),
                ),
                const Gap(8),
                TextButton.icon(
                  onPressed: sortedTasks.isEmpty ? null : notifier.clearAll,
                  icon: const Icon(Symbols.delete_sweep, size: 18),
                  label: const Text('Clear all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedTasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks right now',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedTasks.length,
                    itemBuilder: (context, index) {
                      final task = sortedTasks[index];
                      return AppTaskTile(
                        key: ValueKey(task.id),
                        task: task,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Task tile ---

class AppTaskTile extends StatefulWidget {
  final AppTask task;

  const AppTaskTile({super.key, required this.task});

  @override
  State<AppTaskTile> createState() => _AppTaskTileState();
}

class _AppTaskTileState extends State<AppTaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = _taskIndicatorProgress(task);

    return ExpansionTile(
      leading: Icon(
        _taskStatusIcon(task),
        size: 24,
        color: _taskStatusColor(colorScheme, task),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title.isEmpty ? 'untitled'.tr() : task.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _taskTypeLabel(task.type),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const Gap(4),
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi,
                child: child,
              );
            },
            child: Icon(
              Symbols.expand_more,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      onExpansionChanged: (expanded) {
        if (expanded) {
          _rotationController.forward();
        } else {
          _rotationController.reverse();
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: _TaskDetailsCard(task: task),
        ),
      ],
    );
  }
}

class _TaskDetailsCard extends StatelessWidget {
  final AppTask task;

  const _TaskDetailsCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
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
    final colorScheme = theme.colorScheme;
    final meta = task.metadata;
    final transmissionProgress =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final uploadedChunks = meta?['uploadedChunks'] as int? ?? 0;
    final totalChunks = meta?['totalChunks'] as int? ?? 1;
    final fileSize = meta?['fileSize'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(
          label: task.statusMessage ?? 'Processing',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 2),
        _ProgressRow(
          left: '${(task.progress * 100).toStringAsFixed(1)}%',
          right: '$uploadedChunks/$totalChunks chunks',
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _taskIndicatorProgress(task),
          backgroundColor: colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        const SizedBox(height: 8),
        _DetailSectionHeader(
          label: 'File Transmission',
          color: colorScheme.secondary,
        ),
        const SizedBox(height: 2),
        _ProgressRow(
          left: '${(transmissionProgress * 100).toStringAsFixed(1)}%',
          right:
              '${formatFileSize((transmissionProgress * fileSize).toInt())} / ${formatFileSize(fileSize)}',
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: transmissionProgress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
        ),
        const SizedBox(height: 4),
        Text(
          _formatBytesPerSecond(task),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (task.errorMessage != null) ...[
          const SizedBox(height: 4),
          _ErrorText(message: task.errorMessage!),
        ],
      ],
    );
  }

  String _formatBytesPerSecond(AppTask task) {
    final meta = task.metadata;
    final transmissionProgress =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final fileSize = meta?['fileSize'] as int? ?? 0;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final meta = task.metadata;
    final totalBytes = meta?['totalBytes'] as int? ?? 0;
    final downloadedBytes = meta?['downloadedBytes'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(
          label: task.statusMessage ?? 'Downloading',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 2),
        _ProgressRow(
          left: '${(task.progress * 100).toStringAsFixed(1)}%',
          right:
              '${formatFileSize(downloadedBytes)} / ${formatFileSize(totalBytes)}',
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: task.progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        if (task.errorMessage != null) ...[
          const SizedBox(height: 4),
          _ErrorText(message: task.errorMessage!),
        ],
      ],
    );
  }
}

class _PostPublishDetails extends StatelessWidget {
  final AppTask task;

  const _PostPublishDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(
          label: task.statusMessage ?? 'taskPostPublishPublishing'.tr(),
          color: colorScheme.primary,
        ),
        const SizedBox(height: 2),
        _ProgressRow(
          left: '${(task.progress * 100).toStringAsFixed(0)}%',
          right: _taskStatusLabel(task.status),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: task.progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        if (task.errorMessage != null) ...[
          const SizedBox(height: 4),
          _ErrorText(message: task.errorMessage!),
        ],
      ],
    );
  }
}

class _GenericTaskDetails extends StatelessWidget {
  final AppTask task;

  const _GenericTaskDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(
          label: 'taskProgress'.tr(),
          color: colorScheme.primary,
        ),
        const SizedBox(height: 2),
        _ProgressRow(
          left: '${(task.progress * 100).toStringAsFixed(1)}%',
          right: _taskStatusLabel(task.status),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: task.progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        if (task.errorMessage != null) ...[
          const SizedBox(height: 4),
          _ErrorText(message: task.errorMessage!),
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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: style?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(right, style: style),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
