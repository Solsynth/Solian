import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/models/post.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:styled_widget/styled_widget.dart';

class PostItem extends StatelessWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isOpenable;
  const PostItem({
    super.key,
    required this.item,
    this.padding,
    this.isOpenable = true,
  });

  @override
  Widget build(BuildContext context) {
    final renderingPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    return Padding(
      padding: renderingPadding,
      child: Column(
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              ProfilePictureWidget(item: item.publisher.picture),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.publisher.nick).bold(),
                      if (item.content.isNotEmpty)
                        MarkdownTextContent(content: item.content),
                    ],
                  ),
                  onTap: () {
                    if (isOpenable) {
                      context.router.push(PostDetailRoute(id: item.id));
                    }
                  },
                ),
              ),
            ],
          ),
          if (item.attachments.isNotEmpty)
            CloudFileList(files: item.attachments),
        ],
      ),
    );
  }
}
