import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/accounts/relationship.dart';
import 'package:solar_network_sdk/src/models/accounts/progression.dart';
import 'package:solar_network_sdk/src/models/accounts/fortune.dart';
import 'package:solar_network_sdk/src/models/accounts/discovery.dart';
import 'package:solar_network_sdk/src/models/accounts/action_log.dart';
import 'package:solar_network_sdk/src/models/accounts/abuse_report.dart';
import 'package:solar_network_sdk/src/models/accounts/abuse_report_type.dart';
import 'package:solar_network_sdk/src/models/activity/activity.dart';

/// API for account-related endpoints (/passport).
///
/// Handles account management, relationships, progression, and abuse reports.
class AccountsApi extends BaseApi {
  AccountsApi(super.dio);

  /// Base path for all passport endpoints.
  static const String _basePath = '/passport';

  // ==========================================
  // Account endpoints
  // ==========================================

  /// Gets the current user's account information.
  Future<SnAccount> getCurrentAccount({Options? options}) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/me',
      options: options,
    );
    return SnAccount.fromJson(response.data!);
  }

  /// Updates the current user's account.
  ///
  /// [data] - The account data to update.
  Future<SnAccount> updateCurrentAccount({
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/accounts/me',
      data: data,
    );
    return SnAccount.fromJson(response.data!);
  }

  /// Deletes the current user's account.
  Future<void> deleteCurrentAccount() async {
    await delete('$_basePath/accounts/me');
  }

  /// Gets an account by username.
  ///
  /// [username] - The username to look up.
  Future<SnAccount> getAccountByUsername(String username) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/$username',
    );
    return SnAccount.fromJson(response.data!);
  }

  /// Gets an account by ID.
  ///
  /// [accountId] - The account ID to look up.
  Future<SnAccount> getAccountById(String accountId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/id/$accountId',
    );
    return SnAccount.fromJson(response.data!);
  }

  /// Gets the profile for an account.
  ///
  /// [username] - The username.
  Future<SnAccountProfile> getAccountProfile(String username) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/$username/profile',
    );
    return SnAccountProfile.fromJson(response.data!);
  }

  /// Gets badges for an account.
  ///
  /// [username] - The username.
  Future<List<SnAccountBadge>> getAccountBadges(String username) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/$username/badges',
    );
    return parseList(response, SnAccountBadge.fromJson);
  }

  /// Gets current user's badges.
  Future<List<SnAccountBadge>> getMyBadges() async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/badges',
    );
    return parseList(response, SnAccountBadge.fromJson);
  }

  /// Activates a badge for current user.
  ///
  /// [badgeId] - ID of the badge to activate.
  Future<void> activateBadge(String badgeId) async {
    await post(
      '$_basePath/accounts/me/badges/$badgeId/active',
    );
  }

  // ==========================================
  // Relationship endpoints
  // ==========================================

  /// Gets the relationship status with another account.
  ///
  /// [accountId] - The other account's ID.
  Future<SnRelationship> getRelationship(String accountId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/relationships/$accountId',
    );
    return SnRelationship.fromJson(response.data!);
  }

  /// Follows an account.
  ///
  /// [accountId] - The account ID to follow.
  Future<void> followAccount(String accountId) async {
    await post('$_basePath/relationships/$accountId/follow');
  }

  /// Unfollows an account.
  ///
  /// [accountId] - The account ID to unfollow.
  Future<void> unfollowAccount(String accountId) async {
    await delete('$_basePath/relationships/$accountId/follow');
  }

  /// Blocks an account.
  ///
  /// [accountId] - The account ID to block.
  Future<void> blockAccount(String accountId) async {
    await post('$_basePath/relationships/$accountId/block');
  }

  /// Unblocks an account.
  ///
  /// [accountId] - The account ID to unblock.
  Future<void> unblockAccount(String accountId) async {
    await delete('$_basePath/relationships/$accountId/block');
  }

  /// Mutes an account.
  ///
  /// [accountId] - The account ID to mute.
  /// [duration] - Optional duration in seconds.
  Future<void> muteAccount(String accountId, {int? duration}) async {
    await post(
      '$_basePath/relationships/$accountId/mute',
      data: duration != null ? {'duration': duration} : null,
    );
  }

  /// Unmutes an account.
  ///
  /// [accountId] - The account ID to unmute.
  Future<void> unmuteAccount(String accountId) async {
    await delete('$_basePath/relationships/$accountId/mute');
  }

  /// Gets the list of followers.
  ///
  /// [accountId] - Optional account ID (defaults to current user).
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<SnAccount>> getFollowers({
    String? accountId,
    int offset = 0,
    int take = 20,
  }) async {
    final path = accountId != null
        ? '$_basePath/accounts/$accountId/followers'
        : '$_basePath/accounts/me/followers';
    final response = await get<List<dynamic>>(
      path,
      queryParameters: {'offset': offset, 'take': take},
    );
    return parseList(response, SnAccount.fromJson);
  }

  /// Gets the list of following.
  ///
  /// [accountId] - Optional account ID (defaults to current user).
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<SnAccount>> getFollowing({
    String? accountId,
    int offset = 0,
    int take = 20,
  }) async {
    final path = accountId != null
        ? '$_basePath/accounts/$accountId/following'
        : '$_basePath/accounts/me/following';
    final response = await get<List<dynamic>>(
      path,
      queryParameters: {'offset': offset, 'take': take},
    );
    return parseList(response, SnAccount.fromJson);
  }

  /// Gets the friends overview (mutual follows).
  Future<List<SnAccount>> getFriendsOverview() async {
    final response = await get<List<dynamic>>('$_basePath/friends/overview');
    return parseList(response, SnAccount.fromJson);
  }

  // ==========================================
  // Progression endpoints
  // ==========================================

  /// Gets the current user's progression/achievement state.
  Future<SnAchievementState> getAchievementState() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/progression/achievements',
    );
    return SnAchievementState.fromJson(response.data!);
  }

  /// Gets the current user's quest state.
  Future<List<SnQuestState>> getQuestStates() async {
    final response = await get<List<dynamic>>('$_basePath/progression/quests');
    return parseList(response, SnQuestState.fromJson);
  }

  /// Claims a progression reward.
  ///
  /// [rewardId] - The reward ID to claim.
  Future<SnProgressRewardGrant> claimReward(String rewardId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/progression/rewards/$rewardId/claim',
    );
    return SnProgressRewardGrant.fromJson(response.data!);
  }

  // ==========================================
  // Discovery endpoints
  // ==========================================

  /// Gets the discovery profile.
  Future<SnDiscoveryProfile> getDiscoveryProfile() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/discovery/profile',
    );
    return SnDiscoveryProfile.fromJson(response.data!);
  }

  /// Updates the discovery profile.
  ///
  /// [data] - The profile data to update.
  Future<SnDiscoveryProfile> updateDiscoveryProfile({
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/discovery/profile',
      data: data,
    );
    return SnDiscoveryProfile.fromJson(response.data!);
  }

  /// Resets the discovery profile.
  Future<void> resetDiscoveryProfile() async {
    await post('$_basePath/discovery/reset');
  }

  /// Gets suggested accounts/interests.
  Future<SnSuggestedData> getSuggestions() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/discovery/suggestions',
    );
    return SnSuggestedData.fromJson(response.data!);
  }

  // ==========================================
  // Fortune endpoints
  // ==========================================

  /// Gets a fortune saying for today.
  Future<SnFortuneSaying> getDailyFortune() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/fortune/daily',
    );
    return SnFortuneSaying.fromJson(response.data!);
  }

  /// Gets a random fortune saying.
  Future<SnFortuneSaying> getRandomFortuneSaying() async {
    final response = await get<List<dynamic>>(
      '$_basePath/fortune/random',
    );
    return SnFortuneSaying.fromJson(response.data![0]);
  }

  /// Gets fortune history.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<SnFortuneSaying>> getFortuneHistory({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/fortune/history',
      queryParameters: {'offset': offset, 'take': take},
    );
    return parseList(response, SnFortuneSaying.fromJson);
  }

  // ==========================================
  // Check-in endpoints
  // ==========================================

  /// Gets today's check-in result.
  /// Returns null if not checked in yet.
  Future<SnCheckInResult?> getCheckInResultToday() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '$_basePath/accounts/me/check-in',
      );
      return SnCheckInResult.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Performs daily check-in.
  ///
  /// [captchaToken] - Optional captcha token if required.
  Future<void> checkIn({
    String? captchaToken,
  }) async {
    await post(
      '$_basePath/accounts/me/check-in',
      data: captchaToken != null ? {'token': captchaToken} : null,
    );
  }

  // ==========================================
  // Notable day endpoints
  // ==========================================

  /// Gets next upcoming notable day.
  Future<SnNotableDay?> getNextNotableDay() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '$_basePath/notable/me/next',
      );
      return SnNotableDay.fromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  /// Gets most recent notable day.
  Future<SnNotableDay?> getRecentNotableDay() async {
    try {
      final response = await get<List<dynamic>>(
        '$_basePath/notable/me/recent',
      );
      if (response.data == null || response.data!.isEmpty) return null;
      return SnNotableDay.fromJson(response.data![0]);
    } catch (e) {
      return null;
    }
  }

  /// Gets event calendar entries for a user.
  ///
  /// [username] - Username to fetch calendar for, null for current user.
  /// [year] - Year to fetch.
  /// [month] - Month to fetch (1-12).
  Future<List<SnEventCalendarEntry>> getEventCalendar({
    String? username,
    required int year,
    required int month,
  }) async {
    final path = username != null
        ? '$_basePath/accounts/$username/calendar'
        : '$_basePath/accounts/me/calendar';
    
    final response = await get<List<dynamic>>(
      path,
      queryParameters: {
        'year': year,
        'month': month,
      },
    );

    return parseList(response, SnEventCalendarEntry.fromJson);
  }

  // ==========================================
  // Social Credit endpoints
  // ==========================================

  /// Gets current user's social credit balance.
  Future<double> getSocialCredits() async {
    final response = await get<dynamic>(
      '$_basePath/accounts/me/credits',
    );
    
    final value = response.data;
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  /// Gets social credit transaction history.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSocialCreditRecord>> getSocialCreditHistory({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/credits/history',
      queryParameters: {
        'offset': offset,
        'take': take,
      },
    );
    
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnSocialCreditRecord.fromJson),
      totalCount: totalCount,
    );
  }

  // ==========================================
  // Abuse report endpoints
  // ==========================================

  /// Gets all abuse report types.
  Future<List<AbuseReportType>> getAbuseReportTypes() async {
    final response = await get<List<dynamic>>('$_basePath/abuse-reports/types');
    final data = response.data;
    if (data is! List) return [];
    return data
        .map((value) => AbuseReportType.fromValue(value as int))
        .toList();
  }

  /// Submits an abuse report.
  ///
  /// [targetId] - The ID of the reported entity.
  /// [targetType] - The type of the reported entity.
  /// [reportType] - The type of abuse.
  /// [description] - Optional description.
  Future<SnAbuseReport> submitAbuseReport({
    required String targetId,
    required String targetType,
    required AbuseReportType reportType,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/abuse-reports',
      data: {
        'target_id': targetId,
        'target_type': targetType,
        'report_type': reportType.value,
        'description': ?description,
      },
    );
    return SnAbuseReport.fromJson(response.data!);
  }

  // ==========================================
  // Action log endpoints
  // ==========================================

  /// Gets the action log for the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<SnActionLog>> getActionLog({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/actions/log',
      queryParameters: {'offset': offset, 'take': take},
    );
    return parseList(response, SnActionLog.fromJson);
  }

  /// Gets account timeline events.
  ///
  /// [username] - The username / account ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnAccountTimelineItem>> getAccountTimeline({
    required String username,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/$username/timeline',
      queryParameters: {'offset': offset, 'take': take},
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAccountTimelineItem.fromJson),
      totalCount: totalCount,
    );
  }

  // ==========================================
  // Realms endpoints (via passport)
  // ==========================================

  /// Joins a realm.
  ///
  /// [realmSlug] - The realm slug.
  Future<void> joinRealm(String realmSlug) async {
    await post('$_basePath/realms/$realmSlug/members/me');
  }

  /// Leaves a realm.
  ///
  /// [realmSlug] - The realm slug.
  Future<void> leaveRealm(String realmSlug) async {
    await delete('$_basePath/realms/$realmSlug/members/me');
  }

  /// Gets the current user's realms.
  Future<List<dynamic>> getMyRealms() async {
    final response = await get<List<dynamic>>('$_basePath/realms/members/me');
    return response.data ?? [];
  }
}
