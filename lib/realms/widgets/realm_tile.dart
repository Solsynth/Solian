import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class RealmTile extends HookConsumerWidget {
  final SnRealm realm;
  const RealmTile({super.key, required this.realm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: ProfilePictureWidget(file: realm.picture),
      title: Text(realm.name),
      subtitle: Text(
        realm.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.router.push(RealmDetailRoute(slug: realm.slug)),
    );
  }
}
