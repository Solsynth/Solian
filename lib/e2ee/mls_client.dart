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

class MlsClient {
  final MlsStorage _storage;
  late final MlsIdentityManager _identityManager;
  late final MlsGroupManager _groupManager;
  late final MlsMessageHandler _messageHandler;

  MlsClient({required MlsStorage storage, required Dio padlockClient})
    : _storage = storage {
    _identityManager = MlsIdentityManager(
      storage: storage,
      padlockClient: padlockClient,
    );
    _groupManager = MlsGroupManager(
      storage: storage,
      padlockClient: padlockClient,
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

  Future<void> initialize() async {
    await MlsEngineService.getInstance();
    await _identityManager.generateAndStoreSignerKeyPair();
    final deviceId = await _identityManager.getOrCreateDeviceId();
    talker.debug('MLS Client initialized with deviceId: $deviceId');

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
        talker.debug('Uploaded $toUpload KeyPackage(s) to padlock service');
      } catch (e) {
        talker.warning('Failed to upload KeyPackage during init: $e');
        // Non-fatal: MLS operations will still work for existing groups
      }
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
    talker.debug('Device registered with credential');
  }

  Future<Map<String, dynamic>> encryptMessage({
    required String roomId,
    required String content,
    required List<String> attachmentIds,
    required MlsMessageType messageType,
    String? repliedMessageId,
    String? forwardedMessageId,
  }) async {
    return _messageHandler.encryptMessage(
      roomId: roomId,
      content: content,
      attachmentIds: attachmentIds,
      messageType: messageType,
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
    );
  }

  Future<Map<String, dynamic>?> decryptMessage({
    required String messageId,
    required String roomId,
    required String ciphertext,
    required String? encryptionHeader,
  }) async {
    return _messageHandler.decryptMessage(
      messageId: messageId,
      roomId: roomId,
      ciphertext: ciphertext,
      encryptionHeader: encryptionHeader,
    );
  }

  Future<int> getCurrentEpoch(String roomId) async {
    return _groupManager.getCurrentEpoch(roomId);
  }

  Future<Map<String, dynamic>?> bootstrapGroup(String roomId) async {
    final result = await _groupManager.bootstrapGroup(roomId);
    if (result != null) {
      eventBus.fire(MlsEpochChangedEvent(roomId: roomId, newEpoch: 1));
    }
    return result;
  }

  Future<Map<String, dynamic>?> commitPending(String roomId) async {
    final result = await _groupManager.commitPending(roomId);
    if (result != null) {
      final newEpoch = result['epoch'] as int? ?? 1;
      eventBus.fire(MlsEpochChangedEvent(roomId: roomId, newEpoch: newEpoch));
    }
    return result;
  }

  Future<void> handleReshareRequired(String roomId) async {
    await _groupManager.handleReshareRequired(roomId);
    eventBus.fire(MlsReshareRequiredEvent(roomId: roomId));
  }

  Future<List<Map<String, dynamic>>> getPendingEnvelopes(
    String deviceId,
  ) async {
    return _messageHandler.getPendingEnvelopes(deviceId);
  }

  Future<bool> ackEnvelope(String envelopeId, String deviceId) async {
    return _messageHandler.ackEnvelope(envelopeId, deviceId);
  }

  Future<void> handleEpochChanged(String roomId, int newEpoch) async {
    await _groupManager.handleEpochChanged(roomId, newEpoch);
    eventBus.fire(MlsEpochChangedEvent(roomId: roomId, newEpoch: newEpoch));
  }

  /// Add members to an existing MLS group and fan out the Welcome message.
  ///
  /// Fetches KeyPackages for [memberAccountIds] from the padlock service,
  /// calls `engine.addMembers()` to generate the commit + welcome,
  /// then sends the welcome to the server for distribution.
  Future<Uint8List?> addMembersAndFanoutWelcome(
    String roomId,
    List<String> memberAccountIds,
  ) async {
    final result = await _groupManager.addMembersAndFanoutWelcome(
      roomId,
      memberAccountIds,
    );
    if (result != null) {
      final newEpoch = await _groupManager.getCurrentEpoch(roomId);
      eventBus.fire(MlsEpochChangedEvent(roomId: roomId, newEpoch: newEpoch));
    }
    return result;
  }

  /// Process an incoming Welcome message to join an MLS group.
  ///
  /// Called when the device receives a MlsWelcome envelope from the server.
  Future<Map<String, dynamic>?> processWelcome({
    required String roomId,
    required Uint8List welcomeBytes,
  }) async {
    final result = await _groupManager.processWelcome(
      roomId: roomId,
      welcomeBytes: welcomeBytes,
    );
    if (result != null) {
      final newEpoch = await _groupManager.getCurrentEpoch(roomId);
      eventBus.fire(MlsEpochChangedEvent(roomId: roomId, newEpoch: newEpoch));
    }
    return result;
  }

  /// Process a Welcome envelope directly from the message handler.
  Future<Map<String, dynamic>?> processWelcomeEnvelope({
    required String roomId,
    required Uint8List welcomeBytes,
  }) async {
    return _messageHandler.processWelcomeEnvelope(
      roomId: roomId,
      welcomeBytes: welcomeBytes,
    );
  }
}

final mlsStorageProvider = Provider<MlsStorage>((ref) {
  return MlsStorage();
});

final mlsClientProvider = Provider<MlsClient>((ref) {
  final storage = ref.watch(mlsStorageProvider);
  final padlockClient = ref.watch(padlockApiClientProvider);
  final client = MlsClient(storage: storage, padlockClient: padlockClient);
  client.initialize();
  return client;
});
