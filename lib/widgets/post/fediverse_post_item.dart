import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/post.dart';
import 'package:html/parser.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/attachment/attachment_list.dart';
import 'package:surface/widgets/html.dart';
import 'package:surface/widgets/universal_image.dart';

class FediversePostWidget extends StatelessWidget {
  final SnFediversePost data;
  final double maxWidth;
  const FediversePostWidget(
      {super.key, required this.data, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final borderSide =
        BorderSide(width: 1, color: Theme.of(context).dividerColor);
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainer;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AccountImage(content: data.user.avatar),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.user.nick.isNotEmpty
                            ? data.user.nick
                            : '@${data.user.name}',
                      ).bold(),
                      Text(data.user.identifier),
                    ],
                  ),
                ],
              ),
              const Gap(8),
              ...parseHtmlToWidgets(context, parse(data.content).children),
              if (data.images.isNotEmpty)
                AspectRatio(
                  aspectRatio: 1,
                  child: ScrollConfiguration(
                    behavior: AttachmentListScrollBehavior(),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: data.images.length,
                      itemBuilder: (context, idx) {
                        return Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    border: Border(
                                      top: borderSide,
                                      bottom: borderSide,
                                    ),
                                    borderRadius: AttachmentList.kDefaultRadius,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: AttachmentList.kDefaultRadius,
                                    child: AutoResizeUniversalImage(
                                      data.images[idx],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Chip(
                                    label: Text(
                                        '${idx + 1}/${data.images.length}'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Gap(8),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
            ],
          ).padding(all: 8),
        ),
      ),
    );
  }
}
