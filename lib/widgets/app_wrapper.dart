import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:island/pods/activity/activity_rpc.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/screens/auth/login_content.dart';
import 'package:island/screens/tray_manager.dart';
import 'package:island/pods/web_auth/web_auth_providers.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/tour/tour.dart';
import 'package:island/widgets/post/compose_sheet.dart';
import 'package:island/screens/notification.dart';
import 'package:island/screens/thought/think_sheet.dart';
import 'package:island/services/event_bus.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class AppWrapper extends HookConsumerWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStateShowing = useState(false);
    final wsNotifier = ref.watch(websocketStateProvider.notifier);
    final websocketState = ref.watch(websocketStateProvider);
    final isShowSnow = useState(false);
    final isSnowGone = useState(false);

    // Handle network status modal
    if (websocketState == WebSocketState.duplicateDevice() &&
        !networkStateShowing.value) {
      networkStateShowing.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (context) =>
              NetworkStatusSheet(onReconnect: () => wsNotifier.connect()),
        ).then((_) => networkStateShowing.value = false);
      });
    }

    // Initialize services and listeners
    useEffect(() {
      final ntySubs = setupNotificationListener(context, ref);
      final sharingService = SharingIntentService();
      sharingService.initialize(context);
      UpdateService().checkForUpdates(context);

      final trayService = TrayService.instance;
      trayService.initialize(
        _TrayListenerImpl(
          onTrayIconMouseDown: () => windowManager.show(),
          onTrayIconRightMouseUp: () => trayManager.popUpContextMenu(),
          onTrayMenuItemClick: (menuItem) => trayService.handleAction(menuItem),
        ),
      );

      ref.read(rpcServerStateProvider.notifier).start();
      ref.read(webAuthServerStateProvider.notifier).start();

      // Listen to special action events
      final composeSheetSubs = eventBus.on<ShowComposeSheetEvent>().listen((
        event,
      ) {
        if (context.mounted) _showComposeSheet(context);
      });

      final notificationSheetSubs = eventBus
          .on<ShowNotificationSheetEvent>()
          .listen((event) {
            if (context.mounted) _showNotificationSheet(context);
          });

      final thoughtSheetSubs = eventBus.on<ShowThoughtSheetEvent>().listen((
        event,
      ) {
        if (context.mounted) _showThoughtSheet(context, event);
      });

      // Protocol handler listener
      final protocolListener = _ProtocolListenerImpl(
        onProtocolUrlReceived: (url) =>
            _handleDeepLink(Uri.parse(url), ref, context),
      );
      protocolHandler.addListener(protocolListener);

      // Handle initial URL
      protocolHandler.getInitialUrl().then((initialUrl) {
        if (initialUrl != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleDeepLink(Uri.parse(initialUrl), ref, context);
          });
        }
      });

      return () {
        protocolHandler.removeListener(protocolListener);
        ref.read(rpcServerProvider).stop();
        trayService.dispose(
          _TrayListenerImpl(
            onTrayIconMouseDown: () => {},
            onTrayIconRightMouseUp: () => {},
            onTrayMenuItemClick: (menuItem) => {},
          ),
        );
        ntySubs?.cancel();
        composeSheetSubs.cancel();
        notificationSheetSubs.cancel();
        thoughtSheetSubs.cancel();
      };
    }, []);

    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.watch(appSettingsProvider.notifier);

    final now = DateTime.now();
    final doesShowSnow =
        settings.festivalFeatures &&
        now.month == 12 &&
        (now.day >= 22 && now.day <= 28);

    useEffect(() {
      final now = DateTime.now();
      if (doesShowSnow) {
        isShowSnow.value = true;
        Future.delayed(const Duration(seconds: 60), () {
          if (!context.mounted) return;
          isShowSnow.value = false;
          Future.delayed(const Duration(seconds: 3), () {
            if (!context.mounted) return;
            isSnowGone.value = true;
          });
        });
      }

      if (settings.firstLaunchAt == null) {
        settingsNotifier.setFirstLaunchAt(now.toIso8601String());
      } else if (!settings.askedReview) {
        final launchAt = DateTime.parse(settings.firstLaunchAt!);
        final daysSinceFirstLaunch = now.difference(launchAt).inDays;
        if (daysSinceFirstLaunch >= 3 &&
            !kIsWeb &&
            (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
          final InAppReview inAppReview = InAppReview.instance;
          Future(() async {
            if (await inAppReview.isAvailable()) {
              inAppReview.requestReview();
            }
          });
          settingsNotifier.setAskedReview(true);
        }
      }

      return null;
    }, []);

    return TourTriggerWidget(
      key: const Key("app_tour_trigger"),
      child: Stack(
        children: [
          child,
          if (doesShowSnow && !isSnowGone.value)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: isShowSnow.value ? 1 : 00,
                duration: const Duration(seconds: 3),
                child: SnowFallAnimation(
                  key: const Key("app_snow_animation"),
                  config: SnowfallConfig(numberOfSnowflakes: 50, speed: 1.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showComposeSheet(BuildContext context) {
    PostComposeSheet.show(context);
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const NotificationSheet(),
    );
  }

  void _showThoughtSheet(BuildContext context, ShowThoughtSheetEvent event) {
    ThoughtSheet.show(
      context,
      initialMessage: event.initialMessage,
      attachedMessages: event.attachedMessages,
      attachedPosts: event.attachedPosts,
    );
  }

  void _handleDeepLink(Uri uri, WidgetRef ref, BuildContext context) async {
    String path = '/${uri.host}${uri.path}';

    // Special handling for OIDC auth callback
    if (path == '/auth/callback' && uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      setToken(ref.read(sharedPreferencesProvider), token);
      ref.invalidate(tokenProvider);

      // Do post login tasks
      await performPostLogin(context, ref);

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    // Special handling for share intent deep links
    // Share intents are handled by SharingIntentService showing a modal,
    // not by routing to a page
    if (path == '/share') {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    final router = ref.read(routerProvider);
    if (uri.queryParameters.isNotEmpty) {
      path = Uri.parse(
        path,
      ).replace(queryParameters: uri.queryParameters).toString();
    }
    router.push(path);
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.show();
    }
  }
}

class _TrayListenerImpl implements TrayListener {
  final VoidCallback _primaryAction;
  final VoidCallback _secondaryAction;
  final void Function(MenuItem) _onTrayMenuItemClick;

  _TrayListenerImpl({
    required VoidCallback onTrayIconMouseDown,
    required VoidCallback onTrayIconRightMouseUp,
    required void Function(MenuItem) onTrayMenuItemClick,
  }) : _primaryAction = onTrayIconMouseDown,
       _secondaryAction = onTrayIconRightMouseUp,
       _onTrayMenuItemClick = onTrayMenuItemClick;

  @override
  void onTrayIconMouseDown() => _primaryAction();

  @override
  void onTrayIconRightMouseUp() => _secondaryAction();

  @override
  void onTrayIconMouseUp() => _primaryAction();

  @override
  void onTrayIconRightMouseDown() => _secondaryAction();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) => _onTrayMenuItemClick(menuItem);
}

class _ProtocolListenerImpl implements ProtocolListener {
  final void Function(String) _onProtocolUrlReceived;

  _ProtocolListenerImpl({required void Function(String) onProtocolUrlReceived})
    : _onProtocolUrlReceived = onProtocolUrlReceived;

  @override
  void onProtocolUrlReceived(String url) => _onProtocolUrlReceived(url);
}
