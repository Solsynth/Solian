import 'package:material_ui/material_ui.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';

class PluginPaneData {
  final String id;
  final String pluginId;
  final String pluginName;
  String title;
  PluginUiDescriptor? descriptor;
  Offset position;
  Size size;
  int zIndex;
  bool minimized;

  PluginPaneData({
    required this.id,
    required this.pluginId,
    required this.pluginName,
    required this.title,
    this.descriptor,
    this.position = const Offset(100, 100),
    this.size = const Size(400, 320),
    this.zIndex = 0,
    this.minimized = false,
  });
}

class PluginPaneHost extends ChangeNotifier {
  static final PluginPaneHost _instance = PluginPaneHost._();
  static PluginPaneHost get instance => _instance;

  PluginPaneHost._();

  final List<PluginPaneData> _panes = [];
  int _nextZIndex = 1;
  int _nextId = 0;

  List<PluginPaneData> get panes => List.unmodifiable(_panes);

  String addPane({
    required PluginUiDescriptor descriptor,
    required String pluginId,
    required String pluginName,
    String title = '',
  }) {
    final id = 'pp_${_nextId++}';
    final offset = Offset(
      80.0 + (_panes.length * 28) % 240,
      80.0 + (_panes.length * 28) % 240,
    );
    _panes.add(PluginPaneData(
      id: id,
      pluginId: pluginId,
      pluginName: pluginName,
      title: title,
      descriptor: descriptor,
      position: offset,
      zIndex: _nextZIndex++,
    ));
    notifyListeners();
    return id;
  }

  void removePane(String id) {
    _panes.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clearForPlugin(String pluginId) {
    _panes.removeWhere((p) => p.pluginId == pluginId);
    notifyListeners();
  }

  void updatePosition(String id, Offset position) {
    final i = _panes.indexWhere((p) => p.id == id);
    if (i >= 0) _panes[i].position = position;
    notifyListeners();
  }

  void updateSize(String id, Size size) {
    final i = _panes.indexWhere((p) => p.id == id);
    if (i >= 0) _panes[i].size = size;
    notifyListeners();
  }

  void bringToFront(String id) {
    final i = _panes.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _panes[i].zIndex = _nextZIndex++;
      notifyListeners();
    }
  }

  void toggleMinimize(String id) {
    final i = _panes.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _panes[i].minimized = !_panes[i].minimized;
      notifyListeners();
    }
  }

  void updateDescriptor(String id, PluginUiDescriptor descriptor) {
    final i = _panes.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _panes[i].descriptor = descriptor;
      notifyListeners();
    }
  }
}
