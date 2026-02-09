// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fortune.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFortuneSaying _$SnFortuneSayingFromJson(Map<String, dynamic> json) =>
    _SnFortuneSaying(
      content: json['content'] as String,
      source: json['source'] as String,
      language: json['language'] as String,
    );

Map<String, dynamic> _$SnFortuneSayingToJson(_SnFortuneSaying instance) =>
    <String, dynamic>{
      'content': instance.content,
      'source': instance.source,
      'language': instance.language,
    };
