import 'package:solar_network_sdk/solar_network_sdk.dart';

/// API for ticket/support endpoints (/ticket).
///
/// Handles support tickets, feedback, and customer service.
class TicketsApi extends BaseApi {
  TicketsApi(super.dio);

  /// Base path for all ticket endpoints.
  static const String _basePath = '/passport';

  // ==========================================
  // Ticket endpoints
  // ==========================================

  /// Gets all tickets.
  ///
  /// [status] - Optional status filter.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnTicket>> getTickets({
    int? status,
    int offset = 0,
    int take = 20,
    bool mime = false,
  }) async {
    final response = await get<List<dynamic>>(
      mime ? '$_basePath/tickets/me' : '$_basePath/tickets',
      queryParameters: {'status': ?status, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(
      items: (response.data ?? [])
          .map((json) => SnTicket.fromJson(json))
          .toList(),
      totalCount: totalCount,
    );
  }

  /// Gets a specific ticket by ID.
  ///
  /// [ticketId] - The ticket ID.
  Future<SnTicket> getTicket(String ticketId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId',
    );
    return SnTicket.fromJson(response.data!);
  }

  /// Creates a new ticket.
  ///
  /// [title] - The ticket title.
  /// [content] - The ticket content / description.
  /// [type] - The ticket type identifier.
  /// [priority] - Optional priority (0 = low, 1 = medium, 2 = high).
  /// [fileIds] - Optional list of attached file IDs.
  Future<SnTicket> createTicket({
    required String title,
    String? content,
    required int type,
    int? priority,
    List<String>? fileIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets',
      data: {
        'title': title,
        'content': content,
        'type': type,
        'priority': ?priority,
        'file_ids': ?fileIds,
      },
    );
    return SnTicket.fromJson(response.data!);
  }

  /// Updates a ticket.
  ///
  /// [ticketId] - The ticket ID.
  /// [title] - Optional new ticket title.
  /// [content] - Optional new ticket content / description.
  /// [type] - Optional new ticket type identifier.
  /// [priority] - Optional new priority.
  Future<SnTicket> updateTicket({
    required String ticketId,
    String? title,
    String? content,
    int? type,
    int? priority,
  }) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId',
      data: {
        'title': ?title,
        'content': ?content,
        'type': ?type,
        'priority': ?priority,
      },
    );
    return SnTicket.fromJson(response.data!);
  }

  /// Closes a ticket.
  ///
  /// [ticketId] - The ticket ID.
  Future<void> closeTicket(String ticketId) async {
    await post('$_basePath/tickets/$ticketId/close');
  }

  /// Reopens a ticket.
  ///
  /// [ticketId] - The ticket ID.
  Future<void> reopenTicket(String ticketId) async {
    await post('$_basePath/tickets/$ticketId/reopen');
  }

  /// Deletes a ticket.
  ///
  /// [ticketId] - The ticket ID.
  Future<void> deleteTicket(String ticketId) async {
    await delete('$_basePath/tickets/$ticketId');
  }

  // ==========================================
  // Message endpoints
  // ==========================================

  /// Gets messages for a ticket.
  ///
  /// [ticketId] - The ticket ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getTicketMessages({
    required String ticketId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/tickets/$ticketId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Adds a message to a ticket.
  ///
  /// [ticketId] - The ticket ID.
  /// [content] - The message content.
  /// [fileIds] - Optional list of attached file IDs.
  Future<SnTicketMessage> addTicketMessage({
    required String ticketId,
    required String content,
    List<String>? fileIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId/messages',
      data: {'content': content, 'file_ids': ?fileIds},
    );
    return SnTicketMessage.fromJson(response.data!);
  }

  /// Updates a ticket message.
  ///
  /// [ticketId] - The ticket ID.
  /// [messageId] - The message ID.
  /// [message] - The new message content.
  Future<Map<String, dynamic>> updateTicketMessage({
    required String ticketId,
    required String messageId,
    required String message,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId/messages/$messageId',
      data: {'message': message},
    );
    return response.data!;
  }

  /// Deletes a ticket message.
  ///
  /// [ticketId] - The ticket ID.
  /// [messageId] - The message ID.
  Future<void> deleteTicketMessage({
    required String ticketId,
    required String messageId,
  }) async {
    await delete('$_basePath/tickets/$ticketId/messages/$messageId');
  }

  /// Updates ticket status.
  ///
  /// [ticketId] - The ticket ID.
  /// [status] - New status value.
  Future<SnTicket> updateTicketStatus({
    required String ticketId,
    required int status,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId/status',
      data: {'status': status},
    );
    return SnTicket.fromJson(response.data!);
  }

  /// Assigns ticket to an assignee.
  ///
  /// [ticketId] - The ticket ID.
  /// [assigneeId] - User ID to assign to, null to unassign.
  Future<SnTicket> assignTicket({
    required String ticketId,
    String? assigneeId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId/assign',
      data: {'assignee_id': assigneeId},
    );
    return SnTicket.fromJson(response.data!);
  }

  /// Gets total ticket count with optional status filter.
  ///
  /// [status] - Optional status filter.
  Future<int> getTicketCount({int? status}) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/tickets/count',
      queryParameters: {'status': ?status},
    );
    return response.data!['count'] as int;
  }
}
