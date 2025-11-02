import "dart:convert";
import "dart:math" as math;
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/pods/userinfo.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/response.dart";
import "package:island/widgets/thought/thought_sequence_list.dart";
import "package:island/widgets/thought/thought_shared.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:super_sliver_list/super_sliver_list.dart";
import "package:collection/collection.dart";

part 'think.g.dart';

@riverpod
Future<List<SnThinkingThought>> thoughtSequence(
  Ref ref,
  String sequenceId,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/insight/thought/sequences/$sequenceId',
  );
  return (response.data as List)
      .map((e) => SnThinkingThought.fromJson(e))
      .toList();
}

class ThoughtScreen extends HookConsumerWidget {
  const ThoughtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSequenceId = useState<String?>(null);
    final thoughts =
        selectedSequenceId.value != null
            ? ref.watch(thoughtSequenceProvider(selectedSequenceId.value!))
            : const AsyncValue<List<SnThinkingThought>>.data([]);

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

    // Update local thoughts when provider data changes
    useEffect(() {
      thoughts.whenData((data) {
        // Server returns messages in DESC order (newest first), keep as-is for UI
        localThoughts.value = data;
        // Update topic from the first thought's sequence
        if (data.isNotEmpty && data.first.sequence?.topic != null) {
          currentTopic.value = data.first.sequence!.topic;
        } else {
          currentTopic.value = 'aiThought'.tr();
        }
      });
      return null;
    }, [thoughts]);

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
        sequenceId: selectedSequenceId.value ?? '',
        createdAt: now,
        updatedAt: now,
        sequence:
            selectedSequenceId.value != null
                ? thoughts.value?.firstOrNull?.sequence ??
                    SnThinkingSequence(
                      id: selectedSequenceId.value!,
                      accountId: '',
                      createdAt: now,
                      updatedAt: now,
                    )
                : SnThinkingSequence(
                  id: '',
                  accountId: userInfo.value!.id,
                  createdAt: now,
                  updatedAt: now,
                ),
      );
      localThoughts.value = [userThought, ...localThoughts.value];

      final request = StreamThinkingRequest(
        userMessage: userMessage,
        sequenceId: selectedSequenceId.value,
        accpetProposals: ['post_create'],
        attachedMessages: [], // Message datas
        attachedPosts: [], // ID list for posts
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
                  if (selectedSequenceId.value == null &&
                      aiThought.sequenceId.isNotEmpty) {
                    selectedSequenceId.value = aiThought.sequenceId;
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

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(currentTopic.value ?? 'aiThought'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.history),
            onPressed: () {
              // Show sequence selector
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => ThoughtSequenceSelector(
                      onSequenceSelected: (sequenceId) {
                        selectedSequenceId.value = sequenceId;
                      },
                    ),
              );
            },
          ),
          if (localThoughts.value.isNotEmpty &&
              !isStreaming.value &&
              localThoughts.value.last.role == ThinkingThoughtRole.assistant)
            IconButton(
              icon: const Icon(Symbols.add),
              tooltip: 'thoughtNewConversation'.tr(),
              onPressed: () {
                // Clear current conversation and start new one
                selectedSequenceId.value = null;
                localThoughts.value = [];
                currentTopic.value = 'aiThought'.tr();
                messageController.clear();
              },
            ),
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          // Thoughts list
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Expanded(
                    child: thoughts.when(
                      data:
                          (thoughtList) => SuperListView.builder(
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
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, _) => ResponseErrorWidget(
                            error: error,
                            onRetry:
                                () =>
                                    selectedSequenceId.value != null
                                        ? ref.invalidate(
                                          thoughtSequenceProvider(
                                            selectedSequenceId.value!,
                                          ),
                                        )
                                        : null,
                          ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
