// Dashboard Status Plugin
// Add this item from Dashboard -> Customize after loading the plugin.

var refreshCount = 0;

function buildDashboardStatus() {
  return ui.card(
    "Plugin status",
    "This dashboard item has refreshed " + refreshCount + " time(s).",
    [ui.button("Refresh", "refreshDashboardStatus")],
  );
}

function refreshDashboardStatus() {
  refreshCount++;
  return buildDashboardStatus();
}

ui.register_dashboard_item(
  "status",
  "Plugin status",
  "buildDashboardStatus",
  "dashboard",
);
