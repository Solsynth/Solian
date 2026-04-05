import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/fitness/screens/workouts_screen.dart';

@RoutePage()
class WorkoutsRoute extends StatelessWidget {
  const WorkoutsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkoutsScreen();
  }
}
