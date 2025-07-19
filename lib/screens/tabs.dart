import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/navigation/conditional_bottom_nav.dart';
import 'package:material_symbols_icons/symbols.dart';

final currentRouteProvider = StateProvider<String?>((ref) => null);

class TabsScreen extends HookConsumerWidget {
  final Widget? child;
  const TabsScreen({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final useHorizontalLayout = isWideScreen(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    // Update the current route provider whenever the location changes
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentRouteProvider.notifier).state = currentLocation;
      });
      return null;
    }, [currentLocation]);

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

    final routes = ['/', '/chat', '/realms', '/account'];

    int getCurrentIndex() {
      if (currentLocation.startsWith('/chat')) return 1;
      if (currentLocation.startsWith('/realms')) return 2;
      if (currentLocation.startsWith('/account')) return 3;
      return 0; // Default to explore
    }

    void onDestinationSelected(int index) {
      context.go(routes[index]);
    }

    final currentIndex = getCurrentIndex();

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
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: child ?? const SizedBox.shrink()),
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
                      selectedIndex: currentIndex,
                      onDestinationSelected: onDestinationSelected,
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
