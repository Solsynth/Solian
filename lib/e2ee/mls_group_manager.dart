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
  welcome(5),
  commit(4),
  proposal(7),
  application(6);

  final int value;
  const MlsEnvelopeType(this.value);

  static MlsEnvelopeType fromInt(int? value) {
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

  Future<Map<String, dynamic>?> getGroupState(String mlsGroupId) async {
    return _storage.getGroupState(mlsGroupId);
  }

  Future<void> saveGroupState(
    String mlsGroupId,
    Map<String, dynamic> state,
  ) async {
    await _storage.setGroupState(mlsGroupId, state);
  }

  Future<void> deleteGroupState(String mlsGroupId) async {
    await _storage.deleteGroupState(mlsGroupId);
  }

  Future<bool> hasLocalGroup(String mlsGroupId) async {
    final state = await getGroupState(mlsGroupId);
    if (state == null) return false;
    return state['serialized_group'] != null;
  }

  Future<bool> ensureGroupAvailable(String mlsGroupId) async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;
    final groupIdBytes = utf8.encode(mlsGroupId);

    _mlsLog('ensureGroupAvailable: checking for room $mlsGroupId');

    try {
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      _mlsLog(
        'ensureGroupAvailable: groupIsActive=$isActive for room $mlsGroupId',
      );
      if (isActive) {
        final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
        _mlsLog('ensureGroupAvailable: group active, epoch=${epoch.toInt()}');
        return true;
      }
    } catch (e) {
      _mlsLogWarn(
        'ensureGroupAvailable: Failed to check group for room $mlsGroupId: $e',
      );
    }

    _mlsLog('ensureGroupAvailable: group not found, bootstrapping...');
    await bootstrapGroup(mlsGroupId, force: true);

    try {
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      _mlsLog(
        'ensureGroupAvailable: after bootstrap, isActive=$isActive, epoch=${epoch.toInt()}',
      );
      return isActive;
    } catch (e) {
      _mlsLogError(
        'MLS group still unavailable after bootstrap for room $mlsGroupId: $e',
      );
      return false;
    }
  }

  Future<int> getCurrentEpoch(String mlsGroupId) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode(mlsGroupId);
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      if (!isActive) return 0;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      return epoch.toInt();
    } catch (e) {
      final state = await getGroupState(mlsGroupId);
      if (state == null) return 0;
      return state['epoch'] as int? ?? 0;
    }
  }

  /// Bootstrap an MLS group for a room.
  ///
  /// [mlsGroupId] - The room identifier
  /// [force] - If true, re-create the group even if one exists
  /// [invitedMembers] - Optional list of member IDs to fan out Welcome to
  Future<Map<String, dynamic>?> bootstrapGroup(
    String mlsGroupId, {
    bool force = false,
    List<String>? invitedMembers,
  }) async {
    try {
      final existingState = await getGroupState(mlsGroupId);
      // Check if we have any stored state - OpenMLS persists groups in its encrypted DB
      final hasStoredState = existingState != null;

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode(mlsGroupId);

      _mlsLog(
        'bootstrapGroup: room=$mlsGroupId, force=$force, hasStoredState=$hasStoredState',
      );

      if (!force && hasStoredState) {
        try {
          final isActive = await engine.groupIsActive(
            groupIdBytes: groupIdBytes,
          );
          if (isActive) {
            final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
            _mlsLogInfo(
              'Group already exists and active for room $mlsGroupId (epoch: ${epoch.toInt()})',
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
        await deleteGroupState(mlsGroupId);
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

      _mlsLogInfo('Creating MLS group for room $mlsGroupId...');

      // Create the group - OpenMLS stores it in its encrypted database
      await engine.createGroup(
        config: config,
        signerBytes: signerBytes,
        credentialIdentity: utf8.encode(mlsGroupId),
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
      await saveGroupState(mlsGroupId, {
        'group_id': mlsGroupId,
        'serialized_group': base64Encode(groupContext.groupId),
        'epoch': epoch.toInt(),
        'is_creator': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Call server to bootstrap the group
      try {
        await _padlockClient.post(
          '/e2ee/mls/groups/$mlsGroupId/bootstrap',
          data: {
            'chat_room_id': mlsGroupId,
            'group_id': mlsGroupId,
            'epoch': epoch.toInt(),
            'state_version': 1,
          },
          options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
        );
        _mlsLog('Server bootstrap called for room $mlsGroupId');
      } catch (e) {
        _mlsLogWarn('Failed to call server bootstrap: $e');
      }

      _mlsLogInfo(
        'MLS group bootstrapped for room $mlsGroupId with epoch ${epoch.toInt()}',
      );

      if (invitedMembers != null && invitedMembers.isNotEmpty) {
        await fanoutWelcome(mlsGroupId, invitedMembers);
      }

      return await getGroupState(mlsGroupId);
    } catch (e) {
      _mlsLogError('Failed to bootstrap group for room $mlsGroupId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> joinGroupFromWelcome(
    String mlsGroupId,
    Uint8List welcomeBytes,
  ) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      // Use identity manager for clean signer access
      final signerBytes = await _identityManager.getOrCreateSignerBytes();

      _mlsLog('Joining MLS group from Welcome for room $mlsGroupId...');
      final joinResult = await engine.joinGroupFromWelcome(
        config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
        welcomeBytes: welcomeBytes,
        signerBytes: signerBytes,
      );

      final groupIdBytes = joinResult.groupId;
      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

      await saveGroupState(mlsGroupId, {
        'group_id': mlsGroupId,
        'epoch': epoch.toInt(),
        'is_creator': false,
        'joined_via_welcome': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      _mlsLogInfo(
        'Joined MLS group from Welcome for room $mlsGroupId (epoch: ${epoch.toInt()})',
      );

      return await getGroupState(mlsGroupId);
    } catch (e) {
      _mlsLogError(
        'Failed to join group from Welcome for room $mlsGroupId: $e',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> commitPending(String mlsGroupId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/commit',
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data);
        final newEpoch = await getCurrentEpoch(mlsGroupId);
        await saveGroupState(mlsGroupId, {
          ...?await getGroupState(mlsGroupId),
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

  Future<bool> fanoutWelcome(
    String mlsGroupId,
    List<String> invitedMembers,
  ) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/welcome/fanout',
        data: {'invited_member_ids': invitedMembers},
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
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
    String mlsGroupId,
    List<String> memberAccountIds,
  ) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final groupIdBytes = utf8.encode(mlsGroupId);

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
        _mlsLogWarn(
          'No KeyPackages found for members to add to room $mlsGroupId',
        );
        return null;
      }

      // 2. Add members to MLS group — this produces a commit + welcome
      _mlsLog(
        'Adding ${keyPackages.length} key packages to group room $mlsGroupId...',
      );
      final addResult = await engine.addMembers(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        keyPackagesBytes: keyPackages,
      );

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      await saveGroupState(mlsGroupId, {
        'group_id': mlsGroupId,
        'epoch': epoch.toInt(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_member_add_at': DateTime.now().toIso8601String(),
      });

      _mlsLogInfo(
        'Added ${keyPackages.length} members to group room $mlsGroupId (epoch: ${epoch.toInt()})',
      );

      // 3. Fan out Commit to existing members (critical for epoch advancement)
      if (addResult.commit.isNotEmpty) {
        _mlsLog('Fanout commit to existing members...');
        await _fanoutCommitToExistingMembers(mlsGroupId, addResult.commit);
      }

      // 4. Send welcome to new members for joining
      if (addResult.welcome.isNotEmpty) {
        await _sendWelcomeToServer(
          mlsGroupId,
          addResult.welcome,
          memberAccountIds,
        );
        return addResult.welcome;
      }

      return null;
    } catch (e) {
      _mlsLogError(
        'Failed to add members and fanout welcome for room $mlsGroupId: $e',
      );
      rethrow;
    }
  }

  /// Send welcome bytes to the server for distribution to invited members.
  Future<void> _sendWelcomeToServer(
    String mlsGroupId,
    Uint8List welcomeBytes,
    List<String> memberAccountIds,
  ) async {
    try {
      final welcomeBase64 = base64Encode(welcomeBytes);
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/welcome/fanout',
        data: {
          'welcome': welcomeBase64,
          'invited_member_ids': memberAccountIds,
        },
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _mlsLog('Welcome sent to server for fanout to room $mlsGroupId');
      } else {
        _mlsLogWarn(
          'Unexpected status from welcome fanout: ${response.statusCode}',
        );
      }
    } catch (e) {
      _mlsLogError('Failed to send welcome to server for room $mlsGroupId: $e');
      rethrow;
    }
  }

  /// Fan out Commit message to existing group members.
  ///
  /// When adding new members, a Commit is generated that existing members
  /// must process to advance their epoch. This sends that Commit to the server
  /// for distribution to all existing members.
  Future<void> _fanoutCommitToExistingMembers(
    String mlsGroupId,
    Uint8List commitBytes,
  ) async {
    try {
      final commitBase64 = base64Encode(commitBytes);
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/commit/fanout',
        data: {'commit': commitBase64},
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _mlsLog('Commit fanned out to existing members for room $mlsGroupId');
      } else {
        _mlsLogWarn(
          'Unexpected status from commit fanout: ${response.statusCode}',
        );
      }
    } catch (e) {
      _mlsLogError('Failed to fanout commit for room $mlsGroupId: $e');
      rethrow;
    }
  }

  /// Process an incoming Welcome message to join an existing MLS group.
  ///
  /// Called when a device receives a MlsWelcome envelope from the server
  /// (via pending envelopes or WebSocket). The device joins the group
  /// identified by the Welcome.
  Future<Map<String, dynamic>?> processWelcome({
    required String mlsGroupId,
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
      final result = await joinGroupFromWelcome(mlsGroupId, welcomeBytes);

      if (result != null) {
        _mlsLogInfo(
          'Successfully processed Welcome and joined room $mlsGroupId',
        );
      }

      return result;
    } catch (e) {
      _mlsLogError('Failed to process Welcome for room $mlsGroupId: $e');
      rethrow;
    }
  }

  Future<bool> requestReshare(String mlsGroupId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/reshare-required',
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _mlsLogError('Failed to request reshare: $e');
      return false;
    }
  }

  Future<void> handleEpochChanged(String mlsGroupId, int newEpoch) async {
    final state = await getGroupState(mlsGroupId);
    if (state != null) {
      await saveGroupState(mlsGroupId, {...state, 'epoch': newEpoch});
    }
  }

  Future<void> handleReshareRequired(String mlsGroupId) async {
    talker.log('Reshare required for room $mlsGroupId');
    await requestReshare(mlsGroupId);
  }

  Future<bool> upgradeRoomToMls(String mlsGroupId) async {
    try {
      _mlsLog('Starting MLS upgrade for room $mlsGroupId');

      final List<String> allMembers = [];
      int offset = 0;
      const int pageSize = 100;

      while (true) {
        final response = await _padlockClient.get(
          '/messager/chat/$mlsGroupId/members',
          queryParameters: {
            'offset': offset.toString(),
            'take': pageSize.toString(),
          },
          options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
        );

        if (response.data is! List || response.data.isEmpty) break;

        final members = (response.data as List)
            .map((e) => e['account_id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toList();

        allMembers.addAll(members);

        final totalCount =
            int.tryParse(response.headers.value('X-Total') ?? '') ?? 0;
        if (allMembers.length >= totalCount) break;

        offset += pageSize;
      }

      _mlsLog('Found ${allMembers.length} members in room $mlsGroupId');

      for (final memberId in allMembers) {
        await _padlockClient.post(
          '/e2ee/mls/groups/$mlsGroupId/reshare-required',
          data: {
            'chat_room_id': mlsGroupId,
            'group_id': mlsGroupId,
            'target_account_id': memberId,
            'target_device_id': 'all',
            'epoch': 0,
            'reason': 'room_upgrade_to_mls',
          },
          options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
        );
      }
      _mlsLog('Sent reshare requests for all members in room $mlsGroupId');

      await bootstrapGroup(mlsGroupId, force: true);
      _mlsLog('Bootstrap completed for room $mlsGroupId');

      return true;
    } catch (e) {
      _mlsLogError('Failed to upgrade room $mlsGroupId to MLS: $e');
      return false;
    }
  }

  Future<int> _getCurrentStateVersion(String mlsGroupId) async {
    final state = await getGroupState(mlsGroupId);
    return (state?['state_version'] as int?) ?? 0;
  }

  Future<void> resetAndRebootstrapGroup(
    String mlsGroupId, {
    String reason = 'upgrade',
  }) async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;
    final groupIdBytes = utf8.encode(mlsGroupId);

    try {
      await engine.deleteGroup(groupIdBytes: groupIdBytes);
      await deleteGroupState(mlsGroupId);
      _mlsLog('Deleted local group $mlsGroupId');
    } catch (e) {
      _mlsLog('No local group to delete: $e');
    }

    try {
      await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/reset',
        data: {
          'new_epoch': 0,
          'state_version': await _getCurrentStateVersion(mlsGroupId) + 1,
          'reason': reason,
        },
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _mlsLog(
          'Server has no group $mlsGroupId, will re-bootstrap from scratch',
        );
      } else {
        rethrow;
      }
    }

    await bootstrapGroup(mlsGroupId, force: true);

    // Fetch all members and re-add them to the new MLS group
    try {
      final allMembers = await _fetchAllChatRoomMembers(mlsGroupId);
      if (allMembers.isNotEmpty) {
        _mlsLog('Re-adding ${allMembers.length} members to group $mlsGroupId');
        await addMembersAndFanoutWelcome(mlsGroupId, allMembers);
        _mlsLog('Successfully re-added members to group $mlsGroupId');
      }
    } catch (e) {
      _mlsLogWarn('Failed to re-add members after reset: $e');
    }

    _mlsLog('Group $mlsGroupId reset and re-bootstrapped');
  }

  Future<List<String>> _fetchAllChatRoomMembers(String roomId) async {
    final List<String> allMembers = [];
    int offset = 0;
    const int pageSize = 100;

    while (true) {
      final response = await _padlockClient.get(
        '/messager/chat/$roomId/members',
        queryParameters: {
          'offset': offset.toString(),
          'take': pageSize.toString(),
        },
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );

      if (response.data is! List || response.data.isEmpty) break;

      final members = (response.data as List)
          .map((e) => e['account_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      allMembers.addAll(members);

      final totalCount =
          int.tryParse(response.headers.value('X-Total') ?? '') ?? 0;
      if (allMembers.length >= totalCount) break;

      offset += pageSize;
    }

    return allMembers;
  }
}
