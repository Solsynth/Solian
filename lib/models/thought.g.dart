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
);

Map<String, dynamic> _$StreamThinkingRequestToJson(
  _StreamThinkingRequest instance,
) => <String, dynamic>{
  'user_message': instance.userMessage,
  'sequence_id': instance.sequenceId,
};

_SnThinkingSequence _$SnThinkingSequenceFromJson(Map<String, dynamic> json) =>
    _SnThinkingSequence(
      id: json['id'] as String,
      topic: json['topic'] as String?,
      accountId: json['account_id'] as String,
    );

Map<String, dynamic> _$SnThinkingSequenceToJson(_SnThinkingSequence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'account_id': instance.accountId,
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
      role: const ThinkingThoughtRoleConverter().fromJson(
        (json['role'] as num).toInt(),
      ),
      sequenceId: json['sequence_id'] as String,
      sequence:
          json['sequence'] == null
              ? null
              : SnThinkingSequence.fromJson(
                json['sequence'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$SnThinkingThoughtToJson(_SnThinkingThought instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'role': const ThinkingThoughtRoleConverter().toJson(instance.role),
      'sequence_id': instance.sequenceId,
      'sequence': instance.sequence?.toJson(),
    };
