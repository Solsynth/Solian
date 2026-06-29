import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

const _kStickerExpandHeight = 280.0;

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
              ComposeLogic.applyDraftToState(state, draft);
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
      UploadMenuItemData(Symbols.attach_file, 'linkAttachment', linkAttachment),
    ];

    final isStickerExpanded = useState(false);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.25),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: child,
                ),
              ),
            );
          },
          child: isStickerExpanded.value
              ? Container(
                  key: const ValueKey('sticker-picker'),
                  height: _kStickerExpandHeight,
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: StickerPickerEmbedded(
                      height: _kStickerExpandHeight,
                      onPick: (pack, sticker) {
                        insertPlaceholder(':${pack.prefix}+${sticker.slug}:');
                      },
                      onLongPress: (pack, sticker) {
                        insertPlaceholder(':${pack.prefix}+${sticker.slug}:');
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('sticker-collapsed')),
        ),
        Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surfaceContainer,
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
                          UploadMenu(items: uploadMenuItems),
                          IconButton(
                            onPressed: () {
                              isStickerExpanded.value = !isStickerExpanded.value;
                            },
                            icon: const Icon(Symbols.sticky_note_2),
                            color: colorScheme.primary,
                            tooltip: 'stickers'.tr(),
                          ),
                          // Poll
                          ListenableBuilder(
                            listenable: state.embeds,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickPoll,
                                icon: const Icon(Symbols.how_to_vote),
                                tooltip: 'poll'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.embeds.value.any((e) => e['type'] == 'poll')
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Location
                          ListenableBuilder(
                            listenable: state.embeds,
                            builder: (context, _) {
                              final hasLocation = state.embeds.value.any((e) => e['type'] == 'location');
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
                          // Fund
                          ListenableBuilder(
                            listenable: state.embeds,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickFund,
                                icon: const Icon(Symbols.account_balance_wallet),
                                tooltip: 'fund'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.embeds.value.any((e) => e['type'] == 'fund')
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Meet
                          ListenableBuilder(
                            listenable: state.embeds,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickMeet,
                                icon: const Icon(Symbols.groups),
                                tooltip: 'meet'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.embeds.value.any((e) => e['type'] == 'meet')
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Calendar event
                          ListenableBuilder(
                            listenable: state.embeds,
                            builder: (context, _) {
                              return IconButton(
                                onPressed: pickCalendarEvent,
                                icon: const Icon(Symbols.calendar_month),
                                tooltip: 'calendarEvent'.tr(),
                                color: colorScheme.primary,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    state.embeds.value.any((e) => e['type'] == 'calendar_event')
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Embed
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
        ),
      ],
    );
  }
}
