import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/chat/widgets/chat_link_attachments.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/core/widgets/content/attachment_preview.dart';
import 'package:island/drive/widgets/upload_menu.dart';
import 'package:island/route.gr.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/thoughts/widgets/function_calls_section.dart';
import 'package:island/thoughts/widgets/proposals_section.dart';
import 'package:island/thoughts/widgets/reasoning_section.dart';
import 'package:island/thoughts/widgets/thought_chat_notifier.dart';
import 'package:island/thoughts/widgets/thought_content.dart';
import 'package:island/thoughts/widgets/thought_header.dart';
import 'package:island/thoughts/widgets/token_info.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/drive/widgets/cloud_files.dart';

class ThoughtChatInterface extends HookConsumerWidget {
  final List<SnThinkingThought>? initialThoughts;
  final String? initialSequenceId;
  final String? initialTopic;
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;
  final bool isDisabled;
  final VoidCallback? onSequenceIdChanged;

  const ThoughtChatInterface({
    super.key,
    this.initialThoughts,
    this.initialSequenceId,
    this.initialTopic,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
    this.isDisabled = false,
    this.onSequenceIdChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputKey = useMemoized(() => GlobalKey());
    final isAtLatestThoughts = useState(true);

    // Create args for the provider
    final args = ThoughtChatArgs(
      initialSequenceId: initialSequenceId,
      initialThoughts: initialThoughts,
      initialTopic: initialTopic,
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    // Watch the notifier
    final chatState = ref.watch(thoughtChatProvider(args));
    final notifier = ref.read(thoughtChatProvider(args).notifier);

    // Sync external state changes
    useEffect(() {
      Future(() {
        notifier.updateSequenceId(initialSequenceId);
      });
      return null;
    }, [initialSequenceId]);

    useEffect(() {
      Future(() {
        if (initialThoughts != null) {
          notifier.updateThoughts(initialThoughts!);
        }
      });
      return null;
    }, [initialThoughts]);

    useEffect(() {
      Future(() {
        if (initialTopic != null) {
          notifier.updateTopic(initialTopic);
        }
      });
      return null;
    }, [initialTopic]);

    // Listen for sequence ID changes from the notifier
    useEffect(() {
      Future(() {
        if (chatState.sequenceId != null && onSequenceIdChanged != null) {
          onSequenceIdChanged!();
        }
      });
      return null;
    }, [chatState.sequenceId]);

    useEffect(() {
      void updateAtLatestState() {
        final controller = notifier.scrollController;
        if (!controller.hasClients) return;
        // In reverse list, pixels near 0 means latest messages.
        isAtLatestThoughts.value = controller.position.pixels <= 80;
      }

      notifier.scrollController.addListener(updateAtLatestState);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateAtLatestState());

      return () => notifier.scrollController.removeListener(updateAtLatestState);
    }, [notifier.scrollController]);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          children: [
            Expanded(
              child: SuperListView.builder(
                listController: notifier.listController,
                controller: notifier.scrollController,
                padding: EdgeInsets.only(top: 16),
                reverse: true,
                itemCount: chatState.localThoughts.length + (chatState.isStreaming ? 1 : 0),
                itemBuilder: (context, index) {
                  if (chatState.isStreaming && index == 0) {
                    return ThoughtItem(
                      isStreaming: true,
                      streamingItems: chatState.streamingItems,
                      agentService: chatState.selectedServiceId,
                    );
                  }
                  final thoughtIndex = chatState.isStreaming ? index - 1 : index;
                  final thought = chatState.localThoughts[thoughtIndex];
                  return ThoughtItem(thought: thought, agentService: chatState.selectedServiceId);
                },
              ),
            ),
            if (chatState.currentStatus != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      chatState.currentStatus!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    if (chatState.compactSummary != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chatState.compactSummary!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (chatState.archivedCount != null)
                      Text(
                        'thoughtCompactArchived'.tr(args: [chatState.archivedCount.toString()]),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                      ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ThoughtInput(
                  key: inputKey,
                  messageController: notifier.messageController,
                  isStreaming: chatState.isStreaming,
                  isListScrolledAwayFromLatest: !isAtLatestThoughts.value,
                  onSend: notifier.sendMessage,
                  attachedMessages: attachedMessages,
                  attachedPosts: attachedPosts,
                  isDisabled: isDisabled,
                  // Attachment support
                  attachments: chatState.attachments,
                  attachmentProgress: chatState.attachmentProgress,
                  onUploadAttachment: notifier.uploadAttachment,
                  onDeleteAttachment: notifier.deleteAttachment,
                  onAttachmentsChanged: notifier.updateAttachments,
                  // Service and model selection
                  services: chatState.services,
                  selectedServiceId: chatState.selectedServiceId,
                  onServiceChanged: notifier.setSelectedServiceId,
                  availableModels: chatState.availableModels,
                  selectedModel: chatState.selectedModel,
                  onModelChanged: notifier.setSelectedModel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, String>> _extractProposals(String content) {
  final proposalRegex = RegExp(r'<proposal\s+type="([^"]+)">(.*?)<\/proposal>', dotAll: true);
  final matches = proposalRegex.allMatches(content);
  return matches.map((match) {
    return {'type': match.group(1)!, 'content': match.group(2)!};
  }).toList();
}

void _handleProposalAction(BuildContext context, Map<String, String> proposal) {
  switch (proposal['type']) {
    case 'post_create':
      // Show post creation dialog with the proposal content
      PostComposeDialog.show(
        context,
        initialState: PostComposeInitialState(content: (proposal['content'] ?? '').trim()),
      );
      break;
    default:
      // Show a snackbar for unsupported proposal types
      showSnackBar('Unsupported proposal type: ${proposal['type']}');
  }
}

/// A service selector widget for use in app bars.
class ServiceSelector extends ConsumerWidget {
  final List<ThoughtService> services;
  final String selectedServiceId;
  final ValueChanged<String> onServiceChanged;
  final bool isStreaming;
  final bool isDisabled;

  const ServiceSelector({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onServiceChanged,
    this.isStreaming = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HookBuilder(
      builder: (context) {
        if (services.isEmpty) return const SizedBox.shrink();
        final colorScheme = Theme.of(context).colorScheme;
        final selectedIndex = services.indexWhere((s) => s.id == selectedServiceId);
        final effectiveIndex = selectedIndex >= 0 ? selectedIndex : 0;
        final isInteractive = !isStreaming && !isDisabled;
        final tabController = useTabController(initialLength: services.length, initialIndex: effectiveIndex);

        useEffect(() {
          if (tabController.index != effectiveIndex) {
            tabController.animateTo(effectiveIndex);
          }
          return null;
        }, [effectiveIndex, tabController]);

        return IgnorePointer(
          ignoring: !isInteractive,
          child: Opacity(
            opacity: isInteractive ? 1 : 0.7,
            child: TabBar(
              controller: tabController,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.zero,
              indicator: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.65), width: 1),
              ),
              labelColor: colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor!,
              onTap: (index) => onServiceChanged(services[index].id),
              tabs: services.map((service) {
                final isSelected = services[tabController.index].id == service.id;
                return Tab(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service.id == 'michan' ? Symbols.chat_bubble : Symbols.smart_toy,
                        size: 16,
                        fill: isSelected ? 1 : 0,
                        color: isSelected ? colorScheme.onSurface : Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      const Gap(6),
                      Text(
                        'thinkService${service.id.capitalizeEachWord()}'.tr(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected ? colorScheme.onSurface : Theme.of(context).appBarTheme.foregroundColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ThoughtInput extends HookWidget {
  final TextEditingController messageController;
  final bool isStreaming;
  final bool isListScrolledAwayFromLatest;
  final VoidCallback onSend;
  final List<Map<String, dynamic>>? attachedMessages;
  final List<String>? attachedPosts;
  final bool isDisabled;

  // Attachment support
  final List<UniversalFile> attachments;
  final Map<int, double?> attachmentProgress;
  final Function(int) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;

  // Service and model selection
  final List<ThoughtService> services;
  final String selectedServiceId;
  final ValueChanged<String> onServiceChanged;
  final List<ThoughtServiceModel> availableModels;
  final String? selectedModel;
  final ValueChanged<String?> onModelChanged;

  const ThoughtInput({
    super.key,
    required this.messageController,
    required this.isStreaming,
    required this.isListScrolledAwayFromLatest,
    required this.onSend,
    this.attachedMessages,
    this.attachedPosts,
    this.isDisabled = false,
    // Attachment support
    this.attachments = const [],
    this.attachmentProgress = const {},
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onAttachmentsChanged,
    // Service and model selection
    required this.services,
    required this.selectedServiceId,
    required this.onServiceChanged,
    this.availableModels = const [],
    this.selectedModel,
    required this.onModelChanged,
  });

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _addAttachment(picked);
    }
  }

  Future<void> _linkAttachment(BuildContext context) async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ChatLinkAttachment(),
    );
    if (cloudFile == null) return;

    final newAttachments = [
      ...attachments,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType?.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ];
    onAttachmentsChanged(newAttachments);
  }

  void _addAttachment(XFile file) {
    final newAttachment = UniversalFile(displayName: file.name, data: file, type: _getFileType(file));
    onAttachmentsChanged([...attachments, newAttachment]);
  }

  UniversalFileType _getFileType(XFile file) {
    final mimeType = file.mimeType ?? '';
    if (mimeType.startsWith('image/')) return UniversalFileType.image;
    if (mimeType.startsWith('video/')) return UniversalFileType.video;
    if (mimeType.startsWith('audio/')) return UniversalFileType.audio;
    return UniversalFileType.image;
  }

  void _onMoveAttachment(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= attachments.length) return;
    final newAttachments = [...attachments];
    final item = newAttachments.removeAt(index);
    newAttachments.insert(newIndex, item);
    onAttachmentsChanged(newAttachments);
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T? value,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInteractive = onChanged != null;
    final hasValue = items.contains(value);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: hasValue ? value : null,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Symbols.arrow_drop_down,
            size: 18,
            color: isInteractive ? colorScheme.onSurfaceVariant : colorScheme.outline,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(20),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNullableDropdown<T extends Object>({
    required BuildContext context,
    required T? value,
    required String nullLabel,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInteractive = onChanged != null;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value?.toString() ?? '__null__',
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Symbols.arrow_drop_down,
            size: 18,
            color: isInteractive ? colorScheme.onSurfaceVariant : colorScheme.outline,
          ),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(20),
          onChanged: isInteractive
              ? (v) => onChanged(v == '__null__' ? null : items.firstWhere((i) => i.toString() == v))
              : null,
          items: [
            DropdownMenuItem<String>(
              value: '__null__',
              child: Text(nullLabel, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
            ),
            ...items.map((item) {
              return DropdownMenuItem<String>(value: item.toString(), child: itemBuilder(item));
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              boxShadow: [
                if (isListScrolledAwayFromLatest)
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, -4),
                  ),
              ],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              color: isListScrolledAwayFromLatest ? Theme.of(context).colorScheme.surfaceContainer : Colors.transparent,
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          child: Material(
            elevation: 2,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: SizeTransition(sizeFactor: animation, axisAlignment: -1.0, child: child),
                        ),
                      );
                    },
                    child: attachments.isNotEmpty
                        ? SizedBox(
                            key: ValueKey('attachments-${attachments.length}'),
                            height: 180,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              scrollDirection: Axis.horizontal,
                              itemCount: attachments.length,
                              itemBuilder: (context, idx) {
                                return SizedBox(
                                  width: 180,
                                  child: AttachmentPreview(
                                    isCompact: true,
                                    item: attachments[idx],
                                    progress: attachmentProgress[idx],
                                    isUploading: attachmentProgress.containsKey(idx),
                                    onRequestUpload: () => onUploadAttachment(idx),
                                    onDelete: () => onDeleteAttachment(idx),
                                    onUpdate: (value) {
                                      final newAttachments = [...attachments];
                                      newAttachments[idx] = value;
                                      onAttachmentsChanged(newAttachments);
                                    },
                                    onMove: (delta) => _onMoveAttachment(idx, delta),
                                  ),
                                );
                              },
                              separatorBuilder: (_, _) => const Gap(8),
                            ),
                          ).padding(vertical: 12)
                        : const SizedBox.shrink(key: ValueKey('no-attachments')),
                  ),
                  if ((attachedMessages?.isNotEmpty ?? false) || (attachedPosts?.isNotEmpty ?? false))
                    Container(
                      key: ValueKey('attachments-${attachedMessages?.length ?? 0}-${attachedPosts?.length ?? 0}'),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
                      ),
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Symbols.attach_file, size: 16, color: Theme.of(context).colorScheme.primary),
                          const Gap(4),
                          Text(
                            [
                              if (attachedMessages?.isNotEmpty ?? false)
                                '${attachedMessages!.length} message${attachedMessages!.length > 1 ? 's' : ''}',
                              if (attachedPosts?.isNotEmpty ?? false)
                                '${attachedPosts!.length} post${attachedPosts!.length > 1 ? 's' : ''}',
                            ].join(', '),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 14),
                              onPressed: () {},
                              tooltip: 'clear',
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UploadMenu(
                        items: [
                          UploadMenuItemData(Symbols.add_a_photo, 'addPhoto', () => _pickFile()),
                          UploadMenuItemData(Symbols.attach_file, 'linkAttachment', () => _linkAttachment(context)),
                        ],
                        iconColor: Theme.of(context).colorScheme.onSurface,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          keyboardType: TextInputType.multiline,
                          enabled: !isStreaming && !isDisabled,
                          decoration: InputDecoration(
                            hintText:
                                (isStreaming
                                        ? 'thoughtStreamingHint'
                                        : isDisabled
                                        ? 'thoughtUnpaidHint'.tr()
                                        : 'thoughtInputHint')
                                    .tr(),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (!isStreaming && !isDisabled) ? (_) => onSend() : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(isStreaming ? Symbols.stop : Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: (!isStreaming && !isDisabled) ? onSend : null,
                      ),
                    ],
                  ),
                  // Service and Model selectors
                  if (services.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
                      child: Row(
                        children: [
                          // Bot/Service dropdown
                          Expanded(
                            child: _buildDropdown<ThoughtService>(
                              context: context,
                              value: services.where((s) => s.id == selectedServiceId).firstOrNull,
                              items: services,
                              onChanged: (isStreaming || isDisabled)
                                  ? null
                                  : (ThoughtService? value) {
                                      if (value != null) {
                                        onServiceChanged(value.id);
                                      }
                                    },
                              itemBuilder: (service) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    service.id == 'michan' ? Symbols.chat_bubble : Symbols.smart_toy,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(6),
                                  Flexible(child: Text(service.name, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          ),
                          const Gap(8),
                          // Model dropdown
                          if (availableModels.isNotEmpty)
                            Expanded(
                              child: _buildNullableDropdown<ThoughtServiceModel>(
                                context: context,
                                value: selectedModel != null
                                    ? availableModels.where((m) => m.id == selectedModel).firstOrNull
                                    : null,
                                nullLabel: 'Auto',
                                items: availableModels,
                                onChanged: (isStreaming || isDisabled)
                                    ? null
                                    : (ThoughtServiceModel? value) {
                                        onModelChanged(value?.id);
                                      },
                                itemBuilder: (model) => Text(
                                  model.displayName,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
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

// Unified thought item widget
class ThoughtItem extends StatelessWidget {
  final String agentService;

  const ThoughtItem({
    super.key,
    this.thought,
    this.isStreaming = false,
    this.streamingItems,
    required this.agentService,
  }) : assert(
         (streamingItems != null && isStreaming) || (thought != null && !isStreaming),
         'Either streamingItems or thought must be provided',
       );

  final SnThinkingThought? thought;
  final bool isStreaming;
  final List<StreamItem>? streamingItems;

  @override
  Widget build(BuildContext context) {
    final isUser = !isStreaming && thought!.role == ThinkingThoughtRole.user;
    final isSystem = !isStreaming && thought!.role == ThinkingThoughtRole.system;
    final effectiveBotName = (thought?.botName ?? agentService).toLowerCase();
    final isMichanStyle = effectiveBotName == 'michan';

    if (isSystem) {
      return _buildSystemBanner(context);
    }

    if (isMichanStyle) {
      return _buildMichanChatItem(context, isUser);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ThoughtHeader(agentService: agentService, item: thought, isStreaming: isStreaming, isUser: isUser),
          const Gap(8),
          // Content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: buildWidgetsList(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMichanChatItem(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isUser ? colorScheme.primaryContainer.withOpacity(0.55) : colorScheme.surfaceContainer;
    final bubbleBorderColor = isUser ? colorScheme.primary.withOpacity(0.18) : colorScheme.outline.withOpacity(0.18);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ThoughtHeader(
                      agentService: agentService,
                      item: thought,
                      isStreaming: isStreaming,
                      isUser: isUser,
                    ),
                  ),
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: bubbleBorderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: buildWidgetsList(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildWidgetsList(BuildContext context) {
    if (!isStreaming && (thought?.parts.any((e) => e.metadata?['compaction_summary'] == true)) == true) {
      return [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.compress, size: 16, color: Theme.of(context).colorScheme.secondary),
                  const Gap(4),
                  Text(
                    'Context Compacted',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${thought!.parts.firstWhereOrNull((e) => e.metadata?['compaction_archived_count'] != null)?.metadata?['compaction_archived_count']} messages archived',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              if (thought?.parts.isNotEmpty == true) ...[
                const Gap(8),
                Text(
                  thought!.parts.first.text ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ];
    }

    final List<StreamItem> items = isStreaming
        ? (streamingItems ?? [])
        : thought!.parts.map((p) {
            String type;
            switch (p.type) {
              case ThinkingMessagePartType.text:
                type = 'text';
                break;
              case ThinkingMessagePartType.functionCall:
                type = 'function_call';
                break;
              case ThinkingMessagePartType.functionResult:
                type = 'function_result';
                break;
            }
            return StreamItem(
              type,
              p.type == ThinkingMessagePartType.text ? p.text ?? '' : p.functionCall ?? p.functionResult,
            );
          }).toList();

    final isAI = isStreaming || (!isStreaming && thought!.role == ThinkingThoughtRole.assistant);
    final List<Map<String, String>> proposals = !isStreaming
        ? _extractProposals(
            thought!.parts.where((p) => p.type == ThinkingMessagePartType.text).map((p) => p.text ?? '').join(),
          )
        : [];

    final List<Widget> widgets = [];
    String currentText = '';
    bool hasOpenText = false;
    int i = 0;
    while (i < items.length) {
      final item = items[i];
      if (item.type == 'text') {
        currentText += item.data as String;
        hasOpenText = true;
      } else if (item.type == 'function_call') {
        if (hasOpenText) {
          widgets.add(buildTextRow(currentText));
          currentText = '';
          hasOpenText = false;
        }
        // check next for result
        StreamItem? result;
        if (i + 1 < items.length && items[i + 1].type == 'function_result') {
          result = items[i + 1];
          i++; // skip it
        }
        widgets.add(
          FunctionCallsSection(
            isFinish: result != null,
            isStreaming: isStreaming,
            callData: JsonEncoder.withIndent('  ').convert(item.data.toJson()),
            resultData: result != null ? JsonEncoder.withIndent('  ').convert(result.data.toJson()) : null,
          ),
        );
      } else if (item.type == 'function_result') {
        if (hasOpenText) {
          widgets.add(buildTextRow(currentText));
          currentText = '';
          hasOpenText = false;
        }
        // orphan result, treat as finished with call
        widgets.add(
          FunctionCallsSection(
            isFinish: true,
            isStreaming: isStreaming,
            callData: null,
            resultData: JsonEncoder.withIndent('  ').convert(item.data.toJson()),
          ),
        );
      } else if (item.type == 'reasoning') {
        if (hasOpenText) {
          widgets.add(buildTextRow(currentText));
          currentText = '';
          hasOpenText = false;
        }
        widgets.add(buildItemWidget(item));
      } else {
        // ignore
      }
      i++;
    }
    if (hasOpenText) {
      widgets.add(buildTextRow(currentText));
    }

    // Render files from thought parts (not streaming)
    if (!isStreaming && thought != null) {
      for (final part in thought!.parts) {
        if (part.files != null && part.files!.isNotEmpty) {
          widgets.add(_buildFilesWidget(context, part.files!));
        }
      }
    }

    // Add spinner at the end if streaming
    if (isStreaming) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5)).padding(left: 8),
          ],
        ),
      );
    }

    // The proposals and token info at the end
    if (!isStreaming && proposals.isNotEmpty && isAI) {
      widgets.add(ProposalsSection(proposals: proposals, onProposalAction: _handleProposalAction));
    }
    if (!isStreaming && isAI && thought != null && !thought!.id.startsWith('error-')) {
      widgets.add(TokenInfo(thought: thought!));
    }
    return widgets;
  }

  Widget buildTextRow(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: ThoughtContent(isStreaming: isStreaming, streamingText: text, thought: thought),
        ),
      ],
    );
  }

  Widget buildItemWidget(StreamItem item) {
    switch (item.type) {
      case 'reasoning':
        return ReasoningSection(reasoningChunks: [item.data]);
      default:
        throw 'unknown item type ${item.type}';
    }
  }

  Widget _buildFilesWidget(BuildContext context, List<SnCloudFile> files) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: files.asMap().entries.map((entry) {
        final file = entry.value;
        return InkWell(
          onTap: () {
            final isImage = file.mimeType?.startsWith('image') == true;
            if (isImage) {
              context.pushTransparentRoute(
                CloudFileLightbox(items: files, initialIndex: entry.key, heroTag: 'cloud-file-thought-${file.id}'),
              );
            } else {
              context.router.push(FileDetailRoute(item: file, heroTag: 'cloud-file-thought-${file.id}'));
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: SizedBox(
              width: 200,
              child: CloudFileWidget(item: file, heroTag: 'cloud-file-thought-${file.id}', fit: BoxFit.cover),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSystemBanner(BuildContext context) {
    final textContent =
        thought?.parts.where((p) => p.type == ThinkingMessagePartType.text).map((p) => p.text ?? '').join() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3), width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            visualDensity: VisualDensity.compact,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            leading: Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.secondary),
            title: Text(
              (thought?.parts.any((e) => e.metadata?['compaction_summary'] == true) ?? false)
                  ? 'System: Context Compacted'
                  : 'System',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              if (thought?.parts.any((e) => e.metadata?['compaction_summary'] == true) ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${thought!.parts.firstWhereOrNull((e) => e.metadata?['compaction_archived_count'])?.metadata?['compaction_archived_count']} messages archived',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              MarkdownTextContent(content: textContent, textStyle: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
