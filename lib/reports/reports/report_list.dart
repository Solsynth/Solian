import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/abuse_report.dart';
import 'package:island/accounts/accounts_models/abuse_report_type.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/core/services/time.dart';
import 'package:island/reports/reports_widgets/safety/abuse_report_helper.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

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
    return AppScaffold(
      appBar: AppBar(title: Text('abuseReports').tr()),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showAbuseReportSheet(context, resourceIdentifier: 'unidentified');
        },
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
              padding: EdgeInsets.zero,
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        'reportDetail',
                        pathParameters: {'id': report.id},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.reason,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                report.id,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Type',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                AbuseReportType.fromValue(
                                  report.type,
                                ).displayName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created at',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${report.createdAt.formatRelative(context)} · ${report.createdAt.formatSystem()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                report.resolvedAt != null
                                    ? 'Resolved'
                                    : 'Unresolved',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: report.resolvedAt != null
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
