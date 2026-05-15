import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

/// API for notification endpoints (/ring/notification).
///
/// Handles notifications, preferences, and push notifications.
class NotificationsApi extends BaseApi {
  NotificationsApi(super.dio);

  /// Base path for all notification endpoints.
  static const String _basePath = '/ring';

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
    SnNotificationTopic(
      topic: 'livestream.started',
      description: 'Livestream started',
    ),
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
  Future<List<SnNotificationPushSubscription>> getSubscriptions() async {
    final response = await get<List<dynamic>>(
      '$_basePath/notifications/subscription',
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
  Future<SnNotificationPushSubscription?> getCurrentSubscription() async {
    final response = await get<dynamic>(
      '$_basePath/notifications/subscription/current',
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
}
