import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/drive/widgets/upload_menu.dart';
import 'package:island/posts/widgets/compose/compose_embed_sheet.dart';

import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/draft_manager.dart';
import 'package:island/stickers/widgets/stickers/sticker_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ComposeToolbar extends HookConsumerWidget {
  final ComposeState state;
  final SnPost? originalPost;
  final bool useSafeArea;
  final VoidCallback? onAttachmentAdded;

  const ComposeToolbar({
    super.key,
    required this.state,
    this.originalPost,
    this.useSafeArea = false,
    this.onAttachmentAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void insertPlaceholder(String placeholder) {
      final text = state.contentController.text;
      final selection = state.contentController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      final newText = text.replaceRange(start, end, placeholder);
      state.contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + placeholder.length),
      );
    }

    void showStickerPicker() {
      final buttonContext = context;
      final box = buttonContext.findRenderObject() as RenderBox?;
      final rawOffset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
      final screenHeight = MediaQuery.of(context).size.height;
      const popoverHeight = 480.0;
      final offset = Offset(
        rawOffset.dx,
        rawOffset.dy + popoverHeight > screenHeight
            ? (rawOffset.dy - popoverHeight - 16).clamp(16.0, screenHeight)
            : rawOffset.dy,
      );

      showStickerPickerPopover(
        context,
        offset,
        onPick: (pack, sticker) {
          insertPlaceholder(':${pack.prefix}+${sticker.slug}:');
        },
        onLongPress: (pack, sticker) {
          insertPlaceholder(':${pack.prefix}+${sticker.slug}:');
        },
      );
    }

    void pickPhotoMedia() async {
      final oldCount = state.attachments.value.length;
      await ComposeLogic.pickPhotoMedia(ref, state);
      if (state.attachments.value.length > oldCount) {
        onAttachmentAdded?.call();
      }
    }

    void pickVideoMedia() async {
      final oldCount = state.attachments.value.length;
      await ComposeLogic.pickVideoMedia(ref, state);
      if (state.attachments.value.length > oldCount) {
        onAttachmentAdded?.call();
      }
    }

    void pickGeneralFile() async {
      final oldCount = state.attachments.value.length;
      await ComposeLogic.pickGeneralFile(ref, state);
      if (state.attachments.value.length > oldCount) {
        onAttachmentAdded?.call();
      }
    }

    void addAudio() async {
      final oldCount = state.attachments.value.length;
      await ComposeLogic.recordAudioMedia(ref, state, context);
      if (state.attachments.value.length > oldCount) {
        onAttachmentAdded?.call();
      }
    }

    void linkAttachment() async {
      final oldCount = state.attachments.value.length;
      await ComposeLogic.linkAttachment(ref, state, context);
      if (state.attachments.value.length > oldCount) {
        onAttachmentAdded?.call();
      }
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

    void pickLocation() {
      ComposeLogic.pickLocation(ref, state, context);
    }

    void pickMeet() {
      ComposeLogic.pickMeet(ref, state, context);
    }

    void pickCalendarEvent() {
      ComposeLogic.pickCalendarEvent(ref, state, context);
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
              state.cloudDraftId.value = draft.draftedAt != null
                  ? draft.id
                  : null;
              state.titleController.text = draft.title ?? '';
              state.descriptionController.text = draft.description ?? '';
              state.contentController.text = draft.content ?? '';
              state.visibility.value = draft.visibility;
              state.attachments.value = draft.attachments
                  .map((e) => UniversalFile.fromAttachment(e))
                  .toList();
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
                            onPressed: showStickerPicker,
                            icon: const Icon(Symbols.sticky_note_2),
                            tooltip: 'stickers'.tr(),
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

                          // Location button with visual state when location is set
                          ListenableBuilder(
                            listenable: Listenable.merge([
                              state.locationName,
                              state.locationAddress,
                              state.locationWkt,
                            ]),
                            builder: (context, _) {
                              final hasLocation =
                                  state.locationName.value != null ||
                                  state.locationAddress.value != null ||
                                  state.locationWkt.value != null;
                              return IconButton(
                                onPressed: pickLocation,
                                icon: const Icon(Symbols.location_on),
                                tooltip: 'location'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    hasLocation
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Meet button with visual state when a meet is linked
                          ListenableBuilder(
                            listenable: state.meetId,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickMeet,
                                icon: const Icon(Symbols.groups),
                                tooltip: 'meet'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.meetId.value != null
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Calendar event button with visual state when linked
                          ListenableBuilder(
                            listenable: state.calendarEventId,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickCalendarEvent,
                                icon: const Icon(Symbols.calendar_month),
                                tooltip: 'calendarEvent'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.calendarEventId.value != null
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
