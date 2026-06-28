import 'package:uuid/uuid.dart';

enum NativeCallSource { incomingPush, incomingForeground, outgoingLocal }

class SystemCallDescriptor {
  const SystemCallDescriptor({
    required this.callUuid,
    required this.roomId,
    required this.callerName,
    required this.handle,
    required this.hasVideo,
    required this.source,
    this.metadata = const <String, dynamic>{},
  });

  final String callUuid;
  final String roomId;
  final String callerName;
  final String handle;
  final bool hasVideo;
  final NativeCallSource source;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toAdditionalData() {
    return <String, dynamic>{
      'room_id': roomId,
      'caller_name': callerName,
      'handle': handle,
      'has_video': hasVideo,
      'call_uuid': callUuid,
      'source': source.name,
      ...metadata,
    };
  }
}

const _uuid = Uuid();

SystemCallDescriptor createSystemCallDescriptor({
  required String roomId,
  required String callerName,
  required String handle,
  bool hasVideo = false,
  required NativeCallSource source,
  String? callUuid,
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) {
  final normalizedHandle = handle.trim().isEmpty ? roomId : handle.trim();
  return SystemCallDescriptor(
    callUuid: callUuid?.trim().isNotEmpty == true ? callUuid!.trim() : _uuid.v4(),
    roomId: roomId,
    callerName: callerName.trim().isEmpty ? 'Voice Call' : callerName.trim(),
    handle: normalizedHandle,
    hasVideo: hasVideo,
    source: source,
    metadata: <String, dynamic>{'room_id': roomId, ...metadata},
  );
}

SystemCallDescriptor? systemCallDescriptorFromPushPayload(
  Map<dynamic, dynamic> payload,
) {
  final raw = payload.map((key, value) => MapEntry(key.toString(), value));
  final meta = raw['meta'];
  final source = meta is Map
      ? meta.map((key, value) => MapEntry(key.toString(), value))
      : raw;

  final roomId = _readString(source, const ['room_id', 'roomId']);
  if (roomId == null || roomId.isEmpty) return null;

  final callerId = _readString(source, const ['caller_id', 'callerId']);
  final callerName =
      _readString(source, const ['caller_name', 'callerName']) ?? 'Voice Call';
  final callUuid = _readString(source, const ['uuid', 'call_uuid', 'callUuid']);
  final handle = callerId == null || callerId.isEmpty ? roomId : '@$callerId';
  final hasVideo = _readBool(source, const ['has_video', 'hasVideo']);

  return createSystemCallDescriptor(
    roomId: roomId,
    callerName: callerName,
    handle: handle,
    hasVideo: hasVideo,
    source: NativeCallSource.incomingPush,
    callUuid: callUuid,
    metadata: source,
  );
}

String? _readString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

bool _readBool(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return false;
}
