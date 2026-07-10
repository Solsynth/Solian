import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class NotificationTile extends ConsumerWidget {
  final SnNotification notification;
  final double? avatarRadius;
  final EdgeInsets? contentPadding;
  final bool showImages;
  final bool compact;

  const NotificationTile({
    super.key,
    required this.notification,
    this.avatarRadius,
    this.contentPadding,
    this.showImages = true,
    this.compact = false,
  });

  IconData _getNotificationIcon(String topic) {
    switch (topic) {
      case 'post.replies':
        return Symbols.reply;
      case 'wallet.transactions':
        return Symbols.account_balance_wallet;
      case 'relationships.friends.request':
        return Symbols.person_add;
      case 'invites.chat':
        return Symbols.chat;
      case 'invites.realm':
        return Symbols.domain;
      case 'auth.login':
        return Symbols.login;
      case 'posts.new':
        return Symbols.post_add;
      case 'wallet.orders.paid':
        return Symbols.shopping_bag;
      case 'posts.reactions.new':
        return Symbols.add_reaction;
      default:
        return Symbols.notifications;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfp = notification.meta['pfp'] as String?;
    final images = notification.meta['images'] as List?;
    final imageIds = images?.cast<String>() ?? [];

    return ListTile(
      isThreeLine: true,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: pfp != null
          ? ProfilePictureWidget(
              fileId: pfp,
              radius: avatarRadius ?? (compact ? 16 : 20),
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: avatarRadius ?? (compact ? 16 : 20),
              child: Icon(
                _getNotificationIcon(notification.topic),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: compact ? 16 : 20,
              ),
            ),
      title: Text(
        notification.title,
        style: compact
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.titleMedium,
        maxLines: compact ? 1 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notification.subtitle.isNotEmpty && !compact)
            Text(notification.subtitle, maxLines: compact ? 3 : null).bold(),
          Row(
            spacing: 6,
            children: [
              Text(
                DateFormat().format(notification.createdAt.toLocal()),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: compact ? 10 : 11),
              ),
              Text(
                '·',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                RelativeTime(context).format(notification.createdAt.toLocal()),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: compact ? 10 : 11),
              ),
            ],
          ).opacity(0.75).padding(bottom: compact ? 2 : 4),
          MarkdownTextContent(
            content: (compact && notification.body.length > 60)
                ? '${notification.body.substring(0, 60).replaceAll('\n', ' ')}...'
                : notification.body,
            textStyle:
                (compact
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                      fontSize: compact ? 11 : null,
                    ),
          ),
          if (showImages && imageIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageIds.map((imageId) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CloudImageWidget(
                        fileId: imageId,
                        aspectRatio: 1,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      trailing: notification.viewedAt != null
          ? null
          : Container(
              width: compact ? 8 : 12,
              height: compact ? 8 : 12,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        if (notification.meta['action_uri'] != null) {
          var uri = notification.meta['action_uri'] as String;
          if (uri.startsWith('/')) {
            // In-app routes — use global router so navigation works
            // inside attention modals where context.router is unavailable.
            ref
                .read(routerProvider)
                .navigatePath(
                  notification.meta['action_uri'],
                  onFailure: (err) {
                    showErrorAlert('Unable to open page: $err');
                  },
                );
            dismissAttentionModal('notifications');
          } else {
            // External URLs
            launchUrlString(uri);
          }
        }
      },
    );
  }
}
