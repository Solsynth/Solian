import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:logger/logger.dart';

import 'actions.dart';
import 'event.dart';

bool get isIOS => Platform.isIOS;
bool get supportConnectionService =>
    !isIOS && int.parse(Platform.version) >= 23;

class FlutterCallkeep extends EventManager {
  factory FlutterCallkeep() {
    return _instance;
  }
  FlutterCallkeep._internal() {
    _event.setMethodCallHandler(eventListener);
  }
  static final FlutterCallkeep _instance = FlutterCallkeep._internal();
  static const MethodChannel _channel = MethodChannel('FlutterCallKeep.Method');
  static const MethodChannel _event = MethodChannel('FlutterCallKeep.Event');
  Future<bool> Function()? _showAlertDialog;

  @override
  Logger logger = Logger();

  Future<void> setup({
    Future<bool> Function()? showAlertDialog,
    required Map<String, dynamic> options,
    bool backgroundMode = false,
  }) async {
    _showAlertDialog = showAlertDialog;
    if (!isIOS) {
      await _setupAndroid(
        options: options['android'],
        backgroundMode: backgroundMode,
      );
      return;
    }
    await _setupIOS(options: options['ios']);
  }

  Future<void> registerPhoneAccount() async {
    if (isIOS) {
      return;
    }
    return _channel
        .invokeMethod<void>('registerPhoneAccount', <String, dynamic>{});
  }

  Future<void> registerAndroidEvents() async {
    if (isIOS) {
      return;
    }
    return _channel.invokeMethod<void>('registerEvents', <String, dynamic>{});
  }

  Future<bool> hasDefaultPhoneAccount(
    Map<String, dynamic> options,
  ) async {
    if (!isIOS) {
      return await _hasDefaultPhoneAccount(options);
    }

    // return true on iOS because we don't want to block the endUser
    return true;
  }

  Future<bool?> _checkDefaultPhoneAccount() async {
    return await _channel.invokeMethod<bool>(
      'checkDefaultPhoneAccount',
      <String, dynamic>{},
    );
  }

  Future<bool> _hasDefaultPhoneAccount(Map<String, dynamic> options) async {
    final hasDefault = await _checkDefaultPhoneAccount();
    if (hasDefault == true) {
      final shouldOpenAccounts = await _alert();
      if (shouldOpenAccounts) {
        await _openPhoneAccounts();
        return true;
      }
      return false;
    }
    return true;
  }

  Future<bool> _hasPhoneAccount() async {
    final result = await _channel.invokeMethod<bool>(
      'hasPhoneAccount',
      <String, dynamic>{},
    );
    return result ?? false;
  }

  Future<void> displayIncomingCall({
    required String uuid,
    required String handle,
    String callerName = '',
    String handleType = 'number',
    bool hasVideo = false,
    Map<String, dynamic> additionalData = const {},
  }) async {
    await _channel.invokeMethod<void>('displayIncomingCall', <String, dynamic>{
      'uuid': uuid,
      'handle': handle,
      'handleType': handleType,
      'hasVideo': hasVideo,
      'callerName': callerName,
      'additionalData': additionalData
    });
  }

  Future<void> answerIncomingCall(String uuid) async {
    await _channel.invokeMethod<void>(
      'answerIncomingCall',
      <String, dynamic>{'uuid': uuid},
    );
  }

  Future<void> startCall({
    required String uuid,
    required String handle,
    required String callerName,
    String handleType = 'number',
    bool hasVideo = false,
    Map<String, dynamic> additionalData = const {},
  }) async {
    await _channel.invokeMethod<void>('startCall', <String, dynamic>{
      'uuid': uuid,
      'handle': handle,
      'callerName': callerName,
      'handleType': handleType,
      'hasVideo': hasVideo,
      'additionalData': additionalData
    });
  }

  Future<void> reportConnectingOutgoingCallWithUUID(String uuid) async {
    //only available on iOS
    if (isIOS) {
      await _channel.invokeMethod<void>('reportConnectingOutgoingCallWithUUID',
          <String, dynamic>{'uuid': uuid});
    }
  }

  Future<void> reportConnectedOutgoingCallWithUUID(String uuid) async {
    //only available on iOS
    if (isIOS) {
      await _channel.invokeMethod<void>('reportConnectedOutgoingCallWithUUID',
          <String, dynamic>{'uuid': uuid});
    }
  }

  Future<void> reportStartedCallWithUUID(String uuid) async {
    if (!isIOS) {
      await _channel.invokeMethod<void>(
          'reportStartedCallWithUUID', <String, dynamic>{'uuid': uuid});
    }
  }

  Future<void> reportEndCallWithUUID({
    required String uuid,
    required int reason,
    bool notify = true,
  }) async {
    return await _channel.invokeMethod<void>(
      'reportEndCallWithUUID',
      <String, dynamic>{
        'uuid': uuid,
        'reason': reason,
        'notify': notify,
      },
    );
  }

  /*
   * Android explicitly states we reject a call
   * On iOS we just notify of an endCall
   */
  Future<void> rejectCall(String uuid) async {
    if (!isIOS) {
      await _channel
          .invokeMethod<void>('rejectCall', <String, dynamic>{'uuid': uuid});
    } else {
      await _channel
          .invokeMethod<void>('endCall', <String, dynamic>{'uuid': uuid});
    }
  }

  Future<bool> isCallActive(String uuid) async {
    var resp = await _channel
        .invokeMethod<bool>('isCallActive', <String, dynamic>{'uuid': uuid});
    if (resp != null) {
      return resp;
    }
    return false;
  }

  Future<List<String>> activeCalls() async {
    var resp = await _channel
        .invokeMethod<List<Object?>?>('activeCalls', <String, dynamic>{});
    if (resp != null) {
      var uuids = <String>[];
      resp.forEach((element) {
        if (element is String) {
          uuids.add(element);
        }
      });
      return uuids;
    }
    return [];
  }

  Future<void> endCall(String uuid) async => await _channel
      .invokeMethod<void>('endCall', <String, dynamic>{'uuid': uuid});

  Future<void> endAllCalls() async =>
      await _channel.invokeMethod<void>('endAllCalls', <String, dynamic>{});

  FutureOr<bool> hasPhoneAccount() async {
    if (isIOS) {
      return true;
    }
    var resp = await _channel
        .invokeMethod<bool>('hasPhoneAccount', <String, dynamic>{});
    if (resp != null) {
      return resp;
    }
    return false;
  }

  Future<bool> hasOutgoingCall() async {
    if (isIOS) {
      return true;
    }
    var resp = await _channel
        .invokeMethod<bool>('hasOutgoingCall', <String, dynamic>{});
    if (resp != null) {
      return resp;
    }
    return false;
  }

  Future<void> setMutedCall(
          {required String uuid, required bool shouldMute}) async =>
      await _channel.invokeMethod<void>(
          'setMutedCall', <String, dynamic>{'uuid': uuid, 'muted': shouldMute});

  Future<void> sendDTMF({required String uuid, required String key}) async =>
      await _channel.invokeMethod<void>(
          'sendDTMF', <String, dynamic>{'uuid': uuid, 'key': key});

  Future<void> checkIfBusy() async => isIOS
      ? await _channel.invokeMethod<void>('checkIfBusy', <String, dynamic>{})
      : throw Exception('CallKeep.checkIfBusy was called from unsupported OS');

  Future<void> checkSpeaker() async => isIOS
      ? await _channel.invokeMethod<void>('checkSpeaker', <String, dynamic>{})
      : throw Exception('CallKeep.checkSpeaker was called from unsupported OS');

  Future<void> setAvailable({bool available = true}) async {
    if (isIOS) {
      return;
    }
    // Tell android that we are able to make outgoing calls
    await _channel.invokeMethod<void>(
        'setAvailable', <String, dynamic>{'available': available});
  }

  Future<void> setCurrentCallActive(String callUUID) async {
    if (isIOS) {
      return;
    }

    await _channel.invokeMethod<void>(
        'setCurrentCallActive', <String, dynamic>{'uuid': callUUID});
  }

  Future<void> updateDisplay({
    required String uuid,
    required String callerName,
    required String handle,
  }) async =>
      await _channel.invokeMethod<void>('updateDisplay', <String, dynamic>{
        'uuid': uuid,
        'callerName': callerName,
        'handle': handle
      });

  Future<void> setOnHold(
          {required String uuid, required bool shouldHold}) async =>
      await _channel.invokeMethod<void>(
          'setOnHold', <String, dynamic>{'uuid': uuid, 'hold': shouldHold});

  Future<void> setReachable({bool reachable = true}) async {
    if (isIOS) {
      return;
    }
    await _channel.invokeMethod<void>('setReachable', <String, dynamic>{
      'reachable': reachable,
    });
  }

  // @deprecated
  Future<void> reportUpdatedCall({
    required String uuid,
    required String callerName,
  }) async {
    logger.d(
        'CallKeep.reportUpdatedCall is deprecated, use CallKeep.updateDisplay instead');

    return isIOS
        ? await _channel
            .invokeMethod<void>('reportUpdatedCall', <String, dynamic>{
            'uuid': uuid,
            'callerName': callerName,
          })
        : throw Exception(
            'CallKeep.reportUpdatedCall was called from unsupported OS');
  }

  Future<bool> backToForeground() async {
    if (isIOS) {
      return false;
    }
    var resp = await _channel
        .invokeMethod<bool>('backToForeground', <String, dynamic>{});
    if (resp != null) {
      return resp;
    }
    return false;
  }

  Future<void> _setupIOS({required Map<String, dynamic> options}) async {
    if (options['appName'] == null) {
      throw Exception('CallKeep.setup: option "appName" is required');
    }
    if (options['appName'] is String == false) {
      throw Exception(
          'CallKeep.setup: option "appName" should be of type "string"');
    }
    return await _channel
        .invokeMethod<void>('setup', <String, dynamic>{'options': options});
  }

  Future<bool> _setupAndroid({
    required Map<String, dynamic> options,
    required bool backgroundMode,
  }) async {
    await _channel.invokeMethod<void>('setup', {'options': options});

    if (backgroundMode) {
      return true;
    }

    final additionalPermissions = options['additionalPermissions'] as List?;
    final hasPermissions = await requestPermissions(
      additionalPermissions?.cast<String>(),
    );
    if (!hasPermissions) return false;

    final hasPhoneAccount = await _hasPhoneAccount();
    if (hasPhoneAccount != false) return true;

    final shouldOpenAccounts = await _alert();
    if (shouldOpenAccounts) {
      await _openPhoneAccounts();
      return true;
    }
    return false;
  }

  Future<void> openPhoneAccounts() => _openPhoneAccounts();

  Future<void> _openPhoneAccounts() async {
    if (isIOS) {
      return;
    }
    await _channel.invokeMethod<void>('openPhoneAccounts', <String, dynamic>{});
  }

  Future<bool> requestPermissions([List<String>? optionalPermissions]) async {
    if (isIOS) {
      return true;
    }
    var resp = await _channel
        .invokeMethod<bool>('requestPermissions', <String, dynamic>{
      'additionalPermissions': optionalPermissions ?? [],
    });
    return resp ?? false;
  }

  Future<bool> hasPermissions() async {
    if (isIOS) {
      return true;
    }
    var resp = await _channel.invokeMethod<bool>('hasPermissions');
    return resp ?? false;
  }

  Future<bool> _alert() async {
    if (_showAlertDialog == null) {
      logger.w('No alert dialog function provided. Defaulting to false.');
      return false;
    }
    return await _showAlertDialog!();
  }

  Future<void> setForegroundServiceSettings({
    required Map<String, String> settings,
  }) async {
    if (isIOS) {
      return;
    }
    await _channel.invokeMethod<void>('foregroundService', <String, dynamic>{
      'settings': {'foregroundService': settings}
    });
  }

  Future<void> eventListener(MethodCall call) async {
    logger.d(
        '[CallKeep] INFO: received event "${call.method}" ${call.arguments}');
    final data = call.arguments as Map<dynamic, dynamic>;
    switch (call.method) {
      case 'CallKeepDidReceiveStartCallAction':
        emit(CallKeepDidReceiveStartCallAction.fromMap(data));
        break;
      case 'CallKeepPerformAnswerCallAction':
        emit(CallKeepPerformAnswerCallAction.fromMap(data));
        break;
      case 'CallKeepPerformRejectCallAction':
        emit(CallKeepPerformRejectCallAction.fromMap(data));
        break;
      case 'CallKeepPerformEndCallAction':
        emit(CallKeepPerformEndCallAction.fromMap(data));
        break;
      case 'CallKeepDidActivateAudioSession':
        emit(CallKeepDidActivateAudioSession());
        break;
      case 'CallKeepDidDeactivateAudioSession':
        emit(CallKeepDidDeactivateAudioSession());
        break;
      case 'CallKeepDidDisplayIncomingCall':
        emit(CallKeepDidDisplayIncomingCall.fromMap(data));
        break;
      case 'CallKeepDidPerformSetMutedCallAction':
        emit(CallKeepDidPerformSetMutedCallAction.fromMap(data));
        break;
      case 'CallKeepDidToggleHoldAction':
        emit(CallKeepDidToggleHoldAction.fromMap(data));
        break;
      case 'CallKeepDidPerformDTMFAction':
        emit(CallKeepDidPerformDTMFAction.fromMap(data));
        break;
      case 'CallKeepProviderReset':
        emit(CallKeepProviderReset());
        break;
      case 'CallKeepCheckReachability':
        emit(CallKeepCheckReachability());
        break;
      case 'CallKeepDidLoadWithEvents':
        emit(CallKeepDidLoadWithEvents());
        break;
      case 'CallKeepPushKitToken':
        emit(CallKeepPushKitToken.fromMap(data));
        break;
    }
  }
}
