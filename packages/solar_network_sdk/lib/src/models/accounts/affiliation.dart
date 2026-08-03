import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliation.freezed.dart';
part 'affiliation.g.dart';

/// The kind of an affiliation spell.
///
/// Mirrors `AffiliationSpellType` on the server. Registration invitations
/// follow a distinct lifecycle (purchase, then consume during signup) and are
/// never tracked as conversion results.
enum SnAffiliationSpellType {
  /// A single-use code purchased via `purchaseAffiliationSpell` and consumed
  /// by an unactivated account during registration.
  registrationInvite;

  /// Parses a server-side value: an integer enum value or, defensively, the
  /// enum name. Falls back to [registrationInvite] for unknown values.
  static SnAffiliationSpellType fromJson(Object? value) {
    if (value is num) {
      final index = value.toInt();
      if (index >= 0 && index < SnAffiliationSpellType.values.length) {
        return SnAffiliationSpellType.values[index];
      }
    }
    if (value is String) {
      for (final type in SnAffiliationSpellType.values) {
        if (type.name.toLowerCase() == value.toLowerCase()) return type;
      }
    }
    return SnAffiliationSpellType.registrationInvite;
  }
}

class SnAffiliationSpellTypeConverter
    implements JsonConverter<SnAffiliationSpellType, Object?> {
  const SnAffiliationSpellTypeConverter();

  @override
  SnAffiliationSpellType fromJson(Object? json) =>
      SnAffiliationSpellType.fromJson(json);

  @override
  Object? toJson(SnAffiliationSpellType object) => object.name;
}

@freezed
sealed class SnAffiliationSpell with _$SnAffiliationSpell {
  const SnAffiliationSpell._();

  const factory SnAffiliationSpell({
    required String id,
    required String spell,
    @SnAffiliationSpellTypeConverter()
    @Default(SnAffiliationSpellType.registrationInvite)
    SnAffiliationSpellType type,
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

  /// Maximum number of uses recorded in `meta.max_usages`; null = unlimited.
  int? get maxUsages {
    final value = meta['max_usages'];
    return value is num ? value.toInt() : null;
  }

  /// Whether using this spell bypasses onboarding tests
  /// (`meta.skip_tests`, defaults to true).
  bool get skipTests {
    final value = meta['skip_tests'];
    return value is bool ? value : true;
  }

  /// Whether this is a registration invite rather than a conversion-tracking
  /// spell. Invites are consumed during signup and never track results.
  bool get isRegistrationInvite =>
      type == SnAffiliationSpellType.registrationInvite;
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

/// Result of `POST /affiliations/purchase`.
@freezed
sealed class SnAffiliationPurchase with _$SnAffiliationPurchase {
  const factory SnAffiliationPurchase({
    required String purchaseId,
    required String orderId,
    required double amount,
  }) = _SnAffiliationPurchase;

  factory SnAffiliationPurchase.fromJson(Map<String, dynamic> json) =>
      _$SnAffiliationPurchaseFromJson(json);
}
