import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/e2ee_message_display.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:relative_time/relative_time.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatRoomAvatar extends StatelessWidget {
  final SnChatRoom room;
  final bool isDirect;
  final AsyncValue<SnChatSummary?> summary;
  final List<SnChatMember> validMembers;
  final bool hideRealm;
  final double? radius;

  const ChatRoomAvatar({
    super.key,
    required this.room,
    required this.isDirect,
    required this.summary,
    required this.validMembers,
    this.hideRealm = false,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final avatarChild = (isDirect && room.picture == null)
        ? SplitAvatarWidget(
            files: validMembers.map((e) => e.account.profile.picture).toList(),
            radius: radius ?? 20,
          )
        : room.picture == null
        ? CircleAvatar(
            radius: radius,
            child: Text((room.name ?? 'DM')[0].toUpperCase()),
          )
        : ProfilePictureWidget(file: room.picture, radius: radius ?? 20);

    final badgeChild = Badge(
      isLabelVisible: summary.when(
        data: (data) => (data?.unreadCount ?? 0) > 0,
        loading: () => false,
        error: (_, _) => false,
      ),
      label: Text('${summary.value?.unreadCount ?? 0}'),
      child: avatarChild,
    );

    // Show realm avatar as small overlay if chat belongs to a realm
    if (room.realm != null && !hideRealm) {
      return Stack(
        children: [
          badgeChild,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: ProfilePictureWidget(file: room.realm!.picture),
              ),
            ),
          ),
        ],
      );
    }

    return badgeChild;
  }
}

class ChatRoomSubtitle extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isDirect;
  final List<SnChatMember> validMembers;
  final AsyncValue<SnChatSummary?> summary;
  final Widget? subtitle;

  const ChatRoomSubtitle({
    super.key,
    required this.room,
    required this.isDirect,
    required this.validMembers,
    required this.summary,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(serverUrlProvider);
    final currentUserId = ref.watch(userInfoProvider).value?.id;

    if (subtitle != null) return subtitle!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previousChildren, ?currentChild],
      ),
      child: summary.when(
        data: (data) => Container(
          key: const ValueKey('data'),
          child: data == null
              ? isDirect && room.description == null
                    ? Text(
                        validMembers
                            .map((e) => '@${e.account.name}')
                            .join(', '),
                        maxLines: 1,
                      )
                    : Text(
                        room.description ?? 'descriptionNone'.tr(),
                        maxLines: 1,
                      )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (data.lastMessage == null)
                      Text(
                        room.description ?? 'descriptionNone'.tr(),
                        maxLines: 1,
                      )
                    else
                      Row(
                        spacing: 4,
                        children: [
                          Badge(
                            label: Text(data.lastMessage!.sender.account.nick),
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final lastMessage = data.lastMessage!;
                                final resolved =
                                    resolveE2eeDisplayContentForMessage(
                                      lastMessage,
                                    );
                                final baseStyle = Theme.of(
                                  context,
                                ).textTheme.bodySmall;
                                final hintStyle = baseStyle?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: baseStyle.color?.withOpacity(0.8),
                                );

                                Text buildHint(String text) => Text(
                                  text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: hintStyle,
                                );

                                final textContent =
                                    resolved.content?.trim() ?? '';
                                final hasText = textContent.isNotEmpty;
                                final attachmentCount =
                                    lastMessage.attachments.length;
                                final hasAttachments = attachmentCount > 0;
                                final stickerMatch = RegExp(
                                  r'^:([-\w]*\+[-\w]*):$',
                                ).firstMatch(textContent);
                                final stickerPlaceholder = stickerMatch?.group(
                                  1,
                                );
                                final isStickerOnly =
                                    stickerPlaceholder != null &&
                                    stickerPlaceholder.isNotEmpty;
                                final attachmentLabel = attachmentCount == 1
                                    ? 'Attachment'
                                    : '$attachmentCount attachments';
                                String? reactionPreview() {
                                  if (lastMessage.type !=
                                          'messages.reaction.added' &&
                                      lastMessage.type !=
                                          'messages.reaction.removed') {
                                    return null;
                                  }
                                  final symbol =
                                      lastMessage.meta['symbol']?.toString() ??
                                      (lastMessage.meta['reaction'] is Map
                                          ? (lastMessage.meta['reaction']
                                                    as Map)['symbol']
                                                ?.toString()
                                          : null);
                                  final isAdded =
                                      lastMessage.type ==
                                      'messages.reaction.added';
                                  if (symbol == null || symbol.isEmpty) {
                                    return isAdded
                                        ? 'Added a reaction'
                                        : 'Removed a reaction';
                                  }
                                  return isAdded
                                      ? 'Reacted with $symbol'
                                      : 'Removed reaction $symbol';
                                }

                                if (isStickerOnly && hasAttachments) {
                                  final stickerUri =
                                      '$baseUrl/sphere/stickers/lookup/$stickerPlaceholder/open';
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      UniversalImage(
                                        uri: stickerUri,
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                        noCacheOptimization: true,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          attachmentLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: hintStyle,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                if (isStickerOnly) {
                                  final stickerUri =
                                      '$baseUrl/sphere/stickers/lookup/$stickerPlaceholder/open';
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: UniversalImage(
                                      uri: stickerUri,
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                      noCacheOptimization: true,
                                    ),
                                  );
                                }

                                if (hasText && hasAttachments) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: textContent),
                                        TextSpan(
                                          text: '  $attachmentLabel',
                                          style: hintStyle,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: baseStyle,
                                  );
                                }

                                if (hasAttachments) {
                                  return buildHint(attachmentLabel);
                                }

                                final preview = hasText
                                    ? textContent
                                    : resolved.decryptFailed
                                    ? 'Unable to decrypt message'
                                    : resolved.emptyAfterDecrypt
                                    ? 'Encrypted message'
                                    : reactionPreview() ??
                                          'No message preview';

                                if (!hasText) {
                                  return buildHint(preview);
                                }

                                return Text(
                                  preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: baseStyle,
                                );
                              },
                            ),
                          ),
                          if (currentUserId != null &&
                              data.lastMessage!.membersMentioned.contains(
                                currentUserId,
                              ))
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.alternate_email,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.9),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              RelativeTime(
                                context,
                              ).format(data.lastMessage!.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
        loading: () => Container(
          key: const ValueKey('loading'),
          child: Builder(
            builder: (context) {
              final seed = DateTime.now().microsecondsSinceEpoch;
              final len = 4 + (seed % 17); // 4..20 inclusive
              const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
              var s = seed;
              final buffer = StringBuffer();
              for (var i = 0; i < len; i++) {
                s = (s * 1103515245 + 12345) & 0x7fffffff;
                buffer.write(chars[s % chars.length]);
              }
              return Skeletonizer(
                enabled: true,
                child: Text(buffer.toString()),
              );
            },
          ),
        ),
        error: (_, _) => Container(
          key: const ValueKey('error'),
          child: isDirect && room.description == null
              ? Text(
                  validMembers.map((e) => '@${e.account.name}').join(', '),
                  maxLines: 1,
                )
              : Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1),
        ),
      ),
    );
  }
}
