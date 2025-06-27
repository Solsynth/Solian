import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/widgets/content/cloud_files.dart';

class RealmTile extends HookConsumerWidget {
  final SnRealm realm;
  const RealmTile({super.key, required this.realm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: ProfilePictureWidget(file: realm.picture),
      title: Text(realm.name),
      subtitle: Text(realm.description),
      onTap: () => context.push('/realms/${realm.slug}'),
    );
  }
}
