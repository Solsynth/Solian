// Nekoizer Plugin
// Adds a '喵' to every message and post.

var enabled = true;
var stats = {
  countCalled: 0,
  posts: 0,
  messages: 0,
};

// -- Hooks -----------------------------------------------------------------

function nekoizePost(data) {
  stats.countCalled++;
  stats.posts++;
  if (!enabled) return data;

  var content = data.content || "";
  if (content) {
    data.content = content.split("\n").map(function(line) {
      return line && !line.endsWith("喵") ? line + "喵" : line;
    }).join("\n");
  }
  return data;
}

function nekoizeMessage(data) {
  stats.countCalled++;
  stats.messages++;
  if (!enabled) return data;

  var content = data.content || "";
  if (content) {
    data.content = content.split("\n").map(function(line) {
      return line && !line.endsWith("喵") ? line + "喵" : line;
    }).join("\n");
  }
  return data;
}

hooks.before_post_create(nekoizePost);
hooks.before_message_send(nekoizeMessage);

// -- Commands --------------------------------------------------------------

function cmd_nekoize() {
  return ui.card(
    "Nekoizer",
    "Nekoizer is currently " + (enabled ? "enabled" : "disabled") + ".\n\n" +
      "Processed hook calls: " + stats.countCalled + "\n" +
      "Posts: " + stats.posts + "\n" +
      "Messages: " + stats.messages,
  );
}

commands.register_command(
  "nekoize",
  "About the Nekoizer plugin",
  "cmd_nekoize",
);

function cmd_toggle_nekoizer() {
  enabled = !enabled;
  notify("Nekoizer", enabled ? "Nekoizer enabled." : "Nekoizer disabled.");
  return buildDashboardNekoizer();
}

commands.register_command(
  "nekoizer-toggle",
  "Enable or disable Nekoizer",
  "cmd_toggle_nekoizer",
  "toggle_on",
);

function cmd_nekoizer_stats() {
  return ui.card(
    "Nekoizer Stats",
    "State: " + (enabled ? "enabled" : "disabled") + "\n" +
      "Hook calls: " + stats.countCalled + "\n" +
      "Posts: " + stats.posts + "\n" +
      "Messages: " + stats.messages,
  );
}

commands.register_command(
  "nekoizer-stats",
  "Show Nekoizer statistics",
  "cmd_nekoizer_stats",
  "analytics",
);

// -- Dashboard -------------------------------------------------------------

function buildDashboardNekoizer() {
  return ui.card(
    "Nekoizer",
    "State: " + (enabled ? "enabled" : "disabled") + "\n" +
      "Hook calls: " + stats.countCalled + "\n" +
      "Posts: " + stats.posts + " | Messages: " + stats.messages,
    [ui.button(enabled ? "Disable" : "Enable", "cmd_toggle_nekoizer")],
  );
}

ui.register_dashboard_item(
  "nekoizer-status",
  "Nekoizer status",
  "buildDashboardNekoizer",
  "pets",
);

// -- Lifecycle -------------------------------------------------------------

function on_load() {
  notify("Nekoizer", "喵~ All your messages will now be nekoized!");
}
