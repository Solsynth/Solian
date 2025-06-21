import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      ExploreRoute(),
      ChatListRoute(),
      RealmListRoute(),
      AccountRoute(),
    ];

    return AutoTabsRouter.tabBar(
      routes: routes,
      scrollDirection: useHorizontalLayout ? Axis.vertical : Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);

        // Check if current route is a tab route
        final currentRoute = context.router.topRoute;
        final isTabRoute = routes.any(
          (route) => route.routeName == currentRoute.name,
        );

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
                        overlayColor: WidgetStatePropertyAll(
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
        16.0 -
        safeAreaPadding.right;

    // Use safe area bottom padding + navigation bar height (typically 80px)
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        scaffoldGeometry.bottomSheetSize.height -
        safeAreaPadding.bottom -
        80.0 +
        16;

    return Offset(fabX, fabY);
  }
}
