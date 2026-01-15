import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/notification.dart';
import 'package:island/route.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NotificationItemWidget extends HookConsumerWidget {
  final NotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;
  final int index;
  final int totalNotifications;
  final Animation<double> progress;

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
    required this.index,
    required this.totalNotifications,
    required this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (item.notification.meta['action_uri'] != null) {
          var uri = item.notification.meta['action_uri'] as String;
          if (uri.startsWith('solian://')) {
            uri = uri.replaceFirst('solian://', '');
          }
          if (uri.startsWith('/')) {
            rootNavigatorKey.currentContext?.push(
              item.notification.meta['action_uri'],
            );
          } else {
            launchUrlString(uri);
          }
        }
      },
      onHorizontalDragEnd: isDesktop
          ? (details) {
              if (details.primaryVelocity! > 100) {
                onDismiss();
              }
            }
          : null,
      child: Card(
        elevation: (index == 0 && !isDesktop && totalNotifications > 1) ? 8 : 4,
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.notification.meta['pfp'] != null)
                    ProfilePictureWidget(
                      fileId: item.notification.meta['pfp'],
                      radius: 12,
                    ).padding(right: 12, top: 2)
                  else
                    Icon(
                      Symbols.info,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ).padding(right: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.notification.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (item.notification.content.isNotEmpty)
                          Text(
                            item.notification.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (item.notification.subtitle.isNotEmpty)
                          Text(
                            item.notification.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: progress,
              builder: (context, child) => LinearProgressIndicator(
                value: progress.value,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ).clipRRect(all: 8),
      ),
    );
  }
}