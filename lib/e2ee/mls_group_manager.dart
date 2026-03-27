import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_identity_manager.dart';
import 'mls_storage.dart';

class MlsGroupManager {
  final MlsStorage _storage;
  final Dio _padlockClient;
  final MlsIdentityManager _identityManager;

  MlsGroupManager({
    required MlsStorage storage,
    required Dio padlockClient,
    required MlsIdentityManager identityManager,
  }) : _storage = storage,
       _padlockClient = padlockClient,
       _identityManager = identityManager;

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

  Future<bool> ensureGroupAvailable(String roomId) async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;
    final groupIdBytes = utf8.encode('room:$roomId');

    try {
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      if (isActive) return true;
    } catch (e) {
      talker.warning(
        'Failed to verify MLS group activity for room $roomId, re-bootstrap will be attempted: $e',
      );
    }

    await bootstrapGroup(roomId, force: true);

    try {
      return await engine.groupIsActive(groupIdBytes: groupIdBytes);
    } catch (e) {
      talker.error(
        'MLS group still unavailable after bootstrap for room $roomId: $e',
      );
      return false;
    }
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

  /// Bootstrap an MLS group for a room.
  ///
  /// [roomId] - The room identifier
  /// [force] - If true, re-create the group even if one exists
  /// [invitedMembers] - Optional list of member IDs to fan out Welcome to
  Future<Map<String, dynamic>?> bootstrapGroup(
    String roomId, {
    bool force = false,
    List<String>? invitedMembers,
  }) async {
    try {
      final existingState = await getGroupState(roomId);

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode('room:$roomId');

      final hasStoredGroup =
          existingState != null && existingState['serialized_group'] != null;

      if (!force && hasStoredGroup) {
        try {
          final isActive = await engine.groupIsActive(
            groupIdBytes: groupIdBytes,
          );
          if (isActive) {
            talker.info('Group already exists for room $roomId');
            return existingState;
          }
          talker.warning(
            'Stored group exists but engine group is missing for room $roomId, recreating...',
          );
        } catch (e) {
          talker.warning(
            'Failed to verify MLS group for room $roomId, recreating: $e',
          );
        }
      }

      if (force && hasStoredGroup) {
        talker.info('Force re-bootstrapping MLS group for room $roomId');
      }

      if (hasStoredGroup) {
        await deleteGroupState(roomId);
      }

      // Use identity manager for clean signer access
      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final signerPublicKey = await _identityManager.getSignerPublicKey();

      final config = MlsGroupConfig.defaultConfig(
        ciphersuite: defaultCiphersuite,
      );

      talker.debug('Creating MLS group for room $roomId...');
      final createResult = await engine.createGroup(
        config: config,
        signerBytes: signerBytes,
        credentialIdentity: utf8.encode('room:$roomId'),
        signerPublicKey: signerPublicKey,
        groupId: groupIdBytes,
      );

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'serialized_group': base64Encode(createResult.groupId),
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
      });

      talker.info(
        'MLS group bootstrapped for room $roomId (epoch: ${epoch.toInt()})',
      );

      // Fan out Welcome if members are provided
      if (invitedMembers != null && invitedMembers.isNotEmpty) {
        talker.debug(
          'Fanning out Welcome to ${invitedMembers.length} members...',
        );
        await fanoutWelcome(roomId, invitedMembers);
      }

      return await getGroupState(roomId);
    } catch (e) {
      talker.error('Failed to bootstrap group for room $roomId: $e');
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

      // Use identity manager for clean signer access
      final signerBytes = await _identityManager.getOrCreateSignerBytes();

      talker.debug('Joining MLS group from Welcome for room $roomId...');
      final joinResult = await engine.joinGroupFromWelcome(
        config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
        welcomeBytes: welcomeBytes,
        signerBytes: signerBytes,
      );

      final groupIdBytes = joinResult.groupId;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'serialized_group': base64Encode(groupIdBytes),
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
      });

      talker.info(
        'Joined MLS group from Welcome for room $roomId (epoch: ${epoch.toInt()})',
      );

      return await getGroupState(roomId);
    } catch (e) {
      talker.error('Failed to join group from Welcome for room $roomId: $e');
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
