import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:island/core/models/activitypub.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';

class ActivityPubUserListItem extends StatelessWidget {
  final SnActivityPubUser user;
  final bool isFollowing;
  final bool isLoading;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onTap;

  const ActivityPubUserListItem({
    super.key,
    required this.user,
    this.isFollowing = false,
    this.isLoading = false,
    this.onFollow,
    this.onUnfollow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          if (!user.isLocal)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.public,
                  size: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(child: Text(user.displayName)),
          if (!user.isLocal) const SizedBox(width: 6),
          if (!user.isLocal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.instanceDomain,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('@${user.username}'),
          if (user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Followed ${RelativeTime(context).format(user.followedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : isFollowing
          ? OutlinedButton(
              onPressed: onUnfollow,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Unfollow'),
            )
          : FilledButton(
              onPressed: onFollow,
              style: FilledButton.styleFrom(
                minimumSize: const Size(88, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Follow'),
            ),
      onTap: onTap,
    );
  }
}
