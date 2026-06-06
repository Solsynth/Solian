# Quick Notes Plugin
# Demonstrates: commands, UI rendering, notifications.
# Jot down notes from the command palette.

# ── State ──────────────────────────────────────────────────────────────────────

notes = []
MAX_NOTES = 50

# ── Commands ───────────────────────────────────────────────────────────────────

def cmd_note():
    """Show all saved notes."""
    if len(notes) == 0:
        return ui.card(
            title="Quick Notes",
            body="No notes yet. Use /note-add to create one.",
        )

    items = []
    for i in range(len(notes)):
        n = notes[i]
        items.append(str(i + 1) + ". " + n)

    return ui.card(
        title="Quick Notes (" + str(len(notes)) + ")",
        body="\n".join(items),
        actions=[
            ui.button("Clear All", "cmd_note_clear"),
        ],
    )

def cmd_note_clear():
    """Clear all saved notes."""
    count = len(notes)
    notes.clear()
    notify("Quick Notes", "Cleared " + str(count) + " notes.")

def cmd_note_stats():
    """Show notes statistics."""
    total_chars = 0
    for n in notes:
        total_chars = total_chars + len(n)

    avg = 0
    if len(notes) > 0:
        avg = total_chars // len(notes)

    return ui.card(
        title="Notes Stats",
        body="Notes: " + str(len(notes)) + "/" + str(MAX_NOTES) + "\n"
             + "Total characters: " + str(total_chars) + "\n"
             + "Average length: " + str(avg),
    )

commands.register_command(
    "note",
    "Show all saved notes",
    "cmd_note",
)

commands.register_command(
    "note-clear",
    "Clear all saved notes",
    "cmd_note_clear",
    icon="delete",
)

commands.register_command(
    "note-stats",
    "Show notes statistics",
    "cmd_note_stats",
    icon="bar_chart",
)

# ── Lifecycle ──────────────────────────────────────────────────────────────────

def on_load():
    notify("Quick Notes", "Ready! Use /note to view, commands to manage.")
