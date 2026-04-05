import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/fitness/screens/fitness_dashboard_screen.dart';

@RoutePage()
class FitnessDashboardRoute extends StatelessWidget {
  const FitnessDashboardRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const FitnessDashboardScreen();
  }
}
