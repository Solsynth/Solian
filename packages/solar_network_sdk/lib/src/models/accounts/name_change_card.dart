import 'package:freezed_annotation/freezed_annotation.dart';

part 'name_change_card.freezed.dart';
part 'name_change_card.g.dart';

/// The entity a name change card can be spent on.
///
/// Mirrors the server-side `target_type` values accepted by
/// `POST /accounts/me/name-change-card/use` and reported on purchase rows.
enum SnNameChangeCardTargetType {
  /// The account's own name (`[A-Za-z0-9_-]`, 2-256 chars).
  account('account'),

  /// A realm owned by the account; `target_id` is the realm slug.
  realm('realm'),

  /// A publisher managed by the account (manager+); `target_id` is the
  /// publisher id. Name max 256 chars.
  publisher('publisher');

  const SnNameChangeCardTargetType(this.wire);

  /// The wire value used in request/response JSON.
  final String wire;

  /// Parses a server-side value (or null) into a target type.
  ///
  /// Returns null for unknown values, so unspent purchase rows (whose
  /// `target_type` is null) and future target kinds degrade gracefully.
  static SnNameChangeCardTargetType? fromWire(Object? value) {
    if (value is! String) return null;
    for (final type in values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}

class SnNameChangeCardTargetTypeConverter
    implements JsonConverter<SnNameChangeCardTargetType?, Object?> {
  const SnNameChangeCardTargetTypeConverter();

  @override
  SnNameChangeCardTargetType? fromJson(Object? json) =>
      SnNameChangeCardTargetType.fromWire(json);

  @override
  Object? toJson(SnNameChangeCardTargetType? object) => object?.wire;
}

/// Result of `POST /accounts/me/name-change-card/order`.
///
/// The returned [orderId] must be paid through the Wallet API
/// (`POST /wallet/orders/{orderId}/pay`); the card becomes usable only after
/// the payment event fulfills it. Purchase does not grant the card instantly.
@freezed
sealed class SnNameChangeCardOrder with _$SnNameChangeCardOrder {
  const SnNameChangeCardOrder._();

  const factory SnNameChangeCardOrder({
    required String purchaseId,
    required String orderId,
    required double amount,
  }) = _SnNameChangeCardOrder;

  factory SnNameChangeCardOrder.fromJson(Map<String, dynamic> json) =>
      _$SnNameChangeCardOrderFromJson(json);
}

/// A name change card purchase row from
/// `GET /accounts/me/name-change-card`, and the response of
/// `POST /accounts/me/name-change-card/use`.
///
/// [fulfilledAt] set = paid & usable; [consumedAt] set = spent. A failed use
/// never consumes the card — only a successful rename sets [consumedAt].
@freezed
sealed class SnNameChangeCardPurchase with _$SnNameChangeCardPurchase {
  const SnNameChangeCardPurchase._();

  const factory SnNameChangeCardPurchase({
    required String id,
    required String accountId,
    required String orderId,
    required double amount,
    DateTime? fulfilledAt,
    DateTime? consumedAt,
    @SnNameChangeCardTargetTypeConverter()
    SnNameChangeCardTargetType? targetType,
    String? targetId,
    String? oldName,
    String? newName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnNameChangeCardPurchase;

  factory SnNameChangeCardPurchase.fromJson(Map<String, dynamic> json) =>
      _$SnNameChangeCardPurchaseFromJson(json);

  /// Whether the card has been paid for and is usable.
  bool get isFulfilled => fulfilledAt != null;

  /// Whether the card has been spent on a rename.
  bool get isConsumed => consumedAt != null;
}
