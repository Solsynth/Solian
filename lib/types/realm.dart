import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:surface/types/account.dart';

part 'realm.freezed.dart';
part 'realm.g.dart';

@freezed
class SnRealmMember with _$SnRealmMember {
  const factory SnRealmMember({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int realmId,
    required int accountId,
    required SnRealm realm,
    required SnAccount account,
    required int powerLevel,
  }) = _SnRealmMember;

  factory SnRealmMember.fromJson(Map<String, dynamic> json) =>
      _$SnRealmMemberFromJson(json);
}

@freezed
class SnRealm with _$SnRealm {
  const SnRealm._();

  @HiveType(typeId: 1)
  const factory SnRealm({
    @HiveField(0) required int id,
    @HiveField(1) required DateTime createdAt,
    @HiveField(2) required DateTime updatedAt,
    @HiveField(3) required DateTime? deletedAt,
    @HiveField(4) required String alias,
    @HiveField(5) required String name,
    @HiveField(6) required String description,
    List<SnRealmMember>? members,
    @HiveField(7) required String? avatar,
    @HiveField(8) required String? banner,
    @HiveField(9) required Map<String, dynamic>? accessPolicy,
    @HiveField(10) required int accountId,
    @HiveField(11) required bool isPublic,
    @HiveField(12) required bool isCommunity,
    @Default(0) int popularity,
  }) = _SnRealm;

  factory SnRealm.fromJson(Map<String, dynamic> json) =>
      _$SnRealmFromJson(json);
}
