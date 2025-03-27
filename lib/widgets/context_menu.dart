import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/config.dart';

class ContextMenuArea extends StatelessWidget {
  final ContextMenu contextMenu;
  final Widget child;
  final ValueChanged<dynamic>? onItemSelected;

  const ContextMenuArea({
    super.key,
    required this.contextMenu,
    required this.child,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    Offset mousePosition = Offset.zero;

    return Listener(
      onPointerDown: (event) {
        mousePosition = event.position;
        final cfg = context.read<ConfigProvider>();
        if (!cfg.drawerIsCollapsed) {
          // Leave padding for side navigation
          mousePosition = mousePosition.copyWith(dx: mousePosition.dx - 80 * 2);
        }
      },
      child: GestureDetector(
        onLongPress: () => _showMenu(context, mousePosition),
        onSecondaryTap: () => _showMenu(context, mousePosition),
        child: child,
      ),
    );
  }

  void _showMenu(BuildContext context, Offset mousePosition) async {
    final menu =
        contextMenu.copyWith(position: contextMenu.position ?? mousePosition);
    final value = await showContextMenu(context, contextMenu: menu);
    onItemSelected?.call(value);
  }
}
