import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/core/database.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final currentUserId = ref.read(userInfoProvider).value?.id;
    if (senderId == null ||
        currentUserId == null ||
        senderId == currentUserId) {
      return const SizedBox.shrink();
    }

    final state = ref.watch(roomReadStateProvider(roomId)).value;
    if (state == null) return const SizedBox.shrink();

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

    // The current user's own avatar is noise — never render it in the stack.
    final peers = readerMembers
        .where((m) => m.accountId != currentUserId)
        .toList();
    if (peers.isEmpty) return const SizedBox.shrink();

    return _GroupReadAvatars(
      roomId: roomId,
      messageId: messageId,
      readerMembers: peers,
      textColor: textColor,
    );
  }
}

// -- Stacked avatars for group read receipts --------------------------------

/// Stacked read-receipt avatars. At most two avatars are shown; once a third
/// reader arrives the second avatar is replaced by a "+N" badge that opens a
/// sheet listing every reader at this message. The current user's own avatar
/// is never part of the stack.
class _GroupReadAvatars extends HookWidget {
  final String roomId;
  final String messageId;
  final List<SnChatMember> readerMembers;
  final Color textColor;

  const _GroupReadAvatars({
    required this.roomId,
    required this.messageId,
    required this.readerMembers,
    required this.textColor,
  });

  static const int _maxAvatars = 2;
  static const double _avatarRadius = 8.0;
  static const double _overlap = 4.0;

  @override
  Widget build(BuildContext context) {
    final pitch = _avatarRadius * 2 - _overlap;

    final showCounter = readerMembers.length > _maxAvatars;
    final visible = readerMembers.take(_maxAvatars).toList();

    final hasAnimations = !kIsWeb && !(Platform.isAndroid || Platform.isIOS);

    // Reader set from the previous build — used to detect membership changes.
    final prevVisible = usePrevious(visible) ?? const <SnChatMember>[];
    final isFirstBuild = prevVisible.isEmpty;
    final prevIds = prevVisible.map((m) => m.accountId).toSet();
    final currentIds = visible.map((m) => m.accountId).toSet();
    final sameSet =
        prevIds.length == currentIds.length && prevIds.containsAll(currentIds);
    final morphed = !isFirstBuild && !sameSet;
    final newAccounts = isFirstBuild
        ? visible
        : visible.where((m) => !prevIds.contains(m.accountId)).toList();

    // Entrance animation — staggered fade + scale for new readers.
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );
    useEffect(() {
      if (!hasAnimations) {
        controller.value = controller.upperBound;
        return null;
      }
      if (newAccounts.isNotEmpty) {
        controller.forward(from: 0);
      }
      return null;
    }, [newAccounts.length, hasAnimations]);

    // Flight animation — slides existing avatars between slots on reorder.
    final flight = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    useEffect(() {
      if (!hasAnimations || !morphed) return null;
      flight.forward(from: 0);
      return null;
    }, [morphed, hasAnimations]);

    final entryIntervals = useMemoized(
      () => [
        for (var i = 0; i < newAccounts.length; i++)
          Interval(
            (i * 0.3).clamp(0.0, 0.7),
            ((i * 0.3) + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
      ],
      [newAccounts.length],
    );

    final width =
        visible.length * pitch + 4 + (showCounter ? _avatarRadius * 2 : 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showReadersSheet(context),
        child: AnimatedBuilder(
          animation: Listenable.merge([controller, flight]),
          builder: (context, _) {
            return SizedBox(
              width: width,
              height: _avatarRadius * 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < visible.length; i++)
                    _SlotAvatar(
                      key: ValueKey('read-avatar-${visible[i].accountId}'),
                      member: visible[i],
                      left: _slotLeft(
                        member: visible[i],
                        index: i,
                        prevVisible: prevVisible,
                        pitch: pitch,
                        flight: flight,
                      ),
                      progress: _entryProgress(
                        member: visible[i],
                        index: i,
                        prevIds: prevIds,
                        newAccounts: newAccounts,
                        entryIntervals: entryIntervals,
                        controller: controller,
                      ),
                      avatarRadius: _avatarRadius,
                    ),
                  if (showCounter)
                    _ReadersCounterBadge(
                      left: visible.length * pitch + 4,
                      count: readerMembers.length,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReadersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ReadersSheet(
        roomId: roomId,
        messageId: messageId,
        readerMembers: readerMembers,
      ),
    );
  }

  double _slotLeft({
    required SnChatMember member,
    required int index,
    required List<SnChatMember> prevVisible,
    required double pitch,
    required Animation<double> flight,
  }) {
    final prevIndex = prevVisible.indexWhere(
      (m) => m.accountId == member.accountId,
    );
    if (prevIndex < 0) return index * pitch;
    // Glide from the previous slot to the current one.
    return index * pitch + (prevIndex - index) * pitch * (1 - flight.value);
  }

  double _entryProgress({
    required SnChatMember member,
    required int index,
    required Set<String> prevIds,
    required List<SnChatMember> newAccounts,
    required List<Interval> entryIntervals,
    required AnimationController controller,
  }) {
    if (prevIds.contains(member.accountId)) return 1.0;
    final newIndex = newAccounts.indexWhere(
      (m) => m.accountId == member.accountId,
    );
    if (newIndex < 0) return 1.0;
    return entryIntervals[newIndex].transform(controller.value);
  }
}

/// A single stacked avatar positioned at [left], faded/scaled by [progress].
class _SlotAvatar extends StatelessWidget {
  final SnChatMember member;
  final double left;
  final double progress;
  final double avatarRadius;

  const _SlotAvatar({
    super.key,
    required this.member,
    required this.left,
    required this.progress,
    required this.avatarRadius,
  });

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    return Positioned(
      left: left,
      top: 0,
      child: Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.6 + t * 0.4,
          child: ProfilePictureWidget(
            file: member.account.profile.picture,
            fallbackName: member.account.nick,
            radius: avatarRadius,
          ),
        ),
      ),
    );
  }
}

/// Tappable "+N" badge — opens the readers sheet.
class _ReadersCounterBadge extends StatelessWidget {
  final double left;
  final int count;

  const _ReadersCounterBadge({required this.left, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Sheet listing every reader at this message.
class _ReadersSheet extends StatelessWidget {
  final String roomId;
  final String messageId;
  final List<SnChatMember> readerMembers;

  const _ReadersSheet({
    required this.roomId,
    required this.messageId,
    required this.readerMembers,
  });

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'readUpToHereCount'.tr(
        args: [readerMembers.length.toString()],
      ),
      heightFactor: 0.6,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: readerMembers.length,
        itemBuilder: (context, index) {
          final member = readerMembers[index];
          return ListTile(
            leading: ProfilePictureWidget(
              file: member.account.profile.picture,
              fallbackName: member.account.nick,
              radius: 20,
            ),
            title: AccountName(
              account: member.account,
              textOverride: member.nick,
            ),
            subtitle: Text('@${member.account.name}'),
          );
        },
      ),
    );
  }
}

// -- Provider ----------------------------------------------------------------

/// Per-room read state: for each member, the ID of the last message they've
/// read (their high water mark), plus the members themselves. The `lastReadAt`
/// values live on the member records in the DB store — the read-receipt
/// handler persists them — so recomputation is cheap and always has data.
final roomReadStateProvider = FutureProvider.autoDispose
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

/// Optimistically write [lastReadAt] for [accountId] in [roomId] to the local
/// DB and invalidate [roomReadStateProvider] so the read-receipt avatars
/// update immediately.  Called from [ChatRoomScreen] when the user is
/// viewing the latest messages.
Future<void> markRoomRead(
  WidgetRef ref,
  String roomId,
  String accountId,
  DateTime lastReadAt,
) async {
  final db = ref.read(databaseProvider);
  final member = await db.getMemberByRoomAndAccount(roomId, accountId);
  if (member == null) return;
  if (member.lastReadAt != null && !lastReadAt.isAfter(member.lastReadAt!)) {
    return;
  }
  await db.saveMember(member.copyWith(lastReadAt: lastReadAt));
  ref.invalidate(roomReadStateProvider(roomId));
}
