import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';

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
    required SnCloudFileReference? picture,
    required SnCloudFileReference? background,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    @Default(0) int boostPoints,
    @Default(0) int boostLevel,
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
    required SnAccountStatus? status,
    required String? nick,
    required String? bio,
    required String? labelId,
    required SnRealmLabel? label,
    required int experience,
    required int level,
    required double levelingProgress,
  }) = _SnRealmMember;

  factory SnRealmMember.fromJson(Map<String, dynamic> json) =>
      _$SnRealmMemberFromJson(json);
}

@freezed
sealed class SnRealmLabel with _$SnRealmLabel {
  const factory SnRealmLabel({
    required String id,
    required String realmId,
    @Default("") String name,
    @Default("") String description,
    required String? color,
    required String? icon,
    required String createdByAccountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
  }) = _SnRealmLabel;

  factory SnRealmLabel.fromJson(Map<String, dynamic> json) =>
      _$SnRealmLabelFromJson(json);
}

/// Role-level permission for a realm.
/// Governs what a given role can do inside the realm.
@freezed
sealed class SnRealmRolePermission with _$SnRealmRolePermission {
  const factory SnRealmRolePermission({
    required int roleLevel,
    @Default(true) bool canChat,
    @Default(true) bool canPost,
    @Default(true) bool canComment,
    @Default(true) bool canUploadMedia,
    @Default(false) bool canModeratePosts,
    @Default(false) bool canModerateChat,
    @Default(false) bool canManageMembers,
    @Default(false) bool canManageRealm,
  }) = _SnRealmRolePermission;

  factory SnRealmRolePermission.fromJson(Map<String, dynamic> json) =>
      _$SnRealmRolePermissionFromJson(json);
}

/// User-specific permission override for a realm.
/// Non-null fields override the role-based permission.
@freezed
sealed class SnRealmUserPermission with _$SnRealmUserPermission {
  const factory SnRealmUserPermission({
    required String accountId,
    bool? canChat,
    bool? canPost,
    bool? canComment,
    bool? canUploadMedia,
    bool? canModeratePosts,
    bool? canModerateChat,
    bool? canManageMembers,
    bool? canManageRealm,
  }) = _SnRealmUserPermission;

  factory SnRealmUserPermission.fromJson(Map<String, dynamic> json) =>
      _$SnRealmUserPermissionFromJson(json);
}
