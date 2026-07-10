# Plugin System

Solian supports a JavaScript-based plugin system powered by [flutter_js](https://pub.dev/packages/flutter_js) (QuickJS on Android/Linux/Windows, JavascriptCore on iOS/macOS). Plugins can hook into content creation, register commands in the command palette, show notifications, and render custom UI.

## Quick Start

### 1. Create a plugin folder

Each plugin is a folder containing two files:

```
my_plugin/
  manifest.json    # Metadata and permissions
  main.js          # Entry point
```

### 2. Write a manifest

```json
{
  "id": "com.example.my_plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "A short description of what this plugin does.",
  "entry": "main.js",
  "permissions": ["commandsRegister", "notify"],
  "background": false
}
```

A runnable dashboard-item example is included at
`assets/scripts/examples/dashboard_status/` in the source tree.

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique reverse-domain identifier |
| `name` | Yes | Human-readable name |
| `version` | No | Semver string, defaults to `"1.0.0"` |
| `author` | No | Plugin author |
| `description` | No | Short description |
| `entry` | No | Entry point file, defaults to `"main.js"` |
| `permissions` | No | List of permissions the plugin needs |
| `background` | No | `true` to keep running in the background |
| `icon` | No | Material Symbols icon name |
| `homepage` | No | URL to the plugin's homepage |

### 3. Write the entry point

```javascript
function on_load() {
  notify("My Plugin", "Plugin loaded!");
}

commands.register_command(
  "greet",
  "Say hello",
  "cmd_greet",
);

function cmd_greet() {
  notify("Hello!", "Greetings from my plugin.");
}
```

### 4. Install the plugin

**From the app:** Go to Settings → Plugins → Plugin Editor, paste your code, and tap Run.

**From disk:** Place the plugin folder in the app's plugins directory:
- **macOS/Linux:** `~/Library/Application Support/island/plugins/` or `~/.local/share/island/plugins/`
- **Android/iOS:** App's internal documents directory

## Permissions

Plugins must declare which APIs they intend to use in `manifest.json`. The sandbox only exposes APIs matching the declared permissions.

| Permission | APIs available |
|------------|---------------|
| `eventsSubscribe` | `events.*`, `hooks.*` |
| `commandsRegister` | `commands.*` |
| `uiRender` | `ui.*` |
| `networkInternet` | `internet.*` |
| `solarNetworkApi` | `solar.*` |
| `notify` | `notify()` |
| `tasksSchedule` | `tasks.*` |
| `sdkPostsRead` | *(future)* Read posts |
| `sdkPostsCreate` | *(future)* Create posts |
| `sdkChatRead` | *(future)* Read messages |
| `sdkChatSend` | *(future)* Send messages |
| `sdkDriveRead` | *(future)* Read files |
| `sdkDriveWrite` | *(future)* Write files |
| `sdkUserRead` | *(future)* Read user profile |

## API Reference

### `notify(title, body)`

Show an in-app notification.

```javascript
notify("Hello", "World");
```

---

### `commands`

Register commands that appear in the command palette (Ctrl/Cmd+K).

#### `commands.register_command(name, description, handler, icon)`

Register a command.

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Command name (shown as `/name` in palette) |
| `description` | string | What the command does |
| `handler` | string | Name of the JavaScript function to call |
| `icon` | string | Optional Material Symbols icon name |

The handler function can return a UI descriptor (from `ui.*`) to display a result card.

```javascript
function cmd_hello() {
  return ui.card("Hello!", "World");
}

commands.register_command("hello", "Say hello", "cmd_hello");
```

---

### `hooks`

Intercept and modify content before it reaches the server. Each hook receives an object and must return a modified object, or `null` to cancel the operation.

#### `hooks.before_post_create(handler)`

Called before a post is created. The handler receives an object with keys like `title`, `content`, `description`, `tags`, etc.

```javascript
function addSignature(data) {
  data.content = data.content + "\n\n— Sent via My Plugin";
  return data;
}

hooks.before_post_create(addSignature);
```

#### `hooks.before_message_send(handler)`

Called before a chat message is sent. The handler receives `{content: "..."}`.

```javascript
function censor(data) {
  data.content = data.content.replace(/bad/g, "***");
  return data;
}

hooks.before_message_send(censor);
```

#### `hooks.before_post_display(handler)`

Called before a post is rendered in the feed.

#### `hooks.before_message_display(handler)`

Called before a message is rendered in chat.

**Cancel by returning `null`:**

```javascript
function blockSpam(data) {
  if (data.content.includes("spam")) {
    return null; // cancels the send
  }
  return data;
}

hooks.before_message_send(blockSpam);
```

---

### `events`

Subscribe to app events.

#### `events.subscribe(event_name, handler_name)`

Subscribe to an event. The handler function is called when the event fires.

| Event | Fired when |
|-------|-----------|
| `post.created` | A post is created |
| `post.updated` | A post is updated |
| `post.deleted` | A post is deleted |
| `message.received` | A new message arrives |
| `message.updated` | A message is edited |
| `message.deleted` | A message is deleted |
| `chat.typing` | Someone is typing |

```javascript
function onNewMessage() {
  notify("New Message", "You received a message!");
}

events.subscribe("message.received", "onNewMessage");
```

---

### `ui`

Build UI descriptors that Flutter renders as widgets. All functions return a JSON string describing a widget.

#### `ui.card(title, body, actions)`

A Material card with title, body text, and optional action buttons.

```javascript
return ui.card(
  "My Card",
  "Card content here.",
  [ui.button("OK", "cmd_ok")],
);
```

#### `ui.list_items(items)`

A vertical list of items.

```javascript
return ui.list_items(["Item 1", "Item 2", "Item 3"]);
```

#### `ui.button(label, callback)`

A button descriptor (used inside `actions` lists).

```javascript
ui.button("Click Me", "cmd_on_click");
```

#### `ui.text(content)`

A text widget.

```javascript
ui.text("Hello, world!");
```

#### `ui.section(title, children)`

A titled section containing child widgets.

```javascript
ui.section("My Section", [ui.text("Line 1"), ui.text("Line 2")]);
```

#### `ui.divider()`

A horizontal divider line.

#### `ui.register_dashboard_item(id, title, handler, icon)`

Register a configurable dashboard item. The handler is called whenever the
item is displayed and must return a `ui.*` descriptor. Registered items appear
in Dashboard → Customize on both narrow and expanded layouts. `id` only needs
to be unique within the plugin; the app namespaces it by plugin ID.

```javascript
function buildStatus() {
  return ui.card(
    "Build status",
    "All systems are ready.",
    [ui.button("Refresh", "buildStatus")],
  );
}

ui.register_dashboard_item(
  "status",
  "Build status",
  "buildStatus",
  "dashboard",
);
```

Dashboard callbacks run in the same plugin sandbox. Return another UI
descriptor from an action callback to replace the visible item.

---

### `internet`

`networkInternet` grants a plugin outbound HTTP(S) access. It does not include
cookies, app credentials, or the user's Solar Network token.

#### `internet.request(method, url, options, callback)`

Requests run asynchronously. `callback` is the name of a function that
receives `{ok, status, data}` on completion, or `{ok: false, error}` if the
request could not be made. Request headers cannot override `Authorization`,
`Cookie`, or `Host`.

```javascript
function onStatus(response) {
  if (response.ok) notify("Status", "Request completed");
}

internet.request("GET", "https://example.com/status", null, "onStatus");
```

### `solar`

`solarNetworkApi` grants full access to the currently configured Solar Network
API. Requests must use a relative API path; the host app attaches the current
user token itself and never exposes it to JavaScript. This permission is
separate from `networkInternet`.

#### `solar.request(method, path, options, callback)`

Uses the same asynchronous callback shape as `internet.request`.

```javascript
function onProfile(response) {
  if (!response.ok) return;
  notify("Solar Network", "Authenticated request completed");
}

solar.request("GET", "/sphere/accounts/me", null, "onProfile");
```

---

### `tasks`

Schedule background tasks that run periodically.

#### `tasks.schedule(interval_seconds, handler_name)`

Schedule a function to run every N seconds.

```javascript
function checkUpdates() {
  // runs every 60 seconds
}

tasks.schedule(60, "checkUpdates");
```

Background tasks have a 30-second watchdog timeout.

---

## Lifecycle Hooks

Define these functions in your plugin to hook into lifecycle events:

| Function | Called when |
|----------|-----------|
| `on_load()` | Plugin is loaded and activated |
| `on_unload()` | Plugin is being unloaded |

```javascript
function on_load() {
  notify("My Plugin", "Ready!");
}

function on_unload() {
  // cleanup if needed
}
```

## Examples

### Content Filter

Censors banned words in posts and messages before they are sent.

```javascript
var bannedWords = ["spam", "scam"];

function _censor(text) {
  var result = text;
  var count = 0;
  for (var i = 0; i < bannedWords.length; i++) {
    var word = bannedWords[i];
    var lower = result.toLowerCase();
    var idx = lower.indexOf(word);
    while (idx !== -1) {
      var replacement = "*".repeat(word.length);
      result = result.substring(0, idx) + replacement + result.substring(idx + word.length);
      lower = result.toLowerCase();
      idx = lower.indexOf(word, idx + replacement.length);
      count++;
    }
  }
  return { text: result, count: count };
}

function filterPost(data) {
  var c = _censor(data.content || "");
  if (c.count > 0) {
    data.content = c.text;
  }
  return data;
}

function filterMessage(data) {
  var c = _censor(data.content || "");
  if (c.count > 0) {
    data.content = c.text;
  }
  return data;
}

hooks.before_post_create(filterPost);
hooks.before_message_send(filterMessage);

function on_load() {
  notify("Content Filter", "Filtering " + bannedWords.length + " words.");
}
```

### Word Counter

Shows word count stats for the current post being composed.

```javascript
function cmdWordCount() {
  return ui.card(
    "Word Counter",
    "This plugin counts words in your posts before they are sent.",
  );
}

function countWords(data) {
  var content = data.content || "";
  var words = content.split(/\s+/).length;
  notify("Word Count", words + " words in this post.");
  return data;
}

hooks.before_post_create(countWords);
commands.register_command("word-count", "Count words in posts", "cmdWordCount");

function on_load() {
  notify("Word Counter", "Ready! Posts will be counted before sending.");
}
```

### Inline Calculator

Evaluate math expressions from the command palette.

```javascript
function cmdCalc() {
  return ui.card(
    "Calculator",
    "Use the inline editor to evaluate JavaScript expressions.",
  );
}

commands.register_command("calc", "Open calculator", "cmdCalc");

function on_load() {
  notify("Calculator", "Use /calc to open.");
}
```

## Debugging

Use the **Plugin Editor** (Settings → Plugins → Plugin Editor) to write and test code inline. Errors are shown in the output panel below the editor.

Check the app's log viewer (Cmd/Ctrl+K → "Log Viewer") for plugin-related log messages prefixed with `[PluginManager]`, `[JsBridge]`, or the plugin's logger name.

## Limitations

- Runs in a sandboxed JavaScript runtime (QuickJS / JavascriptCore)
- No filesystem or network access (fully sandboxed)
- No `import` of external modules
- Maximum of 16 simultaneous runtimes
- `networkInternet` and `solarNetworkApi` are powerful opt-in permissions;
  review plugins requesting them before installation.
- Plugins whose startup load is interrupted or fails are disabled on the next
  launch. Re-enable them manually in Settings → Plugins after reviewing the
  plugin or its error message.
