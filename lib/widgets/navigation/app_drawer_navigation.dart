import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/version_label.dart';

class AppNavigationDrawer extends StatefulWidget {
  final double? elevation;

  const AppNavigationDrawer({super.key, this.elevation});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NavigationProvider>()
          .autoDetectIndex(GoRouter.maybeOf(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();
    final nav = context.watch<NavigationProvider>();

    return ListenableBuilder(
      listenable: nav,
      builder: (context, _) {
        return Drawer(
          elevation: widget.elevation,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!kIsWeb &&
                  (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: WindowTitleBarBox(),
                ),
              Gap(MediaQuery.of(context).padding.top),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solar Network').bold(),
                  AppVersionLabel(),
                ],
              ).padding(
                horizontal: 32,
                vertical: 12,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...nav.destinations.mapIndexed((idx, ele) {
                      return ListTile(
                        leading: ele.icon,
                        title: Text(ele.label).tr(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        selected: nav.currentIndex == idx,
                        onTap: () {
                          GoRouter.of(context).pushNamed(ele.screen);
                          nav.setIndex(idx);
                          Scaffold.of(context).closeDrawer();
                        },
                      );
                    })
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  leading: AccountImage(
                    content: ua.user?.avatar,
                    backgroundColor: Colors.transparent,
                    fallbackWidget:
                        ua.isAuthorized ? null : const Icon(Symbols.login),
                  ),
                  title: ua.isAuthorized
                      ? Text(ua.user?.nick ?? 'unknown'.tr()).fontSize(15)
                      : Text('screenAuthLogin').tr(),
                  subtitle: ua.isAuthorized
                      ? Text('@${ua.user?.name ?? 'unknown'.tr()}').fontSize(13)
                      : Text('navBottomUnauthorizedCaption').fontSize(13).tr(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ua.isAuthorized)
                        IconButton(
                          icon: const Icon(Symbols.notifications, fill: 1),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            GoRouter.of(context).pushNamed('notification');
                            Scaffold.of(context).closeDrawer();
                          },
                        ),
                    ],
                  ),
                  onTap: () {
                    GoRouter.of(context).pushNamed('account');
                    Scaffold.of(context).closeDrawer();
                  },
                ),
              ),
              Gap(MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}
