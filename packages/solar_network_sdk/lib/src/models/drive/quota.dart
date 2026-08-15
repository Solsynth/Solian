/// A purchasable extra-quota pack advertised by the drive billing API
/// (`GET /drive/billing/quota/products`).
class SnQuotaProduct {
  /// Stable identifier sent back when creating an order, e.g. `dysonfs.quota.10gb`.
  final String productIdentifier;

  /// Human-readable pack name, e.g. "10 GB Extra Quota".
  final String displayName;

  final String? description;

  /// Storage granted by the pack, in megabytes.
  final int quotaMb;

  /// Price as formatted by the server, e.g. "120".
  final String price;

  /// Currency of [price], e.g. "golds".
  final String currency;

  /// Validity duration string, e.g. `720h`. Null when the pack is permanent.
  final String? expiresIn;

  const SnQuotaProduct({
    required this.productIdentifier,
    required this.displayName,
    required this.description,
    required this.quotaMb,
    required this.price,
    required this.currency,
    required this.expiresIn,
  });

  factory SnQuotaProduct.fromJson(Map<String, dynamic> json) {
    return SnQuotaProduct(
      productIdentifier: json['product_identifier'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      description: json['description'] as String?,
      quotaMb: (json['quota_mb'] as num?)?.toInt() ?? 0,
      price: _stringify(json['price']),
      currency: json['currency'] as String? ?? '',
      expiresIn: json['expires_in'] as String?,
    );
  }
}

/// Response of the quota purchase order creation endpoint
/// (`POST /drive/billing/quota/purchase`).
class SnQuotaOrder {
  /// Wallet order id; pay it via `POST /wallet/orders/{orderId}/pay`.
  final String orderId;

  /// Order amount as formatted by the server, e.g. "120".
  final String amount;

  /// Currency of [amount], e.g. "golds".
  final String currency;

  const SnQuotaOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  factory SnQuotaOrder.fromJson(Map<String, dynamic> json) {
    return SnQuotaOrder(
      orderId: json['order_id'] as String? ?? '',
      amount: _stringify(json['amount']),
      currency: json['currency'] as String? ?? '',
    );
  }
}

String _stringify(dynamic value) {
  if (value == null) return '';
  if (value is num) return value.toString();
  return value.toString();
}
