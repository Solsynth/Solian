import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:island/core/theme.dart';
import 'package:styled_widget/styled_widget.dart';

class PostItemSkeleton extends StatelessWidget {
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isCompact;
  final double? borderRadius;
  final double maxWidth;

  /// Whether the placeholder row draws its own [Card] surface. Hosts that
  /// render the real rows as cards (bookmarks) keep it; hosts that lay rows
  /// straight on the background pass false so the placeholder carries the same
  /// full-bleed extent and insets as the rows it stands in for.
  final bool showCard;
  final Color? cardColor;
  final BorderSide? side;

  const PostItemSkeleton({
    super.key,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = false,
    this.isEmbedReply = false,
    this.isCompact = false,
    this.borderRadius,
    this.maxWidth = 640,
    this.showCard = true,
    this.cardColor,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    final row = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(renderingPadding.top),
        _PostHeaderSkeleton(
          isFullPost: isFullPost,
          isCompact: isCompact,
          renderingPadding: renderingPadding,
        ),
        _PostBodySkeleton(
          isFullPost: isFullPost,
          renderingPadding: renderingPadding,
        ),
        if (isShowReference)
          _ReferencedPostWidgetSkeleton(renderingPadding: renderingPadding),
        if (isEmbedReply)
          _PostReplyPreviewSkeleton(renderingPadding: renderingPadding).padding(
            left: renderingPadding.left,
            right: renderingPadding.right,
            top: 8,
          ),
        Gap(renderingPadding.bottom),
      ],
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: showCard
            ? Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: cardColor,
                shape: side != null
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          borderRadius ?? SolRadius.card,
                        ),
                        side: side!,
                      )
                    : null,
                child: row,
              )
            : row,
      ),
    );
  }
}

class _PostHeaderSkeleton extends StatelessWidget {
  final bool isFullPost;
  final bool isCompact;
  final EdgeInsets renderingPadding;

  const _PostHeaderSkeleton({
    required this.isFullPost,
    required this.isCompact,
    required this.renderingPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child:
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  // Profile picture skeleton
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            if (!isCompact)
                              Container(
                                height: 12,
                                width: 80,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const Gap(4),
                        // Timestamp skeleton
                        Container(
                          height: 12,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reaction button skeleton
                  if (!isCompact)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                ],
              ),
            ],
          ).padding(
            left: renderingPadding.left,
            right: renderingPadding.right,
            bottom: 4,
          ),
    );
  }
}

class _PostBodySkeleton extends StatelessWidget {
  final bool isFullPost;
  final EdgeInsets renderingPadding;

  const _PostBodySkeleton({
    required this.isFullPost,
    required this.renderingPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton (if applicable)
          if (isFullPost)
            Container(
              height: 20,
              width: 200,
              margin: EdgeInsets.only(
                left: renderingPadding.left,
                right: renderingPadding.right,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          // Content skeleton
          Container(
            height: 16,
            margin: EdgeInsets.only(
              left: renderingPadding.left,
              right: renderingPadding.right,
              bottom: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 16,
            width: 250,
            margin: EdgeInsets.only(
              left: renderingPadding.left,
              right: renderingPadding.right,
              bottom: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 16,
            width: 180,
            margin: EdgeInsets.only(
              left: renderingPadding.left,
              right: renderingPadding.right,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Metadata skeleton
          Row(
            spacing: 8,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ).padding(
            left: renderingPadding.left,
            right: renderingPadding.right,
            top: 4,
          ),
        ],
      ),
    );
  }
}

class _ReferencedPostWidgetSkeleton extends StatelessWidget {
  final EdgeInsets renderingPadding;

  const _ReferencedPostWidgetSkeleton({required this.renderingPadding});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: EdgeInsets.only(
          left: renderingPadding.left,
          right: renderingPadding.right,
          top: 8,
          bottom: 8,
        ),
        margin: EdgeInsets.only(
          top: 8,
          left: renderingPadding.left,
          right: renderingPadding.right,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: SolRadius.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostReplyPreviewSkeleton extends StatelessWidget {
  final EdgeInsets renderingPadding;

  const _PostReplyPreviewSkeleton({required this.renderingPadding});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: SolRadius.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Container(
              height: 14,
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
