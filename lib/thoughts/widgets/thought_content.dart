import 'package:flutter/material.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/thoughts/widgets/thought_proposal.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ThoughtContent extends StatelessWidget {
  const ThoughtContent({
    super.key,
    required this.isStreaming,
    required this.streamingText,
    this.thought,
    this.subdueParentheticalText = false,
  });

  final bool isStreaming;
  final String streamingText;
  final SnThinkingThought? thought;
  final bool subdueParentheticalText;

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
    final trimmedContent = content.trim();
    final isParenthetical =
        subdueParentheticalText &&
        ((trimmedContent.startsWith('(') && trimmedContent.endsWith(')')) ||
            (trimmedContent.startsWith('（') && trimmedContent.endsWith('）')));
    final baseStyle = Theme.of(context).textTheme.bodyMedium!;
    final baseColor =
        baseStyle.color ?? Theme.of(context).colorScheme.onSurface;

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
        textStyle: baseStyle.copyWith(
          color: isError
              ? Theme.of(context).colorScheme.error
              : isParenthetical
              ? baseColor.withOpacity(0.58)
              : null,
          fontStyle: isParenthetical ? FontStyle.italic : null,
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
