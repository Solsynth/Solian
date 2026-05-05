import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

List<SnChatMember> getValidMembers(List<SnChatMember> members, String? userId) {
  return members.where((member) => member.accountId != userId).toList();
}

class RoomAppBar extends ConsumerWidget {
  final SnChatRoom room;
  final SnChatOnlineStatus? onlineStatus;

  const RoomAppBar({super.key, required this.room, required this.onlineStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final validMembers = getValidMembers(
      room.members ?? [],
      userInfo.value?.id,
    );
    final isDirect = room.type == 1;
    final title = (isDirect && room.name == null)
        ? validMembers.map((e) => e.account.nick).join(', ')
        : room.name!;
    final subtitle = _buildSubtitle(context, room, validMembers, onlineStatus);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _RoomAvatar(room: room, validMembers: validMembers, size: 28),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).fontSize(17),
              if (subtitle != null) ...[subtitle],
            ],
          ),
        ),
      ],
    );
  }
}

Widget? _buildSubtitle(
  BuildContext context,
  SnChatRoom room,
  List<SnChatMember> validMembers,
  SnChatOnlineStatus? onlineStatus,
) {
  final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
    fontSize: 11,
    height: 1,
    color:
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface,
  );

  if (room.type == 1) {
    final status = onlineStatus?.directMessageStatus;
    final isBot = validMembers.any(
      (member) => member.account.automatedId != null,
    );
    final label = status != null
        ? getStatusDisplayLabel(context, status)
        : null;
    if (label == null && !isBot) return null;
    final statusColor = getStatusIndicatorColor(status);
    final isOnline = showsOnlinePresence(status);

    return Row(
      children: [
        if (label != null) ...[
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isOnline ? statusColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor,
                width: isOnline ? 0 : 1.5,
              ),
            ),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle,
            ),
          ),
        ],
        if (label != null && isBot) const SizedBox(width: 6),
        if (isBot) _BotChip(style: subtitleStyle),
      ],
    );
  }

  final validAccountIds = validMembers
      .map((member) => member.account.id)
      .toSet();
  final onlineNames =
      onlineStatus?.onlineAccounts
          .where((account) => validAccountIds.contains(account.id))
          .map((account) => account.nick.trim())
          .where((name) => name.isNotEmpty)
          .toList() ??
      const <String>[];

  String subtitleText;
  if (onlineNames.isNotEmpty) {
    final preview = onlineNames.take(3).join(', ');
    final remaining = onlineNames.length - 3;
    subtitleText = remaining > 0
        ? '$preview +$remaining online'
        : '$preview online';
  } else {
    final count = onlineStatus?.onlineCount ?? 0;
    subtitleText = count > 0
        ? '$count online'
        : '${validMembers.length} members';
  }

  return Row(
    children: [
      if (_shouldShowSubtitleOnlineDot(room, onlineStatus))
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      Expanded(
        child: Text(
          subtitleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
      ),
    ],
  );
}

bool _shouldShowSubtitleOnlineDot(
  SnChatRoom room,
  SnChatOnlineStatus? onlineStatus,
) {
  return room.type != 1 && (onlineStatus?.onlineCount ?? 0) >= 2;
}

class _BotChip extends StatelessWidget {
  final TextStyle? style;

  const _BotChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.35)),
      ),
      child: Text(
        'Bot',
        style: style?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  final SnChatRoom room;
  final List<SnChatMember> validMembers;
  final double size;

  const _RoomAvatar({
    required this.room,
    required this.validMembers,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: (room.type == 1 && room.picture == null)
          ? SplitAvatarWidget(
              files: validMembers
                  .map((e) => e.account.profile.picture)
                  .toList(),
            )
          : room.picture != null
          ? ProfilePictureWidget(file: room.picture, fallbackIcon: Symbols.chat)
          : CircleAvatar(
              child: Text(
                room.name![0].toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
    );
  }
}
