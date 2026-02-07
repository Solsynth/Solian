class AppToken {
  final String token;
  final DateTime? expiresAt;

  AppToken({required this.token, this.expiresAt});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  factory AppToken.fromJson(Map<String, dynamic> json) {
    return AppToken(
      token: json['token'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}
