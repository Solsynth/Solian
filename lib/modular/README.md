# Plugin Registry and Loader System

## Overview

This module provides a plugin system for the Island app with two types of plugins:
- **Raw Plugins**: Extend app abilities (services, hooks, utilities)
- **Mini-Apps**: Full-screen applications loaded from network with caching

## File Structure

```
lib/
  modular/
    interface.dart           # Plugin interfaces and metadata models
    registry.dart           # PluginRegistry class for managing plugins
  pods/
    plugin_registry.dart    # Riverpod providers for plugin management
```

## Core Components

### 1. Plugin Interface (`lib/modular/interface.dart`)

Defines the base types for plugins:

- `Plugin`: Base interface for all plugins
- `RawPlugin`: For plugins that extend app functionality
- `MiniApp`: For full-screen apps with entry widgets
- `PluginMetadata`: Common metadata structure
- `MiniAppMetadata`: Metadata for mini-apps including download URL, cache path
- `MiniAppServerInfo`: Server response format for mini-app listings
- `PluginLoadResult`: Enum for load operation results

### 2. Plugin Registry (`lib/modular/registry.dart`)

`PluginRegistry` class manages plugin lifecycle:

**Raw Plugins:**
- `registerRawPlugin(RawPlugin plugin)`
- `unregisterRawPlugin(String id)`
- `getRawPlugin(String id)`

**Mini-Apps:**
- `loadMiniApp(MiniAppMetadata metadata, {ProgressCallback? onProgress})`: Loads .evc bytecode
- `unloadMiniApp(String id)`: Unloads and cleans up
- `getMiniApp(String id)`: Get loaded mini-app
- `getMiniAppCacheDirectory()`: Get cache directory path
- `clearMiniAppCache()`: Clear all cached mini-apps
- `dispose()`: Cleanup all resources

### 3. Riverpod Providers (`lib/pods/plugin_registry.dart`)

**Providers:**
- `pluginRegistryProvider`: Main registry provider with `keepAlive: true`
- `miniAppsProvider`: List of loaded mini-apps
- `rawPluginsProvider`: Map of raw plugins

**Methods (via `ref.read(pluginRegistryProvider.notifier)`:**
- `syncMiniAppsFromServer(apiEndpoint)`: Sync with server, returns `MiniAppSyncResult`
- `downloadMiniApp(id, downloadUrl, {ProgressCallback? onProgress})`: Download and cache
- `updateMiniApp(id, {ProgressCallback? onProgress})`: Update to latest version
- `enableMiniApp(id, enabled)`: Enable/disable mini-app
- `deleteMiniApp(id, {deleteCache})`: Remove mini-app
- `clearMiniAppCache()`: Clear cache
- `getMiniApp(id)`: Get specific mini-app
- `getLastSyncTime()`: Get last sync timestamp

## Storage

### SharedPreferences Keys:
- `kMiniAppsRegistryKey`: JSON array of MiniAppMetadata
- `kMiniAppsLastSyncKey`: ISO8601 timestamp of last sync

### Cache Structure:
```
{applicationDocuments}/mini_apps/
  ├── {app_id}.evc           # Compiled bytecode
  └── {app_id}_metadata.json  # Metadata backup (optional)
```

## Usage Examples

### Registering a Raw Plugin

```dart
class MyRawPlugin extends RawPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'my_plugin',
    name: 'My Plugin',
    version: '1.0.0',
    description: 'Extends app with new features',
  );
}

final container = ProviderContainer();
container.read(pluginRegistryProvider.notifier).registerRawPlugin(MyRawPlugin());
```

### Syncing Mini-Apps from Server

```dart
final syncResult = await ref.read(pluginRegistryProvider.notifier).syncMiniAppsFromServer(
  'https://api.example.com/mini-apps',
);

if (syncResult.success) {
  print('Added: ${syncResult.added}');
  print('Updated: ${syncResult.updated}');
}
```

### Downloading and Loading a Mini-App

```dart
await ref.read(pluginRegistryProvider.notifier).downloadMiniApp(
  'com.example.miniapp',
  'https://cdn.example.com/mini-apps/v1/app.evc',
  onProgress: (progress, message) {
    print('$progress: $message');
  },
);
```

### Using a Loaded Mini-App Entry

```dart
class MiniAppScreen extends ConsumerWidget {
  final String appId;

  const MiniAppScreen({required this.appId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniApp = await ref.read(pluginRegistryProvider.notifier).getMiniApp(appId);
    
    if (miniApp == null) {
      return const Center(child: Text('Mini-app not loaded'));
    }

    return Scaffold(
      body: miniApp.buildEntry(),
    );
  }
}
```

### Server API Response Format

```json
{
  "mini_apps": [
    {
      "id": "com.example.miniapp",
      "name": "Example Mini-App",
      "version": "1.2.0",
      "description": "An example mini-application",
      "author": "Example Corp",
      "iconUrl": "https://cdn.example.com/icons/miniapp.png",
      "downloadUrl": "https://cdn.example.com/mini-apps/v1/app.evc",
      "updatedAt": "2026-01-18T00:00:00Z",
      "sizeBytes": 524288
    }
  ]
}
```

## Mini-App Development

A mini-app should export a `buildEntry()` function:

```dart
// mini_app/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildEntry() {
  return MaterialApp(
    title: 'My Mini-App',
    home: Scaffold(
      appBar: AppBar(title: const Text('My Mini-App')),
      body: const Center(
        child: Text('Hello from Mini-App!'),
      ),
    ),
  );
}
```

Compile to .evc using flutter_eval toolchain before uploading to server.

## FlutterEval Integration

Currently, a stub `Runtime` class is provided in `lib/modular/registry.dart` for compilation. To enable full flutter_eval functionality:

1. Resolve dependency conflicts with analyzer package
2. Replace stub `Runtime` class with actual flutter_eval import
3. Test with actual .evc bytecode files

## Notes

- Registry uses `keepAlive: true` to persist across app lifecycle
- All operations are async and return appropriate results
- Progress callbacks provide real-time feedback for download/load operations
- Error handling includes talker logging for debugging
- SharedPreferences persistence survives app restarts

## Future Enhancements

- [ ] Full flutter_eval integration
- [ ] Mini-app permissions and security model
- [ ] Version comparison and auto-update
- [ ] Dependency resolution for mini-apps
- [ ] Mini-app marketplace UI
- [ ] Hot-swapping without app restart
