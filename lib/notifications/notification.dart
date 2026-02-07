import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/network.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/notifications/notification_tile.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:styled_widget/styled_widget.dart';

part 'notification.g.dart';

class SkeletonNotificationTile extends StatelessWidget {
  const SkeletonNotificationTile({super.key});

  @override
  Widget build(BuildContext context) {
    const fakeTitle = 'New notification';
    const fakeSubtitle = 'You have a new message from someone';
    const fakeContent =
        'This is a preview of the notification content. It may contain formatted text.';
    const List<String> fakeImageIds = []; // Empty list for no images
    const String? fakePfp = null; // No profile picture

    return ListTile(
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: fakePfp != null
          ? ProfilePictureWidget(file: null, radius: 20)
          : CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Symbols.notifications,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
      title: const Text(fakeTitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(fakeSubtitle).bold(),
          Row(
            spacing: 6,
            children: [
              Text('Loading...').fontSize(11),
              Skeleton.ignore(child: Text('·').fontSize(11).bold()),
              Text('Now').fontSize(11),
            ],
          ).opacity(0.75).padding(bottom: 4),
          MarkdownTextContent(
            content: fakeContent,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          if (fakeImageIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fakeImageIds.map((imageId) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CloudImageWidget(
                        fileId: imageId,
                        aspectRatio: 1,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {},
    );
  }
}

@riverpod
class NotificationUnreadCountNotifier
    extends _$NotificationUnreadCountNotifier {
  StreamSubscription<WebSocketPacket>? _subscription;

  @override
  Future<int> build() async {
    // Subscribe to websocket events when this provider is built
    _subscribeToWebSocket();

    // Dispose the subscription when this provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/ring/notifications/count');
      return (response.data as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  void _subscribeToWebSocket() {
    final webSocketService = ref.read(websocketProvider);
    _subscription = webSocketService.dataStream.listen((packet) {
      if (packet.type == 'notifications.new' && packet.data != null) {
        final notification = SnNotification.fromJson(packet.data!);
        if (notification.topic != 'messages.new') _incrementCounter();
      }
    });
  }

  Future<void> _incrementCounter() async {
    final current = await future;
    state = AsyncData(current + 1);
  }

  Future<void> decrement(int count) async {
    final current = await future;
    state = AsyncData(math.max(current - count, 0));
  }

  void clear() async {
    state = AsyncData(0);
  }

  Future<void> refresh() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/ring/notifications/count');
      state = AsyncData((response.data as num).toInt());
    } catch (_) {
      // Keep the current state if refresh fails
    }
  }
}

final notificationListProvider = AsyncNotifierProvider.autoDispose(
  NotificationListNotifier.new,
);

class NotificationListNotifier
    extends AsyncNotifier<PaginationState<SnNotification>>
    with AsyncPaginationController<SnNotification> {
  static const int pageSize = 5;

  @override
  FutureOr<PaginationState<SnNotification>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnNotification>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/ring/notifications',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final notifications = response.data
        .map((json) => SnNotification.fromJson(json))
        .cast<SnNotification>()
        .toList();

    final unreadCount = notifications.where((n) => n.viewedAt == null).length;
    if (ref.mounted) {
      ref.read(notificationUnreadCountProvider.notifier).decrement(unreadCount);
    }

    return notifications;
  }
}

class NotificationSheet extends HookConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refresh unread count when sheet opens to sync across devices
    useEffect(() {
      Future(() {
        ref.read(notificationUnreadCountProvider.notifier).refresh();
      });
      return null;
    }, []);

    final isLoading = useState(false);

    Future<void> markAllRead() async {
      isLoading.value = true;
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.post('/ring/notifications/all/read');
      if (!context.mounted) return;
      isLoading.value = false;
      ref.read(notificationListProvider.notifier).refresh();
      ref.watch(notificationUnreadCountProvider.notifier).clear();
    }

    return SheetScaffold(
      titleText: 'notifications'.tr(),
      actions: [
        IconButton(
          onPressed: markAllRead,
          icon: const Icon(Symbols.mark_as_unread),
        ),
      ],
      child: Column(
        children: [
          if (isLoading.value)
            LinearProgressIndicator(
              minHeight: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          Expanded(
            child: PaginationList(
              provider: notificationListProvider,
              notifier: notificationListProvider.notifier,
              footerSkeletonChild: const SkeletonNotificationTile(),
              itemBuilder: (context, index, notification) {
                return NotificationTile(notification: notification);
              },
            ),
          ),
        ],
      ),
    );
  }
}
