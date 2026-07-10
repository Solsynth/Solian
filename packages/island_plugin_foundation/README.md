# Island Plugin Foundation

Reusable JavaScript plugin runtime for Flutter apps, powering the [Island](https://github.com/SolarNetwork/Island) / Solar Network ecosystem. Provides plugin discovery, lifecycle management, sandboxed JS execution, generic APIs, and host extension points.

## What this package gives you

| Capability | Description |
|---|---|
| **Discovery** | Finds plugins from bundled assets and on-disk directories |
| **Lifecycle** | Load, unload, disable, enable, reload — with startup crash safeguards |
| **Sandboxing** | Each plugin runs in its own isolated `JsRuntime` (QuickJS / JavaScriptCore) |
| **Permission gating** | APIs are only exposed to plugins that declare the matching permission |
| **Generic APIs** | `commands`, `events`, `hooks`, `ui`, `tasks` — ready to use out of the box |
| **Host extension model** | Register your own domain-specific `PluginApi` subclasses |
| **Reactive UI** | `PluginController` is a `ChangeNotifier` for Flutter widget trees |

## Adding to your project

```yaml
dependencies:
  island_plugin_foundation:
    path: packages/island_plugin_foundation   # or a published version
```

This package depends on [`flutter_js`](https://pub.dev/packages/flutter_js) and [`path_provider`](https://pub.dev/packages/path_provider) — both are transitive dependencies, so no extra setup is needed beyond adding the package.

## Integration guide

### 1. Register APIs at startup

Host apps register the generic foundation APIs plus their own domain APIs via `PluginController`:

```dart
import 'package:island_plugin_foundation/island_plugin_foundation.dart';

Future<void> setupPlugins() async {
  final controller = PluginController.instance;

  // Foundation APIs
  controller.registerApi('hooks', HooksApi());
  controller.registerApi('events', EventsApi());
  controller.registerApi('commands', CommandsApi());
  controller.registerApi('ui', UiApi());
  controller.registerApi('tasks', BackgroundTaskApi());

  // Your host-specific APIs
  controller.registerApi('notify', MyNotifyApi());
  controller.registerApi('network', MyNetworkApi());

  await controller.initialize();     // discover plugins from disk + assets
  await controller.loadAllAtStartup(); // launch-safe load with crash recovery
}
```

### 2. Listen to state changes

`PluginController` extends `ChangeNotifier`, so it works natively with Flutter's `ListenableBuilder`, Riverpod's `useListenable`, `AnimatedBuilder`, etc.:

```dart
ListenableBuilder(
  listenable: PluginController.instance,
  builder: (context, _) {
    final plugins = PluginController.instance.activePlugins;
    return Text('${plugins.length} plugins active');
  },
)
```

### 3. Fire events to plugins

From anywhere in your app, push realtime events into the plugin sandbox:

```dart
PluginController.instance.fireEvent('post.created', {'id': '123', 'title': 'Hello'});
```

Plugins receive them via `events.subscribe('post.created', 'myHandler')`.

### 4. Run hook chains

Intercept and transform content before it leaves the app:

```dart
final result = PluginHooks.instance.runBeforePostCreate({
  'title': 'Hello',
  'content': 'World',
  // ...
});

if (result.cancelled) {
  // A plugin returned null — block the operation
} else {
  // result.data holds the (possibly modified) payload
}
```

### 5. Render UI descriptors

When a plugin returns a UI descriptor from `ui.*` callbacks, your host app interprets the descriptor map and renders Flutter widgets. The foundation provides the `UiApi` that generates these descriptors — the rendering layer is yours to build:

```dart
// Inside your command palette or plugin page widget:
final descriptor = CommandsApi().executeCommand(command, runtime);
// descriptor is a Map<String, dynamic> — render it as Flutter widgets
```

## Architecture

```
┌──────────────────────────────────────────────────────┐
│  Host app (Island, or your app)                       │
│                                                       │
│  ┌──────────────┐  ┌──────────────────────────────┐  │
│  │ PluginController │  Host PluginApi subclasses  │  │
│  │ (ChangeNotifier) │  (notify, dashboard, network) │  │
│  └──────┬───────┘  └──────────────┬───────────────┘  │
│         │                         │                   │
│  ┌──────┴─────────────────────────┴───────────────┐  │
│  │              PluginManager (singleton)           │  │
│  │  Discovery · Lifecycle · Permissions · Events    │  │
│  └──────┬──────────────────────────────────────────┘  │
│         │                                             │
│  ┌──────┴──────────────────────────────────────────┐  │
│  │              JsBridge (singleton)                  │  │
│  │  One JsRuntime per plugin (isolated sandbox)       │  │
│  └─────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Extension model

The system is designed so **generic capabilities live in this package** and **domain-specific capabilities live in the host app**. Host apps plugin their own APIs by subclassing `PluginApi`:

```dart
class MyNotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:notify:notify', (args) {
      final title = args['title'] ?? '';
      final body = args['body'] ?? '';
      _showSystemNotification(title, body);
    });
  }

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    return '''
      var notify = function(title, body) {
        sendMessage("api:notify:notify", JSON.stringify({title: title, body: body}));
      };
    ''';
  }

  @override
  void onPluginUnload(String pluginId) {
    // cleanup per-plugin notification state
  }
}
```

## Foundation APIs reference

All included APIs are permission-gated. A plugin must declare the matching permission in `manifest.json` to access the API.

### `commands` — register palette commands

| Permission | `commandsRegister` |
|---|---|
| JS API | `commands.register_command(name, description, handler, icon?)` |

Commands appear in the host app's command palette (e.g., Ctrl/Cmd+K). The handler is a JS function name that can return a UI descriptor for result cards.

```javascript
function cmd_hello() {
  return ui.card("Hello!", "World");
}
commands.register_command("hello", "Say hello", "cmd_hello");
```

On the Dart side, read registered commands from `CommandsApi().commands` and execute them with `CommandsApi().executeCommand(command, runtime)`.

### `events` — subscribe to app events

| Permission | `eventsSubscribe` |
|---|---|
| JS API | `events.subscribe(eventName, handlerName)`, `events.list_events()` |

Default events: `post.created`, `post.updated`, `post.deleted`, `message.received`, `message.updated`, `message.deleted`, `chat.typing`, `app.foreground`, `app.background`. Customize by passing `availableEvents` to `EventsApi()`.

Firing events from Dart: `PluginController.instance.fireEvent('post.created', data)`.

### `hooks` — intercept content transforms

| Permission | `eventsSubscribe` |
|---|---|
| JS API | `hooks.<name>(handler)` where name is a hook name |

Default hook names: `before_post_create`, `before_message_send`, `before_post_display`, `before_message_display`. Customize by passing `hookNames` to `HooksApi()`.

Handlers receive a data object and must return the modified object, or `null` to cancel the operation.

Run chains from Dart with `PluginHooks.instance.runHook(name, data)` or the convenience methods `runBeforePostCreate`, `runBeforeMessageSend`, `runBeforePostDisplay`, `runBeforeMessageDisplay`.

### `ui` — build UI descriptors

| Permission | `uiRender` |
|---|---|
| JS API | `ui.card`, `ui.list_items`, `ui.button`, `ui.text`, `ui.section`, `ui.divider`, `ui.page`, `ui.row`, `ui.column`, `ui.spacing`, `ui.icon`, `ui.link`, `ui.input`, `ui.cloud_file`, `ui.image`, `ui.audio`, `ui.video`, `ui.plugin_asset` |

Each function returns a JSON-describable descriptor. The **host app** is responsible for rendering these descriptors into Flutter widgets. `ui.plugin_asset` is validated by `PluginManager.resolvePluginAsset()` to prevent path traversal.

### `tasks` — schedule background tasks

| Permission | `tasksSchedule` |
|---|---|
| JS API | `tasks.schedule(intervalSeconds, handlerName)` |

Tasks run on a periodic `Timer`. Each task has a 30-second watchdog timeout and a reentrancy guard. Tasks are automatically cancelled when the plugin unloads.

## Permission table

| Permission | Gates which API |
|---|---|
| `eventsSubscribe` | `events.*`, `hooks.*` |
| `commandsRegister` | `commands.*` |
| `uiRender` | `ui.*` |
| `tasksSchedule` | `tasks.*` |
| `notify` | `notify()`, `showAlert`, … (host-provided) |
| `networkInternet` | `internet.*` (host-provided) |
| `solarNetworkApi` | `solar.*` (host-provided) |
| `websocketSubscribe` | `ws.subscribe`, `ws.unsubscribe`, `ws.is_connected` (host-provided) |
| `websocketSend` | `ws.send` (host-provided) |

Only the first four are provided by this package. The rest are expected to be registered by the host app as custom `PluginApi` subclasses.

## Plugin format

Each plugin is a folder containing a `manifest.json` and an entry point:

```
my_plugin/
  manifest.json    # metadata + permissions
  main.js          # entry point (on_load / on_unload lifecycle)
  assets/          # optional plugin-owned assets
```

```json
{
  "id": "com.example.my_plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "entry": "main.js",
  "permissions": ["commandsRegister", "notify"]
}
```

Lifecycle hooks in JS: `on_load()` is called when the plugin activates, `on_unload()` before teardown.

## Installing plugins

```dart
// From disk (copies into the app's plugin directory)
await controller.installFromFolder('/path/to/my_plugin');

// From an inline source string (great for development / REPL)
controller.installInlinePlugin(
  name: 'Debug Plugin',
  source: 'function on_load() { notify("debug", "Loaded"); }',
  permissions: ['notify'],
);

// Uninstall
await controller.uninstallPlugin('com.example.my_plugin');
```

The plugins directory path is resolved via `path_provider`:

```dart
final path = await controller.resolvePluginsDirectoryPath();
```

## Startup safety

If a plugin crashes during load, it is **quarantined** — disabled and persisted to `SharedPreferences` so it cannot crash the app on next boot. Re-enable it with `controller.enablePlugin(id)` after reviewing.

## Web support

The JS bridge uses conditional exports: on native platforms it uses `flutter_js` (QuickJS / JavaScriptCore). On web it falls back to a no-op stub — discovery and API registration still work, but plugin JS execution is skipped.

## Key classes

| Class | Role |
|---|---|
| `PluginController` | UI-facing façade — `ChangeNotifier`, the main integration point |
| `PluginManager` | Core lifecycle engine — discovery, load, unload, permissions, events |
| `PluginInstance` | Runtime state of a single plugin |
| `JsBridge` | Manages all JS runtimes (one per plugin) |
| `JsRuntime` | Dart wrapper around a single JS execution context |
| `PluginHooks` | Runs content-transforming hook chains |
| `HookResult<T>` | Chain result — `proceed(data)` or `cancel(pluginId)` |
| `PluginManifest` | Freezed model — `id`, `name`, `version`, `permissions`, etc. |
| `PluginApi` | Abstract base for all API bridges (foundation + host) |

## Quick-start checklist

1. `controller.registerApi(namespace, api)` — register foundation + host APIs
2. Subclass `PluginApi` for domain-specific capabilities (network, UI chrome, notifications)
3. `await controller.initialize()` — discover plugins
4. `await controller.loadAllAtStartup()` — crash-safe batch load
5. `controller.fireEvent(name, data)` — push app events into the sandbox
6. `PluginHooks.instance.runHook(name, data)` — run hook chains from business logic
7. Render `ui.*` descriptors with your own Flutter widget tree
8. Listen to `PluginController.instance` for reactive UI updates
