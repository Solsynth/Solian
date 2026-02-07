class SnAuthChallenge {
  final String id;
  final DateTime? expiredAt;
  final int stepRemain;
  final int stepTotal;
  final int failedAttempts;
  final List<String> blacklistFactors;
  final List<dynamic> audiences;
  final List<dynamic> scopes;
  final String ipAddress;
  final String userAgent;
  final String? nonce;
  final String? countryCode;
  final String? country;
  final String? city;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SnAuthChallenge({
    required this.id,
    this.expiredAt,
    required this.stepRemain,
    required this.stepTotal,
    required this.failedAttempts,
    required this.blacklistFactors,
    required this.audiences,
    required this.scopes,
    required this.ipAddress,
    required this.userAgent,
    this.nonce,
    this.countryCode,
    this.country,
    this.city,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SnAuthChallenge.fromJson(Map<String, dynamic> json) {
    return SnAuthChallenge(
      id: json['id'] as String,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'] as String)
          : null,
      stepRemain: json['stepRemain'] as int,
      stepTotal: json['stepTotal'] as int,
      failedAttempts: json['failedAttempts'] as int,
      blacklistFactors: (json['blacklistFactors'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      nonce: json['nonce'] as String?,
      countryCode: json['countryCode'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }
}

class SnAuthFactor {
  final String id;
  final int type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? expiredAt;
  final DateTime? enabledAt;
  final int trustworthy;
  final Map<String, dynamic>? createdResponse;

  SnAuthFactor({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.expiredAt,
    this.enabledAt,
    required this.trustworthy,
    this.createdResponse,
  });

  factory SnAuthFactor.fromJson(Map<String, dynamic> json) {
    return SnAuthFactor(
      id: json['id'] as String,
      type: json['type'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'] as String)
          : null,
      enabledAt: json['enabledAt'] != null
          ? DateTime.parse(json['enabledAt'] as String)
          : null,
      trustworthy: json['trustworthy'] as int,
      createdResponse: json['createdResponse'] as Map<String, dynamic>?,
    );
  }
}

class SnAccountConnection {
  final String id;
  final String accountId;
  final String provider;
  final String providedIdentifier;
  final Map<String, dynamic> meta;
  final DateTime lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SnAccountConnection({
    required this.id,
    required this.accountId,
    required this.provider,
    required this.providedIdentifier,
    this.meta = const {},
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SnAccountConnection.fromJson(Map<String, dynamic> json) {
    return SnAccountConnection(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      provider: json['provider'] as String,
      providedIdentifier: json['providedIdentifier'] as String,
      meta: Map<String, dynamic>.from(json['meta'] as Map? ?? {}),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }
}
