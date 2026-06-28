import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/notifications/notification_item.dart';
import 'package:styled_widget/styled_widget.dart';

const int kNarrowNotificationVisibleLimit = 5;

class NotificationOverlay extends HookConsumerWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = useState(false);
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
        child: MouseRegion(
          onEnter: (_) => isPaused.value = true,
          onExit: (_) => isPaused.value = false,
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  pauseAutoDismiss: isPaused.value,
                  onDismiss: () {
                    ref
                        .read(notificationStateProvider.notifier)
                        .dismiss(item.id);
                  },
                );
              }).toList(),
            ),
          ).width(itemWidth).alignment(Alignment.topRight),
        ),
      );
    } else {
      final visibleNotifications = notifications
          .take(kNarrowNotificationVisibleLimit)
          .toList();
      final heldCount = notifications.length - visibleNotifications.length;
      // Non-desktop: use Stack with overlapping
      const double overlap = 20.0;
      // Calculate actual height needed for notifications
      // Each notification has some height, and they overlap
      // We use a reasonable max height estimate (overlap * count + single notification height)
      final calculatedHeight =
          overlap * (visibleNotifications.length - 1) + 120.0;

      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: MouseRegion(
          onEnter: (_) => isPaused.value = true,
          onExit: (_) => isPaused.value = false,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: calculatedHeight + (heldCount > 0 ? 28 : 0),
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  ...visibleNotifications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return AnimatedPositioned(
                      key: ValueKey(item.id),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      top: index * overlap + (heldCount > 0 ? 28 / 2 : 0),
                      left: 16,
                      right: 16,
                      child: AnimatedNotificationItem(
                        item: item,
                        isDesktop: false,
                        showStackSeparation: index > 0,
                        pauseAutoDismiss: isPaused.value,
                        onDismiss: () {
                          ref
                              .read(notificationStateProvider.notifier)
                              .dismiss(item.id);
                        },
                      ),
                    );
                  }),
                  Positioned(
                    top: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      reverseDuration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.88,
                              end: 1,
                            ).animate(animation),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: heldCount > 0
                          ? _HeldNotificationBadge(
                              key: ValueKey(heldCount),
                              count: heldCount,
                              onTap: () => ref
                                  .read(notificationStateProvider.notifier)
                                  .clear(),
                            )
                          : const SizedBox.shrink(key: ValueKey('empty-badge')),
                    ),
                  ),
                ],
              ),
            ),
          ).width(itemWidth).alignment(Alignment.topCenter),
        ),
      );
    }
  }
}

class AnimatedNotificationItem extends HookConsumerWidget {
  final NotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;
  final EdgeInsets? margin;
  final bool showStackSeparation;
  final bool pauseAutoDismiss;

  const AnimatedNotificationItem({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
    this.margin,
    this.showStackSeparation = false,
    this.pauseAutoDismiss = false,
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
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed && !item.dismissed) {
          onDismiss();
        }
      }

      progressController.addStatusListener(listener);
      return () => progressController.removeStatusListener(listener);
    }, []);

    useEffect(() {
      if (item.dismissed) return null;
      if (pauseAutoDismiss) {
        progressController.stop(canceled: false);
      } else if (progressController.status != AnimationStatus.completed) {
        progressController.forward();
      }
      return null;
    }, [pauseAutoDismiss, item.dismissed]);

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isDesktop && showStackSeparation)
                Positioned(
                  top: -10,
                  left: 10,
                  right: 10,
                  height: 16,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.shadow.withOpacity(0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                elevation: 3,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.shadow.withOpacity(0.18),
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: NotificationItemWidget(
                  item: item,
                  isDesktop: isDesktop,
                  onDismiss: onDismiss,
                  progress: progressAnimation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeldNotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _HeldNotificationBadge({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.12),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            '+$count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
