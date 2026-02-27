import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatRoomListTile extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isDirect;
  final bool selected;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ChatRoomListTile({
    super.key,
    required this.room,
    this.isDirect = false,
    this.selected = false,
    this.subtitle,
    this.trailing,
    this.onTap,
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
        titleText = validMembers.map((e) => e.account.nick).join(', ');
      } else {
        titleText = 'Direct Message';
      }
    } else {
      titleText = room.name ?? '';
    }

    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withOpacity(0.6),
      leading: ChatRoomAvatar(
        room: room,
        isDirect: isDirect,
        summary: summary,
        validMembers: validMembers,
      ),
      title: Text(titleText),
      subtitle: ChatRoomSubtitle(
        room: room,
        isDirect: isDirect,
        validMembers: validMembers,
        summary: summary,
        subtitle: subtitle,
      ),
      trailing: trailing, // Add this line
      onTap: () async {
        // Clear unread count if there are unread messages
        ref.read(chatSummaryProvider.future).then((summary) {
          if ((summary[room.id]?.unreadCount ?? 0) > 0) {
            ref.read(chatSummaryProvider.notifier).clearUnreadCount(room.id);
          }
        });
        onTap?.call();
      },
    );
  }
}
