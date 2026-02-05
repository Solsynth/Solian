import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/abuse_report.dart';
import 'package:island/accounts/accounts_models/abuse_report_type.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

class AbuseReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;

  const AbuseReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<AbuseReportDetailScreen> createState() =>
      _AbuseReportDetailScreenState();
}

class _AbuseReportDetailScreenState
    extends ConsumerState<AbuseReportDetailScreen> {
  Future<SnAbuseReport>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = ref
        .read(abuseReportServiceProvider)
        .getReport(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Abuse Report Details')),
      body: FutureBuilder<SnAbuseReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final report = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'Report ID', report.id),
                  _buildDetailRow(
                    context,
                    'Resource Identifier',
                    report.resourceIdentifier,
                  ),
                  _buildDetailRow(
                    context,
                    'Type',
                    AbuseReportType.fromValue(report.type).displayName,
                  ),
                  _buildDetailRow(context, 'Reason', report.reason),
                  _buildDetailRow(
                    context,
                    'Resolved At',
                    report.resolvedAt?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    'Resolution',
                    report.resolution ?? 'N/A',
                  ),
                  _buildDetailRow(context, 'Account ID', report.accountId),
                  _buildDetailRow(
                    context,
                    'Created At',
                    report.createdAt.toString(),
                  ),
                  _buildDetailRow(
                    context,
                    'Updated At',
                    report.updatedAt.toString(),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium).bold(),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
