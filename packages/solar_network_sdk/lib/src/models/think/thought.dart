import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'thought.freezed.dart';
part 'thought.g.dart';

enum ThinkingThoughtRole {
  assistant(0),
  user(1),
  system(2);

  const ThinkingThoughtRole(this.value);
  final int value;

  static ThinkingThoughtRole fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}

class ThinkingThoughtRoleConverter
    implements JsonConverter<ThinkingThoughtRole, int> {
  const ThinkingThoughtRoleConverter();

  @override
  ThinkingThoughtRole fromJson(int json) => ThinkingThoughtRole.fromValue(json);

  @override
  int toJson(ThinkingThoughtRole object) => object.value;
}

class ThinkingChunkTypeConverter
    implements JsonConverter<ThinkingChunkType, int> {
  const ThinkingChunkTypeConverter();

  @override
  ThinkingChunkType fromJson(int json) => ThinkingChunkType.fromValue(json);

  @override
  int toJson(ThinkingChunkType object) => object.value;
}

enum ThinkingMessagePartType {
  text(0),
  functionCall(1),
  functionResult(2),
  reasoning(3);

  const ThinkingMessagePartType(this.value);
  final int value;

  static ThinkingMessagePartType fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => text);
  }
}

class ThinkingMessagePartTypeConverter
    implements JsonConverter<ThinkingMessagePartType, int> {
  const ThinkingMessagePartTypeConverter();

  @override
  ThinkingMessagePartType fromJson(int json) =>
      ThinkingMessagePartType.fromValue(json);

  @override
  int toJson(ThinkingMessagePartType object) => object.value;
}

@freezed
sealed class StreamThinkingRequest with _$StreamThinkingRequest {
  const factory StreamThinkingRequest({
    required String userMessage,
    String? sequenceId,
    @Default([]) List<String> acceptProposals,
    List<String>? attachedPosts,
    List<Map<String, dynamic>>? attachedMessages,
    List<String>? attachedFiles,
    String? bot,
    String? model,
  }) = _StreamThinkingRequest;

  factory StreamThinkingRequest.fromJson(Map<String, dynamic> json) =>
      _$StreamThinkingRequestFromJson(json);
}

enum ThinkingChunkType {
  text(0),
  reasoning(1),
  functionCall(2),
  unknown(3);

  const ThinkingChunkType(this.value);
  final int value;

  static ThinkingChunkType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}

@freezed
sealed class SnThinkingChunk with _$SnThinkingChunk {
  const factory SnThinkingChunk({
    @ThinkingChunkTypeConverter() required ThinkingChunkType type,
    Map<String, dynamic>? data,
  }) = _SnThinkingChunk;

  factory SnThinkingChunk.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingChunkFromJson(json);
}

@freezed
sealed class SnFunctionCall with _$SnFunctionCall {
  const factory SnFunctionCall({
    required String id,
    required String name,
    required String arguments,
  }) = _SnFunctionCall;

  factory SnFunctionCall.fromJson(Map<String, dynamic> json) =>
      _$SnFunctionCallFromJson(json);
}

@freezed
sealed class SnFunctionResult with _$SnFunctionResult {
  const factory SnFunctionResult({
    required String callId,
    required dynamic result,
    required bool isError,
  }) = _SnFunctionResult;

  factory SnFunctionResult.fromJson(Map<String, dynamic> json) =>
      _$SnFunctionResultFromJson(json);
}

@freezed
sealed class SnThinkingMessagePart with _$SnThinkingMessagePart {
  const factory SnThinkingMessagePart({
    @ThinkingMessagePartTypeConverter() required ThinkingMessagePartType type,
    String? text,
    String? reasoning,
    Map<String, dynamic>? metadata,
    List<SnCloudFileReference>? files,
    SnFunctionCall? functionCall,
    SnFunctionResult? functionResult,
  }) = _SnThinkingMessagePart;

  factory SnThinkingMessagePart.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingMessagePartFromJson(json);
}

@freezed
sealed class SnThinkingSequence with _$SnThinkingSequence {
  const factory SnThinkingSequence({
    required String id,
    String? topic,
    @Default(0) int totalToken,
    @Default(0) int paidToken,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @JsonKey(name: "agent_initiated") @Default(false) bool agentInitiated,
    @JsonKey(name: "user_last_read_at") DateTime? userLastReadAt,
    @JsonKey(name: "last_message_at") required DateTime lastMessageAt,
    @JsonKey(name: "is_public") @Default(false) bool isPublic,
    String? botName,
  }) = _SnThinkingSequence;

  factory SnThinkingSequence.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingSequenceFromJson(json);
}

@freezed
sealed class SnThinkingThought with _$SnThinkingThought {
  const factory SnThinkingThought({
    required String id,
    @Default([]) List<SnThinkingMessagePart> parts,
    @ThinkingThoughtRoleConverter() required ThinkingThoughtRole role,
    int? tokenCount,
    String? modelName,
    String? botName,
    required String sequenceId,
    SnThinkingSequence? sequence,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required bool isArchived,
  }) = _SnThinkingThought;

  factory SnThinkingThought.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingThoughtFromJson(json);
}

@freezed
sealed class ThoughtServiceModel with _$ThoughtServiceModel {
  const factory ThoughtServiceModel({
    required String id,
    @JsonKey(name: "display_name") required String displayName,
    @JsonKey(name: "min_perk_level") @Default(0) int minPerkLevel,
    @JsonKey(name: "is_default") @Default(false) bool isDefault,
  }) = _ThoughtServiceModel;

  factory ThoughtServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ThoughtServiceModelFromJson(json);
}

@freezed
sealed class ThoughtService with _$ThoughtService {
  const factory ThoughtService({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: "available_models")
    @Default([])
    List<ThoughtServiceModel> availableModels,
  }) = _ThoughtService;

  factory ThoughtService.fromJson(Map<String, dynamic> json) =>
      _$ThoughtServiceFromJson(json);
}

@freezed
sealed class ThoughtServicesResponse with _$ThoughtServicesResponse {
  const factory ThoughtServicesResponse({
    required String defaultBot,
    @JsonKey(name: "bots") required List<ThoughtService> services,
  }) = _ThoughtServicesResponse;

  factory ThoughtServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ThoughtServicesResponseFromJson(json);
}
