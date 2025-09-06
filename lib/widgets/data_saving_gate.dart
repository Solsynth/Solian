import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/config.dart';


typedef WidgetBuilder0 = Widget Function();

class DataSavingGate extends ConsumerWidget {
  final bool bypass;
  final WidgetBuilder0 content;
  final Widget placeholder;

  const DataSavingGate({
    super.key,
    required this.bypass,
    required this.content,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSaving =
        ref.watch(appSettingsNotifierProvider.select((s) => s.dataSavingMode));
    if (bypass || !dataSaving) return content();
    return placeholder;
  }
}
