import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/upload_task.dart';
import 'package:island/pods/upload_tasks.dart';
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
            .toList();
    // if (activeTasks.isEmpty) {
    //   return const SizedBox.shrink();
    // }

    return _UploadOverlayContent(activeTasks: activeTasks);
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
                                    ? Symbols.expand_more
                                    : Symbols.upload,
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
                                        : '${activeTasks.length} ${'uploading'.tr()}',
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
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Clear completed tasks button
                                if (_hasCompletedTasks(activeTasks))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            ref
                                                .read(
                                                  uploadTasksProvider.notifier,
                                                )
                                                .clearCompletedTasks();
                                          },
                                          icon: Icon(
                                            Symbols.clear_all,
                                            size: 18,
                                          ),
                                          label: const Text('Clear Completed'),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Task list
                                Expanded(
                                  child: AnimatedOpacity(
                                    opacity: opacityAnimation,
                                    duration: const Duration(milliseconds: 150),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: activeTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = activeTasks[index];
                                        return UploadTaskTile(task: task);
                                      },
                                    ),
                                  ),
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
      (sum, task) => sum + task.progress,
    );
    return totalProgress / tasks.length;
  }

  String _getOverallProgressText(List<UploadTask> tasks) {
    final overallProgress = _getOverallProgress(tasks);
    return '${(overallProgress * 100).toStringAsFixed(0)}%';
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

class UploadTaskTile extends HookConsumerWidget {
  final UploadTask task;

  const UploadTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);

    return InkWell(
      onTap: () => isExpanded.value = !isExpanded.value,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon
                _buildStatusIcon(context),
                const SizedBox(width: 8),

                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(task.fileSize),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: task.progress,
                    strokeWidth: 3,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),

                // Expand/collapse button
                IconButton(
                  icon: Icon(
                    isExpanded.value
                        ? Symbols.expand_less
                        : Symbols.expand_more,
                    size: 16,
                  ),
                  onPressed: () => isExpanded.value = !isExpanded.value,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // Expanded details
            if (isExpanded.value) ...[
              const SizedBox(height: 8),
              _buildExpandedDetails(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (task.status) {
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

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildExpandedDetails(BuildContext context) {
    final transmissionProgress = task.transmissionProgress ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
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
                '${(task.progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${task.uploadedChunks}/${task.totalChunks} chunks',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: task.progress,
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
                '${_formatFileSize((transmissionProgress * task.fileSize).toInt())} / ${_formatFileSize(task.fileSize)}',
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
                _formatBytesPerSecond(task),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (task.status == UploadTaskStatus.inProgress)
                Text(
                  'ETA: ${_formatDuration(task.estimatedTimeRemaining)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          // Error message if failed
          if (task.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              task.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
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
