import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/misc/about_content.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('about'.tr()), elevation: 0),
      body: const AboutContent(),
    );
  }
}
