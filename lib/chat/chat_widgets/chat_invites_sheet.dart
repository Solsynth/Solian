import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/chat/chat_pod/chat_room.dart';
import 'package:island/chat/chat_widgets/chat_room_list_tile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/realms/realm/realms.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatInvitesSheet extends HookConsumerWidget {
  const ChatInvitesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(chatroomInvitesProvider);

    Future<void> acceptInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/messager/chat/invites/${invite.chatRoom!.id}/accept',
        );
        ref.invalidate(chatroomInvitesProvider);
        ref.invalidate(chatRoomJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/messager/chat/invites/${invite.chatRoom!.id}/decline',
        );
        ref.invalidate(chatroomInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'invites'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(realmInvitesProvider);
          },
        ),
      ],
      child: invites.when(
        data: (items) => items.isEmpty
            ? Center(
                child: Text('invitesEmpty', textAlign: TextAlign.center).tr(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final invite = items[index];
                  return ChatRoomListTile(
                    room: invite.chatRoom!,
                    isDirect: invite.chatRoom!.type == 1,
                    subtitle: Row(
                      spacing: 6,
                      children: [
                        if (invite.chatRoom!.type == 1)
                          Badge(
                            label: const Text('directMessage').tr(),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.check),
                          onPressed: () => acceptInvite(invite),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.close),
                          onPressed: () => declineInvite(invite),
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
