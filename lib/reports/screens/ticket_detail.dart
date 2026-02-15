import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  Future<SnTicket>? _ticketFuture;

  @override
  void initState() {
    super.initState();
    _ticketFuture = ref.read(ticketServiceProvider).getTicket(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: FutureBuilder<SnTicket>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final ticket = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'Ticket ID', ticket.id),
                  _buildDetailRow(context, 'Title', ticket.title),
                  if (ticket.description != null)
                    _buildDetailRow(
                      context,
                      'Description',
                      ticket.description!,
                    ),
                  _buildDetailRow(context, 'Type', ticket.type.toString()),
                  _buildDetailRow(context, 'Status', ticket.status.toString()),
                  _buildDetailRow(
                    context,
                    'Priority',
                    ticket.priority.toString(),
                  ),
                  _buildDetailRow(context, 'Creator ID', ticket.creatorId),
                  if (ticket.assigneeId != null)
                    _buildDetailRow(context, 'Assignee ID', ticket.assigneeId!),
                  _buildDetailRow(
                    context,
                    'Resolved At',
                    ticket.resolvedAt?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    'Created At',
                    ticket.createdAt.toString(),
                  ),
                  _buildDetailRow(
                    context,
                    'Updated At',
                    ticket.updatedAt.toString(),
                  ),
                  if (ticket.messages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Messages',
                      style: Theme.of(context).textTheme.titleMedium,
                    ).bold(),
                    const SizedBox(height: 8),
                    ...ticket.messages.map(
                      (msg) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderId,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(msg.content),
                              const SizedBox(height: 4),
                              Text(
                                msg.createdAt.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium).bold(),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
