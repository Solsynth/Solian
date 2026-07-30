// Task Test Plugin

var counter = 0;

function on_load() {
  console.log("Task Test: on_load called, scheduling task...");
  tasks.schedule(5, "tick");
}

function tick() {
  counter++;
  console.log("Task Test: tick #" + counter);
  notify("Task Test", "Tick #" + counter);
}
