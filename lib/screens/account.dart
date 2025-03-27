import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/account_status.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/universal_image.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const List<AppNavListItem> kNavList = [
    AppNavListItem(
      title: "accountPublishers",
      subtitle: "accountPublishersSubtitle",
      screen: "accountPublishers",
      icon: Symbols.face,
    ),
    AppNavListItem(
      title: "accountProgram",
      subtitle: "accountProgramDescription",
      screen: "accountProgram",
      icon: Symbols.communities,
    ),
    AppNavListItem(
      title: "friends",
      subtitle: "friendsDescription",
      screen: "friend",
      icon: Symbols.person,
    ),
    AppNavListItem(
      title: "album",
      subtitle: "albumDescription",
      screen: "album",
      icon: Symbols.photo_library,
    ),
    AppNavListItem(
      title: "stickers",
      subtitle: "stickersDescription",
      screen: "stickers",
      icon: Symbols.emoji_emotions,
    ),
    AppNavListItem(
      title: "accountWallet",
      subtitle: "accountWalletSubtitle",
      screen: "accountWallet",
      icon: Symbols.wallet,
    ),
    AppNavListItem(
      title: "accountBadges",
      subtitle: "accountBadgesDescription",
      screen: "accountBadges",
      icon: Symbols.award_star,
    ),
    AppNavListItem(
      title: "accountKeyPairs",
      subtitle: "accountKeyPairsDescription",
      screen: "accountKeyPairs",
      icon: Symbols.key,
    ),
    AppNavListItem(
      title: "accountPunishments",
      subtitle: "accountPunishmentsDescription",
      screen: "accountPunishments",
      icon: Symbols.credit_score,
    ),
    AppNavListItem(
      title: "accountActionEvent",
      subtitle: "accountActionEventDescription",
      screen: "accountActionEvents",
      icon: Symbols.history,
    ),
    AppNavListItem(
      title: "accountAuthTickets",
      subtitle: "accountAuthTicketsDescription",
      screen: "accountAuthTickets",
      icon: Symbols.confirmation_number,
    ),
    AppNavListItem(
      title: "accountSettings",
      subtitle: "accountSettingsSubtitle",
      screen: "accountSettings",
      icon: Symbols.manage_accounts,
    ),
    AppNavListItem(
      title: "abuseReport",
      subtitle: "abuseReportActionDescription",
      screen: "abuseReport",
      icon: Symbols.flag,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    final sn = context.read<SnNetworkProvider>();

    return AppScaffold(
      appBar: AppBar(
        leading: AutoAppBarLeading(),
        title: Text("screenAccount").tr(),
        flexibleSpace: ua.user != null && ua.user!.banner.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  AutoResizeUniversalImage(sn.getAttachmentUrl(ua.user!.banner),
                      fit: BoxFit.cover),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 56 + MediaQuery.of(context).padding.top,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Container(
                          color: Colors.black.withOpacity(
                            clampDouble(10 * 0.1, 0, 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: ua.isAuthorized
            ? _AuthorizedAccountScreen()
            : _UnauthorizedAccountScreen(),
      ),
    );
  }
}

class _AuthorizedAccountScreen extends StatelessWidget {
  const _AuthorizedAccountScreen();

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();

    return Column(
      children: [
        Card(
          child: Builder(builder: (context) {
            if (ua.user == null) {
              return SizedBox(
                width: double.infinity,
                height: 120,
                child: CircularProgressIndicator().center(),
              );
            }

            return SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: AccountImage(
                          content: ua.user!.avatar,
                          radius: 28,
                        ),
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed('accountProfilePage', pathParameters: {
                            'name': ua.user!.name,
                          });
                        },
                      ),
                      _AccountStatusWidget(account: ua.user!),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(ua.user!.nick)
                          .textStyle(Theme.of(context).textTheme.titleLarge!),
                      const Gap(4),
                      Text('@${ua.user!.name}')
                          .textStyle(Theme.of(context).textTheme.bodySmall!),
                    ],
                  ),
                  Text(
                    (ua.user!.profile?.description.isNotEmpty ?? false)
                        ? ua.user!.profile!.description
                        : 'userNoDescription'.tr(),
                    style: (ua.user!.profile?.description.isEmpty ?? true)
                        ? TextStyle(fontStyle: FontStyle.italic)
                        : null,
                  ).textStyle(Theme.of(context).textTheme.bodyMedium!),
                ],
              ),
            );
          }).padding(all: 20),
        ).padding(horizontal: 8, top: 16, bottom: 4),
        for (final item in AccountScreen.kNavList)
          Tooltip(
            message: item.subtitle.tr(),
            child: ListTile(
              minTileHeight: 48,
              title: Text(item.title).tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(item.icon),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed(item.screen);
              },
            ),
          ),
        Tooltip(
          message: 'accountLogoutSubtitle'.tr(),
          child: ListTile(
            title: Text('accountLogout').tr(),
            minTileHeight: 48,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.logout),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () async {
              final confirm = await context.showConfirmDialog(
                'accountLogoutConfirmTitle'.tr(),
                'accountLogoutConfirm'.tr(),
              );

              if (!confirm) return;
              if (!context.mounted) return;
              ua.logoutUser();
              final ws = context.read<WebSocketProvider>();
              ws.disconnect();
              context.read<DatabaseProvider>().removeDatabase();
            },
          ),
        ),
      ],
    );
  }
}

class _UnauthorizedAccountScreen extends StatelessWidget {
  const _UnauthorizedAccountScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Symbols.waving_hand, size: 28),
                ),
                const Gap(8),
                Text('accountIntroTitle')
                    .tr()
                    .textStyle(Theme.of(context).textTheme.titleLarge!),
                Text('accountIntroSubtitle').tr(),
              ],
            ).padding(all: 20),
          ),
        ).padding(horizontal: 8, top: 16, bottom: 4),
        ListTile(
          title: Text('screenAuthLogin').tr(),
          subtitle: Text('screenAuthLoginSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.login),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('authLogin').then((value) {
              if (value == true && context.mounted) {
                final ua = context.read<UserProvider>();
                ua.refreshUser();
              }
            });
          },
        ),
        ListTile(
          title: Text('screenAuthRegister').tr(),
          subtitle: Text('screenAuthRegisterSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.person_add),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('authRegister');
          },
        ),
      ],
    );
  }
}

class _AccountStatusWidget extends StatefulWidget {
  final SnAccount account;
  const _AccountStatusWidget({required this.account});

  @override
  State<_AccountStatusWidget> createState() => _AccountStatusWidgetState();
}

class _AccountStatusWidgetState extends State<_AccountStatusWidget> {
  SnAccountStatusInfo? _status;

  Future<void> _fetchStatus() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/id/users/${widget.account.name}/status');
      setState(() {
        _status = SnAccountStatusInfo.fromJson(resp.data);
      });
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          Text(
            _status != null
                ? (_status!.status?.label.isNotEmpty ?? false)
                    ? _status!.status!.label
                    : _status!.isOnline
                        ? 'accountStatusOnline'.tr()
                        : 'accountStatusOffline'.tr()
                : 'loading'.tr(),
          ),
          const Gap(4),
          Icon(
            (_status?.isDisturbable ?? true)
                ? Symbols.circle
                : Symbols.do_not_disturb_on,
            fill: (_status?.isOnline ?? false) ? 1 : 0,
            size: 16,
            color: (_status?.isOnline ?? false)
                ? (_status?.isDisturbable ?? true)
                    ? Colors.green
                    : Colors.red
                : Colors.grey,
          ).padding(all: 4),
        ],
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => AccountStatusActionPopup(
            currentStatus: _status,
          ),
        ).then((value) {
          if (value == true && mounted) {
            _fetchStatus();
          }
        });
      },
    );
  }
}
