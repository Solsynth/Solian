// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_change_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnNameChangeCardOrder _$SnNameChangeCardOrderFromJson(
  Map<String, dynamic> json,
) => _SnNameChangeCardOrder(
  purchaseId: json['purchase_id'] as String,
  orderId: json['order_id'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$SnNameChangeCardOrderToJson(
  _SnNameChangeCardOrder instance,
) => <String, dynamic>{
  'purchase_id': instance.purchaseId,
  'order_id': instance.orderId,
  'amount': instance.amount,
};

_SnNameChangeCardPurchase _$SnNameChangeCardPurchaseFromJson(
  Map<String, dynamic> json,
) => _SnNameChangeCardPurchase(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  orderId: json['order_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  fulfilledAt: json['fulfilled_at'] == null
      ? null
      : DateTime.parse(json['fulfilled_at'] as String),
  consumedAt: json['consumed_at'] == null
      ? null
      : DateTime.parse(json['consumed_at'] as String),
  targetType: const SnNameChangeCardTargetTypeConverter().fromJson(
    json['target_type'],
  ),
  targetId: json['target_id'] as String?,
  oldName: json['old_name'] as String?,
  newName: json['new_name'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SnNameChangeCardPurchaseToJson(
  _SnNameChangeCardPurchase instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'order_id': instance.orderId,
  'amount': instance.amount,
  'fulfilled_at': instance.fulfilledAt?.toIso8601String(),
  'consumed_at': instance.consumedAt?.toIso8601String(),
  'target_type': const SnNameChangeCardTargetTypeConverter().toJson(
    instance.targetType,
  ),
  'target_id': instance.targetId,
  'old_name': instance.oldName,
  'new_name': instance.newName,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
