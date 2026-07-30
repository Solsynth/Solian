// UI Test Plugin — exercises every widget type and pane system

var clickCount = 0;
var textInput = "";

function on_load() {
  console.log("UI Test: loaded, registering dashboard item + commands");
  ui.register_dashboard_item("ui_demo", "UI Demo", "onDashboardRender", "palette");
  commands.register_command("ui.demo", "Open UI demo pane", "cmdDemo", "dashboard");
  commands.register_command("ui.all", "Show all widget types", "cmdShowAll", "widgets");
  commands.register_command("ui.interactive", "Interactive widgets", "cmdInteractive", "hand_gesture");
  commands.register_command("ui.open_pane", "Open pane via ui.open()", "cmdOpenPane", "open_in_new");
}

function on_unload() {
  console.log("UI Test: unloaded");
}

function onDashboardRender() {
  return ui.card("UI Test Plugin", "Click any command to open a floating pane", [
    ui.button("Demo Pane", "cmdDemo"),
    ui.button("All Widgets", "cmdShowAll"),
    ui.button("Interactive", "cmdInteractive"),
    ui.button("ui.open()", "cmdOpenPane")
  ]);
}

function cmdDemo() {
  return ui.page("UI Demo", [
    ui.text("This is a floating pane — drag the title bar to move it."),
    ui.spacing(8),
    ui.text("Resize from the bottom-right corner."),
    ui.spacing(8),
    ui.section("Quick Actions", [
      ui.button("Show All Widgets", "cmdShowAll"),
      ui.button("Interactive Demo", "cmdInteractive"),
      ui.button("ui.open()", "cmdOpenPane"),
    ]),
  ]);
}

function cmdShowAll() {
  return ui.page("All Widget Types", [
    ui.section("Typography", [
      ui.text("Plain text block."),
      ui.text("Another text line."),
    ]),
    ui.divider(),
    ui.section("Buttons", [
      ui.row([
        ui.button("Click Me", "onButtonClick"),
        ui.button("Disabled", null),
      ]),
    ]),
    ui.divider(),
    ui.section("Card", [
      ui.card("Card Title", "This is a card with title, body, and actions.", [
        ui.button("Action", "onButtonClick"),
      ]),
    ]),
    ui.divider(),
    ui.section("Lists", [
      ui.list_items([
        "Item one",
        "Item two",
        "Item three",
        ui.button("Action in list", "onButtonClick"),
      ]),
    ]),
    ui.divider(),
    ui.section("Links & Icons", [
      ui.row([
        ui.icon("home", 24, null, null),
        ui.icon("favorite", 24, null, null),
        ui.icon("settings", 24, null, null),
        ui.link("Flutter", "https://flutter.dev"),
      ]),
    ]),
    ui.divider(),
    ui.section("Row / Column nesting", [
      ui.row([
        ui.text("Left"),
        ui.text("Center"),
        ui.text("Right"),
      ]),
      ui.spacing(8),
      ui.column([
        ui.text("Above"),
        ui.text("Below"),
      ]),
    ]),
    ui.spacing(8),
    ui.text("That's all 19 widget types!"),
  ]);
}

function cmdInteractive() {
  return ui.page("Interactive Demo", [
    ui.text("Click count: " + clickCount),
    ui.spacing(8),
    ui.row([
      ui.button("Increment", "onIncrement"),
      ui.button("Reset", "onReset"),
    ]),
    ui.divider(),
    ui.text("Type something and press Enter:"),
    ui.spacing(4),
    ui.input("Your name", "Enter name...", "onNameInput"),
    ui.spacing(4),
    ui.text(textInput.length > 0 ? "Hello, " + textInput + "!" : ""),
  ]);
}

function cmdOpenPane() {
  ui.open("Opened via ui.open()", ui.card("Floating Card", "This pane was opened by calling ui.open() from a plugin. It can contain anything a normal pane can.", [
    ui.button("Close this pane", "onCloseThisPane"),
  ]));
  return ui.text("A new pane should appear!");
}

function onButtonClick() {
  notify("Button Clicked", "You clicked a button in the test plugin!");
  return ui.text("Button was clicked!");
}

function onIncrement() {
  clickCount++;
  return cmdInteractive();
}

function onReset() {
  clickCount = 0;
  return cmdInteractive();
}

function onNameInput(value) {
  textInput = value;
  return cmdInteractive();
}

function onCloseThisPane() {
  // ui.open() returns nothing that can close the pane from JS side,
  // but we can show a notification
  notify("Pane", "Close the pane manually with the X button");
  return ui.text("Click the X button in the title bar to close this pane.");
}
