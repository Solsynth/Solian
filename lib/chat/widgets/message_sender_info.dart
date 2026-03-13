import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class MessageSenderInfo extends StatelessWidget {
  final String roomId;
  final SnChatMember sender;
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

  @override
  Widget build(BuildContext context) {
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
              member: sender,
              child: ProfilePictureWidget(
                file: sender.account.profile.picture,
                radius: 14,
              ),
            ),
          if (showAvatar) const Gap(4),
          AccountName(
            account: sender.account,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
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
            member: sender,
            child: ProfilePictureWidget(
              file: sender.account.profile.picture,
              radius: 14,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountName(
                  account: sender.account,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
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
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAvatar)
          ChatRoomMemberRegion(
            roomId: roomId,
            member: sender,
            child: ProfilePictureWidget(
              file: sender.account.profile.picture,
              radius: 16,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(timestamp, style: TextStyle(fontSize: 10, color: textColor)),
            AccountName(
              account: sender.account,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
