import 'package:flutter/material.dart';
import 'package:island/reports/reports_widgets/safety/abuse_report_sheet.dart';

/// Helper function to show the safety report sheet
///
/// [context] - The build context
/// [resourceIdentifier] - The identifier of the resource being reported (e.g., post ID, user ID, etc.)
/// [initialReason] - Optional initial reason text to pre-fill the form
Future<void> showAbuseReportSheet(
  BuildContext context, {
  required String resourceIdentifier,
  String? initialReason,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => AbuseReportSheet(
      resourceIdentifier: resourceIdentifier,
      initialReason: initialReason,
    ),
  );
}
