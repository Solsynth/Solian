import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/draft_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ComposeToolbar extends HookConsumerWidget {
  final ComposeState state;
  final SnPost? originalPost;

  const ComposeToolbar({super.key, required this.state, this.originalPost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void pickPhotoMedia() {
      ComposeLogic.pickPhotoMedia(ref, state);
    }

    void pickVideoMedia() {
      ComposeLogic.pickVideoMedia(ref, state);
    }

    void linkAttachment() {
      ComposeLogic.linkAttachment(ref, state, context);
    }

    void saveDraft() {
      ComposeLogic.saveDraft(ref, state);
    }

    void showDraftManager() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => DraftManagerSheet(
              onDraftSelected: (draftId) {
                final draft = ref.read(composeStorageNotifierProvider)[draftId];
                if (draft != null) {
                  state.titleController.text = draft.title ?? '';
                  state.descriptionController.text = draft.description ?? '';
                  state.contentController.text = draft.content ?? '';
                  state.visibility.value = draft.visibility;
                }
              },
            ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 4,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              IconButton(
                onPressed: pickPhotoMedia,
                tooltip: 'addPhoto'.tr(),
                icon: const Icon(Symbols.add_a_photo),
                color: colorScheme.primary,
              ),
              IconButton(
                onPressed: pickVideoMedia,
                tooltip: 'addVideo'.tr(),
                icon: const Icon(Symbols.videocam),
                color: colorScheme.primary,
              ),
              IconButton(
                onPressed: linkAttachment,
                icon: const Icon(Symbols.attach_file),
                tooltip: 'linkAttachment'.tr(),
                color: colorScheme.primary,
              ),
              const Spacer(),
              if (originalPost == null && state.isEmpty)
                IconButton(
                  icon: const Icon(Symbols.draft),
                  color: colorScheme.primary,
                  onPressed: showDraftManager,
                  tooltip: 'drafts'.tr(),
                )
              else if (originalPost == null)
                IconButton(
                  icon: const Icon(Symbols.save),
                  color: colorScheme.primary,
                  onPressed: saveDraft,
                  onLongPress: showDraftManager,
                  tooltip: 'saveDraft'.tr(),
                ),
            ],
          ).padding(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            horizontal: 16,
            top: 8,
          ),
        ),
      ),
    );
  }
}
