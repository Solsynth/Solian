import "dart:convert";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:google_fonts/google_fonts.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/pods/userinfo.dart";
import "package:island/services/time.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/content/markdown.dart";
import "package:island/widgets/post/compose_dialog.dart";
import "package:island/widgets/response.dart";
import "package:island/widgets/thought/thought_sequence_list.dart";
import "package:island/screens/posts/compose.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:styled_widget/styled_widget.dart";
import "package:super_sliver_list/super_sliver_list.dart";
import "package:markdown/markdown.dart" as markdown;
import "package:markdown_widget/markdown_widget.dart";
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
    // Extract proposals from text content
    List<Map<String, String>> extractProposals(String content) {
      final proposalRegex = RegExp(
        r'<proposal\s+type="([^"]+)">(.*?)<\/proposal>',
        dotAll: true,
      );
      final matches = proposalRegex.allMatches(content);
      return matches.map((match) {
        return {'type': match.group(1)!, 'content': match.group(2)!};
      }).toList();
    }

    void handleProposalAction(
      BuildContext context,
      Map<String, String> proposal,
    ) {
      switch (proposal['type']) {
        case 'post_create':
          // Show post creation dialog with the proposal content
          PostComposeDialog.show(
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

    Widget buildChunkTiles(List<SnThinkingChunk> chunks) {
      return Column(
        children: [
          ...chunks
              .where((chunk) => chunk.type == ThinkingChunkType.reasoning)
              .map(
                (chunk) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        'Reasoning',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            chunk.data?['content'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ...chunks
              .where((chunk) => chunk.type == ThinkingChunkType.functionCall)
              .map(
                (chunk) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Function Call',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SelectableText(
                            JsonEncoder.withIndent('  ').convert(chunk.data),
                            style: GoogleFonts.robotoMono(),
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

    Widget thoughtItem(SnThinkingThought thought, int index) {
      final key = Key('thought-${thought.id}');

      // Extract proposals from thought content
      final proposals =
          thought.content != null ? extractProposals(thought.content!) : [];

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
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    spacing: 8,
                    children: [
                      Text(
                        thought.role == ThinkingThoughtRole.assistant
                            ? 'thoughtAiName'.tr()
                            : 'thoughtUserName'.tr(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Tooltip(
                        message: thought.createdAt.formatSystem(),
                        child: Text(
                          thought.createdAt.formatRelative(context),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (thought.role == ThinkingThoughtRole.assistant)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: IconButton(
                      visualDensity: VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(Symbols.content_copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: thought.content ?? ''),
                        );
                        showSnackBar('copiedToClipboard'.tr());
                      },
                    ),
                  ),
              ],
            ),
            if (thought.chunks.isNotEmpty) ...[
              buildChunkTiles(thought.chunks),
              const Gap(8),
            ],
            if (thought.content != null)
              MarkdownTextContent(
                isSelectable: true,
                content: thought.content!,
                extraBlockSyntaxList: [ProposalBlockSyntax()],
                textStyle: Theme.of(context).textTheme.bodyMedium,
                extraGenerators: [
                  ProposalGenerator(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    borderColor: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            if (thought.role == ThinkingThoughtRole.assistant &&
                (thought.tokenCount != null || thought.modelName != null)) ...[
              const Gap(8),
              Row(
                children: [
                  if (thought.modelName != null) ...[
                    const Icon(Symbols.neurology, size: 16),
                    const Gap(4),
                    Text(
                      '${thought.modelName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(16),
                  ],
                  if (thought.tokenCount != null)
                    ...([
                      const Icon(Symbols.token, size: 16),
                      const Gap(4),
                      Text(
                        '${thought.tokenCount} tokens',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ]),
                ],
              ),
            ],
            if (proposals.isNotEmpty &&
                thought.role == ThinkingThoughtRole.assistant) ...[
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    proposals.map((proposal) {
                      return ElevatedButton.icon(
                        onPressed:
                            () => handleProposalAction(context, proposal),
                        icon: Icon(switch (proposal['type']) {
                          'post_create' => Symbols.add,
                          _ => Symbols.lightbulb,
                        }, size: 16),
                        label: Text(switch (proposal['type']) {
                          'post_create' => 'Create Post',
                          _ => proposal['type'] ?? 'Action',
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
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
                'thoughtAiName'.tr(),
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
            extraBlockSyntaxList: [ProposalBlockSyntax()],
            extraGenerators: [
              ProposalGenerator(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                borderColor: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
          if (reasoningChunks.value.isNotEmpty ||
              functionCalls.value.isNotEmpty) ...[
            const Gap(8),
            Column(
              children: [
                ...reasoningChunks.value.map(
                  (chunk) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(
                          'Reasoning',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              chunk,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...functionCalls.value.map(
                  (call) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          'Function Call',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SelectableText(
                              call,
                              style: GoogleFonts.robotoMono(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

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
      body: Center(
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
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
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
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
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

class ProposalBlockSyntax extends markdown.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^<proposal', caseSensitive: false);

  @override
  bool canParse(markdown.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  bool canEndBlock(markdown.BlockParser parser) {
    return parser.current.content.contains('</proposal>');
  }

  @override
  markdown.Node parse(markdown.BlockParser parser) {
    final childLines = <String>[];

    // Extract type from opening tag
    final openingLine = parser.current.content;
    final attrsMatch = RegExp(
      r'<proposal(\s[^>]*)?>',
      caseSensitive: false,
    ).firstMatch(openingLine);
    final attrs = attrsMatch?.group(1) ?? '';
    final typeMatch = RegExp(r'type="([^"]*)"').firstMatch(attrs);
    final type = typeMatch?.group(1) ?? '';

    // Collect all lines until closing tag
    while (!parser.isDone) {
      childLines.add(parser.current.content);
      if (canEndBlock(parser)) {
        parser.advance();
        break;
      }
      parser.advance();
    }

    // Extract content between tags
    final fullContent = childLines.join('\n');
    final contentMatch = RegExp(
      r'<proposal[^>]*>(.*?)</proposal>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(fullContent);
    final content = contentMatch?.group(1)?.trim() ?? '';

    final element = markdown.Element('proposal', [markdown.Text(content)])
      ..attributes['type'] = type;

    return element;
  }
}

class ProposalGenerator extends SpanNodeGeneratorWithTag {
  ProposalGenerator({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
  }) : super(
         tag: 'proposal',
         generator: (
           markdown.Element element,
           MarkdownConfig config,
           WidgetVisitor visitor,
         ) {
           return ProposalSpanNode(
             text: element.textContent,
             type: element.attributes['type'] ?? '',
             backgroundColor: backgroundColor,
             foregroundColor: foregroundColor,
             borderColor: borderColor,
           );
         },
       );
}

class ProposalSpanNode extends SpanNode {
  final String text;
  final String type;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  ProposalSpanNode({
    required this.text,
    required this.type,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Row(
              spacing: 6,
              children: [
                Icon(Symbols.lightbulb, size: 16, color: foregroundColor),
                Text(
                  'SN-chan suggest you to ${type.split('_').reversed.join(' ')}',
                ).fontSize(13).opacity(0.8),
              ],
            ).padding(top: 3, bottom: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
