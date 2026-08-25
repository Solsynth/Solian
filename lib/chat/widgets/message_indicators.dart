import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/message.dart';
import 'package:island/core/database.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:styled_widget/styled_widget.dart';

class MessageIndicators extends StatelessWidget {
  final DateTime? editedAt;
  final MessageStatus? status;
  final bool isCurrentUser;
  final String? roomId;
  final DateTime? messageCreatedAt;
  final Color textColor;
  final EdgeInsets padding;

  const MessageIndicators({
    super.key,
    this.editedAt,
    this.status,
    required this.isCurrentUser,
    this.roomId,
    this.messageCreatedAt,
    required this.textColor,
    this.padding = const EdgeInsets.only(left: 6),
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (editedAt != null) {
      children.add(
        Text(
          'edited'.tr().toLowerCase(),
          style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
        ),
      );
    }

    if (isCurrentUser && status != null && status != MessageStatus.sent) {
      children.add(
        _buildStatusIcon(
          context,
          status!,
          textColor.withOpacity(0.7),
        ).padding(bottom: 2),
      );
    }

    if (isCurrentUser &&
        messageCreatedAt != null &&
        roomId != null &&
        status == MessageStatus.sent) {
      children.add(
        _DmReadIndicator(
          roomId: roomId!,
          messageCreatedAt: messageCreatedAt!,
          textColor: textColor,
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    MessageStatus status,
    Color textColor,
  ) {
    switch (status) {
      case MessageStatus.pending:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            padding: EdgeInsets.zero,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(textColor),
          ),
        ).padding(bottom: 2);
      case MessageStatus.sent:
        return const SizedBox.shrink();
      case MessageStatus.failed:
        return Consumer(
          builder: (context, ref, _) => GestureDetector(
            onTap: () {},
            child: const Icon(Icons.error_outline, size: 12, color: Colors.red),
          ),
        );
    }
  }
}

class _DmReadIndicator extends ConsumerWidget {
  final String roomId;
  final DateTime messageCreatedAt;
  final Color textColor;

  const _DmReadIndicator({
    required this.roomId,
    required this.messageCreatedAt,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead =
        ref
            .watch(
              _dmReadByPeerProvider(
                _DmReadKey(roomId: roomId, createdAt: messageCreatedAt),
              ),
            )
            .value ??
        false;
    return Icon(
      Icons.done_all_rounded,
      size: 14,
      color: (isRead ? Colors.blueAccent : textColor).withOpacity(0.8),
    ).padding(bottom: 1);
  }
}

class _DmReadKey {
  final String roomId;
  final DateTime createdAt;
  const _DmReadKey({required this.roomId, required this.createdAt});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DmReadKey &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          createdAt == other.createdAt;
  @override
  int get hashCode => Object.hash(runtimeType, roomId, createdAt);
}

final _dmReadByPeerProvider = FutureProvider.autoDispose
    .family<bool, _DmReadKey>((ref, key) async {
      final db = ref.read(databaseProvider);
      final room = await db.getChatRoomById(key.roomId);
      if (room == null || room.type != 1) return false;

      final currentUserId = ref.watch(userInfoProvider).value?.id;
      if (currentUserId == null) return false;

      final roomMembers = await db.getMembersByRoomId(key.roomId);
      final peer = roomMembers
          .where((m) => m.accountId != currentUserId)
          .toList();
      if (peer.isEmpty) return false;

      final lastReadAt = peer.first.lastReadAt;
      if (lastReadAt == null) return false;
      return !key.createdAt.isAfter(lastReadAt);
    });
