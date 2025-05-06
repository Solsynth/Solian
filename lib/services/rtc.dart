import 'package:dio/dio.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/user.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

Future<TRTCCloud> _getTRTCCloud() async {
  return TRTCCloud.sharedInstance();
}

bool currentlyJoined = false;

Future<void> joinRealtimeChat(
  Dio apiClient,
  SnChatRoom chat,
  SnAccount user,
) async {
  final resp = await apiClient.get('/chat/realtime/${chat.id}');
  final data = ChatRealtimeJoinResponse.fromJson(resp.data);
  final config = data.config;
  final cloud = await _getTRTCCloud();
  cloud.setConsoleEnabled(true);
  cloud.registerListener(
    TRTCCloudListener(
      onRemoteUserEnterRoom: (userId) {
        print('onRemoteUserEnterRoom: $userId');
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        print('onRemoteUserLeaveRoom: $userId, $reason');
      },
    ),
  );
  cloud.enterRoom(
    TRTCParams(
      sdkAppId: config['app_id'],
      userId: user.name,
      userSig: data.token,
      roomId: chat.id,
      role: TRTCRoleType.anchor,
    ),
    TRTCAppScene.voiceChatRoom,
  );
  cloud.startLocalAudio(TRTCAudioQuality.speech);
  currentlyJoined = true;
}

Future<void> leaveRealtimeChat(SnChatRoom chat) async {
  final cloud = await _getTRTCCloud();
  cloud.exitRoom();
}
