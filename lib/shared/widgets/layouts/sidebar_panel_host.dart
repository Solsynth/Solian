import 'package:flutter/widgets.dart';

/// A tunable sidebar that can host transient panels (e.g. a replies thread)
/// instead of always showing its default content.
///
/// Any descendant of this host can request a panel with [show]; the widget
/// enclosing the host decides how to render it. When [controller] is `null`,
/// the sidebar's default content is shown.
///
/// Subtrees without a host keep their previous behavior (e.g. modal bottom
/// sheets), so this only affects screens that opt in.
class SidebarPanelHost extends InheritedWidget {
  const SidebarPanelHost({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Holds the currently displayed panel; `null` means default content.
  final ValueNotifier<Widget?> controller;

  /// Returns the nearest host without registering a dependency, or `null`
  /// when this subtree has no tunable sidebar.
  static SidebarPanelHost? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<SidebarPanelHost>();
  }

  /// Shows [panel] in the enclosing sidebar.
  void show(Widget panel) => controller.value = panel;

  /// Restores the sidebar's default content.
  void clear() => controller.value = null;

  @override
  bool updateShouldNotify(SidebarPanelHost oldWidget) =>
      controller != oldWidget.controller;
}
