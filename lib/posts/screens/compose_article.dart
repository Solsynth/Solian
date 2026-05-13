import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/widgets/compose/compose_attachments.dart';
import 'package:island/posts/widgets/compose/compose_form_fields.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_toolbar.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/posts/widgets/compose/article_responsive_sidebar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class ArticleEditScreen extends HookConsumerWidget {
  final String id;
  const ArticleEditScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => ArticleComposeScreen(originalPost: post),
      loading: () => AppScaffold(
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: Text('Error: $e', textAlign: TextAlign.center),
      ),
    );
  }
}

class _ArticlePreviewPane extends HookWidget {
  final ComposeState state;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ArticlePreviewPane({
    required this.state,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final title = useValueListenable(state.titleController);
    final description = useValueListenable(state.descriptionController);
    final content = useValueListenable(state.contentController);
    final attachments = useValueListenable(state.attachments);

    final widgetItem = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.text.isNotEmpty) ...[
            Text(
              title.text,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
          ],
          if (description.text.isNotEmpty) ...[
            Text(
              description.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Gap(20),
          ],
          if (content.text.isNotEmpty)
            MarkdownTextContent(
              content: content.text,
              textStyle: theme.textTheme.bodyMedium,
              attachments: attachments
                  .where((e) => e.isOnCloud)
                  .map((e) => e.data)
                  .cast<SnCloudFile>()
                  .toList(),
            ),
        ],
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
}

@RoutePage()
class ArticleComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  const ArticleComposeScreen({super.key, this.originalPost, this.initialState});

  static const int _articlePostType = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        cloudDraftId: initialState?.cloudDraftId,
        postType: 1, // Article type
      ),
      [originalPost, initialState?.cloudDraftId],
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

    final restorePrompted = useState(false);

    // Prompt restore if available (only for new articles)
    useEffect(() {
      if (restorePrompted.value ||
          originalPost != null ||
          initialState != null) {
        return null;
      }
      final latestDraft = ref
          .read(composeStorageProvider.notifier)
          .getLatestDraftByType(_articlePostType);
      if (latestDraft == null) return null;
      final hasMeaningfulContent =
          latestDraft.content?.trim().isNotEmpty == true ||
          latestDraft.title?.trim().isNotEmpty == true ||
          latestDraft.description?.trim().isNotEmpty == true ||
          latestDraft.attachments.isNotEmpty;
      if (!hasMeaningfulContent) return null;

      restorePrompted.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final shouldRestore = await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (context) => AlertDialog(
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'restoreDraftTitle'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(12),
                  Text('restoreDraftMessage'.tr()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('no'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('yes'.tr()),
              ),
            ],
          ),
        );

        if (shouldRestore == true) {
          if (latestDraft.draftedAt != null) {
            state.cloudDraftId.value = latestDraft.id;
          }
          state.titleController.text = latestDraft.title ?? '';
          state.descriptionController.text = latestDraft.description ?? '';
          state.contentController.text = latestDraft.content ?? '';
          state.visibility.value = latestDraft.visibility;
          if (latestDraft.attachments.isNotEmpty) {
            state.attachments.value = latestDraft.attachments
                .map((e) => UniversalFile.fromAttachment(e))
                .toList();
          }
          await ref
              .read(composeStorageProvider.notifier)
              .deleteLocalDraft(latestDraft.id);
        }
      });
      return null;
    }, [originalPost, initialState, restorePrompted.value]);

    // Helper methods
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
          leading: const AutoLeadingButton(),
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
            const SizedBox.shrink(),
            ValueListenableBuilder<SnPublisher?>(
              valueListenable: state.currentPublisher,
              builder: (context, publisher, _) {
                return IconButton(
                  icon: ProfilePictureWidget(
                    file: publisher?.picture,
                    radius: 12,
                    fallbackIcon: publisher == null
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
                );
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
              child: ArticleResponsiveSidebar(
                sidebarWidth: 480,
                attachmentsContent: ArticleComposeAttachments(
                  state: state,
                  onAttachmentAdded: () => showSidebar.value = true,
                ),
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
                                Expanded(
                                  child: _ArticlePreviewPane(
                                    state: state,
                                    theme: theme,
                                    colorScheme: colorScheme,
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            key: ValueKey('narrow-${showPreview.value}'),
                            child: showPreview.value
                                ? _ArticlePreviewPane(
                                    state: state,
                                    theme: theme,
                                    colorScheme: colorScheme,
                                  )
                                : buildEditorPane(),
                          ),
                  ),
                ),
              ),
            ),

            // Bottom toolbar
            ComposeToolbar(
              state: state,
              originalPost: originalPost,
              onAttachmentAdded: () => showSidebar.value = true,
            ),
          ],
        ),
      ),
    );
  }
}
