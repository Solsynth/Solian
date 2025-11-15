import 'package:flutter/material.dart';
import 'package:island/models/thought.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/thought/thought_proposal.dart';

class ThoughtContent extends StatelessWidget {
  const ThoughtContent({
    super.key,
    required this.isStreaming,
    required this.streamingText,
    this.thought,
  });

  final bool isStreaming;
  final String streamingText;
  final SnThinkingThought? thought;

  bool get _isErrorMessage {
    if (thought == null) return false;
    // Check if this is an error thought by ID or content
    if (thought!.id.startsWith('error-')) return true;
    final textParts = thought!.parts
        .where((p) => p.type == ThinkingMessagePartType.text)
        .map((p) => p.text ?? '')
        .join('');
    return textParts.startsWith('Error:');
  }

  @override
  Widget build(BuildContext context) {
    if (isStreaming) {
      // Streaming text with spinner
      if (streamingText.isNotEmpty) {
        final isStreamingError = streamingText.startsWith('Error:');
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding:
                    isStreamingError
                        ? const EdgeInsets.all(8)
                        : EdgeInsets.zero,
                decoration:
                    isStreamingError
                        ? BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        )
                        : null,
                child: MarkdownTextContent(
                  isSelectable: true,
                  content: streamingText,
                  extraBlockSyntaxList: [ProposalBlockSyntax()],
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color:
                        isStreamingError
                            ? Theme.of(context).colorScheme.error
                            : null,
                  ),
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
        );
      }
      return const SizedBox.shrink();
    } else {
      // Regular thought content - render parts
      if (thought!.parts.isNotEmpty) {
        final textParts = thought!.parts
            .where((p) => p.type == ThinkingMessagePartType.text)
            .map((p) => p.text ?? '')
            .join('');
        if (textParts.isNotEmpty) {
          return Container(
            padding:
                _isErrorMessage
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                    : EdgeInsets.zero,
            decoration:
                _isErrorMessage
                    ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    )
                    : null,
            child: MarkdownTextContent(
              isSelectable: true,
              content: textParts,
              extraBlockSyntaxList: [ProposalBlockSyntax()],
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color:
                    _isErrorMessage
                        ? Theme.of(context).colorScheme.error
                        : null,
              ),
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
          );
        }
      }
      return const SizedBox.shrink();
    }
  }
}
