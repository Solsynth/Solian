import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/services/sharing_intent.dart';

@RoutePage()
class AppWrapper extends HookConsumerWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final sharingService = SharingIntentService();
      sharingService.initialize(context);
      return () {
        sharingService.dispose();
      };
    }, const []);

    return AutoRouter();
  }
}
