import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';

CallKitParams createCallKitParams({
  required String roomId,
  required String callerName,
  bool isVideo = false,
}) {
  return CallKitParams(
    id: roomId,
    nameCaller: callerName,
    appName: 'Solian',
    handle: roomId,
    type: isVideo ? 1 : 0,
    extra: {'room_id': roomId},
    ios: const IOSParams(configureAudioSession: false),
  );
}
