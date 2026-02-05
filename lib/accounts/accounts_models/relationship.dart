import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:island/accounts/accounts_models/account.dart';

part 'relationship.freezed.dart';
part 'relationship.g.dart';

@freezed
sealed class SnRelationship with _$SnRelationship {
  const factory SnRelationship({
    required DateTime? createdAt,
    required DateTime? updatedAt,
    required DateTime? deletedAt,
    required String accountId,
    // Usually the account was not included in the response
    required SnAccount? account,
    required String relatedId,
    required SnAccount? related,
    required DateTime? expiredAt,
    required int status,
  }) = _SnRelationship;

  factory SnRelationship.fromJson(Map<String, dynamic> json) =>
      _$SnRelationshipFromJson(json);
}
