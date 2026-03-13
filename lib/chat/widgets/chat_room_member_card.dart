import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

typedef ChatRoomMemberLookup = ({String roomId, String accountId});

final chatRoomMemberDetailsProvider = FutureProvider.autoDispose
    .family<SnChatMember?, ChatRoomMemberLookup>((ref, lookup) async {
      final apiClient = ref.watch(apiClientProvider);
      const take = 100;
      var offset = 0;

      while (true) {
        final response = await apiClient.get(
          '/messager/chat/${lookup.roomId}/members',
          queryParameters: {
            'offset': offset.toString(),
            'take': take,
            'withStatus': true,
          },
        );
        final members = (response.data as List)
            .map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final candidate in members) {
          if (candidate.accountId == lookup.accountId) return candidate;
        }
        if (members.length < take) return null;
        offset += members.length;
      }
    });

class ChatRoomMemberCard extends HookConsumerWidget {
  final String roomId;
  final SnChatMember member;
  final bool canModerate;
  final Future<void> Function()? onUpdated;

  const ChatRoomMemberCard({
    super.key,
    required this.roomId,
    required this.member,
    required this.canModerate,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(chatRoomProvider(roomId));
    final remoteMemberAsync = ref.watch(
      chatRoomMemberDetailsProvider((
        roomId: roomId,
        accountId: member.accountId,
      )),
    );
    final effectiveMember = remoteMemberAsync.value ?? member;
    final fallbackStatus = ref.watch(
      accountStatusProvider(effectiveMember.account.name),
    );
    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();
    final apiClient = ref.watch(apiClientProvider);
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isSelf = currentUserId == effectiveMember.accountId;
    final isPendingInvite = effectiveMember.joinedAt == null;
    final activeTimeoutUntil = effectiveMember.timeoutUntil;
    final hasActiveTimeout =
        activeTimeoutUntil != null &&
        activeTimeoutUntil.isAfter(DateTime.now());
    final canManageTarget = canModerate && !isSelf;
    final loading = useState(false);
    final effectiveStatus = effectiveMember.status ?? fallbackStatus.value;
    final isOwner = roomAsync.value?.accountId == effectiveMember.accountId;

    Future<void> refreshAfterAction() async {
      ref.invalidate(chatRoomProvider(roomId));
      ref.invalidate(chatRoomIdentityProvider(roomId));
      ref.invalidate(
        chatRoomMemberDetailsProvider((
          roomId: roomId,
          accountId: member.accountId,
        )),
      );
      await onUpdated?.call();
    }

    Future<void> applyTimeout(Duration duration) async {
      if (!canManageTarget || isPendingInvite) return;
      loading.value = true;
      try {
        final timeoutUntil = DateTime.now()
            .add(duration)
            .toUtc()
            .toIso8601String();
        await apiClient.post(
          '/messager/chat/$roomId/members/${effectiveMember.accountId}/timeout',
          data: {'timeout_until': timeoutUntil},
        );
        await refreshAfterAction();
        if (context.mounted) {
          showSnackBar(
            'Member timed out until ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(timeoutUntil).toLocal())}',
          );
          Navigator.of(context).maybePop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        loading.value = false;
      }
    }

    Future<void> removeTimeout() async {
      if (!canManageTarget || !hasActiveTimeout) return;
      loading.value = true;
      try {
        await apiClient.delete(
          '/messager/chat/$roomId/members/${effectiveMember.accountId}/timeout',
        );
        await refreshAfterAction();
        if (context.mounted) {
          showSnackBar('Member timeout removed');
          Navigator.of(context).maybePop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        loading.value = false;
      }
    }

    Future<void> removeMember() async {
      if (!canManageTarget) return;
      final confirmed = await showConfirmAlert(
        'removeChatMemberHint'.tr(),
        'removeChatMember'.tr(),
        icon: Symbols.person_remove,
        isDanger: true,
      );
      if (!confirmed) return;

      loading.value = true;
      try {
        await apiClient.delete(
          '/messager/chat/$roomId/members/${effectiveMember.accountId}',
        );
        await refreshAfterAction();
        if (context.mounted) {
          showSnackBar('Member removed');
          Navigator.of(context).maybePop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        loading.value = false;
      }
    }

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfilePictureWidget(
                      file: effectiveMember.account.profile.picture,
                      radius: 22,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountName(
                            account: effectiveMember.account,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '@${effectiveMember.account.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Gap(8),
                          Text(
                            'Joined ${effectiveMember.joinedAt?.formatSystem()} · ${effectiveMember.joinedAt?.formatRelative(context)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (effectiveStatus != null)
                      AccountStatusLabel(
                        status: effectiveStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isOwner)
                      Chip(
                        avatar: const Icon(Symbols.shield_person, size: 18),
                        label: const Text('Owner'),
                      )
                    else
                      Chip(
                        avatar: const Icon(Symbols.person, size: 18),
                        label: const Text('Member'),
                      ),
                    if (isSelf)
                      Chip(
                        avatar: const Icon(Symbols.person, size: 18),
                        label: const Text('You'),
                      ),
                    if (isPendingInvite)
                      Chip(
                        avatar: const Icon(Symbols.pending_actions, size: 18),
                        label: const Text('Invite pending'),
                      ),
                    if (hasActiveTimeout)
                      Chip(
                        avatar: const Icon(Symbols.timer_pause, size: 18),
                        label: Text(
                          'Timed out until ${activeTimeoutUntil.formatSystem()}',
                        ),
                      ),
                  ],
                ),
                if (canManageTarget && !isPendingInvite)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          const Icon(Symbols.timer, size: 16),
                          Text(
                            'Timeout Actions',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ).opacity(0.75),
                      const Gap(4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (hasActiveTimeout)
                            FilledButton.tonalIcon(
                              icon: Icon(
                                Symbols.timer_off,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              label: const Text(
                                'Cancel timeout',
                              ).textColor(Theme.of(context).colorScheme.error),
                              onPressed: loading.value ? null : removeTimeout,
                            ),
                          FilledButton.tonal(
                            onPressed: loading.value
                                ? null
                                : () =>
                                      applyTimeout(const Duration(minutes: 10)),
                            child: const Text('10m'),
                          ),
                          FilledButton.tonal(
                            onPressed: loading.value
                                ? null
                                : () => applyTimeout(const Duration(hours: 1)),
                            child: const Text('1hr'),
                          ),
                          FilledButton.tonal(
                            onPressed: loading.value
                                ? null
                                : () => applyTimeout(const Duration(days: 1)),
                            child: const Text('1d'),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (canManageTarget)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          const Icon(Symbols.group, size: 16),
                          Text(
                            'Membership Actions',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ).opacity(0.75),
                      const Gap(4),
                      FilledButton.tonalIcon(
                        icon: Icon(
                          Symbols.person_remove,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text(
                          isPendingInvite ? 'Remove invite' : 'Remove member',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: loading.value ? null : removeMember,
                      ),
                    ],
                  ),
              ],
            ).padding(horizontal: 20, top: 16),
            AccountNameplate(
              name: effectiveMember.account.name,
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showChatRoomMemberCard(
  BuildContext context, {
  required String roomId,
  required SnChatMember member,
  required bool canModerate,
  Future<void> Function()? onUpdated,
  Offset? offset,
}) async {
  await showPopupCard<void>(
    offset: offset ?? Offset.zero,
    context: context,
    builder: (context) => ChatRoomMemberCard(
      roomId: roomId,
      member: member,
      canModerate: canModerate,
      onUpdated: onUpdated,
    ),
    alignment: Alignment.center,
    dimBackground: true,
  );
}

class _MemberMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MemberMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const Gap(2),
              Text(value, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatRoomMemberRegion extends HookConsumerWidget {
  final String roomId;
  final SnChatMember member;
  final Widget child;

  const ChatRoomMemberRegion({
    super.key,
    required this.roomId,
    required this.member,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomIdentity = ref.watch(chatRoomIdentityProvider(roomId));
    final chatRoom = ref.watch(chatRoomProvider(roomId));
    final canModerate =
        chatRoom.value?.accountId == roomIdentity.value?.accountId ||
        chatRoom.value?.type == 1;

    return GestureDetector(
      child: child,
      onTapDown: (details) {
        showChatRoomMemberCard(
          context,
          roomId: roomId,
          member: member,
          canModerate: canModerate,
          offset: details.localPosition,
        );
      },
    );
  }
}
