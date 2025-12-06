import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'notification.g.dart';

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

final notificationListProvider = AsyncNotifierProvider(
  NotificationListNotifier.new,
);

class NotificationListNotifier extends AsyncNotifier<List<SnNotification>>
    with AsyncPaginationController<SnNotification> {
  static const int pageSize = 5;

  @override
  Future<List<SnNotification>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/ring/notifications',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final notifications =
        response.data
            .map((json) => SnNotification.fromJson(json))
            .cast<SnNotification>()
            .toList();

    final unreadCount = notifications.where((n) => n.viewedAt == null).length;
    ref.read(notificationUnreadCountProvider.notifier).decrement(unreadCount);

    return notifications;
  }
}

class NotificationSheet extends HookConsumerWidget {
  const NotificationSheet({super.key});

  IconData _getNotificationIcon(String topic) {
    switch (topic) {
      case 'post.replies':
        return Symbols.reply;
      case 'wallet.transactions':
        return Symbols.account_balance_wallet;
      case 'relationships.friends.request':
        return Symbols.person_add;
      case 'invites.chat':
        return Symbols.chat;
      case 'invites.realm':
        return Symbols.domain;
      case 'auth.login':
        return Symbols.login;
      case 'posts.new':
        return Symbols.post_add;
      case 'wallet.orders.paid':
        return Symbols.shopping_bag;
      case 'posts.reactions.new':
        return Symbols.add_reaction;
      default:
        return Symbols.notifications;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refresh unread count when sheet opens to sync across devices
    ref.read(notificationUnreadCountProvider.notifier).refresh();

    Future<void> markAllRead() async {
      showLoadingModal(context);
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.post('/ring/notifications/all/read');
      if (!context.mounted) return;
      hideLoadingModal(context);
      ref.invalidate(notificationListProvider);
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
      child: PaginationList(
        provider: notificationListProvider,
        notifier: notificationListProvider.notifier,
        itemBuilder: (context, index, notification) {
          final pfp = notification.meta['pfp'] as String?;
          final images = notification.meta['images'] as List?;
          final imageIds = images?.cast<String>() ?? [];

          return ListTile(
            isThreeLine: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading:
                pfp != null
                    ? ProfilePictureWidget(fileId: pfp, radius: 20)
                    : CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        _getNotificationIcon(notification.topic),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
            title: Text(notification.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (notification.subtitle.isNotEmpty)
                  Text(notification.subtitle).bold(),
                Row(
                  spacing: 6,
                  children: [
                    Text(
                      DateFormat().format(notification.createdAt.toLocal()),
                    ).fontSize(11),
                    Text('·').fontSize(11).bold(),
                    Text(
                      RelativeTime(
                        context,
                      ).format(notification.createdAt.toLocal()),
                    ).fontSize(11),
                  ],
                ).opacity(0.75).padding(bottom: 4),
                MarkdownTextContent(
                  content: notification.content,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                if (imageIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          imageIds.map((imageId) {
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
            trailing:
                notification.viewedAt != null
                    ? null
                    : Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
            onTap: () {
              if (notification.meta['action_uri'] != null) {
                var uri = notification.meta['action_uri'] as String;
                if (uri.startsWith('/')) {
                  // In-app routes
                  rootNavigatorKey.currentContext?.push(
                    notification.meta['action_uri'],
                  );
                } else {
                  // External URLs
                  launchUrlString(uri);
                }
              }
            },
          );
        },
      ),
    );
  }
}
