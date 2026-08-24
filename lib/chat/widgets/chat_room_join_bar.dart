import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The join affordance for a chat room the current user has not joined,
/// rendered as a calm inset strip.
///
/// Realm-linked rooms require a realm membership first: the strip explains
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
    final inviteOnly = !room.isCommunity;

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

    final realmName = linkedRealm?.name.isNotEmpty == true
        ? linkedRealm!.name
        : linkedRealm?.slug ?? '';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            _JoinBadge(
              picture: needsRealmJoin ? linkedRealm?.picture : room.picture,
              icon: inviteOnly
                  ? Symbols.lock
                  : needsRealmJoin
                  ? Symbols.public
                  : Symbols.group,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                inviteOnly
                    ? 'chatJoinInviteOnlyHint'.tr()
                    : needsRealmJoin
                    ? 'chatJoinRealmRequiredHint'.tr(
                        namedArgs: {'realm': realmName},
                      )
                    : 'chatJoinHint'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Gap(12),
            if (!inviteOnly)
              FilledButton.tonalIcon(
                onPressed: needsRealmJoin ? joinRealmThenRoom : joinRoom,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Symbols.add, size: 18),
                label: Text(
                  needsRealmJoin
                      ? 'chatJoinRealmAndChat'.tr()
                      : 'chatJoin'.tr(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JoinBadge extends StatelessWidget {
  final IDisplayableCloudFile? picture;
  final IconData icon;

  const _JoinBadge({required this.icon, this.picture});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = picture;
    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.secondaryContainer,
      ),
      child: file == null
          ? Icon(icon, size: 20, color: theme.colorScheme.onSecondaryContainer)
          : CloudImageWidget(file: file, fit: BoxFit.cover, imageOnly: true),
    );
  }
}
