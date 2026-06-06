// Quick Notes Plugin
// Demonstrates: commands, UI rendering, notifications.
// Jot down notes from the command palette.

// -- State -----------------------------------------------------------------

var notes = [];
var MAX_NOTES = 50;

// -- Commands --------------------------------------------------------------

function cmd_note() {
  if (notes.length === 0) {
    return ui.card("Quick Notes", "No notes yet. Use /note-add to create one.");
  }

  var items = [];
  for (var i = 0; i < notes.length; i++) {
    items.push((i + 1) + ". " + notes[i]);
  }

  return ui.card(
    "Quick Notes (" + notes.length + ")",
    items.join("\n"),
    [ui.button("Clear All", "cmd_note_clear")],
  );
}

function cmd_note_clear() {
  var count = notes.length;
  notes = [];
  notify("Quick Notes", "Cleared " + count + " notes.");
}

function cmd_note_stats() {
  var totalChars = 0;
  for (var i = 0; i < notes.length; i++) {
    totalChars += notes[i].length;
  }

  var avg = 0;
  if (notes.length > 0) {
    avg = Math.floor(totalChars / notes.length);
  }

  return ui.card(
    "Notes Stats",
    "Notes: " + notes.length + "/" + MAX_NOTES + "\n"
    + "Total characters: " + totalChars + "\n"
    + "Average length: " + avg,
  );
}

commands.register_command(
  "note",
  "Show all saved notes",
  "cmd_note",
);

commands.register_command(
  "note-clear",
  "Clear all saved notes",
  "cmd_note_clear",
  "delete",
);

commands.register_command(
  "note-stats",
  "Show notes statistics",
  "cmd_note_stats",
  "bar_chart",
);

// -- Lifecycle -------------------------------------------------------------

function on_load() {
  notify("Quick Notes", "Ready! Use /note to view, commands to manage.");
}
