import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:relative_time/relative_time.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatRoomListTile extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isDirect;
  final bool selected;
  final bool pushNotificationsSuppressed;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onSecondaryTapDown;

  const ChatRoomListTile({
    super.key,
    required this.room,
    this.isDirect = false,
    this.selected = false,
    this.pushNotificationsSuppressed = false,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // A new message replaces the summary map. Select this room's entry so an
    // update in another room does not rebuild every visible list tile.
    final summary = ref.watch(
      chatSummaryProvider.select(
        (summaries) => summaries.whenData((items) => items[room.id]),
      ),
    );
    final unreadCount = summary.value?.unreadCount ?? 0;
    final hasUnread = unreadCount > 0;
    final lastMessageAt = summary.value?.lastMessage?.createdAt;

    final currentUserId = ref.watch(
      userInfoProvider.select((user) => user.value?.id),
    );
    final validMembers = (room.members ?? <SnChatMember>[])
        .where((member) => member.accountId != currentUserId)
        .toList(growable: false);

    final memberIds = validMembers.map((member) => member.accountId).toSet();
    final isOnline =
        isDirect &&
        ref.watch(
          friendsOverviewProvider.select(
        (friends) =>
            friends.value?.any(
                  (friend) =>
                      memberIds.contains(friend.account.id) &&
                      showsOnlinePresence(friend.status),
                ) ??
                false,
          ),
        );

    String titleText;
    if (isDirect && room.name == null) {
      if (room.members?.isNotEmpty ?? false) {
        final memberNames = <String>[];
        for (final member in validMembers) {
          final aliasAsync = ref.watch(
            relationshipAliasProvider(member.accountId),
          );
          final alias = aliasAsync.hasValue ? aliasAsync.value : null;
          memberNames.add(
            (alias != null && alias.isNotEmpty) ? alias : member.account.nick,
          );
        }
        titleText = memberNames.join(', ');
      } else {
        titleText = 'Direct Message';
      }
    } else {
      titleText = room.name ?? '';
    }

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
      color: colorScheme.onSurface,
      letterSpacing: -0.1,
      height: 1.2,
    );
    final timeStyle = theme.textTheme.labelSmall?.copyWith(
      color: hasUnread
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant.withOpacity(0.85),
      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
      height: 1.2,
    );

    final backgroundColor = selected
        ? colorScheme.secondaryContainer.withOpacity(0.55)
        : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown,
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: () async {
            ref.read(chatSummaryProvider.future).then((summaryMap) {
              if ((summaryMap[room.id]?.unreadCount ?? 0) > 0) {
                ref
                    .read(chatSummaryProvider.notifier)
                    .clearUnreadCount(room.id);
              }
            });
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ChatRoomAvatar(
                      room: room,
                      isDirect: isDirect,
                      summary: summary,
                      validMembers: validMembers,
                      radius: 22,
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titleText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                          ),
                          if (room.encryptionMode != 0) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock_outline,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                          if (pushNotificationsSuppressed) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'Notifications suspended for this room',
                              child: Icon(
                                Icons.notifications_off_outlined,
                                size: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (lastMessageAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              RelativeTime(context).format(lastMessageAt),
                              style: timeStyle,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ChatRoomSubtitle(
                              room: room,
                              isDirect: isDirect,
                              validMembers: validMembers,
                              summary: summary,
                              subtitle: subtitle,
                              showTimestamp: false,
                              emphasizeUnread: hasUnread,
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            trailing!,
                          ],
                        ],
                      ),
                    ],
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
