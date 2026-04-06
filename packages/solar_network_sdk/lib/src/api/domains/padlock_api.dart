import 'dart:convert';

import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/action_log.dart';
import 'package:solar_network_sdk/src/models/auth/auth_session.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

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
  Future<PaginatedResult<SnActionLog>> getActionLogs({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/actions',
      queryParameters: {'offset': offset, 'take': take},
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
  Future<PaginatedResult<SnAuthSession>> getSessions({
    int offset = 0,
    int take = 20,
    int? type,
    String? clientId,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/sessions',
      queryParameters: {
        'offset': offset,
        'take': take,
        'type': ?type,
        'clientId': ?clientId,
      },
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

  /// Deauthorizes (revokes) an authorized application.
  ///
  /// [appId] - The ID of the app to deauthorize.
  /// [type] - App type filter (optional).
  Future<void> deauthorizeApp(String appId, {int? type}) async {
    await delete(
      '$_basePath/authorized-apps/$appId',
      queryParameters: {'type': ?type},
    );
  }
}
