import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliation.freezed.dart';
part 'affiliation.g.dart';

@freezed
sealed class SnAffiliationSpell with _$SnAffiliationSpell {
  const factory SnAffiliationSpell({
    required String id,
    required String spell,
    @Default(0) int type,
    DateTime? expiresAt,
    DateTime? affectedAt,
    @Default({}) Map<String, dynamic> meta,
    String? accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAffiliationSpell;

  factory SnAffiliationSpell.fromJson(Map<String, dynamic> json) =>
      _$SnAffiliationSpellFromJson(json);
}

@freezed
sealed class SnAffiliationResult with _$SnAffiliationResult {
  const factory SnAffiliationResult({
    required String id,
    required String resourceIdentifier,
    required String spellId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAffiliationResult;

  factory SnAffiliationResult.fromJson(Map<String, dynamic> json) =>
      _$SnAffiliationResultFromJson(json);
}
