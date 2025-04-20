import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class WindowScaffold extends StatelessWidget {
  final Widget child;
  const WindowScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final windowButtonColor = WindowButtonColors(
        iconNormal: Theme.of(context).colorScheme.primary,
        mouseOver: Theme.of(context).colorScheme.primaryContainer,
        mouseDown: Theme.of(context).colorScheme.onPrimaryContainer,
        iconMouseOver: Theme.of(context).colorScheme.primary,
        iconMouseDown: Theme.of(context).colorScheme.primary,
      );

      return Material(
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1 / devicePixelRatio,
                    ),
                  ),
                ),
                child: MoveWindow(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:
                        Platform.isMacOS
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Solar Network',
                          textAlign:
                              Platform.isMacOS
                                  ? TextAlign.center
                                  : TextAlign.start,
                        ).padding(horizontal: 12, vertical: 5),
                      ),
                      if (!Platform.isMacOS)
                        MinimizeWindowButton(colors: windowButtonColor),
                      if (!Platform.isMacOS)
                        MaximizeWindowButton(colors: windowButtonColor),
                      if (!Platform.isMacOS)
                        CloseWindowButton(
                          colors: windowButtonColor,
                          onPressed: () => appWindow.hide(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }
    return child;
  }
}
