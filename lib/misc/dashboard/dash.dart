import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/event_countdown_sheet.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/notifications/notification_tile.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/auth/login_modal.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/misc/dashboard/dash_customize.dart';
import 'package:island/core/config.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      body: Center(child: DashboardGrid()),
    );
  }
}

// Helper functions for dynamic dashboard rendering
class DashboardRenderer {
  // Map individual card IDs to widgets
  static Widget buildCard(String cardId, WidgetRef ref) {
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
      default:
        return const SizedBox.shrink();
    }
  }

  // Map column group IDs to column widgets
  static Widget buildColumn(String columnId, WidgetRef ref) {
    switch (columnId) {
      case 'activityColumn':
        return SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [
              CheckInWidget(margin: EdgeInsets.zero),
              const TodayOracleCard(),
              Expanded(child: FortuneCard()),
            ],
          ),
        );
      case 'postsColumn':
        return SizedBox(
          width: 400,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return PostFeaturedList(
                collapsable: false,
                maxHeight: constraints.maxHeight,
              );
            },
          ),
        );
      case 'socialColumn':
        return SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [
              FriendsOverviewWidget(),
              Expanded(child: NotificationsCard()),
            ],
          ),
        );
      case 'chatsColumn':
        return SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [Expanded(child: ChatListCard())],
          ),
        );
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

    final userInfo = ref.watch(userInfoProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final dragging = useState(false);

    return DropTarget(
      onDragDone: (detail) {
        dragging.value = false;
        if (detail.files.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => ShareSheet.files(files: detail.files),
          );
        }
      },
      onDragEntered: (_) => dragging.value = true,
      onDragExited: (_) => dragging.value = false,
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: isWide
                  ? math.min(640, MediaQuery.sizeOf(context).height * 0.65)
                  : MediaQuery.sizeOf(context).height,
            ),
            padding: isWide
                ? EdgeInsets.only(top: devicePadding.top)
                : EdgeInsets.only(top: 24 + devicePadding.top),
            child: Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clock card spans full width (only if enabled in settings)
                if (isWide &&
                    (appSettings.dashboardConfig?.showClockAndCountdown ??
                        true))
                  ClockCard().padding(horizontal: 24)
                else if (!isWide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(8),
                      if (appSettings.dashboardConfig?.showClockAndCountdown ??
                          true)
                        Expanded(child: ClockCard(compact: true)),
                      if (appSettings.dashboardConfig?.showSearchBar ?? true)
                        IconButton(
                          onPressed: () {
                            eventBus.fire(CommandPaletteTriggerEvent());
                          },
                          icon: const Icon(Symbols.search),
                          tooltip: 'searchAnything'.tr(),
                        ),
                    ],
                  ).padding(horizontal: 24),
                // Row with two cards side by side (only if enabled in settings)
                if (isWide &&
                    (appSettings.dashboardConfig?.showSearchBar ?? true))
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
                    child: SearchBar(
                      hintText: 'searchAnything'.tr(),
                      constraints: const BoxConstraints(minHeight: 56),
                      leading: const Icon(
                        Symbols.search,
                      ).padding(horizontal: 24),
                      readOnly: true,
                      onTap: () {
                        eventBus.fire(CommandPaletteTriggerEvent());
                      },
                    ),
                  ),
                if (userInfo.value != null)
                  Expanded(
                    child:
                        (isWide
                                ? _HoverHorizontalScrollArea(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: _DashboardGridWide(),
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    scrollDirection: Axis.vertical,
                                    child: _DashboardGridNarrow(),
                                  ))
                            .clipRRect(
                              topLeft: isWide ? 0 : 12,
                              topRight: isWide ? 0 : 12,
                            ),
                  )
                else
                  Center(
                    child: _UnauthorizedCard(isWide: isWide),
                  ).padding(horizontal: isWide ? 24 : 16),
              ],
            ),
          ),
          // Customize button (positioned for wide screens only)
          if (isWide)
            Positioned(
              bottom: 16,
              right: 16,
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          if (dragging.value)
            Positioned.fill(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.upload_file,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(16),
                      Text(
                        'dropToShare'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardGridWide extends HookConsumerWidget {
  const _DashboardGridWide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final List<Widget> children = [];

    // Always include account unactivated card if user is not activated
    if (userInfo.value != null && userInfo.value?.activatedAt == null) {
      children.add(SizedBox(width: 400, child: AccountUnactivatedCard()));
    }

    // Add configured columns in the specified order
    final horizontalLayouts =
        appSettings.dashboardConfig?.horizontalLayouts ??
        ['activityColumn', 'postsColumn', 'socialColumn', 'chatsColumn'];

    for (final columnId in horizontalLayouts) {
      children.add(DashboardRenderer.buildColumn(columnId, ref));
    }

    // If no children, add a SizedBox.expand to maintain width
    if (children.isEmpty) {
      children.add(SizedBox(width: MediaQuery.sizeOf(context).width));
    }

    return Row(spacing: 16, children: children);
  }
}

class _HoverHorizontalScrollArea extends HookWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _HoverHorizontalScrollArea({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final isHovered = useState(false);
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);

    void updateScrollState() {
      if (!controller.hasClients) {
        canScrollLeft.value = false;
        canScrollRight.value = false;
        return;
      }

      final position = controller.position;
      canScrollLeft.value = position.pixels > 0;
      canScrollRight.value = position.pixels < position.maxScrollExtent;
    }

    useEffect(() {
      void listener() => updateScrollState();

      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollState());

      return () => controller.removeListener(listener);
    }, [controller, child, padding]);

    Future<void> scrollBy(double direction) async {
      if (!controller.hasClients) return;
      final position = controller.position;
      final delta = math.max(position.viewportDimension * 0.8, 280.0);
      final target = (position.pixels + delta * direction).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    final scrollBehavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
    );

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: scrollBehavior,
              child: SingleChildScrollView(
                controller: controller,
                padding: padding,
                scrollDirection: Axis.horizontal,
                child: child,
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _AnimatedDashboardScrollArrow(
                icon: Symbols.chevron_left,
                isVisible: isHovered.value && canScrollLeft.value,
                hiddenOffset: const Offset(-0.4, 0),
                onTap: () => scrollBy(-1),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _AnimatedDashboardScrollArrow(
                icon: Symbols.chevron_right,
                isVisible: isHovered.value && canScrollRight.value,
                hiddenOffset: const Offset(0.4, 0),
                onTap: () => scrollBy(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDashboardScrollArrow extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _AnimatedDashboardScrollArrow({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
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

    // Add configured cards in the specified order
    final verticalLayouts =
        appSettings.dashboardConfig?.verticalLayouts ??
        [
          'checkIn',
          'fortuneCard',
          'postFeatured',
          'friendsOverview',
          'notifications',
          'chatList',
          'fortuneGraph',
        ];

    for (final cardId in verticalLayouts) {
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
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ).padding(bottom: 80),
      ),
    );

    return Column(spacing: 16, children: children);
  }
}

class ClockCard extends HookConsumerWidget {
  final bool compact;
  const ClockCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = useState(DateTime.now());
    final timer = useRef<Timer?>(null);
    final countdowns = ref.watch(eventCountdownsProvider(take: 5));

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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => const EventCountdownSheet(),
          );
        },
        child: Padding(
          padding: compact
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    timeIcon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 5,
                            children: [
                              countdowns.when(
                                data: (items) => items.isEmpty
                                    ? Text('countdownEmpty').tr().fontSize(12)
                                    : _buildCountdownText(context, items.first),
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
            ],
          ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        onTap: () {
          // Show notification sheet similar to explore.dart
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => const NotificationSheet(),
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
            ).padding(horizontal: 16, vertical: 12),
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
                    ).padding(horizontal: 16),
                    const SizedBox(height: 8),
                    NotificationTile(
                      notification: recentNotification,
                      compact: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
            ).padding(horizontal: 16, vertical: 8),
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
    final chatUnreadCount = ref.watch(chatUnreadCountProvider);

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
            ).padding(horizontal: 16, vertical: 16),
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
                  return const Center(child: Text('No chat rooms available'));
                }
                // Take only the first 5 rooms
                final recentRooms = rooms.take(5).toList();
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
          ).padding(horizontal: 16, vertical: unlimited ? 12 : 0);
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
                ],
              ).padding(horizontal: 16, vertical: 12),
              if (result == null)
                Text(
                  'checkInViewTemple'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).padding(horizontal: 16, bottom: 16)
              else ...[
                Text(
                  'checkInResultLevel${result.level}'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ).padding(horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          horizontal: 16,
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
                  ).padding(horizontal: 16),
                  const SizedBox(height: 8),
                  _OracleActionRow(
                    icon: Symbols.block,
                    text: report.avoidAction,
                    color: theme.colorScheme.error,
                  ).padding(horizontal: 16),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 32,
          vertical: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(16),
            const SizedBox(width: double.infinity),
            Icon(
              Symbols.dashboard_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
              fill: 1,
            ),
            const Gap(16),
            Text(
              'Welcome to\nthe Solar Network',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Login to access your personalized dashboard with friends, notifications, chats, and more!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  builder: (context) => const LoginModal(),
                );
              },
              icon: const Icon(Symbols.login),
              label: Text('login').tr(),
            ),
          ],
        ),
      ),
    );
  }
}
