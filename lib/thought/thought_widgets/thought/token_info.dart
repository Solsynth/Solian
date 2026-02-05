import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:island/thought/thought.dart';

class TokenInfo extends StatelessWidget {
  const TokenInfo({super.key, required this.thought});

  final SnThinkingThought thought;

  @override
  Widget build(BuildContext context) {
    if (thought.tokenCount == null && thought.modelName == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (thought.tokenCount != null) ...[
              const Icon(Symbols.token, size: 16),
              const Gap(4),
              Text(
                '${thought.tokenCount} tokens',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
