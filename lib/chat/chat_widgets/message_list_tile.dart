import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:island/chat/chat_widgets/message_content.dart';
import 'package:island/chat/chat_widgets/message_sender_info.dart';
import 'package:island/data/message.dart';
import 'package:island/posts/posts_models/embed.dart';
import 'package:island/core/utils/mapping.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/embed/link.dart';

class MessageListTile extends StatelessWidget {
  final LocalChatMessage message;
  final Function(String messageId) onJump;

  const MessageListTile({
    super.key,
    required this.message,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final remoteMessage = message.toRemoteMessage();
    final sender = remoteMessage.sender;

    return ListTile(
      isThreeLine: true,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: ProfilePictureWidget(
          file: sender.account.profile.picture,
          radius: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageSenderInfo(
            sender: sender,
            createdAt: message.createdAt,
            textColor: Theme.of(context).colorScheme.onSurfaceVariant,
            showAvatar: false,
            isCompact: true,
          ),
          const SizedBox(height: 4),
          MessageContent(item: remoteMessage, isSelectable: false),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (remoteMessage.attachments.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                return CloudFileList(
                  files: remoteMessage.attachments,
                  maxWidth: constraints.maxWidth,
                  padding: EdgeInsets.symmetric(vertical: 4),
                );
              },
            ),
          if (remoteMessage.meta['embeds'] != null)
            ...((remoteMessage.meta['embeds'] as List<dynamic>)
                .map((embed) => convertMapKeysToSnakeCase(embed))
                .where((embed) => embed['type'] == 'link')
                .map((embed) => SnScrappedLink.fromJson(embed))
                .map(
                  (link) => LayoutBuilder(
                    builder: (context, constraints) {
                      return EmbedLinkWidget(
                        link: link,
                        maxWidth: math.min(constraints.maxWidth, 480),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      );
                    },
                  ),
                )
                .toList()),
        ],
      ),
      onTap: () => onJump(message.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      dense: true,
    );
  }
}
