import 'dart:async';
import 'package:auto_route/auto_route.dart' hide AutoLeadingButton;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/drive/widgets/upload_menu.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

class SelectedFile {
  final XFile file;
  final String name;
  final bool isImage;

  SelectedFile({required this.file, required this.name, required this.isImage});
}

@RoutePage()
class TicketDetailScreen extends HookConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final inputFocusNode = useFocusNode();
    final isSubmitting = useState(false);
    final attachments = useState<List<SelectedFile>>([]);
    final ticketService = ref.watch(ticketServiceProvider);
    final cachedMessages = useState<List<SnTicketMessage>?>(null);
    final messagePollingTimer = useRef<Timer?>(null);

    void scrollToBottom(ScrollController sc) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (sc.hasClients) {
          sc.animateTo(
            sc.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    useEffect(() {
      messagePollingTimer.value = Timer.periodic(const Duration(minutes: 1), (
        _,
      ) async {
        if (!context.mounted) return;
        final ticket = await ticketService.getTicket(ticketId);
        if (context.mounted &&
            cachedMessages.value != null &&
            ticket.messages.length > cachedMessages.value!.length) {
          cachedMessages.value = ticket.messages;
          scrollToBottom(scrollController);
        }
      });

      return () {
        messagePollingTimer.value?.cancel();
      };
    }, []);

    final uploadAttachment = useCallback((SelectedFile selectedFile) async {
      final universalFile = UniversalFile(
        data: selectedFile.file,
        type: selectedFile.isImage
            ? UniversalFileType.image
            : UniversalFileType.file,
      );

      final pools = await ref.read(poolsProvider.future);
      final settings = ref.read(appSettingsProvider);
      final poolId = resolveDefaultPoolId(settings, pools);

      final cloudFile = await ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: universalFile,
            poolId: poolId,
            mode: selectedFile.isImage
                ? FileUploadMode.mediaSafe
                : FileUploadMode.generic,
          )
          .future;

      return cloudFile;
    }, [ref]);

    final sendMessage = useCallback(
      () async {
        if (messageController.text.trim().isEmpty &&
                attachments.value.isEmpty ||
            isSubmitting.value) {
          return;
        }

        isSubmitting.value = true;

        try {
          // Upload any pending attachments first
          List<String>? attachmentIds;
          final currentAttachments = List<SelectedFile>.from(attachments.value);
          if (currentAttachments.isNotEmpty) {
            for (int i = 0; i < currentAttachments.length; i++) {
              final cloudFile = await uploadAttachment(currentAttachments[i]);
              if (cloudFile != null) {
                attachmentIds ??= [];
                attachmentIds.add(cloudFile.id);
              }
            }
          }

          // Send message with fileIds if attachments were uploaded
          await ref
              .read(ticketServiceProvider)
              .addMessage(
                ticketId,
                messageController.text.trim(),
                fileIds: attachmentIds,
              );
          messageController.clear();
          attachments.value = [];

          // Refresh the ticket to get updated messages
          ref.invalidate(ticketServiceProvider);

          // Update cached messages and scroll
          final updatedTicket = await ticketService.getTicket(ticketId);
          cachedMessages.value = updatedTicket.messages;
          scrollToBottom(scrollController);
        } catch (e) {
          showErrorAlert(e);
        } finally {
          isSubmitting.value = false;
        }
      },
      [
        messageController,
        isSubmitting,
        ref,
        ticketId,
        attachments,
        uploadAttachment,
        cachedMessages,
      ],
    );

    final pickFile = useCallback((bool isPhoto) async {
      final picker = ImagePicker();
      final picked = isPhoto
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        attachments.value = [
          ...attachments.value,
          SelectedFile(
            file: XFile(picked.path),
            name: picked.name,
            isImage: isPhoto,
          ),
        ];
      }
    }, [attachments]);

    final pickGeneralFile = useCallback(() async {
      // Use document picker via file_selector for general files
      // For now, just use image picker as fallback
      final picker = ImagePicker();
      // Try to pick an image as a workaround
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        attachments.value = [
          ...attachments.value,
          SelectedFile(
            file: XFile(picked.path),
            name: picked.name,
            isImage: true,
          ),
        ];
      }
    }, [attachments]);

    final removeAttachment = useCallback((int index) {
      final newAttachments = List<SelectedFile>.from(attachments.value);
      newAttachments.removeAt(index);
      attachments.value = newAttachments;
    }, [attachments]);

    final updateStatus = useCallback((int status) async {
      try {
        await ref
            .read(ticketServiceProvider)
            .updateTicketStatus(ticketId, status);
        ref.invalidate(ticketServiceProvider);
      } catch (e) {
        showErrorAlert(e);
      }
    }, [ref, ticketId]);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: const PageBackButton(),
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
            if (cachedMessages.value == null) {
              cachedMessages.value = ticket.messages;
            }
            return Column(
              children: [
                // Ticket header
                _buildTicketHeader(context, ticket),

                // Messages section
                Expanded(
                  child: _buildMessagesSection(
                    context,
                    cachedMessages.value ?? ticket.messages,
                    scrollController,
                  ),
                ),

                // Message input - chat-like design
                _buildMessageInput(
                  context,
                  messageController,
                  inputFocusNode,
                  isSubmitting,
                  attachments,
                  sendMessage,
                  pickFile,
                  pickGeneralFile,
                  removeAttachment,
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
                _getTypeColor(context, ticket.type),
                Symbols.category,
              ),
              // Status badge
              _buildBadge(
                context,
                ticketStatus.displayName,
                _getStatusColor(context, ticket.status),
                _getStatusIcon(ticket.status),
              ),
              // Priority badge
              _buildBadge(
                context,
                ticketPriority.displayName,
                _getPriorityColor(context, ticket.priority),
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
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
    List<SnTicketMessage> messages,
    ScrollController scrollController,
  ) {
    if (messages.isEmpty) {
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
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
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
    FocusNode inputFocusNode,
    ValueNotifier<bool> isSubmitting,
    ValueNotifier<List<SelectedFile>> attachments,
    VoidCallback sendMessage,
    Function(bool) pickFile,
    VoidCallback pickGeneralFile,
    Function(int) removeAttachment,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Attachments preview
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: attachments.value.isNotEmpty
                    ? SizedBox(
                        key: ValueKey(
                          'attachments-${attachments.value.length}',
                        ),
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: attachments.value.length,
                          itemBuilder: (context, idx) {
                            final file = attachments.value[idx];
                            return _AttachmentPreview(
                              file: file,
                              onRemove: () => removeAttachment(idx),
                            );
                          },
                          separatorBuilder: (_, _) => const Gap(8),
                        ),
                      ).padding(vertical: 8)
                    : const SizedBox.shrink(key: ValueKey('no-attachments')),
              ),
              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload menu
                  UploadMenu(
                    items: [
                      UploadMenuItemData(
                        Symbols.add_a_photo,
                        'addPhoto',
                        () => pickFile(true),
                      ),
                      UploadMenuItemData(
                        Symbols.videocam,
                        'addVideo',
                        () => pickFile(false),
                      ),
                      UploadMenuItemData(
                        Symbols.file_upload,
                        'uploadFile',
                        pickGeneralFile,
                      ),
                    ],
                    iconColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: inputFocusNode,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  // Send button
                  IconButton(
                    icon: isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Symbols.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    onPressed: isSubmitting.value ? null : sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
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

class _AttachmentPreview extends StatelessWidget {
  final SelectedFile file;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                file.isImage ? Symbols.image : Symbols.insert_drive_file,
                size: 24,
              ),
              const Gap(4),
              Text(
                file.name.length > 10
                    ? '${file.name.substring(0, 8)}...'
                    : file.name,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Symbols.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
