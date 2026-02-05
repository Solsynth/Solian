// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WebSocketPacket _$WebSocketPacketFromJson(Map<String, dynamic> json) =>
    _WebSocketPacket(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
      endpoint: json['endpoint'] as String?,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$WebSocketPacketToJson(_WebSocketPacket instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
      'endpoint': instance.endpoint,
      'error_message': instance.errorMessage,
    };
