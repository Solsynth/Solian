import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/post/compose_card.dart';

/// A dialog that wraps PostComposeCard for easy use in dialogs.
/// This provides a convenient way to show the compose interface in a modal dialog.
class PostComposeDialog extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  const PostComposeDialog({super.key, this.originalPost, this.initialState});

  static Future<SnPost?> show(
    BuildContext context, {
    SnPost? originalPost,
    PostComposeInitialState? initialState,
  }) {
    return showDialog<SnPost>(
      context: context,
      useRootNavigator: false,
      builder:
          (context) => PostComposeDialog(
            originalPost: originalPost,
            initialState: initialState,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: PostComposeCard(
          originalPost: originalPost,
          initialState: initialState,
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: (post) => Navigator.of(context).pop(post),
        ),
      ),
    );
  }
}
