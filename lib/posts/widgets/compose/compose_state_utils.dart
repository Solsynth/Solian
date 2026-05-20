import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/creators/screens/publishers_form.dart'
    as publishers_form;
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Utility class for common compose state management logic.
class ComposeStateUtils {
  /// Initializes publisher when data becomes available.
  static void usePublisherInitialization(WidgetRef ref, ComposeState state) {
    final publishers = ref.watch(publishers_form.publishersManagedProvider);
    final publishingSettings = ref.watch(publishingSettingsProvider);

    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (state.currentPublisher.value == null) {
          // Try to find default publisher from settings
          SnPublisher? defaultPublisher;
          if (publishingSettings.hasValue) {
            final defaultId =
                publishingSettings.value!.defaultPostingPublisherId;
            if (defaultId != null) {
              defaultPublisher = publishers.value!
                  .where((p) => p.id == defaultId)
                  .firstOrNull;
            }
          }
          // Fall back to first publisher if no default found
          state.currentPublisher.value =
              defaultPublisher ?? publishers.value!.first;
        }
      }
      return null;
    }, [publishers, publishingSettings]);
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
        if (initialState.cloudDraftId?.isNotEmpty == true) {
          state.cloudDraftId.value = initialState.cloudDraftId;
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
        final mostRecentDraft = ref
            .read(composeStorageProvider.notifier)
            .getLatestDraftByType(state.postType);
        if (mostRecentDraft == null) return null;

        // Only load if the draft has meaningful content
        if (mostRecentDraft.content?.isNotEmpty == true ||
            mostRecentDraft.title?.isNotEmpty == true) {
          state.titleController.text = mostRecentDraft.title ?? '';
          state.descriptionController.text = mostRecentDraft.description ?? '';
          state.contentController.text = mostRecentDraft.content ?? '';
          state.visibility.value = mostRecentDraft.visibility;
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
          ComposeLogic.saveDraftWithoutUpload(ref, state);
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
