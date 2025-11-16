import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:island/pods/activity/activity_rpc.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/screens/tray_manager.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/tour/tour.dart';
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
            builder:
                (context) =>
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

  void _handleDeepLink(Uri uri, WidgetRef ref) {
    String path = '/${uri.host}${uri.path}';

    // Special handling for OIDC auth callback
    if (path == '/auth/callback' &&
        uri.queryParameters.containsKey('challenge')) {
      final challenge = uri.queryParameters['challenge']!;
      eventBus.fire(OidcAuthCallbackEvent(challenge));
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    final router = ref.read(routerProvider);
    if (uri.queryParameters.isNotEmpty) {
      path =
          Uri.parse(
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
