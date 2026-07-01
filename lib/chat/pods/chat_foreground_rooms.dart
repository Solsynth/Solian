import 'package:hooks_riverpod/hooks_riverpod.dart';

final foregroundChatRoomIdsProvider =
    NotifierProvider<ForegroundChatRoomIdsNotifier, Set<String>>(
      ForegroundChatRoomIdsNotifier.new,
    );

class ForegroundChatRoomIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void add(String roomId) {
    state = {...state, roomId};
  }

  void remove(String roomId) {
    if (!state.contains(roomId)) return;
    state = {...state}..remove(roomId);
  }
}
