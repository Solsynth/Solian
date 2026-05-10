import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/posts/widgets/compose/compose_attachments.dart';
import 'package:island/posts/widgets/compose/compose_form_fields.dart';
import 'package:island/posts/widgets/compose/compose_info_banner.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/posts/widgets/compose/compose_toolbar.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/stickers/widgets/stickers/sticker_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A dialog-compatible card widget for post composition.
/// This extracts the core compose functionality from PostComposeScreen
/// and adapts it for use within dialogs or other constrained layouts.
class PostComposeCard extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final VoidCallback? onCancel;
  final Function()? onSubmit;
  final Function(ComposeState)? onStateChanged;
  final bool isContained;
  final bool showHeader;
  final ComposeState? providedState;

  const PostComposeCard({
    super.key,
    this.originalPost,
    this.initialState,
    this.onCancel,
    this.onSubmit,
    this.onStateChanged,
    this.isContained = false,
    this.showHeader = true,
    this.providedState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted = useState(false);

    final repliedPost = initialState?.replyingTo ?? originalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;

    final theme = Theme.of(context);

    // Create compose state
    final ComposeState composeState =
        providedState ??
        useMemoized(
          () => ComposeLogic.createState(
            originalPost: originalPost,
            forwardedPost: forwardedPost,
            repliedPost: repliedPost,
            cloudDraftId: initialState?.cloudDraftId,
            postType: 0,
          ),
          [
            originalPost,
            forwardedPost,
            repliedPost,
            initialState?.cloudDraftId,
          ],
        );

    void insertPlaceholder(String placeholder) {
      final text = composeState.contentController.text;
      final selection = composeState.contentController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      final newText = text.replaceRange(start, end, placeholder);
      composeState.contentController.value = TextEditingValue(
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

    // Add a listener to the entire state to trigger rebuilds
    final stateNotifier = useMemoized(
      () => Listenable.merge([
        composeState.titleController,
        composeState.descriptionController,
        composeState.contentController,
        composeState.visibility,
        composeState.attachments,
        composeState.attachmentProgress,
        composeState.currentPublisher,
        composeState.submitting,
      ]),
      [composeState],
    );
    useListenable(stateNotifier);

    // Notify parent of state changes
    useEffect(() {
      onStateChanged?.call(composeState);
      return null;
    }, [composeState]);

    // Use shared state management utilities
    ComposeStateUtils.usePublisherInitialization(ref, composeState);
    if (providedState == null) {
      ComposeStateUtils.useInitialStateLoader(composeState, initialState);
    }

    // Dispose state when widget is disposed
    useEffect(() {
      return () {
        if (providedState == null) {
          if (!submitted.value &&
              originalPost == null &&
              composeState.currentPublisher.value != null) {
            ComposeLogic.saveDraftWithoutUpload(ref, composeState);
          }
          ComposeLogic.dispose(composeState);
        }
      };
    }, []);

    // Helper methods
    void showSettingsSheet() {
      ComposeLogic.showSettingsSheet(context, composeState);
    }

    Future<void> performSubmit() async {
      await ComposeLogic.performSubmit(
        ref,
        composeState,
        context,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        onSuccess: () {
          // Mark as submitted
          submitted.value = true;

          // Delete draft after successful submission
          ref
              .read(composeStorageProvider.notifier)
              .deleteDraft(composeState.draftId);

          // Reset the form for new composition
          ComposeStateUtils.resetForm(composeState);

          onSubmit?.call();
        },
      );
    }

    final maxHeight = math.min(640.0, MediaQuery.of(context).size.height * 0.8);

    return Card(
      margin: EdgeInsets.zero,
      color: isContained ? Colors.transparent : null,
      elevation: isContained ? 0 : null,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            if (showHeader)
              Container(
                height: 65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Gap(4),
                    Text(
                      'postCompose'.tr(),
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Symbols.settings),
                      onPressed: showSettingsSheet,
                      tooltip: 'postSettings'.tr(),
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Symbols.sticky_note_2),
                      onPressed: showStickerPicker,
                      tooltip: 'stickers'.tr(),
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -2,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          (composeState.submitting.value ||
                              composeState.currentPublisher.value == null)
                          ? null
                          : performSubmit,
                      icon: composeState.submitting.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              originalPost != null
                                  ? Symbols.edit
                                  : Symbols.upload,
                            ),
                      tooltip: originalPost != null
                          ? 'postUpdate'.tr()
                          : 'postPublish'.tr(),
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -2,
                      ),
                    ),
                    if (onCancel != null)
                      IconButton(
                        icon: const Icon(Symbols.close),
                        onPressed: onCancel,
                        tooltip: 'cancel'.tr(),
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -2,
                        ),
                      ),
                  ],
                ),
              ),

            // Info banner (reply/forward)
            ComposeInfoBanner(
              originalPost: originalPost,
              replyingTo: repliedPost,
              forwardingTo: forwardedPost,
              onReferencePostTap: (context, post) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => SheetScaffold(
                    titleText: 'Post Preview',
                    child: SingleChildScrollView(child: PostItem(item: post)),
                  ),
                );
              },
            ),

            // Main content area
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is! KeyDownEvent) {
                    return;
                  }

                  final isModifierPressed =
                      HardwareKeyboard.instance.isMetaPressed ||
                      HardwareKeyboard.instance.isControlPressed;
                  final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

                  if (isSubmit &&
                      isModifierPressed &&
                      !composeState.submitting.value) {
                    performSubmit();
                    return;
                  }

                  ComposeLogic.handleKeyPress(
                    event,
                    composeState,
                    ref,
                    context,
                    originalPost: originalPost,
                    repliedPost: repliedPost,
                    forwardedPost: forwardedPost,
                  );
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Publisher profile picture
                        GestureDetector(
                          child: ProfilePictureWidget(
                            file: composeState.currentPublisher.value?.picture,
                            radius: 20,
                            borderRadius:
                                composeState.currentPublisher.value?.type == 0
                                ? null
                                : 12,
                            fallbackIcon:
                                composeState.currentPublisher.value == null
                                ? Symbols.question_mark
                                : null,
                          ),
                          onTap: () {
                            if (composeState.currentPublisher.value == null) {
                              // No publisher loaded, guide user to create one
                              if (isContained) {
                                Navigator.of(context).pop();
                              }
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                builder: (context) =>
                                    const NewPublisherScreen(),
                              ).then((value) {
                                if (value != null) {
                                  composeState.currentPublisher.value =
                                      value as SnPublisher;
                                  ref.invalidate(publishersManagedProvider);
                                }
                              });
                            } else {
                              // Show modal to select from existing publishers
                              showModalBottomSheet(
                                isScrollControlled: true,
                                useRootNavigator: true,
                                context: context,
                                builder: (context) => const PublisherModal(),
                              ).then((value) {
                                if (value != null) {
                                  composeState.currentPublisher.value = value;
                                }
                              });
                            }
                          },
                        ).padding(top: 8),

                        // Post content form
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ComposeFormFields(
                                state: composeState,
                                showPublisherAvatar: false,
                                onPublisherTap: () {
                                  if (composeState.currentPublisher.value ==
                                      null) {
                                    // No publisher loaded, guide user to create one
                                    if (isContained) {
                                      Navigator.of(context).pop();
                                    }
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      builder: (context) =>
                                          const NewPublisherScreen(),
                                    ).then((value) {
                                      if (value != null) {
                                        composeState.currentPublisher.value =
                                            value as SnPublisher;
                                        ref.invalidate(
                                          publishersManagedProvider,
                                        );
                                      }
                                    });
                                  } else {
                                    // Show modal to select from existing publishers
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      context: context,
                                      builder: (context) =>
                                          const PublisherModal(),
                                    ).then((value) {
                                      if (value != null) {
                                        composeState.currentPublisher.value =
                                            value;
                                      }
                                    });
                                  }
                                },
                              ),
                              const Gap(8),
                              ComposeAttachments(
                                state: composeState,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom toolbar
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: ComposeToolbar(
                state: composeState,
                originalPost: originalPost,
                useSafeArea: isContained,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
