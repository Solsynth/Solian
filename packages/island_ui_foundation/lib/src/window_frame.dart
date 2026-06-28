import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowFrame extends HookWidget {
  final Widget child;
  final Widget? title;
  final List<Widget> overlays;
  final List<Widget> Function(
    BuildContext context,
    ValueNotifier<bool> isMaximized,
  )? additionalTitleBarActions;
  final VoidCallback? onClose;
  final bool isDesktopPlatform;

  const DesktopWindowFrame({
    super.key,
    required this.child,
    this.title,
    this.overlays = const [],
    this.additionalTitleBarActions,
    this.onClose,
    this.isDesktopPlatform = false,
  });

  static bool get isPlatformDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

  @override
  Widget build(BuildContext context) {
    final isMaximized = useState(false);
    final keyboardFocusNode = useFocusNode();

    useEffect(() {
      keyboardFocusNode.requestFocus();
      return null;
    }, []);

    useEffect(() {
      if (!isDesktopPlatform) return null;

      final maximizeListener = _WindowMaximizeListener(isMaximized);
      windowManager.addListener(maximizeListener);
      windowManager.isMaximized().then((max) => isMaximized.value = max);

      return () {
        windowManager.removeListener(maximizeListener);
      };
    }, [isDesktopPlatform]);

    final builtWidget = Focus(
      focusNode: keyboardFocusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.physicalKey == PhysicalKeyboardKey.tab &&
            HardwareKeyboard.instance.isShiftPressed) {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
      child: isDesktopPlatform
          ? Material(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      DragToMoveArea(
                        child: _buildTitleBar(context, isMaximized),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                  ...overlays,
                ],
              ),
            )
          : child,
    );

    return builtWidget;
  }

  Widget _buildTitleBar(
    BuildContext context,
    ValueNotifier<bool> isMaximized,
  ) {
    if (Platform.isMacOS) {
      return SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ?title,
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              if (title != null) Expanded(child: title!),
            ],
          ).padding(horizontal: 12, vertical: 5),
        ),
        if (additionalTitleBarActions != null)
          ...additionalTitleBarActions!(context, isMaximized),
        _WindowButton(
          icon: Symbols.minimize,
          onPressed: () => windowManager.minimize(),
        ),
        _WindowButton(
          icon: isMaximized.value
              ? Symbols.fullscreen_exit
              : Symbols.fullscreen,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.restore();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _WindowButton(
          icon: Symbols.close,
          onPressed: onClose ?? () => windowManager.hide(),
        ),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _WindowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 16,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      color: Theme.of(context).iconTheme.color,
    );
  }
}

class _WindowMaximizeListener with WindowListener {
  final ValueNotifier<bool> isMaximized;

  _WindowMaximizeListener(this.isMaximized);

  @override
  void onWindowMaximize() {
    isMaximized.value = true;
  }

  @override
  void onWindowUnmaximize() {
    isMaximized.value = false;
  }
}
