import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReasoningSection extends StatelessWidget {
  const ReasoningSection({super.key, required this.reasoningChunks});

  final List<String> reasoningChunks;

  @override
  Widget build(BuildContext context) {
    if (reasoningChunks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}
