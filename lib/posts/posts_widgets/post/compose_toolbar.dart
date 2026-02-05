import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/core/widgets/shared/upload_menu.dart';
import 'package:island/posts/posts_widgets/post/compose_embed_sheet.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';
import 'package:island/posts/posts_widgets/post/draft_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ComposeToolbar extends HookConsumerWidget {
  final ComposeState state;
  final SnPost? originalPost;
  final bool useSafeArea;

  const ComposeToolbar({
    super.key,
    required this.state,
    this.originalPost,
    this.useSafeArea = false,
  });

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

    void pickFund() {
      ComposeLogic.pickFund(ref, state, context);
    }

    void showEmbedSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => ComposeEmbedSheet(state: state),
      );
    }

    void showDraftManager() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => DraftManagerSheet(
          onDraftSelected: (draftId) {
            final draft = ref.read(composeStorageProvider)[draftId];
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

    final uploadMenuItems = [
      UploadMenuItemData(Symbols.add_a_photo, 'addPhoto', pickPhotoMedia),
      UploadMenuItemData(Symbols.videocam, 'addVideo', pickVideoMedia),
      UploadMenuItemData(Symbols.mic, 'addAudio', addAudio),
      UploadMenuItemData(Symbols.file_upload, 'uploadFile', pickGeneralFile),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child:
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          UploadMenu(items: uploadMenuItems),
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
                          // Fund button with visual state when a fund is linked
                          ListenableBuilder(
                            listenable: state.fundId,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickFund,
                                icon: const Icon(
                                  Symbols.account_balance_wallet,
                                ),
                                tooltip: 'fund'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.fundId.value != null
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
