import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/e2ee_message_display.dart';
import 'package:island/chat/models/redirect_data.dart';
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
  final bool showTimestamp;
  final bool emphasizeUnread;

  const ChatRoomSubtitle({
    super.key,
    required this.room,
    required this.isDirect,
    required this.validMembers,
    required this.summary,
    this.subtitle,
    this.showTimestamp = true,
    this.emphasizeUnread = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Callers that provide a custom subtitle should not subscribe to provider
    // updates that the custom child does not use.
    if (subtitle != null) return subtitle!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseUrl = ref.watch(serverUrlProvider);
    final currentUserId = ref.watch(
      userInfoProvider.select((user) => user.value?.id),
    );

    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant.withOpacity(
        emphasizeUnread ? 0.95 : 0.78,
      ),
      fontWeight: emphasizeUnread ? FontWeight.w500 : FontWeight.w400,
      height: 1.25,
    );
    final hintStyle = mutedStyle?.copyWith(
      fontStyle: FontStyle.italic,
      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
      fontWeight: FontWeight.w400,
    );
    final senderStyle = mutedStyle?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface.withOpacity(emphasizeUnread ? 0.88 : 0.72),
    );

    Widget fallbackDescription() {
      if (isDirect && room.description == null) {
        return Text(
          validMembers.map((e) => '@${e.account.name}').join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: mutedStyle,
        );
      }
      return Text(
        room.description ?? 'descriptionNone'.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: mutedStyle,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previousChildren, ?currentChild],
      ),
      child: summary.when(
        data: (data) {
          if (data == null || data.lastMessage == null) {
            return Container(
              key: const ValueKey('empty'),
              child: fallbackDescription(),
            );
          }

          final lastMessage = data.lastMessage!;
          final isMentioned =
              currentUserId != null &&
              lastMessage.membersMentioned.contains(currentUserId);
          final senderNick = lastMessage.sender.account.nick;
          final resolved = resolveE2eeDisplayContentForMessage(lastMessage);
          final textContent = resolved.content?.trim() ?? '';
          final hasText = textContent.isNotEmpty;
          final attachmentCount = lastMessage.attachments.length;
          final hasAttachments = attachmentCount > 0;
          final attachmentLabel = attachmentCount == 1
              ? 'Attachment'
              : '$attachmentCount attachments';

          String? reactionPreview() {
            if (lastMessage.type != 'messages.reaction.added' &&
                lastMessage.type != 'messages.reaction.removed') {
              return null;
            }
            final symbol =
                lastMessage.meta['symbol']?.toString() ??
                (lastMessage.meta['reaction'] is Map
                    ? (lastMessage.meta['reaction'] as Map)['symbol']
                          ?.toString()
                    : null);
            final isAdded = lastMessage.type == 'messages.reaction.added';
            if (symbol == null || symbol.isEmpty) {
              return isAdded ? 'Added a reaction' : 'Removed a reaction';
            }
            return isAdded
                ? 'Reacted with $symbol'
                : 'Removed reaction $symbol';
          }

          Widget buildMessagePreview() {
            if (lastMessage.meta['redirect'] is Map) {
              try {
                final redirectData = SnRedirectData.fromJson(
                  Map<String, dynamic>.from(
                    lastMessage.meta['redirect'] as Map,
                  ),
                );
                return Text(
                  'chatRedirectedHistoryFrom'.tr(
                    args: [redirectData.sourceRoomName],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hintStyle,
                );
              } catch (_) {
                return Text(
                  'Forwarded a message',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hintStyle,
                );
              }
            }

            final stickerMatch = RegExp(
              r'^:([-\w]*\+[-\w]*):$',
            ).firstMatch(textContent);
            final stickerPlaceholder = stickerMatch?.group(1);
            final isStickerOnly =
                stickerPlaceholder != null && stickerPlaceholder.isNotEmpty;

            if (isStickerOnly) {
              final stickerUri =
                  '$baseUrl/sphere/stickers/lookup/$stickerPlaceholder/open';
              return Row(
                children: [
                  UniversalImage(
                    uri: stickerUri,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    noCacheOptimization: true,
                  ),
                  if (hasAttachments) ...[
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
                ],
              );
            }

            if (hasText && hasAttachments) {
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: textContent),
                    TextSpan(text: '  $attachmentLabel', style: hintStyle),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mutedStyle,
              );
            }

            if (hasAttachments) {
              return Text(
                attachmentLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hintStyle,
              );
            }

            final preview = hasText
                ? textContent
                : resolved.decryptFailed
                ? 'Unable to decrypt message'
                : resolved.emptyAfterDecrypt
                ? 'Encrypted message'
                : reactionPreview() ?? 'No message preview';

            return Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: hasText ? mutedStyle : hintStyle,
            );
          }

          return Container(
            key: const ValueKey('data'),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 108),
                        child: Text(
                          '$senderNick: ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: senderStyle,
                        ),
                      ),
                      Expanded(child: buildMessagePreview()),
                    ],
                  ),
                ),
                if (isMentioned) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.alternate_email,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
                if (showTimestamp) ...[
                  const SizedBox(width: 8),
                  Text(
                    RelativeTime(context).format(lastMessage.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
                child: Text(buffer.toString(), style: mutedStyle),
              );
            },
          ),
        ),
        error: (_, _) =>
            Container(key: const ValueKey('error'), child: fallbackDescription()),
      ),
    );
  }
}
