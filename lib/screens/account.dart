import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/message.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class AccountShellScreen extends HookConsumerWidget {
  const AccountShellScreen({super.key});

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
            Flexible(flex: 3, child: AutoRouter()),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: AutoRouter());
  }
}

@RoutePage()
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

    if (!user.hasValue || user.value == null) {
      return _UnauthorizedAccountScreen();
    }

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
      noBackground: isWide,
      appBar: AppBar(title: const Text('account').tr()),
      body: SingleChildScrollView(
        child: Column(
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
                          context.router.push(
                            AccountProfileRoute(name: user.value!.name),
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
                                AccountName(
                                  account: user.value!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('@${user.value!.name}'),
                              ],
                            ),
                            Text(
                              (user.value!.profile.bio.isNotEmpty)
                                  ? user.value!.profile.bio
                                  : 'No description yet.',
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
              level: user.value!.profile.level,
              experience: user.value!.profile.experience,
              progress: user.value!.profile.levelingProgress,
            ).padding(horizontal: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Symbols.draw, size: 28).padding(bottom: 8),
                          Text('creatorHub').tr().fontSize(16).bold(),
                          Text('creatorHubDescription').tr(),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                      onTap: () {
                        context.router.push(CreatorHubShellRoute());
                      },
                    ),
                  ).height(140),
                ),
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Symbols.code, size: 28).padding(bottom: 8),
                          Text('developerPortal').tr().fontSize(16).bold(),
                          Text('developerPortalDescription').tr(),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                      onTap: () {},
                    ),
                  ).height(140),
                ),
              ],
            ).padding(horizontal: 8),
            const Gap(8),
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
                context.router.push(NotificationRoute());
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.wallet),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('wallet').tr(),
              onTap: () {
                context.router.push(WalletRoute());
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.people),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('relationships').tr(),
              onTap: () {
                context.router.push(RelationshipRoute());
              },
            ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.settings),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('appSettings').tr(),
              onTap: () {
                context.router.push(SettingsRoute());
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.person_edit),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('updateYourProfile').tr(),
              onTap: () {
                context.router.push(UpdateProfileRoute());
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.manage_accounts),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('accountSettings').tr(),
              onTap: () {
                context.router.push(AccountSettingsRoute());
              },
            ),
            if (kDebugMode) const Divider(height: 1).padding(vertical: 8),
            if (kDebugMode)
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.copy_all),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text('Copy access token'),
                onTap: () async {
                  final tk = ref.watch(tokenProvider);
                  Clipboard.setData(ClipboardData(text: tk!.token));
                },
              ),
            if (kDebugMode)
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.delete),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text('Reset database'),
                onTap: () async {
                  resetDatabase(ref);
                },
              ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.logout),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('logout').tr(),
              onTap: () {
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
                        context.router.push(CreateAccountRoute());
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
                        context.router.push(LoginRoute());
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
                TextButton(
                  onPressed: () {
                    context.router.push(SettingsRoute());
                  },
                  child: Text('appSettings').tr(),
                ).center(),
              ],
            ),
          ).center(),
    );
  }
}
