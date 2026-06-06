# Nekoizer Plugin
# Adds a '喵' to every message and post.

# ── Hooks ──────────────────────────────────────────────────────────────────────

def nekoize_post(data):
    content = data.get("content", "")
    if content and not content.endswith("喵"):
        data["content"] = content + " 喵"
    return data

def nekoize_message(data):
    content = data.get("content", "")
    if content and not content.endswith("喵"):
        data["content"] = content + " 喵"
    return data

hooks.before_post_create(nekoize_post)
hooks.before_message_send(nekoize_message)

# ── Commands ───────────────────────────────────────────────────────────────────

def cmd_nekoize():
    return ui.card(
        title="Nekoizer",
        body="Every post and message now ends with '喵'!\n\nYou can't escape the nya.",
    )

commands.register_command(
    "nekoize",
    "About the Nekoizer plugin",
    "cmd_nekoize",
)

# ── Lifecycle ──────────────────────────────────────────────────────────────────

def on_load():
    notify("Nekoizer", "喵~ All your messages will now be nekoized!")
