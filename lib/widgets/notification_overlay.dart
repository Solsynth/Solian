import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/notification_item.dart';

class NotificationOverlay extends HookConsumerWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationStateProvider);
    final isDesktop = isWideScreen(context);
    final safeTop = MediaQuery.of(context).padding.top;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isDesktop) {
      return Positioned(
        top: safeTop + 16,
        right: 16,
        left: null,
        bottom: null,
        width: 420,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: notifications.reversed.toList().asMap().entries.map((
            entry,
          ) {
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NotificationItemWidget(
                item: item,
                isDesktop: true,
                onDismiss: () {
                  ref.read(notificationStateProvider.notifier).remove(item.id);
                },
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Positioned(
        top: safeTop + 12,
        left: 16,
        right: 16,
        bottom: null,
        child: Stack(
          children: notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Positioned(
              top: index * 12.0,
              left: 0,
              right: 0,
              child: NotificationItemWidget(
                item: item,
                isDesktop: false,
                onDismiss: () {
                  ref.read(notificationStateProvider.notifier).remove(item.id);
                },
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}
