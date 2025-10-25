import "dart:async";
import "dart:convert";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/pods/userinfo.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/content/markdown.dart";
import "package:island/widgets/response.dart";
import "package:island/widgets/thought/thought_sequence_list.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:super_sliver_list/super_sliver_list.dart";

final thoughtSequenceProvider =
    FutureProvider.family<List<SnThinkingThought>, String>((
      ref,
      sequenceId,
    ) async {
      final apiClient = ref.watch(apiClientProvider);
      final response = await apiClient.get(
        '/insight/thought/sequences/$sequenceId',
      );
      return (response.data as List)
          .map((e) => SnThinkingThought.fromJson(e))
          .toList();
    });

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
    final currentTopic = useState<String?>('AI Thought');

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isStreaming = useState(false);
    final streamingText = useState<String>('');

    final listController = useMemoized(() => ListController(), []);

    // Update local thoughts when provider data changes
    useEffect(() {
      thoughts.whenData((data) {
        localThoughts.value = data;
        // Update topic from the first thought's sequence
        if (data.isNotEmpty && data.first.sequence?.topic != null) {
          currentTopic.value = data.first.sequence!.topic;
        } else {
          currentTopic.value = 'AI Thought';
        }
      });
      return null;
    }, [thoughts]);

    // Scroll to bottom when thoughts change or streaming state changes
    useEffect(() {
      if (localThoughts.value.isNotEmpty || isStreaming.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
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
      );

      try {
        isStreaming.value = true;
        streamingText.value = '';

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
        final completer = Completer<String>();
        final buffer = StringBuffer();

        stream.listen(
          (data) {
            final chunk = utf8.decode(data);
            buffer.write(chunk);
            streamingText.value = buffer.toString();
          },
          onDone: () {
            completer.complete(buffer.toString());
            isStreaming.value = false;
            // Parse the response and add AI thought
            try {
              final lines =
                  buffer
                      .toString()
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .toList();
              final lastLine = lines.last;
              final responseJson = jsonDecode(lastLine);
              final aiThought = SnThinkingThought.fromJson(responseJson);

              // Check for topic in second last line
              String? topic;
              if (lines.length >= 2) {
                final secondLastLine = lines[lines.length - 2];
                final topicMatch = RegExp(
                  r'<topic>(.*)</topic>',
                ).firstMatch(secondLastLine);
                if (topicMatch != null) {
                  topic = topicMatch.group(1);
                }
              }

              // Update sequence topic if found
              if (topic != null && aiThought.sequence != null) {
                final updatedSequence = aiThought.sequence!.copyWith(
                  topic: topic,
                );
                final updatedThought = aiThought.copyWith(
                  sequence: updatedSequence,
                );
                localThoughts.value = [updatedThought, ...localThoughts.value];

                // Also update topic in existing thoughts with same sequenceId
                localThoughts.value =
                    localThoughts.value.map((thought) {
                      if (thought.sequenceId == aiThought.sequenceId &&
                          thought.sequence != null) {
                        return thought.copyWith(
                          sequence: thought.sequence!.copyWith(topic: topic),
                        );
                      }
                      return thought;
                    }).toList();

                // Update current topic
                currentTopic.value = topic;

                // Update selected sequence ID to provide context for AI
                if (selectedSequenceId.value != aiThought.sequenceId) {
                  selectedSequenceId.value = aiThought.sequenceId;
                }
              } else {
                localThoughts.value = [aiThought, ...localThoughts.value];

                // Update selected sequence ID if it was null (new conversation)
                if (selectedSequenceId.value == null &&
                    aiThought.sequenceId.isNotEmpty) {
                  selectedSequenceId.value = aiThought.sequenceId;
                }
              }
            } catch (e) {
              showErrorAlert('Failed to parse AI response');
            }
          },
          onError: (error) {
            completer.completeError(error);
            isStreaming.value = false;
            // Handle streaming response errors differently
            if (error is DioException && error.response?.data is ResponseBody) {
              // For streaming responses, show a generic error message
              showErrorAlert('Failed to get AI response. Please try again.');
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

    Widget thoughtItem(SnThinkingThought thought, int index) {
      final key = Key('thought-${thought.id}');

      final thoughtWidget = Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              thought.role == ThinkingThoughtRole.assistant
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  thought.role == ThinkingThoughtRole.assistant
                      ? Symbols.smart_toy
                      : Symbols.person,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  thought.role == ThinkingThoughtRole.assistant ? 'SN 酱' : '您',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const Gap(8),
            if (thought.content != null)
              MarkdownTextContent(
                content: thought.content!,
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      );

      return TweenAnimationBuilder<double>(
        key: key,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(
          milliseconds: 400 + (index % 5) * 50,
        ), // Staggered delay
        curve: Curves.easeOutCubic,
        builder: (context, animationValue, child) {
          return Transform.translate(
            offset: Offset(
              0,
              20 * (1 - animationValue),
            ), // Slide up from bottom
            child: Opacity(opacity: animationValue, child: child),
          );
        },
        child: thoughtWidget,
      );
    }

    Widget streamingThoughtItem() => Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.smart_toy, size: 20),
              const Gap(8),
              Text(
                'AI Assistant',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
          const Gap(8),
          MarkdownTextContent(
            content: streamingText.value,
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );

    return AppScaffold(
      appBar: AppBar(
        title: Text(currentTopic.value ?? 'AI Thought'),
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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: thoughts.when(
              data:
                  (thoughtList) => SuperListView.builder(
                    listController: listController,
                    controller: scrollController,
                    padding: const EdgeInsets.only(top: 16),
                    reverse: true,
                    itemCount:
                        localThoughts.value.length +
                        (isStreaming.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isStreaming.value && index == 0) {
                        return streamingThoughtItem();
                      }
                      final thoughtIndex =
                          isStreaming.value ? index - 1 : index;
                      final thought = localThoughts.value[thoughtIndex];
                      return thoughtItem(thought, thoughtIndex);
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
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
                                  ? 'Sn-chan is thinking...'
                                  : 'Ask me anything...',
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
                      icon: Icon(isStreaming.value ? Symbols.stop : Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
