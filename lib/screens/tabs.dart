import 'dart:developer';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/navigation/conditional_bottom_nav.dart';
import 'package:material_symbols_icons/symbols.dart';

final currentRouteProvider = StateProvider<String?>((ref) => null);

class TabNavigationObserver extends AutoRouterObserver {
  Function(String?) onChange;
  TabNavigationObserver({required this.onChange});

  @override
  void didPush(Route route, Route? previousRoute) {
    log('pushed ${previousRoute?.settings.name} -> ${route.settings.name}');
    if (route is DialogRoute) return;
    final name = route.settings.name;
    if (name == null) return;
    if (name.contains('Shell')) return;
    Future(() {
      onChange(name);
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log('popped ${route.settings.name} -> ${previousRoute?.settings.name}');
    if (previousRoute is DialogRoute) return;
    final name = previousRoute?.settings.name;
    if (name == null) return;
    if (name.contains('Shell')) return;
    Future(() {
      onChange(name);
    });
  }
}

@RoutePage()
class TabsScreen extends HookConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useHorizontalLayout = isWideScreen(context);

    final notificationUnreadCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

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
      ExploreShellRoute(),
      ChatShellRoute(),
      RealmListRoute(),
      AccountShellRoute(),
    ];

    return AutoTabsRouter.tabBar(
      routes: routes,
      scrollDirection: useHorizontalLayout ? Axis.vertical : Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);

        if (isWideScreen(context)) {
          return Row(
            children: [
              NavigationRail(
                destinations:
                    destinations
                        .map(
                          (e) => NavigationRailDestination(
                            icon: e.icon,
                            label: Text(e.label),
                          ),
                        )
                        .toList(),
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ConditionalBottomNav(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.8),
                      ),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: NavigationBar(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          overlayColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          surfaceTintColor: Colors.transparent,
                          height: 56,
                          labelBehavior:
                              NavigationDestinationLabelBehavior.alwaysHide,
                          selectedIndex: tabsRouter.activeIndex,
                          onDestinationSelected: tabsRouter.setActiveIndex,
                          destinations: destinations,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TabbedFabLocation extends FloatingActionButtonLocation {
  final BuildContext context;

  const TabbedFabLocation(this.context);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaPadding = mediaQuery.padding;

    // Calculate position with proper safe area considerations
    final double fabX =
        scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16 -
        safeAreaPadding.right;

    // Use safe area bottom padding + navigation bar height (typically 80px)
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        scaffoldGeometry.bottomSheetSize.height -
        safeAreaPadding.bottom -
        (isWideScreen(context) ? 32 : 80) +
        16;

    return Offset(fabX, fabY);
  }
}
