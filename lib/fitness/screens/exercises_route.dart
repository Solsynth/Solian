import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class ExercisesRoute extends StatelessWidget {
  const ExercisesRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: const Center(child: Text('Exercises Screen - Coming Soon')),
    );
  }
}
