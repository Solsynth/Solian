import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/message.dart';
import 'package:island/pods/chat/chat_rooms.dart';
import 'package:island/pods/chat/messages_notifier.dart';
import 'package:island/pods/translate.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/message_content.dart';
import 'package:island/widgets/chat/message_indicators.dart';
import 'package:island/widgets/chat/message_sender_info.dart';
import 'package:island/widgets/content/alert.native.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/embed/embed_list.dart';
import 'package:island/widgets/post/post_shared.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/widgets/content/sheet.dart';

class MessageItemAction {
  static const String edit = "edit";
  static const String delete = "delete";
  static const String reply = "reply";
  static const String forward = "forward";
}

class MessageItem extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final Map<int, double>? progress;
  final bool showAvatar;
  final Function(String messageId) onJump;

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onAction,
    required this.progress,
    required this.showAvatar,
    required this.onJump,
  });

  static const kFlashDuration = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteMessage = message.toRemoteMessage();
    final settings = ref.watch(appSettingsNotifierProvider);

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    final messageLanguage =
        remoteMessage.content != null
            ? ref.watch(detectStringLanguageProvider(remoteMessage.content!))
            : null;

    final currentLanguage = context.locale.toString();
    final translatableLanguage =
        messageLanguage != null
            ? messageLanguage.substring(0, 2) != currentLanguage.substring(0, 2)
            : false;

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
        builder:
            (context) => MessageActionSheet(
              isCurrentUser: isCurrentUser,
              onAction: onAction,
              translatableLanguage: translatableLanguage,
              translating: translating.value,
              translatedText: translatedText.value,
              translate: translate,
              isMobile: isMobile,
              remoteMessage: remoteMessage,
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

    final flashColor =
        isFlashing.value
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
            : Colors.transparent;

    return InkWell(
      onLongPress: showActionMenu,
      onSecondaryTap: showActionMenu,
      onTap: () {
        // Jump to related message
        if (['messages.update', 'messages.delete'].contains(message.type) &&
            message.meta['message_id'] is String &&
            message.meta['message_id'] != null) {
          onJump(message.meta['message_id']);
        }
      },
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
    );
  }
}

class MessageActionSheet extends StatelessWidget {
  final bool isCurrentUser;
  final Function(String action)? onAction;
  final bool translatableLanguage;
  final bool translating;
  final String? translatedText;
  final VoidCallback translate;
  final bool isMobile;
  final dynamic remoteMessage;

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
  });

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'messageActions'.tr(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(4),
            if (isCurrentUser)
              ListTile(
                leading: Icon(Symbols.edit),
                title: Text('edit'.tr()),
                minTileHeight: 48,
                onTap: () {
                  onAction!.call(MessageItemAction.edit);
                  Navigator.pop(context);
                },
              ),
            if (isCurrentUser)
              ListTile(
                leading: Icon(Symbols.delete),
                title: Text('delete'.tr()),
                minTileHeight: 48,
                onTap: () {
                  onAction!.call(MessageItemAction.delete);
                  Navigator.pop(context);
                },
              ),
            if (isCurrentUser) const Divider(height: 8),
            ListTile(
              leading: Icon(Symbols.reply),
              title: Text('reply'.tr()),
              minTileHeight: 48,
              onTap: () {
                onAction!.call(MessageItemAction.reply);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Symbols.forward),
              title: Text('forward'.tr()),
              minTileHeight: 48,
              onTap: () {
                onAction!.call(MessageItemAction.forward);
                Navigator.pop(context);
              },
            ),
            if (translatableLanguage) const Divider(height: 8),
            if (translatableLanguage)
              ListTile(
                leading: Icon(Symbols.translate),
                minTileHeight: 48,
                title: Text(
                  translatedText == null
                      ? 'translate'.tr()
                      : translating
                      ? 'translating'.tr()
                      : 'translated'.tr(),
                ),
                onTap: () {
                  translate();
                  Navigator.pop(context);
                },
              ),
            if (isMobile) const Divider(height: 8),
            if (isMobile)
              ListTile(
                leading: Icon(Symbols.copy_all),
                title: Text('copyMessage'.tr()),
                minTileHeight: 48,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: remoteMessage.content ?? ''),
                  );
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class MessageItemDisplayBubble extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Map<int, double>? progress;
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
    final textColor =
        isCurrentUser
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final containerColor =
        isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceContainer;

    final hasBackground =
        ref.watch(backgroundImageFileProvider).valueOrNull != null;

    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;

    return Material(
      color:
          hasBackground
              ? Colors.transparent
              : Theme.of(context).colorScheme.surface,
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
                        if (progress != null && progress!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                              if ((remoteMessage.content?.isNotEmpty ?? false))
                                const Gap(0),
                              for (var entry in progress!.entries)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'fileUploadingProgress'.tr(
                                        args: [
                                          (entry.key + 1).toString(),
                                          entry.value.toStringAsFixed(1),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withOpacity(0.8),
                                      ),
                                    ),
                                    const Gap(4),
                                    LinearProgressIndicator(
                                      value: entry.value / 100,
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              const Gap(0),
                            ],
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
  final Map<int, double>? progress;
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
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(message.createdAt.toLocal()),
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ).padding(top: isMultiline ? 2 : 0),
          AccountPfcGestureDetector(
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
                if (progress != null && progress!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      if ((remoteMessage.content?.isNotEmpty ?? false))
                        const SizedBox.shrink(),
                      for (var entry in progress!.entries)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'fileUploadingProgress'.tr(
                                args: [
                                  (entry.key + 1).toString(),
                                  entry.value.toStringAsFixed(1),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            const Gap(4),
                            LinearProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
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
  final Map<int, double>? progress;
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
      child:
          showAvatar
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      AccountPfcGestureDetector(
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
                  Column(
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
                      if (progress != null && progress!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 8,
                          children: [
                            if ((remoteMessage.content?.isNotEmpty ?? false))
                              const SizedBox.shrink(),
                            for (var entry in progress!.entries)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'fileUploadingProgress'.tr(
                                      args: [
                                        (entry.key + 1).toString(),
                                        entry.value.toStringAsFixed(1),
                                      ],
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                  const Gap(4),
                                  LinearProgressIndicator(
                                    value: entry.value / 100,
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceVariant,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ).padding(left: kAvatarRadius * 2 + 8),
                ],
              )
              : Padding(
                padding: EdgeInsets.only(left: kAvatarRadius * 2 + 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAvatar)
                      MessageSenderInfo(
                        sender: sender,
                        createdAt: message.createdAt,
                        textColor: textColor,
                        showAvatar: false,
                        isCompact: true,
                      ),
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
                    if (progress != null && progress!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          if ((remoteMessage.content?.isNotEmpty ?? false))
                            const Gap(0),
                          for (var entry in progress!.entries)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'fileUploadingProgress'.tr(
                                    args: [
                                      (entry.key + 1).toString(),
                                      entry.value.toStringAsFixed(1),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                                const Gap(4),
                                LinearProgressIndicator(
                                  value: entry.value / 100,
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          const Gap(0),
                        ],
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
      messagesNotifierProvider(message.roomId).notifier,
    );

    return FutureBuilder<LocalChatMessage?>(
      future: messagesNotifier.fetchMessageById(
        isReply
            ? message.toRemoteMessage().repliedMessageId!
            : message.toRemoteMessage().forwardedMessageId!,
      ),
      builder: (context, snapshot) {
        final remoteMessage =
            snapshot.hasData ? snapshot.data!.toRemoteMessage() : null;

        if (remoteMessage != null) {
          return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: GestureDetector(
              onTap: () {
                final messageId =
                    isReply
                        ? message.toRemoteMessage().repliedMessageId!
                        : message.toRemoteMessage().forwardedMessageId!;
                // Find the nearest MessageItem ancestor and call its onJump method
                final MessageItem? ancestor =
                    context.findAncestorWidgetOfExactType<MessageItem>();
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
