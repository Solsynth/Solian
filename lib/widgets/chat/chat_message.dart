import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/keypair.dart';
import 'package:surface/providers/translation.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/account_popover.dart';
import 'package:surface/widgets/account/badge.dart';
import 'package:surface/widgets/attachment/attachment_list.dart';
import 'package:surface/widgets/context_menu.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/link_preview.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatMessage extends StatelessWidget {
  final SnChatMessage data;
  final bool isCompact;
  final bool isMerged;
  final bool hasMerged;
  final bool isPending;
  final Function(SnChatMessage)? onReply;
  final Function(SnChatMessage)? onEdit;
  final Function(SnChatMessage)? onDelete;
  final EdgeInsets padding;

  const ChatMessage({
    super.key,
    required this.data,
    this.isCompact = false,
    this.isMerged = false,
    this.hasMerged = false,
    this.isPending = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.padding = const EdgeInsets.only(left: 12, right: 12),
  });

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();
    final ud = context.read<UserDirectoryProvider>();
    final user = ud.getFromCache(data.sender.accountId);

    final isOwner = ua.isAuthorized && data.sender.accountId == ua.user?.id;

    final dateFormatter = DateFormat('MM/dd HH:mm');

    final cfg = context.read<ConfigProvider>();

    return SwipeTo(
      key: Key('chat-message-${data.id}'),
      iconOnLeftSwipe: Symbols.reply,
      iconOnRightSwipe: Symbols.edit,
      swipeSensitivity: 10,
      onLeftSwipe: onReply != null ? (_) => onReply!(data) : null,
      onRightSwipe: (onEdit != null && isOwner) ? (_) => onEdit!(data) : null,
      child: ContextMenuArea(
        contextMenu: ContextMenu(
          entries: [
            MenuHeader(text: "eventResourceTag".tr(args: ['#${data.id}'])),
            if (onReply != null)
              MenuItem(
                label: 'reply'.tr(),
                icon: Symbols.reply,
                onSelected: () {
                  onReply!(data);
                },
              ),
            if (isOwner && data.type == 'messages.new' && onEdit != null)
              MenuItem(
                label: 'edit'.tr(),
                icon: Symbols.edit,
                onSelected: () {
                  onEdit!(data);
                },
              ),
            if (isOwner && data.type == 'messages.new' && onDelete != null)
              MenuItem(
                label: 'delete'.tr(),
                icon: Symbols.delete,
                onSelected: () {
                  onDelete!(data);
                },
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: isCompact ? EdgeInsets.zero : padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMerged && !isCompact)
                    GestureDetector(
                      child: AccountImage(
                        content: user?.avatar,
                        badge: (user?.badges.isNotEmpty ?? false)
                            ? AccountBadge(
                                badge: user!.badges.first,
                                radius: 16,
                                padding: EdgeInsets.all(2),
                              )
                            : null,
                      ),
                      onTap: () {
                        if (user == null) return;
                        showPopover(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          context: context,
                          transition: PopoverTransition.other,
                          bodyBuilder: (context) => SizedBox(
                            width: math.min(
                                400, MediaQuery.of(context).size.width - 10),
                            child: AccountPopoverCard(data: user),
                          ),
                          direction: PopoverDirection.bottom,
                          arrowHeight: 5,
                          arrowWidth: 15,
                          arrowDxOffset: -190,
                        );
                      },
                    )
                  else if (isMerged)
                    const Gap(40),
                  const Gap(8),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMerged)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isCompact)
                                  AccountImage(
                                          content: user?.avatar, radius: 12)
                                      .padding(right: 8),
                                Text(
                                  (data.sender.nick?.isNotEmpty ?? false)
                                      ? data.sender.nick!
                                      : user?.nick ?? 'unknown',
                                ).bold(),
                                const Gap(8),
                                Text(dateFormatter
                                        .format(data.createdAt.toLocal()))
                                    .fontSize(13),
                              ],
                            ).height(21),
                          if (isCompact) const Gap(8),
                          if (data.preload?.quoteEvent != null)
                            StyledWidget(
                              Container(
                                constraints: BoxConstraints(maxWidth: 360),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                      width: 1),
                                ),
                                padding: const EdgeInsets.only(
                                    left: 4, right: 4, top: 8, bottom: 6),
                                child: ChatMessage(
                                  data: data.preload!.quoteEvent!,
                                  isCompact: true,
                                  onReply: onReply,
                                  onEdit: onEdit,
                                  onDelete: onDelete,
                                ),
                              ),
                            ).padding(bottom: 4, top: 4),
                          switch (data.type) {
                            'messages.new' => _ChatMessageText(
                                data: data,
                                onReply: onReply,
                                onEdit: onEdit,
                                onDelete: onDelete,
                              ),
                            _ => _ChatMessageSystemNotify(data: data),
                          },
                        ],
                      ),
                    ),
                  ),
                ],
              ).opacity(isPending ? 0.5 : 1),
            ),
            if (data.body['text'] != null &&
                data.type == 'messages.new' &&
                (data.body['text']?.isNotEmpty ?? false) &&
                (cfg.prefs.getBool(kAppExpandChatLink) ?? true))
              LinkPreviewWidget(text: data.body['text']!)
                  .padding(left: isCompact ? 0 : 48),
            if (data.preload?.attachments?.isNotEmpty ?? false)
              AttachmentList(
                data: data.preload!.attachments!,
                bordered: true,
                maxHeight: 360,
                maxWidth: 480 - 48 - padding.left,
                padding: padding.copyWith(
                    top: 8, left: isCompact ? padding.left : 48 + padding.left),
              ),
            if (!hasMerged && !isCompact)
              const Gap(12)
            else if (!isCompact)
              const Gap(8),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageText extends StatefulWidget {
  final SnChatMessage data;
  final Function(SnChatMessage)? onReply;
  final Function(SnChatMessage)? onEdit;
  final Function(SnChatMessage)? onDelete;

  const _ChatMessageText(
      {required this.data, this.onReply, this.onEdit, this.onDelete});

  @override
  State<_ChatMessageText> createState() => _ChatMessageTextState();
}

class _ChatMessageTextState extends State<_ChatMessageText> {
  late String _displayText = widget.data.body['text'] ?? '';
  bool _isTranslated = false;
  bool _isTranslating = false;

  Future<void> _translateText() async {
    if (widget.data.body['text'] == null || widget.data.body['text']!.isEmpty) {
      return;
    }
    final ta = context.read<SnTranslator>();
    setState(() => _isTranslating = true);
    try {
      final to = EasyLocalization.of(context)!.locale.languageCode;
      _displayText = await ta.translate(
        widget.data.body['text'],
        to: to,
      );
      _isTranslated = true;
      if (mounted) setState(() {});
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final cfg = context.read<ConfigProvider>();
    if (cfg.autoTranslate) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _translateText();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();

    final isOwner =
        ua.isAuthorized && widget.data.sender.accountId == ua.user?.id;

    if (widget.data.body['text'] != null &&
        widget.data.body['text'].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            contextMenuBuilder: (context, editableTextState) {
              final List<ContextMenuButtonItem> items =
                  editableTextState.contextMenuButtonItems;

              if (widget.onReply != null) {
                items.insert(
                  0,
                  ContextMenuButtonItem(
                    label: 'reply'.tr(),
                    onPressed: () {
                      ContextMenuController.removeAny();
                      widget.onReply?.call(widget.data);
                    },
                  ),
                );
              }
              if (isOwner && widget.onEdit != null) {
                items.insert(
                  1,
                  ContextMenuButtonItem(
                    label: 'edit'.tr(),
                    onPressed: () {
                      ContextMenuController.removeAny();
                      widget.onEdit?.call(widget.data);
                    },
                  ),
                );
              }
              if (isOwner && widget.onDelete != null) {
                items.insert(
                  2,
                  ContextMenuButtonItem(
                    label: 'delete'.tr(),
                    onPressed: () {
                      ContextMenuController.removeAny();
                      widget.onDelete?.call(widget.data);
                    },
                  ),
                );
              }
              if (widget.data.body['algorithm'] == 'plain') {
                items.insert(
                  3,
                  ContextMenuButtonItem(
                    label: 'translate'.tr(),
                    onPressed: () {
                      ContextMenuController.removeAny();
                      _translateText();
                    },
                  ),
                );
              }

              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: items,
              );
            },
            child: switch (widget.data.body['algorithm']) {
              'rsa' => _ChatDecryptMessage(message: widget.data),
              _ => MarkdownTextContent(
                  content: _displayText,
                  isAutoWarp: true,
                  isEnlargeSticker: RegExp(r"^:([-\w]+):$")
                      .hasMatch(widget.data.body['text'] ?? ''),
                ),
            },
          ),
          if (widget.data.updatedAt != widget.data.createdAt)
            Text('messageEditedHint'.tr()).fontSize(13).opacity(0.75),
          if (_isTranslating)
            AnimateWidgetExtensions(Text('translating').tr())
                .animate(onPlay: (e) => e.repeat())
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .then()
                .fadeOut(
                  duration: 500.ms,
                  delay: 1000.ms,
                  curve: Curves.easeIn,
                ),
          if (_isTranslated)
            InkWell(
              child: Text('translated').tr().opacity(0.75),
              onTap: () {
                setState(() {
                  _displayText = widget.data.body['text'] ?? '';
                  _isTranslated = false;
                });
              },
            ),
        ],
      );
    } else if (widget.data.body['attachments']?.isNotEmpty) {
      return Row(
        children: [
          const Icon(Symbols.file_present, size: 20),
          const Gap(4),
          Text('messageFileHint'
              .plural(widget.data.body['attachments']!.length)),
        ],
      ).opacity(0.8);
    }

    return const SizedBox.shrink();
  }
}

class _ChatMessageSystemNotify extends StatelessWidget {
  final SnChatMessage data;

  const _ChatMessageSystemNotify({required this.data});

  String _formatDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return '$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case 'messages.edit':
        return Row(
          children: [
            const Icon(Symbols.edit, size: 16),
            const Gap(8),
            Text('messageEdited'.tr(args: ['#${data.relatedEventId}'])),
          ],
        ).opacity(0.8);
      case 'messages.delete':
        return Row(
          children: [
            const Icon(Symbols.delete, size: 16),
            const Gap(8),
            Text('messageDeleted'.tr(args: ['#${data.relatedEventId}'])),
          ],
        ).opacity(0.8);
      case 'calls.start':
        return Row(
          children: [
            const Icon(Symbols.call, size: 16),
            const Gap(8),
            Text('callMessageStarted'.tr())
          ],
        ).opacity(0.8);
      case 'calls.end':
        return Row(
          children: [
            const Icon(Symbols.call_end, size: 16),
            const Gap(8),
            Text('callMessageEnded'.tr(
                args: [_formatDuration(Duration(seconds: data.body['last']))])),
          ],
        ).opacity(0.8);
      default:
        return Row(
          children: [
            const Icon(Symbols.info, size: 16),
            const Gap(8),
            Text('messageUnsupported'.tr(args: [data.type])),
          ],
        ).opacity(0.8);
    }
  }
}

class _ChatDecryptMessage extends StatelessWidget {
  final SnChatMessage message;
  const _ChatDecryptMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final kp = context.read<KeyPairProvider>();
    return FutureBuilder(
      key: Key('chat-message-encrypted-${message.id}'),
      future: kp.decryptText(
        message.body['text'],
        message.body['keypair_id'],
        kpOwner: message.sender.accountId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            children: [
              Icon(Symbols.key_off, size: 16),
              const Gap(8),
              Expanded(
                child: Text('decryptingKeyNotFound'.tr()),
              ),
            ],
          ).opacity(0.8);
        }
        if (!snapshot.hasData) {
          return Row(
            children: [
              Animate(
                autoPlay: true,
                onPlay: (e) => e.repeat(),
                effects: [
                  RotateEffect(
                    duration: const Duration(seconds: 3),
                    begin: 0,
                    end: -1,
                  )
                ],
                child: Icon(Symbols.sync, size: 16),
              ),
              const Gap(8),
              Expanded(
                child: Text('decrypting'.tr()),
              ),
            ],
          );
        }
        return MarkdownTextContent(
          content: snapshot.data!,
          isAutoWarp: true,
          isEnlargeSticker: RegExp(r"^:([-\w]+):$").hasMatch(snapshot.data!),
        );
      },
    );
  }
}
