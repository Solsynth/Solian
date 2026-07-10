import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PublisherCollectionPublisherInfo extends StatelessWidget {
  final SnPublisher data;

  const PublisherCollectionPublisherInfo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.router.push(PublisherProfileRoute(name: data.name)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 6,
              child: CloudImageWidget(file: data.background, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.nick,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(2),
                              HandleChip(
                                handle: data.name,
                                allowCopy: true,
                                maxLines: 1,
                              ),
                              if (data.bio.isNotEmpty) ...[
                                const Gap(8),
                                Text(
                                  data.bio,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.router.push(
                            PublisherProfileRoute(name: data.name),
                          ),
                          icon: const Icon(Symbols.open_in_new),
                          tooltip: 'open'.tr(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -28,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: data.type == 0
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: data.type == 0
                            ? null
                            : BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 3,
                        ),
                      ),
                      child: ProfilePictureWidget(
                        file: data.picture,
                        radius: 28,
                        borderRadius: data.type == 0 ? null : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublisherCollectionHeader extends StatelessWidget {
  final SnPostCollection collection;
  final String title;

  const PublisherCollectionHeader({
    super.key,
    required this.collection,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBackground = collection.background != null;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (collection.background != null)
              CloudFileWidget(item: collection.background!, fit: BoxFit.cover)
            else
              Container(color: theme.colorScheme.surfaceContainerHighest),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ProfilePictureWidget(
                    file: collection.icon,
                    radius: 28,
                    fallbackIcon: Symbols.collections,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: hasBackground
                                ? const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        if (collection.description?.isNotEmpty ?? false)
                          Text(
                            collection.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              shadows: hasBackground
                                  ? const [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 10,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
