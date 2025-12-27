import 'dart:math' as math;
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/navigation/conditional_bottom_nav.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/pods/chat/chat_summary.dart';

final currentRouteProvider = NotifierProvider<CurrentRouteNotifier, String?>(
  CurrentRouteNotifier.new,
);

class CurrentRouteNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void updateRoute(String? route) {
    state = route;
  }
}

const kWideScreenRouteStart = 5;
const kTabRoutes = [
  '/',
  '/explore',
  '/chat',
  '/realms',
  '/account',
  '/files',
  '/thought',
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
        ref.read(currentRouteProvider.notifier).updateRoute(currentLocation);
      });
      return null;
    }, [currentLocation]);

    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);

    final chatUnreadCount = ref.watch(chatUnreadCountProvider);

    final wideScreen = isWideScreen(context);

    final destinations = [
      NavigationDestination(
        label: 'dashboard'.tr(),
        icon: const Icon(Symbols.dashboard_rounded),
      ),
      NavigationDestination(
        label: 'explore'.tr(),
        icon: const Icon(Symbols.explore_rounded),
      ),
      NavigationDestination(
        label: 'chat'.tr(),
        icon: Badge.count(
          count: chatUnreadCount.value ?? 0,
          isLabelVisible: (chatUnreadCount.value ?? 0) > 0,
          child: const Icon(Symbols.forum_rounded),
        ),
      ),
      NavigationDestination(
        label: 'realms'.tr(),
        icon: const Icon(Symbols.groups_3),
      ),
      NavigationDestination(
        label: 'account'.tr(),
        icon: Badge.count(
          count: notificationUnreadCount.value ?? 0,
          isLabelVisible: (notificationUnreadCount.value ?? 0) > 0,
          child: Consumer(
            child: const Icon(Symbols.account_circle_rounded),
            builder: (context, ref, fallbackChild) {
              final userInfo = ref.watch(userInfoProvider);
              if (userInfo.value?.profile.picture != null) {
                return ProfilePictureWidget(
                  file: userInfo.value!.profile.picture,
                  radius: 12,
                );
              }
              return fallbackChild!;
            },
          ),
        ),
      ),
      if (wideScreen)
        ...([
          NavigationDestination(
            label: 'files'.tr(),
            icon: const Icon(Symbols.folder_rounded),
          ),
          NavigationDestination(
            label: 'aiThought'.tr(),
            icon: const Icon(Symbols.bubble_chart),
          ),
          NavigationDestination(
            label: 'creatorHub'.tr(),
            icon: const Icon(Symbols.design_services_rounded),
          ),
          NavigationDestination(
            label: 'developerHub'.tr(),
            icon: const Icon(Symbols.data_object_rounded),
          ),
        ]),
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

    if (isWideScreen(context)) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.transparent,
              destinations: destinations.mapIndexed((idx, d) {
                if (d.icon is Icon) {
                  return NavigationRailDestination(
                    icon: Icon(
                      (d.icon as Icon).icon,
                      fill: currentIndex == idx ? 1 : null,
                    ),
                    label: Text(d.label),
                  );
                }
                return NavigationRailDestination(
                  icon: d.icon,
                  label: Text(d.label),
                );
              }).toList(),
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
      bottomNavigationBar: ConditionalBottomNav(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: NavigationBar(
                  height: 56,
                  destinations: destinations.mapIndexed((idx, d) {
                    if (d.icon is Icon) {
                      return NavigationDestination(
                        icon: Icon(
                          (d.icon as Icon).icon,
                          fill: currentIndex == idx ? 1 : null,
                        ),
                        label: d.label,
                      );
                    }
                    return d;
                  }).toList(),
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.8),
                  indicatorColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
