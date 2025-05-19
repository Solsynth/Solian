import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/services/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';

final currentRouteProvider = StateProvider<String?>((ref) => null);

class TabNavigationObserver extends AutoRouterObserver {
  Function(String?) onChange;
  TabNavigationObserver({required this.onChange});

  @override
  void didPush(Route route, Route? previousRoute) {
    Future(() {
      print('didPush: ${route.settings.name}');
      onChange(route.settings.name);
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    Future(() {
      print('didPop: ${previousRoute?.settings.name}');
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
    print('currentRoute: $currentRoute');

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
        icon: const Icon(Symbols.account_circle),
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
                  Column(
                    children: [
                      Gap(MediaQuery.of(context).padding.top + 8),
                      if (useExpandableLayout)
                        Expanded(
                          child: NavigationDrawer(
                            backgroundColor: Colors.transparent,
                            children: [
                              for (final destination in destinations)
                                NavigationDrawerDestination(
                                  label: Text(destination.label),
                                  icon: destination.icon,
                                ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: activeIndex,
                            onDestinationSelected: (index) {
                              router.replace(routes[index]);
                            },
                            labelType: NavigationRailLabelType.all,
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
