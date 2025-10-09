import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/widgets/post/compose_shared.dart';

/// Utility class for common compose submit logic.
class ComposeSubmitUtils {
  /// Performs the submit action for posts.
  static Future<SnPost> performSubmit(
    WidgetRef ref,
    ComposeState state,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    required Function(SnPost) onSuccess,
  }) async {
    if (state.submitting.value) {
      throw Exception('Already submitting');
    }

    // Don't submit empty posts (no content and no attachments)
    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      // Show error message if context is mounted
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('postContentEmpty')));
      }
      throw Exception('Post content is empty'); // Don't submit empty posts
    }

    try {
      state.submitting.value = true;

      // Upload any local attachments first
      await Future.wait(
        state.attachments.value
            .asMap()
            .entries
            .where((entry) => entry.value.isOnDevice)
            .map(
              (entry) => ComposeLogic.uploadAttachment(ref, state, entry.key),
            ),
      );

      // Prepare API request
      final client = ref.read(apiClientProvider);
      final isNewPost = originalPost == null;
      final endpoint =
          '/sphere${isNewPost ? '/posts' : '/posts/${originalPost.id}'}';

      // Create request payload
      final payload = {
        'title': state.titleController.text,
        'description': state.descriptionController.text,
        'content': state.contentController.text,
        if (state.slugController.text.isNotEmpty)
          'slug': state.slugController.text,
        'visibility': state.visibility.value,
        'attachments':
            state.attachments.value
                .where((e) => e.isOnCloud)
                .map((e) => e.data.id)
                .toList(),
        'type': state.postType,
        if (repliedPost != null) 'replied_post_id': repliedPost.id,
        if (forwardedPost != null) 'forwarded_post_id': forwardedPost.id,
        'tags': state.tagsController.getTags,
        'categories': state.categories.value.map((e) => e.slug).toList(),
        if (state.realm.value != null) 'realm_id': state.realm.value?.id,
        if (state.pollId.value != null) 'poll_id': state.pollId.value,
        if (state.embedView.value != null)
          'embed_view': state.embedView.value!.toJson(),
      };

      // Send request
      final response = await client.request(
        endpoint,
        queryParameters: {'pub': state.currentPublisher.value?.name},
        data: payload,
        options: Options(method: isNewPost ? 'POST' : 'PATCH'),
      );

      // Parse the response into a SnPost
      final post = SnPost.fromJson(response.data);

      // Call the success callback with the created/updated post
      onSuccess(post);

      return post;
    } catch (err) {
      // Show error message if context is mounted
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $err')));
      }
      rethrow;
    } finally {
      state.submitting.value = false;
    }
  }

  /// Shows the settings sheet modal.
  static void showSettingsSheet(BuildContext context, ComposeState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ComposeSettingsSheet(state: state),
    );
  }

  /// Handles keyboard press events for compose shortcuts.
  static void handleKeyPress(
    KeyEvent event,
    ComposeState state,
    WidgetRef ref,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) {
    ComposeLogic.handleKeyPress(
      event,
      state,
      ref,
      context,
      originalPost: originalPost,
      repliedPost: repliedPost,
      forwardedPost: forwardedPost,
    );
  }
}
