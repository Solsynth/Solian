import "dart:convert";
import "dart:math" as math;
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/pods/userinfo.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/content/sheet.dart";
import "package:island/widgets/thought/thought_shared.dart";
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
    final sequenceId = useState<String?>(null);
    final localThoughts = useState<List<SnThinkingThought>>([]);
    final currentTopic = useState<String?>('aiThought'.tr());

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isStreaming = useState(false);
    final streamingText = useState<String>('');
    final functionCalls = useState<List<String>>([]);
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
                  if (sequenceId.value == null &&
                      aiThought.sequenceId.isNotEmpty) {
                    sequenceId.value = aiThought.sequenceId;
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
      child: Stack(
        children: [
          // Thoughts list
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Expanded(
                    child: SuperListView.builder(
                      listController: listController,
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        top: 16,
                        bottom:
                            MediaQuery.of(context).padding.bottom +
                            80, // Leave space for thought input
                      ),
                      reverse: true,
                      itemCount:
                          localThoughts.value.length +
                          (isStreaming.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isStreaming.value && index == 0) {
                          return ThoughtItem(
                            isStreaming: true,
                            streamingText: streamingText.value,
                            reasoningChunks: reasoningChunks.value,
                            streamingFunctionCalls: functionCalls.value,
                          );
                        }
                        final thoughtIndex =
                            isStreaming.value ? index - 1 : index;
                        final thought = localThoughts.value[thoughtIndex];
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
            animation: bottomGradientNotifier.value,
            builder:
                (context, child) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: bottomGradientNotifier.value.value,
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
                  messageController: messageController,
                  isStreaming: isStreaming.value,
                  onSend: sendMessage,
                  attachedMessages: attachedMessages,
                  attachedPosts: attachedPosts,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
