import "dart:async";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

final appLifecycleStateProvider = StreamProvider<AppLifecycleState>((ref) {
  final controller = StreamController<AppLifecycleState>();

  final observer = _AppLifecycleObserver((state) {
    if (controller.isClosed) return;
    controller.add(state);
  });
  WidgetsBinding.instance.addObserver(observer);

  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    controller.close();
  });

  return controller.stream;
});

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState> onChange;
  _AppLifecycleObserver(this.onChange);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }
}
