import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:island/models/thought.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/compose_dialog.dart';
import 'package:island/widgets/thought/thought_proposal.dart';
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
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
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

    final proposals =
        !isStreaming && thought!.content != null
            ? _extractProposals(thought!.content!)
            : [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (!isStreaming) ...[
            Row(
              spacing: 6,
              children: [
                Icon(
                  isUser ? Symbols.person : Symbols.smart_toy,
                  size: 16,
                  color:
                      isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                  fill: 1,
                ),
                Text(
                  isUser ? 'thoughtUserName'.tr() : 'aiThought'.tr(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const Gap(8),
          ] else ...[
            Text(
              'aiThought'.tr(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(8),
          ],
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
              children: [
                // Main content
                if (isStreaming) ...[
                  // Streaming text with spinner
                  if (streamingText.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SelectableText(
                            streamingText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  // Regular thought content
                  if (thought!.content != null && thought!.content!.isNotEmpty)
                    MarkdownTextContent(
                      isSelectable: true,
                      content: thought!.content!,
                      extraBlockSyntaxList: [ProposalBlockSyntax()],
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      extraGenerators: [
                        ProposalGenerator(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                          borderColor: Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                ],

                // Reasoning chunks (streaming only)
                if (isStreaming && reasoningChunks.isNotEmpty) ...[
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.psychology,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(4),
                            Text(
                              'reasoning'.tr(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        ...reasoningChunks.map(
                          (chunk) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              chunk,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Function calls
                if ((isStreaming && streamingFunctionCalls.isNotEmpty) ||
                    (!isStreaming &&
                        isAI &&
                        thought!.chunks.isNotEmpty &&
                        thought!.chunks.any(
                          (chunk) =>
                              chunk.type == ThinkingChunkType.functionCall,
                        ))) ...[
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.code,
                              size: 14,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const Gap(4),
                            Text(
                              'functionCalls'.tr(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        if (isStreaming) ...[
                          ...streamingFunctionCalls.map(
                            (call) => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: SelectableText(
                                call,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          ...thought!.chunks
                              .where(
                                (chunk) =>
                                    chunk.type ==
                                    ThinkingChunkType.functionCall,
                              )
                              .map(
                                (chunk) => Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: SelectableText(
                                    JsonEncoder.withIndent(
                                      '  ',
                                    ).convert(chunk.data),
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),

                  // Token count and model name (for completed AI thoughts only)
                  if (!isStreaming &&
                      isAI &&
                      (thought!.tokenCount != null ||
                          thought!.modelName != null)) ...[
                    const Gap(8),
                    Row(
                      children: [
                        if (thought!.modelName != null) ...[
                          const Icon(Symbols.neurology, size: 16),
                          const Gap(4),
                          Text(
                            '${thought!.modelName}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(16),
                        ],
                        if (thought!.tokenCount != null)
                          ...([
                            const Icon(Symbols.token, size: 16),
                            const Gap(4),
                            Text(
                              '${thought!.tokenCount} tokens',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ]),
                      ],
                    ),
                  ],
                ],
                // Proposals (for completed AI thoughts only)
                if (!isStreaming && proposals.isNotEmpty && isAI) ...[
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        proposals.map((proposal) {
                          return ElevatedButton.icon(
                            onPressed:
                                () => _handleProposalAction(context, proposal),
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
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              foregroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
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
          ),
        ],
      ),
    );
  }
}
