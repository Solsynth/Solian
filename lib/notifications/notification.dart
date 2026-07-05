import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
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
              Text('loading'.tr()).fontSize(11),
              Skeleton.ignore(child: Text('·').fontSize(11).bold()),
              Text('now'.tr()).fontSize(11),
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
      final client = ref.read(solarNetworkClientProvider);
      return await client.notifications.getUnreadCount(
        app: kNotificationTenantAppId,
      );
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
      final client = ref.read(solarNetworkClientProvider);
      final count = await client.notifications.getUnreadCount(
        app: kNotificationTenantAppId,
      );
      state = AsyncData(count);
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
    final client = ref.read(solarNetworkClientProvider);
    final response = await client.notifications.getNotifications(
      offset: fetchedCount,
      take: pageSize,
      app: kNotificationTenantAppId,
    );
    totalCount = response.totalCount;
    final notifications = response.items;

    final unreadCount = notifications.where((n) => n.viewedAt == null).length;
    if (ref.mounted) {
      ref.read(notificationUnreadCountProvider.notifier).decrement(unreadCount);
    }

    return notifications;
  }
}

class NotificationModal extends HookConsumerWidget {
  final VoidCallback onDismiss;

  const NotificationModal({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() async {
        await ref.read(notificationUnreadCountProvider.notifier).refresh();
        await ref.read(notificationListProvider.notifier).refresh();
      });
      return null;
    }, []);

    final isLoading = useState(false);

    Future<void> markAllRead() async {
      isLoading.value = true;
      final client = ref.watch(solarNetworkClientProvider);
      await client.notifications.markAllAsRead(app: kNotificationTenantAppId);
      if (!context.mounted) return;
      isLoading.value = false;
      ref.read(notificationListProvider.notifier).refresh();
      ref.watch(notificationUnreadCountProvider.notifier).clear();
    }

    final titleText = 'notifications'.tr();

    return AttentionModalScaffold(
      titleText: titleText,
      onDismiss: onDismiss,
      actions: [
        IconButton(
          onPressed: markAllRead,
          icon: const Icon(Symbols.mark_as_unread),
          tooltip: 'markAllRead'.tr(),
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
              footerSkeletonChild: Skeletonizer(
                enabled: true,
                child: const SkeletonNotificationTile(),
              ),
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

// ==========================================
// Custom App Notifications (POST /api/private/apps/{appId}/notifications)
// ==========================================

/// Request body for sending a custom-app notification.
/// Docs: DysonNetwork/docs/CUSTOM_APP_NOTIFICATIONS.md
class CustomAppNotificationRequest {
  final String topic;
  final String title;
  final String? accountId;
  final List<String>? accountIds;
  final bool broadcastToAll;
  final String? subtitle;
  final String? body;
  final String? actionUri;
  final String? pushType;
  final bool? isSilent;
  final bool? isSavable;
  final Map<String, dynamic>? meta;

  CustomAppNotificationRequest({
    required this.topic,
    required this.title,
    this.accountId,
    this.accountIds,
    this.broadcastToAll = false,
    this.subtitle,
    this.body,
    this.actionUri,
    this.pushType,
    this.isSilent,
    this.isSavable,
    this.meta,
  }) : assert(
         broadcastToAll || accountId != null || (accountIds?.isNotEmpty == true),
         'Must provide at least one of: broadcastToAll, accountId, or accountIds',
       );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'topic': topic,
      'title': title,
    };
    if (broadcastToAll) data['broadcast_to_all'] = true;
    if (accountId != null) data['account_id'] = accountId;
    if (accountIds?.isNotEmpty == true) {
      data['account_ids'] = accountIds;
    }
    if (subtitle != null) data['subtitle'] = subtitle;
    if (body != null) data['body'] = body;
    if (actionUri != null) data['action_uri'] = actionUri;
    if (pushType != null) data['push_type'] = pushType;
    if (isSilent != null) data['is_silent'] = isSilent;
    if (isSavable != null) data['is_savable'] = isSavable;
    if (meta != null) data['meta'] = meta;
    return data;
  }
}

/// Response from sending a custom-app notification.
class CustomAppNotificationResponse {
  final int sent;
  final String scope;
  final bool broadcastToAll;

  CustomAppNotificationResponse({
    required this.sent,
    required this.scope,
    required this.broadcastToAll,
  });

  factory CustomAppNotificationResponse.fromJson(Map<String, dynamic> json) {
    return CustomAppNotificationResponse(
      sent: (json['sent'] as num).toInt(),
      scope: json['scope'] as String,
      broadcastToAll: json['broadcast_to_all'] as bool,
    );
  }
}

/// Sends a custom-app notification using the app's API key.
///
/// Uses X-Api-Key auth (not Bearer). See CUSTOM_APP_NOTIFICATIONS.md.
Future<CustomAppNotificationResponse> sendCustomAppNotification({
  required String serverUrl,
  required String appId,
  required String apiKey,
  required CustomAppNotificationRequest request,
}) async {
  final dio = Dio(BaseOptions(
    baseUrl: serverUrl,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Api-Key': apiKey,
    },
  ));
  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/private/apps/$appId/notifications',
      data: request.toJson(),
    );
    return CustomAppNotificationResponse.fromJson(response.data!);
  } finally {
    dio.close();
  }
}

/// Riverpod provider that creates a Dio instance for custom-app notification requests.
@riverpod
Dio customAppNotificationDio(Ref ref, String apiKey) {
  final serverUrl = ref.watch(serverUrlProvider);
  final dio = Dio(BaseOptions(
    baseUrl: serverUrl,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Api-Key': apiKey,
    },
  ));
  ref.onDispose(() => dio.close());
  return dio;
}
