import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/post/compose_embed_sheet.dart';
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

    void pickGeneralFile() {
      ComposeLogic.pickGeneralFile(ref, state);
    }

    void addAudio() {
      ComposeLogic.recordAudioMedia(ref, state, context);
    }

    void linkAttachment() {
      ComposeLogic.linkAttachment(ref, state, context);
    }

    void saveDraft() {
      ComposeLogic.saveDraftManually(ref, state, context);
    }

    void pickPoll() {
      ComposeLogic.pickPoll(ref, state, context);
    }

    void showEmbedSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ComposeEmbedSheet(state: state),
      );
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
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                        onPressed: addAudio,
                        tooltip: 'addAudio'.tr(),
                        icon: const Icon(Symbols.mic),
                        color: colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: pickGeneralFile,
                        tooltip: 'uploadFile'.tr(),
                        icon: const Icon(Symbols.file_upload),
                        color: colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: linkAttachment,
                        icon: const Icon(Symbols.attach_file),
                        tooltip: 'linkAttachment'.tr(),
                        color: colorScheme.primary,
                      ),
                      // Poll button with visual state when a poll is linked
                      ListenableBuilder(
                        listenable: state.pollId,
                        builder: (context, _) {
                          return IconButton(
                            onPressed: pickPoll,
                            icon: const Icon(Symbols.how_to_vote),
                            tooltip: 'poll'.tr(),
                            color: colorScheme.primary,
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                state.pollId.value != null
                                    ? colorScheme.primary.withOpacity(0.15)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                      // Embed button with visual state when embed is present
                      ListenableBuilder(
                        listenable: state.embedView,
                        builder: (context, _) {
                          return IconButton(
                            onPressed: showEmbedSheet,
                            icon: const Icon(Symbols.iframe),
                            tooltip: 'embedView'.tr(),
                            color: colorScheme.primary,
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                state.embedView.value != null
                                    ? colorScheme.primary.withOpacity(0.15)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
