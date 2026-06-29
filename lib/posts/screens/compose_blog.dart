import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/database.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      var active = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!active || !context.mounted) return;
        final result = await BlogComposeDialog.show(
          context,
          originalPost: originalPost,
          initialState: initialState,
        );
        if (context.mounted) {
          context.router.maybePop(result);
        }
      });
      return () => active = false;
    }, [originalPost, initialState]);

    return const AppScaffold(isNoBackground: true, body: SizedBox.shrink());
  }
}

class BlogComposeDialog extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final VoidCallback onCancel;
  final VoidCallback onSubmitted;

  const BlogComposeDialog({
    super.key,
    required this.onCancel,
    required this.onSubmitted,
    this.originalPost,
    this.initialState,
  });

  static const int _blogPostType = 2;

  static Future<bool?> show(
    BuildContext context, {
    SnPost? originalPost,
    PostComposeInitialState? initialState,
  }) {
    final completer = Completer<bool?>();
    showAttentionModal(
      id: 'blog-compose',
      replaceIfExists: true,
      barrierDismissible: true,
      builder: (overlayContext, dismiss) => BlogComposeDialog(
        originalPost: originalPost,
        initialState: initialState,
        onCancel: () {
          if (!completer.isCompleted) completer.complete(null);
          dismiss();
        },
        onSubmitted: () {
          if (!completer.isCompleted) completer.complete(true);
          dismiss();
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);
    final database = ref.read(databaseProvider);
    final showWidePanel = isWideScreen(context);

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
        state.startAutoSave(
          (composeState) => ComposeLogic.saveDraftWithoutUploadWithDatabase(
            database,
            composeState,
          ),
        );
      }
      return () {
        state.stopAutoSave();
        if (originalPost == null) {
          ComposeLogic.saveDraftWithoutUploadWithDatabase(database, state);
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
      if (restorePrompted.value ||
          originalPost != null ||
          initialState != null) {
        return null;
      }
      final latestDraft = ref
          .read(composeStorageProvider.notifier)
          .getLatestDraftByType(_blogPostType);
      if (latestDraft == null) return null;
      final hasContent =
          latestDraft.content?.trim().isNotEmpty == true ||
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

    void showSettingsSheet() {
      showAttentionModal(
        id: 'blog-compose-settings',
        replaceIfExists: true,
        barrierDismissible: true,
        builder: (context, dismiss) => AttentionModalScaffold(
          titleText: 'postSettings'.tr(),
          onDismiss: dismiss,
          forceCard: true,
          child: ComposeSettingsSheet(state: state),
        ),
      );
    }

    Future<void> performSubmit() async {
      final url = state.contentController.text.trim();
      if (url.isEmpty) {
        showErrorAlert('blogComposeUrlRequired'.tr());
        return;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        showErrorAlert('blogComposeUrlInvalid'.tr());
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
          if (context.mounted) onSubmitted();
        },
      );
    }

    return PopScope(
      onPopInvoked: (_) {
        if (originalPost == null) {
          ComposeLogic.saveDraftWithoutUploadWithDatabase(database, state);
        }
      },
      child: AttentionModalScaffold(
        titleText: originalPost != null ? 'editBlog'.tr() : 'newBlog'.tr(),
        onDismiss: onCancel,
        actions: [
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
                    if (value != null) state.currentPublisher.value = value;
                  });
                },
                tooltip: 'changePublisher'.tr(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Symbols.tune),
            onPressed: showSettingsSheet,
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
        ],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showWidePanel)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: _BlogComposeForm(state: state),
                          ),
                        ),
                      ),
                      const Gap(24),
                      SizedBox(width: 300, child: _BlogComposeInfoPanel()),
                    ],
                  )
                else ...[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _BlogComposeForm(state: state),
                    ),
                  ),
                  const Gap(16),
                  const _BlogComposeInfoPanel(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlogComposeForm extends StatelessWidget {
  final ComposeState state;

  const _BlogComposeForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.currentPublisher.value != null)
            Row(
              children: [
                ProfilePictureWidget(
                  file: state.currentPublisher.value?.picture,
                  radius: 16,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    '@${state.currentPublisher.value?.name ?? ''}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
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
                  child: Text('changePublisher'.tr()),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.info,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'blogComposePublisherHint'.tr(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          const Gap(20),
          Text('blogUrl'.tr(), style: theme.textTheme.labelLarge),
          const Gap(6),
          Text(
            'blogComposeVerifiedDomainHint'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const Gap(8),
          TextField(
            controller: state.contentController,
            keyboardType: TextInputType.url,
            maxLines: 1,
          ),
          const Gap(16),
          Text('postTitle'.tr(), style: theme.textTheme.labelLarge),
          const Gap(6),
          TextField(controller: state.titleController, maxLength: 1024),
          const Gap(8),
          Text('postDescription'.tr(), style: theme.textTheme.labelLarge),
          const Gap(6),
          TextField(
            controller: state.descriptionController,
            maxLines: 3,
            maxLength: 4096,
          ),
        ],
      ),
    );
  }
}

class _BlogComposeInfoPanel extends StatelessWidget {
  const _BlogComposeInfoPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.public, color: theme.colorScheme.primary, size: 22),
          const Gap(12),
          Text(
            'blogComposePanelTitle'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(10),
          Text(
            'blogComposePanelBody'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const Gap(14),
          Text(
            'blogComposeAboutTitle'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          Text(
            'blogComposeAboutBody'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Gap(18),
          _BlogComposeBenefit(
            icon: Symbols.language,
            label: 'blogComposeBenefitOwnership'.tr(),
          ),
          const Gap(12),
          _BlogComposeBenefit(
            icon: Symbols.campaign,
            label: 'blogComposeBenefitReach'.tr(),
          ),
          const Gap(12),
          _BlogComposeBenefit(
            icon: Symbols.chat_bubble,
            label: 'blogComposeBenefitEngagement'.tr(),
          ),
        ],
      ),
    );
  }
}

class _BlogComposeBenefit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BlogComposeBenefit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
