import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:island/realms/realms_models/realm.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class RealmListTile extends StatelessWidget {
  const RealmListTile({super.key, required this.realm});

  final SnRealm realm;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: realm.background == null
                          ? const SizedBox.shrink()
                          : CloudImageWidget(file: realm.background),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 18,
                    child: ProfilePictureWidget(
                      file: realm.picture,
                      fallbackIcon: Symbols.group,
                      radius: 24,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20 + 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realm.name,
                ).textStyle(Theme.of(context).textTheme.titleMedium!),
                Text(
                  realm.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).textStyle(Theme.of(context).textTheme.bodySmall!),
              ],
            ).padding(horizontal: 24, bottom: 14),
          ],
        ),
        onTap: () {
          context.pushNamed(
            'realmDetail',
            pathParameters: {'slug': realm.slug},
          );
        },
      ),
    );
  }
}
