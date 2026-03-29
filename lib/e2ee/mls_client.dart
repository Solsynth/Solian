import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_storage.dart';
import 'mls_identity_manager.dart';
import 'mls_group_manager.dart';
import 'mls_message_handler.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  talker.log('$_mlsLogPrefix$msg');
}

void _mlsLogWarn(dynamic msg) {
  talker.warning('$_mlsLogPrefix$msg');
}

class MlsClient {
  final MlsStorage _storage;
  late final MlsIdentityManager _identityManager;
  late final MlsGroupManager _groupManager;
  late final MlsMessageHandler _messageHandler;

  MlsClient({
    required MlsStorage storage,
    required Dio padlockClient,
    required Dio apiClient,
  }) : _storage = storage {
    _identityManager = MlsIdentityManager(
      storage: storage,
      padlockClient: padlockClient,
    );
    _groupManager = MlsGroupManager(
      storage: storage,
      padlockClient: padlockClient,
      apiClient: apiClient,
      identityManager: _identityManager,
    );
    _messageHandler = MlsMessageHandler(
      groupManager: _groupManager,
      identityManager: _identityManager,
      padlockClient: padlockClient,
    );
  }

  MlsStorage get storage => _storage;
  MlsIdentityManager get identityManager => _identityManager;
  MlsGroupManager get groupManager => _groupManager;
  MlsMessageHandler get messageHandler => _messageHandler;

  Future<void> setCurrentAccountId(String accountId) async {
    await _identityManager.setCurrentAccountId(accountId);
    _mlsLog('MLS Client account ID set: $accountId');
  }

  Future<void> initialize() async {
    await MlsEngineService.getInstance();
    await _identityManager.generateAndStoreSignerKeyPair();
    final deviceId = await _identityManager.getOrCreateDeviceId();
    _mlsLog('MLS Client initialized with deviceId: $deviceId');

    // Upload a KeyPackage if we have none stored (first launch or after rotation)
    final kpCount = await _identityManager.getKeyPackageUploadCount();
    if (kpCount < 3) {
      try {
        final toUpload = 3 - kpCount;
        for (var i = 0; i < toUpload; i++) {
          final kp = await _identityManager.generateKeyPackage();
          final kpBase64 = base64Encode(kp.keyPackageBytes);
          await _identityManager.uploadKeyPackage(kpBase64);
        }
        _mlsLog('Uploaded $toUpload KeyPackage(s) to padlock service');
      } catch (e) {
        _mlsLogWarn('Failed to upload KeyPackage during init: $e');
        // Non-fatal: MLS operations will still work for existing groups
      }
    }

    // Fetch and process pending E2EE envelopes (Welcome, Commit, Proposal)
    if (deviceId != null) {
      await _fetchAndProcessPendingEnvelopes(deviceId);
    }
  }

  Future<void> _fetchAndProcessPendingEnvelopes(String deviceId) async {
    try {
      final envelopes = await getPendingEnvelopes(deviceId);
      if (envelopes.isEmpty) return;

      _mlsLog('Processing ${envelopes.length} pending envelope(s)');
      for (final envelope in envelopes) {
        final envelopeId = envelope['id']?.toString();
        final envelopeType = envelope['type'] as int?;
        final ciphertext = envelope['ciphertext']?.toString();
        final mlsGroupId = envelope['group_id']?.toString();

        if (envelopeId == null || ciphertext == null || mlsGroupId == null) {
          _mlsLogWarn('Skipping envelope $envelopeId: missing required fields');
          continue;
        }

        try {
          if (envelopeType == MlsEnvelopeType.welcome.value) {
            final welcomeBytes = base64Decode(ciphertext);
            final result = await processWelcome(
              mlsGroupId: mlsGroupId,
              welcomeBytes: welcomeBytes,
            );
            if (result != null) {
              _mlsLog(
                'Processed welcome envelope $envelopeId for group $mlsGroupId',
              );
            }
          }
        } catch (e) {
          _mlsLogWarn('Failed to process envelope $envelopeId: $e');
        }

        // Ack envelope to remove from server
        await ackEnvelope(envelopeId, deviceId);
      }
    } catch (e) {
      _mlsLogWarn('Failed to fetch pending envelopes: $e');
    }
  }

  Future<bool> isDeviceRegistered() async {
    return _identityManager.hasCredential();
  }

  Future<String?> getDeviceId() async {
    return _identityManager.getOrCreateDeviceId();
  }

  Future<void> registerDevice(String credential) async {
    await _identityManager.setCredential(credential);
    _mlsLog('Device registered with credential');
  }

  Future<Map<String, dynamic>> encryptMessage({
    required String mlsGroupId,
    required String content,
    required List<String> attachmentIds,
    required MlsMessageType messageType,
    String? repliedMessageId,
    String? forwardedMessageId,
  }) async {
    return _messageHandler.encryptMessage(
      mlsGroupId: mlsGroupId,
      content: content,
      attachmentIds: attachmentIds,
      messageType: messageType,
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
    );
  }

  Future<Map<String, dynamic>?> decryptMessage({
    required String messageId,
    required String mlsGroupId,
    required String ciphertext,
    required String? encryptionHeader,
    String? encryptionScheme,
  }) async {
    return _messageHandler.decryptMessage(
      messageId: messageId,
      mlsGroupId: mlsGroupId,
      ciphertext: ciphertext,
      encryptionHeader: encryptionHeader,
      encryptionScheme: encryptionScheme,
    );
  }

  Future<int> getCurrentEpoch(String mlsGroupId) async {
    return _groupManager.getCurrentEpoch(mlsGroupId);
  }

  Future<Map<String, dynamic>?> bootstrapGroup(
    String mlsGroupId, {
    bool force = false,
  }) async {
    final result = await _groupManager.bootstrapGroup(mlsGroupId, force: force);
    if (result != null) {
      eventBus.fire(MlsEpochChangedEvent(mlsGroupId: mlsGroupId, newEpoch: 1));
    }
    return result;
  }

  Future<Map<String, dynamic>?> commitPending(String mlsGroupId) async {
    final result = await _groupManager.commitPending(mlsGroupId);
    if (result != null) {
      final newEpoch = result['epoch'] as int? ?? 1;
      eventBus.fire(
        MlsEpochChangedEvent(mlsGroupId: mlsGroupId, newEpoch: newEpoch),
      );
    }
    return result;
  }

  Future<void> handleReshareRequired(String mlsGroupId) async {
    await _groupManager.handleReshareRequired(mlsGroupId);
    eventBus.fire(MlsReshareRequiredEvent(mlsGroupId: mlsGroupId));
  }

  Future<void> fetchAndProcessPendingEnvelopes() async {
    final deviceId = await _identityManager.getOrCreateDeviceId();
    if (deviceId != null) {
      await _fetchAndProcessPendingEnvelopes(deviceId);
    } else {
      _mlsLogWarn('Cannot fetch pending envelopes: device ID is null');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingEnvelopes(
    String deviceId,
  ) async {
    return _messageHandler.getPendingEnvelopes(deviceId);
  }

  Future<bool> ackEnvelope(String envelopeId, String deviceId) async {
    return _messageHandler.ackEnvelope(envelopeId, deviceId);
  }

  Future<void> handleEpochChanged(String mlsGroupId, int newEpoch) async {
    await _groupManager.handleEpochChanged(mlsGroupId, newEpoch);
    eventBus.fire(
      MlsEpochChangedEvent(mlsGroupId: mlsGroupId, newEpoch: newEpoch),
    );
  }

  /// Add members to an existing MLS group and fan out the Welcome message.
  ///
  /// Fetches KeyPackages for [memberAccountIds] from the padlock service,
  /// calls `engine.addMembers()` to generate the commit + welcome,
  /// then sends the welcome to the server for distribution.
  Future<Uint8List?> addMembersAndFanoutWelcome(
    String mlsGroupId,
    List<String> memberAccountIds,
  ) async {
    final result = await _groupManager.addMembersAndFanoutWelcome(
      mlsGroupId,
      memberAccountIds,
    );
    if (result != null) {
      final newEpoch = await _groupManager.getCurrentEpoch(mlsGroupId);
      eventBus.fire(
        MlsEpochChangedEvent(mlsGroupId: mlsGroupId, newEpoch: newEpoch),
      );
    }
    return result;
  }

  /// Process an incoming Welcome message to join an MLS group.
  ///
  /// Called when the device receives a MlsWelcome envelope from the server.
  Future<Map<String, dynamic>?> processWelcome({
    required String mlsGroupId,
    required Uint8List welcomeBytes,
  }) async {
    final result = await _groupManager.processWelcome(
      mlsGroupId: mlsGroupId,
      welcomeBytes: welcomeBytes,
    );
    if (result != null) {
      final newEpoch = await _groupManager.getCurrentEpoch(mlsGroupId);
      _mlsLog(
        'Successfully processed welcome for group $mlsGroupId, new epoch $newEpoch',
      );
      eventBus.fire(
        MlsEpochChangedEvent(mlsGroupId: mlsGroupId, newEpoch: newEpoch),
      );
    }
    return result;
  }

  /// Process a Welcome envelope directly from the message handler.
  Future<Map<String, dynamic>?> processWelcomeEnvelope({
    required String mlsGroupId,
    required Uint8List welcomeBytes,
  }) async {
    return _messageHandler.processWelcomeEnvelope(
      mlsGroupId: mlsGroupId,
      welcomeBytes: welcomeBytes,
    );
  }

  /// Reset and re-bootstrap the MLS group for a room.
  Future<void> resetAndRebootstrapGroup({
    required String roomId,
    required String mlsGroupId,
    required String creatorAccountId,
  }) async {
    await _groupManager.resetAndRebootstrapGroup(
      roomId: roomId,
      mlsGroupId: mlsGroupId,
      creatorAccountId: creatorAccountId,
    );
  }
}

final mlsStorageProvider = Provider<MlsStorage>((ref) {
  return MlsStorage();
});

final mlsClientProvider = Provider<MlsClient>((ref) {
  final storage = ref.watch(mlsStorageProvider);
  final padlockClient = ref.watch(padlockApiClientProvider);
  final apiClient = ref.watch(apiClientProvider);
  final client = MlsClient(
    storage: storage,
    padlockClient: padlockClient,
    apiClient: apiClient,
  );
  client.initialize();
  return client;
});
