import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';

import 'package:island/screens/creators/publishers.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/attachment_uploader.dart';
import 'package:island/screens/posts/post_detail.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/post/compose_toolbar.dart';
import 'package:island/widgets/post/publishers_modal.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ArticleEditScreen extends HookConsumerWidget {
  final String id;
  const ArticleEditScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => ArticleComposeScreen(originalPost: post),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Text('Error: $e', textAlign: TextAlign.center),
          ),
    );
  }
}

class ArticleComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;

  const ArticleComposeScreen({super.key, this.originalPost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        postType: 1, // Article type
      ),
      [originalPost],
    );

    // Start auto-save when component mounts
    useEffect(() {
      Timer? autoSaveTimer;
      if (originalPost == null) {
        // Only auto-save for new articles, not edits
        autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          ComposeLogic.saveDraftWithoutUpload(ref, state);
        });
      }
      return () {
        // Stop auto-save first to prevent race conditions
        state.stopAutoSave();
        // Save final draft before disposing
        if (originalPost == null) {
          ComposeLogic.saveDraftWithoutUpload(ref, state);
        }
        ComposeLogic.dispose(state);
        autoSaveTimer?.cancel();
      };
    }, [state]);

    final showPreview = useState(false);
    final isAttachmentsExpanded = useState(
      true,
    ); // New state for attachments section

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        state.currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // Load draft if available (only for new articles)
    useEffect(() {
      if (originalPost == null) {
        // Try to load the most recent article draft
        final drafts = ref.read(composeStorageNotifierProvider);
        if (drafts.isNotEmpty) {
          final mostRecentDraft = drafts.values.reduce(
            (a, b) =>
                (a.updatedAt ?? DateTime(0)).isAfter(b.updatedAt ?? DateTime(0))
                    ? a
                    : b,
          );

          // Only load if the draft has meaningful content
          if (mostRecentDraft.content?.isNotEmpty == true ||
              mostRecentDraft.title?.isNotEmpty == true) {
            state.titleController.text = mostRecentDraft.title ?? '';
            state.descriptionController.text =
                mostRecentDraft.description ?? '';
            state.contentController.text = mostRecentDraft.content ?? '';
            state.visibility.value = mostRecentDraft.visibility;
          }
        }
      }
      return null;
    }, []);

    // Helper methods
    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ComposeSettingsSheet(state: state),
      );
    }

    Widget buildPreviewPane() {
      final widgetItem = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: state.titleController,
          builder: (context, titleValue, _) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: state.descriptionController,
              builder: (context, descriptionValue, _) {
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: state.contentController,
                  builder: (context, contentValue, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleValue.text.isNotEmpty) ...[
                          Text(
                            titleValue.text,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(16),
                        ],
                        if (descriptionValue.text.isNotEmpty) ...[
                          Text(
                            descriptionValue.text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const Gap(16),
                        ],
                        if (contentValue.text.isNotEmpty)
                          MarkdownTextContent(
                            content: contentValue.text,
                            textStyle: theme.textTheme.bodyMedium,
                            attachments:
                                state.attachments.value
                                    .where((e) => e.isOnCloud)
                                    .map((e) => e.data)
                                    .cast<SnCloudFile>()
                                    .toList(),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      );

      if (isWideScreen(context)) {
        return Align(alignment: Alignment.topLeft, child: widgetItem);
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Symbols.preview, size: 20),
                  const Gap(8),
                  Text('preview'.tr(), style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            Expanded(child: widgetItem),
          ],
        ),
      );
    }

    Widget buildEditorPane() {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: state.titleController,
                decoration: InputDecoration(
                  hintText: 'postTitle'.tr(),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                style: theme.textTheme.titleMedium,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextField(
                controller: state.descriptionController,
                decoration: InputDecoration(
                  hintText: 'postDescription'.tr(),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                ),
                style: theme.textTheme.bodyMedium,
                minLines: 1,
                maxLines: 3,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent:
                      (event) => ComposeLogic.handleKeyPress(
                        event,
                        state,
                        ref,
                        context,
                        originalPost: originalPost,
                      ),
                  child: TextField(
                    controller: state.contentController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'postContent'.tr(),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
              ),

              // Attachments preview
              ValueListenableBuilder<List<UniversalFile>>(
                valueListenable: state.attachments,
                builder: (context, attachments, _) {
                  if (attachments.isEmpty) return const SizedBox.shrink();
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: isAttachmentsExpanded.value,
                      onExpansionChanged: (expanded) {
                        isAttachmentsExpanded.value = expanded;
                      },
                      collapsedBackgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('attachments').tr(),
                          Text(
                            'articleAttachmentHint'.tr(),
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
                      children: [
                        ValueListenableBuilder<Map<int, double>>(
                          valueListenable: state.attachmentProgress,
                          builder: (context, progressMap, _) {
                            return Wrap(
                              runSpacing: 8,
                              spacing: 8,
                              children: [
                                for (
                                  var idx = 0;
                                  idx < attachments.length;
                                  idx++
                                )
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: AttachmentPreview(
                                      isCompact: true,
                                      item: attachments[idx],
                                      progress: progressMap[idx],
                                      onRequestUpload: () async {
                                        final config =
                                            await showModalBottomSheet<
                                              AttachmentUploadConfig
                                            >(
                                              context: context,
                                              isScrollControlled: true,
                                              builder:
                                                  (context) =>
                                                      AttachmentUploaderSheet(
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
                                          (value) =>
                                              ComposeLogic.updateAttachment(
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
                        Gap(16),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      onPopInvoked: (_) {
        if (originalPost == null) {
          ComposeLogic.saveDraftWithoutUpload(ref, state);
        }
      },
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          leading: const PageBackButton(),
          title: ValueListenableBuilder<TextEditingValue>(
            valueListenable: state.titleController,
            builder: (context, titleValue, _) {
              return Text(
                titleValue.text.isEmpty ? 'postTitle'.tr() : titleValue.text,
              );
            },
          ),
          actions: [
            // Info banner for article compose
            const SizedBox.shrink(),
            IconButton(
              icon: ProfilePictureWidget(
                fileId: state.currentPublisher.value?.picture?.id,
                radius: 12,
                fallbackIcon:
                    state.currentPublisher.value == null
                        ? Symbols.question_mark
                        : null,
              ),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => const PublisherModal(),
                ).then((value) {
                  if (value != null) {
                    state.currentPublisher.value = value;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Symbols.settings),
              onPressed: showSettingsSheet,
              tooltip: 'postSettings'.tr(),
            ),
            Tooltip(
              message: 'togglePreview'.tr(),
              child: IconButton(
                icon: Icon(showPreview.value ? Symbols.edit : Symbols.preview),
                onPressed: () => showPreview.value = !showPreview.value,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: state.submitting,
              builder: (context, submitting, _) {
                return IconButton(
                  onPressed:
                      submitting
                          ? null
                          : () => ComposeLogic.performAction(
                            ref,
                            state,
                            context,
                            originalPost: originalPost,
                          ),
                  icon:
                      submitting
                          ? SizedBox(
                            width: 28,
                            height: 28,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ).center()
                          : Icon(
                            originalPost != null
                                ? Symbols.edit
                                : Symbols.upload,
                          ),
                );
              },
            ),
            const Gap(8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child:
                    isWideScreen(context)
                        ? Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              flex: showPreview.value ? 1 : 2,
                              child: buildEditorPane(),
                            ),
                            if (showPreview.value) const VerticalDivider(),
                            if (showPreview.value)
                              Expanded(child: buildPreviewPane()),
                          ],
                        )
                        : showPreview.value
                        ? buildPreviewPane()
                        : buildEditorPane(),
              ),
            ),

            // Bottom toolbar
            ComposeToolbar(state: state, originalPost: originalPost),
          ],
        ),
      ),
    );
  }
}
