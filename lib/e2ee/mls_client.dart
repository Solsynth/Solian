import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/talker.dart';
import 'mls_storage.dart';
import 'mls_identity_manager.dart';
import 'mls_group_manager.dart';
import 'mls_message_handler.dart';

class MlsClient {
  final MlsStorage _storage;
  late final MlsIdentityManager _identityManager;
  late final MlsGroupManager _groupManager;
  late final MlsMessageHandler _messageHandler;
  final Dio _padlockClient;

  MlsClient({required MlsStorage storage, required Dio padlockClient})
    : _storage = storage,
      _padlockClient = padlockClient {
    _identityManager = MlsIdentityManager(
      storage: storage,
      padlockClient: padlockClient,
    );
    _groupManager = MlsGroupManager(
      storage: storage,
      padlockClient: padlockClient,
    );
    _messageHandler = MlsMessageHandler(
      storage: storage,
      groupManager: _groupManager,
      padlockClient: padlockClient,
    );
  }

  MlsStorage get storage => _storage;
  MlsIdentityManager get identityManager => _identityManager;
  MlsGroupManager get groupManager => _groupManager;
  MlsMessageHandler get messageHandler => _messageHandler;

  Future<void> initialize() async {
    final deviceId = await _identityManager.getOrCreateDeviceId();
    talker.debug('MLS Client initialized with deviceId: $deviceId');
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
    required String roomId,
    required String ciphertext,
    required String? encryptionHeader,
  }) async {
    return _messageHandler.decryptMessage(
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
