import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:uuid/uuid.dart';

class RefreshIntent extends Intent {
  const RefreshIntent();
}

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
    final hotKeyIdentifier = useState(Uuid().v4().substring(0, 8));

    final refreshHotKey = HotKey(
      identifier: 'refresh_indicator_$hotKeyIdentifier',
      key: PhysicalKeyboardKey.keyR,
      modifiers: [
        (!kIsWeb && Platform.isMacOS)
            ? HotKeyModifier.meta
            : HotKeyModifier.control,
      ],
      scope: HotKeyScope.inapp,
    );

    useEffect(() {
      if (kIsWeb) return null;

      hotKeyManager.register(
        refreshHotKey,
        keyDownHandler: (_) {
          onRefresh.call();
        },
      );

      return () {
        hotKeyManager.unregister(refreshHotKey);
      };
    }, []);

    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}
