import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/debug_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class AccountShellScreen extends HookConsumerWidget {
  final Widget child;
  const AccountShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            Flexible(flex: 2, child: AccountScreen(isAside: true)),
            VerticalDivider(width: 1),
            Flexible(flex: 3, child: child),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: child);
  }
}

class AccountScreen extends HookConsumerWidget {
  final bool isAside;
  const AccountScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

    final user = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

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
                  if (user.value?.profile.background?.id != null)
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      GestureDetector(
                        child: ProfilePictureWidget(
                          file: user.value?.profile.picture,
                          radius: 24,
                        ),
                        onTap: () {
                          context.pushNamed(
                            'accountProfile',
                            pathParameters: {'name': user.value!.name},
                          );
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
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
                                Flexible(child: Text('@${user.value!.name}')),
                              ],
                            ),
                            Text(
                              (user.value!.profile.bio.isNotEmpty)
                                  ? user.value!.profile.bio
                                  : 'descriptionNone'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).padding(horizontal: 16, top: 16),
                  AccountStatusCreationWidget(uname: user.value!.name),
                ],
              ),
            ).padding(horizontal: 8),
            LevelingProgressCard(
              isCompact: true,
              level: user.value!.profile.level,
              experience: user.value!.profile.experience,
              progress: user.value!.profile.levelingProgress,
              onTap: () {
                context.pushNamed('leveling');
              },
            ).padding(horizontal: 12),
            if (!isWideScreen(context)) const SizedBox.shrink(),
            if (!isWideScreen(context))
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Symbols.draw, size: 28).padding(bottom: 8),
                            Text(
                              'creatorHub',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).tr().fontSize(16).bold(),
                            Text(
                              'creatorHubDescription',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ).tr(),
                          ],
                        ).padding(horizontal: 16, vertical: 12),
                        onTap: () {
                          context.goNamed('creatorHub');
                        },
                      ),
                    ).height(140),
                  ),
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Symbols.code, size: 28).padding(bottom: 8),
                            Text(
                              'developerPortal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).tr().fontSize(16).bold(),
                            Text(
                              'developerPortalDescription',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ).tr(),
                          ],
                        ).padding(horizontal: 16, vertical: 12),
                        onTap: () {
                          context.pushNamed('developerHub');
                        },
                      ),
                    ).height(140),
                  ),
                ],
              ).padding(horizontal: 12),
            const SizedBox.shrink(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Symbols.settings, size: 20),
                          Text('appSettings').tr().fontSize(13).bold(),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                      onTap: () {
                        context.pushNamed('settings');
                      },
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Symbols.person_edit, size: 20),
                          Text('updateYourProfile').tr().fontSize(13).bold(),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                      onTap: () {
                        context.pushNamed('profileUpdate');
                      },
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Symbols.manage_accounts, size: 20),
                          Text('accountSettings').tr().fontSize(13).bold(),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                      onTap: () {
                        context.pushNamed('accountSettings');
                      },
                    ),
                  ),
                ],
              ).padding(horizontal: 12),
            ).height(48),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.notifications),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Row(
                children: [
                  Expanded(child: Text('notifications').tr()),
                  Badge.count(
                    count: notificationUnreadCount.value ?? 0,
                    isLabelVisible: (notificationUnreadCount.value ?? 0) > 0,
                  ),
                ],
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => const NotificationSheet(),
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.wallet),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('wallet').tr(),
              onTap: () {
                context.pushNamed('wallet');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.files),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('files').tr(),
              onTap: () {
                context.pushNamed('files');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.people),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('relationships').tr(),
              onTap: () {
                context.pushNamed('relationships');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.emoji_emotions),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('stickers').tr(),
              onTap: () {
                context.pushNamed('stickerMarketplace');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.rss_feed),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('webFeeds').tr(),
              onTap: () {
                context.pushNamed('webFeedMarketplace');
              },
            ),
            ListTile(
              minTileHeight: 48,
              title: Text('abuseReport').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.gavel),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () => context.pushNamed('reportList'),
            ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('about').tr(),
              onTap: () {
                context.pushNamed('about');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.bug_report),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('debugOptions').tr(),
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
              minTileHeight: 48,
              leading: const Icon(Symbols.logout),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('logout').tr(),
              onTap: () async {
                final apiClient = ref.watch(apiClientProvider);
                showLoadingModal(context);
                await apiClient.delete('/id/accounts/me/sessions/current');
                if (!context.mounted) return;
                hideLoadingModal(context);
                final userNotifier = ref.read(userInfoProvider.notifier);
                userNotifier.logOut();
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
      body:
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        context.pushNamed('createAccount');
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
                      onTap: () {
                        context.pushNamed('login');
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
                    TextButton(
                      onPressed: () {
                        context.pushNamed('about');
                      },
                      child: Text('about').tr(),
                    ),
                    TextButton(
                      child: Text('debugOptions').tr(),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => DebugSheet(),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushNamed('settings');
                      },
                      child: Text('appSettings').tr(),
                    ),
                  ],
                ),
              ],
            ),
          ).center(),
    );
  }
}
