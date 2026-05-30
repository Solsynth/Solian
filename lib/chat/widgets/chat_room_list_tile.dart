import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
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
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    var validMembers = room.members ?? [];
    if (validMembers.isNotEmpty) {
      final userInfo = ref.watch(userInfoProvider);
      if (userInfo.value != null) {
        validMembers = validMembers
            .where((e) => e.accountId != userInfo.value!.id)
            .toList();
      }
    }

    String titleText;
    if (isDirect && room.name == null) {
      if (room.members?.isNotEmpty ?? false) {
        // Look up relationship aliases for each member
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown,
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.6),
        trailing: trailing,
        leading: ChatRoomAvatar(
          room: room,
          isDirect: isDirect,
          summary: summary,
          validMembers: validMembers,
        ),
        title: Row(
          children: [
            Expanded(child: Text(titleText)),
            if (room.encryptionMode != 0)
              Icon(
                Icons.lock,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            if (pushNotificationsSuppressed)
              Tooltip(
                message: 'Notifications suspended for this room',
                child: Icon(
                  Icons.notifications_off,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        subtitle: ChatRoomSubtitle(
          room: room,
          isDirect: isDirect,
          validMembers: validMembers,
          summary: summary,
          subtitle: subtitle,
        ),
        onLongPress: onLongPress,
        onTap: () async {
          ref.read(chatSummaryProvider.future).then((summary) {
            if ((summary[room.id]?.unreadCount ?? 0) > 0) {
              ref.read(chatSummaryProvider.notifier).clearUnreadCount(room.id);
            }
          });
          onTap?.call();
        },
      ),
    );
  }
}
