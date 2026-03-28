import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_identity_manager.dart';
import 'mls_storage.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  talker.info('$_mlsLogPrefix$msg');
}

void _mlsLogWarn(dynamic msg) {
  talker.warning('$_mlsLogPrefix$msg');
}

void _mlsLogError(dynamic msg) {
  talker.error('$_mlsLogPrefix$msg');
}

void _mlsLogInfo(dynamic msg) {
  talker.log('$_mlsLogPrefix$msg');
}

enum MlsEnvelopeType {
  welcome('MlsWelcome'),
  commit('MlsCommit'),
  proposal('MlsProposal'),
  application('MlsApplication');

  final String value;
  const MlsEnvelopeType(this.value);

  static MlsEnvelopeType fromString(String? value) {
    for (final type in MlsEnvelopeType.values) {
      if (type.value == value) return type;
    }
    return MlsEnvelopeType.application;
  }
}

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

    _mlsLog('ensureGroupAvailable: checking for room $roomId');

    try {
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      _mlsLog('ensureGroupAvailable: groupIsActive=$isActive for room $roomId');
      if (isActive) {
        final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
        _mlsLog('ensureGroupAvailable: group active, epoch=${epoch.toInt()}');
        return true;
      }
    } catch (e) {
      _mlsLogWarn(
        'ensureGroupAvailable: Failed to check group for room $roomId: $e',
      );
    }

    _mlsLog('ensureGroupAvailable: group not found, bootstrapping...');
    await bootstrapGroup(roomId, force: true);

    try {
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      _mlsLog(
        'ensureGroupAvailable: after bootstrap, isActive=$isActive, epoch=${epoch.toInt()}',
      );
      return isActive;
    } catch (e) {
      _mlsLogError(
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
      // Check if we have any stored state - OpenMLS persists groups in its encrypted DB
      final hasStoredState = existingState != null;

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode('room:$roomId');

      _mlsLog(
        'bootstrapGroup: room=$roomId, force=$force, hasStoredState=$hasStoredState',
      );

      if (!force && hasStoredState) {
        try {
          final isActive = await engine.groupIsActive(
            groupIdBytes: groupIdBytes,
          );
          if (isActive) {
            final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
            _mlsLogInfo(
              'Group already exists and active for room $roomId (epoch: ${epoch.toInt()})',
            );
            return existingState;
          } else {
            _mlsLog('Group stored but not active in engine, will recreate');
          }
        } catch (e) {
          _mlsLogWarn('Failed to verify group, will recreate: $e');
        }
      }

      if (hasStoredState && force) {
        _mlsLog(
          'Force re-bootstrap: deleting existing state from storage and engine',
        );
        await deleteGroupState(roomId);
        // Also delete from OpenMLS engine to allow recreation
        try {
          await engine.deleteGroup(groupIdBytes: groupIdBytes);
          _mlsLog('Deleted group from OpenMLS engine');
        } catch (e) {
          _mlsLog('Group may not exist in engine (non-fatal): $e');
        }
      }

      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final signerPublicKey = await _identityManager.getSignerPublicKey();

      final config = MlsGroupConfig.defaultConfig(
        ciphersuite: defaultCiphersuite,
      );

      _mlsLogInfo('Creating MLS group for room $roomId...');

      // Create the group - OpenMLS stores it in its encrypted database
      await engine.createGroup(
        config: config,
        signerBytes: signerBytes,
        credentialIdentity: utf8.encode('room:$roomId'),
        signerPublicKey: signerPublicKey,
        groupId: groupIdBytes,
      );

      // Get group context info for logging
      final groupContext = await engine.exportGroupContext(
        groupIdBytes: groupIdBytes,
      );

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      _mlsLogInfo(
        'Group created successfully: epoch=${epoch.toInt()}, '
        'treeHash.length=${groupContext.treeHash.length}, '
        'confirmedTranscriptHash.length=${groupContext.confirmedTranscriptHash.length}',
      );

      // 保存完整 group state
      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'serialized_group': base64Encode(groupContext.groupId),
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      _mlsLogInfo(
        'MLS group bootstrapped for room $roomId with epoch ${epoch.toInt()}',
      );

      if (invitedMembers != null && invitedMembers.isNotEmpty) {
        await fanoutWelcome(roomId, invitedMembers);
      }

      return await getGroupState(roomId);
    } catch (e) {
      _mlsLogError('Failed to bootstrap group for room $roomId: $e');
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

      _mlsLog('Joining MLS group from Welcome for room $roomId...');
      final joinResult = await engine.joinGroupFromWelcome(
        config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
        welcomeBytes: welcomeBytes,
        signerBytes: signerBytes,
      );

      final groupIdBytes = joinResult.groupId;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      _mlsLogInfo(
        'Joined MLS group from Welcome for room $roomId (epoch: ${epoch.toInt()})',
      );

      return await getGroupState(roomId);
    } catch (e) {
      _mlsLogError('Failed to join group from Welcome for room $roomId: $e');
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
      _mlsLogError('Failed to commit: $e');
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
      _mlsLogError('Failed to fanout welcome: $e');
      return false;
    }
  }

  /// Add members to an existing MLS group and fan out the Welcome message.
  ///
  /// Fetches KeyPackages for [memberAccountIds] from the padlock service,
  /// calls `engine.addMembers()` to generate the commit + welcome,
  /// then sends the welcome to the server for distribution.
  ///
  /// Returns the welcome bytes on success.
  Future<Uint8List?> addMembersAndFanoutWelcome(
    String roomId,
    List<String> memberAccountIds,
  ) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final groupIdBytes = utf8.encode('room:$roomId');

      // 1. Fetch KeyPackages for each member
      final List<Uint8List> keyPackages = [];
      for (final memberId in memberAccountIds) {
        final devices = await _identityManager.getDeviceKeyPackages(memberId);
        for (final device in devices) {
          final kpBase64 = device['key_package'] as String?;
          if (kpBase64 != null && kpBase64.isNotEmpty) {
            keyPackages.add(base64Decode(kpBase64));
          }
        }
      }

      if (keyPackages.isEmpty) {
        _mlsLogWarn('No KeyPackages found for members to add to room $roomId');
        return null;
      }

      // 2. Add members to MLS group — this produces a commit + welcome
      _mlsLog(
        'Adding ${keyPackages.length} key packages to group room $roomId...',
      );
      final addResult = await engine.addMembers(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        keyPackagesBytes: keyPackages,
      );

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      await saveGroupState(roomId, {
        'group_id': 'room:$roomId',
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_member_add_at': DateTime.now().toIso8601String(),
      });

      _mlsLogInfo(
        'Added ${keyPackages.length} members to group room $roomId (epoch: ${epoch.toInt()})',
      );

      // 3. Send welcome to server for fanout
      if (addResult.welcome.isNotEmpty) {
        await _sendWelcomeToServer(roomId, addResult.welcome, memberAccountIds);
        return addResult.welcome;
      }

      return null;
    } catch (e) {
      _mlsLogError(
        'Failed to add members and fanout welcome for room $roomId: $e',
      );
      rethrow;
    }
  }

  /// Send welcome bytes to the server for distribution to invited members.
  Future<void> _sendWelcomeToServer(
    String roomId,
    Uint8List welcomeBytes,
    List<String> memberAccountIds,
  ) async {
    try {
      final welcomeBase64 = base64Encode(welcomeBytes);
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$roomId/welcome/fanout',
        data: {
          'welcome': welcomeBase64,
          'invited_member_ids': memberAccountIds,
        },
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _mlsLog('Welcome sent to server for fanout to room $roomId');
      } else {
        _mlsLogWarn(
          'Unexpected status from welcome fanout: ${response.statusCode}',
        );
      }
    } catch (e) {
      _mlsLogError('Failed to send welcome to server for room $roomId: $e');
      rethrow;
    }
  }

  /// Process an incoming Welcome message to join an existing MLS group.
  ///
  /// Called when a device receives a MlsWelcome envelope from the server
  /// (via pending envelopes or WebSocket). The device joins the group
  /// identified by the Welcome.
  Future<Map<String, dynamic>?> processWelcome({
    required String roomId,
    required Uint8List welcomeBytes,
  }) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      // Inspect the welcome to get group info before joining
      try {
        final inspectResult = await engine.inspectWelcome(
          config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
          welcomeBytes: welcomeBytes,
        );
        _mlsLog(
          'Welcome inspection: groupId=${inspectResult.groupId}, '
          'epoch=${inspectResult.epoch}, ciphersuite=${inspectResult.ciphersuite}',
        );
      } catch (e) {
        _mlsLog('Could not inspect welcome (non-fatal): $e');
      }

      // Join the group from the welcome
      final result = await joinGroupFromWelcome(roomId, welcomeBytes);

      if (result != null) {
        _mlsLogInfo('Successfully processed Welcome and joined room $roomId');
      }

      return result;
    } catch (e) {
      _mlsLogError('Failed to process Welcome for room $roomId: $e');
      rethrow;
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
      _mlsLogError('Failed to request reshare: $e');
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
