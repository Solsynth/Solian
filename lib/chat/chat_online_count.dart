import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_online_count.g.dart';

@riverpod
class ChatOnlineCountNotifier extends _$ChatOnlineCountNotifier {
  @override
  Future<SnChatOnlineStatus> build(String chatroomId) async {
    final apiClient = ref.watch(apiClientProvider);
    final ws = ref.watch(websocketProvider);

    final response = await apiClient.get(
      '/messager/chat/$chatroomId/members/online',
    );
    final initialStatus = SnChatOnlineStatus.fromJson(
      response.data as Map<String, dynamic>,
    );

    final subscription = ws.dataStream.listen((WebSocketPacket packet) {
      if (packet.type == 'accounts.status.update') {
        final data = packet.data;
        if (data != null && data['chat_room_id'] == chatroomId) {
          ref.invalidateSelf();
        }
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return initialStatus;
  }
}
