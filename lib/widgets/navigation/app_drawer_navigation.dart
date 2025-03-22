import 'dart:io';

import 'package:animations/animations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/universal_image.dart';
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
              Expanded(
                child: _DrawerContentList(),
              ),
              if (cfg.hideBottomNav)
                Row(
                  spacing: 8,
                  children: nav.destinations.where((ele) => ele.isPinned).map(
                    (ele) {
                      return Expanded(
                        child: Tooltip(
                          message: ele.label.tr(),
                          child: IconButton.filledTonal(
                            icon: ele.icon,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            onPressed: () {
                              GoRouter.of(context).goNamed(ele.screen);
                              Scaffold.of(context).closeDrawer();
                            },
                          ),
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

class _DrawerContentList extends StatelessWidget {
  const _DrawerContentList();

  @override
  Widget build(BuildContext context) {
    final ct = context.read<ChatChannelProvider>();
    final sn = context.read<SnNetworkProvider>();
    final nav = context.watch<NavigationProvider>();
    final rel = context.watch<SnRealmProvider>();

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: nav.focusedRealm == null
          ? ListView(
              key: const Key('realm-list-view'),
              padding: EdgeInsets.zero,
              children: [
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
                ListTile(
                  minTileHeight: 48,
                  contentPadding: EdgeInsets.only(left: 28, right: 16),
                  leading: const Icon(Symbols.home).padding(right: 4),
                  title: Text('screenHome').tr(),
                  onTap: () {
                    GoRouter.of(context).goNamed('home');
                    Scaffold.of(context).closeDrawer();
                  },
                ),
                const Divider(height: 1).padding(vertical: 4),
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
                      nav.setFocusedRealm(ele);
                    },
                  );
                }),
                ListTile(
                  minTileHeight: 48,
                  contentPadding: EdgeInsets.only(left: 28, right: 16),
                  leading: const Icon(Symbols.globe).padding(right: 4),
                  title: Text('screenRealmDiscovery').tr(),
                  onTap: () {
                    GoRouter.of(context).pushNamed('realmDiscovery');
                    Scaffold.of(context).closeDrawer();
                  },
                ),
              ],
            )
          : ListView(
              key: ValueKey(nav.focusedRealm),
              padding: EdgeInsets.zero,
              children: [
                if (nav.focusedRealm!.banner != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: AutoResizeUniversalImage(
                      sn.getAttachmentUrl(
                        nav.focusedRealm!.banner!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ListTile(
                  minTileHeight: 48,
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  contentPadding: EdgeInsets.only(
                    left: 24,
                    right: 16,
                  ),
                  leading: AccountImage(
                    content: nav.focusedRealm!.avatar,
                    radius: 16,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Symbols.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      nav.setFocusedRealm(null);
                    },
                  ),
                  title: Text(nav.focusedRealm!.name),
                  onTap: () {
                    GoRouter.of(context).pushNamed(
                      'realmDetail',
                      pathParameters: {
                        'alias': nav.focusedRealm!.alias,
                      },
                    );
                    Scaffold.of(context).closeDrawer();
                  },
                ),
                ListTile(
                  minTileHeight: 48,
                  contentPadding: EdgeInsets.only(
                    left: 28,
                    right: 8,
                  ),
                  leading: const Icon(Symbols.globe),
                  title: Text('community').tr(),
                  onTap: () {
                    GoRouter.of(context).pushNamed(
                      'realmCommunity',
                      pathParameters: {
                        'alias': nav.focusedRealm!.alias,
                      },
                    );
                    Scaffold.of(context).closeDrawer();
                  },
                ),
                if (ct.availableChannels
                    .where((ele) => ele.realmId == nav.focusedRealm?.id)
                    .isNotEmpty)
                  const Divider(height: 1),
                ...(ct.availableChannels
                    .where((ele) => ele.realmId == nav.focusedRealm?.id)
                    .map((ele) {
                  return ListTile(
                    minTileHeight: 48,
                    contentPadding: EdgeInsets.only(
                      left: 28,
                      right: 8,
                    ),
                    leading: const Icon(Symbols.tag),
                    title: Text(ele.name),
                    onTap: () {
                      GoRouter.of(context).pushNamed(
                        'chatRoom',
                        pathParameters: {
                          'scope': ele.realm?.alias ?? 'global',
                          'alias': ele.alias,
                        },
                      );
                      Scaffold.of(context).closeDrawer();
                    },
                  );
                }))
              ],
            ),
    );
  }
}
