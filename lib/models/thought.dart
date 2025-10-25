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

@freezed
sealed class StreamThinkingRequest with _$StreamThinkingRequest {
  const factory StreamThinkingRequest({
    required String userMessage,
    String? sequenceId,
  }) = _StreamThinkingRequest;

  factory StreamThinkingRequest.fromJson(Map<String, dynamic> json) =>
      _$StreamThinkingRequestFromJson(json);
}

@freezed
sealed class SnThinkingSequence with _$SnThinkingSequence {
  const factory SnThinkingSequence({
    required String id,
    String? topic,
    required String accountId,
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
    @ThinkingThoughtRoleConverter() required ThinkingThoughtRole role,
    required String sequenceId,
    SnThinkingSequence? sequence,
  }) = _SnThinkingThought;

  factory SnThinkingThought.fromJson(Map<String, dynamic> json) =>
      _$SnThinkingThoughtFromJson(json);
}
