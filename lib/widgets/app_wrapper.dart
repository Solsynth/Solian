import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/sharing_intent.dart';
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
      return () {
        sharingService.dispose();
        ntySubs?.cancel();
      };
    }, const []);

    return TourTriggerWidget(child: child);
  }
}
