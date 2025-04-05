import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/news.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/universal_image.dart';

class NewsFeedEntry extends StatelessWidget {
  final SnFeedEntry data;
  const NewsFeedEntry({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final ele = SnSubscriptionItem.fromJson(data.data);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ele.thumbnail.isNotEmpty && ele.thumbnail.startsWith('http'))
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: AutoResizeUniversalImage(ele.thumbnail),
                ),
              ),
            ).padding(horizontal: 16, bottom: 8, top: 4),
          Row(
            children: [
              const Icon(Symbols.globe),
              const Gap(8),
              Expanded(
                child: Text(
                  ele.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ).padding(horizontal: 18, vertical: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ele.description),
              Text(DateFormat().format(ele.createdAt.toLocal()))
                  .tr()
                  .opacity(0.8),
            ],
          ).padding(horizontal: 16),
        ],
      ),
    );
  }
}
