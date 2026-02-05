import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/realms/realms_models/realm.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';

class RealmDiscoveryCard extends ConsumerWidget {
  final SnRealm realm;
  final double? maxWidth;

  const RealmDiscoveryCard({super.key, required this.realm, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageWidget;
    if (realm.picture != null) {
      imageWidget = imageWidget = CloudImageWidget(
        file: realm.background,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = ColoredBox(
        color: Theme.of(context).colorScheme.secondaryContainer,
      );
    }

    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'realmDetail',
            pathParameters: {'slug': realm.slug},
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ProfilePictureWidget(
                          file: realm.picture,
                          fallbackIcon: Symbols.group,
                          radius: 12,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        realm.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: card,
    );
  }
}
