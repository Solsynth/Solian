import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/accounts_widgets/account/account_name.dart';
import 'package:island/accounts/accounts_widgets/account/account_pfc.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';

class MessageSenderInfo extends StatelessWidget {
  final SnChatMember sender;
  final DateTime createdAt;
  final Color textColor;
  final bool showAvatar;
  final bool isCompact;

  const MessageSenderInfo({
    super.key,
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
            AccountPfcRegion(
              uname: sender.account.name,
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
          AccountPfcRegion(
            uname: sender.account.name,
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
          AccountPfcRegion(
            uname: sender.account.name,
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
