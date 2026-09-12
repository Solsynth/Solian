import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'post_item.dart';
import 'post_shared.dart';

/// Renders a chain head's children as one continuous Twitter-style thread.
/// The parent [PostItem] owns the rail leaving its avatar; this section
/// continues it through every child avatar and ends at the last one.
///
/// Every child row carries its own trailing [kChainedRowGap]; the rail is
/// drawn across the full row (content plus gap) so it never breaks between
/// children.
///
/// Chains longer than [collapseThreshold] children are collapsed to the first
/// three, followed by a "show more" row that expands the rest on tap. The
/// expand row carries the terminal rail stub, so the thread reads as one
/// connected column in both states.
///
/// Children are hydrated by the server ordered by `PublishedAt` ascending;
/// chained posts never render as standalone list items.
class PostChainedSection extends StatefulWidget {
  final SnPost head;
  final void Function(String)? onPostTap;

  /// Chained children rendered before the rest collapse behind the
  /// "show more" row.
  static const int collapseThreshold = 3;

  const PostChainedSection({super.key, required this.head, this.onPostTap});

  @override
  State<PostChainedSection> createState() => _PostChainedSectionState();
}

class _PostChainedSectionState extends State<PostChainedSection> {
  bool _expanded = false;

  @override
  void didUpdateWidget(PostChainedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recycled list elements must not leak another post's expanded state.
    if (oldWidget.head.id != widget.head.id) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.head.chainedPosts;
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final hiddenCount =
        children.length > PostChainedSection.collapseThreshold
        ? children.length - PostChainedSection.collapseThreshold
        : 0;
    final collapsed = hiddenCount > 0 && !_expanded;
    final visibleCount = collapsed
        ? PostChainedSection.collapseThreshold
        : children.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < visibleCount; index++)
          _ChainedPostRow(
            post: children[index],
            // When collapsed the expand row is the thread's end, not this row.
            isLast: !collapsed && index == children.length - 1,
            dividerColor: theme.dividerColor,
            onPostTap: widget.onPostTap,
          ),
        if (collapsed)
          _ChainedExpandRow(
            hiddenCount: hiddenCount,
            dividerColor: theme.dividerColor,
            onTap: () => setState(() => _expanded = true),
          ),
      ],
    );
  }
}

class _ChainedPostRow extends StatelessWidget {
  final SnPost post;
  final bool isLast;
  final Color dividerColor;
  final void Function(String)? onPostTap;

  const _ChainedPostRow({
    required this.post,
    required this.isLast,
    required this.dividerColor,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // The rail spans the full row height, including the trailing
                // gap, so consecutive rows stay connected.
                Positioned(
                  top: 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 16 : null,
                  child: SizedBox(
                    width: kPostThreadingLineWidth,
                    child: ColoredBox(color: dividerColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PostAvatar(item: post),
                    if (!isLast) const Gap(kChainedRowGap),
                  ],
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PostActionableItem(
                  item: post,
                  isShowReference: false,
                  isEmbedReply: false,
                  padding: EdgeInsets.zero,
                  hideAvatar: true,
                  onPostTap: onPostTap,
                ),
                if (!isLast) const Gap(kChainedRowGap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Terminal row shown when a chain is collapsed: carries the rail's end stub
/// and a tappable "show N more" control that expands the remaining children.
class _ChainedExpandRow extends StatelessWidget {
  final int hiddenCount;
  final Color dividerColor;
  final VoidCallback onTap;

  const _ChainedExpandRow({
    required this.hiddenCount,
    required this.dividerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  height: 16,
                  child: SizedBox(
                    width: kPostThreadingLineWidth,
                    child: ColoredBox(color: dividerColor),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Symbols.expand_more, size: 18),
                label: Text('showMoreChainedPosts'.plural(hiddenCount)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
