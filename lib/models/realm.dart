import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/user.dart';

part 'realm.freezed.dart';
part 'realm.g.dart';

@freezed
sealed class SnRealm with _$SnRealm {
  const factory SnRealm({
    required String id,
    required String slug,
    @Default('') String name,
    @Default('') String description,
    required String? verifiedAs,
    required DateTime? verifiedAt,
    required bool isCommunity,
    required bool isPublic,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnRealm;

  factory SnRealm.fromJson(Map<String, dynamic> json) =>
      _$SnRealmFromJson(json);
}

@freezed
sealed class SnRealmMember with _$SnRealmMember {
  const factory SnRealmMember({
    required String realmId,
    required SnRealm? realm,
    required String accountId,
    required SnAccount? account,
    required int role,
    required DateTime? joinedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnRealmMember;

  factory SnRealmMember.fromJson(Map<String, dynamic> json) =>
      _$SnRealmMemberFromJson(json);
}
