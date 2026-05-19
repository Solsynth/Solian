import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_online_count.dart';

class OnlineAvatarBadge extends HookConsumerWidget {
  final String roomId;
  final String accountId;
  final double size;
  final Widget child;

  const OnlineAvatarBadge({
    super.key,
    required this.roomId,
    required this.accountId,
    required this.child,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineStatus = ref.watch(chatOnlineCountProvider(roomId));
    final isOnlineInRoom =
        onlineStatus.value?.onlineAccounts.any(
          (account) => account.id == accountId,
        ) ??
        false;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (isOnlineInRoom)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
