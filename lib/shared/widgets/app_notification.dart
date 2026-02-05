import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/route.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NotificationCard extends HookConsumerWidget {
  final SnNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = Symbols.info;

    return GestureDetector(
      onTap: () {
        if (notification.meta['action_uri'] != null) {
          var uri = notification.meta['action_uri'] as String;
          if (uri.startsWith('solian://')) {
            uri = uri.replaceFirst('solian://', '');
          }
          if (uri.startsWith('/')) {
            // In-app routes
            rootNavigatorKey.currentContext?.push(
              notification.meta['action_uri'],
            );
          } else {
            // External URLs
            launchUrlString(uri);
          }
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 8),
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.meta['pfp'] != null)
                    ProfilePictureWidget(
                      fileId: notification.meta['pfp'],
                      radius: 12,
                    ).padding(right: 12, top: 2)
                  else
                    Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ).padding(right: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (notification.content.isNotEmpty)
                          Text(
                            notification.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (notification.subtitle.isNotEmpty)
                          Text(
                            notification.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
