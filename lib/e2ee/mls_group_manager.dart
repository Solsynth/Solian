import 'package:dio/dio.dart';
import 'package:island/talker.dart';
import 'mls_storage.dart';

class MlsGroupManager {
  final MlsStorage _storage;
  final Dio _padlockClient;

  MlsGroupManager({required MlsStorage storage, required Dio padlockClient})
    : _storage = storage,
      _padlockClient = padlockClient;

  Future<Map<String, dynamic>?> getGroupState(String roomId) async {
    return _storage.getGroupState(roomId);
  }

  Future<void> saveGroupState(String roomId, Map<String, dynamic> state) async {
    await _storage.setGroupState(roomId, state);
  }

  Future<void> deleteGroupState(String roomId) async {
    await _storage.deleteGroupState(roomId);
  }

  Future<int> getCurrentEpoch(String roomId) async {
    final state = await getGroupState(roomId);
    if (state == null) return 0;
    return state['epoch'] as int? ?? 0;
  }

  Future<Map<String, dynamic>?> bootstrapGroup(String roomId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$roomId/bootstrap',
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data);
        await saveGroupState(roomId, {
          'group_id': data['group_id'],
          'epoch': data['epoch'] ?? 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        return data;
      }
      return null;
    } catch (e) {
      talker.error('Failed to bootstrap group: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> commitPending(String roomId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$roomId/commit',
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data);
        final currentEpoch = await getCurrentEpoch(roomId);
        await saveGroupState(roomId, {
          ...?await getGroupState(roomId),
          'epoch': data['epoch'] ?? (currentEpoch + 1),
          'last_commit_at': DateTime.now().toIso8601String(),
        });
        return data;
      }
      return null;
    } catch (e) {
      talker.error('Failed to commit: $e');
      rethrow;
    }
  }

  Future<bool> fanoutWelcome(String roomId, List<String> invitedMembers) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$roomId/welcome/fanout',
        data: {'invited_member_ids': invitedMembers},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      talker.error('Failed to fanout welcome: $e');
      return false;
    }
  }

  Future<bool> requestReshare(String roomId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$roomId/reshare-required',
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      talker.error('Failed to request reshare: $e');
      return false;
    }
  }

  Future<void> handleEpochChanged(String roomId, int newEpoch) async {
    final state = await getGroupState(roomId);
    if (state != null) {
      await saveGroupState(roomId, {...state, 'epoch': newEpoch});
    }
  }

  Future<void> handleReshareRequired(String roomId) async {
    talker.log('Reshare required for room $roomId');
    await requestReshare(roomId);
  }
}
