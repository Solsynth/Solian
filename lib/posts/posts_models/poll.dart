import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/posts/posts_models/publisher.dart';

part 'poll.freezed.dart';
part 'poll.g.dart';

@freezed
sealed class SnPollWithStats with _$SnPollWithStats {
  const factory SnPollWithStats({
    required SnPollAnswer? userAnswer,
    @Default({}) Map<String, dynamic> stats,
    required String id,
    required List<SnPollQuestion> questions,
    String? title,
    String? description,
    DateTime? endedAt,
    required String publisherId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnPollWithStats;

  factory SnPollWithStats.fromJson(Map<String, dynamic> json) =>
      _$SnPollWithStatsFromJson(json);
}

@freezed
sealed class SnPoll with _$SnPoll {
  const factory SnPoll({
    required String id,
    required List<SnPollQuestion> questions,

    String? title,
    String? description,

    DateTime? endedAt,

    required String publisherId,
    SnPublisher? publisher,

    // ModelBase fields
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnPoll;

  factory SnPoll.fromJson(Map<String, dynamic> json) => _$SnPollFromJson(json);

  factory SnPoll.fromPollWithStats(SnPollWithStats pollWithStats) => SnPoll(
    id: pollWithStats.id,
    questions: pollWithStats.questions,
    title: pollWithStats.title,
    description: pollWithStats.description,
    endedAt: pollWithStats.endedAt,
    publisherId: pollWithStats.publisherId,
    createdAt: pollWithStats.createdAt,
    updatedAt: pollWithStats.updatedAt,
    deletedAt: pollWithStats.deletedAt,
  );
}

@freezed
sealed class SnPollQuestion with _$SnPollQuestion {
  const factory SnPollQuestion({
    required String id,

    required SnPollQuestionType type,
    List<SnPollOption>? options,

    required String title,
    String? description,
    required int order,
    required bool isRequired,
  }) = _SnPollQuestion;

  factory SnPollQuestion.fromJson(Map<String, dynamic> json) =>
      _$SnPollQuestionFromJson(json);
}

@freezed
sealed class SnPollOption with _$SnPollOption {
  const factory SnPollOption({
    required String id,
    required String label,
    String? description,
    required int order,
  }) = _SnPollOption;

  factory SnPollOption.fromJson(Map<String, dynamic> json) =>
      _$SnPollOptionFromJson(json);
}

enum SnPollQuestionType {
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
sealed class SnPollAnswer with _$SnPollAnswer {
  const factory SnPollAnswer({
    required String id,
    required Map<String, dynamic> answer,
    required String accountId,
    required String pollId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    SnAccount? account,
  }) = _SnPollAnswer;

  factory SnPollAnswer.fromJson(Map<String, dynamic> json) =>
      _$SnPollAnswerFromJson(json);
}
