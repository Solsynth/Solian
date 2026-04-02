import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/action_log.dart';

/// API for security / padlock endpoints (/padlock).
///
/// Handles security events, action logs, and account security.
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
      queryParameters: {
        'offset': offset,
        'take': take,
      },
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnActionLog.fromJson),
      totalCount: totalCount,
    );
  }
}