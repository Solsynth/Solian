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

  @override
  Widget build(BuildContext context) {
    if (isStreaming) {
      // Streaming text with spinner
      if (streamingText.isNotEmpty) {
        return Row(
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
        );
      }
      return const SizedBox.shrink();
    } else {
      // Regular thought content
      if (thought!.content != null && thought!.content!.isNotEmpty) {
        return MarkdownTextContent(
          isSelectable: true,
          content: thought!.content!,
          extraBlockSyntaxList: [ProposalBlockSyntax()],
          textStyle: Theme.of(context).textTheme.bodyMedium,
          extraGenerators: [
            ProposalGenerator(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
              borderColor: Theme.of(context).colorScheme.outline,
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }
  }
}
