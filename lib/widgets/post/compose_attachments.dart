import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/attachment_uploader.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/post/compose_shared.dart';

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
      onRequestUpload: () async {
        final config = await showModalBottomSheet<AttachmentUploadConfig>(
          context: ref.context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder:
              (context) =>
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

/// A specialized attachment widget for article compose with expansion tile.
class ArticleComposeAttachments extends ConsumerWidget {
  final ComposeState state;

  const ArticleComposeAttachments({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<UniversalFile>>(
      valueListenable: state.attachments,
      builder: (context, attachments, _) {
        if (attachments.isEmpty) return const SizedBox.shrink();
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('attachments'),
                Text(
                  'articleAttachmentHint',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            children: [
              ValueListenableBuilder<Map<int, double?>>(
                valueListenable: state.attachmentProgress,
                builder: (context, progressMap, _) {
                  return Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (var idx = 0; idx < attachments.length; idx++)
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: AttachmentPreview(
                            isCompact: true,
                            item: attachments[idx],
                            progress: progressMap[idx],
                            onRequestUpload: () async {
                              final config = await showModalBottomSheet<
                                AttachmentUploadConfig
                              >(
                                context: context,
                                isScrollControlled: true,
                                builder:
                                    (context) => AttachmentUploaderSheet(
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
                            onUpdate:
                                (value) => ComposeLogic.updateAttachment(
                                  state,
                                  value,
                                  idx,
                                ),
                            onDelete:
                                () => ComposeLogic.deleteAttachment(
                                  ref,
                                  state,
                                  idx,
                                ),
                            onInsert:
                                () => ComposeLogic.insertAttachment(
                                  ref,
                                  state,
                                  idx,
                                ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
