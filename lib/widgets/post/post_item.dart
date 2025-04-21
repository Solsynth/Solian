import 'package:flutter/material.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:styled_widget/styled_widget.dart';

class PostItem extends StatelessWidget {
  final SnPost item;
  final EdgeInsets? padding;
  const PostItem({super.key, required this.item, this.padding});

  @override
  Widget build(BuildContext context) {
    final renderingPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    return Padding(
      padding: renderingPadding,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar...
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.publisher.name).bold(),
                    if (item.content.isNotEmpty)
                      MarkdownTextContent(content: item.content),
                  ],
                ),
              ),
            ],
          ),
          for (final attachment in item.attachments)
            CloudFileWidget(item: attachment),
        ],
      ),
    );
  }
}
