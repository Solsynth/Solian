import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService(ref);
});

class TicketService {
  final Ref ref;
  TicketService(this.ref);

  Future<SnTicket> getTicket(String id) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.tickets.getTicket(id);
  }

  Future<List<SnTicket>> getTickets({
    int? status,
    int offset = 0,
    int take = 20,
    bool isAdmin = false,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    final tickets = await client.tickets.getTickets(
      offset: offset,
      take: take,
      status: status,
      mime: isAdmin,
    );
    return tickets.items;
  }

  Future<SnTicket> createTicket({
    required String title,
    String? content,
    required int type,
    int priority = 1,
    List<String>? fileIds,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.createTicket(
      title: title,
      content: content,
      type: type,
      priority: priority,
      fileIds: fileIds,
    );
  }

  Future<SnTicket> updateTicket(
    String id, {
    String? title,
    String? content,
    int? type,
    int? priority,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.updateTicket(
      ticketId: id,
      title: title,
      content: content,
      type: type,
      priority: priority,
    );
  }

  Future<void> deleteTicket(String id) async {
    final client = ref.watch(solarNetworkClientProvider);
    await client.tickets.deleteTicket(id);
  }

  Future<SnTicketMessage> addMessage(
    String ticketId,
    String content, {
    List<String>? fileIds,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.addTicketMessage(
      ticketId: ticketId,
      content: content,
      fileIds: fileIds,
    );
  }

  Future<SnTicket> updateTicketStatus(String ticketId, int status) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.updateTicketStatus(
      ticketId: ticketId,
      status: status,
    );
  }

  Future<SnTicket> assignTicket(String ticketId, String? assigneeId) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.assignTicket(
      ticketId: ticketId,
      assigneeId: assigneeId,
    );
  }

  Future<int> getTicketCount({int? status}) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.getTicketCount(
      status: status,
    );
  }
}
