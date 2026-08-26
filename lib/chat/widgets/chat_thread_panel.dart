import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/chat_input.dart';
import 'package:island/chat/widgets/chat_link_attachments.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/core/network.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/attachment_uploader.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Sidebar/sheet content for viewing a message thread and replying inside it.
///
/// Renders the thread root + flattened replies, plus a [ChatInput] composer
/// with its OWN text controller and attachment state (independent from the
/// main room composer). Sending a message targets the thread root as a
/// `replied_message_id`, so the server places it inside this thread.
class ChatThreadPanel extends ConsumerStatefulWidget {
  final String roomId;
  final SnChatRoom chatRoom;
  final SnChatMessage root;
  final void Function(String messageId) onJump;
  final VoidCallback? onClose;

  const ChatThreadPanel({
    super.key,
    required this.roomId,
    required this.chatRoom,
    required this.root,
    required this.onJump,
    this.onClose,
  });

  @override
  ConsumerState<ChatThreadPanel> createState() => _ChatThreadPanelState();
}

class _ChatThreadPanelState extends ConsumerState<ChatThreadPanel> {
  final _controller = TextEditingController();
  final List<UniversalFile> _attachments = [];
  final Map<String, Map<int, double?>> _attachmentProgress = {};
  late Future<ThreadReplyListResponse> _future;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<ThreadReplyListResponse> _fetch() {
    final apiClient = ref.read(apiClientProvider);
    return apiClient
        .get<Map<String, dynamic>>(
          '/messager/chat/${widget.roomId}/messages/${widget.root.id}/thread',
        )
        .then(
          (response) => ThreadReplyListResponse.fromJson(response.data!),
        );
  }

  void _refresh() {
    setState(() {
      _future = _fetch();
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachments.isEmpty || _sending) return;
    _sending = true;

    try {
      final notifier = ref.read(messagesProvider(widget.roomId).notifier);
      await notifier.sendMessage(
        text,
        List<UniversalFile>.of(_attachments),
        threadingTo: widget.root,
      );
      if (!mounted) return;
      _controller.clear();
      setState(() => _attachments.clear());
      _refresh();
    } catch (_) {
      // sendMessage surfaces errors through its own UI (alerts/pending
      // status); keep the composer text intact so the user can retry.
    } finally {
      _sending = false;
    }
  }

  void _updateAttachments(List<UniversalFile> attachments) {
    setState(() => _attachments
      ..clear()
      ..addAll(attachments));
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final results = await picker.pickMultiImage();
    if (results.isEmpty) return;
    _updateAttachments([
      ..._attachments,
      ...results.map(
        (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
      ),
    ]);
  }

  Future<void> _pickVideos() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;
    _updateAttachments([
      ..._attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
      ),
    ]);
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;
    _updateAttachments([
      ..._attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.audio),
      ),
    ]);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.count == 0) return;
    _updateAttachments([
      ..._attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.file),
      ),
    ]);
  }

  Future<void> _linkAttachment() async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ChatLinkAttachment(),
    );
    if (cloudFile == null) return;
    _updateAttachments([
      ..._attachments,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ]);
  }

  Future<void> _uploadAttachment(
    int index, {
    String? encryptKey,
  }) async {
    final attachment = _attachments[index];
    if (attachment.isOnCloud) return;

    final config = await showAttachmentUploaderModal(
      ref: ref,
      attachments: _attachments,
      index: index,
      encryptedUpload: widget.chatRoom.encryptionMode == 3,
    );
    if (config == null) return;

    setState(() {
      _attachmentProgress['chat-upload'] ??= {};
      _attachmentProgress['chat-upload']![index] = 0;
    });

    try {
      final cloudFile = await ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: attachment,
            poolId: config.poolId,
            encryptPassword: encryptKey,
            usage: 'chat_message',
            mode: attachment.type == UniversalFileType.file
                ? FileUploadMode.generic
                : FileUploadMode.mediaSafe,
            imageCompressionEnabled: config.imageCompressionEnabled,
            imageCompressionQuality: config.imageCompressionQuality,
            onProgress: (progress, _) {
              if (!mounted) return;
              setState(() {
                _attachmentProgress['chat-upload']?[index] = progress ?? 0.0;
              });
            },
          )
          .future;

      if (cloudFile == null) return;

      final clone = List<UniversalFile>.of(_attachments);
      clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
      setState(() {
        _attachments
          ..clear()
          ..addAll(clone);
        _attachmentProgress.remove('chat-upload');
      });
    } catch (_) {
      setState(() => _attachmentProgress.remove('chat-upload'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ThreadTitleBar(onClose: widget.onClose),
        Expanded(
          child: FutureBuilder<ThreadReplyListResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('threadLoadFailed'.tr()),
                      const Gap(8),
                      OutlinedButton(
                        onPressed: _refresh,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                );
              }

              return _ThreadMessageList(
                roomId: widget.roomId,
                root: snapshot.data!.root,
                replies: snapshot.data!.replies,
                onJump: widget.onJump,
              );
            },
          ),
        ),
        _ThreadComposer(
          controller: _controller,
          chatRoom: widget.chatRoom,
          attachments: _attachments,
          attachmentProgress: _attachmentProgress,
          sending: _sending,
          onSend: _send,
          onClear: () {
            _controller.clear();
            _updateAttachments([]);
          },
          onPickPhoto: _pickPhotos,
          onPickVideo: _pickVideos,
          onPickAudio: _pickAudio,
          onPickFile: _pickFiles,
          onLinkAttachment: _linkAttachment,
          onUploadAttachment: _uploadAttachment,
          onDeleteAttachment: (index) {
            final clone = List<UniversalFile>.of(_attachments);
            clone.removeAt(index);
            _updateAttachments(clone);
          },
          onMoveAttachment: (idx, delta) {
            if (idx + delta < 0 || idx + delta >= _attachments.length) return;
            final clone = List<UniversalFile>.of(_attachments);
            clone.insert(idx + delta, clone.removeAt(idx));
            _updateAttachments(clone);
          },
          onAttachmentsChanged: _updateAttachments,
        ),
      ],
    );
  }
}

class _ThreadTitleBar extends StatelessWidget {
  final VoidCallback? onClose;

  const _ThreadTitleBar({this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Icon(
            Symbols.forum,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              'thread'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Symbols.close),
              tooltip: 'close'.tr(),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

class _ThreadComposer extends StatelessWidget {
  final TextEditingController controller;
  final SnChatRoom chatRoom;
  final List<UniversalFile> attachments;
  final Map<String, Map<int, double?>> attachmentProgress;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onPickAudio;
  final VoidCallback onPickFile;
  final VoidCallback onLinkAttachment;
  final Future<void> Function(int, {String? encryptKey}) onUploadAttachment;
  final void Function(int) onDeleteAttachment;
  final void Function(int, int) onMoveAttachment;
  final void Function(List<UniversalFile>) onAttachmentsChanged;

  const _ThreadComposer({
    required this.controller,
    required this.chatRoom,
    required this.attachments,
    required this.attachmentProgress,
    required this.sending,
    required this.onSend,
    required this.onClear,
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onPickAudio,
    required this.onPickFile,
    required this.onLinkAttachment,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChatInput(
      messageController: controller,
      chatRoom: chatRoom,
      onSend: onSend,
      onClear: onClear,
      onPickFile: (isPhoto) {
        if (isPhoto) {
          onPickPhoto();
        } else {
          onPickVideo();
        }
      },
      onPickAudio: onPickAudio,
      onPickGeneralFile: onPickFile,
      onLinkAttachment: onLinkAttachment,
      messageReplyingTo: null,
      messageForwardingTo: null,
      messageEditingTo: null,
      attachments: attachments,
      onUploadAttachment: onUploadAttachment,
      onDeleteAttachment: onDeleteAttachment,
      onMoveAttachment: onMoveAttachment,
      onAttachmentsChanged: onAttachmentsChanged,
      attachmentProgress: attachmentProgress,
      embeds: const [],
      onEmbedsChanged: (_) {},
      isMessageListScrolling: false,
    );
  }
}

/// Builds the thread message list for display: root first, then replies in
/// chronological (oldest-first) order.
///
/// Replies inside a thread are not quoted references — they render as a flat
/// list — so the `repliedMessageId` (and the resulting reply-preview gap) is
/// stripped. The root's thread-hint chip is also suppressed because the user
/// is already inside the thread.
List<LocalChatMessage> buildThreadDisplayMessages({
  required SnChatMessage root,
  required List<ThreadReplyNode> replies,
}) {
  final rootLocal = LocalChatMessage.fromRemoteMessage(
    root,
    MessageStatus.sent,
  );
  // Remove the thread-hint chip from the root's in-thread display copy.
  final rootData = Map<String, dynamic>.from(rootLocal.data)
    ..remove('thread_replies_count');
  final displayRoot = rootLocal.copyWith(data: rootData);

  final repliesOnly = [
    for (final node in replies)
      LocalChatMessage.fromRemoteMessage(
        node.message,
        MessageStatus.sent,
      ).copyWith(clearRepliedMessageId: true),
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  return [displayRoot, ...repliesOnly];
}

/// Renders the thread as a message list using the same [MessageItemWrapper]
/// as the main timeline: the root message first, then its flattened replies.
/// Actions (reply, edit, delete, …) route through the room state notifier so
/// they behave exactly like the main list.
class _ThreadMessageList extends HookConsumerWidget {
  final String roomId;
  final SnChatMessage root;
  final List<ThreadReplyNode> replies;
  final void Function(String messageId) onJump;

  const _ThreadMessageList({
    required this.roomId,
    required this.root,
    required this.replies,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdentity = ref.watch(chatRoomIdentityProvider(roomId));
    final stateNotifier = ref.read(chatRoomStateProvider(roomId).notifier);

    final messages = buildThreadDisplayMessages(root: root, replies: replies);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        // Each thread message is its own group so the sender avatar/name
        // always renders (the root especially).
        return MessageItemWrapper(
          message: message,
          index: index,
          roomId: roomId,
          isFirstInGroup: true,
          isLastInGroup: true,
          chatIdentity: chatIdentity,
          toggleSelectionMode: () {},
          toggleMessageSelection: (_) {},
          onMessageAction: (action, msg) {
            stateNotifier.onMessageAction(action, msg);
          },
          onJump: onJump,
          disableAnimation: true,
          roomOpenTime: DateTime.fromMillisecondsSinceEpoch(0),
        );
      },
    );
  }
}
