import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:island/services/event_bus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class AppWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper>
    with ProtocolListener, TrayListener {
  StreamSubscription? ntySubs;
  bool networkStateShowing = false;

  StreamSubscription? composeSheetSubs;
  StreamSubscription? notificationSheetSubs;

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    Future(() async {
      if (mounted) ntySubs = setupNotificationListener(context, ref);

      final sharingService = SharingIntentService();
      if (mounted) sharingService.initialize(context);
      if (mounted) UpdateService().checkForUpdates(context);

      TrayService.instance.initialize(this);

      ref.read(rpcServerStateProvider.notifier).start();
      ref.read(webAuthServerStateProvider.notifier).start();

      // Listen to special action events
      composeSheetSubs = eventBus.on<ShowComposeSheetEvent>().listen((event) {
        if (mounted) {
          _showComposeSheet();
        }
      });

      notificationSheetSubs = eventBus.on<ShowNotificationSheetEvent>().listen((
        event,
      ) {
        if (mounted) {
          _showNotificationSheet();
        }
      });

      final initialUrl = await protocolHandler.getInitialUrl();
      if (initialUrl != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLink(Uri.parse(initialUrl), ref);
        });
      }
    });
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    ref.read(rpcServerProvider).stop();
    TrayService.instance.dispose(this);
    ntySubs?.cancel();
    composeSheetSubs?.cancel();
    notificationSheetSubs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsNotifier = ref.watch(websocketStateProvider.notifier);
    final websocketState = ref.watch(websocketStateProvider);

    if (websocketState == WebSocketState.duplicateDevice()) {
      if (!networkStateShowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => networkStateShowing = true);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            builder: (context) =>
                NetworkStatusSheet(onReconnect: () => wsNotifier.connect()),
          ).then((_) => setState(() => networkStateShowing = false));
        });
      }
    }

    return TourTriggerWidget(key: UniqueKey(), child: widget.child);
  }

  @override
  void onProtocolUrlReceived(String url) {
    _handleDeepLink(Uri.parse(url), ref);
  }

  void _trayIconPrimaryAction() {
    windowManager.show();
  }

  void _trayIconSecondaryAction() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseUp() {
    _trayIconPrimaryAction();
  }

  @override
  void onTrayIconRightMouseDown() {
    _trayIconSecondaryAction();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    TrayService.instance.handleAction(menuItem);
  }

  void _showComposeSheet() {
    PostComposeSheet.show(context);
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const NotificationSheet(),
    );
  }

  void _handleDeepLink(Uri uri, WidgetRef ref) async {
    String path = '/${uri.host}${uri.path}';

    // Special handling for OIDC auth callback
    if (path == '/auth/callback' && uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      setToken(ref.read(sharedPreferencesProvider), token);
      ref.invalidate(tokenProvider);

      // Do post login tasks
      if (mounted) {
        await performPostLogin(context, ref);
      }

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
