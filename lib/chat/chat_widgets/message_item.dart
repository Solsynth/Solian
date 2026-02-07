import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_widgets/account/account_pfc.dart';
import 'package:island/chat/chat_widgets/message_content.dart';
import 'package:island/chat/chat_widgets/message_indicators.dart';
import 'package:island/chat/chat_widgets/message_sender_info.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/data/message.dart';
import 'package:island/chat/chat_pod/chat_room.dart';
import 'package:island/core/translate.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/embed/embed_list.dart';
import 'package:island/posts/posts_widgets/post/post_shared.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';

class MessageItemAction {
  static const String edit = "edit";
  static const String delete = "delete";
  static const String reply = "reply";
  static const String forward = "forward";
  static const String resend = "resend";
}

class MessageItem extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final Function(String messageId) onJump;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(String messageId)? onToggleSelection;
  final Function()? onEnterSelectionMode;

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onAction,
    required this.progress,
    required this.showAvatar,
    required this.onJump,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
    this.onEnterSelectionMode,
  });

  static const kFlashDuration = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteMessage = message.toRemoteMessage();
    final settings = ref.watch(appSettingsProvider);

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    final currentLanguage = context.locale.toString();
    final translatableLanguage = remoteMessage.content?.isNotEmpty ?? false;

    final translating = useState(false);
    final translatedText = useState<String?>(null);

    Future<void> translate() async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }

      if (translating.value) return;
      if (remoteMessage.content == null) return;
      translating.value = true;
      try {
        final text = await ref.watch(
          translateStringProvider(
            TranslateQuery(
              text: remoteMessage.content!,
              lang: currentLanguage.substring(0, 2),
            ),
          ).future,
        );
        translatedText.value = text;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

    void showActionMenu() {
      if (onAction == null) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => MessageActionSheet(
          isCurrentUser: isCurrentUser,
          onAction: onAction,
          translatableLanguage: translatableLanguage,
          translating: translating.value,
          translatedText: translatedText.value,
          translate: translate,
          isMobile: isMobile,
          remoteMessage: remoteMessage,
          message: message,
          onToggleSelection: onToggleSelection,
          onEnterSelectionMode: onEnterSelectionMode,
        ),
      );
    }

    final flashing = ref.watch(
      flashingMessagesProvider.select((set) => set.contains(message.id)),
    );

    final isFlashing = useState(false);
    final flashTimer = useState<Timer?>(null);

    useEffect(() {
      if (flashing) {
        flashTimer.value?.cancel();
        isFlashing.value = true;
        flashTimer.value = Timer.periodic(
          const Duration(milliseconds: kFlashDuration),
          (timer) {
            isFlashing.value = !isFlashing.value;
            if (timer.tick >= 6) {
              // 6 ticks: 1, 0, 1, 0, 1, 0
              timer.cancel();
              flashTimer.value = null;
              isFlashing.value = false;
              ref
                  .read(flashingMessagesProvider.notifier)
                  .update((set) => set.difference({message.id}));
            }
          },
        );
      } else {
        flashTimer.value?.cancel();
        flashTimer.value = null;
        isFlashing.value = false;
      }
      return () {
        flashTimer.value?.cancel();
      };
    }, [flashing]);

    final flashColor = isFlashing.value
        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
        : Colors.transparent;

    final isHovered = useState(false);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SwipeTo(
          swipeSensitivity: 15,
          rightSwipeWidget: Transform.flip(
            flipX: true,
            child: Icon(Symbols.menu_open),
          ).padding(left: 16),
          leftSwipeWidget: Icon(
            isCurrentUser ? Symbols.forward : Symbols.reply,
          ).padding(right: 16),
          onLeftSwipe: (details) {
            if (onAction != null) {
              if (isCurrentUser) {
                onAction!(MessageItemAction.forward);
              } else {
                onAction!(MessageItemAction.reply);
              }
            }
          },
          onRightSwipe: (details) => showActionMenu(),
          child: InkWell(
            mouseCursor: MouseCursor.defer,
            focusColor: Colors.transparent,
            onLongPress: () {
              if (isSelectionMode && onToggleSelection != null) {
                onToggleSelection!(message.id);
              } else {
                showActionMenu();
              }
            },
            onSecondaryTap: showActionMenu,
            onTap: () {
              if (isSelectionMode && onToggleSelection != null) {
                onToggleSelection!(message.id);
              } else {
                // Jump to related message
                if ([
                      'messages.update',
                      'messages.delete',
                    ].contains(message.type) &&
                    message.meta['message_id'] is String &&
                    message.meta['message_id'] != null) {
                  onJump(message.meta['message_id']);
                }
              }
            },
            child: SizedBox(
              width: double.infinity,
              child: MouseRegion(
                onEnter: (_) => isHovered.value = true,
                onExit: (_) => isHovered.value = false,
                child: AnimatedContainer(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: kFlashDuration),
                  decoration: BoxDecoration(color: flashColor),
                  child: switch (settings.messageDisplayStyle) {
                    'compact' => MessageItemDisplayIRC(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      progress: progress,
                      showAvatar: showAvatar,
                      onJump: onJump,
                      translatedText: translatedText.value,
                      translating: translating.value,
                    ),
                    'column' => MessageItemDisplayDiscord(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      progress: progress,
                      showAvatar: showAvatar,
                      onJump: onJump,
                      translatedText: translatedText.value,
                      translating: translating.value,
                    ),
                    _ => MessageItemDisplayBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      progress: progress,
                      showAvatar: showAvatar,
                      onJump: onJump,
                      translatedText: translatedText.value,
                      translating: translating.value,
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
        if (isHovered.value && !isMobile)
          Positioned(
            top: -15,
            right: 15,
            child: MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: MessageHoverActionMenu(
                isCurrentUser: isCurrentUser,
                onAction: onAction,
                translatableLanguage: translatableLanguage,
                translating: translating.value,
                translatedText: translatedText.value,
                translate: translate,
                remoteMessage: remoteMessage,
              ),
            ),
          ),
      ],
    );
  }
}

class MessageActionSheet extends StatefulWidget {
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final bool translatableLanguage;
  final bool translating;
  final String? translatedText;
  final VoidCallback translate;
  final bool isMobile;
  final dynamic remoteMessage;
  final LocalChatMessage message;
  final Function(String messageId)? onToggleSelection;
  final Function()? onEnterSelectionMode;

  const MessageActionSheet({
    super.key,
    required this.isCurrentUser,
    required this.onAction,
    required this.translatableLanguage,
    required this.translating,
    required this.translatedText,
    required this.translate,
    required this.isMobile,
    required this.remoteMessage,
    required this.message,
    this.onToggleSelection,
    this.onEnterSelectionMode,
  });

  @override
  State<MessageActionSheet> createState() => _MessageActionSheetState();
}

class _MessageActionSheetState extends State<MessageActionSheet> {
  bool _isExpanded = false;
  static const int _maxPreviewLines = 3;

  String get _displayContent {
    return widget.translatedText ?? widget.remoteMessage.content ?? '';
  }

  bool get _shouldShowExpandButton {
    // Simple check: show expand button if content is not empty
    // The actual line limiting is handled by maxLines in SelectableText
    return (widget.translatedText ?? widget.remoteMessage.content ?? '')
        .isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'messageActions'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message content preview section
            if (widget.remoteMessage.content?.isNotEmpty ?? false) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          Icon(
                            Symbols.article,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Gap(6),
                          Text(
                            'messageContent'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          if (_shouldShowExpandButton)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                _isExpanded
                                    ? Symbols.expand_less
                                    : Symbols.expand_more,
                                size: 16,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    // Selectable content
                    SelectableText(
                      _displayContent,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      minLines: 1,
                      maxLines: _isExpanded ? null : _maxPreviewLines,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const Gap(4),
            ],

            Row(
              spacing: 6,
              children: [
                Icon(Symbols.send, size: 16),
                Text(
                  'messageSentAt'.tr(
                    args: [widget.message.createdAt.formatSystem()],
                  ),
                ).fontSize(13),
              ],
            ).opacity(0.75).padding(horizontal: 20, top: 8, bottom: 6),

            const Divider(),

            // Action buttons
            if (widget.isCurrentUser)
              _ActionListTile(
                leading: Icon(Symbols.edit),
                title: Text('edit'.tr()),
                onTap: () {
                  widget.onAction!.call(MessageItemAction.edit);
                  Navigator.pop(context);
                },
              ),
            if (widget.isCurrentUser &&
                widget.message.status == MessageStatus.failed)
              _ActionListTile(
                leading: Icon(Symbols.refresh),
                title: Text('resend'.tr()),
                onTap: () {
                  widget.onAction!.call(MessageItemAction.resend);
                  Navigator.pop(context);
                },
              ),
            if (widget.isCurrentUser)
              _ActionListTile(
                leading: Icon(Symbols.delete),
                title: Text('delete'.tr()),
                onTap: () {
                  widget.onAction!.call(MessageItemAction.delete);
                  Navigator.pop(context);
                },
              ),
            if (widget.isCurrentUser) const Divider(),

            _ActionListTile(
              leading: Icon(Symbols.reply),
              title: Text('reply'.tr()),
              onTap: () {
                widget.onAction!.call(MessageItemAction.reply);
                Navigator.pop(context);
              },
            ),
            _ActionListTile(
              leading: Icon(Symbols.forward),
              title: Text('forward'.tr()),
              onTap: () {
                widget.onAction!.call(MessageItemAction.forward);
                Navigator.pop(context);
              },
            ),

            // AI Selection action
            _ActionListTile(
              leading: Icon(Symbols.smart_toy),
              title: Text('Select for AI'),
              onTap: () {
                if (widget.onEnterSelectionMode != null) {
                  widget.onEnterSelectionMode!();
                  if (widget.onToggleSelection != null) {
                    widget.onToggleSelection!(widget.message.id);
                  }
                }
                Navigator.pop(context);
              },
            ),

            if (widget.translatableLanguage) const Divider(),
            if (widget.translatableLanguage)
              _ActionListTile(
                leading: Icon(Symbols.translate),
                title: Text(
                  widget.translatedText == null
                      ? 'translate'.tr()
                      : widget.translating
                      ? 'translating'.tr()
                      : 'translated'.tr(),
                ),
                onTap: () {
                  widget.translate();
                  Navigator.pop(context);
                },
              ),

            if (widget.isMobile) const Divider(),
            if (widget.isMobile)
              _ActionListTile(
                leading: Icon(Symbols.copy_all),
                title: Text('copyMessage'.tr()),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.remoteMessage.content ?? ''),
                  );
                  Navigator.pop(context);
                },
              ),

            Gap(MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}

class _ActionListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;

  const _ActionListTile({
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: leading),
            const Gap(12),
            Expanded(child: title),
            Icon(
              Symbols.chevron_right,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageHoverActionMenu extends StatelessWidget {
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final bool translatableLanguage;
  final bool translating;
  final String? translatedText;
  final VoidCallback translate;
  final dynamic remoteMessage;

  const MessageHoverActionMenu({
    super.key,
    required this.isCurrentUser,
    required this.onAction,
    required this.translatableLanguage,
    required this.translating,
    required this.translatedText,
    required this.translate,
    required this.remoteMessage,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showConfirmAlert(
      'deleteMessageConfirmation'.tr(),
      'deleteMessage'.tr(),
      isDanger: true,
    );

    if (confirmed) {
      onAction?.call(MessageItemAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    // General actions (available for all users)
    final generalActions = [
      if (!isCurrentUser) // Hide reply for message author
        IconButton(
          icon: Icon(Symbols.reply, size: 16),
          onPressed: () => onAction?.call(MessageItemAction.reply),
          tooltip: 'reply'.tr(),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      IconButton(
        icon: Icon(Symbols.forward, size: 16),
        onPressed: () => onAction?.call(MessageItemAction.forward),
        tooltip: 'forward'.tr(),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      if (translatableLanguage)
        IconButton(
          icon: Icon(Symbols.translate, size: 16),
          onPressed: translate,
          tooltip: translatedText == null
              ? 'translate'.tr()
              : 'translated'.tr(),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
    ];

    // Author-only actions (edit/delete)
    final authorActions = [
      if (isCurrentUser)
        IconButton(
          icon: Icon(Symbols.edit, size: 16),
          onPressed: () => onAction?.call(MessageItemAction.edit),
          tooltip: 'edit'.tr(),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      if (isCurrentUser)
        IconButton(
          icon: Icon(Symbols.delete, size: 16, color: Colors.red),
          onPressed: () => _handleDelete(context),
          tooltip: 'delete'.tr(),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // General actions (left side)
          ...generalActions,
          // Separator (only if both general and author actions exist)
          if (generalActions.isNotEmpty && authorActions.isNotEmpty)
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).colorScheme.outlineVariant,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
          // Author actions (right side)
          ...authorActions,
        ],
      ),
    );
  }
}

class MessageItemDisplayBubble extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final Function(String messageId) onJump;
  final String? translatedText;
  final bool translating;

  const MessageItemDisplayBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.progress,
    required this.showAvatar,
    required this.onJump,
    required this.translatedText,
    required this.translating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isCurrentUser
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final containerColor = isCurrentUser
        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
        : Theme.of(context).colorScheme.surfaceContainer;

    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAvatar) ...[
              const Gap(8),
              MessageSenderInfo(
                sender: sender,
                createdAt: message.createdAt,
                textColor: textColor,
              ),
              const Gap(4),
            ],
            const Gap(2),
            Row(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (remoteMessage.repliedMessageId != null)
                          MessageQuoteWidget(
                            message: message,
                            textColor: textColor,
                            isReply: true,
                          ).padding(vertical: 4),
                        if (remoteMessage.forwardedMessageId != null)
                          MessageQuoteWidget(
                            message: message,
                            textColor: textColor,
                            isReply: false,
                          ).padding(vertical: 4),
                        if (MessageContent.hasContent(remoteMessage))
                          MessageContent(
                            item: remoteMessage,
                            translatedText: translatedText,
                          ),
                        if (remoteMessage.attachments.isNotEmpty)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CloudFileList(
                                files: remoteMessage.attachments,
                                maxWidth: constraints.maxWidth,
                                padding: EdgeInsets.symmetric(vertical: 4),
                              );
                            },
                          ),
                        if (remoteMessage.meta['embeds'] != null &&
                            kMessageEnableEmbedTypes.contains(message.type))
                          EmbedListWidget(
                            embeds:
                                remoteMessage.meta['embeds'] as List<dynamic>,
                            isInteractive: true,
                            isFullPost: false,
                            renderingPadding: EdgeInsets.zero,
                            maxWidth: 480,
                          ),
                        FileUploadProgressWidget(
                          progress: progress,
                          textColor: textColor,
                          hasContent:
                              remoteMessage.content?.isNotEmpty ?? false,
                        ),
                      ],
                    ),
                  ),
                ),
                MessageIndicators(
                  editedAt: remoteMessage.editedAt,
                  status: message.status,
                  isCurrentUser: isCurrentUser,
                  textColor: textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageItemDisplayIRC extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final Function(String messageId) onJump;
  final String? translatedText;
  final bool translating;

  const MessageItemDisplayIRC({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.progress,
    required this.showAvatar,
    required this.onJump,
    required this.translatedText,
    required this.translating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final isMultiline =
        message.type == 'text' ||
        message.repliedMessageId != null ||
        message.forwardedMessageId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(message.createdAt.toLocal()),
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ).padding(top: isMultiline ? 2 : 0),
          AccountPfcRegion(
            uname: sender.account.name,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfilePictureWidget(
                  file: sender.account.profile.picture,
                  radius: 8,
                ).padding(horizontal: 6, top: isMultiline ? 2 : 0),
                Text(
                  sender.account.nick,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (remoteMessage.repliedMessageId != null)
                        MessageQuoteWidget(
                          message: message,
                          textColor: textColor,
                          isReply: true,
                        ).padding(vertical: 4),
                      if (remoteMessage.forwardedMessageId != null)
                        MessageQuoteWidget(
                          message: message,
                          textColor: textColor,
                          isReply: false,
                        ).padding(vertical: 4),
                      if (MessageContent.hasContent(remoteMessage))
                        MessageContent(
                          item: remoteMessage,
                          translatedText: translatedText,
                        ),
                      if (remoteMessage.attachments.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return CloudFileList(
                              files: remoteMessage.attachments,
                              maxWidth: constraints.maxWidth,
                              padding: EdgeInsets.symmetric(vertical: 4),
                            );
                          },
                        ),
                      if (remoteMessage.meta['embeds'] != null &&
                          kMessageEnableEmbedTypes.contains(message.type))
                        EmbedListWidget(
                          embeds: remoteMessage.meta['embeds'] as List<dynamic>,
                          isInteractive: true,
                          isFullPost: false,
                          renderingPadding: EdgeInsets.zero,
                          maxWidth: 480,
                        ),
                      FileUploadProgressWidget(
                        progress: progress,
                        textColor: textColor,
                        hasContent: remoteMessage.content?.isNotEmpty ?? false,
                      ),
                    ],
                  ),
                ),
                MessageIndicators(
                  editedAt: remoteMessage.editedAt,
                  status: message.status,
                  isCurrentUser: isCurrentUser,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageItemDisplayDiscord extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final Function(String messageId) onJump;
  final String? translatedText;
  final bool translating;

  const MessageItemDisplayDiscord({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.progress,
    required this.showAvatar,
    required this.onJump,
    required this.translatedText,
    required this.translating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;

    const kAvatarRadius = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: showAvatar
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    AccountPfcRegion(
                      uname: sender.account.name,
                      child: ProfilePictureWidget(
                        file: sender.account.profile.picture,
                        radius: kAvatarRadius,
                      ),
                    ),
                    MessageSenderInfo(
                      sender: sender,
                      createdAt: message.createdAt,
                      textColor: textColor,
                      showAvatar: false,
                      isCompact: true,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (remoteMessage.repliedMessageId != null)
                            MessageQuoteWidget(
                              message: message,
                              textColor: textColor,
                              isReply: true,
                            ).padding(vertical: 4),
                          if (remoteMessage.forwardedMessageId != null)
                            MessageQuoteWidget(
                              message: message,
                              textColor: textColor,
                              isReply: false,
                            ).padding(vertical: 4),
                          if (MessageContent.hasContent(remoteMessage))
                            MessageContent(
                              item: remoteMessage,
                              translatedText: translatedText,
                            ),
                          if (remoteMessage.attachments.isNotEmpty)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return CloudFileList(
                                  files: remoteMessage.attachments,
                                  maxWidth: constraints.maxWidth,
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                );
                              },
                            ),
                          if (remoteMessage.meta['embeds'] != null &&
                              kMessageEnableEmbedTypes.contains(message.type))
                            EmbedListWidget(
                              embeds:
                                  remoteMessage.meta['embeds'] as List<dynamic>,
                              isInteractive: true,
                              isFullPost: false,
                              renderingPadding: EdgeInsets.zero,
                              maxWidth: 480,
                            ),
                          FileUploadProgressWidget(
                            progress: progress,
                            textColor: textColor,
                            hasContent:
                                remoteMessage.content?.isNotEmpty ?? false,
                          ),
                        ],
                      ),
                    ),
                    MessageIndicators(
                      editedAt: remoteMessage.editedAt,
                      status: message.status,
                      isCurrentUser: isCurrentUser,
                      textColor: textColor,
                    ),
                  ],
                ).padding(left: kAvatarRadius * 2 + 8),
              ],
            )
          : Padding(
              padding: EdgeInsets.only(left: kAvatarRadius * 2 + 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (remoteMessage.repliedMessageId != null)
                          MessageQuoteWidget(
                            message: message,
                            textColor: textColor,
                            isReply: true,
                          ).padding(vertical: 4),
                        if (remoteMessage.forwardedMessageId != null)
                          MessageQuoteWidget(
                            message: message,
                            textColor: textColor,
                            isReply: false,
                          ).padding(vertical: 4),
                        if (MessageContent.hasContent(remoteMessage))
                          MessageContent(
                            item: remoteMessage,
                            translatedText: translatedText,
                          ),
                        if (remoteMessage.attachments.isNotEmpty)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CloudFileList(
                                files: remoteMessage.attachments,
                                maxWidth: constraints.maxWidth,
                                padding: EdgeInsets.symmetric(vertical: 4),
                              );
                            },
                          ),
                        if (remoteMessage.meta['embeds'] != null &&
                            kMessageEnableEmbedTypes.contains(message.type))
                          EmbedListWidget(
                            embeds:
                                remoteMessage.meta['embeds'] as List<dynamic>,
                            isInteractive: true,
                            isFullPost: false,
                            renderingPadding: EdgeInsets.zero,
                            maxWidth: 480,
                          ),
                        FileUploadProgressWidget(
                          progress: progress,
                          textColor: textColor,
                          hasContent:
                              remoteMessage.content?.isNotEmpty ?? false,
                        ),
                      ],
                    ),
                  ),
                  MessageIndicators(
                    editedAt: remoteMessage.editedAt,
                    status: message.status,
                    isCurrentUser: isCurrentUser,
                    textColor: textColor,
                  ),
                ],
              ),
            ),
    );
  }
}

class MessageQuoteWidget extends HookConsumerWidget {
  final LocalChatMessage message;
  final Color textColor;
  final bool isReply;

  const MessageQuoteWidget({
    super.key,
    required this.message,
    required this.textColor,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesNotifier = ref.watch(
      messagesProvider(message.roomId).notifier,
    );

    return FutureBuilder<LocalChatMessage?>(
      future: messagesNotifier.fetchMessageById(
        isReply
            ? message.toRemoteMessage().repliedMessageId!
            : message.toRemoteMessage().forwardedMessageId!,
      ),
      builder: (context, snapshot) {
        final remoteMessage = snapshot.hasData
            ? snapshot.data!.toRemoteMessage()
            : null;

        if (remoteMessage != null) {
          return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: GestureDetector(
              onTap: () {
                final messageId = isReply
                    ? message.toRemoteMessage().repliedMessageId!
                    : message.toRemoteMessage().forwardedMessageId!;
                // Find the nearest MessageItem ancestor and call its onJump method
                final MessageItem? ancestor = context
                    .findAncestorWidgetOfExactType<MessageItem>();
                if (ancestor != null) {
                  ancestor.onJump(messageId);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                color: Theme.of(
                  context,
                ).colorScheme.primaryFixedDim.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReply)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Icon(Symbols.reply, size: 16, color: textColor),
                          Text(
                            '${'repliedTo'.tr()} ${remoteMessage.sender.account.nick}',
                          ).textColor(textColor).bold(),
                        ],
                      ).padding(right: 8)
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Icon(Symbols.forward, size: 16, color: textColor),
                          Text(
                            '${'forwarded'.tr()} ${remoteMessage.sender.account.nick}',
                          ).textColor(textColor).bold(),
                        ],
                      ).padding(right: 8),
                    if (MessageContent.hasContent(remoteMessage))
                      MessageContent(item: remoteMessage),
                    if (remoteMessage.attachments.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.attach_file, size: 12, color: textColor),
                          const SizedBox(width: 4),
                          Text(
                            'hasAttachments'.plural(
                              remoteMessage.attachments.length,
                            ),
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                        ],
                      ).padding(vertical: 2),
                  ],
                ),
              ),
            ),
          ).padding(bottom: 4);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}

class FileUploadProgressWidget extends StatelessWidget {
  final Map<int, double?>? progress;
  final Color textColor;
  final bool hasContent;

  const FileUploadProgressWidget({
    super.key,
    required this.progress,
    required this.textColor,
    required this.hasContent,
  });

  @override
  Widget build(BuildContext context) {
    if (progress == null || progress!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (hasContent) const Gap(0),
        for (var entry in progress!.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'fileUploadingProgress'.tr(
                  args: [
                    (entry.key + 1).toString(),
                    entry.value != null
                        ? (entry.value! * 100).toStringAsFixed(1)
                        : '0.0',
                  ],
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const Gap(4),
              LinearProgressIndicator(
                value: entry.value,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                trackGap: 0,
              ),
            ],
          ),
        const Gap(0),
      ],
    );
  }
}
