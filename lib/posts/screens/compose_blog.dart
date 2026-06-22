import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/services/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class BlogEditScreen extends HookConsumerWidget {
  final String id;
  const BlogEditScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => BlogComposeScreen(originalPost: post),
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

@RoutePage()
class BlogComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  const BlogComposeScreen({super.key, this.originalPost, this.initialState});

  static const int _blogPostType = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final publishers = ref.watch(publishersManagedProvider);

    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        cloudDraftId: initialState?.cloudDraftId,
        postType: _blogPostType,
      ),
      [originalPost, initialState?.cloudDraftId],
    );

    // Auto-save
    useEffect(() {
      if (originalPost == null) {
        state.startAutoSave(ref);
      }
      return () {
        state.stopAutoSave();
        if (originalPost == null) {
          ComposeLogic.saveDraftWithoutUpload(ref, state);
        }
        ComposeLogic.dispose(state);
      };
    }, [state]);

    // Publisher init
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        state.currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // Load initial state
    useEffect(() {
      if (initialState != null) {
        state.titleController.text = initialState!.title ?? '';
        state.descriptionController.text = initialState!.description ?? '';
        state.contentController.text = initialState!.content ?? '';
        if (initialState!.visibility != null) {
          state.visibility.value = initialState!.visibility!;
        }
      }
      return null;
    }, [initialState]);

    // Restore draft prompt
    final restorePrompted = useState(false);
    useEffect(() {
      if (restorePrompted.value || originalPost != null || initialState != null) {
        return null;
      }
      final latestDraft = ref
          .read(composeStorageProvider.notifier)
          .getLatestDraftByType(_blogPostType);
      if (latestDraft == null) return null;
      final hasContent = latestDraft.content?.trim().isNotEmpty == true ||
          latestDraft.title?.trim().isNotEmpty == true;
      if (!hasContent) return null;
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
                  Text('restoreDraftTitle'.tr(),
                      style: Theme.of(context).textTheme.titleLarge),
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
          await ref
              .read(composeStorageProvider.notifier)
              .deleteLocalDraft(latestDraft.id);
        }
      });
      return null;
    }, [originalPost, initialState, restorePrompted.value]);

    final stateNotifier = useMemoized(
      () => Listenable.merge([
        state.titleController,
        state.descriptionController,
        state.contentController,
        state.visibility,
        state.submitting,
        state.currentPublisher,
      ]),
      [state],
    );
    useListenable(stateNotifier);

    ComposeStateUtils.usePublisherInitialization(ref, state);

    final showSidebar = useState(false);

    Future<void> performSubmit() async {
      // Validate URL
      final url = state.contentController.text.trim();
      if (url.isEmpty) {
        showErrorAlert('Blog URL is required');
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        showErrorAlert('Please enter a valid absolute URL');
        return;
      }

      await ComposeLogic.performSubmit(
        ref,
        state,
        context,
        originalPost: originalPost,
        onSuccess: () async {
          final storage = ref.read(composeStorageProvider.notifier);
          final toDelete = <String>{
            state.draftId,
            if (state.cloudDraftId.value != null) state.cloudDraftId.value!,
          };
          for (final id in toDelete) {
            await storage.deleteLocalDraft(id);
          }
          if (context.mounted) Navigator.of(context).maybePop(true);
        },
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
          leading: const AutoLeadingButton(),
          title: Text(originalPost != null ? 'editBlog'.tr() : 'newBlog'.tr()),
          actions: [
            ValueListenableBuilder<SnPublisher?>(
              valueListenable: state.currentPublisher,
              builder: (context, publisher, _) {
                return IconButton(
                  icon: ProfilePictureWidget(
                    file: publisher?.picture,
                    radius: 12,
                    fallbackIcon:
                        publisher == null ? Symbols.question_mark : null,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => const PublisherModal(),
                    ).then((value) {
                      if (value != null) state.currentPublisher.value = value;
                    });
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Symbols.tune),
              onPressed: () => showSidebar.value = !showSidebar.value,
              tooltip: 'settings'.tr(),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: state.submitting,
              builder: (context, submitting, _) {
                return submitting
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : IconButton(
                        onPressed: performSubmit,
                        icon: Icon(
                          originalPost != null ? Symbols.edit : Symbols.upload,
                        ),
                      );
              },
            ),
            const Gap(8),
          ],
        ),
        body: Row(
          children: [
            // Main editor
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Publisher selector row
                        if (state.currentPublisher.value != null)
                          Row(
                            children: [
                              ProfilePictureWidget(
                                file:
                                    state.currentPublisher.value?.picture,
                                radius: 16,
                              ),
                              const Gap(8),
                              Text(
                                '@${state.currentPublisher.value?.name ?? ''}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) =>
                                        const PublisherModal(),
                                  ).then((value) {
                                    if (value != null) {
                                      state.currentPublisher.value = value;
                                    }
                                  });
                                },
                                child: Text('change'.tr()),
                              ),
                            ],
                          ),
                        if (state.currentPublisher.value == null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info,
                                    size: 16,
                                    color: theme.colorScheme.primary),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    'Tap the avatar to select a publisher.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Gap(16),

                        // URL field (required)
                        Text('blogUrl'.tr(),
                            style: theme.textTheme.labelLarge),
                        const Gap(4),
                        TextField(
                          controller: state.contentController,
                          decoration: InputDecoration(
                            hintText: 'https://blog.example.com/my-article',
                            prefixIcon: const Icon(Symbols.link),
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                          keyboardType: TextInputType.url,
                          maxLines: 1,
                        ),
                        const Gap(16),

                        // Title field
                        Text('postTitle'.tr(),
                            style: theme.textTheme.labelLarge),
                        const Gap(4),
                        TextField(
                          controller: state.titleController,
                          decoration: InputDecoration(
                            hintText: 'postTitleHint'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                          maxLength: 1024,
                        ),
                        const Gap(8),

                        // Description field
                        Text('postDescription'.tr(),
                            style: theme.textTheme.labelLarge),
                        const Gap(4),
                        TextField(
                          controller: state.descriptionController,
                          decoration: InputDecoration(
                            hintText: 'postDescriptionHint'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                          maxLines: 3,
                          maxLength: 4096,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar (settings)
            if (showSidebar.value && isWideScreen(context))
              SizedBox(
                width: 320,
                child: Material(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ComposeSettingsSheet(state: state),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
