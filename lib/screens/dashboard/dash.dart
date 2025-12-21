import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/chat_room.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/fortune_graph.dart';
import 'package:island/widgets/account/friends_overview.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/notification_tile.dart';
import 'package:island/widgets/post/post_featured.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/screens/notification.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:styled_widget/styled_widget.dart';
import 'dart:async';

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

class DashboardGrid extends HookConsumerWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final devicePadding = MediaQuery.paddingOf(context);

    final userInfo = ref.watch(userInfoProvider);

    return Container(
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
          // Clock card spans full width
          if (isWide)
            ClockCard().padding(horizontal: 24)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(8),
                Expanded(child: ClockCard(compact: true)),
                IconButton(
                  onPressed: () {
                    eventBus.fire(CommandPaletteTriggerEvent());
                  },
                  icon: const Icon(Symbols.search),
                  tooltip: 'searchAnything'.tr(),
                ),
              ],
            ).padding(horizontal: 24),
          // Row with two cards side by side
          if (isWide)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
              child: SearchBar(
                hintText: 'searchAnything'.tr(),
                constraints: const BoxConstraints(minHeight: 56),
                leading: const Icon(Symbols.search).padding(horizontal: 24),
                readOnly: true,
                onTap: () {
                  eventBus.fire(CommandPaletteTriggerEvent());
                },
              ),
            ),
          if (userInfo.value != null)
            Expanded(
              child:
                  SingleChildScrollView(
                        padding: isWide
                            ? const EdgeInsets.symmetric(horizontal: 24)
                            : EdgeInsets.only(
                                bottom: 64 + devicePadding.bottom,
                              ),
                        scrollDirection: isWide
                            ? Axis.horizontal
                            : Axis.vertical,
                        child: isWide
                            ? _DashboardGridWide()
                            : _DashboardGridNarrow(),
                      )
                      .clipRRect(
                        topLeft: isWide ? 0 : 12,
                        topRight: isWide ? 0 : 12,
                      )
                      .padding(horizontal: isWide ? 0 : 16),
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

    return Row(
      spacing: 16,
      children: [
        if (userInfo.value != null && userInfo.value?.activatedAt == null)
          SizedBox(width: 400, child: AccountUnactivatedCard()),
        SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [
              CheckInWidget(margin: EdgeInsets.zero),
              Card(
                margin: EdgeInsets.zero,
                child: FortuneGraphWidget(
                  events: ref.watch(
                    eventCalendarProvider(
                      EventCalendarQuery(
                        uname: 'me',
                        year: DateTime.now().year,
                        month: DateTime.now().month,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: FortuneCard()),
            ],
          ),
        ),
        SizedBox(width: 400, child: PostFeaturedList(collapsable: false)),
        SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [
              FriendsOverviewWidget(),
              Expanded(child: NotificationsCard()),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: [Expanded(child: ChatListCard())],
          ),
        ),
      ],
    );
  }
}

class _DashboardGridNarrow extends HookConsumerWidget {
  const _DashboardGridNarrow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    return Column(
      spacing: 16,
      children: [
        if (userInfo.value != null && userInfo.value?.activatedAt == null)
          AccountUnactivatedCard(),
        CheckInWidget(margin: EdgeInsets.zero),
        FortuneCard(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: PostFeaturedList(),
        ),
        FriendsOverviewWidget(),
        NotificationsCard(),
        ChatListCard(),
        Card(
          margin: EdgeInsets.zero,
          child: FortuneGraphWidget(
            events: ref.watch(
              eventCalendarProvider(
                EventCalendarQuery(
                  uname: 'me',
                  year: DateTime.now().year,
                  month: DateTime.now().month,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClockCard extends HookConsumerWidget {
  final bool compact;
  const ClockCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = useState(DateTime.now());
    final timer = useRef<Timer?>(null);
    final nextNotableDay = ref.watch(nextNotableDayProvider);

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
                      Row(
                        spacing: 5,
                        children: [
                          Text('notableDayNext')
                              .tr(
                                args: [
                                  nextNotableDay.value?.localName ?? 'idk',
                                ],
                              )
                              .fontSize(12),
                          if (nextNotableDay.value != null)
                            SlideCountdown(
                              decoration: const BoxDecoration(),
                              style: const TextStyle(fontSize: 12),
                              separatorStyle: const TextStyle(fontSize: 12),
                              padding: EdgeInsets.zero,
                              duration: nextNotableDay.value?.date.difference(
                                DateTime.now(),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              loading: () => const SkeletonNotificationTile(),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (notificationList) {
                if (notificationList.isEmpty) {
                  return Center(child: Text('noNotificationsYet').tr());
                }
                // Get the most recent notification (first in the list)
                final recentNotification = notificationList.first;

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
            loading: () => const Center(child: CircularProgressIndicator()),
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
                      context.pushNamed(
                        'chatRoom',
                        pathParameters: {'id': room.id},
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FortuneCard extends HookWidget {
  const FortuneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final fortune = useMemoized(() {
      const fortunes = [
        {'text': '有的人活着，但他已经死了。', 'author': '—— 鲁迅'},
        {'text': '天行健，君子以自强不息。', 'author': '—— 《周易》'},
        {'text': '路漫漫其修远兮，吾将上下而求索。', 'author': '—— 屈原'},
        {'text': '学海无涯苦作舟。', 'author': '—— 韩愈'},
        {'text': '天道酬勤。', 'author': '—— 古语'},
        {'text': '书山有路勤为径，学海无涯苦作舟。', 'author': '—— 韩愈'},
        {'text': '莫等闲，白了少年头，空悲切。', 'author': '—— 岳飞'},
        {
          'text': 'The best way to predict the future is to create it.',
          'author': '— Peter Drucker',
        },
        {'text': 'Fortune favors the bold.', 'author': '— Virgil'},
        {
          'text': 'A journey of a thousand miles begins with a single step.',
          'author': '— Lao Tzu',
        },
        {
          'text': 'The only way to do great work is to love what you do.',
          'author': '— Steve Jobs',
        },
        {
          'text': 'Believe you can and you\'re halfway there.',
          'author': '— Theodore Roosevelt',
        },
        {
          'text':
              'The future belongs to those who believe in the beauty of their dreams.',
          'author': '— Eleanor Roosevelt',
        },
      ];
      return fortunes[math.Random().nextInt(fortunes.length)];
    });

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              fortune['text']!,
              maxLines: 2,
              overflow: TextOverflow.fade,
            ),
          ),
          Text(fortune['author']!).bold(),
        ],
      ).padding(horizontal: 16),
    ).height(48);
  }
}
