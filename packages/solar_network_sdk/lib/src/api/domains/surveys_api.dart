import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/posts/survey.dart';

/// API for survey-related endpoints (/survey).
///
/// Handles surveys, answers, and survey statistics.
class SurveysApi extends BaseApi {
  SurveysApi(super.dio);

  /// Base path for all survey endpoints.
  static const String _basePath = '/survey';

  // ==========================================
  // Survey endpoints
  // ==========================================

  /// Gets all surveys.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSurvey>> getSurveys({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/surveys',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnSurvey.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific survey by ID.
  ///
  /// [surveyId] - The survey ID.
  Future<SnSurveyWithStats> getSurvey(String surveyId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId',
    );
    return SnSurveyWithStats.fromJson(response.data!);
  }

  /// Creates a new survey.
  ///
  /// [title] - The survey title.
  /// [questions] - The survey questions.
  /// [expiresAt] - Optional expiration date.
  Future<SnSurvey> createSurvey({
    required String title,
    required List<SnSurveyQuestion> questions,
    DateTime? expiresAt,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/surveys',
      data: {
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
        if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
      },
    );
    return SnSurvey.fromJson(response.data!);
  }

  /// Updates a survey.
  ///
  /// [surveyId] - The survey ID.
  /// [data] - The data to update.
  Future<SnSurvey> updateSurvey({
    required String surveyId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId',
      data: data,
    );
    return SnSurvey.fromJson(response.data!);
  }

  /// Deletes a survey.
  ///
  /// [surveyId] - The survey ID.
  Future<void> deleteSurvey(String surveyId) async {
    await delete('$_basePath/surveys/$surveyId');
  }

  /// Closes a survey.
  ///
  /// [surveyId] - The survey ID.
  Future<SnSurvey> closeSurvey(String surveyId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId/close',
    );
    return SnSurvey.fromJson(response.data!);
  }

  // ==========================================
  // Answer endpoints
  // ==========================================

  /// Gets answers for a survey.
  ///
  /// [surveyId] - The survey ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSurveyAnswer>> getSurveyAnswers({
    required String surveyId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/surveys/$surveyId/answers',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnSurveyAnswer.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Submits an answer to a survey.
  ///
  /// [surveyId] - The survey ID.
  /// [questionId] - The question ID.
  /// [optionId] - The selected option ID.
  Future<SnSurveyAnswer> submitAnswer({
    required String surveyId,
    required String questionId,
    required String optionId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId/answers',
      data: {'question_id': questionId, 'option_id': optionId},
    );
    return SnSurveyAnswer.fromJson(response.data!);
  }

  /// Updates an answer.
  ///
  /// [surveyId] - The survey ID.
  /// [answerId] - The answer ID.
  /// [optionId] - The new selected option ID.
  Future<SnSurveyAnswer> updateAnswer({
    required String surveyId,
    required String answerId,
    required String optionId,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId/answers/$answerId',
      data: {'option_id': optionId},
    );
    return SnSurveyAnswer.fromJson(response.data!);
  }

  /// Deletes an answer.
  ///
  /// [surveyId] - The survey ID.
  /// [answerId] - The answer ID.
  Future<void> deleteAnswer({
    required String surveyId,
    required String answerId,
  }) async {
    await delete('$_basePath/surveys/$surveyId/answers/$answerId');
  }

  // ==========================================
  // Statistics endpoints
  // ==========================================

  /// Gets survey statistics.
  ///
  /// [surveyId] - The survey ID.
  Future<SnSurveyWithStats> getSurveyStats(String surveyId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId/stats',
    );
    return SnSurveyWithStats.fromJson(response.data!);
  }

  /// Gets survey results (aggregated).
  ///
  /// [surveyId] - The survey ID.
  Future<Map<String, dynamic>> getSurveyResults(String surveyId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/surveys/$surveyId/results',
    );
    return response.data!;
  }

  /// Gets survey participants.
  ///
  /// [surveyId] - The survey ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getSurveyParticipants({
    required String surveyId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/surveys/$surveyId/participants',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  // ==========================================
  // User endpoints
  // ==========================================

  /// Gets surveys created by the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSurvey>> getMySurveys({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/me/surveys',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnSurvey.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets surveys answered by the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSurvey>> getAnsweredSurveys({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/me/answered',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnSurvey.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  // ==========================================
  // Feed endpoints
  // ==========================================

  /// Gets surveys in feed (from followed users).
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnSurvey>> getSurveyFeed({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/feed',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnSurvey.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets trending surveys.
  ///
  /// [limit] - Number of surveys to return.
  Future<List<SnSurvey>> getTrendingSurveys({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/trending',
      queryParameters: {'limit': limit},
    );
    return parseList(response, SnSurvey.fromJson);
  }
}
