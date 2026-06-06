// Content Filter Plugin
// Demonstrates: hooks, events, commands, and UI rendering.

// -- State -----------------------------------------------------------------

var bannedWords = ["spam", "scam", "hack"];
var censorChar = "*";
var stats = { posts_filtered: 0, messages_filtered: 0, words_censored: 0 };

// -- Hooks -----------------------------------------------------------------

function _censor(text) {
  var result = text;
  var count = 0;
  for (var i = 0; i < bannedWords.length; i++) {
    var word = bannedWords[i];
    var lower = result.toLowerCase();
    var idx = lower.indexOf(word);
    while (idx !== -1) {
      var replacement = censorChar.repeat(word.length);
      result = result.substring(0, idx) + replacement + result.substring(idx + word.length);
      lower = result.toLowerCase();
      idx = lower.indexOf(word, idx + replacement.length);
      count++;
    }
  }
  return { text: result, count: count };
}

function filterPost(data) {
  var content = data.content || "";
  var title = data.title || "";

  var c1 = _censor(content);
  var c2 = _censor(title);

  var total = c1.count + c2.count;
  if (total > 0) {
    stats.posts_filtered++;
    stats.words_censored += total;
    data.content = c1.text;
    data.title = c2.text;
  }

  return data;
}

function filterMessage(data) {
  var content = data.content || "";

  var c = _censor(content);
  if (c.count > 0) {
    stats.messages_filtered++;
    stats.words_censored += c.count;
    data.content = c.text;
  }

  return data;
}

hooks.before_post_create(filterPost);
hooks.before_message_send(filterMessage);

// -- Event Handlers --------------------------------------------------------

function on_post_created() {}

function on_message_received() {}

events.subscribe("post.created", "on_post_created");
events.subscribe("message.received", "on_message_received");

// -- Commands --------------------------------------------------------------

function cmd_filter_stats() {
  var lines = [];
  lines.push("Posts filtered: " + stats.posts_filtered);
  lines.push("Messages filtered: " + stats.messages_filtered);
  lines.push("Words censored: " + stats.words_censored);
  lines.push("Banned words: " + bannedWords.length);
  return ui.card("Content Filter Stats", lines.join("\n"));
}

function cmd_filter_list() {
  if (bannedWords.length === 0) {
    return ui.card("Banned Words", "No banned words configured.");
  }
  return ui.card("Banned Words", bannedWords.join(", "));
}

function cmd_filter_reset() {
  stats.posts_filtered = 0;
  stats.messages_filtered = 0;
  stats.words_censored = 0;
  notify("Content Filter", "Statistics have been reset.");
}

commands.register_command(
  "filter-stats",
  "Show content filter statistics",
  "cmd_filter_stats",
);

commands.register_command(
  "filter-list",
  "List banned words",
  "cmd_filter_list",
);

commands.register_command(
  "filter-reset",
  "Reset filter statistics",
  "cmd_filter_reset",
  "refresh",
);

// -- Lifecycle -------------------------------------------------------------

function on_load() {
  notify("Content Filter", "Plugin loaded. Filtering " + bannedWords.length + " words.");
}

function on_unload() {}
