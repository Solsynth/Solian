# Content Filter Plugin
# Demonstrates: hooks, events, commands, and UI rendering.

# ── State ──────────────────────────────────────────────────────────────────────

banned_words = ["spam", "scam", "hack"]
censor_char = "*"
stats = {"posts_filtered": 0, "messages_filtered": 0, "words_censored": 0}

# ── Hooks ──────────────────────────────────────────────────────────────────────

def _censor(text):
    """Replace banned words in text with censor characters."""
    result = text
    count = 0
    for word in banned_words:
        # Case-insensitive replacement
        lower = result.lower()
        idx = lower.find(word)
        while idx != -1:
            replacement = censor_char * len(word)
            result = result[:idx] + replacement + result[idx + len(word):]
            lower = result.lower()
            idx = lower.find(word, idx + len(replacement))
            count += 1
    return result, count

def filter_post(data):
    """Hook: modify post content before creation."""
    content = data.get("content", "")
    title = data.get("title", "")

    censored_content, c1 = _censor(content)
    censored_title, c2 = _censor(title)

    total = c1 + c2
    if total > 0:
        stats["posts_filtered"] += 1
        stats["words_censored"] += total
        data["content"] = censored_content
        data["title"] = censored_title

    return data

def filter_message(data):
    """Hook: modify message content before sending."""
    content = data.get("content", "")

    censored, count = _censor(content)
    if count > 0:
        stats["messages_filtered"] += 1
        stats["words_censored"] += count
        data["content"] = censored

    return data

hooks.before_post_create(filter_post)
hooks.before_message_send(filter_message)

# ── Event Handlers ─────────────────────────────────────────────────────────────

def on_post_created():
    """Called when any post is created."""
    pass

def on_message_received():
    """Called when a message is received."""
    pass

events.subscribe("post.created", "on_post_created")
events.subscribe("message.received", "on_message_received")

# ── Commands ───────────────────────────────────────────────────────────────────

def cmd_filter_stats():
    """Show content filter statistics."""
    lines = []
    lines.append("Posts filtered: " + str(stats["posts_filtered"]))
    lines.append("Messages filtered: " + str(stats["messages_filtered"]))
    lines.append("Words censored: " + str(stats["words_censored"]))
    lines.append("Banned words: " + str(len(banned_words)))
    return ui.card(
        title="Content Filter Stats",
        body="\n".join(lines),
    )

def cmd_filter_list():
    """List all banned words."""
    if len(banned_words) == 0:
        return ui.card(
            title="Banned Words",
            body="No banned words configured.",
        )
    return ui.card(
        title="Banned Words",
        body=", ".join(banned_words),
    )

def cmd_filter_reset():
    """Reset filter statistics."""
    stats["posts_filtered"] = 0
    stats["messages_filtered"] = 0
    stats["words_censored"] = 0
    notify("Content Filter", "Statistics have been reset.")

commands.register_command(
    "filter-stats",
    "Show content filter statistics",
    "cmd_filter_stats",
)

commands.register_command(
    "filter-list",
    "List banned words",
    "cmd_filter_list",
)

commands.register_command(
    "filter-reset",
    "Reset filter statistics",
    "cmd_filter_reset",
    icon="refresh",
)

# ── Lifecycle ──────────────────────────────────────────────────────────────────

def on_load():
    """Called when the plugin is loaded."""
    notify("Content Filter", "Plugin loaded. Filtering " + str(len(banned_words)) + " words.")

def on_unload():
    """Called when the plugin is unloaded."""
    pass
