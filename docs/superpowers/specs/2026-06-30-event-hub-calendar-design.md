# Event Hub Calendar Redesign

**Date:** 2026-06-30  
**Status:** Approved direction, pending spec review

## Goal

Turn `lib/accounts/screens/event_hub_screen.dart` from a calendar/countdown split screen into a proper scheduling system with an Apple Calendar-like feel, built with Material 3 and backed by the existing SolarNetwork/Passport calendar APIs.

## Scope

This redesign covers the Event Hub experience for viewing, navigating, and managing calendar events.

Included:
- Default month-first calendar experience
- Switchable Month / Agenda / Day views
- Selected-day agenda pane/list
- Timed day schedule view
- Reuse of existing create/edit/delete event flows
- Reuse of existing event detail route
- Proper responsive layouts for phone and wide screens
- Countdowns demoted from the primary information architecture into supporting schedule content

Excluded for v1:
- New backend calendar schema
- Recurrence model changes
- Drag-and-drop rescheduling
- Invitation/attendance workflow changes
- Cross-account shared calendar permissions UI

## Existing Constraints

The codebase already contains reusable calendar/event pieces that should be preserved where practical:
- `lib/accounts/event_calendar.dart` contains calendar providers and query state
- `lib/accounts/widgets/account/calendar_event_creation_sheet.dart` already supports creating/editing user events
- `lib/accounts/screens/calendar_event_detail_screen.dart` already supports detail viewing
- `packages/solar_network_sdk/lib/src/api/domains/accounts_api.dart` already exposes calendar and countdown endpoints

The backend already supports event ownership and subscriptions via Passport-side data models, so v1 should remain a client-side UI restructuring, not a backend rewrite.

## Product Direction

The Event Hub should feel like a real calendar application rather than a decorative event feed.

Primary default:
- Month view

Secondary switchable modes:
- Agenda view
- Day view

Design goals:
- Calm, dense, useful scheduling UI
- Minimal visual noise
- Immediate day selection feedback
- Event-first information hierarchy
- Material 3 styling using project colors
- Apple Calendar-inspired structure, but adapted to existing app patterns

## Information Architecture

### Phone
- App bar with month title, today action, and add-event action
- Segmented control for Month / Agenda / Day
- Main content switches by selected mode
- In Month mode, selected date controls the agenda section below the grid
- In Agenda mode, events are grouped chronologically by day
- In Day mode, timed events render in a vertical schedule layout

### Tablet/Desktop
- Two-pane layout
- Left pane: primary navigation surface for Month or Day
- Right pane: selected day agenda, event summary, and quick actions
- Agenda mode may use a broader list-first layout but still keep date context visible

## View Behavior

### Month View
- Month grid is the default landing view
- Header includes previous/next month, current month label, and Today shortcut
- Day cells show:
  - day number
  - subtle event indicators for user events / merged events / notable days
  - selected / today states
- Selecting a day updates the agenda/details pane immediately
- Month changes refetch the relevant calendar data from the existing provider layer

### Agenda View
- Chronological grouped schedule list
- Group by local date
- Show all-day events before timed events within each date section
- Empty dates are omitted
- This becomes the easiest scannable “what’s coming up” mode
- Countdowns, if kept visible, should appear as supporting metadata or a small supporting section rather than the primary experience

### Day View
- Vertical time-based schedule for the selected date
- All-day section at top if needed
- Timed events shown in hourly context
- Event cards should remain simple and legible
- Overlapping events do not need a complex side-by-side packing algorithm in v1; a stacked approximation is acceptable if data is sparse and readability stays high

## Event Interactions

For `name == 'me'`:
- Show add-event action
- Allow create from selected date
- Allow edit using the existing creation sheet
- Allow delete through existing detail flow or existing edit tooling

For other users:
- Read-only schedule browsing
- Existing event detail route remains available where supported

Interaction rules:
- Tapping an event opens `CalendarEventDetailRoute` when an event id is available
- Add/edit flows must invalidate or refresh the relevant calendar providers after mutation
- Month/day/agenda views must share one selected-date state to avoid desync

## Data Strategy

Reuse existing APIs rather than introducing new ones first.

Primary sources:
- Monthly grid data from the existing event calendar provider
- Event detail from existing event detail API/route
- Countdown data only if it can be folded into supporting schedule UI without dominating the screen

The UI should normalize the current event sources into one display-oriented model at the screen/widget layer if needed, but avoid new domain abstractions unless duplication becomes painful.

## Styling Rules

Use Material 3 and existing app color roles.

Rules:
- No decorative gradients/glass effects as the main style language
- Normal radii and compact spacing
- Calm containers with clear hierarchy
- Dense but readable event rows
- Clear today and selected-day states
- Avoid oversized chips, giant hero blocks, or dashboard-style KPI cards

## File Strategy

Prefer the smallest workable refactor.

Expected changes:
- Major rebuild of `lib/accounts/screens/event_hub_screen.dart`
- Likely reduction or replacement of `lib/accounts/widgets/account/event_calendar_content.dart`
- Possible simplification or replacement of `lib/accounts/widgets/account/event_calendar.dart`
- Small focused widgets may be added if they keep the screen code readable:
  - month grid shell
  - agenda list
  - day schedule timeline

Avoid introducing a large new subsystem or speculative abstraction layer.

## Testing Strategy

Follow TDD for the new behavior.

Minimum useful verification for v1:
- Widget tests for mode switching
- Widget tests for selected date driving the visible agenda/day content
- Widget tests for month navigation triggering the correct provider query state
- Basic interaction test for add-event action visibility on `me` vs other users

If the codebase already has a stronger pattern for widget/provider testing, follow it. Keep tests focused on behavior, not decorative rendering.

## Risks

- Existing calendar widgets may be too coupled to the current screen structure
- Day timeline complexity can expand quickly if overlapping events are over-handled
- Countdown integration can re-complicate the screen if not kept secondary

## v1 Recommendation

Ship the smallest version that feels like a real calendar:
- Month default
- Agenda and Day switcher
- Shared selected date state
- Reused create/edit/detail flows
- Supporting, not dominant, countdown content

This delivers the product goal without rewriting the backend or inventing a new scheduling domain.
