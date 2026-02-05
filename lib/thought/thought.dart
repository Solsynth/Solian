import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/drive/drive_models/file.dart';

part 'thought.freezed.dart';
part 'thought.g.dart';

enum ThinkingThoughtRole {
  assistant(0),
  user(1);

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
  functionResult(2);

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
    @Default([]) List<String> accpetProposals,
    List<String>? attachedPosts,
    List<Map<String, dynamic>>? attachedMessages,
    @JsonKey(name: 'service_id') String? serviceId,
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
  }) = _SnThinkingSequence;

  factory SnThinkingSequence.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingSequenceFromJson(json);
}

@freezed
sealed class SnThinkingThought with _$SnThinkingThought {
  const factory SnThinkingThought({
    required String id,
    @Default([]) List<SnThinkingMessagePart> parts,
    @Default([]) List<SnCloudFile> files,
    @ThinkingThoughtRoleConverter() required ThinkingThoughtRole role,
    int? tokenCount,
    String? modelName,
    required String sequenceId,
    SnThinkingSequence? sequence,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnThinkingThought;

  factory SnThinkingThought.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingThoughtFromJson(json);
}

@freezed
sealed class ThoughtService with _$ThoughtService {
  const factory ThoughtService({
    @JsonKey(name: 'service_id') required String serviceId,
    required double billingMultiplier,
    required int perkLevel,
  }) = _ThoughtService;

  factory ThoughtService.fromJson(Map<String, dynamic> json) =>
      _$ThoughtServiceFromJson(json);
}

@freezed
sealed class ThoughtServicesResponse with _$ThoughtServicesResponse {
  const factory ThoughtServicesResponse({
    @JsonKey(name: 'default_service') required String defaultService,
    required List<ThoughtService> services,
  }) = _ThoughtServicesResponse;

  factory ThoughtServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ThoughtServicesResponseFromJson(json);
}
