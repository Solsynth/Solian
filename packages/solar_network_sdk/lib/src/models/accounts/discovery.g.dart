// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnDiscoveryProfile _$SnDiscoveryProfileFromJson(Map<String, dynamic> json) =>
    _SnDiscoveryProfile(
      generatedAt: DateTime.parse(json['generated_at'] as String),
      interests: (json['interests'] as List<dynamic>)
          .map((e) => SnDiscoveryInterest.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedPublishers: (json['suggested_publishers'] as List<dynamic>)
          .map((e) => SnSuggestedData.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedAccounts: (json['suggested_accounts'] as List<dynamic>)
          .map((e) => SnSuggestedData.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedRealms: (json['suggested_realms'] as List<dynamic>)
          .map((e) => SnSuggestedData.fromJson(e as Map<String, dynamic>))
          .toList(),
      suppressed: json['suppressed'] as List<dynamic>,
    );

Map<String, dynamic> _$SnDiscoveryProfileToJson(
  _SnDiscoveryProfile instance,
) => <String, dynamic>{
  'generated_at': instance.generatedAt.toIso8601String(),
  'interests': instance.interests.map((e) => e.toJson()).toList(),
  'suggested_publishers': instance.suggestedPublishers
      .map((e) => e.toJson())
      .toList(),
  'suggested_accounts': instance.suggestedAccounts
      .map((e) => e.toJson())
      .toList(),
  'suggested_realms': instance.suggestedRealms.map((e) => e.toJson()).toList(),
  'suppressed': instance.suppressed,
};

_SnDiscoveryInterest _$SnDiscoveryInterestFromJson(Map<String, dynamic> json) =>
    _SnDiscoveryInterest(
      kind: json['kind'] as String,
      referenceId: json['reference_id'] as String,
      label: json['label'] as String,
      score: (json['score'] as num).toDouble(),
      interactionCount: (json['interaction_count'] as num).toInt(),
      lastInteractedAt: DateTime.parse(json['last_interacted_at'] as String),
      lastSignalType: json['last_signal_type'] as String,
    );

Map<String, dynamic> _$SnDiscoveryInterestToJson(
  _SnDiscoveryInterest instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'reference_id': instance.referenceId,
  'label': instance.label,
  'score': instance.score,
  'interaction_count': instance.interactionCount,
  'last_interacted_at': instance.lastInteractedAt.toIso8601String(),
  'last_signal_type': instance.lastSignalType,
};

_SnSuggestedData _$SnSuggestedDataFromJson(Map<String, dynamic> json) =>
    _SnSuggestedData(
      kind: (json['kind'] as num).toInt(),
      referenceId: json['reference_id'] as String,
      label: json['label'] as String,
      score: (json['score'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      data: json['data'],
    );

Map<String, dynamic> _$SnSuggestedDataToJson(_SnSuggestedData instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'reference_id': instance.referenceId,
      'label': instance.label,
      'score': instance.score,
      'reasons': instance.reasons,
      'data': instance.data,
    };
