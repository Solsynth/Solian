import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/widgets/attachment_uploader.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable widget for displaying attachments in compose screens.
/// Supports both grid and list layouts based on screen width.
class ComposeAttachments extends ConsumerWidget {
  final ComposeState state;
  final bool isCompact;

  const ComposeAttachments({
    super.key,
    required this.state,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.attachments.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = isWideScreen(context);
        return isWide ? _buildWideGrid(ref) : _buildNarrowList(ref);
      },
    );
  }

  Widget _buildWideGrid(WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.attachments.value.length,
      itemBuilder: (context, idx) {
        return _buildAttachmentItem(ref, idx, isCompact: true);
      },
    );
  }

  Widget _buildNarrowList(WidgetRef ref) {
    return Column(
      children: [
        for (var idx = 0; idx < state.attachments.value.length; idx++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildAttachmentItem(ref, idx, isCompact: false),
          ),
      ],
    );
  }

  Widget _buildAttachmentItem(
    WidgetRef ref,
    int idx, {
    required bool isCompact,
  }) {
    final progressMap = state.attachmentProgress.value;
    return AttachmentPreview(
      isCompact: isCompact,
      item: state.attachments.value[idx],
      progress: progressMap[idx],
      isUploading: progressMap.containsKey(idx),
      onRequestUpload: () async {
        final config = await showModalBottomSheet<AttachmentUploadConfig>(
          context: ref.context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) =>
              AttachmentUploaderSheet(ref: ref, state: state, index: idx),
        );
        if (config != null) {
          await ComposeLogic.uploadAttachment(
            ref,
            state,
            idx,
            poolId: config.poolId,
          );
        }
      },
      onDelete: () => ComposeLogic.deleteAttachment(ref, state, idx),
      onUpdate: (value) => ComposeLogic.updateAttachment(state, value, idx),
      onMove: (delta) {
        state.attachments.value = ComposeLogic.moveAttachment(
          state.attachments.value,
          idx,
          delta,
        );
      },
    );
  }
}

class ArticleComposeAttachments extends HookConsumerWidget {
  final ComposeState state;
  final EdgeInsets? padding;

  const ArticleComposeAttachments({
    super.key,
    required this.state,
    this.padding,
  });

  Future<void> _handleDroppedFiles(DropDoneDetails details, ComposeState state) async {
    final newFiles = <UniversalFile>[];

    for (final xfile in details.files) {
      // Create UniversalFile with default type first
      final uf = UniversalFile(data: xfile, type: UniversalFileType.file);
      // Use FileUploader.getMimeType to get proper MIME type
      final mimeType = FileUploader.getMimeType(uf);
      final fileType = switch (mimeType.split('/').firstOrNull) {
        'image' => UniversalFileType.image,
        'video' => UniversalFileType.video,
        'audio' => UniversalFileType.audio,
        _ => UniversalFileType.file,
      };

      // Update the file type
      final correctedUf = UniversalFile(data: xfile, type: fileType);
      newFiles.add(correctedUf);
    }

    if (newFiles.isNotEmpty) {
      state.attachments.value = [...state.attachments.value, ...newFiles];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: padding ?? EdgeInsets.all(16),
      child: ValueListenableBuilder<String?>(
        valueListenable: state.thumbnailId,
        builder: (context, thumbnailId, _) {
          return ValueListenableBuilder<List<UniversalFile>>(
            valueListenable: state.attachments,
            builder: (context, attachments, _) {
              return HookBuilder(
                builder: (context) {
                  final isDragging = useState(false);
                  return DropTarget(
                    onDragDone: (details) async =>
                        await _handleDroppedFiles(details, state),
                    onDragEntered: (details) => isDragging.value = true,
                    onDragExited: (details) => isDragging.value = false,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: isDragging.value ? BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ) : null,
                      child: Padding(
                        padding: isDragging.value ? const EdgeInsets.all(8) : EdgeInsets.zero,
                        child: attachments.isEmpty
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.3),
                                  border: Border.all(
                                    color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.upload,
                                      size: 48,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'dropFilesHere',
                                      style: Theme.of(context).textTheme.titleMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ).tr(),
                                    const SizedBox(height: 8),
                                    Text(
                                      'dragAndDropToAttach',
                                      style: Theme.of(context).textTheme.bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.7),
                                          ),
                                    ).tr(),
                                  ],
                                ),
                              )
                            : ValueListenableBuilder<Map<int, double?>>(
                                valueListenable: state.attachmentProgress,
                                builder: (context, progressMap, _) {
                                  return Wrap(
                                    runSpacing: 8,
                                    spacing: 8,
                                    children: [
                                      for (var idx = 0; idx < attachments.length; idx++)
                                        _AnimatedAttachmentItem(
                                          index: idx,
                                          item: attachments[idx],
                                          progress: progressMap[idx],
                                          isUploading: progressMap.containsKey(idx),
                                          thumbnailId: thumbnailId,
                                          onSetThumbnail: (id) =>
                                              ComposeLogic.setThumbnail(state, id),
                                          onRequestUpload: () async {
                                            final config =
                                                await showModalBottomSheet<
                                                  AttachmentUploadConfig
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  useRootNavigator: true,
                                                  builder: (context) => AttachmentUploaderSheet(
                                                    ref: ref,
                                                    state: state,
                                                    index: idx,
                                                  ),
                                                );
                                            if (config != null) {
                                              await ComposeLogic.uploadAttachment(
                                                ref,
                                                state,
                                                idx,
                                                poolId: config.poolId,
                                              );
                                            }
                                          },
                                          onUpdate: (value) =>
                                              ComposeLogic.updateAttachment(state, value, idx),
                                          onDelete: () =>
                                              ComposeLogic.deleteAttachment(ref, state, idx),
                                          onInsert: () =>
                                              ComposeLogic.insertAttachment(ref, state, idx),
                                        ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedAttachmentItem extends HookWidget {
  final int index;
  final UniversalFile item;
  final double? progress;
  final bool isUploading;
  final String? thumbnailId;
  final Function(String?) onSetThumbnail;
  final VoidCallback onRequestUpload;
  final Function(UniversalFile) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onInsert;

  const _AnimatedAttachmentItem({
    required this.index,
    required this.item,
    required this.progress,
    required this.isUploading,
    required this.thumbnailId,
    required this.onSetThumbnail,
    required this.onRequestUpload,
    required this.onUpdate,
    required this.onDelete,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    useEffect(() {
      final delay = Duration(milliseconds: 50 * index);
      Future.delayed(delay, () {
        animationController.forward();
      });
      return null;
    }, [index]);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: AttachmentPreview(
          isCompact: true,
          item: item,
          progress: progress,
          isUploading: isUploading,
          thumbnailId: thumbnailId,
          onSetThumbnail: onSetThumbnail,
          onRequestUpload: onRequestUpload,
          onUpdate: onUpdate,
          onDelete: onDelete,
          onInsert: onInsert,
          bordered: true,
        ),
      ),
    );
  }
}