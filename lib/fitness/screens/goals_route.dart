import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class GoalsRoute extends StatelessWidget {
  const GoalsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Goals Screen - Coming Soon')),
    );
  }
}
