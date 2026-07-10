/// Reusable JavaScript plugin foundation for Island / Solar Network apps.
///
/// Host apps:
/// 1. Register foundation + domain APIs via [PluginController]
/// 2. Keep host-only APIs (dashboard, Solar Network network, notify UI) in the app
/// 3. Listen to [PluginController] for UI state
library;

export 'src/apis/background_runner.dart';
export 'src/apis/commands_api.dart';
export 'src/apis/events_api.dart';
export 'src/apis/hooks_api.dart';
export 'src/apis/plugin_api.dart';
export 'src/apis/ui_api.dart';
export 'src/bridge/js_bridge.dart';
export 'src/models/plugin_manifest.dart';
export 'src/plugin_controller.dart';
export 'src/plugin_hooks.dart';
export 'src/plugin_manager.dart';
