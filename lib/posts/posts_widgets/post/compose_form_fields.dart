import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/discovery/discovery_models/autocomplete_response.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/posts/posts_models/publisher.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';
import 'package:island/realms/realms_models/realm.dart';
import 'package:island/stickers/stickers_models/sticker.dart';
import 'package:island/discovery/discovery_service.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';

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
              TextField(
                controller: state.titleController,
                enabled: enabled && state.currentPublisher.value != null,
                decoration: InputDecoration(
                  hintText: 'postTitle'.tr(),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                style: theme.textTheme.titleMedium,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),

              // Description field
              TextField(
                controller: state.descriptionController,
                enabled: enabled && state.currentPublisher.value != null,
                decoration: InputDecoration(
                  hintText: 'postDescription'.tr(),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                ),
                style: theme.textTheme.bodyMedium,
                minLines: 1,
                maxLines: 3,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),

              // Content field
              TypeAheadField<AutocompleteSuggestion>(
                controller: state.contentController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    focusNode: focusNode,
                    controller: controller,
                    enabled: enabled && state.currentPublisher.value != null,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'postContent'.tr(),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    maxLines: null,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  );
                },
                suggestionsCallback: (pattern) async {
                  // Only trigger on @ or :
                  final atIndex = pattern.lastIndexOf('@');
                  final colonIndex = pattern.lastIndexOf(':');
                  final triggerIndex = atIndex > colonIndex
                      ? atIndex
                      : colonIndex;
                  if (triggerIndex == -1) return [];
                  final chopped = pattern.substring(triggerIndex);
                  if (chopped.contains(' ')) return [];
                  final service = ref.read(autocompleteServiceProvider);
                  try {
                    return await service.getGeneralSuggestions(chopped);
                  } catch (e) {
                    return [];
                  }
                },
                itemBuilder: (context, suggestion) {
                  String title = 'unknown'.tr();
                  Widget leading = Icon(Icons.help);
                  switch (suggestion.type) {
                    case 'user':
                      final user = SnAccount.fromJson(suggestion.data);
                      title = user.nick;
                      leading = ProfilePictureWidget(
                        file: user.profile.picture,
                        radius: 18,
                      );
                      break;
                    case 'chatroom':
                      final chatRoom = SnChatRoom.fromJson(suggestion.data);
                      title = chatRoom.name ?? 'Chat Room';
                      leading = ProfilePictureWidget(
                        file: chatRoom.picture,
                        radius: 18,
                      );
                      break;
                    case 'realm':
                      final realm = SnRealm.fromJson(suggestion.data);
                      title = realm.name;
                      leading = ProfilePictureWidget(
                        file: realm.picture,
                        radius: 18,
                      );
                      break;
                    case 'publisher':
                      final publisher = SnPublisher.fromJson(suggestion.data);
                      title = publisher.name;
                      leading = ProfilePictureWidget(
                        file: publisher.picture,
                        radius: 18,
                      );
                      break;
                    case 'sticker':
                      final sticker = SnSticker.fromJson(suggestion.data);
                      title = sticker.slug;
                      leading = ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CloudImageWidget(file: sticker.image),
                        ),
                      );
                      break;
                    default:
                  }
                  return ListTile(
                    leading: leading,
                    title: Text(title),
                    subtitle: Text(suggestion.keyword),
                    dense: true,
                  );
                },
                onSelected: (suggestion) {
                  final text = state.contentController.text;
                  final atIndex = text.lastIndexOf('@');
                  final colonIndex = text.lastIndexOf(':');
                  final triggerIndex = atIndex > colonIndex
                      ? atIndex
                      : colonIndex;
                  if (triggerIndex == -1) return;
                  final newText = text.replaceRange(
                    triggerIndex,
                    text.length,
                    suggestion.keyword,
                  );
                  state.contentController.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(
                      offset: triggerIndex + suggestion.keyword.length,
                    ),
                  );
                },
                direction: VerticalDirection.down,
                hideOnEmpty: true,
                hideOnLoading: true,
                debounceDuration: const Duration(milliseconds: 1000),
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
