# Hover Edge Actions Design

## Goal

Introduce a reusable hover-revealed edge action control in `packages/island_ui_foundation`, use it to replace the dashboard's local animated horizontal scroll arrows, and extend `ExtendedRefreshIndicator` so it can expose a hoverable refresh button on the leading edge of the scroll axis while preserving keyboard refresh.

## Current Context

- `lib/misc/dashboard/dash.dart` contains a private `_AnimatedDashboardScrollArrow` used by a horizontal scroll container.
- `lib/shared/widgets/extended_refresh_indicator.dart` currently adds keyboard-triggered refresh (`Cmd/Ctrl+R`) and wraps its child in Flutter's `RefreshIndicator`.
- `packages/island_ui_foundation` already hosts reusable UI primitives and exports them through `lib/island_ui_foundation.dart`.

## Requirements

### Shared edge action primitive

- Add a reusable widget in `packages/island_ui_foundation` for hover-revealed edge actions.
- Preserve the current dashboard visual treatment:
  - circular dark translucent surface
  - slide + fade entrance/exit
  - disabled hit-testing when hidden
- Support both axes:
  - vertical placement for top/bottom edges
  - horizontal placement for left/right edges
- Support both directions on an axis:
  - leading/start edge
  - trailing/end edge
- Allow callers to provide the action content so the same primitive can render chevrons or refresh.

### Dashboard migration

- Replace the private `_AnimatedDashboardScrollArrow` in `lib/misc/dashboard/dash.dart` with the shared foundation widget.
- Keep current behavior unchanged:
  - show arrows only while hovered and scrollable in that direction
  - use left/right chevrons
  - retain current scroll animation and spacing

### Extended refresh indicator

- Extend `ExtendedRefreshIndicator` so it can show a hover-revealed refresh button.
- The refresh button should appear on the leading edge of the content axis:
  - top edge for vertical scrolling
  - left/start edge for horizontal scrolling
- Preserve existing keyboard refresh behavior.
- Keep existing pull-to-refresh behavior for vertical scroll views.
- Avoid forcing horizontal content through Flutter's `RefreshIndicator`, since it only supports vertical overscroll semantics.

## Proposed Design

### 1. Foundation widget

Create a new widget in `packages/island_ui_foundation/lib/src/hover_edge_action.dart` with this role:

- Render a child action button with shared animated visibility treatment.
- Accept:
  - `Axis axis`
  - `bool leading`
  - `bool isVisible`
  - `VoidCallback? onTap`
  - `Widget child`
  - optional size/offset tuning with sensible defaults matching dashboard behavior

Behavior:

- When visible, render at `Offset.zero`.
- When hidden, slide outward from the relevant edge:
  - vertical leading: `Offset(0, -hiddenDistance)`
  - vertical trailing: `Offset(0, hiddenDistance)`
  - horizontal leading: `Offset(-hiddenDistance, 0)`
  - horizontal trailing: `Offset(hiddenDistance, 0)`
- Wrap with `IgnorePointer(ignoring: !isVisible)`.
- Use `AnimatedSlide` and `AnimatedOpacity` with the same duration/curve used in dashboard today.
- Provide a helper constructor or lightweight default shell that produces the existing circular Material + InkWell treatment so callers do not duplicate it.

Export it from `packages/island_ui_foundation/lib/island_ui_foundation.dart`.

### 2. Dashboard integration

In `lib/misc/dashboard/dash.dart`:

- Remove the private `_AnimatedDashboardScrollArrow`.
- Replace its usages with the new foundation widget configured as:
  - `axis: Axis.horizontal`
  - `leading: true` for the left arrow
  - `leading: false` for the right arrow
  - icon child set to the same chevrons
- Keep placement in the surrounding `Positioned` widgets, because the dashboard still owns scrollability detection and scroll commands.

### 3. Extended refresh indicator behavior

Update `lib/shared/widgets/extended_refresh_indicator.dart`:

- Add an `axis` parameter with default `Axis.vertical`.
- Add an optional `showHoverRefresh` flag with default `true`.
- Wrap the rendered content in a `MouseRegion` + `Stack` so hover visibility can be tracked without changing child layout.
- Render the new foundation edge action in a `Positioned` layer:
  - vertical: centered along the top edge
  - horizontal: centered along the left/start edge
- Use a refresh icon button child and call `onRefresh` on tap.
- For `axis == Axis.vertical`, continue to wrap the child with `RefreshIndicator`.
- For `axis == Axis.horizontal`, skip `RefreshIndicator` and return the plain child beneath the hover action; keyboard refresh and button refresh still work.

## Error Handling

- `onRefresh` remains the single source of truth for refresh work; button and keyboard paths call the same callback.
- Hidden controls should not intercept pointer input.
- Horizontal mode intentionally omits pull-to-refresh to avoid nonfunctional UI expectations.

## Testing Strategy

Add widget tests covering:

- foundation hover edge action visibility gating:
  - hidden state disables taps
  - visible state enables taps
- `ExtendedRefreshIndicator`:
  - keyboard refresh still triggers callback
  - hover refresh button appears and triggers callback
  - horizontal mode renders without `RefreshIndicator`

Dashboard migration can be covered by existing compile-time safety unless there are already dashboard widget tests nearby; the main regression risk is visual parity, which can be checked manually.

## Files Expected To Change

- Create: `packages/island_ui_foundation/lib/src/hover_edge_action.dart`
- Modify: `packages/island_ui_foundation/lib/island_ui_foundation.dart`
- Modify: `lib/misc/dashboard/dash.dart`
- Modify: `lib/shared/widgets/extended_refresh_indicator.dart`
- Add tests in the most local existing Flutter test targets for:
  - the foundation widget
  - `ExtendedRefreshIndicator`

## Scope Check

This is one cohesive UI reuse task, not multiple independent subsystems. The shared primitive, dashboard migration, and refresh integration are tightly coupled and should be implemented under one plan.
