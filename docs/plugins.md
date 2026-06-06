# Plugin System

Solian supports a Python-based plugin system powered by [pocketpy](https://github.com/pocketpy/pocketpy). Plugins can hook into content creation, register commands in the command palette, show notifications, and render custom UI.

## Quick Start

### 1. Create a plugin folder

Each plugin is a folder containing two files:

```
my_plugin/
  manifest.json    # Metadata and permissions
  main.py          # Entry point
```

### 2. Write a manifest

```json
{
  "id": "com.example.my_plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "A short description of what this plugin does.",
  "entry": "main.py",
  "permissions": ["commandsRegister", "notify"],
  "background": false
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique reverse-domain identifier |
| `name` | Yes | Human-readable name |
| `version` | No | Semver string, defaults to `"1.0.0"` |
| `author` | No | Plugin author |
| `description` | No | Short description |
| `entry` | No | Entry point file, defaults to `"main.py"` |
| `permissions` | No | List of permissions the plugin needs |
| `background` | No | `true` to keep running in the background |
| `icon` | No | Material Symbols icon name |
| `homepage` | No | URL to the plugin's homepage |

### 3. Write the entry point

```python
def on_load():
    notify("My Plugin", "Plugin loaded!")

commands.register_command(
    "greet",
    "Say hello",
    "cmd_greet",
)

def cmd_greet():
    notify("Hello!", "Greetings from my plugin.")
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

```python
notify("Hello", "World")
```

---

### `commands`

Register commands that appear in the command palette (Ctrl/Cmd+K).

#### `commands.register_command(name, description, handler, icon=None)`

Register a command.

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | str | Command name (shown as `/name` in palette) |
| `description` | str | What the command does |
| `handler` | str | Name of the Python function to call |
| `icon` | str | Optional Material Symbols icon name |

The handler function can return a UI descriptor (from `ui.*`) to display a result card.

```python
def cmd_hello():
    return ui.card(title="Hello!", body="World")

commands.register_command("hello", "Say hello", "cmd_hello")
```

---

### `hooks`

Intercept and modify content before it reaches the server. Each hook receives a `dict` and must return a modified `dict`, or `None` to cancel the operation.

#### `hooks.before_post_create(handler)`

Called before a post is created. The handler receives a dict with keys like `title`, `content`, `description`, `tags`, etc.

```python
def add_signature(data):
    data["content"] = data["content"] + "\n\n— Sent via My Plugin"
    return data

hooks.before_post_create(add_signature)
```

#### `hooks.before_message_send(handler)`

Called before a chat message is sent. The handler receives `{"content": "..."}`.

```python
def censor(data):
    data["content"] = data["content"].replace("bad", "***")
    return data

hooks.before_message_send(censor)
```

#### `hooks.before_post_display(handler)`

Called before a post is rendered in the feed.

#### `hooks.before_message_display(handler)`

Called before a message is rendered in chat.

**Cancel by returning `None`:**

```python
def block_spam(data):
    if "spam" in data["content"]:
        return None  # cancels the send
    return data

hooks.before_message_send(block_spam)
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

```python
def on_new_message():
    notify("New Message", "You received a message!")

events.subscribe("message.received", "on_new_message")
```

---

### `ui`

Build UI descriptors that Flutter renders as widgets. All functions return a JSON string describing a widget.

#### `ui.card(title, body, actions=[])`

A Material card with title, body text, and optional action buttons.

```python
return ui.card(
    title="My Card",
    body="Card content here.",
    actions=[ui.button("OK", "cmd_ok")],
)
```

#### `ui.list_items(items)`

A vertical list of items.

```python
return ui.list_items(["Item 1", "Item 2", "Item 3"])
```

#### `ui.button(label, callback)`

A button descriptor (used inside `actions` lists).

```python
ui.button("Click Me", "cmd_on_click")
```

#### `ui.text(content)`

A text widget.

```python
ui.text("Hello, world!")
```

#### `ui.section(title, children)`

A titled section containing child widgets.

```python
ui.section("My Section", [ui.text("Line 1"), ui.text("Line 2")])
```

#### `ui.divider()`

A horizontal divider line.

---

### `tasks`

Schedule background tasks that run periodically.

#### `tasks.schedule(interval_seconds, handler_name)`

Schedule a function to run every N seconds.

```python
def check_updates():
    # runs every 60 seconds
    pass

tasks.schedule(60, "check_updates")
```

Background tasks have a 30-second watchdog timeout.

---

## Lifecycle Hooks

Define these functions in your plugin to hook into lifecycle events:

| Function | Called when |
|----------|-----------|
| `on_load()` | Plugin is loaded and activated |
| `on_unload()` | Plugin is being unloaded |

```python
def on_load():
    notify("My Plugin", "Ready!")

def on_unload():
    # cleanup if needed
    pass
```

## Examples

### Content Filter

Censors banned words in posts and messages before they are sent.

```python
banned_words = ["spam", "scam"]

def _censor(text):
    result = text
    count = 0
    for word in banned_words:
        lower = result.lower()
        idx = lower.find(word)
        while idx != -1:
            replacement = "*" * len(word)
            result = result[:idx] + replacement + result[idx + len(word):]
            lower = result.lower()
            idx = lower.find(word, idx + len(replacement))
            count += 1
    return result, count

def filter_post(data):
    content = data.get("content", "")
    censored, count = _censor(content)
    if count > 0:
        data["content"] = censored
    return data

def filter_message(data):
    content = data.get("content", "")
    censored, count = _censor(content)
    if count > 0:
        data["content"] = censored
    return data

hooks.before_post_create(filter_post)
hooks.before_message_send(filter_message)

def on_load():
    notify("Content Filter", "Filtering " + str(len(banned_words)) + " words.")
```

### Word Counter

Shows word count stats for the current post being composed.

```python
def cmd_word_count():
    return ui.card(
        title="Word Counter",
        body="This plugin counts words in your posts before they are sent.",
    )

def count_words(data):
    content = data.get("content", "")
    words = len(content.split())
    notify("Word Count", str(words) + " words in this post.")
    return data

hooks.before_post_create(count_words)
commands.register_command("word-count", "Count words in posts", "cmd_word_count")

def on_load():
    notify("Word Counter", "Ready! Posts will be counted before sending.")
```

### Inline Calculator

Evaluate math expressions from the command palette.

```python
def cmd_calc():
    # This is a placeholder - a real implementation would
    # take user input via the command palette
    return ui.card(
        title="Calculator",
        body="Use the inline editor to evaluate Python expressions.",
    )

commands.register_command("calc", "Open calculator", "cmd_calc")

def on_load():
    notify("Calculator", "Use /calc to open.")
```

## Debugging

Use the **Plugin Editor** (Settings → Plugins → Plugin Editor) to write and test code inline. Errors are shown in the output panel below the editor.

Check the app's log viewer (Cmd/Ctrl+K → "Log Viewer") for plugin-related log messages prefixed with `[Plugin]`, `[PyBridge]`, or the plugin's logger name.

## Limitations

- Pocketpy is a minimal Python 3 implementation — not all standard library modules are available
- No filesystem or network access (fully sandboxed)
- No `import` of external packages
- Native functions only accept positional arguments (keyword arguments are converted to positional)
- Maximum of 16 simultaneous VMs (multi-VM mode)
