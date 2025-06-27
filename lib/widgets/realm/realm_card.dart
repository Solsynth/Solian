import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:material_symbols_icons/symbols.dart';

class RealmCard extends ConsumerWidget {
  final SnRealm realm;

  const RealmCard({super.key, required this.realm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider);

    Widget imageWidget;
    if (realm.picture != null) {
      final imageUrl = '${client.options.baseUrl}/files/${realm.picture!.id}';
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      imageWidget = Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Center(
          child: Icon(
            Symbols.photo_camera,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/realms/${realm.slug}');
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
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
                  child: Text(
                    realm.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
