import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/leveling_progress.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/debug_sheet.dart';
import 'package:island/notifications/notification.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const AccountFeatureWidget();
  }
}

@RoutePage()
class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: const AccountFeatureWidget(isAside: true),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Flexible(flex: 3, child: const AutoRouter()),
                ],
              ),
            )
          : const AutoRouter(),
    );
  }
}

class AccountFeatureWidget extends HookConsumerWidget {
  final bool isAside;
  const AccountFeatureWidget({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    final user = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);

    if (user.value == null || user.value == null) {
      return _UnauthorizedAccountScreen();
    }

    return AppScaffold(
      isNoBackground: isWide,
      appBar: AppBar(backgroundColor: Colors.transparent, toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Column(
          spacing: 4,
          children: <Widget>[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.value?.profile.background != null)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 7,
                            child: CloudImageWidget(
                              file: user.value?.profile.background,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -24,
                          left: 16,
                          child: GestureDetector(
                            child: ProfilePictureWidget(
                              file: user.value?.profile.picture,
                              radius: 32,
                            ),
                            onTap: () {
                              context.router.push(
                                AccountProfileRoute(name: user.value!.name),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  Builder(
                    builder: (context) {
                      final hasBackground =
                          user.value?.profile.background != null;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: hasBackground ? 0 : 16,
                        children: [
                          if (!hasBackground)
                            GestureDetector(
                              child: ProfilePictureWidget(
                                file: user.value?.profile.picture,
                                radius: 24,
                              ),
                              onTap: () {
                                context.router.push(
                                  AccountProfileRoute(name: user.value!.name),
                                );
                              },
                            ).padding(bottom: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: AccountName(
                                        account: user.value!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '@${user.value!.name}',
                                      ).fontSize(11).padding(bottom: 2.5),
                                    ),
                                  ],
                                ),
                                Text(
                                  (user.value!.profile.bio.isNotEmpty)
                                      ? user.value!.profile.bio
                                      : 'descriptionNone'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(12),
                              ],
                            ),
                          ),
                        ],
                      ).padding(
                        left: 16,
                        right: 16,
                        top: 16 + (hasBackground ? 16 : 0),
                      );
                    },
                  ),
                ],
              ),
            ).padding(horizontal: 8),
            if (user.value?.activatedAt == null)
              AccountUnactivatedCard().padding(horizontal: 12, bottom: 4),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountStatusCreationWidget(uname: user.value!.name),
                  ActivityPresenceWidget(
                    uname: user.value!.name,
                    isCompact: true,
                    compactPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                      top: 4,
                    ),
                  ),
                ],
              ),
            ).padding(horizontal: 12, bottom: 4),
            LevelingProgressCard(
              isCompact: true,
              level: user.value!.profile.level,
              experience: user.value!.profile.experience,
              progress: user.value!.profile.levelingProgress,
              onTap: () {
                context.router.push(const LevelingRoute());
              },
            ).padding(horizontal: 12),
            Builder(
              builder: (context) {
                final menuItems = [
                  {
                    'icon': Symbols.notifications,
                    'title': 'notifications',
                    'badgeCount': notificationUnreadCount.value ?? 0,
                    'onTap': () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (context) => const NotificationSheet(),
                      );
                    },
                  },
                  {
                    'icon': Symbols.wallet,
                    'title': 'wallet',
                    'onTap': () {
                      context.router.push(const WalletRoute());
                    },
                  },
                  {
                    'icon': Symbols.military_tech,
                    'title': 'badges',
                    'onTap': () {
                      context.router.push(const BadgesRoute());
                    },
                  },
                  {
                    'icon': Symbols.workspace_premium,
                    'title': 'progress',
                    'onTap': () {
                      context.router.push(const ProgressRoute());
                    },
                  },
                  {
                    'icon': Symbols.handshake,
                    'title': 'meet',
                    'onTap': () {
                      context.router.push(const MeetRoute());
                    },
                  },
                  {
                    'icon': Symbols.history,
                    'title': 'actionLogs',
                    'onTap': () {
                      context.router.push(const ActionLogsRoute());
                    },
                  },
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    {
                      'icon': Symbols.nfc,
                      'title': 'physicalPassport',
                      'onTap': () {
                        context.router.push(const PhysicalPassportRoute());
                      },
                    },
                  {
                    'icon': Symbols.people,
                    'title': 'relationships',
                    'onTap': () {
                      context.router.push(const RelationshipRoute());
                    },
                  },
                  {
                    'icon': Symbols.sticker_rounded,
                    'title': 'stickers',
                    'onTap': () {
                      context.router.push(const StickerMarketplaceRoute());
                    },
                  },
                  {
                    'icon': Symbols.rss_feed,
                    'title': 'webFeeds',
                    'onTap': () {
                      context.router.push(const FeedMarketplaceRoute());
                    },
                  },
                  {
                    'icon': Symbols.confirmation_number,
                    'title': 'tickets',
                    'onTap': () {
                      context.router.push(const TicketListRoute());
                    },
                  },
                ];
                return Column(
                  children: menuItems.map((item) {
                    final icon = item['icon'] as IconData;
                    final title = item['title'] as String;
                    final badgeCount = item['badgeCount'] as int?;
                    final onTap = item['onTap'] as VoidCallback?;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      trailing: const Icon(Symbols.chevron_right),
                      dense: true,
                      leading: Badge(
                        isLabelVisible: badgeCount != null && badgeCount > 0,
                        label: Text(badgeCount.toString()),
                        child: Icon(icon, size: 24),
                      ),
                      title: Text(title).tr(),
                      onTap: onTap,
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              leading: const Icon(Symbols.settings),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              dense: true,
              title: Text('appSettings').tr(),
              onTap: () {
                context.router.push(const SettingsRoute());
              },
            ),
            ListTile(
              leading: const Icon(Symbols.person_edit),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              dense: true,
              title: Text('updateYourProfile').tr(),
              onTap: () {
                context.router.push(const AccountUpdateProfileRoute());
              },
            ),
            ListTile(
              leading: const Icon(Symbols.manage_accounts),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              dense: true,
              title: Text('accountSettings').tr(),
              onTap: () {
                context.router.push(const AccountSettingsRoute());
              },
            ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              dense: true,
              title: Text('about').tr(),
              onTap: () {
                context.router.push(const AboutRoute());
              },
            ),
            ListTile(
              leading: const Icon(Symbols.bug_report),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('debugOptions').tr(),
              dense: true,
              onTap: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => DebugSheet(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Symbols.logout),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('logout').tr(),
              dense: true,
              onTap: () async {
                final ws = ref.watch(websocketStateProvider.notifier);
                final apiClient = ref.watch(apiClientProvider);
                showLoadingModal(context);
                await apiClient.delete('/padlock/sessions/current');
                await resetDatabase(ref);
                if (!context.mounted) return;
                hideLoadingModal(context);
                final userNotifier = ref.read(userInfoProvider.notifier);
                userNotifier.logOut();
                ws.close();
              },
            ),
          ],
        ).padding(top: 8, bottom: MediaQuery.of(context).padding.bottom),
      ),
    );
  }
}

class _UnauthorizedAccountScreen extends StatelessWidget {
  const _UnauthorizedAccountScreen();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('account').tr()),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    context.router.push(const CreateAccountRoute());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Symbols.person_add, size: 48),
                        const SizedBox(height: 8),
                        Text('createAccount').tr().bold(),
                        Text('createAccountDescription').tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    context.router.push(const LoginRoute());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Symbols.login, size: 48),
                        const SizedBox(height: 8),
                        Text('login').tr().bold(),
                        Text('loginDescription').tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    context.router.push(const AboutRoute());
                  },
                  iconSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  icon: const Icon(Icons.info, fill: 1),
                  tooltip: 'about'.tr(),
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report, fill: 1),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => DebugSheet(),
                    );
                  },
                  iconSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  tooltip: 'debugOptions'.tr(),
                ),
                IconButton(
                  onPressed: () {
                    context.router.push(const SettingsRoute());
                  },
                  icon: const Icon(Icons.settings, fill: 1),
                  iconSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  tooltip: 'appSettings'.tr(),
                ),
              ],
            ),
          ],
        ),
      ).center(),
    );
  }
}
