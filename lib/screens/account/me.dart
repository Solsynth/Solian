import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:island/widgets/app_scaffold.dart';

@RoutePage()
class MyselfProfileScreen extends StatelessWidget {
  const MyselfProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(appBar: AppBar(leading: const PageBackButton()));
  }
}
