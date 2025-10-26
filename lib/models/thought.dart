import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

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

@freezed
sealed class StreamThinkingRequest with _$StreamThinkingRequest {
  const factory StreamThinkingRequest({
    required String userMessage,
    String? sequenceId,
    @Default([]) List<String> accpetProposals,
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
    String? content,
    @Default([]) List<SnCloudFile> files,
    @Default([]) List<SnThinkingChunk> chunks,
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
