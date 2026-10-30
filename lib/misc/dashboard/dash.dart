import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/notifications/notification_tile.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/auth/login_modal.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/misc/dashboard/dash_customize.dart';
import 'package:island/misc/dashboard/dashboard_layout.dart';
import 'package:island/misc/dashboard/weather.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/plugins/apis/dashboard_api.dart';
import 'package:island/plugins/widgets/plugin_ui_bridge.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

// Dashboard rhythm. One spacing scale for both breakpoints: roomy page
// gutters, `_kCardGap` between cards, and a generous top band so the overview
// reads as a calm glance instead of a dense wall of cards.
const _kCardGap = SolSpace.xl;
const _kBlockGap = SolSpace.xxxl;
const _kCardPadding = SolSpace.card;
const _kCardHeaderPadding = SolSpace.lg;
const _kGutterCompact = SolSpace.page;
const _kGutterExpanded = SolSpace.pageWide;
// Top band, as a fraction of viewport height, that rests the clock/search row
// (and everything under it) lower in the viewport. It lives inside the scroll
// view, so it scrolls away instead of permanently eating the viewport.
const _kTopBand = 0.2;

@RoutePage()
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardEnabled = ref.watch(
      appSettingsProvider.select((settings) => settings.dashboardEnabled),
    );
    if (!dashboardEnabled) return const _DisabledDashboardRedirect();

    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    return AppScaffold(
      isNoBackground: false,
      body: Stack(
        children: [
          Center(child: DashboardGrid()),
          // The dashboard no longer carries a header pill, so portrait keeps a
          // single glass hamburger at the top-left as its navigation entry.
          if (isPortrait)
            Positioned(
              left: kPillSideGutter,
              top: MediaQuery.paddingOf(context).top + kPillSideGutter,
              child: const GlassNavigationButton(),
            ),
        ],
      ),
    );
  }
}

/// Stands in for the dashboard when it is turned off in settings. Explore
/// becomes the landing surface, so anything that lands on `/` — launch, the
/// back-to-home button, a `/dashboard` deep link — is sent there instead.
class _DisabledDashboardRedirect extends HookConsumerWidget {
  const _DisabledDashboardRedirect();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        // The root router resolves `/explore` through the tab shell; the
        // router scoped to this tab cannot.
        ref.read(routerProvider).navigatePath('/explore');
      });
      return null;
    }, []);

    return const AppScaffold(isNoBackground: false, body: SizedBox.shrink());
  }
}

// Helper functions for dynamic dashboard rendering
class DashboardRenderer {
  // Map individual card IDs to widgets
  static Widget buildCard(String cardId, WidgetRef ref) {
    final pluginItem = PluginManager().getApi<DashboardApi>()?.itemForLayoutId(
      cardId,
    );
    if (pluginItem != null) return _PluginDashboardItem(item: pluginItem);
    switch (cardId) {
      case 'checkIn':
        return CheckInWidget(margin: EdgeInsets.zero);
      case 'fortuneGraph':
        return const TodayOracleCard();
      case 'fortuneCard':
        return FortuneCard(unlimited: true);
      case 'postFeatured':
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: PostFeaturedList(),
        );
      case 'friendsOverview':
        return FriendsOverviewWidget();
      case 'notifications':
        return NotificationsCard();
      case 'chatList':
        return ChatListCard();
      case 'weather':
        return const WeatherCard();
      default:
        return const SizedBox.shrink();
    }
  }
}

class DashboardGrid extends HookConsumerWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final devicePadding = MediaQuery.paddingOf(context);
    // Only the safe area stays fixed; the breathing band scrolls with the
    // content, so it never permanently eats the viewport.
    final topBand = MediaQuery.sizeOf(context).height * _kTopBand;

    final userInfo = ref.watch(userInfoProvider);

    // Check if user is authenticated
    final isAuthenticated = userInfo.value != null;

    return Stack(
      children: [
        Container(
          padding: isAuthenticated
              ? EdgeInsets.only(top: devicePadding.top)
              : EdgeInsets.zero,
          child: isAuthenticated
              ? (isWide
                    // Desktop: one scroll, so the band can rest the
                    // search bar near vertical center by default.
                    ? _DashboardGridWide(topBand: topBand)
                    : _DashboardGridNarrowScroll(topBand: topBand))
              : Center(child: _UnauthorizedCard(isWide: isWide)),
        ),
        // Customize button (positioned for wide screens only)
        if (isWide && isAuthenticated)
          Positioned(
            bottom: _kGutterExpanded - 8,
            right: _kGutterExpanded - 8,
            child: TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => const DashboardCustomizationSheet(),
                );
              },
              icon: Icon(
                Symbols.tune,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'customize',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).tr(),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashboardGridWide extends HookConsumerWidget {
  const _DashboardGridWide({required this.topBand});

  /// Breathing room above the clock/search row; scrolls away with the content.
  final double topBand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final scrollController = useScrollController();
    final canScrollDown = useState(false);

    final showClock =
        appSettings.dashboardConfig?.showClockAndCountdown ?? true;
    final showSearch = appSettings.dashboardConfig?.showSearchBar ?? true;

    final List<Widget> cards = [];

    // Always include account unactivated card if user is not activated
    if (userInfo.value != null && userInfo.value?.activatedAt == null) {
      cards.add(const AccountUnactivatedCard());
    }

    // Desktop waterfall: individual cards from horizontalLayouts (migrated).
    final cardIds = DashboardLayout.resolveCardLayouts(
      appSettings.dashboardConfig?.horizontalLayouts,
    );

    for (final cardId in cardIds) {
      cards.add(DashboardRenderer.buildCard(cardId, ref));
    }

    // The band arrives above the clock/search row and repeats at the end, so
    // the last row can settle with the same room.
    final bottomSpacerHeight = MediaQuery.sizeOf(context).height * _kTopBand;

    void updateScrollHint() {
      if (!scrollController.hasClients) {
        canScrollDown.value = false;
        return;
      }
      final position = scrollController.position;
      // More content below the viewport (with a small threshold).
      canScrollDown.value =
          position.maxScrollExtent > 0 &&
          position.pixels < position.maxScrollExtent - 4;
    }

    useEffect(() {
      void listener() => updateScrollHint();
      scrollController.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollHint());
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    final theme = Theme.of(context);
    final fadeColor = theme.scaffoldBackgroundColor;

    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            updateScrollHint();
            return false;
          },
          child: CustomScrollView(
            controller: scrollController,
            primary: false,
            slivers: [
              // Push clock + search lower in the viewport by default.
              SliverToBoxAdapter(child: SizedBox(height: topBand)),
              if (showClock)
                SliverToBoxAdapter(
                  child: ClockCard().padding(
                    horizontal: _kGutterExpanded,
                    bottom: _kCardGap,
                  ),
                ),
              if (showSearch)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: _kGutterExpanded),
                    child: _DashboardSearchBar(),
                  ),
                ),
              if (showClock || showSearch)
                const SliverToBoxAdapter(child: SizedBox(height: _kBlockGap)),
              // Waterfall of section cards, centered on ultra-wide monitors.
              if (cards.isNotEmpty)
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    const maxContentWidth = 1400.0;
                    final available = constraints.crossAxisExtent;
                    final sideInset = available > maxContentWidth
                        ? (available - maxContentWidth) / 2
                        : 0.0;

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        _kGutterExpanded + sideInset,
                        0,
                        _kGutterExpanded + sideInset,
                        0,
                      ),
                      sliver: SliverMasonryGrid(
                        // Three wide columns on a full-width display instead of
                        // four narrow ones: fewer, calmer cards per row.
                        gridDelegate:
                            const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 480,
                            ),
                        mainAxisSpacing: _kCardGap,
                        crossAxisSpacing: _kCardGap,
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => cards[index],
                          childCount: cards.length,
                        ),
                      ),
                    );
                  },
                ),
              // Match the top band so content can settle with the same breathing room.
              SliverToBoxAdapter(child: SizedBox(height: bottomSpacerHeight)),
            ],
          ),
        ),
        // Fade at the bottom when more content is scrollable below.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: canScrollDown.value ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fadeColor.withOpacity(0),
                      fadeColor.withOpacity(0.72),
                      fadeColor.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.55, 1.0],
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

/// Narrow dashboard: the band, the clock/search row and the card column share
/// one scroll, so the whole sheet moves together — nothing is pinned.
class _DashboardGridNarrowScroll extends HookConsumerWidget {
  const _DashboardGridNarrowScroll({required this.topBand});

  /// Breathing room above the clock/search row; scrolls away with the content.
  final double topBand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final showClock =
        appSettings.dashboardConfig?.showClockAndCountdown ?? true;
    final showSearch = appSettings.dashboardConfig?.showSearchBar ?? true;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topBand)),
        if (showClock)
          SliverToBoxAdapter(
            child: ClockCard(
              compact: true,
            ).padding(horizontal: _kGutterCompact, bottom: _kCardGap),
          ),
        if (showSearch)
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _DashboardSearchBar(),
            ),
          ),
        if (showClock || showSearch)
          const SliverToBoxAdapter(child: SizedBox(height: _kGutterCompact)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: _kGutterCompact),
          sliver: SliverToBoxAdapter(child: _DashboardGridNarrow()),
        ),
      ],
    );
  }
}

/// The single search affordance both breakpoints share: a flat bar that opens
/// the command palette.
class _DashboardSearchBar extends StatelessWidget {
  const _DashboardSearchBar();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'searchAnything'.tr(),
      constraints: const BoxConstraints(minHeight: 56),
      elevation: const WidgetStatePropertyAll(0),
      leading: const Icon(Symbols.search).padding(horizontal: _kCardPadding),
      readOnly: true,
      onTap: () {
        eventBus.fire(CommandPaletteTriggerEvent());
      },
    );
  }
}

class _DashboardGridNarrow extends HookConsumerWidget {
  const _DashboardGridNarrow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final List<Widget> children = [];

    // Always include account unactivated card if user is not activated
    if (userInfo.value != null && userInfo.value?.activatedAt == null) {
      children.add(AccountUnactivatedCard());
    }

    // Mobile single-column: individual cards from verticalLayouts.
    final cardIds = DashboardLayout.resolveCardLayouts(
      appSettings.dashboardConfig?.verticalLayouts,
    );

    for (final cardId in cardIds) {
      children.add(DashboardRenderer.buildCard(cardId, ref));
    }

    // Add customize button at the end
    children.add(
      Center(
        child: TextButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => const DashboardCustomizationSheet(),
            );
          },
          icon: Icon(
            Symbols.tune,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: Text(
            'customize',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ).padding(bottom: MediaQuery.paddingOf(context).bottom + _kBlockGap),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _kCardGap,
      children: children,
    );
  }
}

class _PluginDashboardItem extends StatefulWidget {
  final PluginDashboardItem item;

  const _PluginDashboardItem({required this.item});

  @override
  State<_PluginDashboardItem> createState() => _PluginDashboardItemState();
}

class _PluginDashboardItemState extends State<_PluginDashboardItem> {
  PluginUiDescriptor? _descriptor;

  @override
  void initState() {
    super.initState();
    _buildItem();
  }

  void _buildItem([String? callback, String? value]) {
    final runtime = PluginManager().plugins[widget.item.pluginId]?.runtime;
    if (runtime == null) return;
    final result = runtime.callFunction(
      callback ?? widget.item.handlerName,
      value == null ? null : [value],
    );
    final descriptor = switch (result) {
      String value => PluginUiRenderer.parse(value),
      Map value when value['type'] is String => PluginUiDescriptor(
        type: value['type'] as String,
        data: value.map((key, value) => MapEntry(key.toString(), value)),
      ),
      _ => null,
    };
    if (mounted) setState(() => _descriptor = descriptor);
  }

  @override
  Widget build(BuildContext context) {
    if (_descriptor == null) return const SizedBox.shrink();
    return PluginUiRenderer(descriptor: _descriptor!, onCallback: _buildItem);
  }
}

class ClockCard extends HookConsumerWidget {
  final bool compact;
  const ClockCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = useState(DateTime.now());
    final timer = useRef<Timer?>(null);
    final appSettings = ref.watch(appSettingsProvider);
    final userInfo = ref.watch(userInfoProvider);

    // Only fetch countdowns if user is authenticated
    final isAuthenticated = userInfo.value != null;
    final query = isAuthenticated
        ? EventCountdownQuery(
            username: 'me',
            includeNotableDays:
                appSettings.dashboardConfig?.countdownIncludeNotableDays ??
                true,
          )
        : null;
    final countdowns = query != null
        ? ref.watch(eventCountdownListProvider(query))
        : null;

    // Determine icon based on time of day
    final int hour = time.value.hour;
    final IconData timeIcon = (hour >= 6 && hour < 18)
        ? Symbols.sunny_rounded
        : Symbols.dark_mode_rounded;

    useEffect(() {
      timer.value = Timer.periodic(const Duration(seconds: 1), (_) {
        time.value = DateTime.now();
      });
      return () => timer.value?.cancel();
    }, []);

    return InkWell(
      onTap: () {
        context.router.push(EventHubRoute(name: 'me'));
      },
      child: Padding(
        padding: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: _kCardPadding),
        child: compact
            ? Column(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  Icon(
                    timeIcon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(8),
                  Row(
                    textBaseline: .alphabetic,
                    crossAxisAlignment: .baseline,
                    mainAxisAlignment: .center,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          '${time.value.hour.toString().padLeft(2, '0')}:${time.value.minute.toString().padLeft(2, '0')}:${time.value.second.toString().padLeft(2, '0')}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${time.value.month.toString().padLeft(2, '0')}/${time.value.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (isAuthenticated && countdowns != null)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 5,
                        children: [
                          countdowns.when(
                            data: (state) => state.items.isEmpty
                                ? Text('countdownEmpty').tr().fontSize(12)
                                : _buildCountdownText(
                                    context,
                                    state.items.first,
                                  ),
                            error: (err, _) =>
                                Text(err.toString()).fontSize(12),
                            loading: () =>
                                const Text('loading').tr().fontSize(12),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    timeIcon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.ideographic,
                          children: [
                            Flexible(
                              child: Text(
                                '${time.value.hour.toString().padLeft(2, '0')}:${time.value.minute.toString().padLeft(2, '0')}:${time.value.second.toString().padLeft(2, '0')}',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${time.value.month.toString().padLeft(2, '0')}/${time.value.day.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (isAuthenticated && countdowns != null)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 5,
                              children: [
                                countdowns.when(
                                  data: (state) => state.items.isEmpty
                                      ? Text('countdownEmpty').tr().fontSize(12)
                                      : _buildCountdownText(
                                          context,
                                          state.items.first,
                                        ),
                                  error: (err, _) =>
                                      Text(err.toString()).fontSize(12),
                                  loading: () =>
                                      const Text('loading').tr().fontSize(12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCountdownText(BuildContext context, SnEventCountdownItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUserEvent = item.eventType == SnEventCountdownType.userEvent;
    final icon = isUserEvent ? Symbols.event : Symbols.celebration;

    if (item.isOngoing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          Text(
            item.title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'countdownOngoing'.tr(),
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        Text(
          item.title,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        ),
        SlideCountdown(
          decoration: const BoxDecoration(),
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          separatorStyle: TextStyle(fontSize: 12, color: colorScheme.primary),
          padding: EdgeInsets.zero,
          duration: item.startTime.difference(DateTime.now()),
        ),
      ],
    );
  }
}

class NotificationsCard extends HookConsumerWidget {
  const NotificationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final notificationsUnreadCount = ref.watch(notificationUnreadCountProvider);

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: SolRadius.cardRadius,
        onTap: () {
          showAttentionModal(
            id: 'notifications',
            replaceIfExists: true,
            barrierDismissible: true,
            builder: (context, dismiss) =>
                NotificationModal(onDismiss: dismiss),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.notifications,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'notifications'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Badge.count(
                  count: notificationsUnreadCount.value ?? 0,
                  isLabelVisible: (notificationsUnreadCount.value ?? 0) > 0,
                ),
              ],
            ).padding(horizontal: _kCardPadding, vertical: _kCardHeaderPadding),
            notifications.when(
              loading: () => Skeletonizer(
                enabled: true,
                child: const SkeletonNotificationTile(),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (notificationList) {
                if (notificationList.items.isEmpty) {
                  return Center(child: Text('noNotificationsYet').tr());
                }
                // Get the most recent notification (first in the list)
                final recentNotification = notificationList.items.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'mostRecent'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ).padding(horizontal: _kCardPadding),
                    const SizedBox(height: 8),
                    NotificationTile(
                      notification: recentNotification,
                      compact: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: _kCardPadding,
                      ),
                      avatarRadius: 16.0,
                    ),
                  ],
                );
              },
            ),
            Text(
              'tapToViewAllNotifications'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ).padding(horizontal: _kCardPadding, vertical: 8),
          ],
        ),
      ),
    );
  }
}

class ChatListCard extends HookConsumerWidget {
  const ChatListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(chatRoomJoinedProvider);
    final chatSummaries = ref.watch(chatSummaryProvider);
    final chatUnreadCount = ref.watch(chatUnreadCountProvider);

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.chat,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'recentChats'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Badge.count(
                  count: chatUnreadCount.value ?? 0,
                  isLabelVisible: (chatUnreadCount.value ?? 0) > 0,
                ),
              ],
            ).padding(horizontal: _kCardPadding, vertical: _kCardHeaderPadding),
            chatRooms.when(
              loading: () => Center(
                child: ConfuseSpinner(
                  size: 40,
                  speed: 6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                ),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Center(child: Text('noChatRoomsAvailable'.tr()));
                }
                // Sort rooms by last message time (most recent first), then take top 5
                final summaries = chatSummaries.asData?.value ?? {};
                final sortedRooms = List<SnChatRoom>.from(rooms)
                  ..sort((a, b) {
                    final aTime = summaries[a.id]?.lastMessage?.createdAt;
                    final bTime = summaries[b.id]?.lastMessage?.createdAt;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });
                final recentRooms = sortedRooms.take(5).toList();
                return Column(
                  children: recentRooms.map((room) {
                    return ChatRoomListTile(
                      room: room,
                      isDirect: room.type == 1,
                      onTap: () {
                        context.router.navigate(ChatRoomRoute(id: room.id));
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FortuneCard extends HookConsumerWidget {
  final bool unlimited;
  const FortuneCard({super.key, this.unlimited = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(randomFortuneSayingProvider);

    final child = Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: fortuneAsync.when(
        loading: () => Center(
          child: ConfuseSpinner(
            size: 40,
            speed: 6,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.65),
          ),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (fortune) {
          return Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fortune.content,
                  maxLines: unlimited ? null : 2,
                  overflow: TextOverflow.fade,
                ),
              ),
              Text('—— ${fortune.source}').bold(),
            ],
          ).padding(
            horizontal: _kCardPadding,
            vertical: unlimited ? _kCardHeaderPadding : 0,
          );
        },
      ),
    );

    if (unlimited) return child;
    return child.height(48);
  }
}

class TodayOracleCard extends ConsumerWidget {
  const TodayOracleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: todayResult.when(
        loading: () => Center(
          child: ConfuseSpinner(
            size: 36,
            speed: 6,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.65),
          ),
        ).padding(vertical: 16),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            error.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        data: (result) {
          final report = result?.fortuneReport;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.temple_buddhist,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'checkInTodayOracle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.calendar_month, size: 20),
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      context.router.push(EventHubRoute(name: 'me'));
                    },
                  ),
                ],
              ).padding(
                horizontal: _kCardPadding,
                vertical: _kCardHeaderPadding,
              ),
              if (result == null)
                Text(
                  'checkInViewTemple'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).padding(horizontal: _kCardPadding, bottom: _kCardPadding)
              else ...[
                Text(
                  'checkInResultLevel${result.level}'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ).padding(horizontal: _kCardPadding),
                if (report != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _OracleMetaChip(
                        icon: Symbols.palette,
                        text: report.luckyColor,
                      ),
                      _OracleMetaChip(
                        icon: Symbols.schedule,
                        text: report.luckyTime,
                      ),
                      _OracleMetaChip(
                        icon: Symbols.explore,
                        text: report.luckyDirection,
                      ),
                    ],
                  ).padding(horizontal: 12),
                  if (result.tips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kCardPadding,
                      ),
                      child: Row(
                        children: [
                          if (result.tips.any((t) => t.isPositive)) ...[
                            Icon(
                              Symbols.thumb_up,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                result.tips
                                    .where((t) => t.isPositive)
                                    .map((t) => t.title)
                                    .join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (result.tips.any((t) => !t.isPositive))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kCardPadding,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.thumb_down,
                              size: 14,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                result.tips
                                    .where((t) => !t.isPositive)
                                    .map((t) => t.title)
                                    .join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  _OracleActionRow(
                    icon: Symbols.task_alt,
                    text: report.luckyAction,
                    color: theme.colorScheme.primary,
                  ).padding(horizontal: _kCardPadding),
                  const SizedBox(height: 8),
                  _OracleActionRow(
                    icon: Symbols.block,
                    text: report.avoidAction,
                    color: theme.colorScheme.error,
                  ).padding(horizontal: _kCardPadding),
                ],
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OracleMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OracleMetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _OracleActionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _OracleActionRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _UnauthorizedCard extends HookConsumerWidget {
  final bool isWide;
  const _UnauthorizedCard({required this.isWide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 32,
            vertical: isWide ? 40 : 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // The island's resident mascot waves hello, inviting a
              // logged-out guest back into their personal space.
              Image.asset(
                'assets/images/stickers/hello.webp',
                width: 136,
                height: 136,
                fit: BoxFit.contain,
              ),
              const Gap(24),
              Text(
                'welcomeToSolarNetwork'.tr(),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  'loginToAccessDashboard'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(32),
              FilledButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (context) => const LoginModal(),
                  );
                },
                icon: const Icon(Symbols.login, size: 20),
                label: Text('login'.tr()),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
