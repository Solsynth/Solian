import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dismissible_page/dismissible_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose_sheet.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/thoughts/thought.dart';
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
    final inputHeight = useState<double>(80.0);

    // Track previous height for smooth animations
    final previousInputHeight = usePrevious<double>(inputHeight.value);

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

    // Periodic height measurement for dynamic sizing
    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        final renderBox =
            inputKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final newHeight = renderBox.size.height;
          if (newHeight != inputHeight.value) {
            inputHeight.value = newHeight;
          }
        }
      });
      return timer.cancel;
    }, []);

    return Stack(
      children: [
        // Thoughts list
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child:
                      previousInputHeight != null &&
                          previousInputHeight != inputHeight.value
                      ? TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: previousInputHeight,
                            end: inputHeight.value,
                          ),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          builder: (context, height, child) =>
                              SuperListView.builder(
                                listController: notifier.listController,
                                controller: notifier.scrollController,
                                padding: EdgeInsets.only(
                                  top: 16,
                                  bottom:
                                      MediaQuery.of(context).padding.bottom +
                                      8 +
                                      height,
                                ),
                                reverse: true,
                                itemCount:
                                    chatState.localThoughts.length +
                                    (chatState.isStreaming ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (chatState.isStreaming && index == 0) {
                                    return ThoughtItem(
                                      isStreaming: true,
                                      streamingItems: chatState.streamingItems,
                                      agentService: chatState.selectedServiceId,
                                    );
                                  }
                                  final thoughtIndex = chatState.isStreaming
                                      ? index - 1
                                      : index;
                                  final thought =
                                      chatState.localThoughts[thoughtIndex];
                                  return ThoughtItem(
                                    thought: thought,
                                    agentService: chatState.selectedServiceId,
                                  );
                                },
                              ),
                        )
                      : SuperListView.builder(
                          listController: notifier.listController,
                          controller: notifier.scrollController,
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom:
                                MediaQuery.of(context).padding.bottom +
                                8 +
                                inputHeight.value,
                          ),
                          reverse: true,
                          itemCount:
                              chatState.localThoughts.length +
                              (chatState.isStreaming ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (chatState.isStreaming && index == 0) {
                              return ThoughtItem(
                                isStreaming: true,
                                streamingItems: chatState.streamingItems,
                                agentService: chatState.selectedServiceId,
                              );
                            }
                            final thoughtIndex = chatState.isStreaming
                                ? index - 1
                                : index;
                            final thought =
                                chatState.localThoughts[thoughtIndex];
                            return ThoughtItem(
                              thought: thought,
                              agentService: chatState.selectedServiceId,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        // Bottom gradient - appears when scrolling towards newer thoughts (behind thought input)
        AnimatedBuilder(
          animation: notifier.bottomGradientNotifier,
          builder: (context, child) => Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: notifier.bottomGradientNotifier.value,
              child: Container(
                height: math.min(MediaQuery.of(context).size.height * 0.1, 128),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withOpacity(0.8),
                      Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Thought Input positioned above gradient (higher z-index)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0, // At the very bottom, above gradient
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ThoughtInput(
                key: inputKey,
                messageController: notifier.messageController,
                isStreaming: chatState.isStreaming,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<Map<String, String>> _extractProposals(String content) {
  final proposalRegex = RegExp(
    r'<proposal\s+type="([^"]+)">(.*?)<\/proposal>',
    dotAll: true,
  );
  final matches = proposalRegex.allMatches(content);
  return matches.map((match) {
    return {'type': match.group(1)!, 'content': match.group(2)!};
  }).toList();
}

void _handleProposalAction(BuildContext context, Map<String, String> proposal) {
  switch (proposal['type']) {
    case 'post_create':
      // Show post creation dialog with the proposal content
      PostComposeSheet.show(
        context,
        initialState: PostComposeInitialState(
          content: (proposal['content'] ?? '').trim(),
        ),
      );
      break;
    default:
      // Show a snackbar for unsupported proposal types
      showSnackBar('Unsupported proposal type: ${proposal['type']}');
  }
}

/// A service selector dropdown widget for use in app bars
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
    if (services.isEmpty) return const SizedBox.shrink();

    // Ensure the selected value is valid
    final currentValue = selectedServiceId;
    final isValueValid =
        currentValue.isNotEmpty && services.any((s) => s.id == currentValue);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        value: isValueValid ? currentValue : null,
        customButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                Symbols.smart_toy,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              Flexible(
                child: Text(
                  isValueValid
                      ? 'thinkService${services.firstWhere((s) => s.id == currentValue).id.capitalizeEachWord()}'
                            .tr()
                      : 'Select Service',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        items: services
            .map(
              (service) => DropdownMenuItem<String>(
                value: service.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'thinkService${service.id.capitalizeEachWord()}'.tr(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'thinkService${service.id.capitalizeEachWord()}Description'
                          .tr(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: !isStreaming && !isDisabled
            ? (value) {
                if (value != null) {
                  onServiceChanged(value);
                }
              }
            : null,
        isDense: true,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

class ThoughtInput extends HookWidget {
  final TextEditingController messageController;
  final bool isStreaming;
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

  const ThoughtInput({
    super.key,
    required this.messageController,
    required this.isStreaming,
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
    final newAttachment = UniversalFile(
      displayName: file.name,
      data: file,
      type: _getFileType(file),
    );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            children: [
              // Attachment preview list
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0,
                        child: child,
                      ),
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
                                isUploading: attachmentProgress.containsKey(
                                  idx,
                                ),
                                onRequestUpload: () => onUploadAttachment(idx),
                                onDelete: () => onDeleteAttachment(idx),
                                onUpdate: (value) {
                                  final newAttachments = [...attachments];
                                  newAttachments[idx] = value;
                                  onAttachmentsChanged(newAttachments);
                                },
                                onMove: (delta) =>
                                    _onMoveAttachment(idx, delta),
                              ),
                            );
                          },
                          separatorBuilder: (_, _) => const Gap(8),
                        ),
                      ).padding(vertical: 12)
                    : const SizedBox.shrink(key: ValueKey('no-attachments')),
              ),
              // Attached messages/posts indicator
              if ((attachedMessages?.isNotEmpty ?? false) ||
                  (attachedPosts?.isNotEmpty ?? false))
                Container(
                  key: ValueKey(
                    'attachments-${attachedMessages?.length ?? 0}-${attachedPosts?.length ?? 0}',
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Symbols.attach_file,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(4),
                      Text(
                        [
                          if (attachedMessages?.isNotEmpty ?? false)
                            '${attachedMessages!.length} message${attachedMessages!.length > 1 ? 's' : ''}',
                          if (attachedPosts?.isNotEmpty ?? false)
                            '${attachedPosts!.length} post${attachedPosts!.length > 1 ? 's' : ''}',
                        ].join(', '),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () {
                            // Note: Since these are final parameters, we can't modify them directly
                            // This would require making the sheet stateful or using a callback
                            // For now, just show the indicator without remove functionality
                          },
                          tooltip: 'clear',
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload menu
                  UploadMenu(
                    items: [
                      UploadMenuItemData(
                        Symbols.add_a_photo,
                        'addPhoto',
                        () => _pickFile(),
                      ),
                      UploadMenuItemData(
                        Symbols.attach_file,
                        'linkAttachment',
                        () => _linkAttachment(context),
                      ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (!isStreaming && !isDisabled)
                          ? (_) => onSend()
                          : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isStreaming ? Symbols.stop : Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: (!isStreaming && !isDisabled) ? onSend : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
         (streamingItems != null && isStreaming) ||
             (thought != null && !isStreaming),
         'Either streamingItems or thought must be provided',
       );

  final SnThinkingThought? thought;
  final bool isStreaming;
  final List<StreamItem>? streamingItems;

  @override
  Widget build(BuildContext context) {
    final isUser = !isStreaming && thought!.role == ThinkingThoughtRole.user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ThoughtHeader(
            agentService: agentService,
            item: thought,
            isStreaming: isStreaming,
            isUser: isUser,
          ),
          const Gap(8),
          // Content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
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

  List<Widget> buildWidgetsList(BuildContext context) {
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
              p.type == ThinkingMessagePartType.text
                  ? p.text ?? ''
                  : p.functionCall ?? p.functionResult,
            );
          }).toList();

    final isAI =
        isStreaming ||
        (!isStreaming && thought!.role == ThinkingThoughtRole.assistant);
    final List<Map<String, String>> proposals = !isStreaming
        ? _extractProposals(
            thought!.parts
                .where((p) => p.type == ThinkingMessagePartType.text)
                .map((p) => p.text ?? '')
                .join(),
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
            resultData: result != null
                ? JsonEncoder.withIndent('  ').convert(result.data.toJson())
                : null,
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
            resultData: JsonEncoder.withIndent(
              '  ',
            ).convert(item.data.toJson()),
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
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ).padding(left: 8),
          ],
        ),
      );
    }

    // The proposals and token info at the end
    if (!isStreaming && proposals.isNotEmpty && isAI) {
      widgets.add(
        ProposalsSection(
          proposals: proposals,
          onProposalAction: _handleProposalAction,
        ),
      );
    }
    if (!isStreaming &&
        isAI &&
        thought != null &&
        !thought!.id.startsWith('error-')) {
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
          child: ThoughtContent(
            isStreaming: isStreaming,
            streamingText: text,
            thought: thought,
          ),
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
      children: files.map((file) {
        final heroTag = 'cloud-file-thought-${file.id}';
        return InkWell(
          onTap: () {
            context.pushTransparentRoute(
              CloudFileLightbox(item: file, heroTag: heroTag),
            );
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: SizedBox(
              width: 200,
              child: CloudFileWidget(
                item: file,
                heroTag: heroTag,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
