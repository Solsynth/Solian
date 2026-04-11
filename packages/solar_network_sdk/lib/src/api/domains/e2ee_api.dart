import 'package:solar_network_sdk/src/api/base_api.dart';

/// API for End-to-End Encryption endpoints (/e2ee).
///
/// Handles E2EE key management, MLS (Messaging Layer Security), and encryption operations.
class E2EEApi extends BaseApi {
  E2EEApi(super.dio);

  /// Base path for all E2EE endpoints.
  static const String _basePath = '/e2ee';

  // ==========================================
  // Key endpoints
  // ==========================================

  /// Gets the public key for a user.
  ///
  /// [accountId] - The account ID.
  Future<Map<String, dynamic>> getPublicKey(String accountId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/keys/$accountId',
    );
    return response.data!;
  }

  /// Uploads a public key.
  ///
  /// [keyData] - The public key data.
  /// [keyType] - The key type.
  Future<Map<String, dynamic>> uploadPublicKey({
    required String keyData,
    required String keyType,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/keys',
      data: {'key_data': keyData, 'key_type': keyType},
    );
    return response.data!;
  }

  /// Gets key backup.
  Future<Map<String, dynamic>> getKeyBackup() async {
    final response = await get<Map<String, dynamic>>('$_basePath/keys/backup');
    return response.data!;
  }

  /// Creates a key backup.
  ///
  /// [backupData] - The encrypted backup data.
  Future<Map<String, dynamic>> createKeyBackup({
    required Map<String, dynamic> backupData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/keys/backup',
      data: backupData,
    );
    return response.data!;
  }

  /// Rotates keys.
  ///
  /// [newKeyData] - The new key data.
  Future<Map<String, dynamic>> rotateKeys({
    required Map<String, dynamic> newKeyData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/keys/rotate',
      data: newKeyData,
    );
    return response.data!;
  }

  // ==========================================
  // MLS endpoints
  // ==========================================

  /// Gets MLS groups for the current user.
  Future<List<dynamic>> getMLSGroups() async {
    final response = await get<List<dynamic>>('$_basePath/mls/groups');
    return response.data ?? [];
  }

  /// Creates a new MLS group.
  ///
  /// [name] - The group name.
  /// [memberIds] - Initial member IDs.
  Future<Map<String, dynamic>> createMLSGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/mls/groups',
      data: {'name': name, 'member_ids': memberIds},
    );
    return response.data!;
  }

  /// Gets a specific MLS group.
  ///
  /// [groupId] - The group ID.
  Future<Map<String, dynamic>> getMLSGroup(String groupId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId',
    );
    return response.data!;
  }

  /// Updates an MLS group.
  ///
  /// [groupId] - The group ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateMLSGroup({
    required String groupId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes an MLS group.
  ///
  /// [groupId] - The group ID.
  Future<void> deleteMLSGroup(String groupId) async {
    await delete('$_basePath/mls/groups/$groupId');
  }

  /// Adds members to an MLS group.
  ///
  /// [groupId] - The group ID.
  /// [memberIds] - Member IDs to add.
  Future<Map<String, dynamic>> addMLSGroupMembers({
    required String groupId,
    required List<String> memberIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId/members',
      data: {'member_ids': memberIds},
    );
    return response.data!;
  }

  /// Removes members from an MLS group.
  ///
  /// [groupId] - The group ID.
  /// [memberIds] - Member IDs to remove.
  Future<Map<String, dynamic>> removeMLSGroupMembers({
    required String groupId,
    required List<String> memberIds,
  }) async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId/members',
      data: {'member_ids': memberIds},
    );
    return response.data!;
  }

  /// Gets MLS group messages.
  ///
  /// [groupId] - The group ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getMLSGroupMessages({
    required String groupId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/mls/groups/$groupId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Sends an MLS group message.
  ///
  /// [groupId] - The group ID.
  /// [encryptedContent] - The encrypted message content.
  Future<Map<String, dynamic>> sendMLSGroupMessage({
    required String groupId,
    required String encryptedContent,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId/messages',
      data: {'encrypted_content': encryptedContent},
    );
    return response.data!;
  }

  /// Gets MLS group key package.
  ///
  /// [groupId] - The group ID.
  Future<Map<String, dynamic>> getMLSGroupKeyPackage(String groupId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId/kp',
    );
    return response.data!;
  }

  /// Processes MLS group commit.
  ///
  /// [groupId] - The group ID.
  /// [commitData] - The commit data.
  Future<Map<String, dynamic>> processMLSCommit({
    required String groupId,
    required Map<String, dynamic> commitData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/mls/groups/$groupId/commit',
      data: commitData,
    );
    return response.data!;
  }

  // ==========================================
  // Encryption endpoints
  // ==========================================

  /// Encrypts data for a specific recipient.
  ///
  /// [recipientId] - The recipient's account ID.
  /// [data] - The data to encrypt.
  Future<Map<String, dynamic>> encryptForRecipient({
    required String recipientId,
    required Map<String, dynamic> data,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/encrypt/$recipientId',
      data: data,
    );
    return response.data!;
  }

  /// Decrypts data.
  ///
  /// [encryptedData] - The encrypted data.
  Future<Map<String, dynamic>> decrypt({
    required Map<String, dynamic> encryptedData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/decrypt',
      data: encryptedData,
    );
    return response.data!;
  }
}
