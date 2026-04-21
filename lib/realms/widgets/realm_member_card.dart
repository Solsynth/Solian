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

typedef RealmMemberLookup = ({String realmId, String accountId});

final realmMemberDetailsProvider = FutureProvider.autoDispose
    .family<SnRealmMember?, RealmMemberLookup>((ref, lookup) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/passport/realms/${lookup.realmId}/members/${lookup.accountId}',
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
    if (role >= 100) return 'realmRoleOwner'.tr();
    if (role >= 50) return 'realmRoleAdmin'.tr();
    return 'realmRoleMember'.tr();
  }

  IconData _getRoleIcon(int role) {
    if (role >= 100) return Symbols.shield_person;
    if (role >= 50) return Symbols.admin_panel_settings;
    return Symbols.person;
  }

  void _openActionSheet(BuildContext context, WidgetRef ref) {
    final effectiveMember = ref.read(
      realmMemberDetailsProvider((
        realmId: realmId,
        accountId: member.accountId,
      )),
    );
    if (effectiveMember.value == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RealmMemberActionSheet(
        realmId: realmId,
        member: effectiveMember.value!,
        canModerate: canModerate,
        onUpdated: onUpdated,
      ),
    );
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
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final role = effectiveMember.role;
    final isSelf = currentUserId == effectiveMember.accountId;
    final canManageTarget = canModerate && !isSelf;

    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner with account background if available
        if (effectiveMember.account?.profile.background != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CloudImageWidget(
                file: effectiveMember.account!.profile.background!,
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
                      file: effectiveMember.account?.profile.picture,
                      radius: 24,
                    ),
                  ),
                  onTap: () {
                    if (effectiveMember.account != null) {
                      Navigator.pop(context);
                      context.router.push(
                        AccountProfileRoute(
                          name: effectiveMember.account!.name,
                        ),
                      );
                    }
                  },
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with label
                      if (effectiveMember.account != null)
                        Row(
                          children: [
                            AccountName(
                              account: effectiveMember.account!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (effectiveMember.label != null)
                              RealmLabelWidget(
                                label: effectiveMember.label!,
                              ).padding(left: 6),
                          ],
                        ),
                      // Username and nick
                      if (effectiveMember.nick != null)
                        Text(
                          '@${effectiveMember.nick}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (effectiveMember.account != null)
                        Text(
                          '@${effectiveMember.account!.name}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Status
            if (effectiveMember.account != null)
              AccountStatusWidget(
                uname: effectiveMember.account!.name,
                padding: EdgeInsets.zero,
              ),
            // Member info section
            if (effectiveMember.account != null) ...[
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
              // Bot indicator
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
                ).padding(top: 2),
              // Timezone
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
              // Level progress
              Row(
                spacing: 6,
                children: [
                  Icon(Symbols.stairs, size: 17, fill: 1).padding(right: 2),
                  Text(
                    'levelingProgressLevel'.tr(
                      args: [effectiveMember.account!.profile.level.toString()],
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
              // Badges
              if (effectiveMember.account!.badges.isNotEmpty)
                BadgeList(
                  badges: effectiveMember.account!.badges,
                ).padding(top: 12),
              // Activity presence
              ActivityPresenceWidget(
                uname: effectiveMember.account!.name,
                isCompact: true,
                compactPadding: const EdgeInsets.only(top: 12),
              ),
            ],
            const Gap(12),
            // Role and membership chips
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
                    label: Text('you'.tr()),
                  ),
              ],
            ),
            // Join date
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

class _RealmMemberActionSheet extends HookConsumerWidget {
  final String realmId;
  final SnRealmMember member;
  final bool canModerate;
  final Future<void> Function()? onUpdated;

  const _RealmMemberActionSheet({
    required this.realmId,
    required this.member,
    required this.canModerate,
    this.onUpdated,
  });

  String _getRoleLabel(int role) {
    if (role >= 100) return 'realmRoleOwner'.tr();
    if (role >= 50) return 'realmRoleAdmin'.tr();
    return 'realmRoleMember'.tr();
  }

  Future<void> _refreshAfterAction(WidgetRef ref) async {
    ref.invalidate(
      realmMemberDetailsProvider((
        realmId: realmId,
        accountId: member.accountId,
      )),
    );
    await onUpdated?.call();
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'removeRealmMemberHint'.tr(),
      'removeRealmMember'.tr(),
      icon: Symbols.person_remove,
      isDanger: true,
    );
    if (!confirmed) return;

    final client = ref.read(solarNetworkClientProvider);
    try {
      await client.dio.delete(
        '/passport/realms/$realmId/members/${member.accountId}',
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

  Future<void> _updateRole(
    BuildContext context,
    WidgetRef ref,
    int newRole,
  ) async {
    final client = ref.read(solarNetworkClientProvider);
    try {
      await client.dio.put(
        '/passport/realms/$realmId/members/${member.accountId}',
        data: {'role': newRole},
      );
      await _refreshAfterAction(ref);
      if (context.mounted) {
        showSnackBar('roleUpdated'.tr());
        Navigator.of(context).pop();
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final role = member.role;

    return SheetScaffold(
      titleText: 'memberActions'.tr(),
      heightFactor: 0.6,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Member info header
          ListTile(
            leading: ProfilePictureWidget(
              file: member.account?.profile.picture,
              radius: 20,
            ),
            title: member.account != null
                ? AccountName(account: member.account!)
                : Text('@${member.accountId}'),
            subtitle: Text(_getRoleLabel(role)),
          ),
          const Divider(),
          // Role management section
          if (canModerate) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'roleActions'.tr(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (role != 0)
              ListTile(
                leading: const Icon(Symbols.person),
                title: Text('realmRoleMember'.tr()),
                subtitle: Text('setAsMember'.tr()),
                enabled: !loading.value,
                onTap: loading.value
                    ? null
                    : () => _updateRole(context, ref, 0),
              ),
            if (role < 100)
              ListTile(
                leading: const Icon(Symbols.admin_panel_settings),
                title: Text('realmRoleAdmin'.tr()),
                subtitle: Text('setAsAdmin'.tr()),
                enabled: !loading.value,
                onTap: loading.value
                    ? null
                    : () => _updateRole(context, ref, 50),
              ),
            if (role < 50)
              ListTile(
                leading: const Icon(Symbols.shield_person),
                title: Text('realmRoleOwner'.tr()),
                subtitle: Text('setAsOwner'.tr()),
                enabled: !loading.value,
                onTap: loading.value
                    ? null
                    : () => _updateRole(context, ref, 100),
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
              title: Text('removeMember'.tr()),
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
