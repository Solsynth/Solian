import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/fitness/screens/health_sync_screen.dart';

@RoutePage()
class HealthSyncRoute extends StatelessWidget {
  const HealthSyncRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const HealthSyncScreen();
  }
}
