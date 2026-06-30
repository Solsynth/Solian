import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/accounts/relationship.dart';
import 'package:solar_network_sdk/src/models/accounts/progression.dart';
import 'package:solar_network_sdk/src/models/accounts/fortune.dart';
import 'package:solar_network_sdk/src/models/accounts/action_log.dart';
import 'package:solar_network_sdk/src/models/accounts/affiliation.dart';
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
    final response = await get<List<dynamic>>('$_basePath/accounts/me/badges');
    return parseList(response, SnAccountBadge.fromJson);
  }

  /// Activates a badge for current user.
  ///
  /// [badgeId] - ID of the badge to activate.
  Future<void> activateBadge(String badgeId) async {
    await post('$_basePath/accounts/me/badges/$badgeId/active');
  }

  /// Fetches the public badges manifest.
  ///
  /// Returns metadata for all progression badges (colors, icons, labels).
  /// No authentication required; response is cached for 1 hour server-side.
  Future<List<BadgeManifestEntry>> getBadgesManifest() async {
    final response = await get<Map<String, dynamic>>('/.well-known/badges');
    final badges = response.data?['badges'] as List<dynamic>? ?? [];
    return badges
        .map((e) => BadgeManifestEntry.fromJson(e as Map<String, dynamic>))
        .toList();
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
  Future<void> addAccountAsFriend(String accountId) async {
    await post('$_basePath/relationships/$accountId/friends');
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
  Future<List<SnFriendOverviewItem>> getFriendsOverview() async {
    final response = await get<List<dynamic>>('$_basePath/friends/overview');
    return parseList(response, SnFriendOverviewItem.fromJson);
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
    final response = await get<List<dynamic>>('$_basePath/fortune/random');
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
        queryParameters: {'version': 2},
        options: Options(receiveTimeout: const Duration(seconds: 60)),
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
  Future<void> checkIn({String? captchaToken}) async {
    await post(
      '$_basePath/accounts/me/check-in',
      queryParameters: {'version': 2},
      data: captchaToken != null ? jsonEncode(captchaToken) : null,
      options: Options(receiveTimeout: const Duration(seconds: 60)),
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
      final response = await get<List<dynamic>>('$_basePath/notable/me/recent');
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
  /// [includeNotableDays] - Whether to include notable days (holidays).
  Future<List<SnEventCalendarEntry>> getEventCalendar({
    String? username,
    required int year,
    required int month,
    bool includeNotableDays = false,
  }) async {
    final path = username != null
        ? '$_basePath/accounts/$username/calendar'
        : '$_basePath/accounts/me/calendar';

    final response = await get<List<dynamic>>(
      path,
      queryParameters: {
        'year': year,
        'month': month,
        'includeNotableDays': includeNotableDays,
      },
    );

    return parseList(response, SnEventCalendarEntry.fromJson);
  }

  /// Gets merged calendar for the authenticated user.
  ///
  /// [year] - Year to fetch.
  /// [month] - Month to fetch (1-12).
  Future<SnEventCalendarEntry> getMergedCalendar({
    required int year,
    required int month,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/me/calendar/merged',
      queryParameters: {'year': year, 'month': month},
    );

    return SnEventCalendarEntry.fromJson(response.data!);
  }

  /// Gets merged calendar for another user.
  ///
  /// [username] - Username to fetch calendar for.
  /// [year] - Year to fetch.
  /// [month] - Month to fetch (1-12).
  Future<SnEventCalendarEntry> getUserMergedCalendar({
    required String username,
    required int year,
    required int month,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/$username/calendar/merged',
      queryParameters: {'year': year, 'month': month},
    );

    return SnEventCalendarEntry.fromJson(response.data!);
  }

  // ==========================================
  // Calendar Events CRUD endpoints
  // ==========================================

  /// Lists calendar events for the authenticated user.
  ///
  /// [startTime] - Filter events starting after this time.
  /// [endTime] - Filter events ending before this time.
  /// [accountId] - Restrict to one accessible account.
  /// [query] - Matches title, description, location, or exact normalized tag.
  /// [tags] - Filter by one or more tags.
  /// [offset] - Pagination offset.
  /// [take] - Number of results to return.
  Future<PaginatedResult<SnUserCalendarEvent>> listCalendarEvents({
    DateTime? startTime,
    DateTime? endTime,
    String? accountId,
    String? query,
    List<String>? tags,
    int offset = 0,
    int take = 50,
  }) async {
    final queryParameters = <String, dynamic>{'offset': offset, 'take': take};

    if (startTime != null) {
      queryParameters['startTime'] = startTime.toUtc().toIso8601String();
    }
    if (endTime != null) {
      queryParameters['endTime'] = endTime.toUtc().toIso8601String();
    }
    if (accountId != null) {
      queryParameters['accountId'] = accountId;
    }
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }
    if (tags != null && tags.isNotEmpty) {
      queryParameters['tags'] = tags;
    }

    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/events',
      queryParameters: queryParameters,
    );

    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnUserCalendarEvent.fromJson),
      totalCount: totalCount,
    );
  }

  /// Creates a new calendar event.
  ///
  /// [title] - Event title (required, max 256 chars).
  /// [startTime] - Event start time in UTC (required).
  /// [endTime] - Event end time in UTC (required).
  /// [description] - Event description (optional, max 4096 chars).
  /// [location] - Event location (optional, max 512 chars).
  /// [isAllDay] - Whether this is an all-day event.
  /// [visibility] - Visibility level (0=Private, 100=Friends, 200=Public).
  /// [recurrence] - Recurrence pattern.
  /// [tags] - Free-form tags (will be normalized server-side: trimmed, lowercased, deduplicated).
  /// [meta] - Custom metadata.
  /// [iconId] - File ID for event icon.
  /// [backgroundId] - File ID for event background image.
  Future<SnUserCalendarEvent> createCalendarEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    bool isAllDay = false,
    int visibility = SnEventVisibility.private,
    SnRecurrencePattern? recurrence,
    List<String>? tags,
    Map<String, dynamic>? meta,
    String? iconId,
    String? backgroundId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/accounts/me/calendar/events',
      data: {
        'title': title,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'description': ?description,
        'location': ?location,
        'is_all_day': isAllDay,
        'visibility': visibility,
        if (recurrence != null)
          'recurrence': {
            'frequency': recurrence.frequency,
            'interval': recurrence.interval,
            if (recurrence.endDate != null)
              'end_date': recurrence.endDate!.toUtc().toIso8601String(),
            if (recurrence.occurrences != null)
              'occurrences': recurrence.occurrences,
            if (recurrence.daysOfWeek != null)
              'days_of_week': recurrence.daysOfWeek,
            if (recurrence.dayOfMonth != null)
              'day_of_month': recurrence.dayOfMonth,
            if (recurrence.monthOfYear != null)
              'month_of_year': recurrence.monthOfYear,
          },
        'tags': tags,
        'meta': ?meta,
        'icon_id': ?iconId,
        'background_id': ?backgroundId,
      },
    );

    return SnUserCalendarEvent.fromJson(response.data!);
  }

  /// Gets a specific calendar event by ID.
  ///
  /// [id] - Event ID.
  Future<SnUserCalendarEvent> getCalendarEvent(String id) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/me/calendar/events/$id',
    );
    return SnUserCalendarEvent.fromJson(response.data!);
  }

  /// Gets a specific calendar event by username and event ID.
  ///
  /// [username] - Account username.
  /// [id] - Event ID.
  Future<SnUserCalendarEvent> getUserCalendarEvent(
    String username,
    String id,
  ) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/$username/calendar/events/$id',
    );
    return SnUserCalendarEvent.fromJson(response.data!);
  }

  /// Updates an existing calendar event.
  ///
  /// [id] - Event ID.
  /// All other fields are optional - only provided fields will be updated.
  /// When [tags] is provided, it replaces the stored tag set.
  Future<SnUserCalendarEvent> updateCalendarEvent({
    required String id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    bool? isAllDay,
    int? visibility,
    SnRecurrencePattern? recurrence,
    List<String>? tags,
    Map<String, dynamic>? meta,
    String? iconId,
    String? backgroundId,
  }) async {
    final data = <String, dynamic>{
      'title': ?title,
      if (startTime != null) 'start_time': startTime.toUtc().toIso8601String(),
      if (endTime != null) 'end_time': endTime.toUtc().toIso8601String(),
      'description': ?description,
      'location': ?location,
      'is_all_day': ?isAllDay,
      'visibility': ?visibility,
      if (recurrence != null)
        'recurrence': recurrence.frequency == SnRecurrenceFrequency.none
            ? null
            : {
                'frequency': recurrence.frequency,
                'interval': recurrence.interval,
                if (recurrence.endDate != null)
                  'end_date': recurrence.endDate!.toUtc().toIso8601String(),
                if (recurrence.occurrences != null)
                  'occurrences': recurrence.occurrences,
                if (recurrence.daysOfWeek != null)
                  'days_of_week': recurrence.daysOfWeek,
                if (recurrence.dayOfMonth != null)
                  'day_of_month': recurrence.dayOfMonth,
                if (recurrence.monthOfYear != null)
                  'month_of_year': recurrence.monthOfYear,
              },
      'tags': tags,
      'meta': ?meta,
      'icon_id': ?iconId,
      'background_id': ?backgroundId,
    };

    final response = await put<Map<String, dynamic>>(
      '$_basePath/accounts/me/calendar/events/$id',
      data: data,
    );

    return SnUserCalendarEvent.fromJson(response.data!);
  }

  /// Deletes a calendar event (soft delete).
  ///
  /// [id] - Event ID.
  Future<void> deleteCalendarEvent(String id) async {
    await delete('$_basePath/accounts/me/calendar/events/$id');
  }

  // ==========================================
  // Calendar Subscription endpoints
  // ==========================================

  /// Lists account IDs the current user has subscribed to.
  Future<List<String>> listCalendarSubscriptions() async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/subscriptions',
    );
    return (response.data ?? []).cast<String>();
  }

  /// Subscribes to another user's public events.
  ///
  /// [accountId] - The target account to subscribe to.
  Future<void> subscribeToCalendar(String accountId) async {
    await post('$_basePath/accounts/me/calendar/subscriptions/$accountId');
  }

  /// Unsubscribes from another user's events.
  ///
  /// [accountId] - The target account to unsubscribe from.
  Future<void> unsubscribeFromCalendar(String accountId) async {
    await delete('$_basePath/accounts/me/calendar/subscriptions/$accountId');
  }

  /// Gets a list of account IDs subscribed to the current user's events.
  Future<List<String>> listCalendarSubscribers() async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/subscriptions/subscribers',
    );
    return (response.data ?? []).cast<String>();
  }

  // ==========================================
  // Calendar Event Tags endpoints
  // ==========================================

  /// Gets the current user's distinct calendar event tags.
  Future<List<String>> getUsedCalendarTags() async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/tags',
    );
    return (response.data ?? []).cast<String>();
  }

  // ==========================================
  // Calendar Search endpoints
  // ==========================================

  /// Searches accessible calendar events and notable days.
  ///
  /// [query] - Search text matching title, description, location, or exact normalized tag.
  /// [accountId] - Filter event-side results to one accessible account.
  /// [tags] - Filter by one or more event tags.
  /// [startTime] - Filter events starting after this time.
  /// [endTime] - Filter events ending before this time.
  /// [notableDayTag] - Filter notable days by tag (int: 0=Holiday, 1=Event, 2=Anniversary, 3=Memorial, 4=Festival).
  /// [offset] - Pagination offset.
  /// [take] - Number of results to return.
  Future<List<Map<String, dynamic>>> searchCalendarEvents({
    String? query,
    String? accountId,
    List<String>? tags,
    DateTime? startTime,
    DateTime? endTime,
    int? notableDayTag,
    int offset = 0,
    int take = 50,
  }) async {
    final queryParameters = <String, dynamic>{
      'offset': offset,
      'take': take,
    };

    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }
    if (accountId != null) {
      queryParameters['accountId'] = accountId;
    }
    if (tags != null && tags.isNotEmpty) {
      queryParameters['tags'] = tags;
    }
    if (startTime != null) {
      queryParameters['startTime'] = startTime.toUtc().toIso8601String();
    }
    if (endTime != null) {
      queryParameters['endTime'] = endTime.toUtc().toIso8601String();
    }
    if (notableDayTag != null) {
      queryParameters['notableDayTag'] = notableDayTag;
    }

    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/search',
      queryParameters: queryParameters,
    );

    return (response.data ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  // ==========================================
  // Notable Day Detail endpoints
  // ==========================================

  /// Gets generated notable day detail by synthetic occurrence key.
  ///
  /// [occurrenceKey] - Synthetic key in format: region|yyyy-MM-dd|source-identity
  /// Example: us|2026-12-25|christmas
  Future<Map<String, dynamic>> getNotableDayDetail(
    String occurrenceKey,
  ) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/accounts/me/calendar/notable-days/$occurrenceKey',
    );
    return response.data!;
  }

  // ==========================================
  // Event Countdown endpoints
  // ==========================================

  /// Gets upcoming event countdowns for the authenticated user.
  ///
  /// [take] - Number of countdowns to return (default 5).
  /// [offset] - Pagination offset.
  /// [includeNotableDays] - Whether to include notable days (default true).
  /// [tag] - Filter notable days by tag (Holiday, Event, Anniversary, Memorial, Festival).
  Future<PaginatedResult<SnEventCountdownItem>> getEventCountdowns({
    int take = 5,
    int offset = 0,
    bool includeNotableDays = true,
    String? tag,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/me/calendar/countdown',
      queryParameters: {
        'take': take,
        'offset': offset,
        'includeNotableDays': includeNotableDays,
        'tag': ?tag,
      },
    );
    final totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    return PaginatedResult(
      items: parseList(response, SnEventCountdownItem.fromJson),
      totalCount: totalCount,
    );
  }

  /// Gets upcoming event countdowns for another user.
  ///
  /// [username] - Username to fetch countdowns for.
  /// [take] - Number of countdowns to return (default 5).
  /// [offset] - Pagination offset.
  /// [includeNotableDays] - Whether to include notable days (default true).
  /// [tag] - Filter notable days by tag (Holiday, Event, Anniversary, Memorial, Festival).
  Future<PaginatedResult<SnEventCountdownItem>> getUserEventCountdowns(
    String username, {
    int take = 5,
    int offset = 0,
    bool includeNotableDays = true,
    String? tag,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/accounts/$username/calendar/countdown',
      queryParameters: {
        'take': take,
        'offset': offset,
        'includeNotableDays': includeNotableDays,
        'tag': ?tag,
      },
    );
    final totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    return PaginatedResult(
      items: parseList(response, SnEventCountdownItem.fromJson),
      totalCount: totalCount,
    );
  }

  // ==========================================
  // Social Credit endpoints
  // ==========================================

  /// Gets current user's social credit balance.
  Future<double> getSocialCredits() async {
    final response = await get<dynamic>('$_basePath/accounts/me/credits');

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
      queryParameters: {'offset': offset, 'take': take},
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
  // Affiliation spell endpoints
  // ==========================================

  /// Creates a new affiliation spell.
  ///
  /// [spell] - Optional custom spell word. If null, a random 8-char string is generated.
  Future<SnAffiliationSpell> createAffiliationSpell({String? spell}) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/affiliations',
      data: {'spell': ?spell},
    );
    return SnAffiliationSpell.fromJson(response.data!);
  }

  /// Lists the current user's affiliation spells.
  ///
  /// [order] - Sort order: 'date' or 'usage'.
  /// [desc] - Whether to sort descending.
  /// [take] - Number of items to take.
  /// [offset] - Pagination offset.
  Future<PaginatedResult<SnAffiliationSpell>> listAffiliationSpells({
    String order = 'date',
    bool desc = false,
    int take = 20,
    int offset = 0,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/affiliations',
      queryParameters: {
        'order': order,
        'desc': desc,
        'take': take,
        'offset': offset,
      },
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAffiliationSpell.fromJson),
      totalCount: totalCount,
    );
  }

  /// Gets an affiliation spell by ID.
  ///
  /// [id] - The spell ID.
  Future<SnAffiliationSpell> getAffiliationSpell(String id) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/affiliations/$id',
    );
    return SnAffiliationSpell.fromJson(response.data!);
  }

  /// Lists results for an affiliation spell.
  ///
  /// [id] - The spell ID.
  /// [desc] - Whether to sort descending.
  /// [take] - Number of items to take.
  /// [offset] - Pagination offset.
  Future<PaginatedResult<SnAffiliationResult>> listAffiliationResults(
    String id, {
    bool desc = false,
    int take = 20,
    int offset = 0,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/affiliations/$id/results',
      queryParameters: {'desc': desc, 'take': take, 'offset': offset},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: parseList(response, SnAffiliationResult.fromJson),
      totalCount: totalCount,
    );
  }

  /// Deletes an affiliation spell.
  ///
  /// [id] - The spell ID.
  Future<void> deleteAffiliationSpell(String id) async {
    await delete('$_basePath/affiliations/$id');
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
