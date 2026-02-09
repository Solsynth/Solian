// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_completion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutoCompletionAccountResponse _$AutoCompletionAccountResponseFromJson(
  Map<String, dynamic> json,
) => AutoCompletionAccountResponse(
  type: json['type'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => AutoCompletionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$AutoCompletionAccountResponseToJson(
  AutoCompletionAccountResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'runtimeType': instance.$type,
};

AutoCompletionStickerResponse _$AutoCompletionStickerResponseFromJson(
  Map<String, dynamic> json,
) => AutoCompletionStickerResponse(
  type: json['type'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => AutoCompletionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$AutoCompletionStickerResponseToJson(
  AutoCompletionStickerResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'runtimeType': instance.$type,
};

_AutoCompletionItem _$AutoCompletionItemFromJson(Map<String, dynamic> json) =>
    _AutoCompletionItem(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      secondaryText: json['secondary_text'] as String?,
      type: json['type'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$AutoCompletionItemToJson(_AutoCompletionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'secondary_text': instance.secondaryText,
      'type': instance.type,
      'data': instance.data,
    };
