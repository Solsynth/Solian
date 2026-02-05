import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:island/core/models/activitypub.dart';
import 'package:material_symbols_icons/symbols.dart';

class ActorPictureWidget extends StatelessWidget {
  final SnActivityPubActor actor;
  final double radius;

  const ActorPictureWidget({super.key, required this.actor, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = actor.avatarUrl;
    if (avatarUrl == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Icon(
          Symbols.person,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(avatarUrl),
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          child: avatarUrl.isNotEmpty
              ? null
              : Icon(
                  Symbols.person,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            backgroundImage: actor.instance.iconUrl != null
                ? CachedNetworkImageProvider(actor.instance.iconUrl!)
                : null,
            radius: radius * 0.4,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: actor.instance.iconUrl == null
                ? Icon(
                    Symbols.public,
                    size: radius * 0.6,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
