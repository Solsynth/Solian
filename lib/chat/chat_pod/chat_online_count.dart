import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/accounts/accounts_models/account.dart';

part 'chat_online_count.g.dart';

@riverpod
class ChatOnlineCountNotifier extends _$ChatOnlineCountNotifier {
  @override
  Future<int> build(String chatroomId) async {
    final apiClient = ref.watch(apiClientProvider);
    final ws = ref.watch(websocketProvider);

    // Fetch initial online count
    final response = await apiClient.get(
      '/messager/chat/$chatroomId/members/online',
    );
    final initialCount = response.data as int;

    // Listen for websocket status updates
    final subscription = ws.dataStream.listen((WebSocketPacket packet) {
      if (packet.type == 'accounts.status.update') {
        final data = packet.data;
        if (data != null && data['chat_room_id'] == chatroomId) {
          final status = SnAccountStatus.fromJson(data['status']);
          var delta = status.isOnline ? 1 : -1;
          if (status.clearedAt != null &&
              status.clearedAt!.isBefore(DateTime.now())) {
            if (status.isInvisible) delta = 1;
          }
          // Update count based on online status
          state.whenData((currentCount) {
            final newCount = currentCount + delta;
            state = AsyncData(
              newCount.clamp(0, double.infinity).toInt(),
            ); // Ensure non-negative
          });
        }
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return initialCount;
  }
}
