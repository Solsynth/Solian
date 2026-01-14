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

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: isDesktop
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: notifications.asMap().entries.map((entry) {
            final item = entry.value;
            return AnimatedNotificationItem(
              key: Key(item.id),
              item: item,
              isDesktop: isDesktop,
              onDismiss: () {
                ref.read(notificationStateProvider.notifier).remove(item.id);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AnimatedNotificationItem extends HookConsumerWidget {
  final NotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;

  const AnimatedNotificationItem({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    final isDismissed = useState(false);

    final slideTween = Tween<Offset>(
      begin: isDesktop ? Offset(1.0, 0.0) : Offset(0.0, -1.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    useEffect(() {
      animationController.forward();
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
      position: slideTween.animate(animationController),
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.only(bottom: 12, right: 16)
            : const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        child: NotificationItemWidget(
          item: item,
          isDesktop: isDesktop,
          onDismiss: () {},
        ).width(isDesktop ? 420 : MediaQuery.sizeOf(context).width - 40),
      ),
    );
  }
}
