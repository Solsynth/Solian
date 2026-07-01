# callkeep

[![Financial Contributors on Open Collective](https://opencollective.com/flutter-webrtc/all/badge.svg?label=financial+contributors)](https://opencollective.com/flutter-webrtc) [![pub package](https://img.shields.io/pub/v/callkeep.svg)](https://pub.dartlang.org/packages/callkeep) [![slack](https://img.shields.io/badge/join-us%20on%20slack-gray.svg?longCache=true&logo=slack&colorB=brightgreen)](https://join.slack.com/t/flutterwebrtc/shared_invite/zt-q83o7y1s-FExGLWEvtkPKM8ku_F8cEQ)

- iOS CallKit and Android ConnectionService for Flutter
- Support FCM and PushKit

> Keep in mind Callkit is banned in China, so if you want your app in the chinese AppStore consider include a basic alternative for notifying calls (ex. FCM notifications with sound).

`* P-C-M means -> presenter / controller / manager`

## Introduction

Callkeep acts as an intermediate between your call system (RTC, VOIP...) and the user, offering a native calling interface for handling your app calls.

This allows you (for example) to answer calls when your device is locked even if your app is terminated.

## Initial setup

Basic configuration. In Android a popup is displayed before starting requesting some permissions to work properly.

```dart
callKeep.setup(
    showAlertDialog:  () async {
        final BuildContext context = navigatorKey.currentContext!;

        return await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Permissions Required'),
                  content: const Text(
                      'This application needs to access your phone accounts'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            ) ??
            false;
    },
    options:<String, dynamic>{
        'ios': {
            'appName': 'CallKeepDemo',
        },
        'android': {
            'additionalPermissions': [
                'android.permission.CALL_PHONE',
                'android.permission.READ_PHONE_NUMBERS'
            ],
            // Required to get audio in background when using Android 11
            'foregroundService': {
            'channelId': 'com.company.my',
            'channelName': 'Foreground service for my app',
            'notificationTitle': 'My app is running on background',
            'notificationIcon': 'mipmap/ic_notification_launcher',
        },
    },
});
```

This configuration should be defined when your application wakes up, but keep in mind this alert will appear if you aren't granting the needed permissions yet.

A clean alternative is to control by yourself the required permissions when your application wakes up, and only invoke the `setup()` method if those permissions are granted.

## Events

Callkeep offers some events to handle native actions during a call.

These events are quite crucial because they act as an intermediate between the native calling UI and your call P-C-M.

What does it mean?

Assuming your application already implements some calling system (RTC, Voip, or whatever) with its own calling UI, you are using some basic controls:

<img width="40%" vspace="10" src="https://raw.githubusercontent.com/efraespada/callkeep/master/images/sample.png"></p>

> before implementing `callkeep`

- Hang up -> `presenter.hangUp()`
- Microphone switcher -> `presenter.microSwitch()`

> after implementing `callkeep`

- Hang up -> `callkeep.endCall(call_uuid)`
- Microphone switcher -> `callKeep.setMutedCall(uuid, true / false)`

Then you handle the action:

```dart
Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    print('CallKeepPerformAnswerCallAction ${event.callUUID}');
    // notify to your call P-C-M the answer action
};

 Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('CallKeepPerformEndCallAction ${event.callUUID}');
    // notify to your call P-C-M the end action
};

Future<void> didPerformSetMutedCallAction(CallKeepDidPerformSetMutedCallAction event) async {
    print('CallKeepDidPerformSetMutedCallAction ${event.callUUID}');
    // notify to your call P-C-M the muted switch action
};

 Future<void> didToggleHoldCallAction(CallKeepDidToggleHoldAction event) async {
    print('CallKeepDidToggleHoldAction ${event.callUUID}');
    // notify to your call P-C-M the hold switch action
};
```

```dart

 @override
  void initState() {
    super.initState();
    callKeep.on<CallKeepDidDisplayIncomingCall>(didDisplayIncomingCall);
    callKeep.on<CallKeepPerformAnswerCallAction>(answerCall);
    callKeep.on<CallKeepPerformEndCallAction>(endCall);
    callKeep.on<CallKeepDidToggleHoldAction>(didToggleHoldCallAction);
  }
```

## Display incoming calls in foreground, background or terminate state

The incoming call concept we are looking for is firing an incoming call action when "something" is received in our app.

I've tested this concept with FCM and it works pretty fine.

```dart
final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepStarted = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (!_callKeepStarted) {
    try {
      await _callKeep.setup(callSetup);
      _callKeepStarted = true;
    } catch (e) {
      print(e);
    }
  }

  // then process your remote message looking for some call uuid
  // and display any incoming call
}
```

Displaying incoming calls is really simple if you are receiving FCM messages (or whatever). This example shows how to show and close any incoming call:

> Notice that getting data from the payload can be done as you want, this is an example.

A payload data example:

```json
{
  "uuid": "xxxxx-xxxxx-xxxxx-xxxxx",
  "caller_id": "+0123456789",
  "caller_name": "Draco",
  "caller_id_type": "number",
  "has_video": "false"
}
```

A `RemoteMessage` extension for getting data:

```dart
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

extension RemoteMessageExt on RemoteMessage {
  Map<String, dynamic> getContent() {
    return jsonDecode(this.data["content"]);
  }

  Map<String, dynamic> payload() {
    return getContent()["payload"];
  }
}
```

Methods to show and close incoming calls:

```dart
Future<void> showIncomingCall(
  BuildContext context,
  RemoteMessage remoteMessage,
  FlutterCallkeep callKeep,
) async {
  var callerIdFrom = remoteMessage.payload()["caller_id"] as String;
  var callerName = remoteMessage.payload()["caller_name"] as String;
  var uuid = remoteMessage.payload()["uuid"] as String;
  var hasVideo = remoteMessage.payload()["has_video"] == "true";

  callKeep.on<CallKeepDidToggleHoldAction>(onHold);
  callKeep.on<CallKeepPerformAnswerCallAction>(answerAction);
  callKeep.on<CallKeepPerformEndCallAction>(endAction);
  callKeep.on<CallKeepDidPerformSetMutedCallAction>(setMuted);

  print('backgroundMessage: displayIncomingCall ($uuid)');

  bool hasPhoneAccount = await callKeep.hasPhoneAccount();
  if (!hasPhoneAccount) {
    hasPhoneAccount = await callKeep.hasDefaultPhoneAccount(context, callSetup["android"]);
  }

  if (!hasPhoneAccount) {
    return;
  }

  await callKeep.displayIncomingCall(uuid, callerIdFrom, localizedCallerName: callerName, hasVideo: hasVideo);
  callKeep.backToForeground();
}

Future<void> closeIncomingCall(
  RemoteMessage remoteMessage,
  FlutterCallkeep callKeep,
) async {
  var uuid = remoteMessage.payload()[MessageManager.CALLER_UUID] as String;
  print('backgroundMessage: closeIncomingCall ($uuid)');
  bool hasPhoneAccount = await callKeep.hasPhoneAccount();
  if (!hasPhoneAccount) {
    return;
  }
  await callKeep.endAllCalls();
}
```

Pass in your own dialog UI for permissions alerts

````dart
showAlertDialog: () async {
        final BuildContext context = navigatorKey.currentContext!;

        return await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Permissions Required'),
                  content: const Text(
                      'This application needs to access your phone accounts'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
```




### FAQ

> I don't receive the incoming call

Receiving incoming calls depends on FCM push messages (or the system you use) for handling the call information and displaying it.
Remember FCM push messages not always works due to data-only messages are classified as "low priority". Devices can throttle and ignore these messages if your application is in the background, terminated, or a variety of other conditions such as low battery or currently high CPU usage. To help improve delivery, you can bump the priority of messages. Note; this does still not guarantee delivery. More info [here](https://firebase.flutter.dev/docs/messaging/usage/#low-priority-messages)

> How can I manage the call if the app is terminated and the device is locked?

Even in this scenario, the `backToForeground()` method will open the app and your call P-C-M will be able to work.

## push test tool

Please refer to the [Push Toolkit](/tools/) to test callkeep offline push.
````
