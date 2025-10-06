import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/screens/creators/publishers_form.dart';
import 'package:island/screens/posts/compose_article.dart';
import 'package:island/screens/posts/post_detail.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_attachments.dart';
import 'package:island/widgets/post/compose_form_fields.dart';
import 'package:island/widgets/post/compose_info_banner.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/compose_toolbar.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

part 'compose.freezed.dart';
part 'compose.g.dart';

@freezed
sealed class PostComposeInitialState with _$PostComposeInitialState {
  const factory PostComposeInitialState({
    String? title,
    String? description,
    String? content,
    @Default([]) List<UniversalFile> attachments,
    int? visibility,
    SnPost? replyingTo,
    SnPost? forwardingTo,
  }) = _PostComposeInitialState;

  factory PostComposeInitialState.fromJson(Map<String, dynamic> json) =>
      _$PostComposeInitialStateFromJson(json);
}

class PostEditScreen extends HookConsumerWidget {
  final String id;
  const PostEditScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => PostComposeScreen(originalPost: post),
      loading:
          () => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: Text('Error: $e', textAlign: TextAlign.center),
          ),
    );
  }
}

class PostComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final int? type;
  final PostComposeInitialState? initialState;
  const PostComposeScreen({
    super.key,
    this.type,
    this.initialState,
    this.originalPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the compose type: auto-detect from edited post or use query parameter
    final composeType = originalPost?.type ?? type ?? 0;
    final repliedPost = initialState?.replyingTo ?? originalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;

    // If type is 1 (article), return ArticleComposeScreen
    if (composeType == 1) {
      return ArticleComposeScreen(originalPost: originalPost);
    }

    // When editing, preserve the original replied/forwarded post references
    final effectiveRepliedPost = repliedPost ?? originalPost?.repliedPost;
    final effectiveForwardedPost = forwardedPost ?? originalPost?.forwardedPost;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        forwardedPost: effectiveForwardedPost,
        repliedPost: effectiveRepliedPost,
        postType: 0, // Regular post type
      ),
      [originalPost, effectiveForwardedPost, effectiveRepliedPost],
    );

    // Add a listener to the entire state to trigger rebuilds
    final stateNotifier = useMemoized(
      () => Listenable.merge([
        state.titleController,
        state.descriptionController,
        state.contentController,
        state.visibility,
        state.attachments,
        state.attachmentProgress,
        state.currentPublisher,
        state.submitting,
      ]),
      [state],
    );
    useListenable(stateNotifier);

    // Start auto-save when component mounts
    useEffect(() {
      if (originalPost == null) {
        // Only auto-save for new posts, not edits
        state.startAutoSave(ref);
      }
      return () => state.stopAutoSave();
    }, [state]);

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (state.currentPublisher.value == null) {
          // If no publisher is set, use the first available one
          state.currentPublisher.value = publishers.value!.first;
        }
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

    // Load draft if available (only for new posts without initial state)
    useEffect(() {
      if (originalPost == null &&
          effectiveForwardedPost == null &&
          effectiveRepliedPost == null &&
          initialState == null) {
        // Try to load the most recent draft
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

    // Dispose state when widget is disposed
    useEffect(() {
      return () {
        state.stopAutoSave();
        ComposeLogic.dispose(state);
      };
    }, []);

    // Helper methods

    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ComposeSettingsSheet(state: state),
      );
    }

    return PopScope(
      onPopInvoked: (_) {
        if (originalPost == null) {
          ComposeLogic.saveDraft(ref, state);
        }
      },
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          leading: const PageBackButton(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.settings),
              onPressed: showSettingsSheet,
              tooltip: 'postSettings'.tr(),
            ),
            IconButton(
              onPressed:
                  state.submitting.value
                      ? null
                      : () => ComposeLogic.performAction(
                        ref,
                        state,
                        context,
                        originalPost: originalPost,
                        repliedPost: repliedPost,
                        forwardedPost: forwardedPost,
                      ),
              icon:
                  state.submitting.value
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
            ),
            const Gap(8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply/Forward info section
            ComposeInfoBanner(
              originalPost: originalPost,
              replyingTo: repliedPost,
              forwardingTo: forwardedPost,
              onReferencePostTap: (context, post) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        builder:
                            (context, scrollController) => Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      padding: const EdgeInsets.all(16),
                                      child: PostItem(item: post),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                );
              },
            ),

            // Main content area
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Publisher profile picture
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
                    ).padding(top: 16),

                    // Post content form
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
                              repliedPost: repliedPost,
                              forwardedPost: forwardedPost,
                            ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ComposeFormFields(
                                state: state,
                                showPublisherAvatar: false,
                                onPublisherTap: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder:
                                        (context) => const PublisherModal(),
                                  ).then((value) {
                                    if (value != null) {
                                      state.currentPublisher.value = value;
                                    }
                                  });
                                },
                              ),
                              const Gap(8),
                              ComposeAttachments(
                                state: state,
                                isCompact: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 16),
              ).alignment(Alignment.topCenter),
            ),

            // Bottom toolbar
            ComposeToolbar(state: state, originalPost: originalPost),
          ],
        ),
      ),
    );
  }
}
