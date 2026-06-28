import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/notification.dart';
import 'package:island/notifications/notification_item.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';

class SnNotificationOverlay extends HookConsumerWidget {
  const SnNotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationStateProvider);

    return NotificationOverlay<NotificationItem>(
      items: notifications,
      itemBuilder: (context, item, onDismiss, isDesktop, progress) =>
          NotificationItemWidget(
            item: item,
            onDismiss: onDismiss,
            isDesktop: isDesktop,
            progress: progress,
          ),
      onDismiss: (item) {
        ref.read(notificationStateProvider.notifier).dismiss(item.id);
      },
      onRemove: (item) {
        ref.read(notificationStateProvider.notifier).remove(item.id);
      },
    );
  }
}
