import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum VimMode { normal, insert }

class KeyboardNavigation extends StatefulWidget {
  const KeyboardNavigation({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardNavigation> createState() => _KeyboardNavigationState();
}

class _KeyboardNavigationState extends State<KeyboardNavigation> {
  VimMode _mode = VimMode.normal;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_mode == VimMode.normal) {
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        node.focusInDirection(TraversalDirection.down);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyK) {
        node.focusInDirection(TraversalDirection.up);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
        final focusNode = FocusManager.instance.primaryFocus;
        if (focusNode != null) {
          final scrollable = Scrollable.of(focusNode.context!);
          if (scrollable.position.axis == Axis.horizontal) {
            scrollable.position.moveTo(scrollable.position.pixels - 50);
            return KeyEventResult.handled;
          }
        }
        node.focusInDirection(TraversalDirection.left);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        final focusNode = FocusManager.instance.primaryFocus;
        if (focusNode != null) {
          final scrollable = Scrollable.of(focusNode.context!);
          if (scrollable.position.axis == Axis.horizontal) {
            scrollable.position.moveTo(scrollable.position.pixels + 50);
            return KeyEventResult.handled;
          }
        }
        node.focusInDirection(TraversalDirection.right);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
        setState(() {
          _mode = VimMode.insert;
        });
        return KeyEventResult.handled;
      }
    } else if (_mode == VimMode.insert) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() {
          _mode = VimMode.normal;
        });
        // Unfocus the current widget to prevent typing
        node.unfocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusScopeNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
