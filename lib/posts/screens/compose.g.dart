// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostComposeInitialState _$PostComposeInitialStateFromJson(
  Map<String, dynamic> json,
) => _PostComposeInitialState(
  title: json['title'] as String?,
  description: json['description'] as String?,
  content: json['content'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => UniversalFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  visibility: (json['visibility'] as num?)?.toInt(),
  replyingTo: json['replying_to'] == null
      ? null
      : SnPost.fromJson(json['replying_to'] as Map<String, dynamic>),
  forwardingTo: json['forwarding_to'] == null
      ? null
      : SnPost.fromJson(json['forwarding_to'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostComposeInitialStateToJson(
  _PostComposeInitialState instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'content': instance.content,
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'visibility': instance.visibility,
  'replying_to': instance.replyingTo?.toJson(),
  'forwarding_to': instance.forwardingTo?.toJson(),
};
