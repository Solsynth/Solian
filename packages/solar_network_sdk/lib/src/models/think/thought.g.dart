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
  acceptProposals:
      (json['accept_proposals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attachedPosts: (json['attached_posts'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  attachedMessages: (json['attached_messages'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  attachedFiles: (json['attached_files'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  bot: json['bot'] as String?,
  model: json['model'] as String?,
);

Map<String, dynamic> _$StreamThinkingRequestToJson(
  _StreamThinkingRequest instance,
) => <String, dynamic>{
  'user_message': instance.userMessage,
  'sequence_id': instance.sequenceId,
  'accept_proposals': instance.acceptProposals,
  'attached_posts': instance.attachedPosts,
  'attached_messages': instance.attachedMessages,
  'attached_files': instance.attachedFiles,
  'bot': instance.bot,
  'model': instance.model,
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
  metadata: json['metadata'] as Map<String, dynamic>?,
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
      .toList(),
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
  'metadata': instance.metadata,
  'files': instance.files?.map((e) => e.toJson()).toList(),
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
      agentInitiated: json['agent_initiated'] as bool? ?? false,
      userLastReadAt: json['user_last_read_at'] == null
          ? null
          : DateTime.parse(json['user_last_read_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      isPublic: json['is_public'] as bool? ?? false,
      botName: json['bot_name'] as String?,
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
      'agent_initiated': instance.agentInitiated,
      'user_last_read_at': instance.userLastReadAt?.toIso8601String(),
      'last_message_at': instance.lastMessageAt.toIso8601String(),
      'is_public': instance.isPublic,
      'bot_name': instance.botName,
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
      role: const ThinkingThoughtRoleConverter().fromJson(
        (json['role'] as num).toInt(),
      ),
      tokenCount: (json['token_count'] as num?)?.toInt(),
      modelName: json['model_name'] as String?,
      botName: json['bot_name'] as String?,
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
      isArchived: json['is_archived'] as bool,
    );

Map<String, dynamic> _$SnThinkingThoughtToJson(_SnThinkingThought instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parts': instance.parts.map((e) => e.toJson()).toList(),
      'role': const ThinkingThoughtRoleConverter().toJson(instance.role),
      'token_count': instance.tokenCount,
      'model_name': instance.modelName,
      'bot_name': instance.botName,
      'sequence_id': instance.sequenceId,
      'sequence': instance.sequence?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'is_archived': instance.isArchived,
    };

_ThoughtServiceModel _$ThoughtServiceModelFromJson(Map<String, dynamic> json) =>
    _ThoughtServiceModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      minPerkLevel: (json['min_perk_level'] as num?)?.toInt() ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$ThoughtServiceModelToJson(
  _ThoughtServiceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'description': instance.description,
  'min_perk_level': instance.minPerkLevel,
  'is_default': instance.isDefault,
};

_ThoughtService _$ThoughtServiceFromJson(Map<String, dynamic> json) =>
    _ThoughtService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      availableModels:
          (json['available_models'] as List<dynamic>?)
              ?.map(
                (e) => ThoughtServiceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ThoughtServiceToJson(
  _ThoughtService instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'available_models': instance.availableModels.map((e) => e.toJson()).toList(),
};

_ThoughtServicesResponse _$ThoughtServicesResponseFromJson(
  Map<String, dynamic> json,
) => _ThoughtServicesResponse(
  defaultBot: json['default_bot'] as String,
  services: (json['bots'] as List<dynamic>)
      .map((e) => ThoughtService.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ThoughtServicesResponseToJson(
  _ThoughtServicesResponse instance,
) => <String, dynamic>{
  'default_bot': instance.defaultBot,
  'bots': instance.services.map((e) => e.toJson()).toList(),
};
