import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

/// A reusable widget for displaying info banners in compose screens.
/// Shows editing, reply, and forward information.
class ComposeInfoBanner extends StatelessWidget {
  final SnPost? originalPost;
  final SnPost? replyingTo;
  final SnPost? forwardingTo;
  final Function(BuildContext, SnPost)? onReferencePostTap;

  const ComposeInfoBanner({
    super.key,
    this.originalPost,
    this.replyingTo,
    this.forwardingTo,
    this.onReferencePostTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRepliedPost = replyingTo ?? originalPost?.repliedPost;
    final effectiveForwardedPost = forwardingTo ?? originalPost?.forwardedPost;

    // Show editing banner when editing a post
    if (originalPost != null) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Symbols.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Gap(8),
                Text(
                  'postEditing'.tr(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ).padding(horizontal: 16, vertical: 8),
          ),
          // Show reply/forward banners below editing banner if they exist
          if (effectiveRepliedPost != null)
            _buildReferenceBanner(
              context,
              effectiveRepliedPost,
              Symbols.reply,
              'postReplyingTo'.tr(),
            ),
          if (effectiveForwardedPost != null)
            _buildReferenceBanner(
              context,
              effectiveForwardedPost,
              Symbols.forward,
              'postForwardingTo'.tr(),
            ),
        ],
      );
    }

    // Show banner for replies
    if (effectiveRepliedPost != null) {
      return _buildReferenceBanner(
        context,
        effectiveRepliedPost,
        Symbols.reply,
        'postReplyingTo'.tr(),
      );
    }

    // Show banner for forwards
    if (effectiveForwardedPost != null) {
      return _buildReferenceBanner(
        context,
        effectiveForwardedPost,
        Symbols.forward,
        'postForwardingTo'.tr(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReferenceBanner(
    BuildContext context,
    SnPost post,
    IconData icon,
    String labelKey,
  ) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const Gap(4),
              Text(labelKey, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          const Gap(8),
          CompactReferencePost(
            post: post,
            onTap: onReferencePostTap != null
                ? () => onReferencePostTap!(context, post)
                : null,
          ),
        ],
      ).padding(all: 16),
    );
  }
}

/// A compact widget for displaying reference posts (replies/forwards).
class CompactReferencePost extends StatelessWidget {
  final SnPost post;
  final VoidCallback? onTap;

  const CompactReferencePost({super.key, required this.post, this.onTap});

  Widget _buildProfilePicture(BuildContext context) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        fileId: post.publisher!.picture?.id,
        radius: 16,
      );
    }
    // Handle actor case
    if (post.actor != null) {
      final avatarUrl = post.actor!.avatarUrl;
      if (avatarUrl != null) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Symbols.account_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              },
            ),
          ),
        );
      }
    }
    // Fallback
    return ProfilePictureWidget(fileId: null, radius: 16);
  }

  String _getDisplayName() {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.nick;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.displayName ?? post.actor!.username ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            _buildProfilePicture(context),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDisplayName(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (post.title?.isNotEmpty ?? false)
                    Text(
                      post.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (post.content?.isNotEmpty ?? false)
                    Text(
                      post.content!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (post.attachments.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.attach_file,
                          size: 12,
                          color: theme.colorScheme.secondary,
                        ),
                        const Gap(4),
                        Text(
                          'postHasAttachments'.plural(post.attachments.length),
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Symbols.open_in_full,
                size: 16,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}
