import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/widgets/online_avatar_badge.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

class MessageSenderInfo extends StatelessWidget {
  final String roomId;
  final SnChatMember? sender;
  final DateTime createdAt;
  final Color textColor;
  final bool showAvatar;
  final bool isCompact;

  const MessageSenderInfo({
    super.key,
    required this.roomId,
    required this.sender,
    required this.createdAt,
    required this.textColor,
    this.showAvatar = true,
    this.isCompact = false,
  });

  bool get _isSystemMessage {
    final accountId = sender?.accountId;
    if (accountId == 'system') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (sender == null) {
      return const SizedBox.shrink();
    }

    if (_isSystemMessage) {
      return const SizedBox.shrink();
    }

    final s = sender!;

    final timestamp = DateTime.now().difference(createdAt).inDays > 365
        ? DateFormat('yyyy/MM/dd HH:mm').format(createdAt.toLocal())
        : DateTime.now().difference(createdAt).inDays > 0
        ? DateFormat('MM/dd HH:mm').format(createdAt.toLocal())
        : DateFormat('HH:mm').format(createdAt.toLocal());

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (showAvatar)
            ChatRoomMemberRegion(
              roomId: roomId,
              member: s,
              child: OnlineAvatarBadge(
                roomId: roomId,
                accountId: s.accountId,
                child: ProfilePictureWidget(
                  file: s.account.profile.picture,
                  radius: 14,
                ),
              ),
            ),
          if (showAvatar) const Gap(4),
          Row(
            children: [
              AccountName(
                textOverride: (s.nick?.isNotEmpty == true)
                    ? s.nick
                    : (s.realmNick?.isNotEmpty == true)
                    ? s.realmNick
                    : s.account.nick,
                account: s.account,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (s.realmLabel != null)
                RealmLabelWidget(label: s.realmLabel!).padding(left: 6),
            ],
          ),
          const Gap(6),
          Text(
            timestamp,
            style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
          ),
        ],
      );
    }

    if (showAvatar) {
      return Row(
        spacing: 8,
        children: [
          ChatRoomMemberRegion(
            roomId: roomId,
            member: s,
            child: OnlineAvatarBadge(
              roomId: roomId,
              accountId: s.accountId,
              child: ProfilePictureWidget(
                file: s.account.profile.picture,
                radius: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccountName(
                      textOverride: (s.nick?.isNotEmpty == true)
                          ? s.nick
                          : (s.realmNick?.isNotEmpty == true)
                          ? s.realmNick
                          : s.account.nick,
                      account: s.account,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (s.realmLabel != null)
                      RealmLabelWidget(label: s.realmLabel!).padding(left: 6),
                  ],
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Row(
              children: [
                AccountName(
                  textOverride: (s.nick?.isNotEmpty == true)
                      ? s.nick
                      : (s.realmNick?.isNotEmpty == true)
                      ? s.realmNick
                      : s.account.nick,
                  account: s.account,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (s.realmLabel != null)
                  RealmLabelWidget(label: s.realmLabel!).padding(left: 6),
              ],
            ),
            Text(
              timestamp,
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }
}
