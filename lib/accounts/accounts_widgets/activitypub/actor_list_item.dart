import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:island/core/models/activitypub.dart';
import 'package:material_symbols_icons/symbols.dart';

class ApActorListItem extends StatelessWidget {
  final SnActivityPubActor actor;
  final bool isFollowing;
  final bool isLoading;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onTap;

  const ApActorListItem({
    super.key,
    required this.actor,
    this.isFollowing = false,
    this.isLoading = false,
    this.onFollow,
    this.onUnfollow,
    this.onTap,
  });

  String _getDisplayName() {
    if (actor.displayName?.isNotEmpty ?? false) {
      return actor.displayName!;
    }
    if (actor.username?.isNotEmpty ?? false) {
      return actor.username!;
    }
    return actor.id.split('@').lastOrNull ?? 'Unknown';
  }

  String _getUsername() {
    if (actor.username?.isNotEmpty ?? false) {
      return '${actor.username}@${actor.instance.domain}';
    }
    return actor.id;
  }

  String _getInstanceDomain() {
    final parts = actor.id.split('@');
    if (parts.length >= 3) {
      return parts[2];
    }
    return '';
  }

  bool _isLocal() {
    // For now, assume all searched actors are remote
    // This could be determined by checking if the domain matches local instance
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final username = _getUsername();
    final instanceDomain = _getInstanceDomain();
    final isLocal = _isLocal();

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: actor.avatarUrl != null
                ? CachedNetworkImageProvider(actor.avatarUrl!)
                : null,
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            child: actor.avatarUrl == null
                ? Icon(
                    Symbols.person,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          if (!isLocal)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                backgroundImage: actor.instance.iconUrl != null
                    ? CachedNetworkImageProvider(actor.instance.iconUrl!)
                    : null,
                radius: 8,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: actor.instance.iconUrl == null
                    ? Icon(
                        Symbols.public,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(child: Text(displayName)),
          if (!isLocal && instanceDomain.isNotEmpty) const SizedBox(width: 6),
          if (!isLocal && instanceDomain.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                instanceDomain,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        spacing: 8,
        children: [
          Text(username),
          if (actor.summary?.isNotEmpty ?? false)
            Expanded(
              child: Text(
                actor.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (actor.type.isNotEmpty) Text(actor.type),
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
