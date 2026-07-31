import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('DashboardApi');

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

  String get layoutId => 'plugin:$pluginId:$id';
}

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
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
var ui = ui || {};
ui.register_dashboard_item = function(id, title, handler, icon) {
  sendMessage("api:ui:register_dashboard_item", JSON.stringify({id: id, title: title, handler: handler, icon: icon || null}));
};
''');
    runtime.onMessage('api:ui:register_dashboard_item', (raw) {
      try {
        final data = context.router.decode(raw);
        final id = data['id']?.toString();
        final title = data['title']?.toString();
        final handler = data['handler']?.toString();
        if (id == null || id.isEmpty || title == null || title.isEmpty || handler == null || handler.isEmpty) return;
        _items.removeWhere((item) => item.pluginId == context.pluginId && item.id == id);
        _items.add(PluginDashboardItem(
          pluginId: context.pluginId,
          id: id,
          title: title,
          handlerName: handler,
          icon: data['icon']?.toString(),
        ));
        _log.info('Plugin ${context.pluginId} registered dashboard item: $id');
      } catch (e) {
        _log.warning('Failed to register dashboard item: $e');
      }
    });
  }

  @override
  void onPluginUnload(String pluginId) {
    _items.removeWhere((item) => item.pluginId == pluginId);
  }

  @override
  void reset() {
    _items.clear();
  }
}
