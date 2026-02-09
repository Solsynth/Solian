// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPollWithStats _$SnPollWithStatsFromJson(Map<String, dynamic> json) =>
    _SnPollWithStats(
      userAnswer: json['user_answer'] == null
          ? null
          : SnPollAnswer.fromJson(json['user_answer'] as Map<String, dynamic>),
      stats: json['stats'] as Map<String, dynamic>? ?? const {},
      id: json['id'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => SnPollQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      publisherId: json['publisher_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPollWithStatsToJson(_SnPollWithStats instance) =>
    <String, dynamic>{
      'user_answer': instance.userAnswer?.toJson(),
      'stats': instance.stats,
      'id': instance.id,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'description': instance.description,
      'ended_at': instance.endedAt?.toIso8601String(),
      'publisher_id': instance.publisherId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnPoll _$SnPollFromJson(Map<String, dynamic> json) => _SnPoll(
  id: json['id'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => SnPollQuestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  publisherId: json['publisher_id'] as String,
  publisher: json['publisher'] == null
      ? null
      : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPollToJson(_SnPoll instance) => <String, dynamic>{
  'id': instance.id,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'description': instance.description,
  'ended_at': instance.endedAt?.toIso8601String(),
  'publisher_id': instance.publisherId,
  'publisher': instance.publisher?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnPollQuestion _$SnPollQuestionFromJson(Map<String, dynamic> json) =>
    _SnPollQuestion(
      id: json['id'] as String,
      type: $enumDecode(_$SnPollQuestionTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => SnPollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num).toInt(),
      isRequired: json['is_required'] as bool,
    );

Map<String, dynamic> _$SnPollQuestionToJson(_SnPollQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SnPollQuestionTypeEnumMap[instance.type]!,
      'options': instance.options?.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'is_required': instance.isRequired,
    };

const _$SnPollQuestionTypeEnumMap = {
  SnPollQuestionType.singleChoice: 0,
  SnPollQuestionType.multipleChoice: 1,
  SnPollQuestionType.yesNo: 2,
  SnPollQuestionType.rating: 3,
  SnPollQuestionType.freeText: 4,
};

_SnPollOption _$SnPollOptionFromJson(Map<String, dynamic> json) =>
    _SnPollOption(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$SnPollOptionToJson(_SnPollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'description': instance.description,
      'order': instance.order,
    };

_SnPollAnswer _$SnPollAnswerFromJson(Map<String, dynamic> json) =>
    _SnPollAnswer(
      id: json['id'] as String,
      answer: json['answer'] as Map<String, dynamic>,
      accountId: json['account_id'] as String,
      pollId: json['poll_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnPollAnswerToJson(_SnPollAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'answer': instance.answer,
      'account_id': instance.accountId,
      'poll_id': instance.pollId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'account': instance.account?.toJson(),
    };
