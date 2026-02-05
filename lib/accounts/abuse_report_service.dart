import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/abuse_report.dart';
import 'package:island/core/network.dart';

final abuseReportServiceProvider = Provider<AbuseReportService>((ref) {
  return AbuseReportService(ref);
});

class AbuseReportService {
  final Ref ref;
  AbuseReportService(this.ref);

  Future<SnAbuseReport> getReport(String id) async {
    final response = await ref
        .read(apiClientProvider)
        .get('/pass/safety/reports/me/$id');
    return SnAbuseReport.fromJson(response.data);
  }

  Future<List<SnAbuseReport>> getReports() async {
    final response = await ref
        .read(apiClientProvider)
        .get('/pass/safety/reports/me');
    return (response.data as List)
        .map((json) => SnAbuseReport.fromJson(json))
        .toList();
  }
}
