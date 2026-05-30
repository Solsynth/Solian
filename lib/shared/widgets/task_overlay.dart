import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/tasks/app_task.dart';
import 'package:island/core/tasks/tasks_notifier.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/services/drive_task_ws_handler.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_widget/styled_widget.dart';

class TaskOverlay extends HookConsumerWidget {
  const TaskOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(tasksProvider);
    // Ensure drive WebSocket task handler is initialized
    ref.watch(driveTaskWsHandlerProvider);
    final activeTasks =
        allTasks
            .where((task) => task.isActive || task.status == AppTaskStatus.completed)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final isVisibleOverride = useState<bool?>(null);
    final pendingHide = useState(false);
    final isExpandedLocal = useState(false);
    final isCompactLocal = useState(true);
    final autoHideTimer = useState<Timer?>(null);
    final autoCompactTimer = useState<Timer?>(null);

    final allFinished = activeTasks.every((task) => task.isFinished);

    useEffect(() {
      final hasUnfinishedTasks = activeTasks.any((task) => task.isActive);
      if (hasUnfinishedTasks && pendingHide.value) {
        pendingHide.value = false;
      }

      autoHideTimer.value?.cancel();
      if (allFinished &&
          activeTasks.isNotEmpty &&
          !isExpandedLocal.value &&
          !pendingHide.value) {
        autoHideTimer.value = Timer(const Duration(seconds: 3), () {
          pendingHide.value = true;
        });
      } else {
        autoHideTimer.value?.cancel();
        autoHideTimer.value = null;
      }
      return null;
    }, [allFinished, activeTasks, isExpandedLocal.value, pendingHide.value]);

    final isDesktop = isWideScreen(context);

    useEffect(() {
      if (!isDesktop && !isCompactLocal.value && !isExpandedLocal.value) {
        autoCompactTimer.value?.cancel();
        autoCompactTimer.value = Timer(const Duration(seconds: 5), () {
          isCompactLocal.value = true;
        });
      } else {
        autoCompactTimer.value?.cancel();
        autoCompactTimer.value = null;
      }
      return null;
    }, [isCompactLocal.value, isExpandedLocal.value, isDesktop]);
    final isVisible =
        (isVisibleOverride.value ?? activeTasks.isNotEmpty) &&
        !pendingHide.value;
    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final isTopPositioned = !isDesktop;

    final slideAnimation = Tween<Offset>(
      begin: isTopPositioned ? const Offset(0, -1) : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    useEffect(() {
      if (isVisible) {
        slideController.forward();
      } else {
        slideController.reverse();
      }
      return null;
    }, [isVisible]);

    if (!isVisible && slideController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: isTopPositioned ? 0 : null,
      bottom: !isTopPositioned ? 0 : null,
      left: isDesktop ? null : 0,
      right: isDesktop ? 24 : 0,
      child: SlideTransition(
        position: slideAnimation,
        child:
            _TaskOverlayContent(
              activeTasks: activeTasks,
              isExpanded: isExpandedLocal.value,
              isCompact: isCompactLocal.value,
              onExpansionChanged: (expanded) =>
                  isExpandedLocal.value = expanded,
              onCompactChanged: (compact) => isCompactLocal.value = compact,
            ).padding(
              top: isTopPositioned
                  ? MediaQuery.of(context).padding.top + 16
                  : 0,
              bottom: !isTopPositioned
                  ? 16 + MediaQuery.of(context).padding.bottom
                  : 0,
            ),
      ),
    );
  }
}

class _TaskOverlayContent extends HookConsumerWidget {
  final List<AppTask> activeTasks;
  final bool isExpanded;
  final bool isCompact;
  final Function(bool)? onExpansionChanged;
  final Function(bool)? onCompactChanged;

  const _TaskOverlayContent({
    required this.activeTasks,
    required this.isExpanded,
    required this.isCompact,
    this.onExpansionChanged,
    this.onCompactChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: 0.0,
    );
    final compactHeight = 32.0;
    final collapsedHeight = 60.0;
    final expandedHeight = 400.0;

    final currentHeight = isCompact
        ? compactHeight
        : isExpanded
        ? expandedHeight
        : collapsedHeight;

    final opacityAnimation = useAnimation(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    useEffect(() {
      if (isExpanded) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isExpanded]);

    final isMobile = !isWideScreen(context);

    final tasks = ref.read(tasksProvider.notifier);

    void handleInteraction() {
      if (isCompact) {
        onCompactChanged?.call(false);
      } else if (!isExpanded) {
        onExpansionChanged?.call(true);
      } else {
        onExpansionChanged?.call(false);
      }
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(isCompact ? 64 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: isCompact
          ? _getCompactWidth(activeTasks)
          : (isMobile ? MediaQuery.of(context).size.width - 32 : 320),
      height: currentHeight,
      child: GestureDetector(
        onTap: isMobile ? handleInteraction : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCompact ? 64 : 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isCompact
                ? Container(
                    key: const ValueKey('compact'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          _getOverallStatusIcon(activeTasks),
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            activeTasks.isEmpty
                                ? '0 tasks'
                                : _getOverallStatusText(activeTasks),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _getOverallProgress(activeTasks),
                                strokeWidth: 3,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                padding: EdgeInsets.zero,
                              ),
                              if (activeTasks.any(
                                (task) =>
                                    task.status == AppTaskStatus.inProgress &&
                                    task.progress < 1.0,
                              ))
                                CircularProgressIndicator(
                                  value: null,
                                  strokeWidth: 3,
                                  trackGap: 0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.5),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ).padding(horizontal: 12),
                  )
                : Container(
                    key: const ValueKey('expanded'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  key: ValueKey(isExpanded),
                                  isExpanded
                                      ? Symbols.list_rounded
                                      : _getOverallStatusIcon(activeTasks),
                                  size: 24,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExpanded
                                          ? 'tasks'.tr()
                                          : _getOverallStatusText(activeTasks),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (!isExpanded && activeTasks.isNotEmpty)
                                      Text(
                                        _getOverallProgressText(activeTasks),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!isExpanded)
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Stack(
                                    children: [
                                      CircularProgressIndicator(
                                        value: _getOverallProgress(activeTasks),
                                        strokeWidth: 3,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                      ),
                                      if (activeTasks.any(
                                        (task) =>
                                            task.status ==
                                                AppTaskStatus.inProgress &&
                                            task.progress < 1.0,
                                      ))
                                        CircularProgressIndicator(
                                          value: null,
                                          strokeWidth: 3,
                                          trackGap: 0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.5),
                                              ),
                                          backgroundColor: Colors.transparent,
                                        ),
                                    ],
                                  ),
                                ),
                              IconButton(
                                icon: AnimatedRotation(
                                  turns: opacityAnimation * 0.5,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isExpanded
                                        ? Symbols.expand_more
                                        : Symbols.chevron_right,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () =>
                                    onExpansionChanged?.call(!isExpanded),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    width:
                                        1 /
                                        MediaQuery.of(context).devicePixelRatio,
                                  ),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.only(
                                          left: 18,
                                          right: 16,
                                        ),
                                        title: const Text(
                                          'clearCompleted',
                                        ).tr(),
                                        leading: Icon(
                                          Symbols.clear_all,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        onTap: () {
                                          tasks.clearCompleted();
                                          onExpansionChanged?.call(false);
                                        },
                                        trailing: IconButton(
                                          tooltip: 'clearAll'.tr(),
                                          icon: Icon(
                                            Symbols.close,
                                            size: 18,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            tasks.clearAll();
                                            onExpansionChanged?.call(false);
                                          },
                                        ),
                                        tileColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final task = activeTasks[index];
                                        return AnimatedOpacity(
                                          opacity: opacityAnimation,
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          child: AppTaskTile(task: task),
                                        );
                                      }, childCount: activeTasks.length),
                                    ),
                                  ],
                                ),
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

    if (!isMobile) {
      content = MouseRegion(
        onEnter: (_) => onCompactChanged?.call(false),
        onExit: (_) => onCompactChanged?.call(true),
        child: content,
      );
    }

    if (isCompact) {
      content = Center(child: content);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile ? 16 : 24,
        left: isMobile ? 16 : 0,
        right: isMobile ? 16 : 24,
      ),
      child: content,
    );
  }

  double? _getTaskProgress(AppTask task) {
    if (task.status == AppTaskStatus.completed || task.progress >= 1.0) {
      return 1.0;
    }
    if (task.status != AppTaskStatus.inProgress) return 0.0;
    return task.progress;
  }

  double _getOverallProgress(List<AppTask> tasks) {
    if (tasks.isEmpty) return 0.0;
    final progressValues = tasks.map((task) => _getTaskProgress(task));
    final determinateProgresses = progressValues.where((p) => p != null);
    if (determinateProgresses.isEmpty) return 0.0;
    final totalProgress = determinateProgresses.fold<double>(
      0.0,
      (sum, progress) => sum + progress!,
    );
    return totalProgress / tasks.length;
  }

  String _getOverallProgressText(List<AppTask> tasks) {
    final overallProgress = _getOverallProgress(tasks);
    return '${(overallProgress * 100).toStringAsFixed(0)}%';
  }

  IconData _getOverallStatusIcon(List<AppTask> tasks) {
    if (tasks.isEmpty) return Symbols.upload;

    final hasDownload = tasks.any(
      (task) => task.type == AppTaskType.driveDownload,
    );
    final hasInProgress = tasks.any(
      (task) => task.status == AppTaskStatus.inProgress,
    );
    final hasPending = tasks.any(
      (task) => task.status == AppTaskStatus.pending,
    );
    final hasPaused = tasks.any(
      (task) => task.status == AppTaskStatus.paused,
    );
    final hasFailed = tasks.any((task) => task.isFinished && task.status != AppTaskStatus.completed);
    final hasCompleted = tasks.any(
      (task) => task.status == AppTaskStatus.completed,
    );

    if (hasInProgress) {
      return hasDownload ? Symbols.download : Symbols.upload;
    } else if (hasPending) {
      return Symbols.schedule;
    } else if (hasPaused) {
      return Symbols.pause_circle;
    } else if (hasFailed) {
      return Symbols.error;
    } else if (hasCompleted) {
      return Symbols.check_circle;
    } else {
      return Symbols.upload;
    }
  }

  String _getOverallStatusText(List<AppTask> tasks) {
    if (tasks.isEmpty) return 'tasks'.plural(0);

    final hasDownload = tasks.any(
      (task) => task.type == AppTaskType.driveDownload,
    );
    final hasInProgress = tasks.any(
      (task) => task.status == AppTaskStatus.inProgress,
    );
    final hasPending = tasks.any(
      (task) => task.status == AppTaskStatus.pending,
    );
    final hasPaused = tasks.any(
      (task) => task.status == AppTaskStatus.paused,
    );
    final hasFailed = tasks.any((task) => task.isFinished && task.status != AppTaskStatus.completed);
    final hasCompleted = tasks.any(
      (task) => task.status == AppTaskStatus.completed,
    );

    if (hasInProgress) {
      if (hasDownload) {
        return '${tasks.length} ${'downloading'.tr()}';
      } else {
        return '${tasks.length} ${'uploading'.tr()}';
      }
    } else if (hasPending) {
      return '${tasks.length} ${'pending'.tr()}';
    } else if (hasPaused) {
      return '${tasks.length} ${'paused'.tr()}';
    } else if (hasFailed) {
      return '${tasks.length} ${'failed'.tr()}';
    } else if (hasCompleted) {
      return '${tasks.length} ${'completed'.tr()}';
    } else {
      return 'tasks'.plural(tasks.length);
    }
  }

  double _getCompactWidth(List<AppTask> tasks) {
    double width = 16 + 12 + 12;
    final text = activeTasks.isEmpty ? '0 tasks' : _getOverallStatusText(tasks);
    width += text.length * 8.0;
    return width.clamp(200, 280);
  }
}

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
          widget.task.statusMessage ?? 'Publishing',
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
              widget.task.status.name,
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
          'Progress',
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
              widget.task.status.name,
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
      AppTaskType.driveUpload => 'File Upload',
      AppTaskType.driveDownload => 'File Download',
      AppTaskType.postPublish => 'Post Publishing',
      _ => type,
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
