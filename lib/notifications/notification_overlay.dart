import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/notifications/notification_item.dart';
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
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: notifications.asMap().entries.map((entry) {
              final item = entry.value;
              return AnimatedNotificationItem(
                key: Key(item.id),
                item: item,
                isDesktop: true,
                margin: EdgeInsets.symmetric(horizontal: 16),
                onDismiss: () {
                  ref.read(notificationStateProvider.notifier).dismiss(item.id);
                },
              );
            }).toList(),
          ),
        ).width(itemWidth).alignment(Alignment.topRight),
      );
    } else {
      // Non-desktop: use Stack with overlapping
      const double overlap = 20.0;

      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Stack(
              alignment: Alignment.topCenter,
              children: notifications.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Positioned(
                  top: index * overlap,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 4.0 + index * 2.0),
                      ],
                    ),
                    child: AnimatedNotificationItem(
                      key: Key(item.id),
                      item: item,
                      isDesktop: false,
                      onDismiss: () {
                        ref
                            .read(notificationStateProvider.notifier)
                            .dismiss(item.id);
                      },
                    ),
                  ),
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
  final EdgeInsets? margin;

  const AnimatedNotificationItem({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    final progressController = useAnimationController(duration: item.duration);

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
      if (item.dismissed) {
        animationController.reverse().then((_) {
          ref.read(notificationStateProvider.notifier).remove(item.id);
        });
      }
      return null;
    }, [item.dismissed]);

    return SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: SizeTransition(
        sizeFactor: curvedAnimation,
        axis: Axis.vertical,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: NotificationItemWidget(
            item: item,
            isDesktop: isDesktop,
            onDismiss: onDismiss,
            progress: progressAnimation,
          ),
        ),
      ),
    );
  }
}