import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/navigation/conditional_bottom_nav.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        WalletRoute(),
        ThoughtRoute(),
        CreatorHubRoute(),
        DeveloperHubRoute(),
      ],
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      transitionBuilder: _buildTabTransition,
      builder: (context, child) {
        return _TabsScreenContent(child: child);
      },
    );
  }
}

Widget _buildTabTransition(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  final tabsRouter = AutoTabsRouter.of(context);
  final theme = Theme.of(context);
  final previousIndex = tabsRouter.previousIndex ?? tabsRouter.activeIndex;
  final isForward = tabsRouter.activeIndex >= previousIndex;
  final isWide = isWideScreen(context);

  final offset = isWide
      ? Offset(0, isForward ? 0.06 : -0.06)
      : Offset(isForward ? 0.08 : -0.08, 0);

  final position = Tween<Offset>(
    begin: offset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
  final opacity = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  );

  return ColoredBox(
    color: theme.colorScheme.surface,
    child: FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: position, child: child),
    ),
  );
}

class _TabsScreenContent extends ConsumerStatefulWidget {
  final Widget child;

  const _TabsScreenContent({required this.child});

  @override
  ConsumerState<_TabsScreenContent> createState() => _TabsScreenContentState();
}

class _TabsScreenContentState extends ConsumerState<_TabsScreenContent> {
  @override
  void initState() {
    super.initState();
  }

  static List<_TabDestination> get _allDestinations => [
    _TabDestination(
      id: 'dashboard',
      routeIndex: 0,
      routePath: '/',
      label: 'dashboard'.tr(),
      navigationIcon: Symbols.dashboard_rounded,
      iconBuilder: (selected) =>
          Icon(Symbols.dashboard_rounded, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'explore',
      routeIndex: 1,
      routePath: '/explore',
      label: 'explore'.tr(),
      navigationIcon: Symbols.explore_rounded,
      iconBuilder: (selected) =>
          Icon(Symbols.explore_rounded, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'chat',
      routeIndex: 2,
      routePath: '/chat',
      label: 'chat'.tr(),
      navigationIcon: Symbols.forum_rounded,
      iconBuilder: (_) => Consumer(
        builder: (context, ref, _) {
          final chatUnreadCount = ref.watch(chatUnreadCountProvider);
          return Badge.count(
            count: chatUnreadCount.value ?? 0,
            isLabelVisible: (chatUnreadCount.value ?? 0) > 0,
            child: const Icon(Symbols.forum_rounded),
          );
        },
      ),
    ),
    _TabDestination(
      id: 'realms',
      routeIndex: 3,
      routePath: '/realms',
      label: 'realms'.tr(),
      navigationIcon: Symbols.groups_3,
      iconBuilder: (selected) =>
          Icon(Symbols.groups_3, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'account',
      routeIndex: 4,
      routePath: '/account',
      label: 'account'.tr(),
      navigationIcon: Symbols.account_circle_rounded,
      iconBuilder: (_) => Consumer(
        builder: (context, ref, _) {
          final notificationUnreadCount = ref.watch(
            notificationUnreadCountProvider,
          );
          final userInfo = ref.watch(userInfoProvider);
          return Badge.count(
            count: notificationUnreadCount.value ?? 0,
            isLabelVisible: (notificationUnreadCount.value ?? 0) > 0,
            child: userInfo.value?.profile.picture != null
                ? ProfilePictureWidget(
                    file: userInfo.value!.profile.picture,
                    radius: 12,
                  )
                : const Icon(Symbols.account_circle_rounded),
          );
        },
      ),
    ),
    _TabDestination(
      id: 'files',
      routeIndex: 5,
      routePath: '/files',
      label: 'files'.tr(),
      navigationIcon: Symbols.folder_rounded,
      iconBuilder: (selected) =>
          Icon(Symbols.folder_rounded, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'wallet',
      routeIndex: 6,
      routePath: '/wallet',
      label: 'wallet'.tr(),
      navigationIcon: Symbols.wallet,
      iconBuilder: (selected) =>
          Icon(Symbols.wallet, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'thought',
      routeIndex: 7,
      routePath: '/thought',
      label: 'aiThought'.tr(),
      navigationIcon: Symbols.bubble_chart,
      iconBuilder: (selected) =>
          Icon(Symbols.bubble_chart, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'creators',
      routeIndex: 8,
      routePath: '/creators',
      label: 'creatorHub'.tr(),
      navigationIcon: Symbols.design_services_rounded,
      iconBuilder: (selected) =>
          Icon(Symbols.design_services_rounded, fill: selected ? 1 : null),
    ),
    _TabDestination(
      id: 'developers',
      routeIndex: 9,
      routePath: '/developers',
      label: 'developerHub'.tr(),
      navigationIcon: Symbols.data_object_rounded,
      iconBuilder: (selected) =>
          Icon(Symbols.data_object_rounded, fill: selected ? 1 : null),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    final token = ref.watch(tokenProvider);
    final userInfo = ref.watch(userInfoProvider);
    ref.watch(notificationUnreadCountProvider);
    ref.watch(chatUnreadCountProvider);
    final wideScreen = isWideScreen(context);

    final allDestinations = _allDestinations;
    final navCustomization = ref.watch(_navCustomizationProvider);
    final destinationById = {for (final d in allDestinations) d.id: d};
    final defaultBottomNavIds = ['dashboard', 'explore', 'chat', 'account'];
    final defaultRailNavIds = allDestinations.map((e) => e.id).toList();

    List<_TabDestination> resolveDestinations({
      required List<String> preferredIds,
      required List<String> fallbackIds,
      required bool useFallbackWhenEmpty,
    }) {
      final resolved = <_TabDestination>[];
      for (final id in preferredIds) {
        final dest = destinationById[id];
        if (dest == null) continue;
        if (resolved.any((e) => e.id == dest.id)) continue;
        resolved.add(dest);
      }
      if (resolved.isEmpty && useFallbackWhenEmpty) {
        for (final id in fallbackIds) {
          final dest = destinationById[id];
          if (dest == null) continue;
          if (resolved.any((e) => e.id == dest.id)) continue;
          resolved.add(dest);
        }
      }
      return resolved;
    }

    final railDestinations = resolveDestinations(
      preferredIds: navCustomization.railIds,
      fallbackIds: defaultRailNavIds,
      useFallbackWhenEmpty: !navCustomization.hasRailOverride,
    );
    final bottomNavDestinations = resolveDestinations(
      preferredIds: navCustomization.bottomIds,
      fallbackIds: defaultBottomNavIds,
      useFallbackWhenEmpty: !navCustomization.hasBottomOverride,
    );
    final rootTabRoutes = allDestinations.map((d) => d.routePath).toList();
    final bottomNavRoutes = bottomNavDestinations
        .map((d) => d.routePath)
        .toList();
    final drawerDestinations = allDestinations;

    final selectedRailIndex = railDestinations.indexWhere(
      (d) => d.routeIndex == tabsRouter.activeIndex,
    );
    final railCurrentIndex = selectedRailIndex >= 0 ? selectedRailIndex : 0;
    final selectedBottomNavIndex = bottomNavDestinations.indexWhere(
      (d) => d.routeIndex == tabsRouter.activeIndex,
    );
    final bottomNavCurrentIndex = selectedBottomNavIndex >= 0
        ? selectedBottomNavIndex
        : 0;
    final isDrawerEnabled = shouldShowBottomNavForCurrentPath(
      context,
      routes: rootTabRoutes,
    );

    void onDestinationSelected(int index) {
      tabsRouter.setActiveIndex(index);
    }

    void onRailDestinationSelected(int index) {
      if (index < 0 || index >= railDestinations.length) return;
      tabsRouter.setActiveIndex(railDestinations[index].routeIndex);
    }

    void onBottomNavDestinationSelected(int index) {
      if (index < 0 || index >= bottomNavDestinations.length) return;
      tabsRouter.setActiveIndex(bottomNavDestinations[index].routeIndex);
    }

    void openNavigationCustomization() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => _NavigationCustomizationSheet(
          allDestinations: allDestinations,
          initialBottomIds: navCustomization.bottomIds,
          initialRailIds: navCustomization.railIds,
          hasBottomOverride: navCustomization.hasBottomOverride,
          hasRailOverride: navCustomization.hasRailOverride,
          onSave: (bottomIds, railIds) {
            ref
                .read(_navCustomizationProvider.notifier)
                .setLayouts(bottomIds: bottomIds, railIds: railIds);
          },
          onRestoreDefaults: () {
            ref.read(_navCustomizationProvider.notifier).restoreDefaults();
          },
        ),
      );
    }

    Widget buildNavigationDrawerContent() {
      return SafeArea(
        child: NavigationDrawer(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            Navigator.of(context).pop();
            if (index < 0 || index >= drawerDestinations.length) return;
            tabsRouter.setActiveIndex(drawerDestinations[index].routeIndex);
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                        'notLoggedIn'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      Text(
                                        'tapToSignIn'.tr(),
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
            ...drawerDestinations.map((d) {
              return NavigationDrawerDestination(
                label: Text(d.label),
                icon: Icon(d.navigationIcon),
                selectedIcon: Icon(d.navigationIcon, fill: 1),
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Symbols.tune_rounded),
              title: Text('customizeNavigation').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 28),
              dense: true,
              onTap: () {
                Navigator.of(context).pop();
                openNavigationCustomization();
              },
            ),
          ],
        ),
      );
    }

    if (wideScreen) {
      if (railDestinations.isEmpty) {
        return Scaffold(
          key: rootScaffoldKey,
          drawer: isDrawerEnabled
              ? Drawer(child: buildNavigationDrawerContent())
              : null,
          drawerEnableOpenDragGesture: isDrawerEnabled,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
            child: RepaintBoundary(child: widget.child),
          ),
          floatingActionButton: isDrawerEnabled
              ? FloatingActionButton.small(
                  onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Symbols.menu_rounded),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      }
      return Scaffold(
        key: rootScaffoldKey,
        drawer: isDrawerEnabled
            ? Drawer(child: buildNavigationDrawerContent())
            : null,
        drawerEnableOpenDragGesture: isDrawerEnabled,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.transparent,
              destinations: railDestinations.mapIndexed((idx, d) {
                return NavigationRailDestination(
                  icon: d.iconBuilder(railCurrentIndex == idx),
                  label: Text(d.label),
                );
              }).toList(),
              selectedIndex: railCurrentIndex,
              onDestinationSelected: onRailDestinationSelected,
              trailingAtBottom: true,
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: isDrawerEnabled
                      ? () => rootScaffoldKey.currentState?.openDrawer()
                      : null,
                  child: const Icon(Symbols.menu_rounded),
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: RepaintBoundary(child: widget.child),
              ),
            ),
          ],
        ),
      );
    }

    final scaffold = Scaffold(
      key: rootScaffoldKey,
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      drawer: isDrawerEnabled
          ? Drawer(child: buildNavigationDrawerContent())
          : null,
      drawerEnableOpenDragGesture: isDrawerEnabled,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: widget.child,
      ),
      bottomNavigationBar: ConditionalBottomNav(
        routes: bottomNavRoutes,
        child: NavigationBar(
          height: 56,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: bottomNavCurrentIndex + 1,
          onDestinationSelected: (index) {
            if (index == 0) {
              if (isDrawerEnabled) {
                rootScaffoldKey.currentState?.openDrawer();
              }
            } else {
              onBottomNavDestinationSelected(index - 1);
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Symbols.menu_rounded),
              label: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
            ...bottomNavDestinations.mapIndexed((idx, destination) {
              return NavigationDestination(
                icon: destination.iconBuilder(bottomNavCurrentIndex == idx),
                label: destination.label,
              );
            }),
          ],
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
              if (isDrawerEnabled) {
                rootScaffoldKey.currentState?.openDrawer();
              }
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: scaffold),
      ),
    );
  }
}

const _kBottomNavLayoutsKey = 'app_bottom_nav_layouts';
const _kRailNavLayoutsKey = 'app_rail_nav_layouts';

final _navCustomizationProvider =
    NotifierProvider<_NavCustomizationNotifier, _NavCustomizationState>(
      _NavCustomizationNotifier.new,
    );

class _NavCustomizationState {
  final List<String> bottomIds;
  final List<String> railIds;
  final bool hasBottomOverride;
  final bool hasRailOverride;

  const _NavCustomizationState({
    required this.bottomIds,
    required this.railIds,
    required this.hasBottomOverride,
    required this.hasRailOverride,
  });
}

class _NavCustomizationNotifier extends Notifier<_NavCustomizationState> {
  late SharedPreferences _prefs;

  @override
  _NavCustomizationState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _NavCustomizationState(
      bottomIds: _loadIds(_prefs.getString(_kBottomNavLayoutsKey)),
      railIds: _loadIds(_prefs.getString(_kRailNavLayoutsKey)),
      hasBottomOverride: _prefs.containsKey(_kBottomNavLayoutsKey),
      hasRailOverride: _prefs.containsKey(_kRailNavLayoutsKey),
    );
  }

  static List<String> _loadIds(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      // Ignore malformed persisted values.
    }
    return const [];
  }

  void setLayouts({
    required List<String> bottomIds,
    required List<String> railIds,
  }) {
    _prefs.setString(_kBottomNavLayoutsKey, jsonEncode(bottomIds));
    _prefs.setString(_kRailNavLayoutsKey, jsonEncode(railIds));
    state = _NavCustomizationState(
      bottomIds: bottomIds,
      railIds: railIds,
      hasBottomOverride: true,
      hasRailOverride: true,
    );
  }

  void restoreDefaults() {
    _prefs.remove(_kBottomNavLayoutsKey);
    _prefs.remove(_kRailNavLayoutsKey);
    state = const _NavCustomizationState(
      bottomIds: [],
      railIds: [],
      hasBottomOverride: false,
      hasRailOverride: false,
    );
  }
}

class _NavigationCustomizationSheet extends StatefulWidget {
  final List<_TabDestination> allDestinations;
  final List<String> initialBottomIds;
  final List<String> initialRailIds;
  final bool hasBottomOverride;
  final bool hasRailOverride;
  final void Function(List<String> bottomIds, List<String> railIds) onSave;
  final VoidCallback onRestoreDefaults;

  const _NavigationCustomizationSheet({
    required this.allDestinations,
    required this.initialBottomIds,
    required this.initialRailIds,
    required this.hasBottomOverride,
    required this.hasRailOverride,
    required this.onSave,
    required this.onRestoreDefaults,
  });

  @override
  State<_NavigationCustomizationSheet> createState() =>
      _NavigationCustomizationSheetState();
}

class _NavigationCustomizationSheetState
    extends State<_NavigationCustomizationSheet> {
  late List<String> _bottomIds;
  late List<String> _railIds;

  @override
  void initState() {
    super.initState();
    final allIds = widget.allDestinations.map((e) => e.id).toList();
    final defaultBottom = ['dashboard', 'explore', 'chat', 'account'];
    final sanitizedBottom = widget.initialBottomIds
        .where(allIds.contains)
        .toList();
    _bottomIds = widget.hasBottomOverride ? sanitizedBottom : defaultBottom;

    final sanitizedRail = widget.initialRailIds.where(allIds.contains).toList();
    _railIds = widget.hasRailOverride ? sanitizedRail : allIds;
  }

  @override
  Widget build(BuildContext context) {
    final destinationById = {for (final d in widget.allDestinations) d.id: d};
    final allBottomCandidates = widget.allDestinations;

    return SheetScaffold(
      titleText: 'customizeNavigation'.tr(),
      actions: [
        IconButton(
          onPressed: () {
            widget.onRestoreDefaults();
            Navigator.of(context).pop();
          },
          icon: const Icon(Symbols.refresh_rounded),
          tooltip: 'restoreDefaults'.tr(),
        ),
        IconButton(
          onPressed: () {
            widget.onSave(_bottomIds, _railIds);
            Navigator.of(context).pop();
          },
          icon: const Icon(Symbols.save_rounded),
        ),
      ],
      child: Material(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'bottomNavigation'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allBottomCandidates.map((d) {
                    final selected = _bottomIds.contains(d.id);
                    return FilterChip(
                      selected: selected,
                      label: Text(d.label),
                      avatar: Icon(d.navigationIcon, size: 16),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            if (!_bottomIds.contains(d.id)) {
                              _bottomIds.add(d.id);
                            }
                          } else {
                            _bottomIds.remove(d.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: _bottomIds.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _bottomIds.removeAt(oldIndex);
                      _bottomIds.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final id = _bottomIds[index];
                    final destination = destinationById[id]!;
                    return ListTile(
                      key: ValueKey('bottom_$id'),
                      leading: Icon(destination.navigationIcon),
                      title: Text(destination.label),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Symbols.drag_handle_rounded),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'railNavigation'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.allDestinations.map((d) {
                    final selected = _railIds.contains(d.id);
                    return FilterChip(
                      selected: selected,
                      label: Text(d.label),
                      avatar: Icon(d.navigationIcon, size: 16),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            if (!_railIds.contains(d.id)) _railIds.add(d.id);
                          } else {
                            _railIds.remove(d.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _railIds.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _railIds.removeAt(oldIndex);
                      _railIds.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final id = _railIds[index];
                    final destination = destinationById[id]!;
                    return ListTile(
                      key: ValueKey('rail_$id'),
                      leading: Icon(destination.navigationIcon),
                      title: Text(destination.label),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Symbols.drag_handle_rounded),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenDrawerIntent extends Intent {
  const _OpenDrawerIntent();
}

class _TabDestination {
  final String id;
  final int routeIndex;
  final String routePath;
  final String label;
  final IconData navigationIcon;
  final Widget Function(bool selected) iconBuilder;

  const _TabDestination({
    required this.id,
    required this.routeIndex,
    required this.routePath,
    required this.label,
    required this.navigationIcon,
    required this.iconBuilder,
  });
}
