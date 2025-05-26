import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';

final currentRouteProvider = StateProvider<String?>((ref) => null);

class TabNavigationObserver extends AutoRouterObserver {
  Function(String?) onChange;
  TabNavigationObserver({required this.onChange});

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is DialogRoute) return;
    Future(() {
      onChange(route.settings.name);
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is DialogRoute) return;
    Future(() {
      onChange(previousRoute?.settings.name);
    });
  }
}

@RoutePage()
class TabsNavigationWidget extends HookConsumerWidget {
  final Widget child;
  final AppRouter router;
  const TabsNavigationWidget({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useHorizontalLayout = isWideScreen(context);
    final useExpandableLayout = isWidestScreen(context);
    final currentRoute = ref.watch(currentRouteProvider);

    final notificationUnreadCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    int activeIndex = 0;

    final destinations = [
      NavigationDestination(
        label: 'explore'.tr(),
        icon: const Icon(Symbols.explore),
      ),
      NavigationDestination(label: 'chat'.tr(), icon: const Icon(Symbols.chat)),
      NavigationDestination(
        label: 'realms'.tr(),
        icon: const Icon(Symbols.workspaces),
      ),
      NavigationDestination(
        label: 'account'.tr(),
        icon: Badge.count(
          count: notificationUnreadCount.value ?? 0,
          isLabelVisible: (notificationUnreadCount.value ?? 0) > 0,
          child: const Icon(Symbols.account_circle),
        ),
      ),
    ];

    final routes = <PageRouteInfo>[
      ExploreRoute(),
      ChatListRoute(),
      RealmListRoute(),
      AccountRoute(),
    ];
    final routeNames = [
      ExploreRoute.name,
      ChatListRoute.name,
      RealmListRoute.name,
      AccountRoute.name,
      ChatShellRoute.name,
      AccountShellRoute.name,
    ];

    activeIndex = routes.indexWhere((route) => route.routeName == currentRoute);
    if (activeIndex == -1) {
      activeIndex = 0;
    }

    final isTabRoute = routeNames.any((route) {
      return route == currentRoute;
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body:
          useHorizontalLayout
              ? Row(
                children: [
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        Gap(MediaQuery.of(context).padding.top + 8),
                        Expanded(
                          child: NavigationRail(
                            minExtendedWidth: 200,
                            extended: useExpandableLayout,
                            selectedIndex: activeIndex,
                            onDestinationSelected: (index) {
                              router.replace(routes[index]);
                            },
                            // labelType: NavigationRailLabelType.all,
                            destinations:
                                destinations
                                    .map(
                                      (d) => NavigationRailDestination(
                                        icon: d.icon,
                                        label: Text(d.label),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        Gap(MediaQuery.of(context).padding.bottom + 8),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: Theme.of(context).dividerColor,
                    width: 1 / MediaQuery.of(context).devicePixelRatio,
                  ),
                  Expanded(child: child),
                ],
              )
              : child,
      bottomNavigationBar:
          !useHorizontalLayout && isTabRoute
              ? NavigationBar(
                height: 56,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                selectedIndex: activeIndex,
                onDestinationSelected: (index) {
                  router.replace(routes[index]);
                },
                destinations: destinations,
              )
              : null,
    );
  }
}
