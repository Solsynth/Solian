import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/notification.dart';
import 'package:island/route.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

const double kNotificationBorderRadius = 8;

class NotificationItemWidget extends HookConsumerWidget {
  final NotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;
  final Animation<double> progress;

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
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
            ref
                .read(routerProvider)
                .pushPath(item.notification.meta['action_uri']);
          } else {
            launchUrlString(uri);
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 100) {
          onDismiss();
        }
      },
      onVerticalDragEnd: !isDesktop
          ? (details) {
              if (details.primaryVelocity! < -100) {
                onDismiss();
              }
            }
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Stack(
          children: [
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(kNotificationBorderRadius),
                ),
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
                              if (item.notification.body.isNotEmpty)
                                Text(
                                  item.notification.body,
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
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  Symbols.close,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: onDismiss,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ).clipRRect(all: kNotificationBorderRadius),
      ),
    );
  }
}
