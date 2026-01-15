import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/notification_item.dart';
import 'package:styled_widget/styled_widget.dart';

class NotificationOverlay extends HookConsumerWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationStateProvider);
    final isDesktop = isWideScreen(context);
    final devicePadding = MediaQuery.paddingOf(context);
    final topOffset =
        devicePadding.top +
        ((!kIsWeb &&
                (Platform.isMacOS || Platform.isLinux || Platform.isWindows))
            ? 40
            : 16);

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemWidth = isDesktop ? 420.0 : MediaQuery.sizeOf(context).width;

    if (isDesktop) {
      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: notifications.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return AnimatedNotificationItem(
                key: Key(item.id),
                item: item,
                isDesktop: true,
                index: index,
                totalNotifications: notifications.length,
                onDismiss: () {
                  ref.read(notificationStateProvider.notifier).remove(item.id);
                },
              );
            }).toList(),
          ),
        ).width(itemWidth).alignment(Alignment.topRight),
      );
    } else {
      // Non-desktop: use Stack with overlapping
      const double notificationHeight = 80.0;
      const double overlap = 20.0;
      final stackHeight =
          notificationHeight + (notifications.length - 1) * overlap;

      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: stackHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: notifications.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Positioned(
                  top: index * overlap,
                  left: 16,
                  right: 16,
                  child: AnimatedNotificationItem(
                    key: Key(item.id),
                    item: item,
                    isDesktop: false,
                    index: index,
                    totalNotifications: notifications.length,
                    onDismiss: () {
                      ref
                          .read(notificationStateProvider.notifier)
                          .remove(item.id);
                    },
                  ).clipRRect(all: 8),
                );
              }).toList(),
            ),
          ),
        ).width(itemWidth).alignment(Alignment.topCenter),
      );
    }
  }
}

class AnimatedNotificationItem extends HookConsumerWidget {
  final NotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;
  final int index;
  final int totalNotifications;

  const AnimatedNotificationItem({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
    required this.index,
    required this.totalNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    final progressController = useAnimationController(duration: item.duration);
    final isDismissed = useState(false);

    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    final slideTween = Tween<Offset>(
      begin: isDesktop ? Offset(1.0, 0.0) : Offset(0.0, -1.0),
      end: Offset.zero,
    );

    final progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(progressController);

    useEffect(() {
      animationController.forward();
      progressController.forward();
      return null;
    }, []);

    useEffect(() {
      if (isDismissed.value) return null;
      final timer = Timer(item.duration, () async {
        if (!isDismissed.value) {
          isDismissed.value = true;
          await animationController.reverse();
          onDismiss();
        }
      });
      return () => timer.cancel();
    }, [item.duration, isDismissed.value]);

    return SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: SizeTransition(
        sizeFactor: curvedAnimation,
        axis: Axis.vertical,
        child: NotificationItemWidget(
          item: item,
          isDesktop: isDesktop,
          index: index,
          totalNotifications: totalNotifications,
          onDismiss: () {},
          progress: progressAnimation,
        ),
      ),
    );
  }
}
