import "dart:convert";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/pods/userinfo.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/content/sheet.dart";
import "package:island/widgets/thought/shared_widgets.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:super_sliver_list/super_sliver_list.dart";

class ThoughtSheet extends HookConsumerWidget {
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtSheet({
    super.key,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  static Future<void> show(
    BuildContext context, {
    List<Map<String, dynamic>> attachedMessages = const [],
    List<String> attachedPosts = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => ThoughtSheet(
            attachedMessages: attachedMessages,
            attachedPosts: attachedPosts,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localThoughts = useState<List<SnThinkingThought>>([]);
    final currentTopic = useState<String?>('aiThought'.tr());

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isStreaming = useState(false);
    final streamingText = useState<String>('');
    final functionCalls = useState<List<String>>([]);
    final reasoningChunks = useState<List<String>>([]);

    final listController = useMemoized(() => ListController(), []);

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

    void sendMessage() async {
      if (messageController.text.trim().isEmpty) return;

      final userMessage = messageController.text.trim();

      // Add user message to local thoughts
      final userInfo = ref.read(userInfoProvider);
      final now = DateTime.now();
      final userThought = SnThinkingThought(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        content: userMessage,
        files: [],
        role: ThinkingThoughtRole.user,
        sequenceId: '',
        createdAt: now,
        updatedAt: now,
        sequence: SnThinkingSequence(
          id: '',
          accountId: userInfo.value!.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
      localThoughts.value = [userThought, ...localThoughts.value];

      final request = StreamThinkingRequest(
        userMessage: userMessage,
        sequenceId: null,
        accpetProposals: ['post_create'],
        attachedMessages: attachedMessages,
        attachedPosts: attachedPosts,
      );

      try {
        isStreaming.value = true;
        streamingText.value = '';
        functionCalls.value = [];
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
                    streamingText.value += eventData;
                  } else if (type == 'function_call') {
                    functionCalls.value = [
                      ...functionCalls.value,
                      JsonEncoder.withIndent('  ').convert(eventData),
                    ];
                  } else if (type == 'reasoning') {
                    reasoningChunks.value = [
                      ...reasoningChunks.value,
                      eventData,
                    ];
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
              showErrorAlert('thoughtParseError'.tr());
            }
          },
          onError: (error) {
            isStreaming.value = false;
            if (error is DioException && error.response?.data is ResponseBody) {
              showErrorAlert('toughtParseError'.tr());
            } else {
              showErrorAlert(error);
            }
          },
        );

        messageController.clear();
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (error) {
        isStreaming.value = false;
        showErrorAlert(error);
      }
    }

    return SheetScaffold(
      titleText: currentTopic.value ?? 'aiThought'.tr(),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: SuperListView.builder(
                  listController: listController,
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  reverse: true,
                  itemCount:
                      localThoughts.value.length + (isStreaming.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isStreaming.value && index == 0) {
                      return streamingThoughtItem(
                        streamingText.value,
                        reasoningChunks.value,
                        functionCalls.value,
                        context,
                      );
                    }
                    final thoughtIndex = isStreaming.value ? index - 1 : index;
                    final thought = localThoughts.value[thoughtIndex];
                    return thoughtItem(thought, thoughtIndex, context);
                  },
                ),
              ),
              Container(
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Column(
                      children: [
                        if (attachedMessages.isNotEmpty ||
                            attachedPosts.isNotEmpty)
                          Container(
                            key: ValueKey(
                              'attachments-${attachedMessages.length}-${attachedPosts.length}',
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: 4,
                              bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Symbols.attach_file,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const Gap(4),
                                Text(
                                  [
                                    if (attachedMessages.isNotEmpty)
                                      '${attachedMessages.length} message${attachedMessages.length > 1 ? 's' : ''}',
                                    if (attachedPosts.isNotEmpty)
                                      '${attachedPosts.length} post${attachedPosts.length > 1 ? 's' : ''}',
                                  ].join(', '),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
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
                                    tooltip: 'clear'.tr(),
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
                                enabled: !isStreaming.value,
                                decoration: InputDecoration(
                                  hintText:
                                      isStreaming.value
                                          ? 'thoughtStreamingHint'.tr()
                                          : 'thoughtInputHint'.tr(),
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
                                onSubmitted: (_) => sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isStreaming.value ? Symbols.stop : Icons.send,
                              ),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: sendMessage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
