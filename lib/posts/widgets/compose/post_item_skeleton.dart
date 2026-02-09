import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:styled_widget/styled_widget.dart';

class PostItemSkeleton extends StatelessWidget {
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isCompact;
  final double? borderRadius;
  final double maxWidth;

  const PostItemSkeleton({
    super.key,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = false,
    this.isEmbedReply = false,
    this.isCompact = false,
    this.borderRadius,
    this.maxWidth = 640,
  });

  @override
  Widget build(BuildContext context) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          margin: EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(renderingPadding.vertical),
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
                _ReferencedPostWidgetSkeleton(
                  renderingPadding: renderingPadding,
                ),
              if (isEmbedReply)
                _PostReplyPreviewSkeleton(
                  renderingPadding: renderingPadding,
                ).padding(horizontal: renderingPadding.horizontal, top: 8),
              Gap(renderingPadding.vertical),
            ],
          ),
        ),
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
      child: Column(
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
                      spacing: 4,
                      children: [
                        // Name skeleton
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (!isCompact)
                          Container(
                            height: 12,
                            width: 80,
                            margin: const EdgeInsets.only(left: 4),
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
                        color: Theme.of(context).colorScheme.surfaceContainer,
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
      ).padding(horizontal: renderingPadding.horizontal, bottom: 4),
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
                left: renderingPadding.horizontal,
                right: renderingPadding.horizontal,
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
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
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
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
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
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
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
          ).padding(horizontal: renderingPadding.horizontal + 4, top: 4),
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
        padding: EdgeInsets.symmetric(
          horizontal: renderingPadding.horizontal,
          vertical: 8,
        ),
        margin: EdgeInsets.only(
          top: 8,
          left: renderingPadding.vertical,
          right: renderingPadding.vertical,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
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
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
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
