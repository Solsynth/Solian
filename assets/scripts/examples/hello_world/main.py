# Hello World Plugin
# The simplest possible plugin example.

def cmd_hello():
    notify("Hello World", "This is a plugin speaking!")
    return ui.card(
        title="Hello!",
        body="Greetings from the Hello World plugin.",
    )

commands.register_command(
    "hello",
    "Say hello from the plugin",
    "cmd_hello",
)

def on_load():
    notify("Hello World", "Plugin loaded successfully!")
