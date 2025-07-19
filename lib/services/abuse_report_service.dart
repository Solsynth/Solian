import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/abuse_report.dart';
import 'package:island/pods/network.dart';

final abuseReportServiceProvider = Provider<AbuseReportService>((ref) {
  return AbuseReportService(ref);
});

class AbuseReportService {
  final Ref ref;
  AbuseReportService(this.ref);

  Future<SnAbuseReport> getReport(String id) async {
    final response = await ref
        .read(apiClientProvider)
        .get('/id/safety/reports/me/$id');
    return SnAbuseReport.fromJson(response.data);
  }

  Future<List<SnAbuseReport>> getReports() async {
    final response = await ref
        .read(apiClientProvider)
        .get('/id/safety/reports/me');
    return (response.data as List)
        .map((json) => SnAbuseReport.fromJson(json))
        .toList();
  }
}
