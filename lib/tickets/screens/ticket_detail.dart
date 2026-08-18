import 'dart:async';

import 'package:auto_route/auto_route.dart' hide AutoLeadingButton;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/accounts/abuse_report_service.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/drive/widgets/upload_menu.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

class SelectedFile {
  final XFile file;
  final String name;
  final bool isImage;

  SelectedFile({
    required this.file,
    required this.name,
    required this.isImage,
  });
}

@RoutePage()
class TicketDetailScreen extends HookConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    @PathParam('ticketId') required this.ticketId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final inputFocusNode = useFocusNode();
    final isSubmitting = useState(false);
    final attachments = useState<List<SelectedFile>>([]);
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));
    final currentUser = ref.watch(userInfoProvider).value;
    final messages = ticketAsync.value?.messages ?? const <SnTicketMessage>[];
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
      ) {
        ref.invalidate(ticketDetailProvider(ticketId));
      });

      return () {
        messagePollingTimer.value?.cancel();
      };
    }, [ref, ticketId]);

    // Track whether the thread is scrolled to the newest message.
    // The composer background shows only while history is being read.
    final isAtLatestMessages = useState(true);
    final lastAtLatestRef = useRef<bool?>(null);
    useEffect(() {
      final controller = scrollController;

      void updateAtLatest() {
        if (!controller.hasClients || controller.positions.length != 1) {
          return;
        }
        final atLatest =
            controller.positions.first.pixels >=
            controller.position.maxScrollExtent - 80;
        if (lastAtLatestRef.value == atLatest) return;
        lastAtLatestRef.value = atLatest;
        isAtLatestMessages.value = atLatest;
      }

      controller.addListener(updateAtLatest);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateAtLatest());
      return () => controller.removeListener(updateAtLatest);
    }, [scrollController]);

    // Scroll to the newest message whenever the list grows.
    final messageCount = messages.length;
    useEffect(() {
      if (messageCount > 0) {
        scrollToBottom(scrollController);
      }
      return null;
    }, [messageCount, scrollController]);

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
            usage: 'ticket',
            mode: selectedFile.isImage
                ? FileUploadMode.mediaSafe
                : FileUploadMode.generic,
          )
          .future;

      return cloudFile;
    }, [ref]);

    final sendMessage = useCallback(
      () async {
        if ((messageController.text.trim().isEmpty &&
                attachments.value.isEmpty) ||
            isSubmitting.value) {
          return;
        }

        isSubmitting.value = true;

        try {
          List<String>? attachmentIds;
          final currentAttachments = List<SelectedFile>.from(attachments.value);
          if (currentAttachments.isNotEmpty) {
            for (final selected in currentAttachments) {
              final cloudFile = await uploadAttachment(selected);
              if (cloudFile != null) {
                attachmentIds ??= [];
                attachmentIds.add(cloudFile.id);
              }
            }
          }

          await ref
              .read(ticketServiceProvider)
              .addMessage(
                ticketId,
                messageController.text.trim(),
                fileIds: attachmentIds,
              );
          if (!context.mounted) return;

          messageController.clear();
          attachments.value = [];
          ref.invalidate(ticketDetailProvider(ticketId));
        } catch (e) {
          showErrorAlert(e);
        } finally {
          if (context.mounted) {
            isSubmitting.value = false;
          }
        }
      },
      [
        messageController,
        isSubmitting,
        ref,
        ticketId,
        attachments,
        uploadAttachment,
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
      final picker = ImagePicker();
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
      final next = List<SelectedFile>.from(attachments.value)..removeAt(index);
      attachments.value = next;
    }, [attachments]);

    final updateStatus = useCallback((int status) async {
      try {
        await ref
            .read(ticketServiceProvider)
            .updateTicketStatus(ticketId, status);
        ref.invalidate(ticketDetailProvider(ticketId));
      } catch (e) {
        showErrorAlert(e);
      }
    }, [ref, ticketId]);

    return AppScaffold(
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(ticketDetailProvider(ticketId)),
        ),
        data: (ticket) => Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  centerTitle: false,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: _estimateExpandedHeight(context, ticket),
                  leading: const PageBackButton(),
                  actions: [
                    PopupMenuButton<int>(
                      icon: const Icon(Symbols.more_vert),
                      tooltip: 'ticketPriority'.tr(),
                      itemBuilder: (context) => [
                        for (final status in TicketStatus.values)
                          PopupMenuItem(
                            value: status.value,
                            child: Row(
                              children: [
                                Icon(
                                  _statusIcon(status.value),
                                  size: 20,
                                  color: _statusColor(context, status.value),
                                ),
                                const Gap(10),
                                Text(status.displayName),
                                if (ticket.status == status.value) ...[
                                  const Spacer(),
                                  Icon(
                                    Symbols.check,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                      onSelected: updateStatus,
                    ),
                    const Gap(4),
                  ],
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: _MetaChip(
                          label: TicketStatus.fromValue(
                            ticket.status,
                          ).displayName,
                          color: _statusColor(context, ticket.status),
                          icon: _statusIcon(ticket.status),
                        ),
                      ),
                      const Gap(8),
                      _MetaChip(
                        label: TicketPriority.values[ticket.priority]
                            .displayName,
                        color: Theme.of(context).colorScheme.tertiary,
                        icon: Symbols.flag,
                      ),
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _TicketBrief(ticket: ticket),
                  ),
                ),
                if (messages.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyThreadState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      100 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMine = currentUser != null &&
                            message.senderId == currentUser.id;
                        final previous = index > 0 ? messages[index - 1] : null;
                        final showHeader =
                            previous == null ||
                            previous.senderId != message.senderId;

                        return _MessageBubble(
                          message: message,
                          isMine: isMine,
                          showHeader: showHeader,
                        );
                      },
                    ),
                  ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ComposerBar(
                messageController: messageController,
                inputFocusNode: inputFocusNode,
                isSubmitting: isSubmitting,
                attachments: attachments,
                isMessageListScrolling: !isAtLatestMessages.value,
                onSend: sendMessage,
                onPickFile: pickFile,
                onPickGeneralFile: pickGeneralFile,
                onRemoveAttachment: removeAttachment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _estimateExpandedHeight(BuildContext context, SnTicket ticket) {
    final statusTop = MediaQuery.paddingOf(context).top;
    final textScaler = MediaQuery.textScalerOf(context);
    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final contentStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4) ??
        const TextStyle(height: 1.4);

    double contentHeight = 12; // top gap below the toolbar
    contentHeight += 32; // title
    contentHeight += 8; // gap
    contentHeight += 30; // type chip
    if (ticket.content != null && ticket.content!.trim().isNotEmpty) {
      contentHeight += 12;
      final painter = TextPainter(
        text: TextSpan(text: ticket.content, style: contentStyle),
        maxLines: 8,
        textDirection: Directionality.of(context),
        textScaler: textScaler,
      )..layout(maxWidth: availableWidth);
      contentHeight += painter.height.clamp(0.0, 150.0);
    }
    contentHeight += 12;
    contentHeight += 24; // meta row
    final hasResources = ticket.fileIds.isNotEmpty ||
        ticket.resources.whereType<String>().any((e) => e.trim().isNotEmpty);
    if (hasResources) {
      contentHeight += 12 + 30;
    }
    contentHeight += 16; // bottom padding

    return (statusTop + kToolbarHeight + contentHeight).clamp(
      statusTop + kToolbarHeight + 140.0,
      MediaQuery.sizeOf(context).height * 0.55,
    );
  }
}

class _TicketBrief extends StatelessWidget {
  final SnTicket ticket;

  const _TicketBrief({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resources = ticket.resources
        .whereType<String>()
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    // The flex space background fills the whole expanded app bar, including
    // the area behind the toolbar (back button, status chips, menu). Pad the
    // content below the toolbar so it never collides with it.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        kToolbarHeight + MediaQuery.paddingOf(context).top + 12,
        16,
        16,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ticket.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const Gap(8),
            _MetaChip(
              label: TicketType.values[ticket.type].displayName,
              color: _typeColor(context, ticket.type),
              icon: _typeIcon(ticket.type),
            ),
            if (ticket.content != null && ticket.content!.trim().isNotEmpty) ...[
              const Gap(12),
              SelectionArea(
                child: Text(
                  ticket.content!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const Gap(12),
            Row(
              children: [
                ProfilePictureWidget(
                  file: ticket.creator.profile.picture,
                  fallbackName: ticket.creator.nick,
                  radius: 12,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    ticket.creator.nick,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Symbols.schedule,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const Gap(4),
                Text(
                  ticket.createdAt.formatRelative(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (ticket.fileIds.isNotEmpty || resources.isNotEmpty) ...[
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (ticket.fileIds.isNotEmpty)
                    _MetaChip(
                      label:
                          '${ticket.fileIds.length} ${'attachments'.tr().toLowerCase()}',
                      color: colorScheme.outline,
                      icon: Symbols.attach_file,
                    ),
                  for (final resource in resources)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: resource));
                        showSnackBar('copiedToClipboard'.tr());
                      },
                      child: _MetaChip(
                        label: resource.length > 28
                            ? '${resource.substring(0, 25)}...'
                            : resource,
                        color: colorScheme.outline,
                        icon: Symbols.link,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
    );
  }
}

class _EmptyThreadState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.forum,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(6),
            Text(
              'Send a message to start the conversation',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SnTicketMessage message;
  final bool isMine;
  final bool showHeader;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showHeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bubbleColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(top: showHeader ? 12 : 4, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            if (showHeader)
              ProfilePictureWidget(
                file: message.sender.profile.picture,
                fallbackName: message.sender.nick,
                radius: 14,
              )
            else
              const SizedBox(width: 28),
            const Gap(8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AccountName(
                            account: message.sender,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            message.createdAt.formatRelative(context),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMine ? 18 : 6),
                        bottomRight: Radius.circular(isMine ? 6 : 18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.content.trim().isNotEmpty)
                            SelectableText(
                              message.content,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColor,
                                height: 1.35,
                              ),
                            ),
                          if (message.files.isNotEmpty) ...[
                            if (message.content.trim().isNotEmpty)
                              const Gap(10),
                            CloudFileList(
                              files: message.files,
                              maxHeight: 180,
                              borderRadius: 12,
                              initiallyCollapsed: false,
                              heroTagPrefix: 'ticket-msg-${message.id}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const Gap(4),
        ],
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode inputFocusNode;
  final ValueNotifier<bool> isSubmitting;
  final ValueNotifier<List<SelectedFile>> attachments;
  final bool isMessageListScrolling;
  final VoidCallback onSend;
  final void Function(bool isPhoto) onPickFile;
  final VoidCallback onPickGeneralFile;
  final void Function(int index) onRemoveAttachment;

  const _ComposerBar({
    required this.messageController,
    required this.inputFocusNode,
    required this.isSubmitting,
    required this.attachments,
    required this.isMessageListScrolling,
    required this.onSend,
    required this.onPickFile,
    required this.onPickGeneralFile,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // Scroll-aware backdrop: transparent at the latest message so the
        // thread runs to the screen edge; solid + shadow while reading
        // history so the composer reads as a separate surface.
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              boxShadow: [
                if (isMessageListScrolling)
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, -4),
                  ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: isMessageListScrolling
                  ? colorScheme.surfaceContainer
                  : Colors.transparent,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomInset),
          child: Material(
            elevation: 2,
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: attachments.value.isEmpty
                        ? const SizedBox.shrink(
                            key: ValueKey('no-attachments'),
                          )
                        : SizedBox(
                            key: ValueKey(
                              'attachments-${attachments.value.length}',
                            ),
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: attachments.value.length,
                              separatorBuilder: (_, _) => const Gap(8),
                              itemBuilder: (context, index) {
                                final file = attachments.value[index];
                                return _PendingAttachment(
                                  file: file,
                                  onRemove: () =>
                                      onRemoveAttachment(index),
                                );
                              },
                            ),
                          ).padding(bottom: 10),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      UploadMenu(
                        items: [
                          UploadMenuItemData(
                            Symbols.add_a_photo,
                            'addPhoto',
                            () => onPickFile(true),
                          ),
                          UploadMenuItemData(
                            Symbols.videocam,
                            'addVideo',
                            () => onPickFile(false),
                          ),
                          UploadMenuItemData(
                            Symbols.file_upload,
                            'uploadFile',
                            onPickGeneralFile,
                          ),
                        ],
                        iconColor: colorScheme.onSurfaceVariant,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: messageController,
                            focusNode: inputFocusNode,
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'addAdditionalMessage'.tr(),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(6),
                      FilledButton(
                        onPressed: isSubmitting.value ? null : onSend,
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(48, 48),
                        ),
                        child: isSubmitting.value
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Symbols.send, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingAttachment extends StatelessWidget {
  final SelectedFile file;
  final VoidCallback onRemove;

  const _PendingAttachment({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                file.isImage ? Symbols.image : Symbols.insert_drive_file,
                size: 22,
                color: colorScheme.primary,
              ),
              const Gap(6),
              Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Material(
            color: colorScheme.error,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Symbols.close,
                  size: 14,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MetaChip({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const Gap(4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error, size: 48, color: colorScheme.error),
            const Gap(12),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(int type) {
  switch (type) {
    case 0:
      return Symbols.support_agent;
    case 1:
      return Symbols.bug_report;
    case 2:
      return Symbols.lightbulb;
    case 3:
      return Symbols.payments;
    default:
      return Symbols.help;
  }
}

IconData _statusIcon(int status) {
  switch (status) {
    case 0:
      return Symbols.play_arrow;
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

Color _typeColor(BuildContext context, int type) {
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

Color _statusColor(BuildContext context, int status) {
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
