import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/database.dart';
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

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    final sn = context.read<SnNetworkProvider>();

    return AppScaffold(
      appBar: AppBar(
        leading: AutoAppBarLeading(),
        title: Text(
          "screenAccount",
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 5.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ).tr(),
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
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings, fill: 1),
            onPressed: () {
              GoRouter.of(context).pushNamed('settings');
            },
          ),
          const Gap(8),
        ],
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
                      AccountImage(content: ua.user!.avatar, radius: 28),
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
        ListTile(
          title: Text('accountPublishers').tr(),
          subtitle: Text('accountPublishersSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.face),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountPublishers');
          },
        ),
        ListTile(
          title: Text('friends').tr(),
          subtitle: Text('friendsDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.person),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('friend');
          },
        ),
        ListTile(
          title: Text('album').tr(),
          subtitle: Text('albumDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.photo_library),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('album');
          },
        ),
        ListTile(
          title: Text('stickers').tr(),
          subtitle: Text('stickersDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.emoji_emotions),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('stickers');
          },
        ),
        ListTile(
          title: Text('accountWallet').tr(),
          subtitle: Text('accountWalletSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.wallet),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountWallet');
          },
        ),
        ListTile(
          title: Text('accountBadges').tr(),
          subtitle: Text('accountBadgesDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.award_star),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountBadges');
          },
        ),
        ListTile(
          title: Text('accountKeyPairs').tr(),
          subtitle: Text('accountKeyPairsDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.key),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountKeyPairs');
          },
        ),
        ListTile(
          title: Text('accountActionEvent').tr(),
          subtitle: Text('accountActionEventDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.history),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountActionEvents');
          },
        ),
        ListTile(
          title: Text('accountAuthTickets').tr(),
          subtitle: Text('accountAuthTicketsDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.confirmation_number),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountAuthTickets');
          },
        ),
        ListTile(
          title: Text('accountSettings').tr(),
          subtitle: Text('accountSettingsSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.manage_accounts),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('accountSettings');
          },
        ),
        ListTile(
          title: Text('abuseReport').tr(),
          subtitle: Text('abuseReportActionDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.flag),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed('abuseReport');
          },
        ),
        ListTile(
          title: Text('accountLogout').tr(),
          subtitle: Text('accountLogoutSubtitle').tr(),
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
                context.showSnackbar('loginSuccess'.tr(args: [
                  '@${ua.user?.name} (${ua.user?.nick})',
                ]));
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
