import 'package:flutter/material.dart';
import 'package:island/thoughts/thought.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/thoughts/widgets/thought_proposal.dart';

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
    final content = streamingText.isNotEmpty
        ? streamingText
        : thought != null
        ? thought!.parts
              .where((p) => p.type == ThinkingMessagePartType.text)
              .map((p) => p.text ?? '')
              .join('')
        : '';

    if (content.isEmpty) return const SizedBox.shrink();

    final isError = content.startsWith('Error:') || _isErrorMessage;

    return Container(
      padding: isError ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: isError
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: MarkdownTextContent(
        linesMargin: EdgeInsets.zero,
        isSelectable: true,
        content: content,
        extraBlockSyntaxList: [ProposalBlockSyntax()],
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: isError ? Theme.of(context).colorScheme.error : null,
        ),
        extraGenerators: [
          ProposalGenerator(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            borderColor: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
