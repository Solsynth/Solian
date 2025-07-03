import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/abuse_report.dart';
import 'package:island/services/abuse_report_service.dart';

class AbuseReportListScreen extends ConsumerStatefulWidget {
  const AbuseReportListScreen({super.key});

  @override
  ConsumerState<AbuseReportListScreen> createState() =>
      _AbuseReportListScreenState();
}

class _AbuseReportListScreenState extends ConsumerState<AbuseReportListScreen> {
  Future<List<SnAbuseReport>>? _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ref.read(abuseReportServiceProvider).getReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Abuse Reports'),
      ),
      body: FutureBuilder<List<SnAbuseReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text(report.reason),
                  subtitle: Text(report.id),
                  onTap: () {
                    context.push('/safety/reports/me/${report.id}');
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
