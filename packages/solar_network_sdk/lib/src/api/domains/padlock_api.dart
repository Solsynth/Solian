import 'dart:convert';

import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/action_log.dart';
import 'package:solar_network_sdk/src/models/auth/auth_session.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/accounts/punishment.dart';

/// API for security / padlock endpoints (/padlock).
///
/// Handles security events, action logs, sessions, devices, and account security.
class PadlockApi extends BaseApi {
  PadlockApi(super.dio);

  /// Base path for all padlock endpoints.
  static const String _basePath = '/padlock';

  /// Gets paginated account action logs.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [action] - Filter by action type.
  Future<PaginatedResult<SnActionLog>> getActionLogs({
    int offset = 0,
    int take = 20,
    String? action,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/actions',
      queryParameters: {'offset': offset, 'take': take, 'action': action},
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnActionLog.fromJson),
      totalCount: totalCount,
    );
  }

  /// Gets all sessions for the current user with pagination and filtering.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [type] - Filter by session type (0=Login, 1=OAuth, 2=Oidc).
  /// [clientId] - Filter by client/device ID.
  /// [includeChildren] - Include child sessions in the response.
  Future<PaginatedResult<SnAuthSession>> getSessions({
    int offset = 0,
    int take = 20,
    int? type,
    String? clientId,
    bool? includeChildren,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/sessions',
      queryParameters: {
        'offset': offset,
        'take': take,
        'type': ?type,
        'clientId': ?clientId,
        'includeChildren': ?includeChildren,
      },
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAuthSession.fromJson),
      totalCount: totalCount,
    );
  }

  /// Gets direct children of a specific session.
  ///
  /// [sessionId] - The ID of the parent session.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnAuthSession>> getSessionChildren(
    String sessionId, {
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/sessions/$sessionId/children',
      queryParameters: {'offset': offset, 'take': take},
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAuthSession.fromJson),
      totalCount: totalCount,
    );
  }

  /// Revokes a specific session by ID.
  ///
  /// [sessionId] - The ID of the session to revoke.
  Future<void> revokeSession(String sessionId) async {
    await delete('$_basePath/sessions/$sessionId');
  }

  /// Revokes all sessions except the current one.
  Future<void> revokeAllOtherSessions() async {
    await delete('$_basePath/sessions/other');
  }

  /// Gets all authenticated devices with pagination.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnAuthDeviceWithSession>> getDevices({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/devices',
      queryParameters: {'offset': offset, 'take': take},
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAuthDeviceWithSession.fromJson),
      totalCount: totalCount,
    );
  }

  /// Revokes a specific device.
  ///
  /// [deviceId] - The ID of the device to revoke.
  Future<void> revokeDevice(String deviceId) async {
    await delete('$_basePath/devices/$deviceId');
  }

  /// Revokes all devices except the current one.
  Future<void> revokeAllOtherDevices() async {
    await delete('$_basePath/devices/other');
  }

  /// Updates the label of a device.
  ///
  /// [deviceId] - The ID of the device.
  /// [label] - The new label for the device.
  Future<void> updateDeviceLabel(String deviceId, String label) async {
    await patch('$_basePath/devices/$deviceId/label', data: jsonEncode(label));
  }

  /// Gets authorized applications for the current user.
  ///
  /// [type] - Filter by app type (0=Oidc, 1=AppConnect).
  Future<List<Map<String, dynamic>>> getAuthorizedApps({int? type}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/authorized-apps',
      queryParameters: {'type': ?type},
    );
    final data = response.data;
    if (data == null) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Updates the scopes of an authorized application.
  ///
  /// [appId] - The record ID of the authorized app entry.
  /// [scopes] - The new list of scopes.
  Future<void> authorizeAppScopes(String appId, List<String> scopes) async {
    await post(
      '$_basePath/authorized-apps/$appId/scopes',
      data: {'scopes': scopes},
    );
  }

  /// Deauthorizes (revokes) an authorized application by record ID.
  ///
  /// [id] - The record ID of the authorized app entry to revoke.
  /// [type] - App type filter (optional).
  Future<void> deauthorizeApp(String id, {int? type}) async {
    await delete(
      '$_basePath/authorized-apps/$id',
      queryParameters: {'type': ?type},
    );
  }

  // ==========================================
  // Punishment endpoints (/padlock/admin/accounts)
  // ==========================================

  /// Gets punishment overview for an account.
  ///
  /// [username] - The username of the account.
  /// Returns the most severe active punishment or null if none.
  Future<SnAccountPunishment?> getAccountPunishmentOverview(
    String username,
  ) async {
    final response = await get(
      '$_basePath/accounts/$username/punishments/overview',
    );
    return SnAccountPunishment.fromJson(response.data);
  }

  /// Gets all punishments for an account.
  ///
  /// [username] - The username of the account.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnAccountPunishment>> getAccountPunishments(
    String username, {
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/$username/punishments',
      queryParameters: {'offset': offset, 'take': take},
    );
    final items = parseList(response, SnAccountPunishment.fromJson);
    final totalCount = getTotalCount(response.headers);
    final hasMore = items.length == take;
    final cursor = hasMore ? (offset + take).toString() : null;
    return PaginatedResult(
      items: items,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  /// Creates a new punishment for an account.
  ///
  /// [username] - The username of the account.
  /// [reason] - The reason for the punishment.
  /// [type] - The type of punishment.
  /// [expiredAt] - Optional expiration time.
  /// [blockedPermissions] - Optional list of permissions to block.
  /// [socialCreditReduction] - Optional social credit reduction amount.
  Future<SnAccountPunishment> createPunishment({
    required String username,
    required String reason,
    required PunishmentType type,
    DateTime? expiredAt,
    List<String>? blockedPermissions,
    double? socialCreditReduction,
  }) async {
    final response = await post(
      '$_basePath/admin/accounts/$username/punishments',
      data: {
        'reason': reason,
        'type': type.value,
        'expired_at': expiredAt?.toUtc().toIso8601String(),
        'blocked_permissions': blockedPermissions,
        'social_credit_reduction': socialCreditReduction,
      },
    );
    return SnAccountPunishment.fromJson(response.data);
  }

  /// Updates an existing punishment.
  ///
  /// [username] - The username of the account.
  /// [punishmentId] - The ID of the punishment to update.
  /// [reason] - Optional new reason.
  /// [type] - Optional new type.
  /// [expiredAt] - Optional new expiration time.
  /// [blockedPermissions] - Optional new blocked permissions list.
  Future<SnAccountPunishment> updatePunishment({
    required String username,
    required String punishmentId,
    String? reason,
    PunishmentType? type,
    DateTime? expiredAt,
    List<String>? blockedPermissions,
  }) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;
    if (type != null) data['type'] = type.value;
    if (expiredAt != null) {
      data['expired_at'] = expiredAt.toUtc().toIso8601String();
    }
    if (blockedPermissions != null) {
      data['blocked_permissions'] = blockedPermissions;
    }

    final response = await patch<Map<String, dynamic>>(
      '$_basePath/admin/accounts/$username/punishments/$punishmentId',
      data: data,
    );
    return SnAccountPunishment.fromJson(response.data!);
  }

  /// Deletes a punishment.
  ///
  /// [username] - The username of the account.
  /// [punishmentId] - The ID of the punishment to delete.
  Future<void> deletePunishment(String username, String punishmentId) async {
    await delete(
      '$_basePath/admin/accounts/$username/punishments/$punishmentId',
    );
  }

  /// Gets all punishments created by the current admin user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnAccountPunishment>> getAdminCreatedPunishments({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/admin/accounts/punishments/created',
      queryParameters: {'offset': offset, 'take': take},
    );
    final items = parseList(response, SnAccountPunishment.fromJson);
    final totalCount = getTotalCount(response.headers);
    final hasMore = items.length == take;
    final cursor = hasMore ? (offset + take).toString() : null;
    return PaginatedResult(
      items: items,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }
}
