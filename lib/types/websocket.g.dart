// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WebSocketPackage _$WebSocketPackageFromJson(Map<String, dynamic> json) =>
    _WebSocketPackage(
      method: json['w'] as String? ?? 'unknown',
      endpoint: json['e'] as String?,
      message: json['m'] as String?,
      payload: json['p'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$WebSocketPackageToJson(_WebSocketPackage instance) =>
    <String, dynamic>{
      'w': instance.method,
      'e': instance.endpoint,
      'm': instance.message,
      'p': instance.payload,
    };
