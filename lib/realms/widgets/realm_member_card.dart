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
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/timezone/native.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:island/shared/widgets/account_profile_popup.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

typedef RealmMemberLookup = ({String realmId, String accountId});

final realmMemberDetailsProvider = FutureProvider.autoDispose
    .family<SnRealmMember?, RealmMemberLookup>((ref, lookup) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/realms/${lookup.realmId}/members/${lookup.accountId}',
        queryParameters: {'withStatus': true},
      );
      return SnRealmMember.fromJson(response.data as Map<String, dynamic>);
    });

class RealmMemberCard extends HookConsumerWidget {
  final String realmId;
  final SnRealmMember member;
  final bool canModerate;
  final Future<void> Function()? onUpdated;

  const RealmMemberCard({
    super.key,
    required this.realmId,
    required this.member,
    required this.canModerate,
    this.onUpdated,
  });

  String _getRoleLabel(int role) {
    if (role >= 100) return 'Owner';
    if (role >= 50) return 'Admin';
    return 'Member';
  }

  IconData _getRoleIcon(int role) {
    if (role >= 100) return Symbols.shield_person;
    if (role >= 50) return Icons.admin_panel_settings_outlined;
    return Symbols.person;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteMemberAsync = ref.watch(
      realmMemberDetailsProvider((
        realmId: realmId,
        accountId: member.accountId,
      )),
    );
    final effectiveMember = remoteMemberAsync.value ?? member;
    final client = ref.watch(solarNetworkClientProvider);
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final role = effectiveMember.role;
    final isSelf = currentUserId == effectiveMember.accountId;
    final canManageTarget = canModerate && !isSelf;
    final loading = useState(false);

    Future<void> refreshAfterAction() async {
      ref.invalidate(
        realmMemberDetailsProvider((
          realmId: realmId,
          accountId: member.accountId,
        )),
      );
      await onUpdated?.call();
    }

    Future<void> removeMember() async {
      if (!canManageTarget) return;
      final confirmed = await showConfirmAlert(
        'removeRealmMemberHint'.tr(),
        'removeRealmMember'.tr(),
        icon: Symbols.person_remove,
        isDanger: true,
      );
      if (!confirmed) return;

      loading.value = true;
      try {
        await client.dio.delete(
          '/realms/$realmId/members/${effectiveMember.accountId}',
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

    Future<void> updateRole(int newRole) async {
      if (!canManageTarget) return;
      loading.value = true;
      try {
        await client.dio.put(
          '/realms/$realmId/members/${effectiveMember.accountId}',
          data: {'role': newRole},
        );
        await refreshAfterAction();
        if (context.mounted) {
          showSnackBar('Role updated');
          Navigator.of(context).maybePop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        loading.value = false;
      }
    }

    Widget buildHeader() {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            const Gap(28),
            Icon(
              Icons.groups_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                'Realm Member',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AccountProfilePopupCard(
      header: buildHeader(),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePictureWidget(
                file: effectiveMember.account?.profile.picture,
                radius: 22,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (effectiveMember.account != null)
                      Row(
                        children: [
                          AccountName(
                            account: effectiveMember.account!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (effectiveMember.label != null)
                            RealmLabelWidget(
                              label: effectiveMember.label!,
                            ).padding(left: 6),
                        ],
                      ).padding(bottom: effectiveMember.nick != null ? 4 : 0),
                    if (effectiveMember.nick != null)
                      Text(
                        '@${effectiveMember.nick}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (effectiveMember.account != null)
                      Text(
                        '@${effectiveMember.account?.name ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const Gap(8),
                    Text(
                      'Joined ${effectiveMember.joinedAt?.formatSystem()} · ${effectiveMember.joinedAt?.formatRelative(context)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountStatusWidget(
                uname: effectiveMember.account?.name ?? '',
                padding: EdgeInsets.zero,
              ),
              if (effectiveMember.account != null) ...[
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
                        '${effectiveMember.account!.profile.socialCredits.toStringAsFixed(2)} pts',
                      ).fontSize(12),
                      switch (effectiveMember
                          .account!
                          .profile
                          .socialCreditsLevel) {
                        -1 => Text('socialCreditsLevelPoor').tr(),
                        0 => Text('socialCreditsLevelNormal').tr(),
                        1 => Text('socialCreditsLevelGood').tr(),
                        2 => Text('socialCreditsLevelExcellent').tr(),
                        _ => Text('unknown').tr(),
                      }.fontSize(12),
                    ],
                  ),
                ),
                if (effectiveMember.account!.automatedId != null)
                  Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Symbols.smart_toy,
                        size: 17,
                        fill: 1,
                      ).padding(right: 2),
                      Text('accountAutomated').tr().fontSize(12),
                    ],
                  ),
                if (effectiveMember.account!.profile.timeZone.isNotEmpty &&
                    !kIsWeb)
                  () {
                    try {
                      final tzInfo = getTzInfo(
                        effectiveMember.account!.profile.timeZone,
                      );
                      return Row(
                        spacing: 6,
                        children: [
                          Icon(
                            Symbols.alarm,
                            size: 17,
                            fill: 1,
                          ).padding(right: 2),
                          Text(
                            tzInfo.$2.formatCustomGlobal('HH:mm'),
                          ).fontSize(12),
                          Text(tzInfo.$1.formatOffsetLocal()).fontSize(12),
                        ],
                      ).padding(top: 2);
                    } catch (e) {
                      return Row(
                        spacing: 6,
                        children: [
                          Icon(
                            Symbols.alarm,
                            size: 17,
                            fill: 1,
                          ).padding(right: 2),
                          Text('timezoneNotFound'.tr()).fontSize(12),
                        ],
                      ).padding(top: 2);
                    }
                  }(),
                Row(
                  spacing: 6,
                  children: [
                    Icon(Symbols.stairs, size: 17, fill: 1).padding(right: 2),
                    Text(
                      'levelingProgressLevel'.tr(
                        args: [
                          effectiveMember.account!.profile.level.toString(),
                        ],
                      ),
                    ).fontSize(12),
                    Expanded(
                      child: Tooltip(
                        message:
                            '${(effectiveMember.account!.profile.levelingProgress * 100).toStringAsFixed(2)}%',
                        child: LinearProgressIndicator(
                          value:
                              effectiveMember.account!.profile.levelingProgress,
                          stopIndicatorRadius: 0,
                          trackGap: 0,
                          minHeight: 4,
                        ).padding(top: 1),
                      ),
                    ),
                  ],
                ).padding(top: 2),
                if (effectiveMember.account!.badges.isNotEmpty)
                  BadgeList(
                    badges: effectiveMember.account!.badges,
                  ).padding(top: 12),
                ActivityPresenceWidget(
                  uname: effectiveMember.account!.name,
                  isCompact: true,
                  compactPadding: const EdgeInsets.only(top: 12),
                ),
              ],
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(_getRoleIcon(role), size: 18),
                label: Text(_getRoleLabel(role)),
              ),
              if (isSelf)
                Chip(
                  avatar: const Icon(Symbols.person, size: 18),
                  label: const Text('You'),
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
                    const Icon(Icons.admin_panel_settings_outlined, size: 16),
                    Text(
                      'Role Actions',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ).opacity(0.75),
                const Gap(4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (role != 0)
                      FilledButton.tonal(
                        onPressed: loading.value ? null : () => updateRole(0),
                        child: const Text('Member'),
                      ),
                    if (role < 100)
                      FilledButton.tonal(
                        onPressed: loading.value ? null : () => updateRole(50),
                        child: const Text('Admin'),
                      ),
                    if (role < 50)
                      FilledButton.tonal(
                        onPressed: loading.value ? null : () => updateRole(100),
                        child: const Text('Owner'),
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
                    'Remove member',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: loading.value ? null : removeMember,
                ),
              ],
            ),
        ],
      ).padding(horizontal: 20, vertical: 16),
    );
  }
}

Future<void> showRealmMemberCard(
  BuildContext context, {
  required String realmId,
  required SnRealmMember member,
  required bool canModerate,
  Future<void> Function()? onUpdated,
  Offset? offset,
}) async {
  await showPopupCard<void>(
    offset: offset ?? Offset.zero,
    context: context,
    builder: (context) => RealmMemberCard(
      realmId: realmId,
      member: member,
      canModerate: canModerate,
      onUpdated: onUpdated,
    ),
    alignment: Alignment.center,
    dimBackground: true,
  );
}

class RealmMemberRegion extends HookConsumerWidget {
  final String realmId;
  final SnRealmMember member;
  final Widget child;
  final bool canModerate;

  const RealmMemberRegion({
    super.key,
    required this.realmId,
    required this.member,
    required this.child,
    this.canModerate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        showRealmMemberCard(
          context,
          realmId: realmId,
          member: member,
          canModerate: canModerate,
          offset: details.localPosition,
        );
      },
    );
  }
}
