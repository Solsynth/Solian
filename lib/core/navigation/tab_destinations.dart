import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A root tab the shell can place in the rail, the bottom bar or the drawer.
class TabDestination {
  final String id;
  final int routeIndex;
  final String routePath;
  final String label;
  final IconData navigationIcon;
  final Widget Function(bool selected) iconBuilder;

  /// SF Symbol names for the native iOS glass tab bar, which renders a real
  /// `UITabBar` and cannot draw [navigationIcon].
  final String nativeSymbol;
  final String? nativeSelectedSymbol;

  const TabDestination({
    required this.id,
    required this.routeIndex,
    required this.routePath,
    required this.label,
    required this.navigationIcon,
    required this.iconBuilder,
    required this.nativeSymbol,
    this.nativeSelectedSymbol,
  });
}

/// Every root tab, in route order.
///
/// Labels and badge counts are resolved when the shell builds, so this is a
/// getter rather than a const list.
List<TabDestination> get allTabDestinations => [
  TabDestination(
    id: 'dashboard',
    routeIndex: 0,
    routePath: '/',
    label: 'dashboard'.tr(),
    navigationIcon: Symbols.dashboard_rounded,
    iconBuilder: (selected) =>
        Icon(Symbols.dashboard_rounded, fill: selected ? 1 : null),
    nativeSymbol: 'square.grid.2x2',
    nativeSelectedSymbol: 'square.grid.2x2.fill',
  ),
  TabDestination(
    id: 'explore',
    routeIndex: 1,
    routePath: '/explore',
    label: 'explore'.tr(),
    navigationIcon: Symbols.explore_rounded,
    iconBuilder: (selected) =>
        Icon(Symbols.explore_rounded, fill: selected ? 1 : null),
    nativeSymbol: 'safari',
    nativeSelectedSymbol: 'safari.fill',
  ),
  TabDestination(
    id: 'search',
    routeIndex: 2,
    routePath: '/search',
    label: 'search'.tr(),
    navigationIcon: Symbols.search,
    iconBuilder: (selected) => Icon(Symbols.search, fill: selected ? 1 : null),
    nativeSymbol: 'magnifyingglass',
  ),
  TabDestination(
    id: 'chat',
    routeIndex: 3,
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
    nativeSymbol: 'bubble.left.and.bubble.right',
    nativeSelectedSymbol: 'bubble.left.and.bubble.right.fill',
  ),
  TabDestination(
    id: 'realms',
    routeIndex: 4,
    routePath: '/realms',
    label: 'realms'.tr(),
    navigationIcon: Symbols.groups_3,
    iconBuilder: (selected) => Icon(Symbols.groups_3, fill: selected ? 1 : null),
    nativeSymbol: 'person.3',
    nativeSelectedSymbol: 'person.3.fill',
  ),
  TabDestination(
    id: 'account',
    routeIndex: 5,
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
          child: userInfo.value != null
              ? ProfilePictureWidget(
                  file: userInfo.value!.profile.picture,
                  fallbackName: userInfo.value!.nick,
                  radius: 12,
                )
              : const Icon(Symbols.account_circle_rounded),
        );
      },
    ),
    nativeSymbol: 'person.crop.circle',
    nativeSelectedSymbol: 'person.crop.circle.fill',
  ),
  TabDestination(
    id: 'wallet',
    routeIndex: 6,
    routePath: '/wallet',
    label: 'wallet'.tr(),
    navigationIcon: Symbols.wallet,
    iconBuilder: (selected) => Icon(Symbols.wallet, fill: selected ? 1 : null),
    nativeSymbol: 'creditcard',
    nativeSelectedSymbol: 'creditcard.fill',
  ),
  TabDestination(
    id: 'creators',
    routeIndex: 7,
    routePath: '/creators',
    label: 'creatorHub'.tr(),
    navigationIcon: Symbols.design_services_rounded,
    iconBuilder: (selected) =>
        Icon(Symbols.design_services_rounded, fill: selected ? 1 : null),
    nativeSymbol: 'paintbrush.pointed',
    nativeSelectedSymbol: 'paintbrush.pointed.fill',
  ),
  TabDestination(
    id: 'thoughts',
    routeIndex: 8,
    routePath: '/thoughts',
    label: 'thoughts'.tr(),
    navigationIcon: Symbols.psychology_rounded,
    iconBuilder: (selected) =>
        Icon(Symbols.psychology_rounded, fill: selected ? 1 : null),
    nativeSymbol: 'brain.head.profile',
  ),
];

/// The reachable destinations: a disabled dashboard is not one.
List<TabDestination> reachableTabDestinations(bool dashboardEnabled) =>
    allTabDestinations
        .where((d) => dashboardEnabled || d.id != 'dashboard')
        .toList();

const kDefaultBottomNavIds = ['dashboard', 'explore', 'chat', 'account'];

const _kBottomNavLayoutsKey = 'app_bottom_nav_layouts';
const _kRailNavLayoutsKey = 'app_rail_nav_layouts';

/// The shell's persisted per-bar destination layouts.
final navCustomizationProvider =
    NotifierProvider<NavCustomizationNotifier, NavCustomizationState>(
      NavCustomizationNotifier.new,
    );

class NavCustomizationState {
  final List<String> bottomIds;
  final List<String> railIds;
  final bool hasBottomOverride;
  final bool hasRailOverride;

  const NavCustomizationState({
    required this.bottomIds,
    required this.railIds,
    required this.hasBottomOverride,
    required this.hasRailOverride,
  });
}

class NavCustomizationNotifier extends Notifier<NavCustomizationState> {
  late SharedPreferences _prefs;

  @override
  NavCustomizationState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return NavCustomizationState(
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
    state = NavCustomizationState(
      bottomIds: bottomIds,
      railIds: railIds,
      hasBottomOverride: true,
      hasRailOverride: true,
    );
  }

  void restoreDefaults() {
    _prefs.remove(_kBottomNavLayoutsKey);
    _prefs.remove(_kRailNavLayoutsKey);
    state = const NavCustomizationState(
      bottomIds: [],
      railIds: [],
      hasBottomOverride: false,
      hasRailOverride: false,
    );
  }
}

/// Picks which destinations the bottom bar and the rail carry, and in what
/// order. Reached from Settings → Navigation; the navigation surfaces
/// themselves never offer it.
class NavigationCustomizationSheet extends StatefulWidget {
  const NavigationCustomizationSheet({super.key});

  @override
  State<NavigationCustomizationSheet> createState() =>
      _NavigationCustomizationSheetState();
}

class _NavigationCustomizationSheetState
    extends State<NavigationCustomizationSheet> {
  late List<String> _bottomIds;
  late List<String> _railIds;
  late final List<TabDestination> _allDestinations;
  late final bool _hasBottomOverride;
  late final bool _hasRailOverride;

  @override
  void initState() {
    super.initState();
    final container = ProviderScope.containerOf(context);
    final dashboardEnabled = container.read(
      appSettingsProvider.select((settings) => settings.dashboardEnabled),
    );
    final customization = container.read(navCustomizationProvider);
    _allDestinations = reachableTabDestinations(dashboardEnabled);
    _hasBottomOverride = customization.hasBottomOverride;
    _hasRailOverride = customization.hasRailOverride;

    final allIds = _allDestinations.map((e) => e.id).toList();
    // Defaults are sanitized too: a disabled dashboard is not a destination.
    _bottomIds =
        (_hasBottomOverride
                ? customization.bottomIds
                : kDefaultBottomNavIds)
            .where(allIds.contains)
            .toList();

    final sanitizedRail = customization.railIds
        .where(allIds.contains)
        .toList();
    _railIds = _hasRailOverride ? sanitizedRail : allIds;
  }

  @override
  Widget build(BuildContext context) {
    final destinationById = {for (final d in _allDestinations) d.id: d};

    return SheetScaffold(
      titleText: 'customizeNavigation'.tr(),
      actions: [
        IconButton(
          onPressed: () {
            ProviderScope.containerOf(
              context,
            ).read(navCustomizationProvider.notifier).restoreDefaults();
            Navigator.of(context).pop();
          },
          icon: const Icon(Symbols.refresh_rounded),
          tooltip: 'restoreDefaults'.tr(),
        ),
        IconButton(
          onPressed: () {
            ProviderScope.containerOf(
              context,
            ).read(navCustomizationProvider.notifier).setLayouts(
              bottomIds: _bottomIds,
              railIds: _railIds,
            );
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
                  children: _allDestinations.map((d) {
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
                  children: _allDestinations.map((d) {
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
