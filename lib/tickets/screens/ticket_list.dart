import 'dart:async';
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
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  Future<List<SnTicket>>? _ticketsFuture;
  bool _showAllTickets = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _loadTickets();
      }
    });
  }

  void _loadTickets() {
    final user = ref.read(userInfoProvider).value;
    final isAdmin = user?.isSuperuser == true;
    _ticketsFuture = ref
        .read(ticketServiceProvider)
        // The SDK's `isAdmin` flag selects the `/tickets` endpoint when false
        // and `/tickets/me` when true. Regular users must always use `/me`.
        .getTickets(isAdmin: !isAdmin || !_showAllTickets);
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
    ref.listen<AsyncValue<SnAccount?>>(userInfoProvider, (_, next) {
      if (next.hasValue && mounted) {
        _loadTickets();
        setState(() {});
      }
    });
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
          showAbuseReportSheet(context);
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
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: tickets.length,
                separatorBuilder: (_, _) => const Gap(16),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (ticket.content != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                ticket.content!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _M3Chip(
                                  label: TicketType
                                      .values[ticket.type]
                                      .displayName,
                                  color: _getTypeColor(context, ticket.type),
                                ),
                                _M3Chip(
                                  label: TicketPriority
                                      .values[ticket.priority]
                                      .displayName,
                                  color: _getPriorityColor(
                                    context,
                                    ticket.priority,
                                  ),
                                ),
                                _M3Chip(
                                  label: TicketStatus.fromValue(
                                    ticket.status,
                                  ).displayName,
                                  color: _getStatusColor(
                                    context,
                                    ticket.status,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Symbols.schedule,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    '${ticket.createdAt.formatRelative(context)} · ${ticket.createdAt.formatSystem()}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                if (isAdmin) ...[
                                  Icon(
                                    Symbols.person,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(4),
                                  Text(
                                    ticket.creator.nick,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
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

  Color _getTypeColor(BuildContext context, int type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case 0:
        return colorScheme.primary;
      case 1:
        return colorScheme.error;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      default:
        return colorScheme.outline;
    }
  }

  Color _getPriorityColor(BuildContext context, int priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority) {
      case 0:
        return colorScheme.outline;
      case 1:
        return colorScheme.primary;
      case 2:
        return Colors.orange;
      case 3:
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  Color _getStatusColor(BuildContext context, int status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return colorScheme.primary;
      case 2:
        return Colors.green;
      case 3:
        return colorScheme.outline;
      default:
        return colorScheme.outline;
    }
  }
}

class _M3Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _M3Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
