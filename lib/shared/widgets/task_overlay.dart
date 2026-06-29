import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/services/drive_task_ws_handler.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'task_overlay_state.dart';

class TaskOverlay extends HookConsumerWidget {
  const TaskOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(driveTaskWsHandlerProvider);

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
          allTasks: allTasks,
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
  final List<AppTask> allTasks;
  final double height;
  final bool isDesktop;

  const _TaskOverlayBar({
    required this.snapshot,
    required this.allTasks,
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
    final horizontalPadding = _overlayPadding(context);
    final fillColor = _statusFillColor(colorScheme, primaryTask);
    final trackColor = colorScheme.surfaceContainerHighest;
    final contentColor = colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          left: isDesktop ? 0 : horizontalPadding.left,
          right: isDesktop ? 0 : horizontalPadding.right,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showTaskSheet(context, ref),
          child: SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDesktop ? 0 : 18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: trackColor,
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fillWidth =
                          constraints.maxWidth * snapshot.progress.clamp(0, 1);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width: fillWidth,
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(isDesktop ? 0 : 18),
                              right: Radius.circular(
                                fillWidth >= constraints.maxWidth - 0.5
                                    ? (isDesktop ? 0 : 18)
                                    : 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: isDesktop ? 22 : 36,
                          height: isDesktop ? 22 : 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 7 : 12,
                            ),
                          ),
                          child: Icon(
                            _statusIcon(primaryTask),
                            color: contentColor,
                            size: isDesktop ? 14 : 20,
                          ),
                        ),
                        Gap(isDesktop ? 8 : 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$title · $subtitle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: contentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: isDesktop ? 13 : null,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(isDesktop ? 8 : 12),
                        Text(
                          '${(snapshot.progress * 100).round()}%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: contentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: isDesktop ? 12 : null,
                          ),
                        ),
                        Gap(isDesktop ? 6 : 8),
                        Icon(
                          Symbols.expand_less,
                          color: contentColor.withOpacity(0.9),
                          size: isDesktop ? 14 : 18,
                        ),
                      ],
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

  EdgeInsets _overlayPadding(BuildContext context) {
    if (isDesktop) return EdgeInsets.zero;
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      left: 10 + mediaQuery.padding.left,
      right: 10 + mediaQuery.padding.right,
    );
  }

  IconData _statusIcon(AppTask? task) {
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

  Color _statusFillColor(ColorScheme colorScheme, AppTask? task) {
    if (task == null) return colorScheme.primary;
    return switch (task.status) {
      AppTaskStatus.completed => Colors.green,
      AppTaskStatus.failed ||
      AppTaskStatus.cancelled ||
      AppTaskStatus.expired => Colors.red,
      _ => colorScheme.primary,
    };
  }

  void _showTaskSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tasksProvider.notifier);
    final sortedTasks = [...allTasks]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final navigator = Navigator.of(context, rootNavigator: true);

    showModalBottomSheet<void>(
      context: navigator.context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (sheetContext) {
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
                      style: Theme.of(sheetContext).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: notifier.clearCompleted,
                      icon: const Icon(Symbols.done_all, size: 18),
                      label: const Text('Clear done'),
                    ),
                    const Gap(8),
                    TextButton.icon(
                      onPressed: notifier.clearAll,
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
                          style: Theme.of(sheetContext).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedTasks.length,
                        itemBuilder: (context, index) {
                          return AppTaskTile(task: sortedTasks[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

double taskOverlayHeight(bool isDesktop) => isDesktop ? 32 : 56;

class AppTaskTile extends StatefulWidget {
  final AppTask task;

  const AppTaskTile({super.key, required this.task});

  @override
  State<AppTaskTile> createState() => _AppTaskTileState();

  static double? _getTaskProgress(AppTask task) {
    if (task.status == AppTaskStatus.completed || task.progress >= 1.0) {
      return 1.0;
    }
    if (task.status == AppTaskStatus.inProgress) return null;
    return task.progress;
  }
}

class _AppTaskTileState extends State<AppTaskTile>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

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
    return ExpansionTile(
      leading: _buildStatusIcon(context),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.title.isEmpty ? 'untitled'.tr() : widget.task.title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _getTaskTypeLabel(widget.task.type),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                value: AppTaskTile._getTaskProgress(widget.task),
                strokeWidth: 2.5,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const Gap(4),
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi,
                child: Icon(
                  Symbols.expand_more,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
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
          child: _buildExpandedDetails(context),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (widget.task.status) {
      case AppTaskStatus.pending:
        icon = Symbols.schedule;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case AppTaskStatus.inProgress:
        icon = widget.task.type == AppTaskType.driveDownload
            ? Symbols.download
            : Symbols.upload;
        color = Theme.of(context).colorScheme.primary;
        break;
      case AppTaskStatus.paused:
        icon = Symbols.pause_circle;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case AppTaskStatus.completed:
        icon = Symbols.check_circle;
        color = Colors.green;
        break;
      case AppTaskStatus.failed:
        icon = Symbols.error;
        color = Theme.of(context).colorScheme.error;
        break;
      case AppTaskStatus.cancelled:
        icon = Symbols.cancel;
        color = Theme.of(context).colorScheme.error;
        break;
      case AppTaskStatus.expired:
        icon = Symbols.timer_off;
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Icon(icon, size: 24, color: color);
  }

  Widget _buildExpandedDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: switch (widget.task.type) {
        AppTaskType.driveUpload => _buildDriveUploadDetails(context),
        AppTaskType.driveDownload => _buildDriveDownloadDetails(context),
        AppTaskType.postPublish => _buildPostPublishDetails(context),
        _ => _buildGenericTaskDetails(context),
      },
    );
  }

  Widget _buildDriveUploadDetails(BuildContext context) {
    final meta = widget.task.metadata;
    final transmissionProgress =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final uploadedChunks = meta?['uploadedChunks'] as int? ?? 0;
    final totalChunks = meta?['totalChunks'] as int? ?? 1;
    final fileSize = meta?['fileSize'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.statusMessage ?? 'Processing',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.task.progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$uploadedChunks/$totalChunks chunks',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: AppTaskTile._getTaskProgress(widget.task),
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'File Transmission',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(transmissionProgress * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${_formatFileSize((transmissionProgress * fileSize).toInt())} / ${_formatFileSize(fileSize)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: transmissionProgress,
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatBytesPerSecond(widget.task),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (widget.task.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDriveDownloadDetails(BuildContext context) {
    final meta = widget.task.metadata;
    final totalBytes = meta?['totalBytes'] as int? ?? 0;
    final downloadedBytes = meta?['downloadedBytes'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.statusMessage ?? 'Downloading',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.task.progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${_formatFileSize(downloadedBytes)} / ${_formatFileSize(totalBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: widget.task.progress,
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        if (widget.task.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostPublishDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.statusMessage ?? 'taskPostPublishPublishing'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.task.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              _taskStatusLabel(widget.task.status),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: widget.task.progress,
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        if (widget.task.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenericTaskDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'taskProgress'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.task.progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              _taskStatusLabel(widget.task.status),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: widget.task.progress,
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        if (widget.task.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  String _getTaskTypeLabel(String type) {
    return switch (type) {
      AppTaskType.driveUpload => 'taskTypeDriveUpload'.tr(),
      AppTaskType.driveDownload => 'taskTypeDriveDownload'.tr(),
      AppTaskType.postPublish => 'taskTypePostPublish'.tr(),
      _ => type,
    };
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

  String _formatFileSize(num bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  String _formatBytesPerSecond(AppTask task) {
    final meta = task.metadata;
    final uploadedBytes =
        (meta?['transmissionProgress'] as num?)?.toDouble() ?? 0.0;
    final fileSize = meta?['fileSize'] as int? ?? 0;
    final bytes = (uploadedBytes * fileSize).toInt();
    if (bytes == 0) return '0 B/s';

    final elapsedSeconds = DateTime.now().difference(task.createdAt).inSeconds;
    if (elapsedSeconds == 0) return '0 B/s';

    final bytesPerSecond = bytes / elapsedSeconds;
    return '${_formatFileSize(bytesPerSecond.toInt())}/s';
  }
}
