import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/universal_image.dart';

class RealmItemWidget extends StatelessWidget {
  final SnRealm item;
  final bool isListView;
  final List<PopupMenuItem>? actionListView;
  final Function? onUpdate;
  final Function? onTap;

  const RealmItemWidget({
    super.key,
    required this.item,
    required this.isListView,
    this.actionListView,
    this.onUpdate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isListView) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: AccountImage(
          content: item.avatar,
          fallbackWidget: const Icon(Symbols.group, size: 20),
        ),
        title: Text(item.name),
        subtitle: Text(
          item.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(itemBuilder: (BuildContext context) => actionListView ?? []),
        onTap: () {
          GoRouter.of(context).pushNamed(
            'realmDetail',
            pathParameters: {'alias': item.alias},
          ).then((value) {
            if (value == true) {
              onUpdate?.call();
            }
          });
        },
      );
    }

    final sn = context.read<SnNetworkProvider>();

    return Container(
      constraints: BoxConstraints(maxWidth: 640),
      child: Card(
        margin: const EdgeInsets.all(12),
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
                        child: (item.banner?.isEmpty ?? true)
                            ? const SizedBox.shrink()
                            : AutoResizeUniversalImage(
                                sn.getAttachmentUrl(item.banner!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: 18,
                      child: AccountImage(
                        content: item.avatar,
                        radius: 24,
                        fallbackWidget: const Icon(Symbols.group, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20 + 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name).textStyle(Theme.of(context).textTheme.titleMedium!),
                  Text(item.description).textStyle(Theme.of(context).textTheme.bodySmall!),
                ],
              ).padding(horizontal: 24, bottom: 14),
            ],
          ),
          onTap: () {
            if (onTap != null) onTap!();
            GoRouter.of(context).pushNamed(
              'realmDetail',
              pathParameters: {'alias': item.alias},
            ).then((value) {
              if (value == true) {
                onUpdate?.call();
              }
            });
          },
        ),
      ),
    ).center();
  }
}
