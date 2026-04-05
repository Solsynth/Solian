import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class MetricsRoute extends StatelessWidget {
  const MetricsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Metrics')),
      body: const Center(child: Text('Metrics Screen - Coming Soon')),
    );
  }
}
