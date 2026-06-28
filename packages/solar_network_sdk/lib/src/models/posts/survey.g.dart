// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnSurveyWithStats _$SnSurveyWithStatsFromJson(
  Map<String, dynamic> json,
) => _SnSurveyWithStats(
  userAnswer: json['user_answer'] == null
      ? null
      : SnSurveyAnswer.fromJson(json['user_answer'] as Map<String, dynamic>),
  stats: json['stats'] as Map<String, dynamic>? ?? const {},
  id: json['id'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => SnSurveyQuestion.fromJson(e as Map<String, dynamic>))
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
  status: $enumDecode(_$SnSurveyStatusEnumMap, json['status']),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  notifySubscribers: json['notify_subscribers'] as bool? ?? false,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => SnCloudFileReference.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnSurveyWithStatsToJson(_SnSurveyWithStats instance) =>
    <String, dynamic>{
      'user_answer': instance.userAnswer?.toJson(),
      'stats': instance.stats,
      'id': instance.id,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'description': instance.description,
      'ended_at': instance.endedAt?.toIso8601String(),
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'status': _$SnSurveyStatusEnumMap[instance.status]!,
      'published_at': instance.publishedAt?.toIso8601String(),
      'notify_subscribers': instance.notifySubscribers,
      'is_anonymous': instance.isAnonymous,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

const _$SnSurveyStatusEnumMap = {
  SnSurveyStatus.draft: 0,
  SnSurveyStatus.published: 1,
  SnSurveyStatus.archived: 2,
};

_SnSurvey _$SnSurveyFromJson(Map<String, dynamic> json) => _SnSurvey(
  id: json['id'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => SnSurveyQuestion.fromJson(e as Map<String, dynamic>))
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
  status: $enumDecode(_$SnSurveyStatusEnumMap, json['status']),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  notifySubscribers: json['notify_subscribers'] as bool? ?? false,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => SnCloudFileReference.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnSurveyToJson(_SnSurvey instance) => <String, dynamic>{
  'id': instance.id,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'title': instance.title,
  'description': instance.description,
  'ended_at': instance.endedAt?.toIso8601String(),
  'publisher_id': instance.publisherId,
  'publisher': instance.publisher?.toJson(),
  'status': _$SnSurveyStatusEnumMap[instance.status]!,
  'published_at': instance.publishedAt?.toIso8601String(),
  'notify_subscribers': instance.notifySubscribers,
  'is_anonymous': instance.isAnonymous,
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnSurveyQuestion _$SnSurveyQuestionFromJson(Map<String, dynamic> json) =>
    _SnSurveyQuestion(
      id: json['id'] as String,
      type: $enumDecode(_$SnSurveyQuestionTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => SnSurveyOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num).toInt(),
      isRequired: json['is_required'] as bool,
      maxSelections: (json['max_selections'] as num?)?.toInt(),
      maxLength: (json['max_length'] as num?)?.toInt(),
      minValue: (json['min_value'] as num?)?.toDouble(),
      maxValue: (json['max_value'] as num?)?.toDouble(),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map(
                (e) => SnCloudFileReference.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnSurveyQuestionToJson(_SnSurveyQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SnSurveyQuestionTypeEnumMap[instance.type]!,
      'options': instance.options?.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'is_required': instance.isRequired,
      'max_selections': instance.maxSelections,
      'max_length': instance.maxLength,
      'min_value': instance.minValue,
      'max_value': instance.maxValue,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

const _$SnSurveyQuestionTypeEnumMap = {
  SnSurveyQuestionType.singleChoice: 0,
  SnSurveyQuestionType.multipleChoice: 1,
  SnSurveyQuestionType.yesNo: 2,
  SnSurveyQuestionType.rating: 3,
  SnSurveyQuestionType.freeText: 4,
};

_SnSurveyOption _$SnSurveyOptionFromJson(Map<String, dynamic> json) =>
    _SnSurveyOption(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$SnSurveyOptionToJson(_SnSurveyOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'description': instance.description,
      'order': instance.order,
    };

_SnSurveyAnswer _$SnSurveyAnswerFromJson(Map<String, dynamic> json) =>
    _SnSurveyAnswer(
      id: json['id'] as String,
      answer: json['answer'] as Map<String, dynamic>,
      accountId: json['account_id'] as String,
      surveyId: json['survey_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnSurveyAnswerToJson(_SnSurveyAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'answer': instance.answer,
      'account_id': instance.accountId,
      'survey_id': instance.surveyId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'account': instance.account?.toJson(),
    };

_SnSurveySubscription _$SnSurveySubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnSurveySubscription(
  id: json['id'] as String,
  surveyId: json['survey_id'] as String,
  accountId: json['account_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnSurveySubscriptionToJson(
  _SnSurveySubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'survey_id': instance.surveyId,
  'account_id': instance.accountId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
