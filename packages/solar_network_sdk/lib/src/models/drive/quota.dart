/// Purchase configuration for extra quota packs, from
/// `GET /drive/billing/quota/purchase`.
class SnQuotaPurchaseConfig {
  /// Price per gigabyte, in [currency] (e.g. 0.05).
  final double pricePerGb;

  /// Currency of [pricePerGb], e.g. "golds".
  final String currency;

  /// Minimum purchasable quantity in GB.
  final int minGb;

  /// Total cap in GB — the user cannot hold more extra quota than this.
  final int maxGb;

  const SnQuotaPurchaseConfig({
    required this.pricePerGb,
    required this.currency,
    required this.minGb,
    required this.maxGb,
  });

  factory SnQuotaPurchaseConfig.fromJson(Map<String, dynamic> json) {
    return SnQuotaPurchaseConfig(
      pricePerGb: _toDouble(json['price_per_gb']) ?? 0,
      currency: json['currency'] as String? ?? '',
      minGb: (json['min_gb'] as num?)?.toInt() ?? 1,
      maxGb: (json['max_gb'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Response of the quota purchase order creation endpoint
/// (`POST /drive/billing/quota/purchase`).
class SnQuotaOrder {
  /// Wallet order id; pay it via `POST /wallet/orders/{orderId}/pay`.
  final String orderId;

  /// Order amount as formatted by the server, e.g. "0.5".
  final String amount;

  /// Currency of [amount], e.g. "golds".
  final String currency;

  /// Purchased quantity in GB.
  final int quantityGb;

  /// Storage granted by this order, in megabytes.
  final int quotaMb;

  const SnQuotaOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.quantityGb,
    required this.quotaMb,
  });

  factory SnQuotaOrder.fromJson(Map<String, dynamic> json) {
    return SnQuotaOrder(
      orderId: json['order_id'] as String? ?? '',
      amount: _stringify(json['amount']),
      currency: json['currency'] as String? ?? '',
      quantityGb: (json['quantity_gb'] as num?)?.toInt() ?? 0,
      quotaMb: (json['quota_mb'] as num?)?.toInt() ?? 0,
    );
  }
}

String _stringify(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
