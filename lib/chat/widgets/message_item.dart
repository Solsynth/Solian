import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/e2ee_message_display.dart';
import 'package:island/chat/models/redirect_data.dart';
import 'package:island/chat/widgets/message_content.dart';
import 'package:island/chat/widgets/chat_message_reaction_sheet.dart';
import 'package:island/chat/widgets/chat_thread_sheet.dart';
import 'package:island/chat/widgets/message_bubble_shape.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/widgets/message_indicators.dart';
import 'package:island/chat/widgets/message_sender_info.dart';
import 'package:island/chat/widgets/online_avatar_badge.dart';
import 'package:island/chat/widgets/sticky_avatar_box.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/data/message.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/translate.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/embeds/embed_list.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final kTextSelectable = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Body type for a message in every display style.
///
/// The size is the app's own body scale: chat reads at the same size as the
/// rest of the app. Only the leading is loosened slightly, because a message
/// column is narrow and lines wrap often. The colour is passed in because it
/// differs per style and per direction.
TextStyle chatMessageBodyStyle(BuildContext context, Color color) {
  return Theme.of(
    context,
  ).textTheme.bodyMedium!.copyWith(height: 1.45, color: color);
}

class MessageItemAction {
  static const String edit = "edit";
  static const String delete = "delete";
  static const String reply = "reply";
  static const String replyInThread = "reply_in_thread";
  static const String forward = "forward";
  static const String resend = "resend";
  static const String redirect = "redirect";
  static const String pin = "pin";
  static const String unpin = "unpin";
}

Map<String, int> getMessageReactionsCount(LocalChatMessage message) {
  final raw = message.data['reactions_count'];
  if (raw is! Map) return {};
  return raw.map((key, value) {
    final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return MapEntry(key.toString(), count);
  });
}

Map<String, bool> getMessageReactionsMade(LocalChatMessage message) {
  final raw = message.data['reactions_made'];
  if (raw is! Map) return {};
  return raw.map((key, value) => MapEntry(key.toString(), value == true));
}

/// Left inset of the accessories that hang below a message row (reaction
/// chips, thread chip, pinned label).
///
/// Bubble mode aligns them with the bubble's own left edge, which is the row
/// inset plus the avatar gutter. That offset is owned by
/// [MessageItemDisplayBubble.contentOffset]; hardcoding a copy of it here is
/// how the chips drift left as soon as the avatar changes size.
double _messageAccessoryLeftPadding(String displayStyle) {
  return switch (displayStyle) {
    'compact' => 12,
    'column' => 44,
    _ => 12 + MessageItemDisplayBubble.contentOffset,
  };
}

class MessageItem extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final bool showBubbleAvatar;
  final bool showColumnAvatar;

  /// Whether this message is the newest message of its sender group: no
  /// same-sender message sits below it on screen.
  final bool isFirstInGroup;

  /// Whether this message is the oldest message of its sender group: no
  /// same-sender message sits above it on screen. Equal to [showAvatar].
  final bool isLastInGroup;
  final GlobalKey<State<StatefulWidget>>? avatarAnchorKey;
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
    this.showBubbleAvatar = true,
    this.showColumnAvatar = true,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.avatarAnchorKey,
    required this.onJump,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
    this.onEnterSelectionMode,
  });

  static const kFlashStepDuration = 120;
  static const kFlashAnimationDuration = 100;

  bool get _hasSelectableText {
    final remoteMessage = message.toRemoteMessage();
    final resolvedDisplay = resolveE2eeDisplayContentForMessage(remoteMessage);
    final content = resolvedDisplay.content?.trim() ?? '';
    return content.isNotEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteMessage = message.toRemoteMessage();
    final resolvedDisplay = resolveE2eeDisplayContentForMessage(remoteMessage);
    final settings = ref.watch(appSettingsProvider);
    final messagesNotifier = ref.read(
      messagesProvider(message.roomId).notifier,
    );

    final isPinned = messagesNotifier.isMessagePinned(message.id);
    final roomAsync = ref.watch(chatRoomProvider(message.roomId));
    final identityAsync = ref.watch(chatRoomIdentityProvider(message.roomId));
    final room = roomAsync.value;
    final identity = identityAsync.value;
    final canPin = room == null
        ? false
        : room.type ==
              1 // DM: any member can pin
        ? true
        : room.accountId == identity?.accountId; // Group: owner only

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final swipeEnabled = isMobile && onAction != null && !isSelectionMode;

    final currentLanguage = context.locale.toString();
    final translatableLanguage = resolvedDisplay.content?.isNotEmpty ?? false;

    final translating = useState(false);
    final translatedText = useState<String?>(null);

    Future<void> translate() async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }

      if (translating.value) return;
      final sourceText = resolvedDisplay.content;
      if (sourceText == null || sourceText.isEmpty) return;
      translating.value = true;
      try {
        final text = await ref.watch(
          translateStringProvider(
            TranslateQuery(
              text: sourceText,
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

    final flashToken = ref.watch(
      flashingMessagesProvider.select((map) => map[message.id]),
    );

    final flashOpacity = useState(0.0);
    final flashTimer = useState<Timer?>(null);

    useEffect(() {
      if (flashToken != null) {
        const pulseSequence = [1.0, 0.0, 0.82, 0.0, 0.55, 0.0];
        var step = 0;

        flashTimer.value?.cancel();
        flashOpacity.value = pulseSequence[step];

        flashTimer.value = Timer.periodic(
          const Duration(milliseconds: kFlashStepDuration),
          (timer) {
            step++;
            if (step >= pulseSequence.length) {
              timer.cancel();
              flashTimer.value = null;
              flashOpacity.value = 0;
              ref
                  .read(flashingMessagesProvider.notifier)
                  .clearMessage(message.id);
              return;
            }
            flashOpacity.value = pulseSequence[step];
          },
        );
      } else {
        flashTimer.value?.cancel();
        flashTimer.value = null;
        flashOpacity.value = 0;
      }
      return () {
        flashTimer.value?.cancel();
      };
    }, [flashToken, message.id, ref]);

    final flashColor = Theme.of(
      context,
    ).colorScheme.primaryContainer.withOpacity(0.34 * flashOpacity.value);

    final isHovered = useState(false);
    final reacting = useState(false);
    final isSystemInfoExpanded = useState(false);
    final swipeProgress = useState(0.0);
    final reactionsCount = getMessageReactionsCount(message);
    final reactionsMade = getMessageReactionsMade(message);

    Future<void> reactMessage(String symbol, int attitude) async {
      if (reacting.value) return;
      reacting.value = true;
      await messagesNotifier.reactToMessage(
        message.id,
        symbol: symbol,
        attitude: attitude,
      );
      reacting.value = false;
    }

    void openReactionSheet({int initialTabIndex = 0}) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => ChatMessageReactionSheet(
          reactionsCount: reactionsCount,
          reactionsMade: reactionsMade,
          onReact: reactMessage,
          roomId: message.roomId,
          messageId: message.id,
          initialTabIndex: initialTabIndex,
        ),
      );
    }

    Widget buildReactionChips({bool insideBubble = false}) =>
        MessageReactionChips(
          displayStyle: settings.messageDisplayStyle,
          isCurrentUser: isCurrentUser,
          showAvatar: showAvatar,
          reactionsCount: reactionsCount,
          reactionsMade: reactionsMade,
          isExpanded: isSystemInfoExpanded.value,
          submitting: reacting.value,
          onReact: reactMessage,
          insideBubble: insideBubble,
        );

    void openReactionHistorySheet() {
      openReactionSheet(initialTabIndex: 1);
    }

    void showActionMenu() {
      if (onAction == null) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => MessageActionSheet(
          isCurrentUser: isCurrentUser,
          isPinned: isPinned,
          canPin: canPin,
          onAction: onAction,
          onReact: openReactionSheet,
          onReactionHistory: openReactionHistorySheet,
          onQuickReact: reactMessage,
          reactionsCount: reactionsCount,
          reactionsMade: reactionsMade,
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

    Widget buildSwipeHintBackground({
      required bool isStartToEnd,
      required IconData icon,
    }) {
      final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
      return LayoutBuilder(
        builder: (context, constraints) {
          const iconSize = 20.0;
          const edgePadding = 10.0;
          final progress = isStartToEnd
              ? swipeProgress.value.clamp(0.0, 1.0)
              : (-swipeProgress.value).clamp(0.0, 1.0);
          final revealedWidth = progress * constraints.maxWidth;
          final distance = (revealedWidth - iconSize - edgePadding).clamp(
            0.0,
            constraints.maxWidth - iconSize - edgePadding,
          );

          return Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: isStartToEnd ? distance : null,
                right: isStartToEnd ? null : distance,
                child: Icon(icon, color: iconColor, size: iconSize),
              ),
            ],
          );
        },
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Dismissible(
          key: ValueKey(
            'message-swipe-${message.clientMessageId ?? message.id}',
          ),
          direction: swipeEnabled
              ? DismissDirection.horizontal
              : DismissDirection.none,
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.35,
            DismissDirection.endToStart: 0.35,
          },
          resizeDuration: null,
          movementDuration: const Duration(milliseconds: 120),
          background: buildSwipeHintBackground(
            isStartToEnd: true,
            icon: Symbols.menu_open,
          ),
          secondaryBackground: buildSwipeHintBackground(
            isStartToEnd: false,
            icon: isCurrentUser ? Symbols.forward : Symbols.reply,
          ),
          onUpdate: swipeEnabled
              ? (details) {
                  final direction = details.direction;
                  if (direction == DismissDirection.startToEnd) {
                    swipeProgress.value = details.progress.clamp(0.0, 1.0);
                  } else if (direction == DismissDirection.endToStart) {
                    swipeProgress.value = -details.progress.clamp(0.0, 1.0);
                  } else {
                    swipeProgress.value = 0.0;
                  }
                }
              : null,
          confirmDismiss: swipeEnabled
              ? (direction) async {
                  swipeProgress.value = 0.0;
                  if (direction == DismissDirection.startToEnd) {
                    showActionMenu();
                  } else if (direction == DismissDirection.endToStart) {
                    if (isCurrentUser) {
                      onAction!(MessageItemAction.forward);
                    } else {
                      onAction!(MessageItemAction.reply);
                    }
                  }
                  return false;
                }
              : null,
          child: ContextMenuWidget(
            previewBuilder: contextMenuPreviewBuilder,
            menuProvider: (_) {
              return Menu(
                children: [
                  if (!isCurrentUser)
                    MenuAction(
                      title: 'reply'.tr(),
                      image: MenuImage.icon(Symbols.reply),
                      callback: () => onAction?.call(MessageItemAction.reply),
                    ),
                  MenuAction(
                    title: 'replyInThread'.tr(),
                    image: MenuImage.icon(Symbols.forum),
                    callback: () =>
                        onAction?.call(MessageItemAction.replyInThread),
                  ),
                  MenuAction(
                    title: 'forward'.tr(),
                    image: MenuImage.icon(Symbols.forward),
                    callback: () => onAction?.call(MessageItemAction.forward),
                  ),
                  if (message.type == 'text')
                    MenuAction(
                      title: 'redirect'.tr(),
                      image: MenuImage.icon(Symbols.send),
                      callback: () =>
                          onAction?.call(MessageItemAction.redirect),
                    ),
                  MenuAction(
                    title: 'react'.tr(),
                    image: MenuImage.icon(Symbols.add_reaction),
                    callback: () => openReactionSheet(),
                  ),
                  if (_hasSelectableText)
                    MenuAction(
                      title: 'chatSelectText'.tr(),
                      image: MenuImage.icon(Symbols.text_select_start),
                      callback: () {
                        final text =
                            translatedText.value ??
                            resolvedDisplay.content ??
                            '';
                        if (text.trim().isEmpty) return;
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            barrierColor: Colors.black54,
                            transitionDuration: const Duration(
                              milliseconds: 260,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 220,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    _MessageTextSelectionView(
                                      text: text,
                                      sender: remoteMessage.sender,
                                      roomId: message.roomId,
                                      sentAt: message.createdAt.formatSystem(),
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  final curved = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  );
                                  return FadeTransition(
                                    opacity: curved,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.06),
                                        end: Offset.zero,
                                      ).animate(curved),
                                      child: child,
                                    ),
                                  );
                                },
                          ),
                        );
                      },
                    ),
                  MenuAction(
                    title: 'chatSelectMessages'.tr(),
                    image: MenuImage.icon(Symbols.select_all),
                    callback: () {
                      if (onEnterSelectionMode != null) {
                        onEnterSelectionMode!();
                        if (onToggleSelection != null) {
                          onToggleSelection!(message.id);
                        }
                      }
                    },
                  ),
                  if (canPin)
                    MenuAction(
                      title: isPinned ? 'unpinMessage'.tr() : 'pinMessage'.tr(),
                      image: MenuImage.icon(
                        isPinned ? Icons.push_pin_outlined : Symbols.push_pin,
                      ),
                      callback: () => onAction?.call(
                        isPinned
                            ? MessageItemAction.unpin
                            : MessageItemAction.pin,
                      ),
                    ),
                  if (translatableLanguage)
                    MenuAction(
                      title: translatedText.value?.isEmpty == null
                          ? 'translate'.tr()
                          : 'translated'.tr(),
                      image: MenuImage.icon(Symbols.translate),
                      callback: translate,
                    ),
                  if (isCurrentUser)
                    MenuAction(
                      title: 'edit'.tr(),
                      image: MenuImage.icon(Symbols.edit),
                      callback: () => onAction?.call(MessageItemAction.edit),
                    ),
                  if (isCurrentUser && message.status == MessageStatus.failed)
                    MenuAction(
                      title: 'resend'.tr(),
                      image: MenuImage.icon(Symbols.refresh),
                      callback: () => onAction?.call(MessageItemAction.resend),
                    ),
                  if (isCurrentUser)
                    MenuAction(
                      title: 'delete'.tr(),
                      image: MenuImage.icon(Symbols.delete),
                      callback: () => onAction?.call(MessageItemAction.delete),
                    ),
                ],
              );
            },
            child: InkWell(
              mouseCursor: MouseCursor.defer,
              focusColor: Colors.transparent,
              onSecondaryTap: isMobile ? showActionMenu : null,
              onTap: () {
                if (isSelectionMode && onToggleSelection != null) {
                  onToggleSelection!(message.id);
                } else {
                  // Jump to related message
                  if ([
                        'messages.update',
                        'messages.delete',
                        'messages.reaction.added',
                        'messages.reaction.removed',
                        'messages.pinned',
                        'messages.unpinned',
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
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isPinned)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: _messageAccessoryLeftPadding(
                                    settings.messageDisplayStyle,
                                  ),
                                  right: 16,
                                  bottom: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Symbols.push_pin,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'pinnedMessage'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            switch (settings.messageDisplayStyle) {
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
                                showColumnAvatar: showColumnAvatar,
                                avatarAnchorKey: avatarAnchorKey,
                                onJump: onJump,
                                translatedText: translatedText.value,
                                translating: translating.value,
                              ),
                              _ => MessageItemDisplayBubble(
                                message: message,
                                isCurrentUser: isCurrentUser,
                                progress: progress,
                                showAvatar: showAvatar,
                                showBubbleAvatar: showBubbleAvatar,
                                isFirstInGroup: isFirstInGroup,
                                isLastInGroup: isLastInGroup,
                                avatarAnchorKey: avatarAnchorKey,
                                onJump: onJump,
                                translatedText: translatedText.value,
                                translating: translating.value,
                                // Bubble mode carries the chips inside the
                                // bubble; the other styles keep them below.
                                reactions: buildReactionChips(
                                  insideBubble: true,
                                ),
                              ),
                            },
                            if (settings.messageDisplayStyle == 'compact' ||
                                settings.messageDisplayStyle == 'column')
                              buildReactionChips(),
                            ThreadRepliesChip(
                              roomId: message.roomId,
                              messageId: message.id,
                              replyCount: remoteMessage.threadRepliesCount,
                              rootContent: remoteMessage.content ?? '',
                              rootSenderName: remoteMessage.sender.account.nick,
                              onJump: onJump,
                              onOpenThread: () => onAction?.call(
                                MessageItemAction.replyInThread,
                              ),
                              leftPadding: _messageAccessoryLeftPadding(
                                settings.messageDisplayStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            curve: Curves.easeInOut,
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(
                                    milliseconds: kFlashAnimationDuration,
                                  ),
                            decoration: BoxDecoration(color: flashColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isHovered.value && !isMobile && !isSelectionMode)
          Positioned(
            top: 4,
            right: 8,
            child: MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: MessageHoverActionMenu(
                isCurrentUser: isCurrentUser,
                isPinned: isPinned,
                canPin: canPin,
                onAction: onAction,
                onReact: openReactionSheet,
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
  final bool isPinned;
  final bool canPin;
  final Function(String action)? onAction;
  final VoidCallback onReact;
  final VoidCallback onReactionHistory;
  final Future<void> Function(String symbol, int attitude) onQuickReact;
  final Map<String, int> reactionsCount;
  final Map<String, bool> reactionsMade;
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
    required this.isPinned,
    required this.canPin,
    required this.onAction,
    required this.onReact,
    required this.onReactionHistory,
    required this.onQuickReact,
    required this.reactionsCount,
    required this.reactionsMade,
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
  E2eeDisplayContent get _resolved => resolveE2eeDisplayContent(
    roomId: widget.message.roomId,
    content:
        widget.translatedText ??
        widget.remoteMessage.content ??
        widget.message.content,
    meta: widget.message.meta,
  );

  bool get _isEncryptedMessage => _resolved.isEncrypted;

  String get _displayContent {
    final base = _resolved.content;
    if (base != null && base.isNotEmpty) return base;
    if (_resolved.decryptFailed) return '[Unable to decrypt this message]';
    if (_isEncryptedMessage) return '[Encrypted message has no text content]';
    return '';
  }

  bool get _hasSelectableText {
    final content = _resolved.content?.trim() ?? '';
    return content.isNotEmpty;
  }

  Future<void> _openTextSelectionView() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _MessageTextSelectionView(
              text: _displayContent,
              sender: widget.remoteMessage.sender,
              roomId: widget.message.roomId,
              sentAt: widget.message.createdAt.formatSystem(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const quickReactions = [
      'thumb_up',
      'heart',
      'laugh',
      'clap',
      'party',
      'confuse',
    ];
    final primaryActions = <Widget>[
      _ActionListTile(
        leading: Icon(Symbols.reply),
        title: Text('reply'.tr()),
        onTap: () {
          widget.onAction!.call(MessageItemAction.reply);
          Navigator.pop(context);
        },
      ),
      _ActionListTile(
        leading: const Icon(Symbols.forum),
        title: Text('replyInThread'.tr()),
        onTap: () {
          widget.onAction!.call(MessageItemAction.replyInThread);
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
      if (widget.message.type == 'text')
        _ActionListTile(
          leading: Icon(Symbols.send),
          title: Text('redirect'.tr()),
          onTap: () {
            widget.onAction!.call(MessageItemAction.redirect);
            Navigator.pop(context);
          },
        ),
      _ActionListTile(
        leading: const Icon(Symbols.add_reaction),
        title: Text('react'.tr()),
        onTap: () {
          Navigator.pop(context);
          widget.onReact();
        },
      ),
      _ActionListTile(
        leading: const Icon(Symbols.history),
        title: Text('reactionHistory'.tr()),
        onTap: () {
          Navigator.pop(context);
          widget.onReactionHistory();
        },
      ),
      if (_hasSelectableText)
        _ActionListTile(
          leading: const Icon(Symbols.text_select_start),
          title: Text('chatSelectText'.tr()),
          onTap: () {
            Navigator.pop(context);
            _openTextSelectionView();
          },
        ),
      _ActionListTile(
        leading: Icon(Symbols.select_all),
        title: Text('chatSelectMessages'.tr()),
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
      if (widget.canPin)
        _ActionListTile(
          leading: Icon(
            widget.isPinned ? Icons.push_pin_outlined : Symbols.push_pin,
          ),
          title: Text(
            widget.isPinned ? 'unpinMessage'.tr() : 'pinMessage'.tr(),
          ),
          onTap: () {
            widget.onAction!.call(
              widget.isPinned ? MessageItemAction.unpin : MessageItemAction.pin,
            );
            Navigator.pop(context);
          },
        ),
    ];
    final authorActions = <Widget>[
      if (widget.isCurrentUser)
        _ActionListTile(
          leading: Icon(Symbols.edit),
          title: Text('edit'.tr()),
          onTap: () {
            widget.onAction!.call(MessageItemAction.edit);
            Navigator.pop(context);
          },
        ),
      if (widget.isCurrentUser && widget.message.status == MessageStatus.failed)
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
          isDanger: true,
        ),
    ];
    final utilityActions = <Widget>[
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
      if (widget.isMobile)
        _ActionListTile(
          leading: Icon(Symbols.copy_all),
          title: Text('copyMessage'.tr()),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _displayContent));
            Navigator.pop(context);
          },
        ),
    ];

    return SheetScaffold(
      titleText: 'messageActions'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    for (final symbol in quickReactions)
                      _QuickReactionChip(
                        symbol: symbol,
                        count: widget.reactionsCount[symbol] ?? 0,
                        isMade: widget.reactionsMade[symbol] == true,
                        onTap: () async {
                          await widget.onQuickReact(
                            symbol,
                            kReactionTemplates[symbol]?.attitude ?? 1,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (primaryActions.isNotEmpty)
              _ActionSection(children: primaryActions),
            if (authorActions.isNotEmpty)
              _ActionSection(children: authorActions),
            if (utilityActions.isNotEmpty)
              _ActionSection(children: utilityActions),
            Gap(MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final List<Widget> children;

  const _ActionSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SolSpace.md,
        SolSpace.sm,
        SolSpace.md,
        0,
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: SolRadius.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _ActionListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionListTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isDanger
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: SolRadius.controlRadius,
      child: Padding(
        // 12px vertical keeps the row a comfortable target without the
        // stretch that makes a six-item sheet feel like a settings page.
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.lg,
          vertical: SolSpace.md,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: Row(
              children: [
                SizedBox(width: 24, height: 24, child: leading),
                const Gap(SolSpace.md),
                Expanded(child: title),
                Icon(
                  Symbols.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickReactionChip extends StatelessWidget {
  final String symbol;
  final int count;
  final bool isMade;
  final VoidCallback onTap;

  const _QuickReactionChip({
    required this.symbol,
    required this.count,
    required this.isMade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isMade
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHigh;
    final foregroundColor = isMade
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final borderColor = isMade
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : Colors.transparent;
    final label = ReactInfo.getTranslationKey(symbol).tr();

    // Icon and tally only. Spelling out "Thumbs Up" on six chips turned the
    // reaction row into a sentence; the glyph is the label, and the name is
    // kept for screen readers and the long-press tooltip.
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: SolRadius.pillRadius,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: count > 0 ? 12 : 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: SolRadius.pillRadius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildReactionIcon(symbol, 22, iconSize: 18),
                if (count > 0) ...[
                  const Gap(6),
                  Text(
                    count.toString(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTextSelectionView extends HookConsumerWidget {
  final String text;
  final SnChatMember sender;
  final String roomId;
  final String sentAt;

  const _MessageTextSelectionView({
    required this.text,
    required this.sender,
    required this.roomId,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 300) {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 72, 20, 72),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: MarkdownTextContent(
                                content: text,
                                isSelectable: true,
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  height: 1.6,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    ChatRoomMemberRegion(
                      roomId: roomId,
                      member: sender,
                      child: ProfilePictureWidget(
                        file: sender.account.profile.picture,
                        fallbackName: sender.account.nick,
                        radius: 14,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AccountName(
                            textOverride: (sender.nick?.isNotEmpty == true)
                                ? sender.nick
                                : (sender.realmNick?.isNotEmpty == true)
                                ? sender.realmNick
                                : sender.account.nick,
                            account: sender.account,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            sentAt,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        showSnackBar('copiedToClipboard'.tr());
                      },
                      icon: const Icon(Symbols.copy_all),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Symbols.close, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageHoverActionMenu extends StatelessWidget {
  final bool isCurrentUser;
  final bool isPinned;
  final bool canPin;
  final Function(String action)? onAction;
  final VoidCallback onReact;
  final bool translatableLanguage;
  final bool translating;
  final String? translatedText;
  final VoidCallback translate;
  final dynamic remoteMessage;

  const MessageHoverActionMenu({
    super.key,
    required this.isCurrentUser,
    required this.isPinned,
    required this.canPin,
    required this.onAction,
    required this.onReact,
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
      IconButton(
        icon: const Icon(Symbols.add_reaction, size: 16),
        onPressed: onReact,
        tooltip: 'react'.tr(),
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
      if (canPin)
        IconButton(
          icon: Icon(
            isPinned ? Icons.push_pin_outlined : Symbols.push_pin,
            size: 16,
          ),
          onPressed: () => onAction?.call(
            isPinned ? MessageItemAction.unpin : MessageItemAction.pin,
          ),
          tooltip: isPinned ? 'unpinMessage'.tr() : 'pinMessage'.tr(),
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

class MessageReactionChips extends HookConsumerWidget {
  final String displayStyle;
  final bool isCurrentUser;
  final bool showAvatar;
  final Map<String, int> reactionsCount;
  final Map<String, bool> reactionsMade;
  final bool isExpanded;
  final bool submitting;

  /// Renders the chips inside the message bubble instead of below it. The
  /// bubbles' own horizontal padding is narrower than the below-the-bubble
  /// gutter (which also offsets the avatar), so the padding differs.
  final bool insideBubble;
  final Future<void> Function(String symbol, int attitude) onReact;

  const MessageReactionChips({
    super.key,
    required this.displayStyle,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.reactionsCount,
    required this.reactionsMade,
    required this.isExpanded,
    required this.submitting,
    required this.onReact,
    this.insideBubble = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reactionsCount.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseUrl = ref.watch(serverUrlProvider);
    final orderedSymbols = reactionsCount.keys.toList()
      ..sort(
        (a, b) => (reactionsCount[b] ?? 0).compareTo(reactionsCount[a] ?? 0),
      );

    final sectionPadding = insideBubble
        ? const EdgeInsets.only(left: 10, right: 10, bottom: 6)
        : EdgeInsets.only(
            left: _messageAccessoryLeftPadding(displayStyle),
            right: 12,
            bottom: displayStyle == 'compact' ? 2 : 6,
          );
    final sectionAlign = Alignment.centerLeft;

    return Align(
      alignment: sectionAlign,
      // A plain [Align] expands to the incoming max width. Inside a bubble the
      // chips are a child of the bubble's own column, so that expansion would
      // stretch the bubble out to the full row width as soon as a reaction
      // exists. Hugging the content keeps the bubble sized to its content.
      widthFactor: 1,
      child: Padding(
        padding: sectionPadding,
        child: reactionsCount.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final symbol in orderedSymbols)
                    InkWell(
                      onTap: submitting
                          ? null
                          : () {
                              onReact(
                                symbol,
                                kReactionTemplates[symbol]?.attitude ?? 1,
                              );
                            },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: reactionsMade[symbol] == true
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: reactionsMade[symbol] == true
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (symbol.contains('+'))
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: UniversalImage(
                                  uri:
                                      '$baseUrl/sphere/stickers/lookup/$symbol/open',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                ),
                              )
                            else
                              buildReactionIcon(symbol, 18, iconSize: 13),
                            const SizedBox(width: 5),
                            // The count alone: "x3" adds a glyph that reads as
                            // syntax. A number next to a reaction is already
                            // understood as its tally.
                            Text(
                              '${reactionsCount[symbol] ?? 0}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: reactionsMade[symbol] == true
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ).padding(top: 4)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class MessageItemDisplayBubble extends HookConsumerWidget {
  static const double _avatarRadius = 18;
  static const double _avatarSize = _avatarRadius * 2;
  static const double _avatarGap = 8;

  /// Radius of the sender avatar drawn in the row's gutter. Public because
  /// the grouped layout draws the same avatar from the list, outside this
  /// widget; a second copy of the number there would drift.
  static const double avatarRadius = _avatarRadius;

  /// Distance from the row's left edge to the bubble's left edge: the avatar
  /// plus the gap that separates it from the bubble.
  static const double contentOffset = _avatarSize + _avatarGap;

  /// Inset inside the bubble. Same numbers as before the redesign: the text
  /// block is what the reader scans, so its rhythm is left alone.
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(10, 6, 10, 6);

  /// Vertical gap between two bubbles of the same sender group. Small enough
  /// that the squared corners still read as one connected block.
  static const double _groupGap = 1;

  /// Vertical gap around a sender group.
  static const double _groupOuterGap = 5;

  final LocalChatMessage message;
  final bool isCurrentUser;
  final Map<int, double?>? progress;
  final bool showAvatar;
  final bool showBubbleAvatar;

  /// Newest message of its sender group: no same-sender bubble below.
  final bool isFirstInGroup;

  /// Oldest message of its sender group: no same-sender bubble above. The
  /// avatar sits next to this bubble, so it carries the tail.
  final bool isLastInGroup;
  final GlobalKey<State<StatefulWidget>>? avatarAnchorKey;
  final Function(String messageId) onJump;
  final String? translatedText;
  final bool translating;

  /// Reaction chips rendered inside the bubble body (bubble display style).
  final Widget? reactions;

  const MessageItemDisplayBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.progress,
    required this.showAvatar,
    required this.showBubbleAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.avatarAnchorKey,
    required this.onJump,
    required this.translatedText,
    required this.translating,
    this.reactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Body text is the message: it sits at full contrast in both directions.
    // The previous `onSurfaceVariant` greyed every incoming message by a step,
    // which read as "disabled" next to the outgoing bubbles.
    final textColor = isCurrentUser
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    // Both directions are one tonal step above the page: incoming on the
    // higher surface so it lifts off the paper, outgoing in the accent
    // container held back from full saturation so a long thread of your own
    // messages does not shout.
    final containerColor = isCurrentUser
        ? colorScheme.primaryContainer.withValues(alpha: 0.72)
        : colorScheme.surfaceContainerHigh;

    final bodyStyle = chatMessageBodyStyle(context, textColor);

    // Group geometry: the avatar sits at the top of the group, so the corner
    // closest to it is the top-left of the oldest bubble. The corners where
    // consecutive bubbles of the group meet are squared so the group reads as
    // one connected unit.
    final connectsAbove = !isLastInGroup; // Older group bubble above.
    final connectsBelow = !isFirstInGroup; // Newer group bubble below.
    final bubbleShape = MessageBubbleShape(
      connectsAbove: connectsAbove,
      connectsBelow: connectsBelow,
    );

    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;
    final isRedirect = remoteMessage.meta['redirect'] is Map;
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isMentioningCurrentUser =
        currentUserId != null &&
        remoteMessage.membersMentioned.contains(currentUserId);

    final avatar = ChatRoomMemberRegion(
      roomId: message.roomId,
      member: sender,
      child: OnlineAvatarBadge(
        roomId: message.roomId,
        accountId: sender.accountId,
        child: ProfilePictureWidget(
          file: sender.account.profile.picture,
          fallbackName: sender.account.nick,
          radius: _avatarRadius,
        ),
      ),
    );

    final header = MessageSenderInfo(
      roomId: message.roomId,
      sender: sender,
      createdAt: message.createdAt,
      textColor: textColor,
      showAvatar: false,
      isCompact: true,
    );

    final attachmentMaxH =
        ref.watch(appSettingsProvider.select((s) => s.attachmentPreviewMode)) ==
            'small'
        ? 200.0
        : 560.0;
    // The reference bands (reply, forward) are full-bleed children of the
    // bubble, not body content: counting them here would leave an empty
    // padded strip under a quote-only message.
    final hasBodyContent =
        remoteMessage.meta['redirect'] is Map ||
        (!isRedirect && MessageContent.hasContent(remoteMessage)) ||
        (remoteMessage.meta['embeds'] != null &&
            kMessageEnableEmbedTypes.contains(message.type));
    final hasProgress = progress != null && progress!.isNotEmpty;
    // Files are clipped a second time inside [CloudFileList]. That inner
    // rounding must never round a corner the block keeps square: the notch
    // would expose the bubble fill exactly where the block meets the body or
    // the next bubble of the group. Only a block with four free corners keeps
    // the rounded file corners.
    final attachmentItemBorderRadius =
        hasBodyContent || hasProgress || connectsAbove || connectsBelow
        ? 0.0
        : bubbleShape.radius;

    Widget buildMessageBody() {
      // The reference band owns the bubble's top edge when present: it is
      // drawn full-bleed with the bubble's own top corners, so the quote and
      // the message read as one sheet with a seam instead of a card pasted
      // inside a bubble. Attachments follow the same rule.
      final showsReply = remoteMessage.repliedMessageId != null;
      final showsForward =
          remoteMessage.forwardedMessageId != null && !isRedirect;
      final topCorners = BorderRadius.only(
        topLeft: Radius.circular(connectsAbove ? 0 : bubbleShape.radius),
        topRight: Radius.circular(bubbleShape.radius),
      );

      return Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: bubbleShape.borderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: _BubbleColumn(
          children: [
            if (showsReply)
              _BubbleStretchBand(
                child: MessageQuoteWidget(
                  message: message,
                  textColor: textColor,
                  isReply: true,
                  borderRadius: topCorners,
                ),
              ),
            if (showsForward)
              _BubbleStretchBand(
                child: MessageQuoteWidget(
                  message: message,
                  textColor: textColor,
                  isReply: false,
                  borderRadius: showsReply ? BorderRadius.zero : topCorners,
                ),
              ),
            if (!isRedirect && remoteMessage.attachments.isNotEmpty)
              ClipRRect(
                borderRadius: (showsReply || showsForward || hasBodyContent)
                    ? BorderRadius.zero
                    : bubbleShape.borderRadius,
                child: CloudFileList(
                  files: remoteMessage.attachments,
                  maxHeight: attachmentMaxH,
                  maxWidth: double.infinity,
                  padding: EdgeInsets.zero,
                  borderRadius: attachmentItemBorderRadius,
                ),
              ),
            if (hasBodyContent || hasProgress)
              Padding(
                padding: _bodyPadding.copyWith(
                  bottom: isMentioningCurrentUser ? 2 : _bodyPadding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (remoteMessage.meta['redirect'] is Map)
                      (() {
                        final data = SnRedirectData.fromJson(
                          Map<String, dynamic>.from(
                            remoteMessage.meta['redirect'] as Map,
                          ),
                        );
                        return data.map(
                          historySegment: (_) => RedirectMessageCard(
                            redirect: data,
                            textColor: textColor,
                          ),
                          singleMessage: (_) => RedirectInlineContent(
                            redirect: data,
                            textColor: textColor,
                          ),
                        );
                      })(),
                    if (!isRedirect && MessageContent.hasContent(remoteMessage))
                      MessageContent(
                        item: remoteMessage,
                        translatedText: translatedText,
                        textStyle: bodyStyle,
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
                      hasContent: MessageContent.hasContent(remoteMessage),
                    ),
                  ],
                ),
              ),
            ?reactions,
            if (isMentioningCurrentUser)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: _MentionHint(textColor: textColor),
              ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        // Group members sit [_groupGap] apart so the squared corners still
        // read as one connected block; the group's outer edges get the wider
        // [_groupOuterGap].
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: isLastInGroup ? _groupOuterGap : _groupGap,
          bottom: isFirstInGroup ? _groupOuterGap : _groupGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAvatar)
              Padding(
                padding: const EdgeInsets.only(left: contentOffset, bottom: 4),
                child: header,
              ),
            _StickyAvatarMessageRow(
              key:
                  avatarAnchorKey ??
                  ValueKey(
                    'sticky-avatar-${message.clientMessageId ?? message.id}',
                  ),
              showAvatar: showAvatar && showBubbleAvatar,
              avatar: avatar,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(child: buildMessageBody()),
                  MessageIndicators(
                    editedAt: remoteMessage.editedAt,
                    status: message.status,
                    isCurrentUser: isCurrentUser,
                    roomId: message.roomId,
                    messageId: message.id,
                    senderId: message.senderId,
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleColumnParentData extends ContainerBoxParentData<RenderBox> {
  bool stretch = false;
}

/// Marks a [_BubbleColumn] child (such as a reply/forward quote band) to
/// stretch to the widest sibling's width without expanding the bubble itself.
class _BubbleStretchBand extends ParentDataWidget<_BubbleColumnParentData> {
  const _BubbleStretchBand({required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _BubbleColumnParentData;
    if (!parentData.stretch) {
      parentData.stretch = true;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _BubbleColumn;
}

class _BubbleColumn extends MultiChildRenderObjectWidget {
  const _BubbleColumn({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBubbleColumn();
}

class _RenderBubbleColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BubbleColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BubbleColumnParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BubbleColumnParentData) {
      child.parentData = _BubbleColumnParentData();
    }
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final childConstraints = BoxConstraints(maxWidth: maxWidth);

    var widest = constraints.minWidth;
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      widest = math.max(widest, child.size.width);
      child = childAfter(child);
    }

    final bubbleWidth = math.min(maxWidth, widest);

    var totalHeight = 0.0;
    child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _BubbleColumnParentData;
      if (parentData.stretch && child.size.width < bubbleWidth) {
        child.layout(
          BoxConstraints(minWidth: bubbleWidth, maxWidth: bubbleWidth),
          parentUsesSize: true,
        );
      }
      parentData.offset = Offset(0, totalHeight);
      totalHeight += child.size.height;
      child = childAfter(child);
    }

    size = constraints.constrain(Size(bubbleWidth, totalHeight));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      width = math.max(width, child.getMinIntrinsicWidth(height));
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      width = math.max(width, child.getMaxIntrinsicWidth(height));
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      height += child.getMinIntrinsicHeight(width);
      child = childAfter(child);
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      height += child.getMaxIntrinsicHeight(width);
      child = childAfter(child);
    }
    return height;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

/// A bubble row with its sender avatar drawn in the gutter beside it. The
/// avatar pins to the top of the viewport while the row is taller than the
/// avatar, so a long message keeps a visible sender.
class _StickyAvatarMessageRow extends StatelessWidget {
  static const double _size = MessageItemDisplayBubble._avatarSize;
  static const double _contentOffset = MessageItemDisplayBubble.contentOffset;
  static const double _viewportTopMargin = 12;

  final bool showAvatar;
  final Widget avatar;
  final Widget child;

  const _StickyAvatarMessageRow({
    super.key,
    required this.showAvatar,
    required this.avatar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _contentOffset),
            child: child,
          ),
          if (showAvatar)
            Positioned(
              left: 0,
              top: 0,
              child: StickyAvatarBox(
                topMargin: _viewportTopMargin,
                // The avatar is re-composited on every scroll frame while it is
                // pinned; keep its own layer so that costs no re-rasterizing.
                child: RepaintBoundary(
                  child: SizedBox(
                    width: _size,
                    height: _size,
                    child: Align(alignment: Alignment.topCenter, child: avatar),
                  ),
                ),
              ),
            ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final isRedirect = remoteMessage.meta['redirect'] is Map;
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isMentioningCurrentUser =
        currentUserId != null &&
        remoteMessage.membersMentioned.contains(currentUserId);

    final isMultiline =
        message.type == 'text' ||
        message.repliedMessageId != null ||
        message.forwardedMessageId != null;

    return Padding(
      // Compact is a dense style by definition, but the previous 2px vertical
      // left consecutive rows touching. 4px is the smallest gap that still
      // reads as separate messages without turning into the bubble style.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(message.createdAt.toLocal()),
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ).padding(top: isMultiline ? 2 : 0),
          ChatRoomMemberRegion(
            roomId: message.roomId,
            member: sender,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OnlineAvatarBadge(
                  roomId: message.roomId,
                  accountId: sender.accountId,
                  child: ProfilePictureWidget(
                    file: sender.account.profile.picture,
                    fallbackName: sender.account.nick,
                    radius: 8,
                  ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          if (remoteMessage.meta['redirect'] is Map)
                            (() {
                              final data = SnRedirectData.fromJson(
                                Map<String, dynamic>.from(
                                  remoteMessage.meta['redirect'] as Map,
                                ),
                              );
                              return data.map(
                                historySegment: (_) => RedirectMessageCard(
                                  redirect: data,
                                  textColor: textColor,
                                ).padding(vertical: 4),
                                singleMessage: (_) => RedirectInlineContent(
                                  redirect: data,
                                  textColor: textColor,
                                ).padding(vertical: 4),
                              );
                            })(),
                          if (remoteMessage.forwardedMessageId != null &&
                              !isRedirect)
                            MessageQuoteWidget(
                              message: message,
                              textColor: textColor,
                              isReply: false,
                            ).padding(vertical: 4),
                          if (!isRedirect &&
                              remoteMessage.attachments.isNotEmpty)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final amaxH =
                                    ref.watch(
                                          appSettingsProvider.select(
                                            (s) => s.attachmentPreviewMode,
                                          ),
                                        ) ==
                                        'small'
                                    ? 200.0
                                    : 560.0;
                                return CloudFileList(
                                  files: remoteMessage.attachments,
                                  maxHeight: amaxH,
                                  maxWidth: constraints.maxWidth,
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                );
                              },
                            ),
                          if (!isRedirect &&
                              MessageContent.hasContent(remoteMessage))
                            MessageContent(
                              item: remoteMessage,
                              translatedText: translatedText,
                              textStyle: chatMessageBodyStyle(
                                context,
                                textColor,
                              ),
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
                            hasContent: MessageContent.hasContent(
                              remoteMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MessageIndicators(
                      editedAt: remoteMessage.editedAt,
                      status: message.status,
                      isCurrentUser: isCurrentUser,
                      roomId: message.roomId,
                      messageId: message.id,
                      senderId: message.senderId,
                      textColor: textColor,
                    ),
                  ],
                ),
                if (isMentioningCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _MentionHint(textColor: textColor),
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
  final bool showColumnAvatar;
  final GlobalKey<State<StatefulWidget>>? avatarAnchorKey;
  final Function(String messageId) onJump;
  final String? translatedText;
  final bool translating;

  const MessageItemDisplayDiscord({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.progress,
    required this.showAvatar,
    required this.showColumnAvatar,
    this.avatarAnchorKey,
    required this.onJump,
    required this.translatedText,
    required this.translating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;
    final isRedirect = remoteMessage.meta['redirect'] is Map;
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isMentioningCurrentUser =
        currentUserId != null &&
        remoteMessage.membersMentioned.contains(currentUserId);

    const kAvatarRadius = 12.0;

    return Padding(
      // Column style keeps its airy gutter, but consecutive rows need a
      // visible break: the body text of one row must not read as the header of
      // the next.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: showAvatar
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    SizedBox(
                      key: avatarAnchorKey,
                      width: kAvatarRadius * 2,
                      height: kAvatarRadius * 2,
                      child: showColumnAvatar
                          ? ChatRoomMemberRegion(
                              roomId: message.roomId,
                              member: sender,
                              child: OnlineAvatarBadge(
                                roomId: message.roomId,
                                accountId: sender.accountId,
                                child: ProfilePictureWidget(
                                  file: sender.account.profile.picture,
                                  fallbackName: sender.account.nick,
                                  radius: kAvatarRadius,
                                ),
                              ),
                            )
                          : null,
                    ),
                    MessageSenderInfo(
                      roomId: message.roomId,
                      sender: sender,
                      createdAt: message.createdAt,
                      textColor: textColor,
                      showAvatar: false,
                      isCompact: true,
                    ),
                  ],
                ),
                Row(
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
                          if (remoteMessage.meta['redirect'] is Map)
                            (() {
                              final data = SnRedirectData.fromJson(
                                Map<String, dynamic>.from(
                                  remoteMessage.meta['redirect'] as Map,
                                ),
                              );
                              return data.map(
                                historySegment: (_) => RedirectMessageCard(
                                  redirect: data,
                                  textColor: textColor,
                                ).padding(vertical: 4),
                                singleMessage: (_) => RedirectInlineContent(
                                  redirect: data,
                                  textColor: textColor,
                                ).padding(vertical: 4),
                              );
                            })(),
                          if (remoteMessage.forwardedMessageId != null &&
                              !isRedirect)
                            MessageQuoteWidget(
                              message: message,
                              textColor: textColor,
                              isReply: false,
                            ).padding(vertical: 4),
                          if (!isRedirect &&
                              remoteMessage.attachments.isNotEmpty)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final amaxH =
                                    ref.watch(
                                          appSettingsProvider.select(
                                            (s) => s.attachmentPreviewMode,
                                          ),
                                        ) ==
                                        'small'
                                    ? 200.0
                                    : 560.0;
                                return CloudFileList(
                                  files: remoteMessage.attachments,
                                  maxHeight: amaxH,
                                  maxWidth: constraints.maxWidth,
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  isColumn: true,
                                );
                              },
                            ),
                          if (!isRedirect &&
                              MessageContent.hasContent(remoteMessage))
                            MessageContent(
                              item: remoteMessage,
                              translatedText: translatedText,
                              textStyle: chatMessageBodyStyle(
                                context,
                                textColor,
                              ),
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
                            hasContent: MessageContent.hasContent(
                              remoteMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MessageIndicators(
                      editedAt: remoteMessage.editedAt,
                      status: message.status,
                      isCurrentUser: isCurrentUser,
                      roomId: message.roomId,
                      messageId: message.id,
                      senderId: message.senderId,
                      textColor: textColor,
                    ),
                  ],
                ),
                if (isMentioningCurrentUser)
                  Padding(
                    padding: EdgeInsets.only(
                      left: kAvatarRadius * 2 + 8,
                      top: 4,
                    ),
                    child: _MentionHint(textColor: textColor),
                  ),
              ],
            )
          : Padding(
              padding: EdgeInsets.only(left: kAvatarRadius * 2 + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            if (remoteMessage.meta['redirect'] is Map)
                              (() {
                                final data = SnRedirectData.fromJson(
                                  Map<String, dynamic>.from(
                                    remoteMessage.meta['redirect'] as Map,
                                  ),
                                );
                                return data.map(
                                  historySegment: (_) => RedirectMessageCard(
                                    redirect: data,
                                    textColor: textColor,
                                  ).padding(vertical: 4),
                                  singleMessage: (_) => RedirectInlineContent(
                                    redirect: data,
                                    textColor: textColor,
                                  ).padding(vertical: 4),
                                );
                              })(),
                            if (remoteMessage.forwardedMessageId != null &&
                                !isRedirect)
                              MessageQuoteWidget(
                                message: message,
                                textColor: textColor,
                                isReply: false,
                              ).padding(vertical: 4),
                            if (!isRedirect &&
                                remoteMessage.attachments.isNotEmpty)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final amaxH =
                                      ref.watch(
                                            appSettingsProvider.select(
                                              (s) => s.attachmentPreviewMode,
                                            ),
                                          ) ==
                                          'small'
                                      ? 200.0
                                      : 560.0;
                                  return CloudFileList(
                                    files: remoteMessage.attachments,
                                    maxHeight: amaxH,
                                    maxWidth: constraints.maxWidth,
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    isColumn: true,
                                  );
                                },
                              ),
                            if (!isRedirect &&
                                MessageContent.hasContent(remoteMessage))
                              MessageContent(
                                item: remoteMessage,
                                translatedText: translatedText,
                                textStyle: chatMessageBodyStyle(
                                  context,
                                  textColor,
                                ),
                              ),
                            if (remoteMessage.meta['embeds'] != null &&
                                kMessageEnableEmbedTypes.contains(message.type))
                              EmbedListWidget(
                                embeds:
                                    remoteMessage.meta['embeds']
                                        as List<dynamic>,
                                isInteractive: true,
                                isFullPost: false,
                                renderingPadding: EdgeInsets.zero,
                                maxWidth: 480,
                              ),
                            FileUploadProgressWidget(
                              progress: progress,
                              textColor: textColor,
                              hasContent: MessageContent.hasContent(
                                remoteMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MessageIndicators(
                        editedAt: remoteMessage.editedAt,
                        status: message.status,
                        isCurrentUser: isCurrentUser,
                        roomId: message.roomId,
                        messageId: message.id,
                        senderId: message.senderId,
                        textColor: textColor,
                      ),
                    ],
                  ),
                  if (isMentioningCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _MentionHint(textColor: textColor),
                    ),
                ],
              ),
            ),
    );
  }
}

class _MentionHint extends StatelessWidget {
  final Color textColor;

  const _MentionHint({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.alternate_email,
            size: 14,
            color: textColor.withOpacity(0.8),
          ),
          const Gap(4),
          Text(
            'chatMentionedYou'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withOpacity(0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageQuoteWidget extends HookConsumerWidget {
  final LocalChatMessage message;
  final Color textColor;
  final bool isReply;

  /// When set, the quote is drawn as a full-bleed band with these corner
  /// radii instead of a floating card: the bubble passes its own top corners
  /// so the band merges into the bubble the way an attachment does.
  final BorderRadius? borderRadius;

  const MessageQuoteWidget({
    super.key,
    required this.message,
    required this.textColor,
    required this.isReply,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotedMessageId = isReply
        ? message.toRemoteMessage().repliedMessageId!
        : message.toRemoteMessage().forwardedMessageId!;
    final cachedQuote = ref.watch(
      referencedChatMessageCacheProvider(
        message.roomId,
      ).select((cache) => cache[quotedMessageId]),
    );
    useEffect(() {
      if (cachedQuote == null) {
        unawaited(
          ref
              .read(referencedChatMessageCacheProvider(message.roomId).notifier)
              .resolve(quotedMessageId),
        );
      }
      return null;
    }, [message.roomId, quotedMessageId, cachedQuote]);

    final remoteMessage = cachedQuote?.value?.toRemoteMessage();
    if (remoteMessage == null) return const SizedBox.shrink();

    final merged = borderRadius;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReply ? Symbols.reply : Symbols.forward,
              size: 14,
              color: textColor.withValues(alpha: 0.75),
            ),
            const Gap(6),
            Flexible(
              child: Text(
                '${isReply ? 'repliedTo'.tr() : 'forwarded'.tr()} '
                '${remoteMessage.sender.account.nick}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
        if (MessageContent.hasContent(remoteMessage))
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Opacity(
              opacity: 0.85,
              child: MessageContent(item: remoteMessage, isSelectable: false),
            ),
          ),
        if (remoteMessage.attachments.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: CloudFileList(
              files: remoteMessage.attachments,
              maxWidth: 180,
              maxHeight: 96,
              minWidth: 120,
              initiallyCollapsed: false,
              heroTagPrefix: 'cloud-file-quote-${message.id}',
              padding: const EdgeInsets.only(top: 6),
            ),
          ),
      ],
    );

    void jumpToQuoted() {
      final ancestor = context.findAncestorWidgetOfExactType<MessageItem>();
      ancestor?.onJump(quotedMessageId);
    }

    if (merged != null) {
      // Merged: a full-bleed band at the top of the bubble, painted as a
      // wash of the bubble's own surface rather than a second colour.
      // `onSurface` is near-black in light mode and near-white in dark mode,
      // so the band always reads as one step away from the bubble it sits in.
      // The bubble clips it to its own outline, so the band and the body read
      // as one sheet with a seam — the same construction the attachment block
      // uses above the text.
      return Material(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: merged,
        child: InkWell(
          onTap: jumpToQuoted,
          child: Padding(
            // Same inset as the bubble body, so the band's text and the
            // message text below it start on the same left edge.
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: body,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.primaryFixedDim.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(SolRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: jumpToQuoted,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: body,
          ),
        ),
      ),
    );
  }
}

class RedirectMessageCard extends StatelessWidget {
  final SnRedirectData redirect;
  final Color textColor;

  const RedirectMessageCard({
    super.key,
    required this.redirect,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final sourceRoomName = redirect.sourceRoomName;
    final historyCount = redirect.messageCount;

    final cardLabel = 'chatRedirectedHistoryFrom'.tr(args: [sourceRoomName]);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => _RedirectHistorySheet(redirect: redirect),
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryFixedDim.withOpacity(0.35),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            children: [
              Icon(Symbols.history, size: 16, color: textColor),
              const Gap(6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cardLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (historyCount > 0)
                      Text(
                        'chatRedirectMessagesCount'.plural(
                          historyCount,
                          args: [historyCount.toString()],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.82),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(6),
              Icon(
                Symbols.chevron_right,
                size: 16,
                color: textColor.withOpacity(0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RedirectInlineContent extends StatelessWidget {
  final SnRedirectData redirect;
  final Color textColor;

  const RedirectInlineContent({
    super.key,
    required this.redirect,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final sourceRoomName = redirect.sourceRoomName;
    final content = redirect.resolvedSourceContent ?? '';
    final parsedAttachments = redirect.resolvedSourceAttachments;
    final sourceSenderName = redirect.resolvedSourceSenderName;
    final sourceSenderProfilePicture = redirect.sourceSenderProfilePicture;
    final sourceSenderPictureId = redirect.sourceSenderPictureId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Symbols.subdirectory_arrow_right,
              size: 14,
              color: textColor.withOpacity(0.6),
            ),
            const Gap(4),
            ProfilePictureWidget(
              file: sourceSenderProfilePicture,
              fileId: sourceSenderPictureId,
              radius: 8,
            ),
            if (sourceSenderProfilePicture != null ||
                sourceSenderPictureId != null)
              const Gap(4),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (sourceSenderName != null &&
                        sourceSenderName.trim().isNotEmpty) ...[
                      TextSpan(
                        text: sourceSenderName,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    TextSpan(
                      text: 'chatRedirectedFromRoom'.tr(args: [sourceRoomName]),
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MarkdownTextContent(
              content: content,
              isSelectable: kTextSelectable,
              linesMargin: EdgeInsets.zero,
            ),
          ),
        if (parsedAttachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CloudFileList(
              files: parsedAttachments,
              maxWidth: 240,
              maxHeight: 120,
              minWidth: 120,
              initiallyCollapsed: false,
              heroTagPrefix: 'redirect-att',
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

class _RedirectHistorySheet extends StatelessWidget {
  final SnRedirectData redirect;

  const _RedirectHistorySheet({required this.redirect});

  @override
  Widget build(BuildContext context) {
    final transcriptMessages = redirect.map(
      singleMessage: (d) => [],
      historySegment: (d) => d.messages,
    );

    return SheetScaffold(
      titleText: 'chatRedirectHistoryTitle'.tr(args: [redirect.sourceRoomName]),
      child: transcriptMessages.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (redirect.messageCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'chatRedirectMessagesCount'.plural(
                        redirect.messageCount,
                        args: [redirect.messageCount.toString()],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: transcriptMessages.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 1 / MediaQuery.devicePixelRatioOf(context),
                    ),
                    itemBuilder: (context, index) {
                      final senderName =
                          redirect.historyMessageSenderName(index) ??
                          'unknown'.tr();
                      final senderUname = redirect
                          .historyMessageSenderAccountName(index);
                      final pictureId = redirect.historyMessageSenderPictureId(
                        index,
                      );
                      final senderAccount = redirect
                          .historyMessageSenderAccount(index);

                      final content =
                          redirect.historyMessageContent(index) ?? '';
                      final attachments = redirect
                          .historyMessageResolvedAttachments(index);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AccountPfcRegion(
                              uname: senderUname,
                              child: ProfilePictureWidget(
                                fileId: pictureId,
                                radius: 12,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (senderAccount != null)
                                    AccountName(
                                      account: senderAccount,
                                      textOverride: senderName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    )
                                  else
                                    Text(
                                      senderName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  if (content.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: MarkdownTextContent(
                                        content: content.trim(),
                                        isSelectable: kTextSelectable,
                                        linesMargin: EdgeInsets.zero,
                                      ),
                                    ),
                                  if (attachments.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: CloudFileList(
                                        files: attachments,
                                        maxWidth: double.infinity,
                                        maxHeight: 200,
                                        minWidth: 120,
                                        initiallyCollapsed: false,
                                        heroTagPrefix: 'hist-att',
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  redirect.resolvedSourceContent?.trim().isNotEmpty == true
                      ? redirect.resolvedSourceContent!
                      : 'chatNoContent'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
