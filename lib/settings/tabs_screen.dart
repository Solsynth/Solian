import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/navigation/conditional_bottom_nav.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/chat/pods/chat_summary.dart';

@RoutePage()
class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        DashboardRoute(),
        ExploreRoute(),
        ChatRoute(),
        RealmListRoute(),
        AccountRoute(),
        FileListRoute(),
        ThoughtRoute(),
        CreatorHubRoute(),
        DeveloperHubRoute(),
      ],
      transitionBuilder: (context, child, animation) => child,
      builder: (context, child) {
        return _TabsScreenContent(child: child);
      },
    );
  }
}

class _TabsScreenContent extends HookConsumerWidget {
  final Widget child;

  const _TabsScreenContent({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsRouter = AutoTabsRouter.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final token = ref.watch(tokenProvider);
    final userInfo = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);
    final chatUnreadCount = ref.watch(chatUnreadCountProvider);
    final wideScreen = isWideScreen(context);

    final allDestinations = <_TabDestination>[
      _TabDestination(
        label: 'dashboard'.tr(),
        navigationIcon: Symbols.dashboard_rounded,
        iconBuilder: (selected) =>
            Icon(Symbols.dashboard_rounded, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'explore'.tr(),
        navigationIcon: Symbols.explore_rounded,
        iconBuilder: (selected) =>
            Icon(Symbols.explore_rounded, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'chat'.tr(),
        navigationIcon: Symbols.forum_rounded,
        iconBuilder: (_) => Badge.count(
          count: chatUnreadCount.value ?? 0,
          isLabelVisible: (chatUnreadCount.value ?? 0) > 0,
          child: const Icon(Symbols.forum_rounded),
        ),
      ),
      _TabDestination(
        label: 'realms'.tr(),
        navigationIcon: Symbols.groups_3,
        iconBuilder: (selected) =>
            Icon(Symbols.groups_3, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'account'.tr(),
        navigationIcon: Symbols.account_circle_rounded,
        iconBuilder: (_) => Badge.count(
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
      _TabDestination(
        label: 'files'.tr(),
        navigationIcon: Symbols.folder_rounded,
        iconBuilder: (selected) =>
            Icon(Symbols.folder_rounded, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'aiThought'.tr(),
        navigationIcon: Symbols.bubble_chart,
        iconBuilder: (selected) =>
            Icon(Symbols.bubble_chart, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'creatorHub'.tr(),
        navigationIcon: Symbols.design_services_rounded,
        iconBuilder: (selected) =>
            Icon(Symbols.design_services_rounded, fill: selected ? 1 : null),
      ),
      _TabDestination(
        label: 'developerHub'.tr(),
        navigationIcon: Symbols.data_object_rounded,
        iconBuilder: (selected) =>
            Icon(Symbols.data_object_rounded, fill: selected ? 1 : null),
      ),
    ];
    final railAndDrawerDestinations = allDestinations;
    final bottomNavRouteIndices = <int>[0, 1, 2, 4];
    final bottomNavDestinations = bottomNavRouteIndices
        .map((idx) => allDestinations[idx])
        .toList();

    final railCurrentIndex = min(
      tabsRouter.activeIndex,
      railAndDrawerDestinations.length - 1,
    );
    final selectedBottomNavIndex = bottomNavRouteIndices.indexOf(
      tabsRouter.activeIndex,
    );
    final bottomNavCurrentIndex = selectedBottomNavIndex >= 0
        ? selectedBottomNavIndex
        : 0;
    final shouldShowBottomNav = selectedBottomNavIndex >= 0;

    void onDestinationSelected(int index) {
      tabsRouter.setActiveIndex(index);
    }

    void onBottomNavDestinationSelected(int index) {
      if (index < 0 || index >= bottomNavRouteIndices.length) return;
      tabsRouter.setActiveIndex(bottomNavRouteIndices[index]);
    }

    if (wideScreen) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.transparent,
              destinations: railAndDrawerDestinations.mapIndexed((idx, d) {
                return NavigationRailDestination(
                  icon: d.iconBuilder(railCurrentIndex == idx),
                  label: Text(d.label),
                );
              }).toList(),
              selectedIndex: railCurrentIndex,
              onDestinationSelected: onDestinationSelected,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    final scaffold = Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: SafeArea(
          child: NavigationDrawer(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
              Navigator.of(context).pop();
              onDestinationSelected(index);
            },
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onDestinationSelected(4);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  height: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (token != null &&
                          userInfo.value?.profile.background != null)
                        CloudFileWidget(
                          item: userInfo.value!.profile.background!,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.48),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (token != null &&
                                userInfo.value?.profile.picture != null)
                              ProfilePictureWidget(
                                file: userInfo.value!.profile.picture,
                                radius: 18,
                              )
                            else
                              CircleAvatar(
                                radius: 18,
                                child: Icon(
                                  token != null
                                      ? Symbols.account_circle_rounded
                                      : Symbols.login_rounded,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: token == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Not logged in',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          'Tap to sign in',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userInfo.value?.nick ?? 'Account',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '@${userInfo.value?.name ?? ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white70),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                            const Icon(
                              Symbols.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...railAndDrawerDestinations.map((d) {
                return NavigationDrawerDestination(
                  label: Text(d.label),
                  icon: Icon(d.navigationIcon),
                  selectedIcon: Icon(d.navigationIcon, fill: 1),
                );
              }),
            ],
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: child,
      ),
      floatingActionButton: shouldShowBottomNav
          ? null
          : FloatingActionButton.small(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              child: const Icon(Symbols.menu_rounded),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Expanded(
                          child: _BottomNavButton(
                            selected: false,
                            icon: const Icon(Symbols.menu_rounded),
                            label: MaterialLocalizations.of(
                              context,
                            ).openAppDrawerTooltip,
                            onTap: () => scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavButton(
                            selected: bottomNavCurrentIndex == 0,
                            icon: bottomNavDestinations[0].iconBuilder(
                              bottomNavCurrentIndex == 0,
                            ),
                            label: bottomNavDestinations[0].label,
                            onTap: () => onBottomNavDestinationSelected(0),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavButton(
                            selected: bottomNavCurrentIndex == 1,
                            icon: bottomNavDestinations[1].iconBuilder(
                              bottomNavCurrentIndex == 1,
                            ),
                            label: bottomNavDestinations[1].label,
                            onTap: () => onBottomNavDestinationSelected(1),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavButton(
                            selected: bottomNavCurrentIndex == 2,
                            icon: bottomNavDestinations[2].iconBuilder(
                              bottomNavCurrentIndex == 2,
                            ),
                            label: bottomNavDestinations[2].label,
                            onTap: () => onBottomNavDestinationSelected(2),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavButton(
                            selected: bottomNavCurrentIndex == 3,
                            icon: bottomNavDestinations[3].iconBuilder(
                              bottomNavCurrentIndex == 3,
                            ),
                            label: bottomNavDestinations[3].label,
                            onTap: () => onBottomNavDestinationSelected(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.backquote, meta: true):
            _OpenDrawerIntent(),
        SingleActivator(LogicalKeyboardKey.backquote, control: true):
            _OpenDrawerIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenDrawerIntent: CallbackAction<_OpenDrawerIntent>(
            onInvoke: (_) {
              scaffoldKey.currentState?.openDrawer();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: scaffold),
      ),
    );
  }
}

class _OpenDrawerIntent extends Intent {
  const _OpenDrawerIntent();
}

class _TabDestination {
  final String label;
  final IconData navigationIcon;
  final Widget Function(bool selected) iconBuilder;

  const _TabDestination({
    required this.label,
    required this.navigationIcon,
    required this.iconBuilder,
  });
}

class _BottomNavButton extends StatelessWidget {
  final bool selected;
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
      ),
      icon: icon,
    );
  }
}
