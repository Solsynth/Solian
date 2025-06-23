import 'package:auto_route/auto_route.dart';
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
import 'package:island/screens/posts/detail.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class ArticleEditScreen extends HookConsumerWidget {
  final String id;
  const ArticleEditScreen({super.key, @PathParam('id') required this.id});

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

@RoutePage()
class ArticleComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;

  const ArticleComposeScreen({super.key, this.originalPost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(originalPost: originalPost),
      [originalPost],
    );

    final showPreview = useState(false);

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        state.currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // Dispose state when widget is disposed
    useEffect(() {
      return () => ComposeLogic.dispose(state);
    }, []);

    // Helper methods
    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => ComposeSettingsSheet(
              titleController: state.titleController,
              descriptionController: state.descriptionController,
              visibility: state.visibility,
              onVisibilityChanged: () {
                // Trigger rebuild if needed
              },
            ),
      );
    }

    Widget buildPreviewPane() {
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(16),
                                ],
                                if (descriptionValue.text.isNotEmpty) ...[
                                  Text(
                                    descriptionValue.text,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                  const Gap(16),
                                ],
                                if (contentValue.text.isNotEmpty)
                                  MarkdownTextContent(
                                    content: contentValue.text,
                                    textStyle: theme.textTheme.bodyMedium,
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildEditorPane() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Publisher row
          Card(
            margin: EdgeInsets.only(bottom: 8),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    child: ProfilePictureWidget(
                      fileId: state.currentPublisher.value?.picture?.id,
                      radius: 20,
                      fallbackIcon:
                          state.currentPublisher.value == null
                              ? Symbols.question_mark
                              : null,
                    ),
                    onTap: () {
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
                  const Gap(12),
                  Text(
                    state.currentPublisher.value?.name ??
                        'postPublisherUnselected'.tr(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Content field with keyboard listener
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey:
                  (event) => ComposeLogic.handleKeyPress(
                    event,
                    state,
                    ref,
                    context,
                    originalPost: originalPost,
                    postType: 1, // Article type
                  ),
              child: TextField(
                controller: state.contentController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'postContent'.tr(),
                  contentPadding: const EdgeInsets.all(8),
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
              return Column(
                children: [
                  const Gap(16),
                  ValueListenableBuilder<Map<int, double>>(
                    valueListenable: state.attachmentProgress,
                    builder: (context, progressMap, _) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var idx = 0; idx < attachments.length; idx++)
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: AttachmentPreview(
                                item: attachments[idx],
                                progress: progressMap[idx],
                                onRequestUpload:
                                    () => ComposeLogic.uploadAttachment(
                                      ref,
                                      state,
                                      idx,
                                    ),
                                onDelete:
                                    () => ComposeLogic.deleteAttachment(
                                      ref,
                                      state,
                                      idx,
                                    ),
                                onMove: (delta) {
                                  state
                                      .attachments
                                      .value = ComposeLogic.moveAttachment(
                                    state.attachments.value,
                                    idx,
                                    delta,
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      );
    }

    return AppScaffold(
      noBackground: false,
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
                          postType: 1, // Article type
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
                          originalPost != null ? Symbols.edit : Symbols.upload,
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
          Material(
            elevation: 4,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => ComposeLogic.pickPhotoMedia(ref, state),
                  icon: const Icon(Symbols.add_a_photo),
                  color: colorScheme.primary,
                ),
                IconButton(
                  onPressed: () => ComposeLogic.pickVideoMedia(ref, state),
                  icon: const Icon(Symbols.videocam),
                  color: colorScheme.primary,
                ),
              ],
            ).padding(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              horizontal: 16,
              top: 8,
            ),
          ),
        ],
      ),
    );
  }
}
