enum AbuseReportType {
  copyright(0),
  harassment(1),
  impersonation(2),
  offensiveContent(3),
  spam(4),
  privacyViolation(5),
  illegalContent(6),
  other(7);

  const AbuseReportType(this.value);
  final int value;

  static AbuseReportType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  String get displayName {
    switch (this) {
      case AbuseReportType.copyright:
        return 'Copyright';
      case AbuseReportType.harassment:
        return 'Harassment';
      case AbuseReportType.impersonation:
        return 'Impersonation';
      case AbuseReportType.offensiveContent:
        return 'Offensive Content';
      case AbuseReportType.spam:
        return 'Spam';
      case AbuseReportType.privacyViolation:
        return 'Privacy Violation';
      case AbuseReportType.illegalContent:
        return 'Illegal Content';
      case AbuseReportType.other:
        return 'Other';
    }
  }
}
