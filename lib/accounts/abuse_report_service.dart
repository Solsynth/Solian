import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService(ref);
});

class TicketService {
  final Ref ref;
  TicketService(this.ref);

  Future<SnTicket> createTicket({
    required String title,
    String? content,
    required int type,
    int priority = 1,
    List<String>? fileIds,
    List<String?>? resources,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return await client.tickets.createTicket(
      title: title,
      content: content,
      type: type,
      priority: priority,
      fileIds: fileIds,
      resources: resources,
    );
  }
}
