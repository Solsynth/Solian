import 'package:island/plugin/plugin_manager.dart';
import 'package:island/plugin/models/plugin_manifest.dart';

bool _isInitialized = false;

bool isPythonAvailable() => _isInitialized;

Future<void> initPython() async {
  if (_isInitialized) return;
  try {
    await PluginManager().initialize();
    _isInitialized = true;
  } catch (e) {
    _isInitialized = false;
  }
}

Future<void> evalPythonCode(String code) async {
  if (!_isInitialized) return;
  final manager = PluginManager();
  manager.installInlinePlugin(
    name: 'eval',
    source: code,
    id: 'inline.eval',
    permissions: PluginPermission.values,
  );
}
