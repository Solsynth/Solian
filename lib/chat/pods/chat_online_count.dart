import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/desktop_chat_window.dart';
import 'package:island/core/websocket.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_online_count.g.dart';

@riverpod
class ChatOnlineCountNotifier extends _$ChatOnlineCountNotifier {
  @override
  Future<SnChatOnlineStatus> build(String chatroomId) async {
    if (!isPrimaryDesktopWindow(ref) && supportsDesktopMultiWindow) {
      return const SnChatOnlineStatus(onlineCount: 0);
    }
    final apiClient = ref.watch(apiClientProvider);
    final websocket = ref.watch(websocketProvider);
    final subscription = websocket.dataStream.listen((packet) {
      final data = packet.data;
      if ((packet.type == 'chat.presence.updated' ||
              packet.type == 'chat.presence.activities.updated') &&
          data?['room_id'] == chatroomId) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(subscription.cancel);

    final response = await apiClient.get(
      '/messager/chat/$chatroomId/members/online',
    );
    return SnChatOnlineStatus.fromJson(response.data as Map<String, dynamic>);
  }
}
