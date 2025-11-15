import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/thought.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/compose_sheet.dart';
import 'package:island/widgets/thought/function_calls_section.dart';
import 'package:island/widgets/thought/proposals_section.dart';
import 'package:island/widgets/thought/reasoning_section.dart';
import 'package:island/widgets/thought/thought_content.dart';
import 'package:island/widgets/thought/thought_header.dart';
import 'package:island/widgets/thought/token_info.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ThoughtChatState {
  final ValueNotifier<String?> sequenceId;
  final ValueNotifier<List<SnThinkingThought>> localThoughts;
  final ValueNotifier<String?> currentTopic;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final ValueNotifier<bool> isStreaming;
  final ValueNotifier<List<SnThinkingMessagePart>> streamingParts;
  final ValueNotifier<List<String>> reasoningChunks;
  final ListController listController;
  final ValueNotifier<ValueNotifier<double>> bottomGradientNotifier;
  final Future<void> Function() sendMessage;

  ThoughtChatState({
    required this.sequenceId,
    required this.localThoughts,
    required this.currentTopic,
    required this.messageController,
    required this.scrollController,
    required this.isStreaming,
    required this.streamingParts,
    required this.reasoningChunks,
    required this.listController,
    required this.bottomGradientNotifier,
    required this.sendMessage,
  });
}

ThoughtChatState useThoughtChat(
  WidgetRef ref, {
  String? initialSequenceId,
  List<SnThinkingThought>? initialThoughts,
  String? initialTopic,
  List<Map<String, dynamic>> attachedMessages = const [],
  List<String> attachedPosts = const [],
  VoidCallback? onSequenceIdChanged,
}) {
  final sequenceId = useState<String?>(initialSequenceId);
  final localThoughts = useState<List<SnThinkingThought>>(
    initialThoughts ?? [],
  );
  final currentTopic = useState<String?>(initialTopic ?? 'aiThought'.tr());

  final messageController = useTextEditingController();
  final scrollController = useScrollController();
  final isStreaming = useState(false);
  final streamingParts = useState<List<SnThinkingMessagePart>>([]);
  final reasoningChunks = useState<List<String>>([]);

  final listController = useMemoized(() => ListController(), []);

  // Scroll animation notifiers
  final bottomGradientNotifier = useState(ValueNotifier<double>(0.0));

  // Scroll to bottom when thoughts change or streaming state changes
  useEffect(() {
    if (localThoughts.value.isNotEmpty || isStreaming.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
    return null;
  }, [localThoughts.value.length, isStreaming.value]);

  // Add scroll listener for gradient animations
  useEffect(() {
    void onScroll() {
      // Update gradient animations
      final pixels = scrollController.position.pixels;

      // Bottom gradient: appears when not at bottom (pixels > 0)
      bottomGradientNotifier.value.value = (pixels / 500.0).clamp(0.0, 1.0);
    }

    scrollController.addListener(onScroll);
    return () => scrollController.removeListener(onScroll);
  }, [scrollController]);

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();

    // Add user message to local thoughts
    final userInfo = ref.read(userInfoProvider);
    final now = DateTime.now();
    final userThought = SnThinkingThought(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: userMessage,
        ),
      ],
      files: [],
      role: ThinkingThoughtRole.user,
      sequenceId: sequenceId.value ?? '',
      createdAt: now,
      updatedAt: now,
      sequence: SnThinkingSequence(
        id: sequenceId.value ?? '',
        accountId: userInfo.value!.id,
        createdAt: now,
        updatedAt: now,
      ),
    );
    localThoughts.value = [userThought, ...localThoughts.value];

    final request = StreamThinkingRequest(
      userMessage: userMessage,
      sequenceId: sequenceId.value,
      accpetProposals: ['post_create'],
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    try {
      isStreaming.value = true;
      streamingParts.value = [];
      reasoningChunks.value = [];

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/insight/thought',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          sendTimeout: Duration(minutes: 1),
          receiveTimeout: Duration(minutes: 1),
        ),
      );

      final stream = response.data.stream;
      final lineBuffer = StringBuffer();

      stream.listen(
        (data) {
          final chunk = utf8.decode(data);
          lineBuffer.write(chunk);
          final lines = lineBuffer.toString().split('\n');
          lineBuffer.clear();
          lineBuffer.write(lines.last); // keep incomplete line

          for (final line in lines.sublist(0, lines.length - 1)) {
            if (line.trim().isEmpty) continue;
            try {
              if (line.startsWith('data: ')) {
                final jsonStr = line.substring(6);
                final event = jsonDecode(jsonStr);
                final type = event['type'];
                final eventData = event['data'];
                if (type == 'text') {
                  if (streamingParts.value.isNotEmpty &&
                      streamingParts.value.last.type ==
                          ThinkingMessagePartType.text) {
                    final last = streamingParts.value.last;
                    final newParts = [...streamingParts.value];
                    newParts[newParts.length - 1] = last.copyWith(
                      text: (last.text ?? '') + eventData,
                    );
                    streamingParts.value = newParts;
                  } else {
                    streamingParts.value = [
                      ...streamingParts.value,
                      SnThinkingMessagePart(
                        type: ThinkingMessagePartType.text,
                        text: eventData,
                      ),
                    ];
                  }
                } else if (type == 'function_call') {
                  streamingParts.value = [
                    ...streamingParts.value,
                    SnThinkingMessagePart(
                      type: ThinkingMessagePartType.functionCall,
                      functionCall: SnFunctionCall.fromJson(eventData),
                    ),
                  ];
                } else if (type == 'function_result') {
                  streamingParts.value = [
                    ...streamingParts.value,
                    SnThinkingMessagePart(
                      type: ThinkingMessagePartType.functionResult,
                      functionResult: SnFunctionResult.fromJson(eventData),
                    ),
                  ];
                } else if (type == 'reasoning') {
                  reasoningChunks.value = [...reasoningChunks.value, eventData];
                }
              } else if (line.startsWith('topic: ')) {
                final jsonStr = line.substring(7);
                final event = jsonDecode(jsonStr);
                currentTopic.value = event['data'];
              } else if (line.startsWith('thought: ')) {
                final jsonStr = line.substring(9);
                final event = jsonDecode(jsonStr);
                final aiThought = SnThinkingThought.fromJson(event['data']);
                localThoughts.value = [aiThought, ...localThoughts.value];
                if (sequenceId.value == null &&
                    aiThought.sequenceId.isNotEmpty) {
                  sequenceId.value = aiThought.sequenceId;
                  onSequenceIdChanged?.call();
                }
                isStreaming.value = false;
              }
            } catch (e) {
              // Ignore parsing errors for individual events
            }
          }
        },
        onDone: () {
          if (isStreaming.value) {
            isStreaming.value = false;
            // Add error thought to the list for incomplete response
            final now = DateTime.now();
            final errorThought = SnThinkingThought(
              id: 'error-${DateTime.now().millisecondsSinceEpoch}',
              parts: [
                SnThinkingMessagePart(
                  type: ThinkingMessagePartType.text,
                  text: 'Error: ${'thoughtParseError'.tr()}',
                ),
              ],
              files: [],
              role: ThinkingThoughtRole.assistant,
              sequenceId: sequenceId.value ?? '',
              createdAt: now,
              updatedAt: now,
              sequence: SnThinkingSequence(
                id: sequenceId.value ?? '',
                accountId: '',
                createdAt: now,
                updatedAt: now,
              ),
            );
            localThoughts.value = [errorThought, ...localThoughts.value];
          }
        },
        onError: (error) {
          isStreaming.value = false;

          // Add error thought to the list
          final now = DateTime.now();
          final errorMessage =
              error is DioException && error.response?.data is ResponseBody
                  ? 'toughtParseError'.tr()
                  : error.toString();
          final errorThought = SnThinkingThought(
            id: 'error-${DateTime.now().millisecondsSinceEpoch}',
            parts: [
              SnThinkingMessagePart(
                type: ThinkingMessagePartType.text,
                text: 'Error: $errorMessage',
              ),
            ],
            files: [],
            role: ThinkingThoughtRole.assistant,
            sequenceId: sequenceId.value ?? '',
            createdAt: now,
            updatedAt: now,
            sequence: SnThinkingSequence(
              id: sequenceId.value ?? '',
              accountId: '',
              createdAt: now,
              updatedAt: now,
            ),
          );
          localThoughts.value = [errorThought, ...localThoughts.value];
        },
      );

      messageController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (error) {
      isStreaming.value = false;

      // Add error thought to the list for initial request errors
      final now = DateTime.now();
      final userInfo = ref.read(userInfoProvider);
      final errorMessage = error.toString();
      final errorThought = SnThinkingThought(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        parts: [
          SnThinkingMessagePart(
            type: ThinkingMessagePartType.text,
            text: 'Error: $errorMessage',
          ),
        ],
        files: [],
        role: ThinkingThoughtRole.assistant,
        sequenceId: sequenceId.value ?? '',
        createdAt: now,
        updatedAt: now,
        sequence: SnThinkingSequence(
          id: sequenceId.value ?? '',
          accountId: userInfo.value!.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
      localThoughts.value = [errorThought, ...localThoughts.value];
    }
  }

  return ThoughtChatState(
    sequenceId: sequenceId,
    localThoughts: localThoughts,
    currentTopic: currentTopic,
    messageController: messageController,
    scrollController: scrollController,
    isStreaming: isStreaming,
    streamingParts: streamingParts,
    reasoningChunks: reasoningChunks,
    listController: listController,
    bottomGradientNotifier: bottomGradientNotifier,
    sendMessage: sendMessage,
  );
}

class ThoughtChatInterface extends HookConsumerWidget {
  final List<SnThinkingThought>? initialThoughts;
  final String? initialTopic;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtChatInterface({
    super.key,
    this.initialThoughts,
    this.initialTopic,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = useThoughtChat(
      ref,
      initialThoughts: initialThoughts,
      initialTopic: initialTopic,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    return Stack(
      children: [
        // Thoughts list
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: SuperListView.builder(
                    listController: chatState.listController,
                    controller: chatState.scrollController,
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom:
                          MediaQuery.of(context).padding.bottom +
                          80, // Leave space for thought input
                    ),
                    reverse: true,
                    itemCount:
                        chatState.localThoughts.value.length +
                        (chatState.isStreaming.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatState.isStreaming.value && index == 0) {
                        final streamingText = chatState.streamingParts.value
                            .where(
                              (p) => p.type == ThinkingMessagePartType.text,
                            )
                            .map((p) => p.text ?? '')
                            .join('');
                        final streamingFunctionCalls =
                            chatState.streamingParts.value
                                .where(
                                  (p) =>
                                      p.type ==
                                      ThinkingMessagePartType.functionCall,
                                )
                                .map(
                                  (p) => JsonEncoder.withIndent(
                                    '  ',
                                  ).convert(p.functionCall?.toJson() ?? {}),
                                )
                                .toList();
                        return ThoughtItem(
                          isStreaming: true,
                          streamingText: streamingText,
                          reasoningChunks: chatState.reasoningChunks.value,
                          streamingFunctionCalls: streamingFunctionCalls,
                        );
                      }
                      final thoughtIndex =
                          chatState.isStreaming.value ? index - 1 : index;
                      final thought =
                          chatState.localThoughts.value[thoughtIndex];
                      return ThoughtItem(
                        thought: thought,
                        thoughtIndex: thoughtIndex,
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
          animation: chatState.bottomGradientNotifier.value,
          builder:
              (context, child) => Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: chatState.bottomGradientNotifier.value.value,
                  child: Container(
                    height: math.min(
                      MediaQuery.of(context).size.height * 0.1,
                      128,
                    ),
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
              constraints: BoxConstraints(maxWidth: 640),
              child: ThoughtInput(
                messageController: chatState.messageController,
                isStreaming: chatState.isStreaming.value,
                onSend: chatState.sendMessage,
                attachedMessages: attachedMessages,
                attachedPosts: attachedPosts,
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

class ThoughtInput extends HookWidget {
  final TextEditingController messageController;
  final bool isStreaming;
  final VoidCallback onSend;
  final List<Map<String, dynamic>>? attachedMessages;
  final List<String>? attachedPosts;

  const ThoughtInput({
    super.key,
    required this.messageController,
    required this.isStreaming,
    required this.onSend,
    this.attachedMessages,
    this.attachedPosts,
  });

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
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      keyboardType: TextInputType.multiline,
                      enabled: !isStreaming,
                      decoration: InputDecoration(
                        hintText:
                            (isStreaming
                                    ? 'thoughtStreamingHint'
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
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isStreaming ? Symbols.stop : Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: onSend,
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
  const ThoughtItem({
    super.key,
    this.thought,
    this.thoughtIndex,
    this.isStreaming = false,
    this.streamingText = '',
    this.reasoningChunks = const [],
    this.streamingFunctionCalls = const [],
  }) : assert(
         (thought != null && !isStreaming) || (thought == null && isStreaming),
         'Either thought or streaming parameters must be provided',
       );

  final SnThinkingThought? thought;
  final int? thoughtIndex;
  final bool isStreaming;
  final String streamingText;
  final List<String> reasoningChunks;
  final List<String> streamingFunctionCalls;

  @override
  Widget build(BuildContext context) {
    final isUser = !isStreaming && thought!.role == ThinkingThoughtRole.user;
    final isAI =
        isStreaming ||
        (!isStreaming && thought!.role == ThinkingThoughtRole.assistant);

    final List<Map<String, String>> proposals =
        !isStreaming
            ? _extractProposals(
              thought!.parts
                  .where((p) => p.type == ThinkingMessagePartType.text)
                  .map((p) => p.text ?? '')
                  .join(''),
            )
            : [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ThoughtHeader(isStreaming: isStreaming, isUser: isUser),
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
              children: [
                // Main content
                ThoughtContent(
                  isStreaming: isStreaming,
                  streamingText: streamingText,
                  thought: thought,
                ),

                // Reasoning chunks (streaming only)
                if (reasoningChunks.isNotEmpty)
                  ReasoningSection(reasoningChunks: reasoningChunks),

                // Function calls
                if (streamingFunctionCalls.isNotEmpty ||
                    (thought?.parts.isNotEmpty ?? false) &&
                        thought!.parts.any(
                          (part) =>
                              part.type == ThinkingMessagePartType.functionCall,
                        ))
                  FunctionCallsSection(
                    isStreaming: isStreaming,
                    streamingFunctionCalls: streamingFunctionCalls,
                    thought: thought,
                  ),

                // Token count and model name (for completed AI thoughts only)
                if (!isStreaming && isAI && thought != null)
                  TokenInfo(thought: thought!),

                // Proposals (for completed AI thoughts only)
                if (!isStreaming && proposals.isNotEmpty && isAI)
                  ProposalsSection(
                    proposals: proposals,
                    onProposalAction: _handleProposalAction,
                  ),

                if (isStreaming && isAI) LinearProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
