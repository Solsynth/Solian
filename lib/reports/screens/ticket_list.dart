import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/core/services/time.dart';
import 'package:island/reports/widgets/ticket_fire.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide AutoLeadingButton;
import 'package:island/route.gr.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  Future<List<SnTicket>>? _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ref.read(ticketServiceProvider).getTickets();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('tickets').tr(),
        leading: const AutoLeadingButton(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showAbuseReportSheet(context, resourceIdentifier: 'unidentified');
        },
      ).padding(bottom: MediaQuery.paddingOf(context).bottom + 8),
      body: FutureBuilder<List<SnTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tickets = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: tickets.length,
              separatorBuilder: (_, _) => const Gap(16),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.router.push(
                        TicketDetailRoute(ticketId: ticket.id),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (ticket.content != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              ticket.content!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                ticket.id,
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
                                TicketType.values[ticket.type].displayName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Priority',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                TicketPriority
                                    .values[ticket.priority]
                                    .displayName,
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
                                '${ticket.createdAt.formatRelative(context)} · ${ticket.createdAt.formatSystem()}',
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
                                TicketStatus.fromValue(ticket.status).displayName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          ticket.status == 2 ||
                                          ticket.status == 3
                                          ? Colors.green
                                          : ticket.status == 1
                                          ? Colors.blue
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
