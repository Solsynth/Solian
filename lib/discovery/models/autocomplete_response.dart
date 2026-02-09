import 'package:freezed_annotation/freezed_annotation.dart';

part 'autocomplete_response.freezed.dart';
part 'autocomplete_response.g.dart';

@freezed
sealed class AutocompleteSuggestion with _$AutocompleteSuggestion {
  const factory AutocompleteSuggestion({
    required String type,
    required String keyword,
    required dynamic data,
  }) = _AutocompleteSuggestion;

  factory AutocompleteSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteSuggestionFromJson(json);
}
