/// Island plugin system — host integration + foundation re-exports.
///
/// Core runtime lives in `package:island_plugin_foundation`. Host-only APIs
/// (dashboard, Solar Network network, notify UI, app event bridge) stay here.
library;

export 'package:island_plugin_foundation/island_plugin_foundation.dart';

export 'apis/dashboard_api.dart';
export 'apis/icons_api.dart';
export 'apis/network_api.dart';
export 'apis/notify_api.dart';
export 'apis/websocket_api.dart';
export 'icons/material_symbol_lookup.dart';
export 'icons/plugin_icon_font_registry.dart';
export 'plugin_event_bridge.dart';
export 'widgets/plugin_ui_bridge.dart';
