import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The join affordance for a chat room the current user has not joined.
///
/// Realm-linked rooms require a realm membership first: the bar explains
/// that and offers to join the realm, chaining into the chat join after.
/// Non-community rooms cannot be self-joined at all and say so instead.
class ChatRoomJoinBar extends HookConsumerWidget {
  final SnChatRoom room;
  final VoidCallback? onJoined;

  const ChatRoomJoinBar({super.key, required this.room, this.onJoined});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final identity = ref.watch(chatRoomIdentityProvider(room.id));
    final joinedRealms = ref.watch(realmsJoinedProvider);

    final linkedRealm = room.realmId == null
        ? null
        : joinedRealms.value?.firstWhereOrNull(
            (realm) => realm.id == room.realmId,
          );
    final needsRealmJoin = room.realmId != null && linkedRealm == null;

    Future<void> joinRoom() async {
      showLoadingModal(context);
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post('/messager/chat/${room.id}/members/me');
        ref.invalidate(chatRoomIdentityProvider(room.id));
        ref.invalidate(chatRoomProvider(room.id));
        ref.invalidate(chatRoomJoinedProvider);
        if (context.mounted) showSnackBar('chatJoinSuccess'.tr());
        onJoined?.call();
      } catch (err) {
        if (context.mounted) showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> joinRealmThenRoom() async {
      showLoadingModal(context);
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.realms.joinRealm(linkedRealm!.slug);
        ref.invalidate(realmsJoinedProvider);
        if (context.mounted) hideLoadingModal(context);
        await joinRoom();
      } catch (err) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert(err);
        }
      }
    }

    if (identity.value != null || identity.isLoading) {
      return const SizedBox.shrink();
    }

    final realmName = room.realm?.name.isNotEmpty == true
        ? room.realm!.name
        : room.realm?.slug ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (needsRealmJoin) ...[
          Text(
            'chatJoinRealmRequiredHint'.tr(namedArgs: {'realm': realmName}),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
        ],
        if (!room.isCommunity)
          Text(
            'chatJoinInviteOnlyHint'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          FilledButton.icon(
            onPressed: needsRealmJoin ? joinRealmThenRoom : joinRoom,
            icon: Icon(needsRealmJoin ? Symbols.public : Symbols.add),
            label: Text(needsRealmJoin ? 'joinRealm'.tr() : 'chatJoin'.tr()),
          ),
      ],
    );
  }
}
