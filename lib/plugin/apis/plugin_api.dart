import 'dart:ffi';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';

/// Base class for API bridges that expose Dart functionality to Python plugins.
///
/// Each API registers Python functions into a plugin's module, gated by permissions.
abstract class PluginApi {
  /// Permissions required for this API to be available.
  /// Empty means always available.
  Set<PluginPermission> get requiredPermissions;

  /// Register this API's functions into the given plugin module.
  void register(Pointer<py_TValue> module, PyBridge py);
}
