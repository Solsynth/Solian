import 'package:dio/dio.dart';

import '../base_api.dart';
import '../../models/accounts/account.dart';

/// API for notification endpoints (/notification).
///
/// Handles notifications, preferences, and push notifications.
class NotificationsApi extends BaseApi {
  NotificationsApi(super.dio);

  /// Base path for all notification endpoints.
  static const String _basePath = '/notification';

  // ==========================================
  // Notification endpoints
  // ==========================================

  /// Gets all notifications.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnNotification>> getNotifications({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/notifications',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnNotification.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific notification by ID.
  ///
  /// [notificationId] - The notification ID.
  Future<SnNotification> getNotification(String notificationId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/notifications/$notificationId',
    );
    return SnNotification.fromJson(response.data!);
  }

  /// Marks a notification as read.
  ///
  /// [notificationId] - The notification ID.
  Future<void> markAsRead(String notificationId) async {
    await post('$_basePath/notifications/$notificationId/read');
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    await post('$_basePath/notifications/read-all');
  }

  /// Deletes a notification.
  ///
  /// [notificationId] - The notification ID.
  Future<void> deleteNotification(String notificationId) async {
    await delete('$_basePath/notifications/$notificationId');
  }

  /// Deletes all notifications.
  Future<void> deleteAllNotifications() async {
    await delete('$_basePath/notifications');
  }

  /// Gets unread notification count.
  Future<int> getUnreadCount() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/notifications/unread-count',
    );
    return response.data!['count'] as int;
  }

  // ==========================================
  // Preference endpoints
  // ==========================================

  /// Gets notification preferences.
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await get<Map<String, dynamic>>('$_basePath/preferences');
    return response.data!;
  }

  /// Updates notification preferences.
  ///
  /// [preferences] - The preferences to update.
  Future<Map<String, dynamic>> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/preferences',
      data: preferences,
    );
    return response.data!;
  }

  /// Gets notification topics.
  Future<List<dynamic>> getTopics() async {
    final response = await get<List<dynamic>>('$_basePath/topics');
    return response.data ?? [];
  }

  /// Subscribes to a notification topic.
  ///
  /// [topicId] - The topic ID.
  Future<void> subscribeToTopic(String topicId) async {
    await post('$_basePath/topics/$topicId/subscribe');
  }

  /// Unsubscribes from a notification topic.
  ///
  /// [topicId] - The topic ID.
  Future<void> unsubscribeFromTopic(String topicId) async {
    await post('$_basePath/topics/$topicId/unsubscribe');
  }

  // ==========================================
  // Push notification endpoints
  // ==========================================

  /// Registers a device for push notifications.
  ///
  /// [token] - The push notification token.
  /// [platform] - The platform (e.g., 'ios', 'android').
  /// [deviceId] - The device ID.
  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/push/register',
      data: {'token': token, 'platform': platform, 'device_id': deviceId},
    );
    return response.data!;
  }

  /// Unregisters a device from push notifications.
  ///
  /// [deviceId] - The device ID.
  Future<void> unregisterPushToken(String deviceId) async {
    await delete('$_basePath/push/register/$deviceId');
  }

  /// Updates push notification settings.
  ///
  /// [deviceId] - The device ID.
  /// [settings] - The notification settings.
  Future<Map<String, dynamic>> updatePushSettings({
    required String deviceId,
    required Map<String, dynamic> settings,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/push/$deviceId/settings',
      data: settings,
    );
    return response.data!;
  }

  // ==========================================
  // In-app notification endpoints
  // ==========================================

  /// Gets in-app notification settings.
  Future<Map<String, dynamic>> getInAppSettings() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/in-app/settings',
    );
    return response.data!;
  }

  /// Updates in-app notification settings.
  ///
  /// [settings] - The settings to update.
  Future<Map<String, dynamic>> updateInAppSettings({
    required Map<String, dynamic> settings,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/in-app/settings',
      data: settings,
    );
    return response.data!;
  }

  /// Clears in-app notification badge.
  Future<void> clearBadge() async {
    await post('$_basePath/in-app/badge/clear');
  }

  // ==========================================
  // Activity endpoints
  // ==========================================

  /// Gets notification activity log.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getActivityLog({int offset = 0, int take = 50}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/activity',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets notification statistics.
  Future<Map<String, dynamic>> getStats() async {
    final response = await get<Map<String, dynamic>>('$_basePath/stats');
    return response.data!;
  }
}
