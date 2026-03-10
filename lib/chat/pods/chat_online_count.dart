import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_online_count.g.dart';

@riverpod
class ChatOnlineCountNotifier extends _$ChatOnlineCountNotifier {
  @override
  Future<SnChatOnlineStatus> build(String chatroomId) async {
    final apiClient = ref.watch(apiClientProvider);

    final response = await apiClient.get(
      '/messager/chat/$chatroomId/members/online',
    );
    return SnChatOnlineStatus.fromJson(response.data as Map<String, dynamic>);
  }
}
