import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/models/thought.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/compose_dialog.dart';
import 'package:island/widgets/thought/function_calls_section.dart';
import 'package:island/widgets/thought/proposals_section.dart';
import 'package:island/widgets/thought/reasoning_section.dart';
import 'package:island/widgets/thought/thought_content.dart';
import 'package:island/widgets/thought/thought_header.dart';
import 'package:island/widgets/thought/token_info.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
        !isStreaming && thought!.content != null
            ? _extractProposals(thought!.content!)
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
                    (thought?.chunks.isNotEmpty ?? false) &&
                        thought!.chunks.any(
                          (chunk) =>
                              chunk.type == ThinkingChunkType.functionCall,
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
