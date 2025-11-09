import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/upload_task.dart';
import 'package:island/pods/upload_tasks.dart';
import 'package:island/services/responsive.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:easy_localization/easy_localization.dart';

class UploadOverlay extends HookConsumerWidget {
  const UploadOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadTasks = ref.watch(uploadTasksProvider);
    final activeTasks =
        uploadTasks
            .where(
              (task) =>
                  task.status == UploadTaskStatus.pending ||
                  task.status == UploadTaskStatus.inProgress ||
                  task.status == UploadTaskStatus.paused ||
                  task.status == UploadTaskStatus.completed,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first

    final isVisible = activeTasks.isNotEmpty;
    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from below the screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    // Animate when visibility changes
    useEffect(() {
      if (isVisible) {
        slideController.forward();
      } else {
        slideController.reverse();
      }
      return null;
    }, [isVisible]);

    if (!isVisible && slideController.status == AnimationStatus.dismissed) {
      // If not visible and animation is complete (back to start), don't show anything
      return const SizedBox.shrink();
    }

    final isDesktop = isWideScreen(context);

    return Positioned(
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      left: isDesktop ? null : 0,
      right: isDesktop ? 24 : 0,
      child: SlideTransition(
        position: slideAnimation,
        child: _UploadOverlayContent(activeTasks: activeTasks),
      ),
    );
  }
}

class _UploadOverlayContent extends HookConsumerWidget {
  final List<UploadTask> activeTasks;

  const _UploadOverlayContent({required this.activeTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: 0.0,
    );
    final heightAnimation = useAnimation(
      Tween<double>(begin: 60, end: 400).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
    );
    final opacityAnimation = useAnimation(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    useEffect(() {
      if (isExpanded.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isExpanded.value]);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Positioned(
      bottom: isMobile ? 16 : 24,
      left: isMobile ? 16 : null,
      right: isMobile ? 16 : 24,
      child: GestureDetector(
        onTap: () => isExpanded.value = !isExpanded.value,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Material(
              elevation: 8 + (opacityAnimation * 4),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isMobile ? MediaQuery.of(context).size.width - 32 : 320,
                height: heightAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Collapsed Header
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Upload icon with animation
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                key: ValueKey(isExpanded.value),
                                isExpanded.value
                                    ? Symbols.list_rounded
                                    : _getOverallStatusIcon(activeTasks),
                                size: 24,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title and count
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isExpanded.value
                                        ? 'uploadTasks'.tr()
                                        : _getOverallStatusText(activeTasks),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!isExpanded.value &&
                                      activeTasks.isNotEmpty)
                                    Text(
                                      _getOverallProgressText(activeTasks),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Progress indicator (collapsed)
                            if (!isExpanded.value)
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: _getOverallProgress(activeTasks),
                                  strokeWidth: 3,
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                ),
                              ),

                            // Expand/collapse button
                            IconButton(
                              icon: AnimatedRotation(
                                turns: opacityAnimation * 0.5,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isExpanded.value
                                      ? Symbols.expand_more
                                      : Symbols.chevron_right,
                                  size: 20,
                                ),
                              ),
                              onPressed:
                                  () => isExpanded.value = !isExpanded.value,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Expanded content
                      if (isExpanded.value)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width:
                                      1 /
                                      MediaQuery.of(context).devicePixelRatio,
                                ),
                              ),
                            ),
                            child: CustomScrollView(
                              slivers: [
                                // Clear completed tasks button
                                if (_hasCompletedTasks(activeTasks))
                                  SliverToBoxAdapter(
                                    child: ListTile(
                                      dense: true,
                                      title: const Text('Clear Completed'),
                                      leading: Icon(
                                        Symbols.clear_all,
                                        size: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                      onTap: () {
                                        ref
                                            .read(uploadTasksProvider.notifier)
                                            .clearCompletedTasks();
                                      },
                                      tileColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    ),
                                  ),

                                // Task list
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
                                      child: UploadTaskTile(task: task),
                                    );
                                  }, childCount: activeTasks.length),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _getOverallProgress(List<UploadTask> tasks) {
    if (tasks.isEmpty) return 0.0;
    final totalProgress = tasks.fold<double>(
      0.0,
      (sum, task) =>
          sum +
          (task.status == UploadTaskStatus.inProgress
              ? task.progress
              : task.status == UploadTaskStatus.completed
              ? 1
              : 0),
    );
    return totalProgress / tasks.length;
  }

  String _getOverallProgressText(List<UploadTask> tasks) {
    final overallProgress = _getOverallProgress(tasks);
    return '${(overallProgress * 100).toStringAsFixed(0)}%';
  }

  IconData _getOverallStatusIcon(List<UploadTask> tasks) {
    if (tasks.isEmpty) return Symbols.upload;

    final hasInProgress = tasks.any(
      (task) => task.status == UploadTaskStatus.inProgress,
    );
    final hasPending = tasks.any(
      (task) => task.status == UploadTaskStatus.pending,
    );
    final hasPaused = tasks.any(
      (task) => task.status == UploadTaskStatus.paused,
    );
    final hasFailed = tasks.any(
      (task) =>
          task.status == UploadTaskStatus.failed ||
          task.status == UploadTaskStatus.cancelled ||
          task.status == UploadTaskStatus.expired,
    );
    final hasCompleted = tasks.any(
      (task) => task.status == UploadTaskStatus.completed,
    );

    // Priority order: in progress > pending > paused > failed > completed
    if (hasInProgress) {
      return Symbols.upload;
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

  String _getOverallStatusText(List<UploadTask> tasks) {
    if (tasks.isEmpty) return '0 tasks';

    final hasInProgress = tasks.any(
      (task) => task.status == UploadTaskStatus.inProgress,
    );
    final hasPending = tasks.any(
      (task) => task.status == UploadTaskStatus.pending,
    );
    final hasPaused = tasks.any(
      (task) => task.status == UploadTaskStatus.paused,
    );
    final hasFailed = tasks.any(
      (task) =>
          task.status == UploadTaskStatus.failed ||
          task.status == UploadTaskStatus.cancelled ||
          task.status == UploadTaskStatus.expired,
    );
    final hasCompleted = tasks.any(
      (task) => task.status == UploadTaskStatus.completed,
    );

    // Priority order: in progress > pending > paused > failed > completed
    if (hasInProgress) {
      return '${tasks.length} ${'uploading'.tr()}';
    } else if (hasPending) {
      return '${tasks.length} ${'pending'.tr()}';
    } else if (hasPaused) {
      return '${tasks.length} ${'paused'.tr()}';
    } else if (hasFailed) {
      return '${tasks.length} ${'failed'.tr()}';
    } else if (hasCompleted) {
      return '${tasks.length} ${'completed'.tr()}';
    } else {
      return '${tasks.length} ${'tasks'.tr()}';
    }
  }

  bool _hasCompletedTasks(List<UploadTask> tasks) {
    return tasks.any(
      (task) =>
          task.status == UploadTaskStatus.completed ||
          task.status == UploadTaskStatus.failed ||
          task.status == UploadTaskStatus.cancelled ||
          task.status == UploadTaskStatus.expired,
    );
  }
}

class UploadTaskTile extends StatefulWidget {
  final UploadTask task;

  const UploadTaskTile({super.key, required this.task});

  @override
  State<UploadTaskTile> createState() => _UploadTaskTileState();
}

class _UploadTaskTileState extends State<UploadTaskTile>
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
            widget.task.fileName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _formatFileSize(widget.task.fileSize),
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
                value: widget.task.progress,
                strokeWidth: 2.5,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
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
      case UploadTaskStatus.pending:
        icon = Symbols.schedule;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case UploadTaskStatus.inProgress:
        icon = Symbols.upload;
        color = Theme.of(context).colorScheme.primary;
        break;
      case UploadTaskStatus.paused:
        icon = Symbols.pause_circle;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case UploadTaskStatus.completed:
        icon = Symbols.check_circle;
        color = Colors.green;
        break;
      case UploadTaskStatus.failed:
        icon = Symbols.error;
        color = Theme.of(context).colorScheme.error;
        break;
      case UploadTaskStatus.cancelled:
        icon = Symbols.cancel;
        color = Theme.of(context).colorScheme.error;
        break;
      case UploadTaskStatus.expired:
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
        'FileUpload' => _buildFileUploadDetails(context),
        _ => _buildGenericTaskDetails(context),
      },
    );
  }

  Widget _buildFileUploadDetails(BuildContext context) {
    final transmissionProgress = widget.task.transmissionProgress ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Server Processing Progress
        Text(
          'Server Processing',
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
              '${widget.task.uploadedChunks}/${widget.task.totalChunks} chunks',
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

        const SizedBox(height: 8),

        // File Transmission Progress
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
              '${_formatFileSize((transmissionProgress * widget.task.fileSize).toInt())} / ${_formatFileSize(widget.task.fileSize)}',
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

        // Speed and ETA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatBytesPerSecond(widget.task),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.task.status == UploadTaskStatus.inProgress)
              Text(
                'ETA: ${_formatDuration(widget.task.estimatedTimeRemaining)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),

        // Error message if failed
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
        // Generic task progress
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

        // Error message if failed
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

  String _formatFileSize(int bytes) {
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

  String _formatBytesPerSecond(UploadTask task) {
    if (task.uploadedBytes == 0) return '0 B/s';

    final elapsedSeconds = DateTime.now().difference(task.createdAt).inSeconds;
    if (elapsedSeconds == 0) return '0 B/s';

    final bytesPerSecond = task.uploadedBytes / elapsedSeconds;
    return '${_formatFileSize(bytesPerSecond.toInt())}/s';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
