import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';

class ReasoningSection extends HookWidget {
  const ReasoningSection({super.key, required this.reasoningChunks});

  final List<String> reasoningChunks;

  @override
  Widget build(BuildContext context) {
    if (reasoningChunks.isEmpty) {
      return const SizedBox.shrink();
    }

    final isExpanded = useState(false);
    final totalChars = reasoningChunks.fold<int>(
      0,
      (sum, chunk) => sum + chunk.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          minTileHeight: 24,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          collapsedBackgroundColor: Theme.of(
            context,
          ).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalChars chars',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondaryContainer.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
              SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  isExpanded.value
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 16,
                  color: isExpanded.value
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondaryFixedDim,
                ),
              ),
            ],
          ),
          showTrailingIcon: true,
          onExpansionChanged: (expanded) => isExpanded.value = expanded,
          title: Row(
            spacing: 8,
            children: [
              Icon(
                Symbols.psychology,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Expanded(
                child: Text(
                  'reasoning'.tr(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          children: [
            ...reasoningChunks.map(
              (chunk) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  chunk,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).padding(vertical: 4);
  }
}
