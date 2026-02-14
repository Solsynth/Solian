import 'package:flutter/material.dart';
import 'package:island/reports/reports_widgets/safety/abuse_report_sheet.dart';

/// Helper function to show the ticket create sheet
///
/// [context] - The build context
/// [resourceIdentifier] - Optional identifier of the related resource
/// [initialTitle] - Optional initial title to pre-fill the form
Future<void> showAbuseReportSheet(
  BuildContext context, {
  String? resourceIdentifier,
  String? initialTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => TicketCreateSheet(
      resourceIdentifier: resourceIdentifier,
      initialTitle: initialTitle,
    ),
  );
}
