import 'dart:ui' show ImageFilter;

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/navigation/pill_bottom_nav.dart';
import 'package:island/core/navigation/conditional_bottom_nav.dart';
import 'package:island/core/navigation/navigation_rail_scope.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/core/navigation/tab_destinations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

const double kBottomNavHeight = 56.0;

/// The native glass bar's item limit. Without an action button taking the
/// trailing slot, the plugin allows five tabs.
///
/// Wider user-customized layouts keep the Material pill bar.
const int kNativeGlassMaxTabs = 5;

/// Blur sigma the incoming tab page settles out of, at the start of the
/// transition. Subtle: the page must stay readable while it resolves.
const double kTabBlurSigma = 12.0;

@RoutePage()
class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        DashboardRoute(),
        ExploreRoute(),
        UniversalSearchRoute(),
        ChatRoute(),
        RealmListRoute(),
        AccountRoute(),
        WalletRoute(),
        CreatorHubRoute(),
        ThoughtsRoute(),
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
  final theme = Theme.of(context);
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

  // The incoming page resolves out of a blur instead of sliding in: the
  // stack's outgoing page is already gone (auto_route keeps an
  // `IndexedStack`), so what the blur smears is the page's own content
  // settling into focus. Fading in alongside keeps the settle legible.
  //
  // `BackdropFilter` would be wrong here: it blurs whatever is painted
  // behind the child, which is the tab bar and the page under it, not the
  // page itself.
  return ColoredBox(
    color: theme.colorScheme.surface,
    child: FadeTransition(
      opacity: curved,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: kTabBlurSigma * (1 - animation.value),
          sigmaY: kTabBlurSigma * (1 - animation.value),
        ),
        child: child,
      ),
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
  /// Whether the wide layout's rail is expanded over every destination.
  ///
  /// The rail replaces the drawer there, so a request to open the navigation
  /// expands it instead of sliding a drawer over the page. The choice is kept
  /// while switching destinations, so a collapsed rail stays collapsed and an
  /// expanded one stays expanded.
  bool _railExpanded = false;

  void _toggleRail() {
    setState(() => _railExpanded = !_railExpanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Narrow layouts have no rail, so the drawer takes over there; a stale
    // expansion must not survive the width change.
    if (_railExpanded && !isWideScreen(context)) {
      _railExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildShell(context);
  }

  Widget _buildShell(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    final token = ref.watch(tokenProvider);
    final userInfo = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);
    final chatUnreadCount = ref.watch(chatUnreadCountProvider);
    final wideScreen = isWideScreen(context);

    final dashboardEnabled = ref.watch(
      appSettingsProvider.select((settings) => settings.dashboardEnabled),
    );
    // A disabled dashboard is not reachable, so it is not a destination.
    final allDestinations = reachableTabDestinations(dashboardEnabled);
    final navCustomization = ref.watch(navCustomizationProvider);
    final destinationById = {for (final d in allDestinations) d.id: d};
    final defaultRailNavIds = allDestinations.map((e) => e.id).toList();

    List<TabDestination> resolveDestinations({
      required List<String> preferredIds,
      required List<String> fallbackIds,
      required bool useFallbackWhenEmpty,
    }) {
      final resolved = <TabDestination>[];
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
      fallbackIds: kDefaultBottomNavIds,
      useFallbackWhenEmpty: !navCustomization.hasBottomOverride,
    );
    final rootTabRoutes = allDestinations.map((d) => d.routePath).toList();
    final bottomNavRoutes = bottomNavDestinations
        .map((d) => d.routePath)
        .toList();
    final drawerDestinations = allDestinations;
    final accountRouteIndex = allDestinations
        .firstWhere((d) => d.id == 'account')
        .routeIndex;

    // The rail stands in for the drawer on wide layouts, so expanding it has
    // to offer every destination — including the ones the user dropped from
    // the rail — with the customized rail order kept in front.
    final railExpanded = _railExpanded && railDestinations.isNotEmpty;
    final displayedRailDestinations = railExpanded
        ? <TabDestination>[
            ...railDestinations,
            ...allDestinations.where(
              (destination) =>
                  !railDestinations.any((rail) => rail.id == destination.id),
            ),
          ]
        : railDestinations;
    final selectedRailIndex = displayedRailDestinations.indexWhere(
      (d) => d.routeIndex == tabsRouter.activeIndex,
    );
    final railCurrentIndex = selectedRailIndex >= 0 ? selectedRailIndex : 0;
    final selectedBottomNavIndex = bottomNavDestinations.indexWhere(
      (d) => d.routeIndex == tabsRouter.activeIndex,
    );
    final bottomNavCurrentIndex = selectedBottomNavIndex >= 0
        ? selectedBottomNavIndex
        : 0;
    final isDrawerEnabled =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        shouldShowBottomNavForCurrentPath(context, routes: rootTabRoutes);
    // The rail is the wide layout's navigation surface: whenever it is shown,
    // expanding it replaces the drawer entirely.
    final railAvailable = wideScreen && railDestinations.isNotEmpty;
    // In landscape the rail carries the navigation toggle in its bottom-left
    // corner, so pages no longer spend their leading slot on the hamburger.
    final showRailToggle =
        railAvailable &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final drawerEnabled = isDrawerEnabled && !railAvailable;

    /// Handles the "open the navigation" request: expand the rail where it
    /// stands in for the drawer, slide the drawer out everywhere else.
    void openNavigation() {
      if (railAvailable) {
        _toggleRail();
        return;
      }
      if (drawerEnabled) {
        rootScaffoldKey.currentState?.openDrawer();
      }
    }

    /// Wraps a layout in the ⌘` / Ctrl-` navigation shortcut.
    Widget withNavigationShortcut(Widget child) {
      return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.backquote, meta: true):
              _OpenNavigationIntent(),
          SingleActivator(LogicalKeyboardKey.backquote, control: true):
              _OpenNavigationIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _OpenNavigationIntent: CallbackAction<_OpenNavigationIntent>(
              onInvoke: (_) {
                openNavigation();
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: child),
        ),
      );
    }

    void onDestinationSelected(int index) {
      tabsRouter.setActiveIndex(index);
    }

    void onRailDestinationSelected(int index) {
      if (index < 0 || index >= displayedRailDestinations.length) return;
      tabsRouter.setActiveIndex(displayedRailDestinations[index].routeIndex);
    }

    void onBottomNavDestinationSelected(int index) {
      if (index < 0 || index >= bottomNavDestinations.length) return;
      tabsRouter.setActiveIndex(bottomNavDestinations[index].routeIndex);
    }

    /// Opens the per-tab entrances that used to live elsewhere in the UI.
    ///
    /// Only Explore has entrances today: category/tag browsing, shuffle, the
    /// post footprints (bookmarks and reactions) and the draft box.
    /// Long-pressing its destination in the bottom bar, drawer or rail is the
    /// replacement for the app-bar icons and list rows these used to have.
    void showDestinationEntrances(TabDestination destination) {
      if (destination.id != 'explore') return;
      HapticFeedback.mediumImpact();
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    'explore'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.category),
                  title: Text('categoriesAndTags'.tr()),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.router.push(PostCategoriesListRoute());
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.shuffle),
                  title: Text('postShuffle'.tr()),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.router.push(const PostShuffleRoute());
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.footprint),
                  title: Text('browseFootprints'.tr()),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.router.push(const BookmarksRoute());
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.drafts),
                  title: Text('draftBox').tr(),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.router.push(const DraftBoxRoute());
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget withEntranceMenu(Widget child, TabDestination destination) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => showDestinationEntrances(destination),
        child: child,
      );
    }

    Widget buildNavigationDrawerContent() {
      return SafeArea(
        child: NavigationDrawer(
          // Destinations are indexed by position in `drawerDestinations`,
          // so the active tab must be mapped onto it.
          selectedIndex: drawerDestinations.indexWhere(
            (d) => d.routeIndex == tabsRouter.activeIndex,
          ),
          onDestinationSelected: (index) {
            Navigator.of(context).pop();
            if (index < 0 || index >= drawerDestinations.length) return;
            tabsRouter.setActiveIndex(drawerDestinations[index].routeIndex);
          },
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onDestinationSelected(accountRouteIndex);
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
                      CloudImageWidget(
                        file: userInfo.value!.profile.background!,
                        fit: BoxFit.cover,
                        imageOnly: true,
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
                          if (token != null && userInfo.value != null)
                            ProfilePictureWidget(
                              file: userInfo.value!.profile.picture,
                              fallbackName: userInfo.value!.nick,
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
                label: withEntranceMenu(Text(d.label), d),
                icon: withEntranceMenu(Icon(d.navigationIcon), d),
                selectedIcon: withEntranceMenu(
                  Icon(d.navigationIcon, fill: 1),
                  d,
                ),
              );
            }),
          ],
        ),
      );
    }

    if (wideScreen) {
      if (railDestinations.isEmpty) {
        // No rail to expand: the drawer stays the navigation surface.
        return withNavigationShortcut(
          Scaffold(
            key: rootScaffoldKey,
            drawer: drawerEnabled
                ? Drawer(child: buildNavigationDrawerContent())
                : null,
            drawerEnableOpenDragGesture: drawerEnabled,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            body: SafeArea(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: RepaintBoundary(child: widget.child),
              ),
            ),
          ),
        );
      }
      // No drawer on this layout: the rail is present, so a menu request
      // expands it over every destination instead of sliding a second
      // navigation surface over the page.
      //
      // The rail sizes itself to its content, so a trailing child cannot be
      // spread across its full width. The toggle is therefore overlaid on the
      // bottom slot reserved by `trailing`: 16px in, so its 24px glyph lines
      // up with the destination icons (which are centred in the rail's 80px
      // control column), but with no label beside it.
      Widget rail = NavigationRail(
        backgroundColor: Colors.transparent,
        extended: railExpanded,
        // Extended rails always paint their labels and reject any
        // other label type.
        labelType: railExpanded ? NavigationRailLabelType.none : null,
        // Short windows cannot fit every destination, and the
        // expanded rail shows all of them.
        scrollable: true,
        destinations: displayedRailDestinations.mapIndexed((idx, d) {
          return NavigationRailDestination(
            icon: withEntranceMenu(d.iconBuilder(railCurrentIndex == idx), d),
            label: withEntranceMenu(Text(d.label), d),
          );
        }).toList(),
        selectedIndex: railCurrentIndex,
        onDestinationSelected: onRailDestinationSelected,
        trailing: showRailToggle ? const SizedBox(height: 56) : null,
        trailingAtBottom: true,
      );
      if (showRailToggle) {
        rail = Stack(
          children: [
            rail,
            Positioned(
              left: 16,
              bottom: 8,
              child: const SolDrawerButton(pinnedToRail: true),
            ),
          ],
        );
      }

      final railContent = Scaffold(
        key: rootScaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: SafeArea(
          child: Row(
            children: [
              rail,
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
        ),
      );
      return withNavigationShortcut(
        NavigationRailScope(
          available: true,
          expanded: railExpanded,
          toggle: _toggleRail,
          child: railContent,
        ),
      );
    }

    // `extendBody: true` makes Scaffold inject the floating bar's full slot
    // height (`NavigationBar` + the `PillBottomNav` gutters + the bottom safe
    // area) as `MediaQuery.padding.bottom` here, which is exactly the
    // clearance a tab page needs. Do not add the device safe area on top of
    // it: that double counts the home indicator and leaves pages hovering
    // above the tab bar.
    final mobileTabBody = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: widget.child,
    );

    // The Material pill bar: every platform's baseline, and the glass bar's
    // fallback on non-iOS and pre-Liquid-Glass devices.
    final pillBar = PillBottomNav(
      child: NavigationBar(
        // Icons only: the destinations are already distinguished by the
        // selection indicator, and the band is 56px tall.
        height: kBottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: bottomNavCurrentIndex,
        onDestinationSelected: (index) {
          onBottomNavDestinationSelected(index);
        },
        destinations: bottomNavDestinations.mapIndexed((idx, destination) {
          return NavigationDestination(
            // `label` still feeds semantics ("Home, Tab 1 of 3"), so only
            // the paint is suppressed — here and in the tooltip, whose
            // long-press gesture the entrance menu owns.
            tooltip: '',
            icon: withEntranceMenu(
              destination.iconBuilder(bottomNavCurrentIndex == idx),
              destination,
            ),
            label: destination.label,
          );
        }).toList(),
      ),
    );

    // On iOS the glass bar renders a real `UITabBar`; the widget swaps to
    // [pillBar] itself when the async Liquid Glass support check comes back
    // negative (older iOS), so an unsupported device just keeps the pill bar.
    final glassDestinations = bottomNavDestinations;
    // A bar with no tab at all is not a navigation bar.
    final useGlassBar =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        glassDestinations.isNotEmpty &&
        glassDestinations.length <= kNativeGlassMaxTabs;
    final selectedGlassIndex = glassDestinations.indexWhere(
      (d) => d.routeIndex == tabsRouter.activeIndex,
    );
    // A route the bar does not carry (reached from the drawer) selects no
    // tab, same as the pill bar.
    final glassCurrentIndex = selectedGlassIndex >= 0 ? selectedGlassIndex : 0;
    final bottomBar = useGlassBar
        ? NativeGlassNavBar(
            currentIndex: glassCurrentIndex,
            onTap: (index) {
              if (index < 0 || index >= glassDestinations.length) return;
              tabsRouter.setActiveIndex(glassDestinations[index].routeIndex);
            },
            tabs: [
              for (final destination in glassDestinations)
                NativeGlassNavBarItem(
                  // A titleless `UITabBar` item paints icon-only, which
                  // is the look we want; the plugin exposes no label
                  // toggle. Trade-off: VoiceOver then reads the tab
                  // position only.
                  label: '',
                  symbol: destination.nativeSymbol,
                  selectedSymbol: destination.nativeSelectedSymbol,
                  badgeValue: switch (destination.id) {
                    'chat' when (chatUnreadCount.value ?? 0) > 0 =>
                      '${chatUnreadCount.value}',
                    'account' when (notificationUnreadCount.value ?? 0) > 0 =>
                      '${notificationUnreadCount.value}',
                    _ => null,
                  },
                ),
            ],
            fallback: pillBar,
          )
        : pillBar;
    final scaffold = Scaffold(
      key: rootScaffoldKey,
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      drawer: drawerEnabled
          ? Drawer(child: buildNavigationDrawerContent())
          : null,
      drawerEnableOpenDragGesture: drawerEnabled,
      body: mobileTabBody,
      bottomNavigationBar: ConditionalBottomNav(
        routes: bottomNavRoutes,
        // The drawer's only entry point is the app bar's leading slot, so the
        // tab bar no longer carries a leading menu destination.
        child: bottomBar,
      ),
    );

    return withNavigationShortcut(scaffold);
  }
}

class _OpenNavigationIntent extends Intent {
  const _OpenNavigationIntent();
}
