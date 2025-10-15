import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
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
}

@riverpod
class NotificationListNotifier extends _$NotificationListNotifier
    with CursorPagingNotifierMixin<SnNotification> {
  static const int _pageSize = 5;

  @override
  Future<CursorPagingData<SnNotification>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnNotification>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/ring/notifications',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final notifications =
        data.map((json) => SnNotification.fromJson(json)).toList();

    final hasMore = offset + notifications.length < total;
    final nextCursor =
        hasMore ? (offset + notifications.length).toString() : null;
    final unreadCount = notifications.where((n) => n.viewedAt == null).length;
    ref
        .read(notificationUnreadCountNotifierProvider.notifier)
        .decrement(unreadCount);

    return CursorPagingData(
      items: notifications,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class NotificationSheet extends HookConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> markAllRead() async {
      showLoadingModal(context);
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.post('/ring/notifications/all/read');
      if (!context.mounted) return;
      hideLoadingModal(context);
      ref.invalidate(notificationListNotifierProvider);
      ref.watch(notificationUnreadCountNotifierProvider.notifier).clear();
    }

    return SheetScaffold(
      titleText: 'notifications'.tr(),
      actions: [
        IconButton(
          onPressed: markAllRead,
          icon: const Icon(Symbols.mark_as_unread),
        ),
      ],
      child: PagingHelperView(
        provider: notificationListNotifierProvider,
        futureRefreshable: notificationListNotifierProvider.future,
        notifierRefreshable: notificationListNotifierProvider.notifier,
        contentBuilder:
            (data, widgetCount, endItemView) => ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widgetCount,
              itemBuilder: (context, index) {
                if (index == widgetCount - 1) {
                  return endItemView;
                }

                final notification = data.items[index];
                return ListTile(
                  isThreeLine: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                            DateFormat().format(
                              notification.createdAt.toLocal(),
                            ),
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
                        textStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
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
      ),
    );
  }
}
