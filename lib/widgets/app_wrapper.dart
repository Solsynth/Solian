import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/activity/activity_rpc.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/screens/tray_manager.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/tour/tour.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class AppWrapper extends HookConsumerWidget with TrayListener {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      StreamSubscription? ntySubs;
      StreamSubscription? appLinksSubs;
      Future(() async {
        final appLinks = AppLinks();

        if (context.mounted) ntySubs = setupNotificationListener(context, ref);

        final sharingService = SharingIntentService();
        if (context.mounted) sharingService.initialize(context);
        if (context.mounted) UpdateService().checkForUpdates(context);

        TrayService.instance.initialize(this);

        ref.read(rpcServerStateProvider.notifier).start();

        final initialUri = await appLinks.getLatestLink();
        if (initialUri != null && context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleDeepLink(initialUri, ref);
          });
        }

        appLinksSubs = appLinks.uriLinkStream.listen((uri) {
          _handleDeepLink(uri, ref);
        });
      });

      return () {
        ref.read(rpcServerProvider).stop();
        TrayService.instance.dispose(this);
        ntySubs?.cancel();
        appLinksSubs?.cancel();
      };
    }, const []);

    final wsNotifier = ref.watch(websocketStateProvider.notifier);
    final websocketState = ref.watch(websocketStateProvider);

    final networkStateShowing = useState(false);

    if (websocketState == WebSocketState.duplicateDevice()) {
      if (!networkStateShowing.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          networkStateShowing.value = true;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            builder:
                (context) =>
                    NetworkStatusSheet(onReconnect: () => wsNotifier.connect()),
          ).then((_) => networkStateShowing.value = false);
        });
      }
    }

    return TourTriggerWidget(key: UniqueKey(), child: child);
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
    final router = ref.read(routerProvider);
    String path = '/${uri.path}';
    if (uri.queryParameters.isNotEmpty) {
      path =
          Uri.parse(
            path,
          ).replace(queryParameters: uri.queryParameters).toString();
    }
    router.go(path);
  }
}
