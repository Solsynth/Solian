import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/timezone/native.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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

  void _openActionSheet(BuildContext context, WidgetRef ref) {
    final effectiveMember = ref.read(
      chatRoomMemberDetailsProvider((
        roomId: roomId,
        accountId: member.accountId,
      )),
    );
    if (effectiveMember.value == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ChatRoomMemberActionSheet(
        roomId: roomId,
        member: effectiveMember.value!,
        canModerate: canModerate,
        onUpdated: onUpdated,
      ),
    );
  }

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
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isSelf = currentUserId == effectiveMember.accountId;
    final isPendingInvite = effectiveMember.joinedAt == null;
    final activeTimeoutUntil = effectiveMember.timeoutUntil;
    final hasActiveTimeout =
        activeTimeoutUntil != null &&
        activeTimeoutUntil.isAfter(DateTime.now());
    final canManageTarget = canModerate && !isSelf;
    final isOwner = roomAsync.value?.accountId == effectiveMember.accountId;

    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner with account background if available
        if (effectiveMember.account.profile.background != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CloudImageWidget(
                file: effectiveMember.account.profile.background!,
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture with launch icon
                GestureDetector(
                  child: Badge(
                    isLabelVisible: true,
                    padding: const EdgeInsets.all(2),
                    label: Icon(
                      Symbols.launch,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    offset: const Offset(4, 28),
                    child: ProfilePictureWidget(
                      file: effectiveMember.account.profile.picture,
                      radius: 24,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.router.push(
                      AccountProfileRoute(name: effectiveMember.account.name),
                    );
                  },
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with realm label
                      Row(
                        children: [
                          if (effectiveMember.nick?.isNotEmpty == true)
                            Tooltip(
                              message: 'originalNick'.tr(
                                args: [effectiveMember.account.nick],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AccountName(
                                    account: effectiveMember.account,
                                    textOverride: effectiveMember.nick,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(4),
                                  const Icon(Symbols.edit, size: 14),
                                ],
                              ),
                            )
                          else
                            AccountName(
                              account: effectiveMember.account,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (effectiveMember.realmLabel != null)
                            RealmLabelWidget(
                              label: effectiveMember.realmLabel!,
                            ).padding(left: 6),
                        ],
                      ),
                      // Username
                      Text(
                        '@${effectiveMember.account.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // Realm bio if available
                      if (effectiveMember.realmBio?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            effectiveMember.realmBio!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Status
            AccountStatusWidget(
              uname: effectiveMember.account.name,
              padding: EdgeInsets.zero,
            ),
            const Gap(8),
            // Social credits
            Tooltip(
              message: 'creditsStatus'.tr(),
              child: Row(
                spacing: 6,
                children: [
                  Icon(
                    Symbols.attribution,
                    size: 17,
                    fill: 1,
                  ).padding(right: 2),
                  Text(
                    '${effectiveMember.account.profile.socialCredits.toStringAsFixed(2)} pts',
                  ).fontSize(12),
                  switch (effectiveMember.account.profile.socialCreditsLevel) {
                    -1 => Text('socialCreditsLevelPoor').tr(),
                    0 => Text('socialCreditsLevelNormal').tr(),
                    1 => Text('socialCreditsLevelGood').tr(),
                    2 => Text('socialCreditsLevelExcellent').tr(),
                    _ => Text('unknown').tr(),
                  }.fontSize(12),
                ],
              ),
            ),
            // Bot indicator
            if (effectiveMember.account.automatedId != null)
              Row(
                spacing: 6,
                children: [
                  Icon(Symbols.smart_toy, size: 17, fill: 1).padding(right: 2),
                  Text('accountAutomated').tr().fontSize(12),
                ],
              ).padding(top: 2),
            // Timezone
            if (effectiveMember.account.profile.timeZone.isNotEmpty && !kIsWeb)
              () {
                try {
                  final tzInfo = getTzInfo(
                    effectiveMember.account.profile.timeZone,
                  );
                  return Row(
                    spacing: 6,
                    children: [
                      Icon(Symbols.alarm, size: 17, fill: 1).padding(right: 2),
                      Text(tzInfo.$2.formatCustomGlobal('HH:mm')).fontSize(12),
                      Text(tzInfo.$1.formatOffsetLocal()).fontSize(12),
                    ],
                  ).padding(top: 2);
                } catch (e) {
                  return Row(
                    spacing: 6,
                    children: [
                      Icon(Symbols.alarm, size: 17, fill: 1).padding(right: 2),
                      Text('timezoneNotFound'.tr()).fontSize(12),
                    ],
                  ).padding(top: 2);
                }
              }(),
            // Level progress
            Row(
              spacing: 6,
              children: [
                Icon(Symbols.stairs, size: 17, fill: 1).padding(right: 2),
                Text(
                  'levelingProgressLevel'.tr(
                    args: [effectiveMember.account.profile.level.toString()],
                  ),
                ).fontSize(12),
                Expanded(
                  child: Tooltip(
                    message:
                        '${(effectiveMember.account.profile.levelingProgress * 100).toStringAsFixed(2)}%',
                    child: LinearProgressIndicator(
                      value: effectiveMember.account.profile.levelingProgress,
                      stopIndicatorRadius: 0,
                      trackGap: 0,
                      minHeight: 4,
                    ).padding(top: 1),
                  ),
                ),
              ],
            ).padding(top: 2),
            // Badges
            if (effectiveMember.account.badges.isNotEmpty)
              BadgeList(
                badges: effectiveMember.account.badges,
              ).padding(top: 12),
            // Activity presence
            ActivityPresenceWidget(
              uname: effectiveMember.account.name,
              isCompact: true,
              compactPadding: const EdgeInsets.only(top: 12),
            ),
            const Gap(12),
            // Role and status chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isOwner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'chatRoleOwner'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'chatRoleMember'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                if (isSelf)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'you'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                if (isPendingInvite)
                  Chip(
                    avatar: const Icon(Symbols.pending_actions, size: 18),
                    label: Text('invitePending'.tr()),
                  ),
                if (hasActiveTimeout)
                  Chip(
                    avatar: const Icon(Symbols.timer_pause, size: 18),
                    label: Text(
                      'timedOutUntil'.tr(
                        args: [activeTimeoutUntil.formatSystem()],
                      ),
                    ),
                  ),
              ],
            ),
            // Join date
            if (!isPendingInvite)
              Text(
                'joinedAt'.tr(
                  args: [
                    effectiveMember.joinedAt?.formatSystem() ?? 'unknown'.tr(),
                    effectiveMember.joinedAt?.formatRelative(context) ??
                        'unknown'.tr(),
                  ],
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).padding(top: 8),
            // Action sheet button for moderation
            if (canManageTarget) ...[
              const Gap(12),
              FilledButton.tonalIcon(
                icon: const Icon(Symbols.more_vert, size: 18),
                label: Text('memberActions'.tr()),
                onPressed: () => _openActionSheet(context, ref),
              ),
            ],
          ],
        ).padding(horizontal: 20, vertical: 16),
      ],
    );

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: width,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ChatRoomMemberActionSheet extends HookConsumerWidget {
  final String roomId;
  final SnChatMember member;
  final bool canModerate;
  final Future<void> Function()? onUpdated;

  const _ChatRoomMemberActionSheet({
    required this.roomId,
    required this.member,
    required this.canModerate,
    this.onUpdated,
  });

  Future<void> _refreshAfterAction(WidgetRef ref) async {
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

  Future<void> _applyTimeout(
    BuildContext context,
    WidgetRef ref,
    Duration duration,
  ) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final timeoutUntil = DateTime.now()
          .add(duration)
          .toUtc()
          .toIso8601String();
      await apiClient.post(
        '/messager/chat/$roomId/members/${member.accountId}/timeout',
        data: {'timeout_until': timeoutUntil},
      );
      await _refreshAfterAction(ref);
      if (context.mounted) {
        showSnackBar(
          'memberTimedOutUntil'.tr(
            args: [
              DateFormat(
                'yyyy-MM-dd HH:mm',
              ).format(DateTime.parse(timeoutUntil).toLocal()),
            ],
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> _removeTimeout(BuildContext context, WidgetRef ref) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.delete(
        '/messager/chat/$roomId/members/${member.accountId}/timeout',
      );
      await _refreshAfterAction(ref);
      if (context.mounted) {
        showSnackBar('memberTimeoutRemoved'.tr());
        Navigator.of(context).pop();
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'removeChatMemberHint'.tr(),
      'removeChatMember'.tr(),
      icon: Symbols.person_remove,
      isDanger: true,
    );
    if (!confirmed) return;

    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.delete(
        '/messager/chat/$roomId/members/${member.accountId}',
      );
      await _refreshAfterAction(ref);
      if (context.mounted) {
        showSnackBar('memberRemoved'.tr());
        Navigator.of(context).pop();
        Navigator.of(context).maybePop();
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> _showCustomTimeoutDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final minutesController = TextEditingController();
    final hoursController = TextEditingController();
    final daysController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('timeoutCustom'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('timeoutCustomHint'.tr()),
            const Gap(16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'days'.tr(),
                suffixText: 'd',
              ),
            ),
            const Gap(8),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'hours'.tr(),
                suffixText: 'hr',
              ),
            ),
            const Gap(8),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'minutes'.tr(),
                suffixText: 'min',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final days = int.tryParse(daysController.text) ?? 0;
      final hours = int.tryParse(hoursController.text) ?? 0;
      final minutes = int.tryParse(minutesController.text) ?? 0;

      if (days == 0 && hours == 0 && minutes == 0) {
        showSnackBar('timeoutCustomEmpty'.tr());
        return;
      }

      final duration = Duration(days: days, hours: hours, minutes: minutes);

      await _applyTimeout(context, ref, duration);
    }

    minutesController.dispose();
    hoursController.dispose();
    daysController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final isPendingInvite = member.joinedAt == null;
    final activeTimeoutUntil = member.timeoutUntil;
    final hasActiveTimeout =
        activeTimeoutUntil != null &&
        activeTimeoutUntil.isAfter(DateTime.now());

    return SheetScaffold(
      titleText: 'memberActions'.tr(),
      heightFactor: 0.7,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Member info header
          ListTile(
            leading: ProfilePictureWidget(
              file: member.account.profile.picture,
              radius: 20,
            ),
            title: AccountName(account: member.account),
            subtitle: isPendingInvite
                ? Text('invitePending'.tr())
                : (hasActiveTimeout
                      ? Text(
                          'timedOutUntil'.tr(
                            args: [activeTimeoutUntil.formatSystem()],
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      : null),
          ),
          const Divider(),
          // Timeout actions section
          if (canModerate && !isPendingInvite) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'timeoutActions'.tr(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (hasActiveTimeout)
              ListTile(
                leading: Icon(
                  Symbols.timer_off,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text('cancelTimeout'.tr()),
                textColor: Theme.of(context).colorScheme.error,
                enabled: !loading.value,
                onTap: loading.value
                    ? null
                    : () => _removeTimeout(context, ref),
              ),
            ListTile(
              leading: const Icon(Symbols.timer_10),
              title: const Text('10m'),
              subtitle: Text('timeoutFor10Minutes'.tr()),
              enabled: !loading.value,
              onTap: loading.value
                  ? null
                  : () => _applyTimeout(
                      context,
                      ref,
                      const Duration(minutes: 10),
                    ),
            ),
            ListTile(
              leading: const Icon(Symbols.timer),
              title: const Text('1hr'),
              subtitle: Text('timeoutFor1Hour'.tr()),
              enabled: !loading.value,
              onTap: loading.value
                  ? null
                  : () => _applyTimeout(context, ref, const Duration(hours: 1)),
            ),
            ListTile(
              leading: const Icon(Symbols.timer_3_alt_1),
              title: const Text('1d'),
              subtitle: Text('timeoutFor1Day'.tr()),
              enabled: !loading.value,
              onTap: loading.value
                  ? null
                  : () => _applyTimeout(context, ref, const Duration(days: 1)),
            ),
            ListTile(
              leading: const Icon(Symbols.tune),
              title: Text('custom'.tr()),
              subtitle: Text('timeoutCustom'.tr()),
              enabled: !loading.value,
              onTap: loading.value
                  ? null
                  : () => _showCustomTimeoutDialog(context, ref),
            ),
            const Divider(),
          ],
          // Membership actions section
          if (canModerate) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'membershipActions'.tr(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Symbols.person_remove,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                isPendingInvite ? 'removeInvite'.tr() : 'removeMember'.tr(),
              ),
              textColor: Theme.of(context).colorScheme.error,
              enabled: !loading.value,
              onTap: loading.value ? null : () => _removeMember(context, ref),
            ),
          ],
        ],
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
