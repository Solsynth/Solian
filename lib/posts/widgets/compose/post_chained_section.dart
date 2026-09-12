import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'post_item.dart';

/// Renders a chain head's children beneath it, attached to the head card.
///
/// Children are always hydrated by the server ordered by `PublishedAt`
/// ascending; chained posts never render as standalone list items.
class PostChainedSection extends StatelessWidget {
  final SnPost head;

  const PostChainedSection({super.key, required this.head});

  @override
  Widget build(BuildContext context) {
    if (head.chainedPosts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.link, size: 14, color: theme.colorScheme.outline),
            const Gap(4),
            Text(
              'chainedPosts'.tr(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const Gap(6),
        for (final child in head.chainedPosts)
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
            child: PostActionableItem(item: child, isCompact: true),
          ),
      ],
    );
  }
}
