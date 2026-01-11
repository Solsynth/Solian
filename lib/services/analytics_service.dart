import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:island/talker.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal() {
    _init();
  }

  FirebaseAnalytics? _analytics;
  bool _enabled = true;

  bool get _supportsAnalytics =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  void _init() {
    if (!_supportsAnalytics) return;
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      talker.warning('[Analytics] Failed to init: $e');
      _analytics = null;
    }
  }

  void logEvent(String name, Map<String, Object>? parameters) {
    if (!_enabled || !_supportsAnalytics) return;
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      talker.warning('[Analytics] Failed to log event $name: $e');
    }
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  void setUserId(String? id) {
    if (!_supportsAnalytics) return;
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      analytics.setUserId(id: id);
    } catch (e) {
      talker.warning('[Analytics] Failed to set user ID: $e');
    }
  }

  void logAppOpen() {
    logEvent('app_open', null);
  }

  void logLogin(String authMethod) {
    logEvent('login', {'auth_method': authMethod, 'platform': _getPlatform()});
  }

  void logLogout() {
    logEvent('logout', null);
  }

  void logPostViewed(String postId, String postType, String viewSource) {
    logEvent('post_viewed', {
      'post_id': postId,
      'post_type': postType,
      'view_source': viewSource,
    });
  }

  void logPostCreated(
    String postType,
    String visibility,
    bool hasAttachments,
    String publisherId,
  ) {
    logEvent('post_created', {
      'post_type': postType,
      'visibility': visibility,
      'has_attachments': hasAttachments ? 'yes' : 'no',
      'publisher_id': publisherId,
    });
  }

  void logPostReacted(
    String postId,
    String reactionSymbol,
    int attitude,
    bool isRemoving,
  ) {
    logEvent('post_reacted', {
      'post_id': postId,
      'reaction_symbol': reactionSymbol,
      'attitude': attitude,
      'is_removing': isRemoving ? 'yes' : 'no',
    });
  }

  void logPostReplied(
    String postId,
    String parentId,
    int characterCount,
    bool hasAttachments,
  ) {
    logEvent('post_replied', {
      'post_id': postId,
      'parent_id': parentId,
      'character_count': characterCount,
      'has_attachments': hasAttachments,
    });
  }

  void logPostShared(String postId, String shareMethod, String postType) {
    logEvent('post_shared', {
      'post_id': postId,
      'share_method': shareMethod,
      'post_type': postType,
    });
  }

  void logPostEdited(String postId, int contentChangeDelta) {
    logEvent('post_edited', {
      'post_id': postId,
      'content_change_delta': contentChangeDelta,
    });
  }

  void logPostDeleted(String postId, String postType, int timeSinceCreation) {
    logEvent('post_deleted', {
      'post_id': postId,
      'post_type': postType,
      'time_since_creation': timeSinceCreation,
    });
  }

  void logPostPinned(String postId, String pinMode, String realmId) {
    logEvent('post_pinned', {
      'post_id': postId,
      'pin_mode': pinMode,
      'realm_id': realmId,
    });
  }

  void logPostAwarded(
    String postId,
    double amount,
    String attitude,
    bool hasMessage,
  ) {
    logEvent('post_awarded', {
      'post_id': postId,
      'amount': amount,
      'attitude': attitude,
      'has_message': hasMessage ? 'yes' : 'no',
      'currency': 'NSP',
    });
  }

  void logPostTranslated(
    String postId,
    String sourceLanguage,
    String targetLanguage,
  ) {
    logEvent('post_translated', {
      'post_id': postId,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
    });
  }

  void logPostForwarded(
    String postId,
    String originalPostId,
    String publisherId,
  ) {
    logEvent('post_forwarded', {
      'post_id': postId,
      'original_post_id': originalPostId,
      'publisher_id': publisherId,
    });
  }

  void logMessageSent(
    String channelId,
    String messageType,
    bool hasAttachments,
    int attachmentCount,
  ) {
    logEvent('message_sent', {
      'channel_id': channelId,
      'message_type': messageType,
      'has_attachments': hasAttachments,
      'attachment_count': attachmentCount,
    });
  }

  void logMessageReceived(
    String channelId,
    String messageType,
    bool isMentioned,
  ) {
    logEvent('message_received', {
      'channel_id': channelId,
      'message_type': messageType,
      'is_mentioned': isMentioned,
    });
  }

  void logMessageReplied(
    String channelId,
    String originalMessageId,
    int replyDepth,
  ) {
    logEvent('message_replied', {
      'channel_id': channelId,
      'original_message_id': originalMessageId,
      'reply_depth': replyDepth,
    });
  }

  void logMessageEdited(
    String channelId,
    String messageId,
    int contentChangeDelta,
  ) {
    logEvent('message_edited', {
      'channel_id': channelId,
      'message_id': messageId,
      'content_change_delta': contentChangeDelta,
    });
  }

  void logMessageDeleted(
    String channelId,
    String messageId,
    String messageType,
    bool isOwn,
  ) {
    logEvent('message_deleted', {
      'channel_id': channelId,
      'message_id': messageId,
      'message_type': messageType,
      'is_own': isOwn,
    });
  }

  void logChatRoomOpened(String channelId, String roomType) {
    logEvent('chat_room_opened', {
      'channel_id': channelId,
      'room_type': roomType,
    });
  }

  void logChatJoined(String channelId, String roomType, bool isPublic) {
    logEvent('chat_joined', {
      'channel_id': channelId,
      'room_type': roomType,
      'is_public': isPublic,
    });
  }

  void logChatLeft(String channelId, String roomType) {
    logEvent('chat_left', {'channel_id': channelId, 'room_type': roomType});
  }

  void logChatInvited(String channelId, String invitedUserId) {
    logEvent('chat_invited', {
      'channel_id': channelId,
      'invited_user_id': invitedUserId,
    });
  }

  void logFileUploaded(
    String fileType,
    String fileSizeCategory,
    String uploadSource,
  ) {
    logEvent('file_uploaded', {
      'file_type': fileType,
      'file_size_category': fileSizeCategory,
      'upload_source': uploadSource,
    });
  }

  void logFileDownloaded(
    String fileType,
    String fileSizeCategory,
    String downloadMethod,
  ) {
    logEvent('file_downloaded', {
      'file_type': fileType,
      'file_size_category': fileSizeCategory,
      'download_method': downloadMethod,
    });
  }

  void logFileDeleted(
    String fileType,
    String fileSizeCategory,
    String deleteSource,
    bool isBatchDelete,
    int batchCount,
  ) {
    logEvent('file_deleted', {
      'file_type': fileType,
      'file_size_category': fileSizeCategory,
      'delete_source': deleteSource,
      'is_batch_delete': isBatchDelete,
      'batch_count': batchCount,
    });
  }

  void logStickerUsed(String packId, String stickerSlug, String context) {
    logEvent('sticker_used', {
      'pack_id': packId,
      'sticker_slug': stickerSlug,
      'context': context,
    });
  }

  void logStickerPackAdded(String packId, String packName, int stickerCount) {
    logEvent('sticker_pack_added', {
      'pack_id': packId,
      'pack_name': packName,
      'sticker_count': stickerCount,
    });
  }

  void logStickerPackViewed(String packId, int stickerCount, bool isOwned) {
    logEvent('sticker_pack_viewed', {
      'pack_id': packId,
      'sticker_count': stickerCount,
      'is_owned': isOwned,
    });
  }

  void logSearchPerformed(
    String searchType,
    String query,
    int resultCount,
    bool hasFilters,
  ) {
    logEvent('search_performed', {
      'search_type': searchType,
      'query': query,
      'result_count': resultCount,
      'has_filters': hasFilters,
    });
  }

  void logFeedSubscribed(String feedId, String feedUrl, int articleCount) {
    logEvent('feed_subscribed', {
      'feed_id': feedId,
      'feed_url': feedUrl,
      'article_count': articleCount,
    });
  }

  void logFeedUnsubscribed(String feedId, String feedUrl) {
    logEvent('feed_unsubscribed', {'feed_id': feedId, 'feed_url': feedUrl});
  }

  void logWalletTransfer(
    double amount,
    String currency,
    String payeeId,
    bool hasRemark,
  ) {
    logEvent('wallet_transfer', {
      'amount': amount,
      'currency': currency,
      'payee_id': payeeId,
      'has_remark': hasRemark,
    });
  }

  void logWalletBalanceChecked(List<String> currenciesViewed) {
    logEvent('wallet_balance_checked', {
      'currencies_viewed': currenciesViewed.join(','),
    });
  }

  void logWalletOpened(String activeTab) {
    logEvent('wallet_opened', {'active_tab': activeTab});
  }

  void logRealmJoined(String realmSlug, String realmType) {
    logEvent('realm_joined', {
      'realm_slug': realmSlug,
      'realm_type': realmType,
    });
  }

  void logRealmLeft(String realmSlug) {
    logEvent('realm_left', {'realm_slug': realmSlug});
  }

  void logFriendAdded(String friendId, String pickerMethod) {
    logEvent('friend_added', {
      'friend_id': friendId,
      'picker_method': pickerMethod,
    });
  }

  void logFriendRemoved(String relationshipId, String relationshipType) {
    logEvent('friend_removed', {
      'relationship_id': relationshipId,
      'relationship_type': relationshipType,
    });
  }

  void logUserBlocked(String blockedUserId, String previousRelationship) {
    logEvent('user_blocked', {
      'blocked_user_id': blockedUserId,
      'previous_relationship': previousRelationship,
    });
  }

  void logUserUnblocked(String unblockedUserId) {
    logEvent('user_unblocked', {'unblocked_user_id': unblockedUserId});
  }

  void logFriendRequestAccepted(String requesterId) {
    logEvent('friend_request_accepted', {'requester_id': requesterId});
  }

  void logFriendRequestDeclined(String requesterId) {
    logEvent('friend_request_declined', {'requester_id': requesterId});
  }

  void logThemeChanged(String oldMode, String newMode) {
    logEvent('theme_changed', {'old_mode': oldMode, 'new_mode': newMode});
  }

  void logLanguageChanged(String oldLanguage, String newLanguage) {
    logEvent('language_changed', {
      'old_language': oldLanguage,
      'new_language': newLanguage,
    });
  }

  void logAiQuerySent(
    int messageLength,
    String contextType,
    int attachedPostsCount,
  ) {
    logEvent('ai_query_sent', {
      'message_length': messageLength,
      'context_type': contextType,
      'attached_posts_count': attachedPostsCount,
    });
  }

  void logAiResponseReceived(int responseThoughtCount, String sequenceId) {
    logEvent('ai_response_received', {
      'response_thought_count': responseThoughtCount,
      'sequence_id': sequenceId,
    });
  }

  void logShuffleViewed(int postIndex, int totalPostsLoaded) {
    logEvent('shuffle_viewed', {
      'post_index': postIndex,
      'total_posts_loaded': totalPostsLoaded,
    });
  }

  void logDraftSaved(String draftId, String postType, bool hasContent) {
    logEvent('draft_saved', {
      'draft_id': draftId,
      'post_type': postType,
      'has_content': hasContent,
    });
  }

  void logDraftDeleted(String draftId, String postType) {
    logEvent('draft_deleted', {'draft_id': draftId, 'post_type': postType});
  }

  void logCategoryViewed(String categorySlug, String categoryId) {
    logEvent('category_viewed', {
      'category_slug': categorySlug,
      'category_id': categoryId,
    });
  }

  void logTagViewed(String tagSlug, String tagId) {
    logEvent('tag_viewed', {'tag_slug': tagSlug, 'tag_id': tagId});
  }

  void logCategorySubscribed(String categorySlug, String categoryId) {
    logEvent('category_subscribed', {
      'category_slug': categorySlug,
      'category_id': categoryId,
    });
  }

  void logTagSubscribed(String tagSlug, String tagId) {
    logEvent('tag_subscribed', {'tag_slug': tagSlug, 'tag_id': tagId});
  }

  void logNotificationViewed() {
    logEvent('notification_viewed', null);
  }

  void logNotificationActioned(String actionType, String notificationType) {
    logEvent('notification_actioned', {
      'action_type': actionType,
      'notification_type': notificationType,
    });
  }

  void logProfileUpdated(List<String> fieldsUpdated) {
    logEvent('profile_updated', {'fields_updated': fieldsUpdated.join(',')});
  }

  void logAvatarChanged(String imageSource, bool isCropped) {
    logEvent('avatar_changed', {
      'image_source': imageSource,
      'is_cropped': isCropped,
    });
  }

  String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'web';
  }
}
