import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
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

  Future<bool> hasLocalGroup(String roomId) async {
    final state = await getGroupState(roomId);
    if (state == null) return false;
    return state['serialized_group'] != null;
  }

  Future<int> getCurrentEpoch(String roomId) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode('room:$roomId');
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      if (!isActive) return 0;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      return epoch.toInt();
    } catch (e) {
      final state = await getGroupState(roomId);
      if (state == null) return 0;
      return state['epoch'] as int? ?? 0;
    }
  }

  Future<Map<String, dynamic>?> bootstrapGroup(String roomId) async {
    try {
      final existingState = await getGroupState(roomId);
      if (existingState != null && existingState['serialized_group'] != null) {
        talker.info('Group already exists locally for room $roomId');
        return existingState;
      }

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final signerKeyPairRaw = await _storage.getSignerKeyPair();
      if (signerKeyPairRaw == null) {
        throw Exception(
          'Signer keypair not found. Please initialize MLS first.',
        );
      }

      final signerKeyPair = MlsSignatureKeyPair.fromRaw(
        ciphersuite: defaultCiphersuite,
        privateKey: base64Decode(signerKeyPairRaw.split(':')[0]),
        publicKey: base64Decode(signerKeyPairRaw.split(':')[1]),
      );

      final deviceId = await _storage.getDeviceId();
      if (deviceId == null) {
        throw Exception('Device ID not found');
      }

      final groupIdBytes = utf8.encode('room:$roomId');

      final config = MlsGroupConfig.defaultConfig(
        ciphersuite: defaultCiphersuite,
      );
      final createResult = await engine.createGroup(
        config: config,
        signerBytes: signerKeyPair.privateKey(),
        credentialIdentity: utf8.encode('room:$roomId'),
        signerPublicKey: signerKeyPair.publicKey(),
        groupId: groupIdBytes,
      );

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'serialized_group': base64Encode(createResult.groupId),
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
      });

      talker.info('Group bootstrapped for room $roomId');

      return await getGroupState(roomId);
    } catch (e) {
      talker.error('Failed to bootstrap group: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> joinGroupFromWelcome(
    String roomId,
    Uint8List welcomeBytes,
  ) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final signerKeyPairRaw = await _storage.getSignerKeyPair();
      if (signerKeyPairRaw == null) {
        throw Exception(
          'Signer keypair not found. Please initialize MLS first.',
        );
      }

      final signerKeyPair = MlsSignatureKeyPair.fromRaw(
        ciphersuite: defaultCiphersuite,
        privateKey: base64Decode(signerKeyPairRaw.split(':')[0]),
        publicKey: base64Decode(signerKeyPairRaw.split(':')[1]),
      );

      final joinResult = await engine.joinGroupFromWelcome(
        config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
        welcomeBytes: welcomeBytes,
        signerBytes: signerKeyPair.privateKey(),
      );

      final groupIdBytes = joinResult.groupId;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(roomId, {
        'group_id': base64Encode(groupIdBytes),
        'serialized_group': base64Encode(groupIdBytes),
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
      });

      talker.info('Joined group from welcome for room $roomId');

      return await getGroupState(roomId);
    } catch (e) {
      talker.error('Failed to join group from welcome: $e');
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
        final newEpoch = await getCurrentEpoch(roomId);
        await saveGroupState(roomId, {
          ...?await getGroupState(roomId),
          'epoch': data['epoch'] ?? newEpoch,
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
