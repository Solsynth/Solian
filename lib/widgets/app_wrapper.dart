import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/screens/tray_manager.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/tour/tour.dart';
import 'package:tray_manager/tray_manager.dart';

class AppWrapper extends HookConsumerWidget with TrayListener {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      StreamSubscription? ntySubs;
      Future(() {
        if (context.mounted) ntySubs = setupNotificationListener(context, ref);
      });

      final sharingService = SharingIntentService();
      sharingService.initialize(context);

      UpdateService().checkForUpdates(context);

      TrayService.instance.initialize(this);

      return () {
        TrayService.instance.dispose(this);
        sharingService.dispose();
        ntySubs?.cancel();
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
    appWindow.show();
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
}
