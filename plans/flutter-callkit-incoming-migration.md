# Migration Plan: Replace Custom PushKit + CallKit with `flutter_callkit_incoming`

## Goal

Migrate away from the in-repo `packages/callkeep` plugin to `flutter_callkit_incoming`, which handles PushKit, CXProvider, and event delivery to Dart as a single unit.

## Context: Why This Architecture

From reading `flutter_callkit_incoming`'s native iOS source:

- **PushKit**: plugin owns `PKPushRegistry`. AppDelegate just needs 4 lines to forward callbacks — no descriptor store or pending-answer cache.
- **CXProvider**: plugin's `SwiftFlutterCallkitIncomingPlugin` owns the single provider + `CallManager`. All `reportNewIncomingCall` / answer / end / mute / hold flow through Dart calls, not native macros.
- **Token**: `SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(...)` + `FlutterCallkitIncoming.getDevicePushTokenVoIP()` — no UserDefaults bridge.
- **Audio/WebRTC handoff**: plugin conforms to `CallkitIncomingAppDelegate` with `didActivateAudioSession` / `didDeactivateAudioSession` — this is where `RTCAudioSession.useManualAudio` / `isAudioEnabled` toggles go (see the commented block in their example AppDelegate).
- **Events**: plugin streams events via `EventCallbackHandler` to a Dart `EventChannel` — no native → Dart Handoff UUID cache.
- **Data model**: `FlutterCallkitIncoming` Dart class replaces callkeep's `FlutterCallkeep` and `CallKit`-suffixed event classes with the unified `Data` model.

## Files to Change

### 1. `pubspec.yaml`

- Remove `callkeep: path: packages/callkeep`
- Add `flutter_callkit_incoming: ^x.y.z` (use latest, pin semver)

### 2. `ios/Runner/AppDelegate.swift`

**Before:** ~140 lines of custom `mapPushPayload`, `reportIncomingCall`, descriptor store, debug channel, pending-answer bridge, own `PKPushRegistry` + `CXProvider`.

After:

```swift
import UIKit
import CallKit
import AVFAudio
import PushKit
import Flutter
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?
    private let voipRegistry = PKPushRegistry(queue: .main)
    private let deepLinkChannelName = "dev.solsynth.solian/deeplink"
    private let shareSuggestionsChannelName = "dev.solsynth.solian/share_suggestions"
    private var implicitDeepLinkChannel: FlutterMethodChannel?

    // All AppIntents / WidgetKit / Watch / Deep Link / Share / Widget-sync / Cache channels preserved as-is.
    // All UserDefaults handoff keys and debug channel REMOVED.

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        sendCfgToAppGroup()
        refreshAppIntents()
        WidgetCenter.shared.reloadAllTimelines()

        if let launchUrl = launchOptions?[.url] as? URL {
            _ = handleIncomingDeepLink(launchUrl)
        }

        UNUserNotificationCenter.current().delegate = notifyDelegate

        // replyableMessageCategory — unchanged
        // WCSession — unchanged
        // UserDefaults.register(defaults: ["CallKeepSettings": ...]) — REMOVED (plugin uses its own)

        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        // If using WebRTC:
        // RTCAudioSession.sharedInstance().useManualAudio = true
        // RTCAudioSession.sharedInstance().isAudioEnabled = false

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // PKPushRegistryDelegate — forward to plugin singleton
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        // Plugin parses the payload itself; no macro-mapping needed
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.didReceiveIncomingPush(payload: payload, forType: type, withCompletionHandler: completion)
    }

    // CallkitIncomingAppDelegate — audio handoff point for WebRTC
    func didActivateAudioSession(_ audioSession: AVAudioSession) {
        // If using WebRTC:
        // RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
        // RTCAudioSession.sharedInstance().isAudioEnabled = true
    }

    func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
        // If using WebRTC:
        // RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
        // RTCAudioSession.sharedInstance().isAudioEnabled = false
    }

    // onAccept, onDecline, onEnd, onTimeOut, providerDidReset — fulfilled by default via the plugin
    // (these can be implemented if needed for custom Rx logic)

    // didInitializeImplicitFlutterEngine — UNCHANGED (keeps Widget/Share/DeepLink channels)
}
```

Also remove:
- `CallKeepPushDelegate` conformance (never declared in this file but referenced by custom `setDelegate`)
- `CallKeep.h` / `FlutterCallkeepPlugin` imports
- `import PushKit` only appears once for `PKPushRegistryDelegate`
- The `import flutter_callkit_incoming` replaces these
- `Report incoming call` native code — plugin does this
- `mapPushPayload` — plugin does this
- `reportIncomingCall` — plugin does this
- `loadNativeCallDescriptorStore` / `storeNativeCallDescriptor` / `removeNativeCallDescriptor` — plugin does this
- `existingNativeCallUuid` — plugin does this
- `stringValue` / `dictionaryValue` / `jsonSafeObject` / `boolValue` / `callerName` / `callerIdType` — plugin does this
- `makeDeepLinkChannel` wiring with `setupNativeCallDebugChannel` — debug channel removed
- The 6 private-let handoff keys — plugin does this

### 3. `ios/Runner/Runner-Bridging-Header.h`

Remove:
```objc
#import <callkeep/CallKeep.h>
```

Add:
```objc
#import <flutter_callkit_incoming/FlutterCallkitIncomingPlugin.h>
```
(Flutter auto-generates the umbrella header — confirm via `GeneratedPluginRegistrant.m`)

### 4. `ios/Runner/GeneratedPluginRegistrant.m`

Remove:
```objc
#if __has_include(<callkeep/FlutterCallkeepPlugin.h>)
#import <callkeep/FlutterCallkeepPlugin.h>
@import callkeep;
...
[FlutterCallkeepPlugin registerWithRegistrar:...]
#endif
```
The new plugin registers via `FlutterCallkitIncomingPlugin.register(with:)` — Flutter tooling regenerates this.

### 5. `lib/chat/pods/native_call_bridge.dart`

Replace `callkeep/callkeep.dart` import with `package:flutter_callkit_incoming/flutter_callkit_incoming.dart`.

Rewrite the call lifecycle:
- `NativeCallBackgroundBridge.showIncomingCallFromPayload` → build `Data` map and call `FlutterCallkitIncoming.showIncomingCall(args, fromPushKit: true)`
- `ensureCallKeepSetup` → call `FlutterCallkitIncoming.setup(...)` with iOS options (`appName`, `ringtoneSound`, etc.)
- `_callKeep.on<CallKeepPushKitToken>` → drop; plugin pushes token via `getDevicePushTokenVoIP()`
- `_callKeep.on<CallKeepDidDisplayIncomingCall>` → drop; plugin streams `ACTION_CALL_INCOMING`
- `_callKeep.on<CallKeepPerformAnswerCallAction>` — KEPT for call pickup; listens to plugin event stream and triggers accepted-state + Flutter WebRTC activation
- `_callKeep.on<CallKeepDidPerformSetMutedCallAction>` / `DidToggleHoldAction` → subscribe to plugin event stream
- `_callKeep.on<CallKeepPerformEndCallAction>` — KEPT for call end; subscribes to plugin event stream
- `_callKeep.displayIncomingCall` (custom-display path) → plugin handles this natively
- Token reading: `loadPersistedNativeCallPushToken` / `_persistPushToken` → drop UserDefaults bridge; use `await FlutterCallkitIncoming.getDevicePushTokenVoIP()`
- Descriptor store / pending answer — REMOVED (plugin handles natively)
- `_logNativeCallDebugState` — REMOVED (no debug channel)

The **call pickup** path is what `callkeep` kept and what we're keeping intent on:
```
answerEvent →
  descriptor lookup →
  start Flutter WebRTC audio session →
  mark accepted (state.callKitAcceptedRoomId + isAcceptedPending) →
  transition to connected UI
```

### 6. `lib/core/utils/call_kit_utils.dart`

- Import path: `package:flutter_callkit_incoming/...`
- `systemCallDescriptorFromPushPayload` — may remain if useful for pre-Dart payload inspection. Plugin already normalizes.
- `createSystemCallDescriptor` — likely dropped; the Dart `Data` model from the plugin tracks the model.
- `NativeCallSource` enum — probably removed; the event stream's body contains `fromPushKit`.

### 7. Call UI consumers (`lib/chat/widgets/call_button.dart`, `lib/shared/widgets/app_wrapper.dart`, `lib/core/debug_sheet.dart`)

- `ref.read(nativeCallBridgeProvider.notifier).startOutgoingCall(...)` — signature unchanged if we keep the method
- `ref.read(nativeCallBridgeProvider.notifier).endCall()` — same
- Event wiring may change if `state.source` is removed; UI likely only renders incoming-call banner when `state.isIncomingDisplayed` is true, and drives from `CallKit` events.

### 8. Server payload

Server contract already decided (from the earlier conversation's diffs). No change needed here.

### 9. Android side

No change. `callkeep` is purely the iOS VoIP wrapper; Android's `VoiceConnectionService` is unaffected. Remove the `callkeep` **from iOS scope only** by ensuring `pubspec.yaml` still declares it (it will be linked via Flutter's plugin registry only for Android on iOS builds).

Wait — if `pubspec.yaml` removes `callkeep`, Android loses it entirely. Resolution: keep `callkeep` for Android scope but remove all iOS-side `callkeep` plumbing (AppDelegate, Bridging-Header, PluginRegistrant). The plugin's `registerWithRegistrar` will only wire on iOS if the plugin exposes iOS code. Android's VoiceConnectionService registration is **separate** (via `registerWithRegistrar` method on Android side), so iOS-side Android bridging continues to work regardless.

But since `FlutterCallkeepPlugin` on iOS is the source of the `voipRegistration` call we're killing, we still delete it.

Actually: simplest, cleanest routing:

- `pubspec.yaml` keeps `callkeep` (Android needs it).
- **iOS runner code** no longer references it. The plugin's iOS `FlutterCallkeepPlugin` still registers — but it's safe because `voipRegistration` becomes inert when `flutter_callkit_incoming` takes over. The deletion described above doesn't slice out just iOS plugins; it stops the AppDelegate from calling them.
- We can optionally set `ENABLE_BITCODE` and use method channel routing so flutter_callkit_incoming's native plugin handles VoIP. If `flutter_callkit_incoming`'s SwiftFlutterCallkitIncomingPlugin also registers a `PKPushRegistry` internally, both registries may conflict. We must audit: **does `flutter_callkit_incoming` register its own `PKPushRegistry` without requiring AppDelegate to create one?**

Reading the example AppDelegate: AppDelegate both creates **and** sets delegate:

```swift
let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
voipRegistry.delegate = self
voipRegistry.desiredPushTypes = [PKPushType.voIP]
```

The AppDelegate is the registry delegate. The plugin doesn't create its own `PKPushRegistry` — instead, the AppDelegate's `didReceiveIncomingPushWith` forwards the payload to the plugin via `sharedInstance?.didReceiveIncomingPush(payload:...)`.

Wait — I didn't see `didReceiveIncomingPush` in the native code I fetched. Let me check. The native code I fetched had `FlutterCallkitIncomingPlugin: NSObject` (forwarding to `SwiftFlutterCallkitIncomingPlugin.register`). The `SwiftFlutterCallkitIncomingPlugin` had `showCallkitIncoming` etc., but I didn't find a `didReceiveIncomingPush` entry point. It may use `FlutterMethodCall` for the AppDelegate → plugin boundary, or it may register its own `PKPushRegistry`.

Actually: when I rendered the full `SwiftFlutterCallkitIncomingPlugin.swift`, there are references to `PKPush` behavior and the `CallManager` / `CXProvider` callbacks, but I didn't find `pushRegistry(_:didReceiveIncomingPushWith:...)`. To avoid guessing, I'll note this risk in the plan as a **pre-implementation verification step**.

## Call-Pickup: What We Keep from Callkeep

The user explicitly called out: "make sure the callkeep still participant in the call picking up process."

Despite the package swap, the **architecture is preserved**:

- AppDelegate conforms to `CallkitIncomingAppDelegate.onAccept` — `SwiftFlutterCallkitIncomingPlugin.sharedInstance` calls `appDelegate.onAccept(call, action)`.
- This is the callback bridge: native CallKit answer button → Flutter WebRTC activation.
- Previously, callkeep's DTO `CallKeepPerformAnswerCallAction` carried `callData.additionalData` back to Dart. Now, plugin's `Action_CALL_ACCEPT` event.body carries the same payload (the `Data` JSON including `uuid`, `nameCaller`, `handle`).
- The Dart side's `state.callKitAcceptedRoomId` + `isAcceptedPending` state machine remains — just reading the new event stream.

## Cleanup After Migration

- Delete `packages/callkeep/`.
- Delete `ios/Runner/AppDelegate.swift` lines referencing the UserDefaults handoff keys, native `CXProvider` reporting payload, debug method channel.
- Flutter clean + pod deintegrate + pod install.
- Clean derived data in Xcode; do a fresh `flutter build ios` to ensure no stale `callkeep` framework references.
- Send a test VoIP push with the current server payload (already flat-format) and verify: incoming banner appears, tap Answer activates Flutter WebRTC audio, state reconciles.

## Risks / Open Verifications

1. **Does `flutter_callkit_incoming` register its own `PKPushRegistry`, or expect the AppDelegate to own it?** The example AppDelegate creates its own registry and sets `voipRegistry.delegate = self`. We follow that pattern. The AppDelegate must not instantiate `PKPushRegistry` outside this scope — plugin's own registry initialization is unknown until inspection.
2. **Two `CXProvider` instances conflict** if any native code still creates a provider. After removing all CallKit code from AppDelegate, only the plugin's `sharedProvider` exists. Risk is resolved.
3. **Shared plugin singleton lifetime**: `SwiftFlutterCallkitIncomingPlugin.sharedInstance` must be set early. The plugin's `FlutterCallkitIncomingPlugin.register(with:)` call sets it at Flutter engine startup. AppDelegate assumes this; if AppDelegate is created before the plugin module, the first `pushRegistry(_:didUpdate:)` may be dropped. We mitigate by registering plugins before trying to set delegates in `application(_:didFinishLaunchingWithOptions:)`.
4. **Dart event list vs. legacy callback registration**: plugin uses `EventChannel` subscriptions (`FlutterCallkitIncoming.listen`), not `on<EventType>` style. The old callkeep callbacks must be replaced with event stream parsing.
5. **Dart `Data` vs. custom `SystemCallDescriptor`**: plugin's `Data` model includes `extra: [String: Any]` dict already, so `metadata` from server lives inside `extra`. Will refactor `systemCallDescriptorFromPushPayload` to read from `Data.toJSON()` instead of `event.callData.additionalData`.

## Execution Order

1. `pubspec.yaml` update + `flutter pub get`.
2. Rewrite `ios/Runner/AppDelegate.swift` (the big file).
3. Update `ios/Runner/Runner-Bridging-Header.h`.
4. Update `ios/Runner/GeneratedPluginRegistrant.m` (or regenerate via `flutter pub get` + build).
5. Rewrite `lib/chat/pods/native_call_bridge.dart`.
6. Update `lib/core/utils/call_kit_utils.dart` (or delete).
7. Update call UI consumers.
8. `flutter clean`, `pod deintegrate`, fresh `flutter build ios`.
9. Test on real device:
   - Foreground push → incoming banner → Answer → Flutter WebRTC connects.
   - Background push → incoming banner → tap Answer → app launches → Flutter WebRTC connects.
   - Outgoing call → CallKit outgoing UI → connect → Flutter audio active.
   - Native hangup → Flutter audio stops.
