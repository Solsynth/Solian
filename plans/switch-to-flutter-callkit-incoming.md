# Plan: Switch to flutter_callkit_incoming

## Context

We currently have a custom native CallKit implementation in `packages/island_call/ios/`. The user wants to explore switching to `flutter_callkit_incoming` (v3.1.2) which provides:
- All CXProviderDelegate events exposed to Dart
- PushKit/VoIP handling
- Incoming/outgoing call UI
- Mute, hold, audio session events

## Current Custom Implementation

**What we built:**
- `CallManager.swift` - CXProviderDelegate, PKPushRegistryDelegate
- `IslandCallPlugin.swift` - Method channel bridge
- `CallState.swift` - Observable state
- Custom event channels for CallKit events

**Events we emit:**
- `callAccepted` (with roomId)
- `callEnded`
- `muteChanged` (isMuted)
- `holdChanged` (not yet implemented)
- `audioSessionActivated` (not yet implemented)
- `audioSessionDeactivated` (not yet implemented)

## flutter_callkit_incoming Features

**Events provided:**
```dart
Event.actionCallIncoming      // incoming call received
Event.actionCallStart         // outgoing call started
Event.actionCallAccept        // call accepted
Event.actionCallDecline       // call declined
Event.actionCallEnded         // call ended
Event.actionCallTimeout       // missed call
Event.actionCallCallback      // callback from missed call
Event.actionCallToggleHold    // hold toggle (iOS)
Event.actionCallToggleMute    // mute toggle (iOS)
Event.actionCallToggleDmtf    // DTMF (iOS)
Event.actionCallToggleGroup   // group call (iOS)
Event.actionCallToggleAudioSession  // audio session (iOS)
Event.actionDidUpdateDevicePushTokenVoip  // VoIP token
Event.actionCallCustom        // custom action
```

**Key advantages:**
1. All events already exposed to Dart
2. PushKit integration built-in
3. Active maintenance (updated 3 days ago)
4. 503 likes on pub.dev
5. Handles edge cases (terminated state, background, etc.)

## Migration Plan

### Step 1: Add dependency
```yaml
# packages/island_call/pubspec.yaml
dependencies:
  flutter_callkit_incoming: ^3.1.2
```

### Step 2: Replace native CallKit code
- Remove `CallManager.swift` (CallKit delegates)
- Remove `CallState.swift` (state management)
- Keep `IslandCallPlugin.swift` for method channel (or simplify)
- Keep PushKit token handling

### Step 3: Update Dart side
Replace custom event channel with package's event stream:
```dart
FlutterCallkitIncoming.onEvent.listen((event) {
  switch (event!.event) {
    case Event.actionCallAccept:
      // Handle accept - connect to LiveKit
      break;
    case Event.actionCallEnded:
      // Handle end
      break;
    case Event.actionCallToggleMute:
      // Handle mute
      break;
    // etc.
  }
});
```

### Step 4: Update call flow
**Incoming call:**
1. VoIP push arrives → `FlutterCallkitIncoming.showCallkitIncoming()`
2. User accepts → `Event.actionCallAccept` event
3. Flutter connects to LiveKit
4. Call `FlutterCallkitIncoming.setCallConnected()` when ready

**Outgoing call:**
1. User taps call → `FlutterCallkitIncoming.startCall()`
2. `Event.actionCallStart` event
3. Flutter connects to LiveKit
4. `Event.actionCallAccept` when connected

### Step 5: Keep custom code for
- LiveKit connection (Flutter side)
- Call UI (CallScreen)
- Call state management (CallNotifier)
- Avatar/profile picture handling

## Files to Modify

**Remove/simplify:**
- `packages/island_call/ios/island_call/Sources/island_call/CallManager.swift`
- `packages/island_call/ios/island_call/Sources/island_call/CallState.swift`

**Update:**
- `packages/island_call/pubspec.yaml` (add dependency)
- `packages/island_call/lib/island_call.dart` (update API)
- `packages/island_call/lib/island_call_method_channel.dart` (simplify)
- `packages/island_call/lib/island_call_platform_interface.dart` (simplify)
- `lib/chat/pods/native_call_bridge.dart` (use new events)
- `lib/shared/widgets/app_wrapper.dart` (update event handling)

## Trade-offs

**Pros:**
- Less native code to maintain
- All CallKit events properly handled
- Active community support
- Handles edge cases (terminated state, etc.)

**Cons:**
- Less control over native behavior
- Dependency on third-party package
- May need to work around package limitations

## Questions for User

1. Do we want to keep any custom native code, or fully migrate to the package?
2. Should we handle VoIP pushes in native code or let the package handle them?
3. Do we need the "pending answer" pattern (wait for LiveKit connection before fulfilling answer)?

## Verification

1. Test incoming call (app in foreground, background, terminated)
2. Test outgoing call
3. Test mute toggle from CallKit UI
4. Test hold toggle from CallKit UI
5. Test call end from CallKit UI
6. Test VoIP push handling
7. Test audio session activation/deactivation
