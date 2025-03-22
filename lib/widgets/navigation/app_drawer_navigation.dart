import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/sn_realm.dart';
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
    final cfg = context.watch<ConfigProvider>();
    final rel = context.read<SnRealmProvider>();

    final backgroundColor = cfg.drawerIsExpanded ? Colors.transparent : null;

    return ListenableBuilder(
      listenable: nav,
      builder: (context, _) {
        return Drawer(
          elevation: widget.elevation,
          backgroundColor: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!kIsWeb &&
                  (Platform.isWindows ||
                      Platform.isLinux ||
                      Platform.isMacOS) &&
                  !cfg.drawerIsExpanded)
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
                    ...rel.availableRealms.map((ele) {
                      return ListTile(
                        minTileHeight: 48,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        leading: AccountImage(
                          content: ele.avatar,
                          radius: 16,
                        ),
                        title: Text(ele.name),
                        onTap: () {
                          GoRouter.of(context).goNamed(
                            'realmDetail',
                            pathParameters: {
                              'alias': ele.alias,
                            },
                          );
                          Scaffold.of(context).closeDrawer();
                        },
                      );
                    }),
                  ],
                ),
              ),
              Row(
                spacing: 8,
                children: nav.destinations.where((ele) => ele.isPinned).map(
                  (ele) {
                    return Expanded(
                      child: IconButton.filledTonal(
                        icon: ele.icon,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        onPressed: () {
                          GoRouter.of(context).goNamed(ele.screen);
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
                    );
                  },
                ).toList(),
              ).padding(horizontal: 16),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  leading: AccountImage(content: ua.user?.avatar),
                  title: Text(ua.user?.nick ?? 'unknown'.tr()).fontSize(15),
                  subtitle:
                      Text('@${ua.user?.name ?? 'unknown'.tr()}').fontSize(13),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.notifications, fill: 1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          GoRouter.of(context).pushNamed('notification');
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Symbols.settings, fill: 1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          GoRouter.of(context).pushNamed('settings');
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
              Gap(MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}
