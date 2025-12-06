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
  attachedPosts: (json['attached_posts'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  attachedMessages: (json['attached_messages'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  serviceId: json['service_id'] as String?,
);

Map<String, dynamic> _$StreamThinkingRequestToJson(
  _StreamThinkingRequest instance,
) => <String, dynamic>{
  'user_message': instance.userMessage,
  'sequence_id': instance.sequenceId,
  'accpet_proposals': instance.accpetProposals,
  'attached_posts': instance.attachedPosts,
  'attached_messages': instance.attachedMessages,
  'service_id': instance.serviceId,
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

_SnFunctionCall _$SnFunctionCallFromJson(Map<String, dynamic> json) =>
    _SnFunctionCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );

Map<String, dynamic> _$SnFunctionCallToJson(_SnFunctionCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arguments': instance.arguments,
    };

_SnFunctionResult _$SnFunctionResultFromJson(Map<String, dynamic> json) =>
    _SnFunctionResult(
      callId: json['call_id'] as String,
      result: json['result'],
      isError: json['is_error'] as bool,
    );

Map<String, dynamic> _$SnFunctionResultToJson(_SnFunctionResult instance) =>
    <String, dynamic>{
      'call_id': instance.callId,
      'result': instance.result,
      'is_error': instance.isError,
    };

_SnThinkingMessagePart _$SnThinkingMessagePartFromJson(
  Map<String, dynamic> json,
) => _SnThinkingMessagePart(
  type: const ThinkingMessagePartTypeConverter().fromJson(
    (json['type'] as num).toInt(),
  ),
  text: json['text'] as String?,
  functionCall: json['function_call'] == null
      ? null
      : SnFunctionCall.fromJson(json['function_call'] as Map<String, dynamic>),
  functionResult: json['function_result'] == null
      ? null
      : SnFunctionResult.fromJson(
          json['function_result'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SnThinkingMessagePartToJson(
  _SnThinkingMessagePart instance,
) => <String, dynamic>{
  'type': const ThinkingMessagePartTypeConverter().toJson(instance.type),
  'text': instance.text,
  'function_call': instance.functionCall?.toJson(),
  'function_result': instance.functionResult?.toJson(),
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
      deletedAt: json['deleted_at'] == null
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
      parts:
          (json['parts'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SnThinkingMessagePart.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      role: const ThinkingThoughtRoleConverter().fromJson(
        (json['role'] as num).toInt(),
      ),
      tokenCount: (json['token_count'] as num?)?.toInt(),
      modelName: json['model_name'] as String?,
      sequenceId: json['sequence_id'] as String,
      sequence: json['sequence'] == null
          ? null
          : SnThinkingSequence.fromJson(
              json['sequence'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnThinkingThoughtToJson(_SnThinkingThought instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parts': instance.parts.map((e) => e.toJson()).toList(),
      'files': instance.files.map((e) => e.toJson()).toList(),
      'role': const ThinkingThoughtRoleConverter().toJson(instance.role),
      'token_count': instance.tokenCount,
      'model_name': instance.modelName,
      'sequence_id': instance.sequenceId,
      'sequence': instance.sequence?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_ThoughtService _$ThoughtServiceFromJson(Map<String, dynamic> json) =>
    _ThoughtService(
      serviceId: json['service_id'] as String,
      billingMultiplier: (json['billing_multiplier'] as num).toDouble(),
      perkLevel: (json['perk_level'] as num).toInt(),
    );

Map<String, dynamic> _$ThoughtServiceToJson(_ThoughtService instance) =>
    <String, dynamic>{
      'service_id': instance.serviceId,
      'billing_multiplier': instance.billingMultiplier,
      'perk_level': instance.perkLevel,
    };

_ThoughtServicesResponse _$ThoughtServicesResponseFromJson(
  Map<String, dynamic> json,
) => _ThoughtServicesResponse(
  defaultService: json['default_service'] as String,
  services: (json['services'] as List<dynamic>)
      .map((e) => ThoughtService.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ThoughtServicesResponseToJson(
  _ThoughtServicesResponse instance,
) => <String, dynamic>{
  'default_service': instance.defaultService,
  'services': instance.services.map((e) => e.toJson()).toList(),
};
