import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/tour/tour.dart';

class AppWrapper extends HookConsumerWidget {
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
      return () {
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
}
