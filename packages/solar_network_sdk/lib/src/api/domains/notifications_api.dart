import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

/// API for notification endpoints (/ring/notification).
///
/// Handles notifications, preferences, and push notifications.
class NotificationsApi extends BaseApi {
  NotificationsApi(super.dio);

  /// Base path for all notification endpoints.
  static const String _basePath = '/ring';

  Map<String, dynamic>? _queryWithApp(
    String? app,
    Map<String, dynamic>? query,
  ) {
    final next = <String, dynamic>{...?query};
    if (app != null && app.isNotEmpty) {
      next['app'] = app;
    }
    return next.isEmpty ? null : next;
  }

  // Hardcoded notification topics
  static const List<SnNotificationTopic> _defaultTopics = [
    SnNotificationTopic(
      topic: 'posts.mentions.new',
      description: 'Post mentions',
    ),
    SnNotificationTopic(topic: 'post.replies', description: 'Post replies'),
    SnNotificationTopic(
      topic: 'posts.reactions.new',
      description: 'New reactions',
    ),
    SnNotificationTopic(topic: 'posts.awards.new', description: 'Post awards'),
    SnNotificationTopic(
      topic: 'subscriptions.discontinued_in_app',
      description: 'Subscription discontinued',
    ),
    SnNotificationTopic(
      topic: 'subscriptions.begun',
      description: 'Subscription started',
    ),
    SnNotificationTopic(topic: 'gifts.claimed', description: 'Gift claimed'),
    SnNotificationTopic(
      topic: 'wallets.transactions',
      description: 'Wallet transactions',
    ),
    SnNotificationTopic(
      topic: 'auth.verification',
      description: 'Auth verification',
    ),
    SnNotificationTopic(topic: 'invites.realms', description: 'Realm invites'),
  ];

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
    String? app,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/notifications',
      queryParameters: _queryWithApp(app, {'offset': offset, 'take': take}),
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
  Future<void> markAllAsRead({String? app}) async {
    await post(
      '$_basePath/notifications/all/read',
      queryParameters: _queryWithApp(app, null),
    );
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
  Future<int> getUnreadCount({String? app}) async {
    final response = await get<dynamic>(
      '$_basePath/notifications/count',
      queryParameters: _queryWithApp(app, null),
    );
    final data = response.data;
    if (data is num) return data.toInt();
    if (data is Map<String, dynamic>) {
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  // ==========================================
  // Preference endpoints
  // ==========================================

  /// Gets all notification preferences.
  Future<List<SnNotificationPreference>> getPreferences() async {
    final response = await get<List<dynamic>>(
      '$_basePath/notifications/preferences',
    );
    final data = response.data ?? [];
    return data
        .map(
          (json) =>
              SnNotificationPreference.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets preference for a specific topic.
  ///
  /// Returns the preference level for a topic. Returns Normal if no custom preference is set.
  Future<SnNotificationPreferenceLevel> getPreference(String topic) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/notifications/preferences/$topic',
    );
    final preference = response.data!['preference'] as int;
    return SnNotificationPreferenceLevel.fromValue(preference);
  }

  /// Sets or updates the preference for a topic.
  ///
  /// [topic] - The topic identifier.
  /// [preference] - The preference level to set.
  Future<void> setPreference(
    String topic,
    SnNotificationPreferenceLevel preference,
  ) async {
    await put<Map<String, dynamic>>(
      '$_basePath/notifications/preferences/$topic',
      data: {'preference': preference.value},
    );
  }

  /// Deletes the custom preference for a topic, resetting to default (Normal).
  ///
  /// [topic] - The topic identifier.
  Future<void> deletePreference(String topic) async {
    await delete('$_basePath/notifications/preferences/$topic');
  }

  /// Gets all available notification topics.
  ///
  /// Returns the hardcoded default topics. Users can set preferences for any custom topic.
  List<SnNotificationTopic> getTopics() {
    return _defaultTopics;
  }

  /// Gets only the default hardcoded topics.
  List<SnNotificationTopic> getDefaultTopics() {
    return _defaultTopics;
  }

  /// Adds a custom topic.
  ///
  /// [topic] - The custom topic identifier.
  /// [description] - Description for the topic.
  Future<void> addCustomTopic(String topic, String description) async {
    await post<Map<String, dynamic>>(
      '$_basePath/notifications/topics',
      data: {'topic': topic, 'description': description},
    );
  }

  // ==========================================
  // Push subscription endpoints
  // ==========================================

  /// Lists all push subscriptions for the current account.
  Future<List<SnNotificationPushSubscription>> getSubscriptions({
    String? app,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/notifications/subscription',
      queryParameters: _queryWithApp(app, null),
    );
    final data = response.data ?? [];
    return data
        .map(
          (json) => SnNotificationPushSubscription.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Gets the active push subscription for the current device session.
  ///
  /// Returns null if no subscription is active on this device.
  Future<SnNotificationPushSubscription?> getCurrentSubscription({
    String? app,
  }) async {
    final response = await get<dynamic>(
      '$_basePath/notifications/subscription/current',
      queryParameters: _queryWithApp(app, null),
    );
    if (response.data == null) return null;
    return SnNotificationPushSubscription.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Deletes a specific push subscription by ID.
  ///
  /// [subscriptionId] - The subscription ID to delete.
  Future<void> deleteSubscription(String subscriptionId) async {
    await delete('$_basePath/notifications/subscription/$subscriptionId');
  }

  /// Registers or updates a push subscription for the current device.
  Future<void> registerPushSubscription({
    required String deviceToken,
    required SnNotificationPushSubscriptionProvider provider,
    String? deviceName,
    String? appId,
  }) async {
    await put(
      '$_basePath/notifications/subscription',
      data: {
        'device_token': deviceToken,
        'provider': provider.value,
        if (deviceName != null && deviceName.isNotEmpty)
          'device_name': deviceName,
        if (appId != null && appId.isNotEmpty) 'app_id': appId,
      },
    );
  }

  /// Registers an SOP subscription for the current device.
  Future<Map<String, dynamic>> registerSopSubscription({
    required String deviceName,
    String? appId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/notifications/sop/subscription',
      data: {
        'device_name': deviceName,
        if (appId != null && appId.isNotEmpty) 'app_id': appId,
      },
    );
    return response.data ?? const {};
  }
}
