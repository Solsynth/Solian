import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/publishers_form.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';

/// Utility class for common compose state management logic.
class ComposeStateUtils {
  /// Initializes publisher when data becomes available.
  static void usePublisherInitialization(WidgetRef ref, ComposeState state) {
    final publishers = ref.watch(publishersManagedProvider);

    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (state.currentPublisher.value == null) {
          state.currentPublisher.value = publishers.value!.first;
        }
      }
      return null;
    }, [publishers]);
  }

  /// Loads initial state from provided parameters.
  static void useInitialStateLoader(
    ComposeState state,
    PostComposeInitialState? initialState,
  ) {
    useEffect(() {
      if (initialState != null) {
        state.titleController.text = initialState.title ?? '';
        state.descriptionController.text = initialState.description ?? '';
        state.contentController.text = initialState.content ?? '';
        if (initialState.visibility != null) {
          state.visibility.value = initialState.visibility!;
        }
        if (initialState.attachments.isNotEmpty) {
          state.attachments.value = List.from(initialState.attachments);
        }
      }
      return null;
    }, [initialState]);
  }

  /// Loads draft if available (for new posts without initial state).
  static void useDraftLoader(
    WidgetRef ref,
    ComposeState state,
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    PostComposeInitialState? initialState,
  ) {
    useEffect(() {
      if (originalPost == null &&
          forwardedPost == null &&
          repliedPost == null &&
          initialState == null) {
        // Try to load the most recent draft
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
  }

  /// Handles auto-save functionality for new posts.
  static void useAutoSave(WidgetRef ref, ComposeState state, bool isNewPost) {
    useEffect(() {
      if (isNewPost) {
        state.startAutoSave(ref);
      }
      return () => state.stopAutoSave();
    }, [state]);
  }

  /// Handles disposal and draft saving logic.
  static void useDisposalHandler(
    WidgetRef ref,
    ComposeState state,
    SnPost? originalPost,
    bool submitted,
  ) {
    useEffect(() {
      return () {
        if (!submitted &&
            originalPost == null &&
            state.currentPublisher.value != null) {
          final hasContent =
              state.titleController.text.trim().isNotEmpty ||
              state.descriptionController.text.trim().isNotEmpty ||
              state.contentController.text.trim().isNotEmpty;
          final hasAttachments = state.attachments.value.isNotEmpty;
          if (hasContent || hasAttachments) {
            final draft = SnPost(
              id: state.draftId,
              title: state.titleController.text,
              description: state.descriptionController.text,
              content: state.contentController.text,
              visibility: state.visibility.value,
              type: state.postType,
              attachments: state.attachments.value
                  .where((e) => e.isOnCloud)
                  .map((e) => e.data as SnCloudFile)
                  .toList(),
              publisher: state.currentPublisher.value!,
              updatedAt: DateTime.now(),
            );
            ref
                .read(composeStorageProvider.notifier)
                .saveDraft(draft)
                .catchError((e) => debugPrint('Failed to save draft: $e'));
          }
        }
        ComposeLogic.dispose(state);
      };
    }, []);
  }

  /// Creates and manages the state notifier for rebuilds.
  static Listenable useStateNotifier(ComposeState state) {
    return useMemoized(
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
  }

  /// Resets form to clean state for new composition.
  static void resetForm(ComposeState state) {
    // Clear text fields
    state.titleController.clear();
    state.descriptionController.clear();
    state.contentController.clear();
    state.slugController.clear();

    // Reset visibility to default (0 = public)
    state.visibility.value = 0;

    // Clear attachments
    state.attachments.value = [];

    // Clear attachment progress
    state.attachmentProgress.value = {};

    // Clear tags
    state.tags.value = [];

    // Clear categories
    state.categories.value = [];

    // Clear embed view
    state.embedView.value = null;

    // Clear poll
    state.pollId.value = null;

    // Clear realm
    state.realm.value = null;

    // Generate new draft ID for fresh composition
    // Note: We don't recreate the entire state, just reset the fields
    // The existing state object is reused for continuity
  }
}
