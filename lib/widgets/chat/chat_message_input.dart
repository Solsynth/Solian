import 'dart:io';
import 'dart:math' show min;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/chat_message_controller.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_sticker.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/post/post_media_pending_list.dart';
import 'package:surface/widgets/universal_image.dart';

class ChatMessageInput extends StatefulWidget {
  final ChatMessageController controller;
  final SnChannelMember? otherMember;

  const ChatMessageInput(
      {super.key, required this.controller, this.otherMember});

  @override
  State<ChatMessageInput> createState() => ChatMessageInputState();
}

class ChatMessageInputState extends State<ChatMessageInput> {
  bool _isBusy = false;
  double? _progress;

  bool _isEncrypted = false;

  SnChatMessage? _replyingMessage, _editingMessage;

  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final HotKey _pasteHotKey = HotKey(
    key: PhysicalKeyboardKey.keyV,
    modifiers: [
      (!kIsWeb && Platform.isMacOS)
          ? HotKeyModifier.meta
          : HotKeyModifier.control
    ],
    scope: HotKeyScope.inapp,
  );
  final HotKey _newLineHotKey = HotKey(
    key: PhysicalKeyboardKey.enter,
    modifiers: [
      (!kIsWeb && Platform.isMacOS)
          ? HotKeyModifier.meta
          : HotKeyModifier.control
    ],
    scope: HotKeyScope.inapp,
  );

  void _registerHotKey() {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;
    hotKeyManager.register(_pasteHotKey, keyDownHandler: (_) async {
      final imageBytes = await Pasteboard.image;
      if (imageBytes == null) return;
      _attachments.add(PostWriteMedia.fromBytes(
        imageBytes,
        'attachmentPastedImage'.tr(),
        SnMediaType.image,
      ));
      setState(() {});
    });
    hotKeyManager.register(_newLineHotKey, keyDownHandler: (_) async {
      if (_contentController.text.isEmpty) return;
      _contentController.text += '\n';
    });
  }

  @override
  void initState() {
    super.initState();
    _registerHotKey();
    _contentController.addListener(() {
      if (_contentController.text.isNotEmpty) {
        widget.controller.pingTypingStatus();
      }
    });
  }

  void setEncrypted(bool value) {
    setState(() => _isEncrypted = value);
  }

  void setReply(SnChatMessage? value) {
    setState(() => _replyingMessage = value);
  }

  void setInitialText(String? value) {
    _contentController.text = value ?? '';
    setState(() {});
  }

  void setInitialAttachments(List<PostWriteMedia>? value) {
    _attachments.addAll(value ?? []);
    setState(() {});
  }

  void setEdit(SnChatMessage? value) {
    _contentController.text = value?.body['text'] ?? '';
    _attachments.clear();
    _attachments.addAll(
        value?.preload?.attachments?.map((e) => PostWriteMedia(e)) ?? []);
    setState(() => _editingMessage = value);
  }

  Future<void> deleteMessage(SnChatMessage message) async {
    final confirm = await context.showConfirmDialog(
      'messageDelete'.tr(args: ['#${message.id}']),
      'messageDeleteDescription'.tr(),
    );
    if (!confirm) return;

    if (!mounted) return;
    setState(() => _isBusy = true);

    await widget.controller.deleteMessage(message);

    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Future<void> _sendMessage() async {
    if (_contentController.text.isEmpty && _attachments.isEmpty) return;
    if (_isBusy) return;

    final attach = context.read<SnAttachmentProvider>();

    setState(() => _isBusy = true);

    try {
      for (int i = 0; i < _attachments.length; i++) {
        final media = _attachments[i];
        if (media.attachment != null) continue; // Already uploaded, skip
        if (media.isEmpty) continue; // Nothing to do, skip

        final place = await attach.chunkedUploadInitialize(
          (await media.length())!,
          media.name,
          'messaging',
          null,
          mimetype: media.raw != null && media.type == SnMediaType.image
              ? 'image/png'
              : null,
        );

        final item = await attach.chunkedUploadParts(
          media.toFile()!,
          place.$1,
          place.$2,
          analyzeNow: media.type == SnMediaType.image,
          onProgress: (progress) {
            // Calculate overall progress for attachments
            setState(() {
              progress = (i + progress) / _attachments.length;
            });
          },
        );

        setState(() {
          _attachments[i] = PostWriteMedia(item);
        });
      }
    } catch (err) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      context.showErrorDialog(err);
      return;
    }

    // Send the message
    // NOTICE This future should not be awaited, so that the message can be sent in the background and the user can continue to type
    widget.controller.sendMessage(
      _editingMessage != null ? 'messages.edit' : 'messages.new',
      _contentController.text,
      attachments: _attachments
          .where((e) => e.attachment != null)
          .map((e) => e.attachment!.rid)
          .toList(),
      relatedId: _editingMessage?.id,
      quoteId: _replyingMessage?.id,
      editingMessage: _editingMessage,
      isEncrypted: _isEncrypted,
    );
    _contentController.clear();
    _attachments.clear();
    _editingMessage = null;
    _replyingMessage = null;

    setState(() => _isBusy = false);
  }

  final List<PostWriteMedia> _attachments = List.empty(growable: true);

  OverlayEntry? _overlayEntry;

  void _showEmojiPicker(BuildContext context) {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16 + MediaQuery.of(context).padding.bottom,
        right: 16,
        child: _StickerPicker(
          originalText: _contentController.text,
          onDismiss: () => _dismissEmojiPicker(),
          onInsert: (str) => _contentController.text = str,
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _dismissEmojiPicker() {
    _overlayEntry?.remove();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    _dismissEmojiPicker();
    if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
      hotKeyManager.unregister(_pasteHotKey);
      hotKeyManager.unregister(_newLineHotKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isBusy && _progress != null)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: Duration(milliseconds: 300),
            builder: (context, value, _) =>
                LinearProgressIndicator(value: value, minHeight: 2),
          )
        else if (_isBusy)
          const LinearProgressIndicator(value: null, minHeight: 2),
        Padding(
          padding: _attachments.isNotEmpty
              ? const EdgeInsets.only(top: 8)
              : EdgeInsets.zero,
          child: PostMediaPendingList(
            attachments: _attachments,
            isBusy: _isBusy,
            onUpdate: (idx, updatedMedia) async {
              setState(() => _attachments[idx] = updatedMedia);
            },
            onRemove: (idx) async {
              setState(() => _attachments.removeAt(idx));
            },
            onUpdateBusy: (state) => setState(() => _isBusy = state),
          ),
        ).height(_attachments.isNotEmpty ? 80 + 8 : 0, animate: true).animate(
            const Duration(milliseconds: 300), Curves.fastEaseInToSlowEaseOut),
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: _replyingMessage != null
              ? Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Symbols.reply, size: 20),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _replyingMessage?.body['text'] ??
                              '${_replyingMessage?.sender.nick}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(16),
                      InkWell(
                        child: Text('cancel'.tr()),
                        onTap: () {
                          _attachments.clear();
                          setState(() => _replyingMessage = null);
                        },
                      ),
                    ],
                  ).padding(vertical: 8),
                )
              : const SizedBox.shrink(),
        ).height(_replyingMessage != null ? 38 : 0, animate: true).animate(
            const Duration(milliseconds: 300), Curves.fastEaseInToSlowEaseOut),
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: _editingMessage != null
              ? Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Symbols.edit, size: 20),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _editingMessage?.body['text'] ??
                              '${_editingMessage?.sender.nick}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(16),
                      InkWell(
                        child: Text('cancel'.tr()),
                        onTap: () {
                          _attachments.clear();
                          _contentController.clear();
                          setState(() => _editingMessage = null);
                        },
                      ),
                    ],
                  ).padding(vertical: 8),
                )
              : const SizedBox.shrink(),
        ).height(_editingMessage != null ? 38 : 0, animate: true).animate(
            const Duration(milliseconds: 300), Curves.fastEaseInToSlowEaseOut),
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 6,
          ),
          constraints: BoxConstraints(maxHeight: 240),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _contentController,
                  decoration: InputDecoration(
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      maxWidth: 24,
                    ),
                    prefixIcon:
                        _isEncrypted ? Icon(Symbols.lock, size: 18) : null,
                    hintText: widget.otherMember != null
                        ? 'fieldChatMessageDirect'.tr(args: [
                            '@${ud.getFromCache(widget.otherMember?.accountId)?.name}',
                          ])
                        : 'fieldChatMessage'.tr(args: [
                            widget.controller.channel?.name ?? 'loading'.tr()
                          ]),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onSubmitted: (_) {
                    if (_isBusy) return;
                    _sendMessage();
                    _focusNode.requestFocus();
                  },
                  maxLines: null,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Symbols.mood,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  _showEmojiPicker(context);
                },
              ),
              AddPostMediaButton(
                visualDensity: VisualDensity.compact,
                onAdd: (items) {
                  setState(() {
                    _attachments.addAll(items);
                  });
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _isBusy ? null : _sendMessage,
                icon: Icon(
                  Symbols.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Gap(MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

class _StickerPicker extends StatelessWidget {
  final String originalText;
  final Function? onDismiss;
  final Function(String)? onInsert;

  const _StickerPicker(
      {this.onDismiss, required this.originalText, this.onInsert});

  @override
  Widget build(BuildContext context) {
    final sticker = context.read<SnStickerProvider>();
    if (sticker.stickersByPack.isEmpty) {
      return GestureDetector(
        onTap: () {
          onDismiss?.call();
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: min(360, MediaQuery.of(context).size.width - 40),
          ),
          child: Material(
            elevation: 8,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Symbols.ar_stickers, size: 48),
                  const Gap(8),
                  Text('stickerPickerEmpty').tr().bold(),
                  Text(
                    'stickerPickerEmptyHint',
                    textAlign: TextAlign.center,
                  ).tr().opacity(0.75),
                  TextButton(
                    child: Text('goto'.tr(args: ['screenStickers'.tr()])),
                    onPressed: () {
                      GoRouter.of(context).goNamed('stickers');
                    },
                  ),
                  InkWell(
                    child: Text(
                      'stickersReload',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ).tr(),
                    onTap: () async {
                      await sticker.listSticker();
                      if (!context.mounted) return;
                      HapticFeedback.heavyImpact();
                      context.showSnackbar('stickersReloaded'.tr());
                      onDismiss?.call();
                    },
                  )
                ],
              ).padding(all: 64),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        onDismiss?.call();
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: min(360, MediaQuery.of(context).size.width - 40),
          maxHeight: 240,
        ),
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: ListView(
              padding: EdgeInsets.zero,
              children: sticker.stickersByPack.entries
                  .map((e) {
                    return <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.first.pack.name).bold(),
                            Text(e.value.first.pack.description),
                          ],
                        ),
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 48,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: e.value.length,
                        itemBuilder: (context, index) {
                          final sn = context.read<SnNetworkProvider>();
                          final element = e.value[index];
                          return GestureDetector(
                            onTap: () {
                              final withSpace = originalText.isNotEmpty;
                              onInsert?.call(
                                  '$originalText${withSpace ? ' ' : ''}:${element.pack.prefix}${element.alias}:');
                              onDismiss?.call();
                            },
                            child: Tooltip(
                              richMessage: TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          ':${element.pack.prefix}${element.alias}:\n',
                                      style: GoogleFonts.robotoMono()),
                                  TextSpan(text: element.name).bold(),
                                ],
                              ),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  child: UniversalImage(
                                    sn.getAttachmentUrl(element.attachment.rid),
                                    width: 48,
                                    height: 48,
                                    cacheHeight: 48,
                                    cacheWidth: 48,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ];
                  })
                  .expand((ele) => ele)
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
