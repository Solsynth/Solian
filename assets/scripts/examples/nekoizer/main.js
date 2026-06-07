// Nekoizer Plugin
// Adds a '喵' to every message and post.

// -- Hooks -----------------------------------------------------------------

function nekoizePost(data) {
  var content = data.content || "";
  if (content) {
    data.content = content.split("\n").map(function(line) {
      return line && !line.endsWith("喵") ? line + "喵" : line;
    }).join("\n");
  }
  return data;
}

function nekoizeMessage(data) {
  var content = data.content || "";
  if (content) {
    data.content = content.split("\n").map(function(line) {
      return line && !line.endsWith("喵") ? line + "喵" : line;
    }).join("\n");
  }
  notify("Nekoizer", "Hook fired! content: " + data.content);
  return data;
}

hooks.before_post_create(nekoizePost);
hooks.before_message_send(nekoizeMessage);

// -- Commands --------------------------------------------------------------

function cmd_nekoize() {
  return ui.card(
    "Nekoizer",
    "Every post and message now ends with '喵'!\n\nYou can't escape the nya.",
  );
}

commands.register_command(
  "nekoize",
  "About the Nekoizer plugin",
  "cmd_nekoize",
);

// -- Lifecycle -------------------------------------------------------------

function on_load() {
  notify("Nekoizer", "喵~ All your messages will now be nekoized!");
}
