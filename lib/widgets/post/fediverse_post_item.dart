import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/attachment/attachment_list.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:surface/widgets/universal_image.dart';

class FediversePostWidget extends StatelessWidget {
  final SnFediversePost data;
  final double maxWidth;
  const FediversePostWidget({
    super.key,
    required this.data,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AccountImage(
                  content: data.user.avatar,
                  radius: 20,
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.user.nick.isNotEmpty
                          ? data.user.nick
                          : '@${data.user.name}',
                      maxLines: 1,
                    ).bold(),
                    Row(
                      children: [
                        Text(
                          data.user.identifier.contains('@')
                              ? data.user.identifier
                              : '${data.user.identifier}@${data.user.origin}',
                          maxLines: 1,
                        ).fontSize(13),
                        const Gap(4),
                        Text(
                          RelativeTime(context)
                              .format(data.createdAt.toLocal()),
                        ).fontSize(13),
                      ],
                    ),
                  ],
                ),
              ],
            ).padding(horizontal: 12, vertical: 8),
            MarkdownTextContent(
              isAutoWarp: true,
              content: html2md.convert(data.content),
            ).padding(horizontal: 16, bottom: 6),
            if (data.images.isNotEmpty)
              _FediversePostImageList(
                data: data,
                maxWidth: maxWidth,
              ),
          ],
        ),
      ),
    );
  }
}

class _FediversePostImageList extends StatelessWidget {
  const _FediversePostImageList({
    required this.data,
    required this.maxWidth,
  });

  final SnFediversePost data;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final borderSide =
        BorderSide(width: 1, color: Theme.of(context).dividerColor);
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainer;

    if (data.images.length == 1) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
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
              data.images.first,
            ),
          ),
        ),
      ).padding(horizontal: 8);
    }

    return AspectRatio(
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
                        label: Text('${idx + 1}/${data.images.length}'),
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
    );
  }
}
