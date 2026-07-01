class CallData {
  const CallData(
    this.callUUID,
    this.handle,
    this.name,
    this.hasVideo,
    this.fromPushKit,
    this.additionalData,
  );

  factory CallData.fromMap(Map<dynamic, dynamic> arguments) {
    final callUUID = arguments['callUUID'];
    final handle = arguments['handle'];
    final name = arguments['name'];
    final hasVideo = arguments['hasVideo'];
    final fromPushKit = arguments['fromPushKit'];
    final additionalData = arguments['additionalData'];
    return CallData(
      callUUID,
      handle,
      name,
      hasVideo,
      fromPushKit,
      additionalData == null ? null : Map.from(additionalData),
    );
  }

  final String? callUUID;
  final String? handle;
  final String? name;
  final bool? hasVideo;
  final bool? fromPushKit;
  final Map<String, dynamic>? additionalData;
}
