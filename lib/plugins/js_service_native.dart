import 'package:island/plugins/plugin_manager.dart';
import 'package:island/plugins/models/plugin_manifest.dart';

bool _isInitialized = false;

bool isJsAvailable() => _isInitialized;

Future<void> initJs() async {
  if (_isInitialized) return;
  try {
    await PluginManager().initialize();
    _isInitialized = true;
  } catch (e) {
    _isInitialized = false;
  }
}

Future<void> evalJsCode(String code) async {
  if (!_isInitialized) return;
  final manager = PluginManager();
  manager.installInlinePlugin(
    name: 'eval',
    source: code,
    id: 'inline.eval',
    permissions: PluginPermission.values,
  );
}
