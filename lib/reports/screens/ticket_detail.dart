import 'package:auto_route/auto_route.dart' hide AutoLeadingButton;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/reports/ticket_models.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class TicketDetailScreen extends HookConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isSubmitting = useState(false);
    final ticketService = ref.watch(ticketServiceProvider);

    final sendMessage = useCallback(() async {
      if (messageController.text.trim().isEmpty || isSubmitting.value) return;

      isSubmitting.value = true;

      try {
        await ref
            .read(ticketServiceProvider)
            .addMessage(ticketId, messageController.text.trim());
        messageController.clear();

        // Refresh the ticket to get updated messages
        ref.invalidate(ticketServiceProvider);

        // Scroll to bottom after sending
        await Future.delayed(const Duration(milliseconds: 100));
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
        }
      } finally {
        isSubmitting.value = false;
      }
    }, [messageController, isSubmitting, ref, ticketId]);

    final updateStatus = useCallback((int status) async {
      try {
        await ref
            .read(ticketServiceProvider)
            .updateTicketStatus(ticketId, status);
        ref.invalidate(ticketServiceProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: $e')),
          );
        }
      }
    }, [ref, ticketId]);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: const AutoLeadingButton(),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Symbols.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [Icon(Symbols.play_arrow), Gap(8), Text('Open')],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Symbols.pending),
                    Gap(8),
                    Text('In Progress'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Symbols.check_circle),
                    Gap(8),
                    Text('Resolved'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: Row(
                  children: [Icon(Symbols.cancel), Gap(8), Text('Closed')],
                ),
              ),
            ],
            onSelected: updateStatus,
          ),
        ],
      ),
      body: FutureBuilder<SnTicket>(
        future: ticketService.getTicket(ticketId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.error, size: 48, color: Colors.red),
                  const Gap(16),
                  Text('Error: ${snapshot.error}'),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(ticketServiceProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final ticket = snapshot.data!;
            return Column(
              children: [
                // Ticket header
                _buildTicketHeader(context, ticket),

                // Messages section
                Expanded(
                  child: _buildMessagesSection(
                    context,
                    ticket,
                    scrollController,
                  ),
                ),

                // Message input
                _buildMessageInput(
                  context,
                  messageController,
                  isSubmitting,
                  sendMessage,
                ),
              ],
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildTicketHeader(BuildContext context, SnTicket ticket) {
    final ticketType = TicketType.fromValue(ticket.type);
    final ticketStatus = TicketStatus.fromValue(ticket.status);
    final ticketPriority = TicketPriority.fromValue(ticket.priority);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            ticket.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(12),

          // Content/Description
          if (ticket.content != null && ticket.content!.isNotEmpty) ...[
            Text(
              ticket.content!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(12),
          ],

          // Status badges row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Type badge
              _buildBadge(
                context,
                ticketType.displayName,
                _getTypeColor(ticket.type),
                Symbols.category,
              ),
              // Status badge
              _buildBadge(
                context,
                ticketStatus.displayName,
                _getStatusColor(ticket.status),
                _getStatusIcon(ticket.status),
              ),
              // Priority badge
              _buildBadge(
                context,
                ticketPriority.displayName,
                _getPriorityColor(ticket.priority),
                _getPriorityIcon(ticket.priority),
              ),
            ],
          ),
          const Gap(12),

          // Created info
          Row(
            children: [
              Icon(
                Symbols.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const Gap(4),
              Text(
                'Created ${ticket.createdAt.formatRelative(context)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Files section
          if (ticket.fileIds.isNotEmpty) ...[
            const Gap(12),
            const Divider(),
            const Gap(8),
            Text(
              'Attachments (${ticket.fileIds.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ticket.fileIds.map((fileId) {
                return Chip(
                  avatar: const Icon(Symbols.attach_file, size: 18),
                  label: Text(
                    fileId.length > 8 ? fileId.substring(0, 8) : fileId,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(
    BuildContext context,
    SnTicket ticket,
    ScrollController scrollController,
  ) {
    if (ticket.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.chat_bubble_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const Gap(16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            Text(
              'Send a message to start the conversation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: ticket.messages.length,
      itemBuilder: (context, index) {
        final message = ticket.messages[index];
        return _buildMessageCard(context, message);
      },
    );
  }

  Widget _buildMessageCard(BuildContext context, SnTicketMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePictureWidget(
                file: message.sender.profile.picture,
                radius: 16,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccountName(
                      account: message.sender,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${message.createdAt.formatRelative(context)} · ${message.createdAt.formatSystem()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(message.content, style: Theme.of(context).textTheme.bodyMedium),
          // Files section for message
          if (message.files.isNotEmpty) ...[
            const Divider(),
            Text(
              'Attachments (${message.files.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            CloudFileList(files: message.files),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    TextEditingController messageController,
    ValueNotifier<bool> isSubmitting,
    VoidCallback sendMessage,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const Gap(8),
          IconButton.filled(
            onPressed: isSubmitting.value ? null : sendMessage,
            icon: isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.send),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.red;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Symbols.radio_button_unchecked;
      case 1:
        return Symbols.pending;
      case 2:
        return Symbols.check_circle;
      case 3:
        return Symbols.cancel;
      default:
        return Symbols.help;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 0:
        return Symbols.arrow_downward;
      case 1:
        return Symbols.remove;
      case 2:
        return Symbols.arrow_upward;
      case 3:
        return Symbols.priority_high;
      default:
        return Symbols.remove;
    }
  }
}
