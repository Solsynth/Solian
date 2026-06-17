import 'package:solar_network_sdk/solar_network_sdk.dart';

enum ThinkingThoughtRole { assistant, user, system }

ThinkingThoughtRole _roleFromString(String? value) {
  switch (value) {
    case 'assistant':
      return ThinkingThoughtRole.assistant;
    case 'system':
      return ThinkingThoughtRole.system;
    case 'user':
    default:
      return ThinkingThoughtRole.user;
  }
}

enum ThinkingMessagePartType { text, functionCall, functionResult, reasoning }

class SnFunctionCall {
  const SnFunctionCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;
  final String arguments;

  factory SnFunctionCall.fromJson(Map<String, dynamic> json) {
    return SnFunctionCall(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arguments: json['arguments']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arguments': arguments,
  };
}

class SnFunctionResult {
  const SnFunctionResult({
    required this.callId,
    required this.result,
    required this.isError,
  });

  final String callId;
  final dynamic result;
  final bool isError;

  factory SnFunctionResult.fromJson(Map<String, dynamic> json) {
    return SnFunctionResult(
      callId: json['callId']?.toString() ?? '',
      result: json['result'],
      isError: json['isError'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'callId': callId,
    'result': result,
    'isError': isError,
  };
}

class SnThinkingMessagePart {
  const SnThinkingMessagePart({
    required this.type,
    this.text,
    this.reasoning,
    this.metadata,
    this.files,
    this.functionCall,
    this.functionResult,
  });

  final ThinkingMessagePartType type;
  final String? text;
  final String? reasoning;
  final Map<String, dynamic>? metadata;
  final List<SnCloudFileReference>? files;
  final SnFunctionCall? functionCall;
  final SnFunctionResult? functionResult;
}

class SnThinkingSequence {
  const SnThinkingSequence({
    required this.id,
    this.topic,
    this.totalToken = 0,
    this.paidToken = 0,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.agentInitiated = false,
    this.userLastReadAt,
    required this.lastMessageAt,
    this.isPublic = false,
    this.botName,
  });

  final String id;
  final String? topic;
  final int totalToken;
  final int paidToken;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool agentInitiated;
  final DateTime? userLastReadAt;
  final DateTime lastMessageAt;
  final bool isPublic;
  final String? botName;

  factory SnThinkingSequence.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? '');
    return SnThinkingSequence(
      id: json['id']?.toString() ?? '',
      topic: json['title']?.toString(),
      accountId: json['account_id']?.toString() ?? '',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
      lastMessageAt: updatedAt ?? createdAt ?? DateTime.now(),
      botName: json['agent_id']?.toString(),
    );
  }
}

class SnThinkingThought {
  const SnThinkingThought({
    required this.id,
    this.parts = const [],
    required this.role,
    this.tokenCount,
    this.modelName,
    this.botName,
    required this.sequenceId,
    this.sequence,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isArchived,
  });

  final String id;
  final List<SnThinkingMessagePart> parts;
  final ThinkingThoughtRole role;
  final int? tokenCount;
  final String? modelName;
  final String? botName;
  final String sequenceId;
  final SnThinkingSequence? sequence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isArchived;

  factory SnThinkingThought.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final sequenceId = json['thread_id']?.toString() ?? '';
    return SnThinkingThought(
      id: json['id']?.toString() ?? '',
      role: _roleFromString(json['role']?.toString()),
      sequenceId: sequenceId,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: createdAt ?? DateTime.now(),
      isArchived: false,
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: json['content']?.toString() ?? '',
        ),
      ],
    );
  }

  factory SnThinkingThought.fromMessage({
    required PersonalityConversation conversation,
    required PersonalityMessage message,
    String? modelName,
    int? tokenCount,
    List<SnThinkingMessagePart>? parts,
  }) {
    return SnThinkingThought(
      id: message.id,
      parts:
          parts ??
          [
            SnThinkingMessagePart(
              type: ThinkingMessagePartType.text,
              text: message.content,
            ),
          ],
      role: _roleFromString(message.role),
      tokenCount: tokenCount,
      modelName: modelName,
      botName: conversation.agentId,
      sequenceId: conversation.id,
      sequence: SnThinkingSequence.fromJson(conversation.toJson()),
      createdAt: message.createdAt,
      updatedAt: message.createdAt,
      isArchived: false,
    );
  }
}

class ThoughtServiceModel {
  const ThoughtServiceModel({
    required this.id,
    required this.displayName,
    this.minPerkLevel = 0,
    this.isDefault = false,
  });

  final String id;
  final String displayName;
  final int minPerkLevel;
  final bool isDefault;

  factory ThoughtServiceModel.fromJson(Map<String, dynamic> json) {
    return ThoughtServiceModel(
      id: json['id']?.toString() ?? '',
      displayName:
          json['display_name']?.toString() ?? json['id']?.toString() ?? '',
      minPerkLevel: (json['min_perk_level'] as num?)?.toInt() ?? 0,
      isDefault: json['is_default'] == true,
    );
  }
}

class ThoughtService {
  const ThoughtService({
    required this.id,
    required this.name,
    required this.description,
    this.availableModels = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<ThoughtServiceModel> availableModels;

  factory ThoughtService.fromJson(Map<String, dynamic> json) {
    final model = json['model']?.toString();
    return ThoughtService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      availableModels: model == null || model.isEmpty
          ? const []
          : [
              ThoughtServiceModel(
                id: model,
                displayName: model,
                isDefault: true,
              ),
            ],
    );
  }
}

class ThoughtServicesResponse {
  const ThoughtServicesResponse({
    required this.defaultBot,
    required this.services,
  });

  final String defaultBot;
  final List<ThoughtService> services;
}

class PersonalityConversation {
  const PersonalityConversation({
    required this.id,
    required this.accountId,
    required this.agentId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String accountId;
  final String agentId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PersonalityConversation.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? '');
    return PersonalityConversation(
      id: json['id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'New conversation',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'agent_id': agentId,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class PersonalityMessage {
  const PersonalityMessage({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
    required this.sequence,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String role;
  final String content;
  final int sequence;
  final DateTime createdAt;

  factory PersonalityMessage.fromJson(Map<String, dynamic> json) {
    return PersonalityMessage(
      id: json['id']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class PersonalityRun {
  const PersonalityRun({
    required this.id,
    required this.status,
    this.model,
  });

  final String id;
  final String status;
  final String? model;

  factory PersonalityRun.fromJson(Map<String, dynamic> json) {
    return PersonalityRun(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      model: json['model']?.toString(),
    );
  }
}

class PersonalityRunResponse {
  const PersonalityRunResponse({
    required this.thread,
    required this.run,
    required this.requestMessage,
    required this.responseMessage,
    required this.content,
  });

  final PersonalityConversation thread;
  final PersonalityRun run;
  final PersonalityMessage requestMessage;
  final PersonalityMessage responseMessage;
  final String content;

  factory PersonalityRunResponse.fromJson(Map<String, dynamic> json) {
    return PersonalityRunResponse(
      thread: PersonalityConversation.fromJson(
        json['thread'] as Map<String, dynamic>,
      ),
      run: PersonalityRun.fromJson(json['run'] as Map<String, dynamic>),
      requestMessage: PersonalityMessage.fromJson(
        json['request_message'] as Map<String, dynamic>,
      ),
      responseMessage: PersonalityMessage.fromJson(
        json['response_message'] as Map<String, dynamic>,
      ),
      content: json['content']?.toString() ?? '',
    );
  }
}
