import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/block_content_editor.dart';
import 'package:island/drive/widgets/cloud_files.dart';

/// Inset shared by the title, description and content fields so their text
/// starts on the same column and the gaps between them stay even.
const EdgeInsets _fieldPadding = EdgeInsets.all(8);

KeyEventResult _preserveComposeFieldFocus(FocusNode node, KeyEvent event) {
  final isArrowKey =
      event.logicalKey == LogicalKeyboardKey.arrowUp ||
      event.logicalKey == LogicalKeyboardKey.arrowDown ||
      event.logicalKey == LogicalKeyboardKey.arrowLeft ||
      event.logicalKey == LogicalKeyboardKey.arrowRight;
  final isEnterKey = event.logicalKey == LogicalKeyboardKey.enter;
  final hasModifier =
      HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isAltPressed;
  final isKeyDownEvent = event is KeyDownEvent || event is KeyRepeatEvent;

  if (isKeyDownEvent && isArrowKey && !hasModifier) {
    return KeyEventResult.ignored;
  }
  if (isKeyDownEvent && isEnterKey && !hasModifier) {
    return KeyEventResult.ignored;
  }
  return KeyEventResult.ignored;
}

/// A reusable widget for the form fields in compose screens.
/// Includes title, description, and content text fields.
class ComposeFormFields extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Publisher profile picture
        if (showPublisherAvatar)
          GestureDetector(
            onTap: onPublisherTap,
            child: ProfilePictureWidget(
              file: state.currentPublisher.value?.picture,
              fallbackName: state.currentPublisher.value?.nick,
              radius: 20,
              fallbackIcon: state.currentPublisher.value == null
                  ? Icons.question_mark
                  : null,
            ),
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
              Focus(
                onKeyEvent: _preserveComposeFieldFocus,
                child: TextField(
                  controller: state.titleController,
                  enabled: enabled && state.currentPublisher.value != null,
                  decoration: InputDecoration(
                    hintText: 'postTitle'.tr(),
                    border: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: _fieldPadding,
                  ),
                  style: theme.textTheme.titleMedium,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),

              // Description field
              Focus(
                onKeyEvent: _preserveComposeFieldFocus,
                child: TextField(
                  controller: state.descriptionController,
                  enabled: enabled && state.currentPublisher.value != null,
                  decoration: InputDecoration(
                    hintText: 'postDescription'.tr(),
                    border: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    // Same inset as the title above and the content below, so
                    // the three fields read as one block of text.
                    contentPadding: _fieldPadding,
                  ),
                  style: theme.textTheme.bodyMedium,
                  minLines: 1,
                  maxLines: 3,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),

              // Content field
              BlockContentEditor(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                state: state,
                enabled: enabled && state.currentPublisher.value != null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
