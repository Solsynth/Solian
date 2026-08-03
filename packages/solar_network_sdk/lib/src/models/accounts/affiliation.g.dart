// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'affiliation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAffiliationSpell _$SnAffiliationSpellFromJson(Map<String, dynamic> json) =>
    _SnAffiliationSpell(
      id: json['id'] as String,
      spell: json['spell'] as String,
      type: json['type'] == null
          ? SnAffiliationSpellType.registrationInvite
          : const SnAffiliationSpellTypeConverter().fromJson(json['type']),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      affectedAt: json['affected_at'] == null
          ? null
          : DateTime.parse(json['affected_at'] as String),
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      accountId: json['account_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAffiliationSpellToJson(_SnAffiliationSpell instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spell': instance.spell,
      'type': const SnAffiliationSpellTypeConverter().toJson(instance.type),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'affected_at': instance.affectedAt?.toIso8601String(),
      'meta': instance.meta,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAffiliationResult _$SnAffiliationResultFromJson(Map<String, dynamic> json) =>
    _SnAffiliationResult(
      id: json['id'] as String,
      resourceIdentifier: json['resource_identifier'] as String,
      spellId: json['spell_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAffiliationResultToJson(
  _SnAffiliationResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'resource_identifier': instance.resourceIdentifier,
  'spell_id': instance.spellId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnAffiliationPurchase _$SnAffiliationPurchaseFromJson(
  Map<String, dynamic> json,
) => _SnAffiliationPurchase(
  purchaseId: json['purchase_id'] as String,
  orderId: json['order_id'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$SnAffiliationPurchaseToJson(
  _SnAffiliationPurchase instance,
) => <String, dynamic>{
  'purchase_id': instance.purchaseId,
  'order_id': instance.orderId,
  'amount': instance.amount,
};
