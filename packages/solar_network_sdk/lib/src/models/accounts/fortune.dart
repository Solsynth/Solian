import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune.g.dart';
part 'fortune.freezed.dart';

@freezed
sealed class SnFortuneSaying with _$SnFortuneSaying {
  const factory SnFortuneSaying({
    required String content,
    required String source,
    required String language,
  }) = _SnFortuneSaying;

  factory SnFortuneSaying.fromJson(Map<String, dynamic> json) =>
      _$SnFortuneSayingFromJson(json);
}
