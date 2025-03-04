import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/universal_image.dart';

import '../../screens/account/profile_page.dart' show kBadgesMeta;

class PublisherPopoverCard extends StatelessWidget {
  final SnPublisher data;

  const PublisherPopoverCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final ud = context.read<UserDirectoryProvider>();

    final user = data.type == 0 ? ud.getFromCache(data.accountId) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.banner.isNotEmpty)
          Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: AutoResizeUniversalImage(
                sn.getAttachmentUrl(data.banner),
                fit: BoxFit.cover,
              ),
            ),
          ),
        // Top padding
        Gap(16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountImage(
              content: data.avatar,
              radius: 20,
              borderRadius: data.type == 1 ? 8 : 20,
            ),
            Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.nick).bold(),
                  Text('@${data.name}').fontSize(13).opacity(0.75),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).pushNamed(
                  'postPublisher',
                  pathParameters: {'name': data.name},
                );
              },
              icon: const Icon(Symbols.chevron_right),
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            const Gap(8)
          ],
        ).padding(horizontal: 16),
        if (user != null && user.badges.isNotEmpty) const Gap(16),
        if (user != null && user.badges.isNotEmpty)
          Wrap(
            spacing: 4,
            children: user.badges
                .map(
                  (ele) => Tooltip(
                    richMessage: TextSpan(
                      children: [
                        TextSpan(
                            text: kBadgesMeta[ele.type]?.$1.tr() ??
                                'unknown'.tr()),
                        if (ele.metadata['title'] != null)
                          TextSpan(
                            text: '\n${ele.metadata['title']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        TextSpan(text: '\n'),
                        TextSpan(
                          text: DateFormat.yMEd().format(ele.createdAt),
                        ),
                      ],
                    ),
                    child: Icon(
                      kBadgesMeta[ele.type]?.$2 ?? Symbols.question_mark,
                      color: kBadgesMeta[ele.type]?.$3,
                      fill: 1,
                    ),
                  ),
                )
                .toList(),
          ).padding(horizontal: 24),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('publisherSocialPoint').tr().fontSize(13).opacity(0.75),
                  Text((data.totalUpvote - data.totalDownvote).toString()),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: const VerticalDivider(
                thickness: 1,
              ),
            ).padding(horizontal: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('publisherTotalUpvote').tr().fontSize(13).opacity(0.75),
                  Text(data.totalUpvote.toString()),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: const VerticalDivider(
                thickness: 1,
              ),
            ).padding(horizontal: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('publisherTotalDownvote')
                      .tr()
                      .fontSize(13)
                      .opacity(0.75),
                  Text(data.totalDownvote.toString()),
                ],
              ),
            ),
          ],
        ).padding(horizontal: 16),
        // Bottom padding
        const Gap(16),
      ],
    );
  }
}
