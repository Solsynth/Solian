import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/route.gr.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  Future<List<SnTicket>>? _ticketsFuture;
  bool _showAllTickets = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final user = ref.read(userInfoProvider).value;
    final isAdmin = user?.isSuperuser == true;
    _ticketsFuture = ref
        .read(ticketServiceProvider)
        .getTickets(isAdmin: isAdmin && _showAllTickets);
  }

  void _toggleShowAllTickets() {
    setState(() {
      _showAllTickets = !_showAllTickets;
    });
    _loadTickets();
  }

  Future<void> _refreshTickets() async {
    _loadTickets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userInfoProvider);
    final isAdmin = userAsync.value?.isSuperuser == true;

    return AppScaffold(
      appBar: AppBar(
        title: Text('tickets').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(
                _showAllTickets ? Icons.people_outline : Icons.person_outline,
              ),
              tooltip: _showAllTickets
                  ? 'Showing all tickets'
                  : 'Showing my tickets',
              onPressed: _toggleShowAllTickets,
            ),
          const Gap(8),
        ],
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
            return RefreshIndicator(
              onRefresh: _refreshTickets,
              child: ListView.separated(
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
                            if (isAdmin) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Creator',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    ticket.creator.nick,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  TicketStatus.fromValue(
                                    ticket.status,
                                  ).displayName,
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
              ),
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
