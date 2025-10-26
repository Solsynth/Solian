// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreamThinkingRequest _$StreamThinkingRequestFromJson(
  Map<String, dynamic> json,
) => _StreamThinkingRequest(
  userMessage: json['user_message'] as String,
  sequenceId: json['sequence_id'] as String?,
  accpetProposals:
      (json['accpet_proposals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$StreamThinkingRequestToJson(
  _StreamThinkingRequest instance,
) => <String, dynamic>{
  'user_message': instance.userMessage,
  'sequence_id': instance.sequenceId,
  'accpet_proposals': instance.accpetProposals,
};

_SnThinkingChunk _$SnThinkingChunkFromJson(Map<String, dynamic> json) =>
    _SnThinkingChunk(
      type: const ThinkingChunkTypeConverter().fromJson(
        (json['type'] as num).toInt(),
      ),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SnThinkingChunkToJson(_SnThinkingChunk instance) =>
    <String, dynamic>{
      'type': const ThinkingChunkTypeConverter().toJson(instance.type),
      'data': instance.data,
    };

_SnThinkingSequence _$SnThinkingSequenceFromJson(Map<String, dynamic> json) =>
    _SnThinkingSequence(
      id: json['id'] as String,
      topic: json['topic'] as String?,
      totalToken: (json['total_token'] as num?)?.toInt() ?? 0,
      paidToken: (json['paid_token'] as num?)?.toInt() ?? 0,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnThinkingSequenceToJson(_SnThinkingSequence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'total_token': instance.totalToken,
      'paid_token': instance.paidToken,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnThinkingThought _$SnThinkingThoughtFromJson(Map<String, dynamic> json) =>
    _SnThinkingThought(
      id: json['id'] as String,
      content: json['content'] as String?,
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chunks:
          (json['chunks'] as List<dynamic>?)
              ?.map((e) => SnThinkingChunk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      role: const ThinkingThoughtRoleConverter().fromJson(
        (json['role'] as num).toInt(),
      ),
      tokenCount: (json['token_count'] as num?)?.toInt(),
      modelName: json['model_name'] as String?,
      sequenceId: json['sequence_id'] as String,
      sequence:
          json['sequence'] == null
              ? null
              : SnThinkingSequence.fromJson(
                json['sequence'] as Map<String, dynamic>,
              ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnThinkingThoughtToJson(_SnThinkingThought instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'chunks': instance.chunks.map((e) => e.toJson()).toList(),
      'role': const ThinkingThoughtRoleConverter().toJson(instance.role),
      'token_count': instance.tokenCount,
      'model_name': instance.modelName,
      'sequence_id': instance.sequenceId,
      'sequence': instance.sequence?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
