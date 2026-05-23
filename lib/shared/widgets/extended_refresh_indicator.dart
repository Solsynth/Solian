import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExtendedRefreshIndicator extends HookConsumerWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const ExtendedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (kIsWeb || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        final isRefreshKey = event.logicalKey == LogicalKeyboardKey.keyR;
        final isRefreshModifier = Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

        if (isRefreshKey && isRefreshModifier) {
          onRefresh();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: RefreshIndicator(onRefresh: onRefresh, child: child),
    );
  }
}
