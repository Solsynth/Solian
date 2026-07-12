import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island_ui_foundation/src/responsive.dart';
import 'package:styled_widget/styled_widget.dart';

const int kNarrowNotificationVisibleLimit = 5;

abstract interface class OverlayNotificationItem {
  String get id;
  Duration get duration;
  bool get dismissed;
}

typedef NotificationItemBuilder<T extends OverlayNotificationItem> =
    Widget Function(
      BuildContext context,
      T item,
      VoidCallback onDismiss,
      bool isDesktop,
      Animation<double> progress,
    );

typedef NotificationDismissCallback<T extends OverlayNotificationItem> =
    void Function(T item);

typedef NotificationRemoveCallback<T extends OverlayNotificationItem> =
    void Function(T item);

class NotificationOverlay<T extends OverlayNotificationItem>
    extends HookWidget {
  const NotificationOverlay({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onDismiss,
    required this.onRemove,
  });

  final List<T> items;
  final NotificationItemBuilder<T> itemBuilder;
  final NotificationDismissCallback<T> onDismiss;
  final NotificationRemoveCallback<T> onRemove;

  @override
  Widget build(BuildContext context) {
    final isPaused = useState(false);
    final isDesktop = isWideScreen(context);
    final devicePadding = MediaQuery.paddingOf(context);
    final topOffset =
        devicePadding.top +
        ((!kIsWeb &&
                (Platform.isMacOS || Platform.isLinux || Platform.isWindows))
            ? 40
            : 16);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemWidth = isDesktop ? 420.0 : MediaQuery.sizeOf(context).width;

    // Own Stack so Positioned works whether this widget sits under a parent
    // Stack or is used as a loose child (e.g. Overlay entry / SizedBox).
    if (isDesktop) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topRight,
              child: MouseRegion(
                opaque: false,
                hitTestBehavior: HitTestBehavior.deferToChild,
                onEnter: (_) => isPaused.value = true,
                onExit: (_) => isPaused.value = false,
                child: SizedBox(
                  width: itemWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: items.asMap().entries.map((entry) {
                        final item = entry.value;
                        return AnimatedNotificationItem<T>(
                          key: Key(item.id),
                          item: item,
                          itemBuilder: itemBuilder,
                          isDesktop: true,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          pauseAutoDismiss: isPaused.value,
                          onDismiss: () => onDismiss(item),
                          onRemove: () => onRemove(item),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      final visibleItems = items.take(kNarrowNotificationVisibleLimit).toList();
      final heldCount = items.length - visibleItems.length;
      const double overlap = 20.0;
      final calculatedHeight = overlap * (visibleItems.length - 1) + 120.0;

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: MouseRegion(
              opaque: false,
              hitTestBehavior: HitTestBehavior.deferToChild,
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
                      ...visibleItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return AnimatedPositioned(
                          key: ValueKey(item.id),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          top: index * overlap + (heldCount > 0 ? 28 / 2 : 0),
                          left: 16,
                          right: 16,
                          child: AnimatedNotificationItem<T>(
                            item: item,
                            itemBuilder: itemBuilder,
                            isDesktop: false,
                            showStackSeparation: index > 0,
                            pauseAutoDismiss: isPaused.value,
                            onDismiss: () => onDismiss(item),
                            onRemove: () => onRemove(item),
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
                                  onTap: () {
                                    for (final item in items) {
                                      onDismiss(item);
                                    }
                                  },
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('empty-badge'),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).width(itemWidth).alignment(Alignment.topCenter),
            ),
          ),
        ],
      );
    }
  }
}

class AnimatedNotificationItem<T extends OverlayNotificationItem>
    extends HookWidget {
  const AnimatedNotificationItem({
    super.key,
    required this.item,
    required this.itemBuilder,
    required this.onDismiss,
    required this.onRemove,
    required this.isDesktop,
    this.margin,
    this.showStackSeparation = false,
    this.pauseAutoDismiss = false,
  });

  final T item;
  final NotificationItemBuilder<T> itemBuilder;
  final VoidCallback onDismiss;
  final VoidCallback onRemove;
  final bool isDesktop;
  final EdgeInsets? margin;
  final bool showStackSeparation;
  final bool pauseAutoDismiss;

  @override
  Widget build(BuildContext context) {
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
          onRemove();
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
                child: itemBuilder(
                  context,
                  item,
                  onDismiss,
                  isDesktop,
                  progressAnimation,
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
