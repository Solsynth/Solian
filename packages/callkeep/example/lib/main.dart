import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:callkeep/callkeep.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// For fcm background message handler.
final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;

/*
{
    "uuid": "xxxxx-xxxxx-xxxxx-xxxxx",
    "caller_id": "+8618612345678",
    "caller_name": "hello",
    "caller_id_type": "number", 
    "has_video": false,

    "extra": {
        "foo": "bar",
        "key": "value",
    }
}
*/

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) {
  Logger logger = Logger();
  logger.d('backgroundMessage: message => ${message.toString()}');

  // Handle data message
  var data = message.data;
  var callerId = data['caller_id'] ?? message.senderId ?? "No Sender Id";
  var callerName = data['caller_name'] as String;
  var callUUID = data['uuid'] ?? const Uuid().v4();
  var hasVideo = data['has_video'] == "true";

  _callKeep.on<CallKeepPerformAnswerCallAction>(
      (CallKeepPerformAnswerCallAction event) {
    logger.d(
        'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callData.callUUID}');
    Timer(const Duration(seconds: 1), () {
      logger.d(
          '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerName');
      _callKeep.setCurrentCallActive(callUUID);
    });
    //_callKeep.endCall(event.callUUID);
  });

  _callKeep
      .on<CallKeepPerformEndCallAction>((CallKeepPerformEndCallAction event) {
    logger
        .d('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
  });
  if (!_callKeepInited) {
    _callKeep.setup(
      showAlertDialog: null,
      options: <String, dynamic>{
        'ios': {
          'appName': 'CallKeepDemo',
        },
        'android': {
          'additionalPermissions': [
            'android.permission.CALL_PHONE',
            'android.permission.READ_PHONE_NUMBERS'
          ],
          'foregroundService': {
            'channelId': 'com.example.call-kit-test',
            'channelName': 'callKitTest',
            'notificationTitle': 'My app is running on background',
            'notificationIcon': 'Path to the resource icon of the notification',
          },
        },
      },
    );
    _callKeepInited = true;
  }

  logger.d('backgroundMessage: displayIncomingCall ($callerId)');
  _callKeep.displayIncomingCall(
    uuid: callUUID,
    handle: callerId,
    callerName: callerName,
    hasVideo: hasVideo,
  );
  _callKeep.backToForeground();
  /*

  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    logger.d('notification => ${notification.toString()}');
  }

  // Or do other work.
  */
  return Future.value(null);
}

void main() {
  Logger.level = Level.all;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}

class MyAppState extends State<HomePage> {
  final FlutterCallkeep _callKeep = FlutterCallkeep();
  Map<String, Call> calls = {};
  String newUUID() => const Uuid().v4();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Logger logger = Logger();

  void iOSPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    logger.d('Settings registered: $settings');
  }

  void removeCall(String callUUID) {
    setState(() {
      calls.remove(callUUID);
    });
  }

  void setCallHeld(String callUUID, bool held) {
    setState(() {
      calls[callUUID]?.held = held;
    });
  }

  void setCallMuted(String callUUID, bool muted) {
    setState(() {
      calls[callUUID]?.muted = muted;
    });
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final callUUID = event.callData.callUUID;
    final number = calls[callUUID]?.number;
    if (callUUID == null) {
      logger.e("Tried to answer call but callUUID is null");
      return;
    }
    logger.d('[answerCall] $callUUID, number: $number');

    Timer(const Duration(seconds: 1), () {
      logger.d('[setCurrentCallActive] $callUUID, number: $number');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    final callUUID = event.callUUID;
    if (callUUID == null) {
      logger.e("Tried to endcall but callUUID is null");
      return;
    }
    logger.d('[endCall] $callUUID');
    removeCall(callUUID);
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    logger
        .d('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
    CallKeepDidReceiveStartCallAction event,
  ) async {
    final callData = event.callData;
    if (callData.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    final String callUUID = callData.callUUID ?? newUUID();
    final Call call = Call(callData.handle ?? "No Handle");
    setState(() {
      calls[callUUID] = call;
    });
    logger
        .d('[didReceiveStartCallAction] $callUUID, number: ${callData.handle}');

    _callKeep.startCall(
        uuid: callUUID, handle: call.number, callerName: call.number);

    Timer(const Duration(seconds: 1), () {
      logger.d('[setCurrentCallActive] $callUUID, number: ${callData.handle}');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    final callUUID = event.callUUID;
    if (callUUID == null) {
      logger.e("Tried to mute call but callUUID is null");
      return;
    }
    final number = calls[callUUID]?.number ?? "No Number";
    final muted = event.muted ?? false;
    logger.d(
        '[didPerformSetMutedCallAction] $callUUID, number: $number ($muted)');

    setCallMuted(callUUID, muted);
  }

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    final callUUID = event.callUUID;
    if (callUUID == null) {
      logger.e("Tried to hold call but callUUID is null");
      return;
    }
    final number = calls[callUUID]?.number ?? "No Number";
    final hold = event.hold ?? false;
    logger.d('[didToggleHoldCallAction] $callUUID, number: $number ($hold)');

    setCallHeld(callUUID, hold);
  }

  Future<void> hangup(String callUUID) async {
    _callKeep.endCall(callUUID);
    removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    _callKeep.setOnHold(uuid: callUUID, shouldHold: held);
    final String handle = calls[callUUID]?.number ?? "No Number";
    logger.d('[setOnHold: $held] $callUUID, number: $handle');
    setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    _callKeep.setMutedCall(uuid: callUUID, shouldMute: muted);
    final String handle = calls[callUUID]?.number ?? "No Number";
    logger.d('[setMutedCall: $muted] $callUUID, number: $handle');
    setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {
    final String number = calls[callUUID]?.number ?? "No Number";
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      _callKeep.updateDisplay(
          uuid: callUUID, callerName: 'New Name', handle: number);
    } else {
      _callKeep.updateDisplay(
          uuid: callUUID, callerName: number, handle: 'New Name');
    }

    logger.d('[updateDisplay: $number] $callUUID');
  }

  Future<void> displayIncomingCallDelayed(String number) async {
    Timer(const Duration(seconds: 3), () {
      displayIncomingCall(number);
    });
  }

  Future<void> displayIncomingCall(String number) async {
    final String callUUID = newUUID();
    setState(() {
      calls[callUUID] = Call(number);
    });
    logger.d('Display incoming call now');
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(<String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
        'foregroundService': {
          'channelId': 'com.company.my',
          'channelName': 'Foreground service for my app',
          'notificationTitle': 'My app is running on background',
          'notificationIcon': 'Path to the resource icon of the notification',
        },
      });
    }

    logger.d('[displayIncomingCall] $callUUID number: $number');
    _callKeep.displayIncomingCall(
        uuid: callUUID, handle: number, handleType: 'number', hasVideo: false);
  }

  void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
    final callUUID = event.callData.callUUID;
    final number = event.callData.handle ?? "No Number";
    if (callUUID == null) {
      logger.e("Tried to diplay incoming call but callUUID is null");
      return;
    }
    logger.d('[displayIncomingCall] $callUUID number: $number');
    setState(() {
      calls[callUUID] = Call(number);
    });
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    logger.d('[onPushKitToken] token => ${event.token}');
  }

  @override
  void initState() {
    super.initState();
    _callKeep.on<CallKeepDidDisplayIncomingCall>(didDisplayIncomingCall);
    _callKeep.on<CallKeepPerformAnswerCallAction>(answerCall);
    _callKeep.on<CallKeepDidPerformDTMFAction>(didPerformDTMFAction);
    _callKeep.on<CallKeepDidReceiveStartCallAction>(didReceiveStartCallAction);
    _callKeep.on<CallKeepDidToggleHoldAction>(didToggleHoldCallAction);
    _callKeep
        .on<CallKeepDidPerformSetMutedCallAction>(didPerformSetMutedCallAction);
    _callKeep.on<CallKeepPerformEndCallAction>(endCall);
    _callKeep.on<CallKeepPushKitToken>(onPushKitToken);

    _callKeep.setup(
      showAlertDialog: () => showDialog<bool>(
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
      ).then((value) => value ?? false),
      options: <String, dynamic>{
        'ios': {
          'appName': 'CallKeepDemo',
        },
        'android': {
          'additionalPermissions': [
            'android.permission.CALL_PHONE',
            'android.permission.READ_PHONE_NUMBERS'
          ],
          'foregroundService': {
            'channelId': 'com.example.call-kit-test',
            'channelName': 'callKitTest',
            'notificationTitle': 'My app is running on background',
            'notificationIcon': 'Path to the resource icon of the notification',
          },
        },
      },
    );

    if (Platform.isIOS) iOSPermission();

    if (Platform.isAndroid) {
      _firebaseMessaging.getToken().then((token) {
        logger.d('[FCM] token => $token');
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        logger.d('onMessage: $message');

        // Handle data message
        var data = message.data;
        var callerId = data['caller_id'] ?? message.senderId ?? "No Sender Id";
        var callerName = data['caller_name'] as String;
        var callUUID = data['uuid'] ?? const Uuid().v4();
        var hasVideo = data['has_video'] == "true";

        setState(() {
          calls[callUUID] = Call(callerId);
        });
        _callKeep.displayIncomingCall(
          uuid: callUUID,
          handle: callerId,
          callerName: callerName,
          hasVideo: hasVideo,
        );

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }

  Widget buildCallingWidgets() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: calls.entries
            .map((MapEntry<String, Call> item) =>
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('number: ${item.value.number}'),
                  Text('uuid: ${item.key}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          setOnHold(item.key, !item.value.held);
                        },
                        child: Text(item.value.held ? 'Unhold' : 'Hold'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          updateDisplay(item.key);
                        },
                        child: const Text('Display'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setMutedCall(item.key, !item.value.muted);
                        },
                        child: Text(item.value.muted ? 'Unmute' : 'Mute'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          hangup(item.key);
                        },
                        child: const Text('Hangup'),
                      ),
                    ],
                  )
                ]))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  displayIncomingCall('10086');
                },
                child: const Text('Display incoming call now'),
              ),
              ElevatedButton(
                onPressed: () async {
                  displayIncomingCallDelayed('10086');
                },
                child: const Text('Display incoming call now in 3s'),
              ),
              buildCallingWidgets()
            ],
          ),
        ),
      ),
    );
  }
}
