import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/main.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

class AppNotificationToast extends HookConsumerWidget {
  const AppNotificationToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(appNotificationsProvider);

    // Create a global key for AnimatedList
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());

    // Track visual notification count (including those being animated out)
    final visualCount = useState(notifications.length);

    // Track notifications being removed to manage visual count
    final animatingOutIds = useState<Set<String>>({});

    // Track previous notifications to detect changes
    final previousNotifications = usePrevious(notifications) ?? [];

    // Handle notification changes
    useEffect(() {
      final currentIds = notifications.map((n) => n.data.id).toSet();
      final previousIds = previousNotifications.map((n) => n.data.id).toSet();

      // Find new notifications (added)
      final newIds = currentIds.difference(previousIds);

      // Update visual count for new notifications
      if (newIds.isNotEmpty) {
        visualCount.value += newIds.length;
      }

      // Insert new notifications with animation
      for (final id in newIds) {
        final index = notifications.indexWhere((n) => n.data.id == id);
        if (index != -1 &&
            listKey.currentState != null &&
            index >= 0 &&
            index <= notifications.length) {
          try {
            listKey.currentState!.insertItem(
              index,
              duration: const Duration(milliseconds: 150),
            );
          } catch (e) {
            // Log error but don't crash the app
            debugPrint('Error inserting notification: $e');
          }
        }
      }

      return null;
    }, [notifications]);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 50,
      left: 16,
      right: 16,
      child: SizedBox(
        // Use visualCount instead of notifications.length for height calculation
        height: visualCount.value * 80,
        child: AnimatedList(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          key: listKey,
          initialItemCount: notifications.length,
          itemBuilder: (context, index, animation) {
            // Safely access notifications with bounds check
            if (index >= notifications.length) {
              return const SizedBox.shrink(); // Return empty widget if out of bounds
            }

            final notification = notifications[index];
            final now = DateTime.now();
            final createdAt = notification.createdAt ?? now;
            final duration =
                notification.duration ?? const Duration(seconds: 5);
            final elapsedTime = now.difference(createdAt);
            final remainingTime = duration - elapsedTime;
            final progress =
                1.0 -
                (remainingTime.inMilliseconds / duration.inMilliseconds).clamp(
                  0.0,
                  1.0,
                ); // Ensure progress is clamped

            return SizeTransition(
              sizeFactor: animation.drive(
                CurveTween(curve: Curves.fastLinearToSlowEaseIn),
              ),
              child: _NotificationCard(
                notification: notification,
                progress: progress.clamp(0.0, 1.0),
                onDismiss: () {
                  // Find the current index before removal
                  final currentIndex = notifications.indexWhere(
                    (n) => n.data.id == notification.data.id,
                  );

                  // Add to animating out set
                  final notificationId = notification.data.id;
                  if (!animatingOutIds.value.contains(notificationId)) {
                    animatingOutIds.value = {
                      ...animatingOutIds.value,
                      notificationId,
                    };
                  }

                  if (currentIndex != -1 &&
                      listKey.currentState != null &&
                      currentIndex >= 0 &&
                      currentIndex < notifications.length) {
                    try {
                      // Remove the item with animation
                      listKey.currentState!.removeItem(
                        currentIndex,
                        (context, animation) => SizeTransition(
                          sizeFactor: animation.drive(
                            CurveTween(curve: Curves.fastLinearToSlowEaseIn),
                          ),
                          child: _NotificationCard(
                            notification: notification,
                            progress: progress.clamp(0.0, 1.0),
                            onDismiss:
                                () {}, // Empty because it's being removed
                          ),
                        ),
                        duration: const Duration(milliseconds: 150),
                        // When animation completes, update the visual count
                      );

                      // Schedule decrementing the visual count after animation completes
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (animatingOutIds.value.contains(notificationId)) {
                          visualCount.value =
                              visualCount.value > 0 ? visualCount.value - 1 : 0;
                          animatingOutIds.value =
                              animatingOutIds.value
                                  .where((id) => id != notificationId)
                                  .toSet();
                        }
                      });
                    } catch (e) {
                      // Log error but don't crash the app
                      log('[Notification] Error removing notification: $e');
                      // Still update visual count in case of error
                      visualCount.value =
                          visualCount.value > 0 ? visualCount.value - 1 : 0;
                      animatingOutIds.value =
                          animatingOutIds.value
                              .where((id) => id != notificationId)
                              .toSet();
                    }
                  }

                  // Actually remove from state
                  ref
                      .read(appNotificationsProvider.notifier)
                      .removeNotification(notification);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends HookConsumerWidget {
  final AppNotification notification;
  final double progress;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.progress,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use state to track the current progress for smooth animation
    final progressState = useState(progress);

    // Use effect to update progress smoothly
    useEffect(() {
      if (progress < 1.0) {
        // Update progress every 16ms (roughly 60fps) for smooth animation
        final timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
          final now = DateTime.now();
          final createdAt = notification.createdAt ?? now;
          final duration = notification.duration ?? const Duration(seconds: 5);
          final elapsedTime = now.difference(createdAt);
          final remainingTime = duration - elapsedTime;
          final newProgress = (1.0 -
                  (remainingTime.inMilliseconds / duration.inMilliseconds))
              .clamp(0.0, 1.0);

          progressState.value = newProgress;

          // Auto-dismiss when complete
          if (newProgress >= 1.0) {
            onDismiss();
          }
        });

        return timer.cancel;
      }
      return null;
    }, [notification.createdAt, notification.duration]);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: () {
          if (notification.data.meta['action_uri'] != null) {
            var uri = notification.data.meta['action_uri'] as String;
            if (uri.startsWith('/')) {
              // In-app routes
              appRouter.pushPath(notification.data.meta['action_uri']);
            } else {
              // External URLs
              launchUrlString(uri);
            }
            onDismiss();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            if (progressState.value > 0 && progressState.value < 1.0)
              AnimatedBuilder(
                animation: progressState,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    value: 1.0 - progressState.value,
                    backgroundColor: Colors.transparent,
                    color: Theme.of(context).colorScheme.tertiary,
                    minHeight: 3,
                    stopIndicatorColor: Colors.transparent,
                    stopIndicatorRadius: 0,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.data.meta['avatar'] != null)
                    ProfilePictureWidget(
                      fileId: notification.data.meta['avatar'],
                      radius: 12,
                    ).padding(right: 12, top: 2)
                  else if (notification.icon != null)
                    Icon(
                      notification.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ).padding(right: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.data.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (notification.data.content.isNotEmpty)
                          Text(
                            notification.data.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (notification.data.subtitle.isNotEmpty)
                          Text(
                            notification.data.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.close, size: 18),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification({
    required SnNotification data,
    @JsonKey(ignore: true) IconData? icon,
    @JsonKey(ignore: true) Duration? duration,
    @Default(null) DateTime? createdAt,
    @Default(false) @JsonKey(ignore: true) bool isAnimatingOut,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

// Using riverpod_generator for cleaner provider code
@riverpod
class AppNotifications extends _$AppNotifications {
  StreamSubscription? _subscription;

  @override
  List<AppNotification> build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _initWebSocketListener();
    return [];
  }

  void _initWebSocketListener() {
    final service = ref.read(websocketProvider);
    _subscription = service.dataStream.listen((packet) {
      // Handle notification packets
      if (packet.type == 'notifications.new') {
        try {
          final data = SnNotification.fromJson(packet.data!);

          IconData? icon;
          switch (data.topic) {
            case 'general':
            default:
              icon = Symbols.info;
              break;
          }

          addNotification(
            AppNotification(
              data: data,
              icon: icon,
              createdAt: data.createdAt.toLocal(),
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (e) {
          log('[Notification] Error processing notification: $e');
        }
      }
    });
  }

  void addNotification(AppNotification notification) {
    // Create a new notification with createdAt if not provided
    final newNotification =
        notification.createdAt == null
            ? notification.copyWith(createdAt: DateTime.now())
            : notification;

    // Add to state
    state = [...state, newNotification];

    // Auto-remove notification after duration
    final duration = newNotification.duration ?? const Duration(seconds: 5);
    Future.delayed(duration, () {
      // Find the notification in the current state
      final notificationToRemove = state.firstWhereOrNull(
        (n) => n.data.id == newNotification.data.id,
      );

      // Only proceed if the notification still exists in state
      if (notificationToRemove != null) {
        // Call removeNotification which will handle the animation
        removeNotification(notificationToRemove);
      }
    });
  }

  // Map to track notifications that are being animated out
  final Map<String, bool> _animatingNotifications = {};

  // Map to track which notifications should animate out
  final Map<String, bool> _animatingOutNotifications = {};

  void removeNotification(AppNotification notification) {
    final notificationId = notification.data.id;

    // If this notification is already being removed, don't do anything
    if (_animatingNotifications[notificationId] == true) {
      return;
    }

    // Mark this notification as being removed
    _animatingNotifications[notificationId] = true;

    // Remove from state immediately - AnimatedList handles the animation
    state = state.where((n) => n.data.id != notificationId).toList();

    // Clean up tracking
    _animatingNotifications.remove(notificationId);
    _animatingOutNotifications.remove(notificationId);
  }

  // Helper method to check if a notification should animate out
  bool isAnimatingOut(String notificationId) {
    return _animatingOutNotifications[notificationId] == true;
  }

  // Helper method to manually add a notification for testing
  void showNotification({
    required SnNotification data,
    IconData? icon,
    Duration? duration,
  }) {
    addNotification(
      AppNotification(
        data: data,
        icon: icon,
        duration: duration,
        createdAt: data.createdAt,
      ),
    );
  }
}
