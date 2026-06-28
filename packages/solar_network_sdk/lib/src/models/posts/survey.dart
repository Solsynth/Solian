import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'survey.freezed.dart';
part 'survey.g.dart';

enum SnSurveyStatus {
  @JsonValue(0)
  draft,
  @JsonValue(1)
  published,
  @JsonValue(2)
  archived,
}

@freezed
sealed class SnSurveyWithStats with _$SnSurveyWithStats {
  const factory SnSurveyWithStats({
    required SnSurveyAnswer? userAnswer,
    @Default({}) Map<String, dynamic> stats,
    required String id,
    required List<SnSurveyQuestion> questions,
    String? title,
    String? description,
    DateTime? endedAt,
    required String publisherId,
    SnPublisher? publisher,
    required SnSurveyStatus status,
    DateTime? publishedAt,
    @Default(false) bool notifySubscribers,
    @Default(false) bool isAnonymous,
    @Default([]) List<SnCloudFileReference> attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnSurveyWithStats;

  factory SnSurveyWithStats.fromJson(Map<String, dynamic> json) =>
      _$SnSurveyWithStatsFromJson(json);
}

@freezed
sealed class SnSurvey with _$SnSurvey {
  const factory SnSurvey({
    required String id,
    required List<SnSurveyQuestion> questions,

    String? title,
    String? description,

    DateTime? endedAt,

    required String publisherId,
    SnPublisher? publisher,

    required SnSurveyStatus status,
    DateTime? publishedAt,
    @Default(false) bool notifySubscribers,
    @Default(false) bool isAnonymous,
    @Default([]) List<SnCloudFileReference> attachments,

    // ModelBase fields
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnSurvey;

  factory SnSurvey.fromJson(Map<String, dynamic> json) => _$SnSurveyFromJson(json);

  factory SnSurvey.fromSurveyWithStats(SnSurveyWithStats surveyWithStats) => SnSurvey(
    id: surveyWithStats.id,
    questions: surveyWithStats.questions,
    title: surveyWithStats.title,
    description: surveyWithStats.description,
    endedAt: surveyWithStats.endedAt,
    publisherId: surveyWithStats.publisherId,
    publisher: surveyWithStats.publisher,
    status: surveyWithStats.status,
    publishedAt: surveyWithStats.publishedAt,
    notifySubscribers: surveyWithStats.notifySubscribers,
    isAnonymous: surveyWithStats.isAnonymous,
    attachments: surveyWithStats.attachments,
    createdAt: surveyWithStats.createdAt,
    updatedAt: surveyWithStats.updatedAt,
    deletedAt: surveyWithStats.deletedAt,
  );
}

@freezed
sealed class SnSurveyQuestion with _$SnSurveyQuestion {
  const factory SnSurveyQuestion({
    required String id,

    required SnSurveyQuestionType type,
    List<SnSurveyOption>? options,

    required String title,
    String? description,
    required int order,
    required bool isRequired,

    int? maxSelections,
    int? maxLength,
    double? minValue,
    double? maxValue,
    @Default([]) List<SnCloudFileReference> attachments,
  }) = _SnSurveyQuestion;

  factory SnSurveyQuestion.fromJson(Map<String, dynamic> json) =>
      _$SnSurveyQuestionFromJson(json);
}

@freezed
sealed class SnSurveyOption with _$SnSurveyOption {
  const factory SnSurveyOption({
    required String id,
    required String label,
    String? description,
    required int order,
  }) = _SnSurveyOption;

  factory SnSurveyOption.fromJson(Map<String, dynamic> json) =>
      _$SnSurveyOptionFromJson(json);
}

enum SnSurveyQuestionType {
  @JsonValue(0)
  singleChoice,
  @JsonValue(1)
  multipleChoice,
  @JsonValue(2)
  yesNo,
  @JsonValue(3)
  rating,
  @JsonValue(4)
  freeText,
}

@freezed
sealed class SnSurveyAnswer with _$SnSurveyAnswer {
  const factory SnSurveyAnswer({
    required String id,
    required Map<String, dynamic> answer,
    required String accountId,
    required String surveyId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    SnAccount? account,
  }) = _SnSurveyAnswer;

  factory SnSurveyAnswer.fromJson(Map<String, dynamic> json) =>
      _$SnSurveyAnswerFromJson(json);
}

@freezed
sealed class SnSurveySubscription with _$SnSurveySubscription {
  const factory SnSurveySubscription({
    required String id,
    required String surveyId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnSurveySubscription;

  factory SnSurveySubscription.fromJson(Map<String, dynamic> json) =>
      _$SnSurveySubscriptionFromJson(json);
}
