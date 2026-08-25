import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/message.dart';
import 'package:island/core/database.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class MessageIndicators extends StatelessWidget {
  final DateTime? editedAt;
  final MessageStatus? status;
  final bool isCurrentUser;
  final String? roomId;
  final String? messageId;
  final Color textColor;
  final EdgeInsets padding;

  const MessageIndicators({
    super.key,
    this.editedAt,
    this.status,
    required this.isCurrentUser,
    this.roomId,
    this.messageId,
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

    if (messageId != null && roomId != null && status == MessageStatus.sent) {
      children.add(
        _DmReadIndicator(
          roomId: roomId!,
          messageId: messageId!,
          isOutgoing: isCurrentUser,
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

// -- Read receipt indicator -------------------------------------------------

class _DmReadIndicator extends ConsumerWidget {
  final String roomId;
  final String messageId;
  final bool isOutgoing;
  final Color textColor;

  const _DmReadIndicator({
    required this.roomId,
    required this.messageId,
    required this.isOutgoing,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highWaterMarks = ref
        .watch(_groupReadHighWaterMarksProvider(roomId))
        .value;

    if (highWaterMarks == null) {
      return const SizedBox.shrink();
    }

    if (!isOutgoing) {
      // Incoming: has current user read this message?
      final currentUserId = ref.read(userInfoProvider).value?.id;
      if (currentUserId == null) return const SizedBox.shrink();
      final hwMessageId = highWaterMarks[currentUserId];
      final isRead =
          hwMessageId != null &&
          (hwMessageId == messageId || hwMessageId != messageId);
      return Icon(
        Icons.done_all_rounded,
        size: 14,
        color: (isRead ? Colors.blueAccent : textColor).withOpacity(0.8),
      ).padding(bottom: 1);
    }

    // Outgoing: show readers whose high water mark is this message
    final readers = highWaterMarks.entries
        .where((e) => e.value == messageId)
        .map((e) => e.key)
        .toList();

    return _GroupReadAvatars(
      readerIds: readers,
      roomId: roomId,
      textColor: textColor,
    );
  }
}

// -- Stacked avatars for group read receipts --------------------------------

class _GroupReadAvatars extends ConsumerWidget {
  final List<String> readerIds;
  final String roomId;
  final Color textColor;

  const _GroupReadAvatars({
    required this.readerIds,
    required this.roomId,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (readerIds.isEmpty) return const SizedBox.shrink();

    final members = ref.watch(_roomMembersProvider(roomId)).value;
    if (members == null) return const SizedBox.shrink();

    final readerMembers = readerIds
        .map((id) => members.where((m) => m.accountId == id).firstOrNull)
        .whereType<SnChatMember>()
        .toList();

    if (readerMembers.isEmpty) return const SizedBox.shrink();

    const avatarRadius = 8.0;
    const overlap = 4.0;
    const maxVisible = 3;

    final visible = readerMembers.take(maxVisible).toList();
    final overflow = readerMembers.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < visible.length; i++)
          Transform.translate(
            offset: Offset(-i * overlap, 0),
            child: ProfilePictureWidget(
              file: visible[i].account.profile.picture,
              fallbackName: visible[i].account.nick,
              radius: avatarRadius,
            ),
          ),
        if (overflow > 0)
          Transform.translate(
            offset: Offset(-(visible.length * overlap), 0),
            child: Container(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '+$overflow',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.8),
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    ).padding(bottom: 1);
  }
}

// -- Providers ---------------------------------------------------------------

final _roomMembersProvider = FutureProvider.autoDispose
    .family<List<SnChatMember>, String>((ref, roomId) async {
      final db = ref.read(databaseProvider);
      return db.getMembersByRoomId(roomId);
    });

/// High water marks: accountId → messageId of the last message they've read.
final _groupReadHighWaterMarksProvider = FutureProvider.autoDispose
    .family<Map<String, String>, String>((ref, roomId) async {
      final db = ref.read(databaseProvider);
      final room = await db.getChatRoomById(roomId);
      if (room == null) return {};

      final currentUserId = ref.read(userInfoProvider).value?.id;
      if (currentUserId == null) return {};

      final members = await db.getMembersByRoomId(roomId);
      final messages = await db.getMessagesForRoom(roomId, limit: 10000);

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final result = <String, String>{};

      if (room.type == 1) {
        // DM: compute for the peer
        final peer = members.firstWhere(
          (m) => m.accountId != currentUserId,
          orElse: () => members.first,
        );
        if (peer.lastReadAt != null) {
          String? lastReadMessageId;
          for (final msg in messages) {
            if (!msg.createdAt.isAfter(peer.lastReadAt!)) {
              lastReadMessageId = msg.id;
            }
          }
          if (lastReadMessageId != null) {
            result[peer.accountId] = lastReadMessageId;
          }
        }
      } else {
        // Group: compute for all other members
        for (final member in members) {
          if (member.accountId == currentUserId) continue;
          if (member.lastReadAt == null) continue;

          String? lastReadMessageId;
          for (final msg in messages) {
            if (!msg.createdAt.isAfter(member.lastReadAt!)) {
              lastReadMessageId = msg.id;
            }
          }
          if (lastReadMessageId != null) {
            result[member.accountId] = lastReadMessageId;
          }
        }
      }

      return result;
    });
