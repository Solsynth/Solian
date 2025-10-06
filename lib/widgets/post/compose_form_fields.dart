import 'package:flutter/material.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_shared.dart';

/// A reusable widget for the form fields in compose screens.
/// Includes title, description, and content text fields.
class ComposeFormFields extends StatelessWidget {
  final ComposeState state;
  final bool enabled;
  final bool showPublisherAvatar;
  final VoidCallback? onPublisherTap;

  const ComposeFormFields({
    super.key,
    required this.state,
    this.enabled = true,
    this.showPublisherAvatar = true,
    this.onPublisherTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Publisher profile picture
        if (showPublisherAvatar)
          GestureDetector(
            child: ProfilePictureWidget(
              fileId: state.currentPublisher.value?.picture?.id,
              radius: 20,
              fallbackIcon:
                  state.currentPublisher.value == null
                      ? Icons.question_mark
                      : null,
            ),
            onTap: onPublisherTap,
          ),

        // Post content form
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.currentPublisher.value == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap the avatar to create a publisher and start composing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Title field
              TextField(
                controller: state.titleController,
                enabled: enabled && state.currentPublisher.value != null,
                decoration: InputDecoration(
                  hintText: 'postTitle',
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                style: theme.textTheme.titleMedium,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),

              // Description field
              TextField(
                controller: state.descriptionController,
                enabled: enabled && state.currentPublisher.value != null,
                decoration: InputDecoration(
                  hintText: 'postDescription',
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                ),
                style: theme.textTheme.bodyMedium,
                minLines: 1,
                maxLines: 3,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),

              // Content field
              TextField(
                controller: state.contentController,
                enabled: enabled && state.currentPublisher.value != null,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'postContent',
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                maxLines: null,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A specialized form fields widget for article compose with expanded content field.
class ArticleComposeFormFields extends StatelessWidget {
  final ComposeState state;
  final bool enabled;

  const ArticleComposeFormFields({
    super.key,
    required this.state,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: state.titleController,
              decoration: InputDecoration(
                hintText: 'postTitle',
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
              ),
              style: theme.textTheme.titleMedium,
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),

            // Description field
            TextField(
              controller: state.descriptionController,
              decoration: InputDecoration(
                hintText: 'postDescription',
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              ),
              style: theme.textTheme.bodyMedium,
              minLines: 1,
              maxLines: 3,
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),

            // Content field (expanded)
            Expanded(
              child: TextField(
                controller: state.contentController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'postContent',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
