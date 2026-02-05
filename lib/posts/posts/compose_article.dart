import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/publishers_form.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/posts/posts/post_detail.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/posts_widgets/post/compose_attachments.dart';
import 'package:island/posts/posts_widgets/post/compose_form_fields.dart';
import 'package:island/posts/posts_widgets/post/compose_settings_sheet.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';
import 'package:island/posts/posts_widgets/post/compose_toolbar.dart';
import 'package:island/posts/posts_widgets/post/publishers_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
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
      loading: () => AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: Text('Error: $e', textAlign: TextAlign.center),
      ),
    );
  }
}

class ArticleComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  const ArticleComposeScreen({super.key, this.originalPost, this.initialState});

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
    final showSidebar = useState(false);

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        state.currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // Load initial state if provided (for sharing functionality)
    useEffect(() {
      if (initialState != null) {
        state.titleController.text = initialState!.title ?? '';
        state.descriptionController.text = initialState!.description ?? '';
        state.contentController.text = initialState!.content ?? '';
        if (initialState!.visibility != null) {
          state.visibility.value = initialState!.visibility!;
        }
        if (initialState!.attachments.isNotEmpty) {
          state.attachments.value = List.from(initialState!.attachments);
        }
      }
      return null;
    }, [initialState]);

    // Load draft if available (only for new articles)
    useEffect(() {
      if (originalPost == null && initialState == null) {
        // Try to load the most recent article draft
        final drafts = ref.read(composeStorageProvider);
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
    Widget buildPreviewPane() {
      final widgetItem = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
                          const Gap(20),
                        ],
                        if (descriptionValue.text.isNotEmpty) ...[
                          Text(
                            descriptionValue.text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const Gap(20),
                        ],
                        if (contentValue.text.isNotEmpty)
                          MarkdownTextContent(
                            content: contentValue.text,
                            textStyle: theme.textTheme.bodyMedium,
                            attachments: state.attachments.value
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
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
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
      final editorContent = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ComposeFormFields(
                    state: state,
                    showPublisherAvatar: false,
                    onPublisherTap: () {
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
                ),
              ),
            ],
          ),
        ),
      );

      // Add background color for mobile editor pane
      if (!isWideScreen(context)) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: editorContent,
        );
      }

      return editorContent;
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
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.fastEaseInToSlowEaseOut,
                switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                child: Text(
                  titleValue.text.isEmpty ? 'postTitle'.tr() : titleValue.text,
                  key: ValueKey(titleValue.text),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          actions: [
            // Info banner for article compose
            const SizedBox.shrink(),
            IconButton(
              icon: ProfilePictureWidget(
                file: state.currentPublisher.value?.picture,
                radius: 12,
                fallbackIcon: state.currentPublisher.value == null
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
              icon: const Icon(Symbols.tune),
              onPressed: () => showSidebar.value = !showSidebar.value,
              tooltip: 'sidebar'.tr(),
            ),
            Tooltip(
              message: 'togglePreview'.tr(),
              child: IconButton(
                icon: Icon(
                  showPreview.value ? Symbols.preview_off : Symbols.preview,
                ),
                onPressed: () => showPreview.value = !showPreview.value,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: state.submitting,
              builder: (context, submitting, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.8,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: submitting
                      ? SizedBox(
                          key: const ValueKey('submitting'),
                          width: 28,
                          height: 28,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ).center()
                      : IconButton(
                          key: const ValueKey('icon'),
                          onPressed: () => ComposeLogic.performAction(
                            ref,
                            state,
                            context,
                            originalPost: originalPost,
                          ),
                          icon: Icon(
                            originalPost != null
                                ? Symbols.edit
                                : Symbols.upload,
                          ),
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
              child: ResponsiveSidebar(
                sidebarWidth: 480,
                attachmentsContent: ArticleComposeAttachments(state: state),
                settingsContent: ComposeSettingsSheet(state: state),
                showSidebar: showSidebar,
                mainContent: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          final isWide = isWideScreen(context);
                          if (isWide) {
                            // Desktop: scale animation
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            );
                          } else {
                            // Mobile: horizontal slide animation
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            );
                          }
                        },
                    child: isWideScreen(context)
                        ? Row(
                            spacing: 16,
                            children: [
                              Expanded(child: buildEditorPane()),
                              if (showPreview.value)
                                Expanded(child: buildPreviewPane()),
                            ],
                          )
                        : Container(
                            key: ValueKey('narrow-${showPreview.value}'),
                            child: showPreview.value
                                ? buildPreviewPane()
                                : buildEditorPane(),
                          ),
                  ),
                ),
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
