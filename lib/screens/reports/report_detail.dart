import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/abuse_report.dart';
import 'package:island/services/abuse_report_service.dart';

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
    _reportFuture =
        ref.read(abuseReportServiceProvider).getReport(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abuse Report Details'),
      ),
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
                  Text('Report ID: ${report.id}'),
                  Text('Resource Identifier: ${report.resourceIdentifier}'),
                  Text('Type: ${report.type}'),
                  Text('Reason: ${report.reason}'),
                  Text('Resolved At: ${report.resolvedAt}'),
                  Text('Resolution: ${report.resolution}'),
                  Text('Account ID: ${report.accountId}'),
                  Text('Created At: ${report.createdAt}'),
                  Text('Updated At: ${report.updatedAt}'),
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
}