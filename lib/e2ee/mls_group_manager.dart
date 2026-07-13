import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:openmls/openmls.dart';

import 'mls_engine.dart';
import 'mls_identity_manager.dart';
import 'mls_storage.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  Logger.root.info('$_mlsLogPrefix$msg');
}

void _mlsLogWarn(dynamic msg) {
  Logger.root.warning('$_mlsLogPrefix$msg');
}

void _mlsLogError(dynamic msg) {
  Logger.root.severe('$_mlsLogPrefix$msg');
}

void _mlsLogInfo(dynamic msg) {
  Logger.root.info('$_mlsLogPrefix$msg');
}

void _logEpochTransition(
  String mlsGroupId,
  int fromEpoch,
  int toEpoch,
  String reason,
) {
  Logger.root.info(
    '$_mlsLogPrefix[EPOCH] group=$mlsGroupId $fromEpoch → $toEpoch reason=$reason',
  );
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

String _generateNonce() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = timestamp.hashCode.abs().toString();
  return base64Url.encode(utf8.encode('$timestamp$random')).replaceAll('=', '');
}

class MlsGroupManager {
  final MlsStorage _storage;
  final Dio _padlockClient;
  final Dio _apiClient;
  final MlsIdentityManager _identityManager;

  MlsGroupManager({
    required MlsStorage storage,
    required Dio padlockClient,
    required Dio apiClient,
    required MlsIdentityManager identityManager,
  }) : _storage = storage,
       _padlockClient = padlockClient,
       _apiClient = apiClient,
       _identityManager = identityManager;

  String? _resolveRoomId(String mlsGroupId, String? roomId) {
    if (roomId != null && roomId.isNotEmpty) return roomId;
    const prefix = 'room:';
    if (mlsGroupId.startsWith(prefix)) {
      return mlsGroupId.substring(prefix.length);
    }
    return null;
  }

  Future<Map<String, String>> _getMlsHeaders() async {
    final deviceId = await _identityManager.getOrCreateDeviceId();
    return {'X-Device-Id': ?deviceId};
  }

  Future<bool> _notifyGroupJoined({
    required String? roomId,
    required int epoch,
  }) async {
    if (roomId == null) {
      _mlsLogWarn('Cannot notify group join: chat room ID is unknown');
      return false;
    }
    try {
      final deviceId = await _identityManager.getOrCreateDeviceId();
      await _apiClient.post(
        '/messager/chat/$roomId/devices/me/joined',
        data: {'mls_device_id': deviceId, 'epoch': epoch},
      );
      _mlsLog('Notified server of group join for room $roomId (epoch: $epoch)');
      return true;
    } catch (e) {
      _mlsLogWarn('Failed to notify group joined for room $roomId: $e');
      return false;
    }
  }

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

    _mlsLog(
      'ensureGroupAvailable: group not found, checking bootstrap owner...',
    );
    await bootstrapGroup(mlsGroupId, roomId: null, force: false);

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
  /// [mlsGroupId] - The room identifier (also used as roomId if not specified)
  /// [roomId] - Chat room ID for notifying the server (defaults to mlsGroupId)
  /// [force] - If true, re-create the group even if one exists
  /// [invitedMembers] - Optional list of member IDs to fan out Welcome to
  Future<Map<String, dynamic>?> bootstrapGroup(
    String mlsGroupId, {
    String? roomId,
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
            final membershipReady = await _notifyGroupJoined(
              roomId: _resolveRoomId(mlsGroupId, roomId),
              epoch: epoch.toInt(),
            );
            if (!membershipReady) {
              throw StateError(
                'MLS group is active locally but device membership could not '
                'be registered with the delivery service.',
              );
            }
            if (!await uploadGroupInfo(mlsGroupId)) {
              throw StateError(
                'Local MLS state could not publish GroupInfo at its current epoch.',
              );
            }
            _mlsLogInfo(
              'Group already exists and active for room $mlsGroupId (epoch: ${epoch.toInt()})',
            );
            return existingState;
          } else {
            throw StateError(
              'MLS group state exists but is not active. A Welcome or '
              'authorized external join is required; refusing to fork the '
              'existing group.',
            );
          }
        } catch (e) {
          _mlsLogWarn('Failed to restore stored MLS group: $e');
          rethrow;
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
      final deviceId = await _identityManager.getOrCreateDeviceId();
      if (deviceId == null) {
        throw StateError('Cannot bootstrap MLS group without a device ID.');
      }

      // Reserve bootstrap ownership before creating local cryptographic state.
      // Replaying this request is safe, but a different device must wait for a
      // Welcome instead of independently creating a group with the same ID.
      final bootstrapResponse = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/bootstrap',
        data: {
          'epoch': 0,
          'state_version': 1,
          'meta': {'bootstrap_device_id': deviceId},
        },
        options: Options(headers: await _getMlsHeaders()),
      );
      final serverState = Map<String, dynamic>.from(
        bootstrapResponse.data as Map? ?? const <String, dynamic>{},
      );
      final serverMeta = serverState['meta'] is Map
          ? Map<String, dynamic>.from(serverState['meta'] as Map)
          : const <String, dynamic>{};
      final bootstrapDeviceId = serverMeta['bootstrap_device_id']?.toString();
      if (!force && bootstrapDeviceId != deviceId) {
        throw StateError(
          'MLS group is already bootstrapped by another device. Waiting for '
          'a Welcome instead of creating divergent group state.',
        );
      }

      final config = MlsGroupConfig.defaultConfig(
        ciphersuite: defaultCiphersuite,
      );

      _mlsLogInfo('Creating MLS group for room $mlsGroupId...');

      // Create the group - OpenMLS stores it in its encrypted database
      await engine.createGroup(
        config: config,
        signerBytes: signerBytes,
        credentialIdentity: utf8.encode(deviceId),
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

      _mlsLogInfo(
        'MLS group bootstrapped for room $mlsGroupId with epoch ${epoch.toInt()}',
      );

      _logEpochTransition(mlsGroupId, 0, epoch.toInt(), 'bootstrap');

      final membershipReady = await _notifyGroupJoined(
        roomId: _resolveRoomId(mlsGroupId, roomId),
        epoch: epoch.toInt(),
      );
      if (!membershipReady) {
        throw StateError(
          'MLS group was created, but device membership registration failed.',
        );
      }
      if (!await uploadGroupInfo(mlsGroupId)) {
        throw StateError('Failed to publish initial MLS GroupInfo.');
      }

      if (invitedMembers != null && invitedMembers.isNotEmpty) {
        await addMembersAndFanoutWelcome(
          mlsGroupId,
          invitedMembers,
          chatRoomId: roomId ?? mlsGroupId,
        );
      }

      return await getGroupState(mlsGroupId);
    } catch (e) {
      _mlsLogError('Failed to bootstrap group for room $mlsGroupId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> joinGroupFromWelcome(
    String mlsGroupId,
    Uint8List welcomeBytes, {
    String? roomId,
  }) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final expectedGroupIdBytes = utf8.encode(mlsGroupId);

      // A Welcome may be redelivered when joining succeeded but the membership
      // acknowledgement failed. Finish that idempotent server step without
      // trying to consume the single-use Welcome again.
      if (await engine.groupIsActive(groupIdBytes: expectedGroupIdBytes)) {
        final epoch = await engine.groupEpoch(
          groupIdBytes: expectedGroupIdBytes,
        );
        final membershipReady = await _notifyGroupJoined(
          roomId: _resolveRoomId(mlsGroupId, roomId),
          epoch: epoch.toInt(),
        );
        if (!membershipReady) {
          throw StateError('Failed to register joined MLS device membership.');
        }
        return await getGroupState(mlsGroupId);
      }

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

      _logEpochTransition(mlsGroupId, 0, epoch.toInt(), 'welcome_join');

      final membershipReady = await _notifyGroupJoined(
        roomId: _resolveRoomId(mlsGroupId, roomId),
        epoch: epoch.toInt(),
      );
      if (!membershipReady) {
        throw StateError('Failed to register joined MLS device membership.');
      }

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
      final currentEpoch = await getCurrentEpoch(mlsGroupId);
      final response = await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/commit',
        data: {'epoch': currentEpoch, 'reason': 'client_commit'},
        options: Options(headers: await _getMlsHeaders()),
      );
      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data);
        final newEpoch = await getCurrentEpoch(mlsGroupId);
        await saveGroupState(mlsGroupId, {
          ...?await getGroupState(mlsGroupId),
          'epoch': data['epoch'] ?? newEpoch,
          'last_commit_at': DateTime.now().toIso8601String(),
        });

        await uploadGroupInfo(mlsGroupId);

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
      final welcome = await addMembersAndFanoutWelcome(
        mlsGroupId,
        invitedMembers,
        chatRoomId: mlsGroupId,
      );
      return welcome != null;
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
    List<String> memberAccountIds, {
    String? chatRoomId,
  }) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final groupIdBytes = utf8.encode(mlsGroupId);
      // 1. Fetch KeyPackages for each member
      final List<Uint8List> keyPackages = [];
      final addedDeviceIdsByAccount = <String, List<String>>{};
      for (final memberId in memberAccountIds) {
        final devices = await _identityManager.getDeviceKeyPackages(memberId);
        for (final device in devices) {
          final kpBase64 = device['key_package'] as String?;
          final deviceId = device['device_id']?.toString();
          if (kpBase64 != null &&
              kpBase64.isNotEmpty &&
              deviceId != null &&
              deviceId.isNotEmpty) {
            keyPackages.add(base64Decode(kpBase64));
            addedDeviceIdsByAccount
                .putIfAbsent(memberId, () => [])
                .add(deviceId);
          }
        }
      }

      if (keyPackages.isEmpty) {
        _mlsLogWarn(
          'No KeyPackages found for members to add to room $mlsGroupId',
        );
        return null;
      }

      final previousEpoch = await getCurrentEpoch(mlsGroupId);

      // 2. Add members to MLS group — this produces a pending commit + welcome.
      // OpenMLS does not advance the sender until mergePendingCommit is called.
      _mlsLog(
        'Adding ${keyPackages.length} key packages to group room $mlsGroupId...',
      );
      final addResult = await engine.addMembers(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        keyPackagesBytes: keyPackages,
      );

      final expectedEpoch = previousEpoch + 1;
      final commitMessageId = _generateNonce();

      // 3. CRITICAL: Fan out Commit to ALL existing members
      // This is required for epoch synchronization - without it, existing members
      // will have stale epoch and cannot decrypt new messages
      if (addResult.commit.isNotEmpty) {
        await _fanoutCommitToExistingMembers(
          mlsGroupId,
          addResult.commit,
          epoch: expectedEpoch,
          clientMessageId: commitMessageId,
        );
        _mlsLogInfo('Commit fanout completed');
      } else {
        _mlsLogWarn(
          'No commit in addResult - this is unexpected for member add',
        );
      }

      // 4. Send welcome to new members for joining
      if (addResult.welcome.isNotEmpty) {
        await _sendWelcomeToServer(
          mlsGroupId,
          addResult.welcome,
          addedDeviceIdsByAccount,
        );

        // The Commit and Welcome are now durably accepted by the delivery
        // service. Advance the sender to the exact epoch carried by them.
        await engine.mergePendingCommit(groupIdBytes: groupIdBytes);
        final mergedEpoch = (await engine.groupEpoch(
          groupIdBytes: groupIdBytes,
        )).toInt();
        if (mergedEpoch != expectedEpoch) {
          throw StateError(
            'MLS pending commit merged to epoch $mergedEpoch; '
            'expected $expectedEpoch.',
          );
        }

        _logEpochTransition(
          mlsGroupId,
          previousEpoch,
          mergedEpoch,
          'member_add(${keyPackages.length})',
        );
        await saveGroupState(mlsGroupId, {
          ...?await getGroupState(mlsGroupId),
          'group_id': mlsGroupId,
          'epoch': mergedEpoch,
          'updated_at': DateTime.now().toIso8601String(),
          'last_member_add_at': DateTime.now().toIso8601String(),
        });
        await uploadGroupInfo(mlsGroupId);

        _mlsLogInfo(
          'Added ${keyPackages.length} members to group room '
          '$mlsGroupId (epoch: $mergedEpoch)',
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
    Map<String, List<String>> deviceIdsByAccount,
  ) async {
    final myAccountId = await _identityManager.getCurrentAccountId();
    if (myAccountId == null) {
      _mlsLogWarn('Cannot fanout welcome: no current account ID');
      return;
    }

    final welcomeBase64 = base64Encode(welcomeBytes);
    final clientMessageId = _generateNonce();

    final header = base64Encode(
      utf8.encode(
        jsonEncode({
          'v': 1,
          'type': 1, // MlsWelcome
          'scheme': 'chat.mls.v2',
        }),
      ),
    );

    try {
      for (final entry in deviceIdsByAccount.entries) {
        final memberId = entry.key;
        final devices = entry.value;
        if (devices.isEmpty) continue;

        final payloads = devices
            .map(
              (deviceId) => {
                'recipient_device_id': deviceId,
                'ciphertext': welcomeBase64,
                'header': header,
                'client_message_id': clientMessageId,
                'meta': {'invited_by': myAccountId},
              },
            )
            .toList();

        await _padlockClient.post(
          '/e2ee/mls/groups/$mlsGroupId/welcome/fanout',
          data: {'recipient_account_id': memberId, 'payloads': payloads},
          options: Options(headers: await _getMlsHeaders()),
        );
      }
      _mlsLog(
        'Welcome sent to server for fanout to room $mlsGroupId (${deviceIdsByAccount.length} members)',
      );
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
    Uint8List commitBytes, {
    required int epoch,
    required String clientMessageId,
  }) async {
    final commitBase64 = base64Encode(commitBytes);

    final header = base64Encode(
      utf8.encode(
        jsonEncode({
          'v': 1,
          'type': 2, // MlsCommit
          'epoch': epoch,
          'scheme': 'chat.mls.v2',
        }),
      ),
    );

    try {
      await _padlockClient.post(
        '/e2ee/mls/groups/$mlsGroupId/commit/fanout',
        data: {
          'epoch': epoch,
          'ciphertext': commitBase64,
          'header': header,
          'client_message_id': clientMessageId,
          'meta': {
            'reason': 'member_add',
            'client_message_id': clientMessageId,
          },
        },
        options: Options(headers: await _getMlsHeaders()),
      );
      _mlsLog('Commit fanned out to existing members for room $mlsGroupId');
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
        data: {},
        options: Options(headers: await _getMlsHeaders()),
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
    Logger.root.info('Processing reshare for room $mlsGroupId');
    await processReshareForGroup(mlsGroupId);
  }

  Future<List<Map<String, dynamic>>> getReshareRequiredGroups() async {
    try {
      final response = await _padlockClient.get(
        '/e2ee/mls/devices/me/reshare-required',
        options: Options(headers: await _getMlsHeaders()),
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } catch (e) {
      _mlsLogError('Failed to get reshare-required groups: $e');
      return [];
    }
  }

  Future<bool> processReshareForGroup(String mlsGroupId) async {
    try {
      _mlsLog('Processing reshare for group $mlsGroupId');

      final isActive = await ensureGroupAvailable(mlsGroupId);
      if (!isActive) {
        _mlsLogWarn('Group $mlsGroupId not available for reshare');
        return false;
      }

      final kpStatus = await _identityManager.getKeyPackageStatus();
      if (kpStatus == null) {
        _mlsLogWarn('No key package status available');
        return false;
      }
      final devicesNeedingKp = kpStatus.devicesNeedingKps
          .where((d) => d['mls_group_id'] == mlsGroupId)
          .toList();

      if (devicesNeedingKp.isEmpty) {
        _mlsLog('No devices need key packages for group $mlsGroupId');
        return true;
      }

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode(mlsGroupId);

      for (final device in devicesNeedingKp) {
        final deviceId = device['device_id']?.toString();
        if (deviceId == null) continue;

        _mlsLog('Adding device $deviceId to group $mlsGroupId');

        final keyPackages = await _identityManager.getDeviceKeyPackages(
          deviceId,
        );
        if (keyPackages.isEmpty) {
          _mlsLogWarn('No key packages available for device $deviceId');
          continue;
        }

        final kpBytes = keyPackages.first['key_package_bytes'] as String?;
        if (kpBytes == null) continue;

        final kp = base64Decode(kpBytes);

        final signerBytes = await _identityManager.getOrCreateSignerBytes();
        await engine.addMembers(
          groupIdBytes: groupIdBytes,
          signerBytes: signerBytes,
          keyPackagesBytes: [kp],
        );

        _mlsLog('Added device $deviceId to group $mlsGroupId');
      }

      await commitPending(mlsGroupId);

      await _padlockClient.post(
        '/e2ee/mls/devices/me/reshare-required/$mlsGroupId/complete',
        options: Options(headers: await _getMlsHeaders()),
      );

      _mlsLog('Reshare completed for group $mlsGroupId');
      return true;
    } catch (e) {
      _mlsLogError('Failed to process reshare for $mlsGroupId: $e');
      return false;
    }
  }

  Future<bool> checkAndProcessReshare(String mlsGroupId) async {
    try {
      final reshareRequired = await getReshareRequiredGroups();
      final groupNeedsReshare = reshareRequired.any(
        (g) => g['mls_group_id'] == mlsGroupId,
      );

      if (groupNeedsReshare) {
        _mlsLog('Group $mlsGroupId requires reshare, processing...');
        return await processReshareForGroup(mlsGroupId);
      }

      return false;
    } catch (e) {
      _mlsLogError('Failed to check reshare status for $mlsGroupId: $e');
      return false;
    }
  }

  Future<bool> uploadGroupInfo(String mlsGroupId) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;
      final groupIdBytes = utf8.encode(mlsGroupId);
      final signerBytes = await _identityManager.getOrCreateSignerBytes();

      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      if (!isActive) {
        _mlsLogWarn(
          'Cannot upload group info: group not active for $mlsGroupId',
        );
        return false;
      }

      final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      final groupInfo = await engine.exportGroupInfo(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
      );
      final ratchetTree = await engine.exportRatchetTree(
        groupIdBytes: groupIdBytes,
      );

      final response = await _padlockClient.put(
        '/e2ee/mls/groups/$mlsGroupId/groupinfo',
        data: {
          'group_info': base64Encode(groupInfo),
          'ratchet_tree': base64Encode(ratchetTree),
          'epoch': epoch.toInt(),
        },
        options: Options(headers: await _getMlsHeaders()),
      );

      _mlsLog('Uploaded group info for $mlsGroupId (epoch: ${epoch.toInt()})');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _mlsLogError('Failed to upload group info for $mlsGroupId: $e');
      return false;
    }
  }

  Future<bool> joinGroupExternal(String mlsGroupId, {String? roomId}) async {
    try {
      _mlsLog('Attempting external join for group $mlsGroupId');

      final response = await _padlockClient.get(
        '/e2ee/mls/groups/$mlsGroupId/groupinfo',
        options: Options(headers: await _getMlsHeaders()),
      );

      final data = Map<String, dynamic>.from(response.data ?? {});
      final groupInfoBase64 = data['group_info']?.toString();
      final ratchetTreeBase64 = data['ratchet_tree']?.toString();

      if (groupInfoBase64 == null) {
        _mlsLogWarn('Missing group_info in response');
        return false;
      }

      final groupInfoBytes = base64Decode(groupInfoBase64);
      final ratchetTreeBytes = ratchetTreeBase64 != null
          ? base64Decode(ratchetTreeBase64)
          : null;

      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final signerBytes = await _identityManager.getOrCreateSignerBytes();
      final signerPublicKey = await _identityManager.getSignerPublicKey();
      final identity = await _identityManager.getOrCreateDeviceId();

      if (identity == null) {
        _mlsLogWarn('No identity available for external join');
        return false;
      }

      final myCredentialIdentity = utf8.encode(identity);

      final joinResult = await engine.joinGroupExternalCommit(
        config: MlsGroupConfig.defaultConfig(ciphersuite: defaultCiphersuite),
        groupInfoBytes: groupInfoBytes,
        ratchetTreeBytes: ratchetTreeBytes,
        signerBytes: signerBytes,
        credentialIdentity: myCredentialIdentity,
        signerPublicKey: signerPublicKey,
      );

      final externalCommitBytes = joinResult.commit;

      if (externalCommitBytes.isEmpty) {
        _mlsLogError('No commit message returned from external join');
        return false;
      }

      final groupIdBytes = joinResult.groupId;
      final currentEpoch = int.tryParse(data['epoch']?.toString() ?? '');
      if (currentEpoch == null) {
        _mlsLogWarn('Missing epoch in GroupInfo response');
        return false;
      }
      final expectedEpoch = currentEpoch + 1;

      // An external Commit is also pending local state. Distribute it before
      // merging so a network failure cannot silently advance only this client.
      await _fanoutCommitToExistingMembers(
        mlsGroupId,
        externalCommitBytes,
        epoch: expectedEpoch,
        clientMessageId: _generateNonce(),
      );

      await engine.mergePendingCommit(groupIdBytes: groupIdBytes);
      final newEpoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);
      if (newEpoch.toInt() != expectedEpoch) {
        throw StateError(
          'External Commit merged to epoch ${newEpoch.toInt()}; '
          'expected $expectedEpoch.',
        );
      }

      await saveGroupState(mlsGroupId, {
        'group_id': mlsGroupId,
        'epoch': newEpoch.toInt(),
        'joined_via_external': true,
        'external_join_at': DateTime.now().toIso8601String(),
        'ratchet_tree': ratchetTreeBase64,
      });

      _mlsLogInfo('External join successful, new epoch: $newEpoch');

      await uploadGroupInfo(mlsGroupId);

      final membershipReady = await _notifyGroupJoined(
        roomId: _resolveRoomId(mlsGroupId, roomId),
        epoch: newEpoch.toInt(),
      );
      if (!membershipReady) {
        throw StateError('Failed to register externally joined MLS device.');
      }

      return true;
    } catch (e, stack) {
      _mlsLogError('Failed to external join group $mlsGroupId: $e\n$stack');
      return false;
    }
  }

  Future<bool> upgradeRoomToMls({
    required String roomId,
    required String mlsGroupId,
    required String creatorAccountId,
  }) async {
    try {
      _mlsLog('Starting MLS upgrade for room $roomId (group: $mlsGroupId)');

      final allMembers = await _fetchAllChatRoomMembers(roomId);
      final membersToAdd = allMembers
          .where((id) => id != creatorAccountId)
          .toList();
      _mlsLog(
        'Found ${allMembers.length} members, adding ${membersToAdd.length} (excluding creator)',
      );

      for (final memberId in membersToAdd) {
        await _padlockClient.post(
          '/e2ee/mls/groups/$mlsGroupId/reshare-required',
          data: {
            'chat_room_id': roomId,
            'group_id': mlsGroupId,
            'target_account_id': memberId,
            'target_device_id': 'all',
            'epoch': 0,
            'reason': 'room_upgrade_to_mls',
          },
          options: Options(headers: await _getMlsHeaders()),
        );
      }
      _mlsLog('Sent reshare requests for all members in room $roomId');

      await bootstrapGroup(mlsGroupId, roomId: roomId, force: true);
      _mlsLog('Bootstrap completed for room $roomId');

      return true;
    } catch (e) {
      _mlsLogError('Failed to upgrade room $roomId to MLS: $e');
      return false;
    }
  }

  Future<int> _getCurrentStateVersion(String mlsGroupId) async {
    final state = await getGroupState(mlsGroupId);
    return (state?['state_version'] as int?) ?? 0;
  }

  Future<void> resetAndRebootstrapGroup({
    required String roomId,
    required String mlsGroupId,
    required String creatorAccountId,
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
        options: Options(headers: await _getMlsHeaders()),
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

    await bootstrapGroup(mlsGroupId, roomId: roomId, force: true);

    // Fetch all members and re-add them to the new MLS group (excluding creator)
    try {
      final allMembers = await _fetchAllChatRoomMembers(roomId);
      final membersToAdd = allMembers
          .where((id) => id != creatorAccountId)
          .toList();
      if (membersToAdd.isNotEmpty) {
        _mlsLog(
          'Re-adding ${membersToAdd.length} members to group $mlsGroupId (excluded creator)',
        );
        await addMembersAndFanoutWelcome(
          mlsGroupId,
          membersToAdd,
          chatRoomId: roomId,
        );
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
      final response = await _apiClient.get(
        '/messager/chat/$roomId/members',
        queryParameters: {
          'offset': offset.toString(),
          'take': pageSize.toString(),
        },
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
