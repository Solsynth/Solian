import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/services/responsive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'app_scaffold.freezed.dart';
part 'app_scaffold.g.dart';

class WindowScaffold extends HookConsumerWidget {
  final Widget child;
  final AppRouter router;
  const WindowScaffold({super.key, required this.child, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final windowButtonColor = WindowButtonColors(
        iconNormal: Theme.of(context).colorScheme.primary,
        mouseOver: Theme.of(context).colorScheme.primaryContainer,
        mouseDown: Theme.of(context).colorScheme.onPrimaryContainer,
        iconMouseOver: Theme.of(context).colorScheme.primary,
        iconMouseDown: Theme.of(context).colorScheme.primary,
      );

      return Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                WindowTitleBarBox(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1 / devicePixelRatio,
                        ),
                      ),
                    ),
                    child: MoveWindow(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment:
                            Platform.isMacOS
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Solar Network',
                              textAlign:
                                  Platform.isMacOS
                                      ? TextAlign.center
                                      : TextAlign.start,
                            ).padding(horizontal: 12, vertical: 5),
                          ),
                          if (!Platform.isMacOS)
                            MinimizeWindowButton(colors: windowButtonColor),
                          if (!Platform.isMacOS)
                            MaximizeWindowButton(colors: windowButtonColor),
                          if (!Platform.isMacOS)
                            CloseWindowButton(
                              colors: windowButtonColor,
                              onPressed: () => appWindow.hide(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
            _WebSocketIndicator(),
            _AppNotificationToast(),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [child, _WebSocketIndicator(), _AppNotificationToast()],
    );
  }
}

final rootScaffoldKey = GlobalKey<ScaffoldState>();

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? bottomNavigationBar;
  final PreferredSizeWidget? bottomSheet;
  final Drawer? drawer;
  final Widget? endDrawer;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final AppBar? appBar;
  final DrawerCallback? onDrawerChanged;
  final DrawerCallback? onEndDrawerChanged;
  final bool? noBackground;

  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.noBackground,
  });

  @override
  Widget build(BuildContext context) {
    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;

    final noBackground = this.noBackground ?? isWideScreen(context);

    final content = Column(
      children: [
        IgnorePointer(
          child: SizedBox(height: appBar != null ? appBarHeight + safeTop : 0),
        ),
        if (body != null) Expanded(child: body!),
      ],
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor:
          noBackground
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
      body:
          noBackground ? content : AppBackground(isRoot: true, child: content),
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      floatingActionButtonLocation: floatingActionButtonLocation,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onEndDrawerChanged,
    );
  }
}

class PageBackButton extends StatelessWidget {
  final Color? color;
  final List<Shadow>? shadows;
  final VoidCallback? onWillPop;
  const PageBackButton({super.key, this.shadows, this.onWillPop, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onWillPop?.call();
        context.router.maybePop();
      },
      icon: Icon(
        color: color,
        (!kIsWeb && (Platform.isMacOS || Platform.isIOS))
            ? Symbols.arrow_back_ios_new
            : Symbols.arrow_back,
        shadows: shadows,
      ),
    );
  }
}

const kAppBackgroundImagePath = 'island_app_background';

final backgroundImageFileProvider = FutureProvider<File?>((ref) async {
  if (kIsWeb) return null;
  final dir = await getApplicationSupportDirectory();
  final path = '${dir.path}/$kAppBackgroundImagePath';
  final file = File(path);
  return file.existsSync() ? file : null;
});

class AppBackground extends ConsumerWidget {
  final Widget child;
  final bool isRoot;

  const AppBackground({super.key, required this.child, this.isRoot = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFileAsync = ref.watch(backgroundImageFileProvider);

    if (isRoot || !isWideScreen(context)) {
      return imageFileAsync.when(
        data: (file) {
          if (file != null) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  color: Theme.of(context).colorScheme.surface,
                  image: DecorationImage(
                    opacity: 0.2,
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
                child: child,
              ),
            );
          }
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: child,
          );
        },
        loading: () => const SizedBox(),
        error:
            (_, _) => Material(
              color: Theme.of(context).colorScheme.surface,
              child: child,
            ),
      );
    }

    return Material(color: Colors.transparent, child: child);
  }
}

class EmptyPageHolder extends HookConsumerWidget {
  const EmptyPageHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBackground =
        ref.watch(backgroundImageFileProvider).valueOrNull != null;
    if (hasBackground) {
      return const SizedBox.shrink();
    }
    return Container(color: Theme.of(context).scaffoldBackgroundColor);
  }
}

class _WebSocketIndicator extends HookConsumerWidget {
  const _WebSocketIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    final user = ref.watch(userInfoProvider);
    final websocketState = ref.watch(websocketStateProvider);
    final indicatorHeight =
        MediaQuery.of(context).padding.top + (isDesktop ? 27.5 : 60);

    Color indicatorColor;
    String indicatorText;

    if (websocketState == WebSocketState.connected()) {
      indicatorColor = Colors.green;
      indicatorText = 'connectionConnected';
    } else if (websocketState == WebSocketState.connecting()) {
      indicatorColor = Colors.teal;
      indicatorText = 'connectionReconnecting';
    } else {
      indicatorColor = Colors.orange;
      indicatorText = 'connectionDisconnected';
    }

    // Add a test button for notifications when connected
    if (websocketState == WebSocketState.connected &&
        user.hasValue &&
        user.value != null) {
      // This is just for testing - you can remove this later
      Future.delayed(const Duration(milliseconds: 100), () {
        // Add a small button to the corner of the screen for testing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final overlay = Overlay.of(context);
          final entry = OverlayEntry(
            builder:
                (context) => Positioned(
                  right: 20,
                  bottom: 100,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final testNotification = SnNotification(
                          id: 'test-${DateTime.now().millisecondsSinceEpoch}',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          deletedAt: null,
                          topic: 'test',
                          title: 'Test Notification',
                          content: 'This is a test notification message',
                          priority: 1,
                          viewedAt: null,
                          accountId: 'test',
                          meta: {},
                        );

                        ref
                            .read(appNotificationsProvider.notifier)
                            .showNotification(
                              data: testNotification,
                              icon: Icons.notifications,
                              duration: const Duration(seconds: 5),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
          );
          // Only add if not already added
          try {
            overlay.insert(entry);
          } catch (e) {
            // Ignore if already added
          }
        });
      });
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1850),
      top:
          !user.hasValue ||
                  user.value == null ||
                  websocketState == WebSocketState.connected()
              ? -indicatorHeight
              : 0,
      curve: Curves.fastLinearToSlowEaseIn,
      left: 0,
      right: 0,
      height: indicatorHeight,
      child: IgnorePointer(
        child: Material(
          elevation:
              !user.hasValue || websocketState == WebSocketState.connected()
                  ? 0
                  : 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: indicatorColor,
            child: Center(
              child:
                  Text(
                    indicatorText,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ).tr(),
            ).padding(top: MediaQuery.of(context).padding.top),
          ),
        ),
      ),
    );
  }
}

class _AppNotificationToast extends HookConsumerWidget {
  const _AppNotificationToast();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(appNotificationsProvider);
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    // If no notifications, return empty container
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the most recent notification
    final notification = notifications.last;

    // Calculate position based on device type
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final notificationTop = safeAreaTop + (isDesktop ? 30 : 10);

    return Positioned(
      top: notificationTop,
      left: 16,
      right: 16,
      child: Column(
        children:
            notifications.map((notification) {
              // Calculate how long the notification has been visible
              final now = DateTime.now();
              final createdAt = notification.createdAt ?? now;
              final duration =
                  notification.duration ?? const Duration(seconds: 5);
              final elapsedTime = now.difference(createdAt);
              final remainingTime = duration - elapsedTime;
              final progress =
                  1.0 -
                  (remainingTime.inMilliseconds / duration.inMilliseconds);

              return _NotificationCard(
                notification: notification,
                progress: progress.clamp(0.0, 1.0),
                onDismiss: () {
                  ref
                      .read(appNotificationsProvider.notifier)
                      .removeNotification(notification);
                },
              );
            }).toList(),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final double progress;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.progress,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.data.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  minHeight: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notification.icon != null)
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
                            ).padding(top: 4),
                          if (notification.data.subtitle.isNotEmpty)
                            Text(
                              notification.data.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ).padding(top: 2),
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
            default:
              icon = Symbols.info;
              break;
          }

          addNotification(
            AppNotification(data: data, icon: icon, createdAt: data.createdAt),
          );
        } catch (e) {
          print('Error processing notification: $e');
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
      removeNotification(newNotification);
    });
  }

  void removeNotification(AppNotification notification) {
    state = state.where((n) => n != notification).toList();
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
