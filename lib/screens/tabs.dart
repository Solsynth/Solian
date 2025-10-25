import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/navigation/conditional_bottom_nav.dart';
import 'package:island/widgets/post/compose_dialog.dart';
import 'package:material_symbols_icons/symbols.dart';

final currentRouteProvider = StateProvider<String?>((ref) => null);

const kWideScreenRouteStart = 4;
const kTabRoutes = [
  '/',
  '/chat',
  '/realms',
  '/account',
  '/creators',
  '/developers',
];

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

    final wideScreen = isWideScreen(context);

    final destinations = [
      NavigationDestination(
        label: 'explore'.tr(),
        icon: const Icon(Symbols.explore),
      ),
      NavigationDestination(
        label: 'chat'.tr(),
        icon: const Icon(Symbols.chat_rounded),
      ),
      NavigationDestination(
        label: 'realms'.tr(),
        icon: const Icon(Symbols.group),
      ),
      NavigationDestination(
        label: 'account'.tr(),
        icon: Badge.count(
          count: notificationUnreadCount.value ?? 0,
          isLabelVisible: (notificationUnreadCount.value ?? 0) > 0,
          child: const Icon(Symbols.account_circle),
        ),
      ),
      if (wideScreen)
        NavigationDestination(
          label: 'creatorHub'.tr(),
          icon: const Icon(Symbols.ink_pen),
        ),
      if (wideScreen)
        NavigationDestination(
          label: 'developerHub'.tr(),
          icon: const Icon(Symbols.data_object),
        ),
    ];

    int getCurrentIndex() {
      if (currentLocation == '/') return 0;
      final idx = kTabRoutes.indexWhere(
        (p) => currentLocation.startsWith(p),
        1,
      );
      final value = math.max(idx, 0);
      return math.min(value, destinations.length - 1);
    }

    void onDestinationSelected(int index) {
      context.go(kTabRoutes[index]);
    }

    final currentIndex = getCurrentIndex();

    final routes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );
    final shouldShowFab = routes.contains(currentLocation) && !wideScreen;

    if (isWideScreen(context)) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.transparent,
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      floatingActionButton:
          shouldShowFab
              ? FloatingActionButton(
                child: const Icon(Symbols.menu),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(24),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            leading: const Icon(Symbols.post_add_rounded),
                            title: Text('postCompose'.tr()),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await PostComposeDialog.show(context);
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final notificationCount = ref.watch(
                                notificationUnreadCountNotifierProvider,
                              );
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                leading: const Icon(Symbols.notifications),
                                trailing: Badge(
                                  label: Text(notificationCount.toString()),
                                  isLabelVisible: notificationCount.value! > 0,
                                ),
                                title: Text('notifications'.tr()),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    useRootNavigator: true,
                                    builder:
                                        (context) => const NotificationSheet(),
                                  );
                                },
                              );
                            },
                          ),
                          Gap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      );
                    },
                  );
                },
              )
              : null,
      floatingActionButtonLocation:
          shouldShowFab ? TabbedFabLocation(context) : null,
      bottomNavigationBar: ConditionalBottomNav(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: BottomAppBar(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 24),
                shape: AutomaticNotchedShape(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: () {
                    final navItems =
                        destinations.asMap().entries.map<Widget>((entry) {
                          int index = entry.key;
                          NavigationDestination dest = entry.value;
                          return IconButton(
                            icon: dest.icon,
                            onPressed: () => onDestinationSelected(index),
                            color:
                                index == currentIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                          );
                        }).toList();
                    // Add mock item in the center to leave space for FAB
                    int centerIndex = navItems.length ~/ 2;
                    navItems.insert(centerIndex, const SizedBox(width: 72));
                    return navItems;
                  }(),
                ),
              ),
            ),
          ),
        ),
      ),
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

    // Center horizontally
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2;

    // Position closer to bottom with reduced padding
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        scaffoldGeometry.bottomSheetSize.height -
        safeAreaPadding.bottom -
        16;

    return Offset(fabX, fabY);
  }
}
