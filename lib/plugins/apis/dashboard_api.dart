import 'dart:convert';

import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('DashboardApi');

/// A dashboard item contributed by an active plugin.
class PluginDashboardItem {
  final String pluginId;
  final String id;
  final String title;
  final String handlerName;
  final String? icon;

  const PluginDashboardItem({
    required this.pluginId,
    required this.id,
    required this.title,
    required this.handlerName,
    this.icon,
  });

  /// Stable identifier stored in the user's dashboard configuration.
  String get layoutId => 'plugin:$pluginId:$id';
}

/// Host-specific API: plugins register descriptor-based dashboard items.
///
/// Lives in the Island app (not the foundation package) because it is tied to
/// the Solian dashboard layout system.
class DashboardApi extends PluginApi {
  final List<PluginDashboardItem> _items = [];

  List<PluginDashboardItem> get items => List.unmodifiable(_items);

  PluginDashboardItem? itemForLayoutId(String layoutId) {
    for (final item in _items) {
      if (item.layoutId == layoutId) return item;
    }
    return null;
  }

  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.uiRender};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.uiRender)) return '';
    // Extend the `ui` object created by foundation UiApi (or create it).
    return '''
var ui = ui || {};
ui.register_dashboard_item = function(id, title, handler, icon) {
  sendMessage("api:ui:register_dashboard_item", JSON.stringify({id: id, title: title, handler: handler, icon: icon || null}));
};
''';
  }

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:ui:register_dashboard_item', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final id = data['id']?.toString();
        final title = data['title']?.toString();
        final handler = data['handler']?.toString();
        if (id == null ||
            id.isEmpty ||
            title == null ||
            title.isEmpty ||
            handler == null ||
            handler.isEmpty) {
          return;
        }
        final pluginId = PluginManager.activePluginId;
        if (pluginId == null) return;
        _items.removeWhere(
          (item) => item.pluginId == pluginId && item.id == id,
        );
        _items.add(
          PluginDashboardItem(
            pluginId: pluginId,
            id: id,
            title: title,
            handlerName: handler,
            icon: data['icon']?.toString(),
          ),
        );
        _log.info('Plugin $pluginId registered dashboard item: $id');
      } catch (e) {
        _log.warning('Failed to register dashboard item: $e');
      }
    });
  }

  @override
  void onPluginUnload(String pluginId) {
    clearItems(pluginId);
  }

  void clearItems(String pluginId) =>
      _items.removeWhere((item) => item.pluginId == pluginId);

  @override
  void reset() {
    _items.clear();
  }
}
