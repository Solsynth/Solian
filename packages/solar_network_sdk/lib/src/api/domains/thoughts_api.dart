import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/think/thought.dart';

/// API for thoughts/insight endpoints (/insight).
///
/// Handles thought sequences, billing, and thought-related services.
class ThoughtsApi extends BaseApi {
  ThoughtsApi(super.dio);

  /// Base path for all insight endpoints.
  static const String _basePath = '/insight';

  // ==========================================
  // Thought sequence endpoints
  // ==========================================

  /// Gets all thought sequences.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<SnThinkingSequence>> getSequences({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/thought/sequences',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data?.map((e) => SnThinkingSequence.fromJson(e)).toList() ??
        [];
  }

  /// Gets a specific thought sequence by ID.
  ///
  /// [sequenceId] - The sequence ID.
  Future<SnThinkingSequence> getSequence(String sequenceId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/thought/sequences/$sequenceId',
    );
    return SnThinkingSequence.fromJson(response.data!);
  }

  /// Creates a new thought sequence.
  ///
  /// [title] - The sequence title.
  /// [content] - The sequence content.
  Future<Map<String, dynamic>> createSequence({
    required String title,
    required String content,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/thought/sequences',
      data: {'title': title, 'content': content},
    );
    return response.data!;
  }

  /// Updates a thought sequence.
  ///
  /// [sequenceId] - The sequence ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateSequence({
    required String sequenceId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/thought/sequences/$sequenceId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a thought sequence.
  ///
  /// [sequenceId] - The sequence ID.
  Future<void> deleteSequence(String sequenceId) async {
    await delete('$_basePath/thought/sequences/$sequenceId');
  }

  /// Marks a thought sequence as read.
  ///
  /// [sequenceId] - The sequence ID.
  Future<void> markSequenceAsRead(String sequenceId) async {
    await post('$_basePath/thought/sequences/$sequenceId/read');
  }

  // ==========================================
  // Thought service endpoints
  // ==========================================

  /// Gets available thought services.
  Future<ThoughtServicesResponse> getServices() async {
    final response = await get('$_basePath/thought/services');
    return ThoughtServicesResponse.fromJson(response.data);
  }

  /// Gets a specific thought service by ID.
  ///
  /// [serviceId] - The service ID.
  Future<Map<String, dynamic>> getService(String serviceId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/thought/services/$serviceId',
    );
    return response.data!;
  }

  // ==========================================
  // Billing endpoints
  // ==========================================

  /// Gets the current billing status.
  Future<Map<String, dynamic>> getBillingStatus() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/billing/status',
    );
    return response.data!;
  }

  /// Gets billing history.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getBillingHistory({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/billing/history',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets billing plans.
  Future<List<dynamic>> getBillingPlans() async {
    final response = await get<List<dynamic>>('$_basePath/billing/plans');
    return response.data ?? [];
  }

  /// Subscribes to a billing plan.
  ///
  /// [planId] - The plan ID.
  Future<Map<String, dynamic>> subscribeToPlan(String planId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/billing/subscribe',
      data: {'plan_id': planId},
    );
    return response.data!;
  }

  /// Cancels the current subscription.
  Future<void> cancelSubscription() async {
    await post('$_basePath/billing/cancel');
  }

  // ==========================================
  // Usage endpoints
  // ==========================================

  /// Gets current usage statistics.
  Future<Map<String, dynamic>> getUsageStats() async {
    final response = await get<Map<String, dynamic>>('$_basePath/usage');
    return response.data!;
  }

  /// Gets usage history.
  ///
  /// [startDate] - Start date (ISO 8601 format).
  /// [endDate] - End date (ISO 8601 format).
  Future<List<dynamic>> getUsageHistory({
    required String startDate,
    required String endDate,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/usage/history',
      queryParameters: {'start_date': startDate, 'end_date': endDate},
    );
    return response.data ?? [];
  }
}
