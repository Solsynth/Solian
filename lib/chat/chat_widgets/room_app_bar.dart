import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

List<SnChatMember> getValidMembers(List<SnChatMember> members, String? userId) {
  return members.where((member) => member.accountId != userId).toList();
}

class RoomAppBar extends ConsumerWidget {
  final SnChatRoom room;
  final int onlineCount;
  final bool compact;

  const RoomAppBar({
    super.key,
    required this.room,
    required this.onlineCount,
    required this.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final validMembers = getValidMembers(
      room.members ?? [],
      userInfo.value?.id,
    );

    if (compact) {
      return Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _OnlineCountBadge(
            onlineCount: onlineCount,
            child: _RoomAvatar(
              room: room,
              validMembers: validMembers,
              size: 28,
            ),
          ),
          Text(
            (room.type == 1 && room.name == null)
                ? validMembers.map((e) => e.account.nick).join(', ')
                : room.name!,
          ).fontSize(19),
        ],
      );
    }

    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _OnlineCountBadge(
          onlineCount: onlineCount,
          child: _RoomAvatar(room: room, validMembers: validMembers, size: 26),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? validMembers.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(15),
      ],
    );
  }
}

class _OnlineCountBadge extends StatelessWidget {
  final int onlineCount;
  final Widget child;

  const _OnlineCountBadge({required this.onlineCount, required this.child});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: onlineCount > 1,
      label: Text('$onlineCount'),
      textStyle: GoogleFonts.robotoMono(fontSize: 10),
      textColor: Colors.white,
      backgroundColor: onlineCount > 1 ? Colors.green : Colors.grey,
      offset: const Offset(6, 14),
      child: child,
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
