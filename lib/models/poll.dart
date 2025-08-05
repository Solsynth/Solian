import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/publisher.dart';

part 'poll.freezed.dart';
part 'poll.g.dart';

@freezed
sealed class SnPollWithStats with _$SnPollWithStats {
  const factory SnPollWithStats({
    required Map<String, dynamic>? userAnswer,
    required Map<String, dynamic> stats,
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
