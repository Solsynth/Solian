import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:island/models/chat.dart";
import "package:island/models/file.dart";
import "package:island/pods/config.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/content/attachment_preview.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:pasteboard/pasteboard.dart";
import "package:styled_widget/styled_widget.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:island/widgets/stickers/picker.dart";
import "package:island/pods/chat/chat_subscribe.dart";

class ChatInput extends HookConsumerWidget {
  final TextEditingController messageController;
  final SnChatRoom chatRoom;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final Function(bool isPhoto) onPickFile;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnChatMessage? messageEditingTo;
  final List<UniversalFile> attachments;
  final Function(int) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double>> attachmentProgress;

  const ChatInput({
    super.key,
    required this.messageController,
    required this.chatRoom,
    required this.onSend,
    required this.onClear,
    required this.onPickFile,
    required this.messageReplyingTo,
    required this.messageForwardingTo,
    required this.messageEditingTo,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputFocusNode = useFocusNode();
    final chatSubscribe = ref.watch(chatSubscribeNotifierProvider(chatRoom.id));

    void send() {
      onSend.call();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inputFocusNode.requestFocus();
      });
    }

    void insertNewLine() {
      final text = messageController.text;
      final selection = messageController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      final newText = text.replaceRange(start, end, '\n');
      messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + 1),
      );
    }

    Future<void> handlePaste() async {
      final clipboard = await Pasteboard.image;
      if (clipboard == null) return;

      onAttachmentsChanged([
        ...attachments,
        UniversalFile(
          data: XFile.fromData(clipboard, mimeType: "image/jpeg"),
          type: UniversalFileType.image,
        ),
      ]);
    }

    inputFocusNode.onKeyEvent = (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
      final isModifierPressed =
          HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;

      if (isPaste && isModifierPressed) {
        handlePaste();
        return KeyEventResult.handled;
      }

      final enterToSend = ref.read(appSettingsNotifierProvider).enterToSend;
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;

      if (isEnter) {
        if (isModifierPressed) {
          insertNewLine();
          return KeyEventResult.handled;
        } else if (enterToSend) {
          send();
          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.ignored;
    };

    final double leftMargin = isWideScreen(context) ? 8 : 16;
    final double rightMargin = isWideScreen(context) ? leftMargin + 8 : 16;
    const double bottomMargin = 16;

    return Container(
      margin: EdgeInsets.only(
        left: leftMargin,
        right: rightMargin,
        bottom: bottomMargin,
      ),
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.fastEaseInToSlowEaseOut,
                switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child:
                    chatSubscribe.isNotEmpty
                        ? Container(
                          key: const ValueKey('typing-indicator'),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Symbols.more_horiz,
                                size: 16,
                              ).padding(horizontal: 8),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'typingHint'.plural(
                                    chatSubscribe.length,
                                    args: [
                                      chatSubscribe
                                          .map((x) => x.nick ?? x.account.nick)
                                          .join(', '),
                                    ],
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(
                          key: ValueKey('typing-indicator-none'),
                        ),
              ),
              if (attachments.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: attachments.length,
                    itemBuilder: (context, idx) {
                      return SizedBox(
                        width: 180,
                        child: AttachmentPreview(
                          isCompact: true,
                          item: attachments[idx],
                          progress: attachmentProgress['chat-upload']?[idx],
                          onRequestUpload: () => onUploadAttachment(idx),
                          onDelete: () => onDeleteAttachment(idx),
                          onUpdate: (value) {
                            attachments[idx] = value;
                            onAttachmentsChanged(attachments);
                          },
                          onMove: (delta) => onMoveAttachment(idx, delta),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const Gap(8),
                  ),
                ).padding(vertical: 12),
              if (messageReplyingTo != null ||
                  messageForwardingTo != null ||
                  messageEditingTo != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  margin: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        messageReplyingTo != null
                            ? Symbols.reply
                            : messageForwardingTo != null
                            ? Symbols.forward
                            : Symbols.edit,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          messageReplyingTo != null
                              ? 'Replying to ${messageReplyingTo?.sender.account.nick}'
                              : messageForwardingTo != null
                              ? 'Forwarding message'
                              : 'Editing message',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: InkWell(
                          onTap: onClear,
                          child: const Icon(Icons.close, size: 20).center(),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'stickers'.tr(),
                        icon: const Icon(Symbols.add_reaction),
                        onPressed: () {
                          final size = MediaQuery.of(context).size;
                          showStickerPickerPopover(
                            context,
                            Offset(
                              20,
                              size.height -
                                  480 -
                                  MediaQuery.of(context).padding.bottom,
                            ),
                            onPick: (placeholder) {
                              // Insert placeholder at current cursor position
                              final text = messageController.text;
                              final selection = messageController.selection;
                              final start =
                                  selection.start >= 0
                                      ? selection.start
                                      : text.length;
                              final end =
                                  selection.end >= 0
                                      ? selection.end
                                      : text.length;
                              final newText = text.replaceRange(
                                start,
                                end,
                                placeholder,
                              );
                              messageController.value = TextEditingValue(
                                text: newText,
                                selection: TextSelection.collapsed(
                                  offset: start + placeholder.length,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      PopupMenuButton(
                        icon: const Icon(Symbols.photo_library),
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                onTap: () => onPickFile(true),
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    const Icon(Symbols.photo),
                                    Text('addPhoto').tr(),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () => onPickFile(false),
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    const Icon(Symbols.video_call),
                                    Text('addVideo').tr(),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: inputFocusNode,
                      controller: messageController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText:
                            (chatRoom.type == 1 && chatRoom.name == null)
                                ? 'chatDirectMessageHint'.tr(
                                  args: [
                                    chatRoom.members!
                                        .map((e) => e.account.nick)
                                        .join(', '),
                                  ],
                                )
                                : 'chatMessageHint'.tr(args: [chatRoom.name!]),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        counterText:
                            messageController.text.length > 1024
                                ? '${messageController.text.length}/4096'
                                : null,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: send,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
