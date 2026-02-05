import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/chat/chat_widgets/message_item.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/posts/posts_models/poll.dart';
import 'package:island/wallet/wallet_models/wallet.dart';
import 'package:island/chat/chat_pod/chat_subscribe.dart';
import 'package:island/data/message.dart';
import 'package:pasteboard/pasteboard.dart';

class RoomInputManager {
  final TextEditingController messageController;
  final List<UniversalFile> attachments;
  final Map<String, Map<int, double?>> attachmentProgress;
  final SnChatMessage? messageEditingTo;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnPoll? selectedPoll;
  final SnWalletFund? selectedFund;
  final void Function(List<UniversalFile>) updateAttachments;
  final void Function(String, double?) updateAttachmentProgress;
  final void Function(SnChatMessage?) setEditingTo;
  final void Function(SnChatMessage?) setReplyingTo;
  final void Function(SnChatMessage?) setForwardingTo;
  final void Function(SnPoll?) setPoll;
  final void Function(SnWalletFund?) setFund;
  final void Function() clear;
  final void Function() clearAttachmentsOnly;
  final Future<void> Function() handlePaste;
  final void Function(WidgetRef ref) sendMessage;
  final void Function(String action, LocalChatMessage message) onMessageAction;

  RoomInputManager({
    required this.messageController,
    required this.attachments,
    required this.attachmentProgress,
    this.messageEditingTo,
    this.messageReplyingTo,
    this.messageForwardingTo,
    this.selectedPoll,
    this.selectedFund,
    required this.updateAttachments,
    required this.updateAttachmentProgress,
    required this.setEditingTo,
    required this.setReplyingTo,
    required this.setForwardingTo,
    required this.setPoll,
    required this.setFund,
    required this.clear,
    required this.clearAttachmentsOnly,
    required this.handlePaste,
    required this.sendMessage,
    required this.onMessageAction,
  });
}

RoomInputManager useRoomInputManager(WidgetRef ref, String roomId) {
  final messageController = useTextEditingController();
  final attachments = useState<List<UniversalFile>>([]);
  final attachmentProgress = useState<Map<String, Map<int, double?>>>({});
  final messageEditingTo = useState<SnChatMessage?>(null);
  final messageReplyingTo = useState<SnChatMessage?>(null);
  final messageForwardingTo = useState<SnChatMessage?>(null);
  final selectedPoll = useState<SnPoll?>(null);
  final selectedFund = useState<SnWalletFund?>(null);

  final chatSubscribeNotifier = ref.read(
    chatSubscribeProvider(roomId).notifier,
  );
  final messagesNotifier = ref.read(messagesProvider(roomId).notifier);

  void updateAttachments(List<UniversalFile> newAttachments) {
    attachments.value = newAttachments;
  }

  void updateAttachmentProgress(String messageId, double? progress) {
    attachmentProgress.value = {
      ...attachmentProgress.value,
      messageId: {0: progress},
    };
  }

  void setEditingTo(SnChatMessage? message) {
    messageEditingTo.value = message;
    if (message != null) {
      messageController.text = message.content ?? '';
      attachments.value = message.attachments
          .map((e) => UniversalFile.fromAttachment(e))
          .toList();
    }
  }

  void setReplyingTo(SnChatMessage? message) {
    messageReplyingTo.value = message;
  }

  void setForwardingTo(SnChatMessage? message) {
    messageForwardingTo.value = message;
  }

  void setPoll(SnPoll? poll) {
    selectedPoll.value = poll;
  }

  void setFund(SnWalletFund? fund) {
    selectedFund.value = fund;
  }

  void clear() {
    messageController.clear();
    messageEditingTo.value = null;
    messageReplyingTo.value = null;
    messageForwardingTo.value = null;
    selectedPoll.value = null;
    selectedFund.value = null;
    attachments.value = [];
  }

  void clearAttachmentsOnly() {
    messageController.clear();
    attachments.value = [];
  }

  void onTextChange() {
    if (messageController.text.isNotEmpty) {
      chatSubscribeNotifier.sendTypingStatus();
    }
  }

  useEffect(() {
    messageController.addListener(onTextChange);
    return () => messageController.removeListener(onTextChange);
  }, [messageController]);

  Future<void> handlePaste() async {
    final image = await Pasteboard.image;
    if (image != null) {
      final newAttachments = [
        ...attachments.value,
        UniversalFile(
          displayName: 'image.jpeg',
          data: XFile.fromData(
            image,
            mimeType: "image/jpeg",
            name: 'image.jpeg',
          ),
          type: UniversalFileType.image,
        ),
      ];
      attachments.value = newAttachments;
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

  void onMessageAction(String action, LocalChatMessage message) {
    switch (action) {
      case MessageItemAction.delete:
        messagesNotifier.deleteMessage(message.id);
      case MessageItemAction.edit:
        setEditingTo(message.toRemoteMessage());
      case MessageItemAction.forward:
        setForwardingTo(message.toRemoteMessage());
      case MessageItemAction.reply:
        setReplyingTo(message.toRemoteMessage());
      case MessageItemAction.resend:
        messagesNotifier.retryMessage(message.id);
    }
  }

  void sendMessage(WidgetRef ref) {
    if (messageController.text.trim().isNotEmpty ||
        attachments.value.isNotEmpty ||
        selectedPoll.value != null ||
        selectedFund.value != null) {
      messagesNotifier.sendMessage(
        ref,
        messageController.text.trim(),
        attachments.value,
        poll: selectedPoll.value,
        fund: selectedFund.value,
        editingTo: messageEditingTo.value,
        forwardingTo: messageForwardingTo.value,
        replyingTo: messageReplyingTo.value,
        onProgress: (messageId, progress) {
          attachmentProgress.value = {
            ...attachmentProgress.value,
            messageId: progress,
          };
        },
      );
      clear();
    }
  }

  return RoomInputManager(
    messageController: messageController,
    attachments: attachments.value,
    attachmentProgress: attachmentProgress.value,
    messageEditingTo: messageEditingTo.value,
    messageReplyingTo: messageReplyingTo.value,
    messageForwardingTo: messageForwardingTo.value,
    selectedPoll: selectedPoll.value,
    selectedFund: selectedFund.value,
    updateAttachments: updateAttachments,
    updateAttachmentProgress: updateAttachmentProgress,
    setEditingTo: setEditingTo,
    setReplyingTo: setReplyingTo,
    setForwardingTo: setForwardingTo,
    setPoll: setPoll,
    setFund: setFund,
    clear: clear,
    clearAttachmentsOnly: clearAttachmentsOnly,
    handlePaste: handlePaste,
    sendMessage: sendMessage,
    onMessageAction: onMessageAction,
  );
}
