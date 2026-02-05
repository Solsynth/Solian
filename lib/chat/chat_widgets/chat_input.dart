import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:island/accounts/accounts_models/account.dart";
import "package:island/discovery/discovery_models/autocomplete_response.dart";
import "package:island/chat/chat_models/chat.dart";
import "package:island/drive/drive_models/file.dart";
import "package:island/posts/posts_models/poll.dart";
import "package:island/posts/posts_models/publisher.dart";
import "package:island/posts/posts_widgets/post/compose_fund.dart";
import "package:island/posts/posts_widgets/post/compose_poll.dart";
import "package:island/stickers/stickers_widgets/stickers/sticker_picker.dart";
import "package:island/wallet/wallet_models/wallet.dart";
import "package:island/realms/realms_models/realm.dart";
import "package:island/stickers/stickers_models/sticker.dart";
import "package:island/core/config.dart";
import "package:island/accounts/accounts_pod.dart";
import "package:island/discovery/discovery_service.dart";
import "package:island/core/services/responsive.dart";
import "package:island/core/widgets/content/attachment_preview.dart";
import "package:island/drive/drive_widgets/cloud_files.dart";
import "package:island/core/widgets/shared/upload_menu.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:pasteboard/pasteboard.dart";
import "package:styled_widget/styled_widget.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:island/chat/chat_pod/chat_subscribe.dart";

void _insertPlaceholder(TextEditingController controller, String placeholder) {
  final text = controller.text;
  final selection = controller.selection;
  final start = selection.start >= 0 ? selection.start : text.length;
  final end = selection.end >= 0 ? selection.end : text.length;
  final newText = text.replaceRange(start, end, placeholder);
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + placeholder.length),
  );
}

const kInputDrawerExpandedHeight = 180.0;

const kExpandedSectionTabHeight = 32.0;

class _ExpandedSection extends StatelessWidget {
  final TextEditingController messageController;
  final SnPoll? selectedPoll;
  final Function(SnPoll?) onPollSelected;
  final SnWalletFund? selectedFund;
  final Function(SnWalletFund?) onFundSelected;

  const _ExpandedSection({
    required this.messageController,
    this.selectedPoll,
    required this.onPollSelected,
    this.selectedFund,
    required this.onFundSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('expanded'),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      margin: const EdgeInsets.only(top: 8, bottom: 3),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(kExpandedSectionTabHeight),
                child: TabBar(
                  splashBorderRadius: const BorderRadius.all(
                    Radius.circular(40),
                  ),
                  tabs: [
                    Tab(
                      text: 'features'.tr(),
                      height: kExpandedSectionTabHeight,
                    ),
                    Tab(
                      text: 'stickers'.tr(),
                      height: kExpandedSectionTabHeight,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: kInputDrawerExpandedHeight,
                child: TabBarView(
                  children: [
                    SizedBox(
                      height:
                          kInputDrawerExpandedHeight -
                          48, // subtract tab bar height approx
                      child: GridView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 120,
                              childAspectRatio: 1, // 1:1 aspect ratio
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        children: [
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            onTap: () async {
                              final poll = await showModalBottomSheet<SnPoll>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => const ComposePollSheet(),
                              );
                              if (poll != null) {
                                onPollSelected(poll);
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.poll),
                                  const Gap(4),
                                  Text(
                                    'Poll',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            onTap: () async {
                              final fund =
                                  await showModalBottomSheet<SnWalletFund>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        const ComposeFundSheet(),
                                  );
                              if (fund != null) {
                                onFundSelected(fund);
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.currency_exchange),
                                  const Gap(4),
                                  Text(
                                    'fund'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StickerPickerEmbedded(
                      height: kInputDrawerExpandedHeight,
                      onPick: (placeholder) =>
                          _insertPlaceholder(messageController, placeholder),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatInput extends HookConsumerWidget {
  final TextEditingController messageController;
  final SnChatRoom chatRoom;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final Function(bool isPhoto) onPickFile;
  final VoidCallback onPickAudio;
  final VoidCallback onPickGeneralFile;
  final VoidCallback? onLinkAttachment;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnChatMessage? messageEditingTo;
  final List<UniversalFile> attachments;
  final Function(int) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double?>> attachmentProgress;
  final SnPoll? selectedPoll;
  final Function(SnPoll?) onPollSelected;
  final SnWalletFund? selectedFund;
  final Function(SnWalletFund?) onFundSelected;

  const ChatInput({
    super.key,
    required this.messageController,
    required this.chatRoom,
    required this.onSend,
    required this.onClear,
    required this.onPickFile,
    required this.onPickAudio,
    required this.onPickGeneralFile,
    this.onLinkAttachment,
    required this.messageReplyingTo,
    required this.messageForwardingTo,
    required this.messageEditingTo,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
    this.selectedPoll,
    required this.onPollSelected,
    this.selectedFund,
    required this.onFundSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputFocusNode = useFocusNode();
    final chatSubscribe = ref.watch(chatSubscribeProvider(chatRoom.id));
    final isExpanded = useState(false);

    void send() {
      inputFocusNode.requestFocus();
      if (isExpanded.value) isExpanded.value = false;
      onSend.call();
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
      final image = await Pasteboard.image;
      if (image != null) {
        onAttachmentsChanged([
          ...attachments,
          UniversalFile(
            displayName: 'image.jpeg',
            data: XFile.fromData(
              image,
              mimeType: "image/jpeg",
              name: 'image.jpeg',
            ),
            type: UniversalFileType.image,
          ),
        ]);
        return;
      }

      final textData = await Clipboard.getData(Clipboard.kTextPlain);
      if (textData != null && textData.text != null) {
        final text = messageController.text;
        final selection = messageController.selection;
        final start = selection.start >= 0 ? selection.start : text.length;
        final end = selection.end >= 0 ? selection.end : text.length;
        final newText = text.replaceRange(start, end, textData.text!);
        messageController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: start + textData.text!.length,
          ),
        );
      }
    }

    final settings = ref.watch(appSettingsProvider);

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

      final enterToSend = settings.enterToSend;
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

    final userInfo = ref.watch(userInfoProvider);

    List<SnChatMember> getValidMembers(List<SnChatMember> members) {
      return members
          .where((member) => member.accountId != userInfo.value?.id)
          .toList();
    }

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
                    position:
                        Tween<Offset>(
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
                child: chatSubscribe.isNotEmpty
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
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
                child: attachments.isNotEmpty
                    ? SizedBox(
                        key: ValueKey('attachments-${attachments.length}'),
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
                                progress:
                                    attachmentProgress['chat-upload']?[idx],
                                isUploading:
                                    attachmentProgress['chat-upload']
                                        ?.containsKey(idx) ??
                                    false,
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
                      ).padding(vertical: 12)
                    : const SizedBox.shrink(key: ValueKey('no-attachments')),
              ),
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
                child: selectedPoll != null
                    ? Container(
                        key: const ValueKey('selected-poll'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.how_to_vote,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                selectedPoll!.title ?? 'Poll',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => onPollSelected(null),
                                tooltip: 'clear'.tr(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-selected-poll')),
              ),
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
                child: selectedFund != null
                    ? Container(
                        key: const ValueKey('selected-fund'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.currency_exchange,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${selectedFund!.totalAmount.toStringAsFixed(2)} ${selectedFund!.currency}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (selectedFund!.message != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        selectedFund!.message!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 10,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => onFundSelected(null),
                                tooltip: 'clear'.tr(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-selected-fund')),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
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
                child:
                    (messageReplyingTo != null ||
                        messageForwardingTo != null ||
                        messageEditingTo != null)
                    ? Container(
                        key: ValueKey(
                          messageReplyingTo?.id ??
                              messageForwardingTo?.id ??
                              messageEditingTo?.id ??
                              'action',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  messageReplyingTo != null
                                      ? Symbols.reply
                                      : messageForwardingTo != null
                                      ? Symbols.forward
                                      : Symbols.edit,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    messageReplyingTo != null
                                        ? 'chatReplyingTo'.tr(
                                            args: [
                                              messageReplyingTo
                                                      ?.sender
                                                      .account
                                                      .nick ??
                                                  'unknown'.tr(),
                                            ],
                                          )
                                        : messageForwardingTo != null
                                        ? 'chatForwarding'.tr()
                                        : 'chatEditing'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: onClear,
                                    tooltip: 'clear'.tr(),
                                  ),
                                ),
                              ],
                            ),
                            if (messageReplyingTo != null ||
                                messageForwardingTo != null ||
                                messageEditingTo != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  left: 26,
                                ),
                                child: Text(
                                  (messageReplyingTo ??
                                              messageForwardingTo ??
                                              messageEditingTo)
                                          ?.content ??
                                      'chatNoContent'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-action')),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: isExpanded.value
                            ? 'collapse'.tr()
                            : 'more'.tr(),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: isExpanded.value
                              ? const Icon(
                                  Symbols.close,
                                  key: ValueKey('close'),
                                )
                              : const Icon(Symbols.add, key: ValueKey('add')),
                        ),
                        onPressed: () {
                          isExpanded.value = !isExpanded.value;
                        },
                      ),
                      UploadMenu(
                        items: [
                          UploadMenuItemData(
                            Symbols.add_a_photo,
                            'addPhoto',
                            () => onPickFile(true),
                          ),
                          UploadMenuItemData(
                            Symbols.videocam,
                            'addVideo',
                            () => onPickFile(false),
                          ),
                          UploadMenuItemData(
                            Symbols.mic,
                            'addAudio',
                            onPickAudio,
                          ),
                          UploadMenuItemData(
                            Symbols.file_upload,
                            'uploadFile',
                            onPickGeneralFile,
                          ),
                          if (onLinkAttachment != null)
                            UploadMenuItemData(
                              Symbols.attach_file,
                              'linkAttachment',
                              onLinkAttachment!,
                            ),
                        ],
                        iconColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TypeAheadField<AutocompleteSuggestion>(
                      controller: messageController,
                      focusNode: inputFocusNode,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          focusNode: focusNode,
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintMaxLines: 1,
                            hintText:
                                (chatRoom.type == 1 && chatRoom.name == null)
                                ? 'chatDirectMessageHint'.tr(
                                    args: [
                                      getValidMembers(
                                        chatRoom.members!,
                                      ).map((e) => e.account.nick).join(', '),
                                    ],
                                  )
                                : 'chatMessageHint'.tr(args: [chatRoom.name!]),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            counterText: messageController.text.length > 1024
                                ? '${messageController.text.length}/4096'
                                : null,
                          ),
                          maxLines: 5,
                          minLines: 1,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          textInputAction: settings.enterToSend
                              ? TextInputAction.send
                              : null,
                          onSubmitted: settings.enterToSend
                              ? (_) => send()
                              : null,
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
                          return await service.getSuggestions(
                            chatRoom.id,
                            chopped,
                          );
                        } catch (e) {
                          return [];
                        }
                      },
                      itemBuilder: (context, suggestion) {
                        String title = 'unknown'.tr();
                        Widget leading = Icon(Symbols.help);
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
                            final chatRoom = SnChatRoom.fromJson(
                              suggestion.data,
                            );
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
                            final publisher = SnPublisher.fromJson(
                              suggestion.data,
                            );
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
                        final text = messageController.text;
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
                        messageController.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                            offset: triggerIndex + suggestion.keyword.length,
                          ),
                        );
                      },
                      direction: VerticalDirection.up,
                      hideOnEmpty: true,
                      hideOnLoading: true,
                      debounceDuration: const Duration(milliseconds: 1000),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: send,
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
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
                child: isExpanded.value
                    ? _ExpandedSection(
                        messageController: messageController,
                        selectedPoll: selectedPoll,
                        onPollSelected: onPollSelected,
                        selectedFund: selectedFund,
                        onFundSelected: onFundSelected,
                      )
                    : const SizedBox.shrink(key: ValueKey('collapsed')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
