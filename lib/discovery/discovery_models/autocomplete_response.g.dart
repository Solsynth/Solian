// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutocompleteSuggestion _$AutocompleteSuggestionFromJson(
  Map<String, dynamic> json,
) => _AutocompleteSuggestion(
  type: json['type'] as String,
  keyword: json['keyword'] as String,
  data: json['data'],
);

Map<String, dynamic> _$AutocompleteSuggestionToJson(
  _AutocompleteSuggestion instance,
) => <String, dynamic>{
  'type': instance.type,
  'keyword': instance.keyword,
  'data': instance.data,
};
