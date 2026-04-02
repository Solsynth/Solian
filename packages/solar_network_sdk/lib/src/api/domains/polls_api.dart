import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/posts/poll.dart';

/// API for poll-related endpoints (/poll).
///
/// Handles polls, voting, and poll statistics.
class PollsApi extends BaseApi {
  PollsApi(super.dio);

  /// Base path for all poll endpoints.
  static const String _basePath = '/poll';

  // ==========================================
  // Poll endpoints
  // ==========================================

  /// Gets all polls.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPoll>> getPolls({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/polls',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPoll.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific poll by ID.
  ///
  /// [pollId] - The poll ID.
  Future<SnPollWithStats> getPoll(String pollId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/polls/$pollId',
    );
    return SnPollWithStats.fromJson(response.data!);
  }

  /// Creates a new poll.
  ///
  /// [title] - The poll title.
  /// [questions] - The poll questions.
  /// [expiresAt] - Optional expiration date.
  Future<SnPoll> createPoll({
    required String title,
    required List<SnPollQuestion> questions,
    DateTime? expiresAt,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/polls',
      data: {
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
        if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
      },
    );
    return SnPoll.fromJson(response.data!);
  }

  /// Updates a poll.
  ///
  /// [pollId] - The poll ID.
  /// [data] - The data to update.
  Future<SnPoll> updatePoll({
    required String pollId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/polls/$pollId',
      data: data,
    );
    return SnPoll.fromJson(response.data!);
  }

  /// Deletes a poll.
  ///
  /// [pollId] - The poll ID.
  Future<void> deletePoll(String pollId) async {
    await delete('$_basePath/polls/$pollId');
  }

  /// Closes a poll.
  ///
  /// [pollId] - The poll ID.
  Future<SnPoll> closePoll(String pollId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/polls/$pollId/close',
    );
    return SnPoll.fromJson(response.data!);
  }

  // ==========================================
  // Answer endpoints
  // ==========================================

  /// Gets answers for a poll.
  ///
  /// [pollId] - The poll ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPollAnswer>> getPollAnswers({
    required String pollId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/polls/$pollId/answers',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPollAnswer.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Submits an answer to a poll.
  ///
  /// [pollId] - The poll ID.
  /// [questionId] - The question ID.
  /// [optionId] - The selected option ID.
  Future<SnPollAnswer> submitAnswer({
    required String pollId,
    required String questionId,
    required String optionId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/polls/$pollId/answers',
      data: {'question_id': questionId, 'option_id': optionId},
    );
    return SnPollAnswer.fromJson(response.data!);
  }

  /// Updates an answer.
  ///
  /// [pollId] - The poll ID.
  /// [answerId] - The answer ID.
  /// [optionId] - The new selected option ID.
  Future<SnPollAnswer> updateAnswer({
    required String pollId,
    required String answerId,
    required String optionId,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/polls/$pollId/answers/$answerId',
      data: {'option_id': optionId},
    );
    return SnPollAnswer.fromJson(response.data!);
  }

  /// Deletes an answer.
  ///
  /// [pollId] - The poll ID.
  /// [answerId] - The answer ID.
  Future<void> deleteAnswer({
    required String pollId,
    required String answerId,
  }) async {
    await delete('$_basePath/polls/$pollId/answers/$answerId');
  }

  // ==========================================
  // Statistics endpoints
  // ==========================================

  /// Gets poll statistics.
  ///
  /// [pollId] - The poll ID.
  Future<SnPollWithStats> getPollStats(String pollId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/polls/$pollId/stats',
    );
    return SnPollWithStats.fromJson(response.data!);
  }

  /// Gets poll results (aggregated).
  ///
  /// [pollId] - The poll ID.
  Future<Map<String, dynamic>> getPollResults(String pollId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/polls/$pollId/results',
    );
    return response.data!;
  }

  /// Gets poll participants.
  ///
  /// [pollId] - The poll ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getPollParticipants({
    required String pollId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/polls/$pollId/participants',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  // ==========================================
  // User endpoints
  // ==========================================

  /// Gets polls created by the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPoll>> getMyPolls({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/me/polls',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPoll.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets polls answered by the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPoll>> getAnsweredPolls({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/me/answered',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPoll.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  // ==========================================
  // Feed endpoints
  // ==========================================

  /// Gets polls in feed (from followed users).
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPoll>> getPollFeed({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/feed',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPoll.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets trending polls.
  ///
  /// [limit] - Number of polls to return.
  Future<List<SnPoll>> getTrendingPolls({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/trending',
      queryParameters: {'limit': limit},
    );
    return parseList(response, SnPoll.fromJson);
  }
}
