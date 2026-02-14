import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService(ref);
});

class TicketService {
  final Ref ref;
  TicketService(this.ref);

  Future<SnTicket> getTicket(String id) async {
    final response = await ref.read(apiClientProvider).get('/pass/tickets/$id');
    return SnTicket.fromJson(response.data);
  }

  Future<List<SnTicket>> getTickets({
    String? status,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await ref
        .read(apiClientProvider)
        .get(
          '/pass/tickets/me',
          queryParameters: {'status': ?status, 'offset': offset, 'take': take},
        );
    return (response.data as List)
        .map((json) => SnTicket.fromJson(json))
        .toList();
  }

  Future<SnTicket> createTicket({
    required String title,
    String? description,
    required int type,
    int priority = 1,
    List<String>? fileIds,
  }) async {
    final response = await ref
        .read(apiClientProvider)
        .post(
          '/pass/tickets',
          data: {
            'title': title,
            'description': description,
            'type': type,
            'priority': priority,
            'file_ids': fileIds,
          },
        );
    return SnTicket.fromJson(response.data);
  }

  Future<SnTicket> updateTicket(
    String id, {
    String? title,
    String? description,
    String? type,
    String? priority,
  }) async {
    final response = await ref
        .read(apiClientProvider)
        .put(
          '/pass/tickets/$id',
          data: {
            'title': ?title,
            'description': ?description,
            'type': ?type,
            'priority': ?priority,
          },
        );
    return SnTicket.fromJson(response.data);
  }

  Future<void> deleteTicket(String id) async {
    await ref.read(apiClientProvider).delete('/pass/tickets/$id');
  }

  Future<SnTicketMessage> addMessage(String ticketId, String content) async {
    final response = await ref
        .read(apiClientProvider)
        .post('/pass/tickets/$ticketId/messages', data: {'content': content});
    return SnTicketMessage.fromJson(response.data);
  }

  Future<SnTicket> updateTicketStatus(String ticketId, String status) async {
    final response = await ref
        .read(apiClientProvider)
        .post('/pass/tickets/$ticketId/status', data: {'status': status});
    return SnTicket.fromJson(response.data);
  }

  Future<SnTicket> assignTicket(String ticketId, String? assigneeId) async {
    final response = await ref
        .read(apiClientProvider)
        .post(
          '/pass/tickets/$ticketId/assign',
          data: {'assignee_id': assigneeId},
        );
    return SnTicket.fromJson(response.data);
  }

  Future<int> getTicketCount({String? status}) async {
    final response = await ref
        .read(apiClientProvider)
        .get('/pass/tickets/count', queryParameters: {'status': ?status});
    return response.data['count'] as int;
  }
}

// Provider for backward compatibility
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
