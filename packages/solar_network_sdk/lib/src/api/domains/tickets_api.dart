import 'package:dio/dio.dart';

import '../base_api.dart';

/// API for ticket/support endpoints (/ticket).
///
/// Handles support tickets, feedback, and customer service.
class TicketsApi extends BaseApi {
  TicketsApi(super.dio);

  /// Base path for all ticket endpoints.
  static const String _basePath = '/ticket';

  // ==========================================
  // Ticket endpoints
  // ==========================================

  /// Gets all tickets.
  ///
  /// [status] - Optional status filter.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getTickets({
    String? status,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/tickets',
      queryParameters: {
        if (status != null) 'status': status,
        'offset': offset,
        'take': take,
      },
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Gets a specific ticket by ID.
  ///
  /// [ticketId] - The ticket ID.
  Future<Map<String, dynamic>> getTicket(String ticketId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId',
    );
    return response.data!;
  }

  /// Creates a new ticket.
  ///
  /// [subject] - The ticket subject.
  /// [description] - The ticket description.
  /// [category] - The ticket category.
  /// [priority] - Optional priority (e.g., 'low', 'medium', 'high').
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String description,
    required String category,
    String? priority,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets',
      data: {
        'subject': subject,
        'description': description,
        'category': category,
        if (priority != null) 'priority': priority,
      },
    );
    return response.data!;
  }

  /// Updates a ticket.
  ///
  /// [ticketId] - The ticket ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateTicket({
    required String ticketId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId',
      data: data,
    );
    return response.data!;
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
  /// [message] - The message content.
  /// [attachments] - Optional attachments.
  Future<Map<String, dynamic>> addTicketMessage({
    required String ticketId,
    required String message,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/tickets/$ticketId/messages',
      data: {
        'message': message,
        if (attachments != null) 'attachments': attachments,
      },
    );
    return response.data!;
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

  // ==========================================
  // Category endpoints
  // ==========================================

  /// Gets all ticket categories.
  Future<List<dynamic>> getCategories() async {
    final response = await get<List<dynamic>>('$_basePath/categories');
    return response.data ?? [];
  }

  /// Gets a specific category by ID.
  ///
  /// [categoryId] - The category ID.
  Future<Map<String, dynamic>> getCategory(String categoryId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/categories/$categoryId',
    );
    return response.data!;
  }

  // ==========================================
  // FAQ endpoints
  // ==========================================

  /// Gets FAQ items.
  ///
  /// [category] - Optional category filter.
  Future<List<dynamic>> getFAQ({String? category}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/faq',
      queryParameters: category != null ? {'category': category} : null,
    );
    return response.data ?? [];
  }

  /// Searches FAQ items.
  ///
  /// [query] - The search query.
  Future<List<dynamic>> searchFAQ(String query) async {
    final response = await get<List<dynamic>>(
      '$_basePath/faq/search',
      queryParameters: {'q': query},
    );
    return response.data ?? [];
  }

  // ==========================================
  // Feedback endpoints
  // ==========================================

  /// Submits feedback.
  ///
  /// [type] - The feedback type (e.g., 'bug', 'feature', 'general').
  /// [content] - The feedback content.
  /// [rating] - Optional rating (1-5).
  Future<Map<String, dynamic>> submitFeedback({
    required String type,
    required String content,
    int? rating,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/feedback',
      data: {
        'type': type,
        'content': content,
        if (rating != null) 'rating': rating,
      },
    );
    return response.data!;
  }

  /// Gets feedback status.
  ///
  /// [feedbackId] - The feedback ID.
  Future<Map<String, dynamic>> getFeedbackStatus(String feedbackId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/feedback/$feedbackId',
    );
    return response.data!;
  }
}
