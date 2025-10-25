import "dart:async";
import "dart:convert";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/content/markdown.dart";
import "package:island/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:super_sliver_list/super_sliver_list.dart";

// State management providers
final thoughtSequencesProvider = FutureProvider<List<SnThinkingSequence>>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/insight/thought/sequences');
  return (response.data as List)
      .map((e) => SnThinkingSequence.fromJson(e))
      .toList();
});

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
    final sequences = ref.watch(thoughtSequencesProvider);
    final selectedSequenceId = useState<String?>(null);
    final thoughts =
        selectedSequenceId.value != null
            ? ref.watch(thoughtSequenceProvider(selectedSequenceId.value!))
            : const AsyncValue<List<SnThinkingThought>>.data([]);

    final localThoughts = useState<List<SnThinkingThought>>([]);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isStreaming = useState(false);
    final streamingText = useState<String>('');

    final listController = useMemoized(() => ListController(), []);

    // Update local thoughts when provider data changes
    useEffect(() {
      thoughts.whenData((data) => localThoughts.value = data);
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
      final userThought = SnThinkingThought(
        id: 'temp-user-${DateTime.now().millisecondsSinceEpoch}',
        content: userMessage,
        files: [],
        role: ThinkingThoughtRole.user,
        sequenceId: selectedSequenceId.value ?? '',
        sequence:
            selectedSequenceId.value != null
                ? thoughts.value?.firstOrNull?.sequence ??
                    SnThinkingSequence(
                      id: selectedSequenceId.value!,
                      accountId: '',
                    )
                : SnThinkingSequence(id: '', accountId: ''),
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
              final lines = buffer.toString().split('\n');
              final lastLine = lines.lastWhere(
                (line) => line.trim().isNotEmpty,
              );
              final responseJson = jsonDecode(lastLine);
              final aiThought = SnThinkingThought.fromJson(responseJson);
              localThoughts.value = [aiThought, ...localThoughts.value];
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
      } catch (error) {
        isStreaming.value = false;
        showErrorAlert(error);
      }
    }

    Widget thoughtItem(SnThinkingThought thought) => Container(
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
                thought.role == ThinkingThoughtRole.assistant
                    ? 'AI Assistant'
                    : 'You',
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
        title: const Text('AI Thought'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.history),
            onPressed: () {
              // Show sequence selector
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => sequences.when(
                      data:
                          (seqs) => ListView.builder(
                            itemCount: seqs.length,
                            itemBuilder: (context, index) {
                              final seq = seqs[index];
                              return ListTile(
                                title: Text(
                                  seq.topic ?? 'Untitled Conversation',
                                ),
                                onTap: () {
                                  selectedSequenceId.value = seq.id;
                                  Navigator.of(context).pop();
                                },
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
                                () => ref.invalidate(thoughtSequencesProvider),
                          ),
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
                    padding: const EdgeInsets.only(bottom: 16),
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
                      return thoughtItem(thought);
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: isStreaming.value ? null : sendMessage,
                  icon: Icon(isStreaming.value ? Symbols.stop : Symbols.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
