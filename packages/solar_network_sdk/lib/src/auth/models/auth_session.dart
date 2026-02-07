class SnAuthSession {
  final String id;
  final String? label;
  final DateTime lastGrantedAt;
  final DateTime? expiredAt;
  final List<dynamic> audiences;
  final List<dynamic> scopes;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final int type;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SnAuthSession({
    required this.id,
    this.label,
    required this.lastGrantedAt,
    this.expiredAt,
    required this.audiences,
    required this.scopes,
    this.ipAddress,
    this.userAgent,
    this.location,
    required this.type,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SnAuthSession.fromJson(Map<String, dynamic> json) {
    return SnAuthSession(
      id: json['id'] as String,
      label: json['label'] as String?,
      lastGrantedAt: DateTime.parse(json['lastGrantedAt'] as String),
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'] as String)
          : null,
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location']?.toString(),
      type: json['type'] as int,
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'lastGrantedAt': lastGrantedAt.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
      'audiences': audiences,
      'scopes': scopes,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'location': location,
      'type': type,
      'accountId': accountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
