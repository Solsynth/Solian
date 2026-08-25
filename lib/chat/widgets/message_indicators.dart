import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/message.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/database.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class MessageIndicators extends StatelessWidget {
  final DateTime? editedAt;
  final MessageStatus? status;
  final bool isCurrentUser;
  final String? roomId;
  final String? messageId;
  final String? senderId;
  final Color textColor;
  final EdgeInsets padding;

  const MessageIndicators({
    super.key,
    this.editedAt,
    this.status,
    required this.isCurrentUser,
    this.roomId,
    this.messageId,
    this.senderId,
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
        _ReadIndicator(
          roomId: roomId!,
          messageId: messageId!,
          senderId: senderId,
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

class _ReadIndicator extends ConsumerWidget {
  final String roomId;
  final String messageId;
  final String? senderId;
  final Color textColor;

  const _ReadIndicator({
    required this.roomId,
    required this.messageId,
    required this.senderId,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Never put a read mark on the current user's own sent message — a peer's
    // high-water mark may land here (it is their latest readable message), but
    // an avatar stack on your own bubble reads as noise. Compare the sender
    // directly instead of trusting the isCurrentUser plumbing, which can be
    // wrong while the room identity is still loading.
    final currentUserId = ref.read(userInfoProvider).value?.id;
    if (senderId == null ||
        currentUserId == null ||
        senderId == currentUserId) {
      return const SizedBox.shrink();
    }

    final state = ref.watch(_roomReadStateProvider(roomId)).value;
    if (state == null) return const SizedBox.shrink();

    // Readers whose high water mark is exactly this message — the last
    // message each of them has read. Their avatars stack here. This includes
    // the current user's own avatar once they have read up to this message
    // ("our reading status"), but never on messages they sent themselves.
    final readerIds = state.lastReadMessage.entries
        .where((e) => e.value == messageId)
        .map((e) => e.key)
        .toList();

    if (readerIds.isEmpty) return const SizedBox.shrink();

    final readerMembers = readerIds
        .map((id) => state.members.where((m) => m.accountId == id).firstOrNull)
        .whereType<SnChatMember>()
        .toList();

    if (readerMembers.isEmpty) return const SizedBox.shrink();

    return _GroupReadAvatars(
      readerMembers: readerMembers,
      textColor: textColor,
    );
  }
}

// -- Stacked avatars for group read receipts --------------------------------

class _GroupReadAvatars extends StatelessWidget {
  final List<SnChatMember> readerMembers;
  final Color textColor;

  const _GroupReadAvatars({
    required this.readerMembers,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
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

// -- Provider ----------------------------------------------------------------

/// Per-room read state: for each member, the ID of the last message they've
/// read (their high water mark), plus the members themselves. The `lastReadAt`
/// values live on the member records in the DB store — the read-receipt
/// handler persists them — so recomputation is cheap and always has data.
final _roomReadStateProvider = FutureProvider.autoDispose
    .family<_RoomReadState, String>((ref, roomId) async {
      // Invalidate when read receipts arrive or messages change, but never
      // depend on those providers' async values (they go null mid-reload).
      ref.watch(chatRoomProvider(roomId));
      ref.watch(messagesProvider(roomId));

      final db = ref.read(databaseProvider);
      final allMessages = await db.getMessagesForRoom(roomId, limit: 10000);
      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final members = await db.getMembersByRoomId(roomId);

      // Each member's boundary = newest message at-or-before their lastReadAt.
      final lastReadMessage = <String, String>{};
      for (final member in members) {
        final lastReadAt = member.lastReadAt;
        if (lastReadAt == null) continue;

        String? boundary;
        for (final m in allMessages) {
          if (!m.createdAt.isAfter(lastReadAt)) {
            boundary = m.id;
          }
        }
        if (boundary != null) {
          lastReadMessage[member.accountId] = boundary;
        }
      }

      return _RoomReadState(lastReadMessage: lastReadMessage, members: members);
    });

class _RoomReadState {
  final Map<String, String> lastReadMessage;
  final List<SnChatMember> members;

  const _RoomReadState({required this.lastReadMessage, required this.members});
}
