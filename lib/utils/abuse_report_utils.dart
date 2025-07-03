String getAbuseReportTypeString(int type) {
  switch (type) {
    case 0:
      return 'Copyright';
    case 1:
      return 'Harassment';
    case 2:
      return 'Impersonation';
    case 3:
      return 'Offensive Content';
    case 4:
      return 'Spam';
    case 5:
      return 'Privacy Violation';
    case 6:
      return 'Illegal Content';
    case 7:
      return 'Other';
    default:
      return 'Unknown';
  }
}
