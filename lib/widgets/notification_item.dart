import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );
    final isDismissed = useState(false);

    final slideTween = Tween<Offset>(
      begin: Offset(isDesktop ? 1.0 : 0.0, -0.2),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    final fadeTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOut));

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    useEffect(() {
      if (isDismissed.value) return null;
      final timer = Timer(item.duration, () async {
        if (!isDismissed.value) {
          isDismissed.value = true;
          await animationController.reverse();
          onDismiss();
        }
      });
      return () => timer.cancel();
    }, [item.duration, isDismissed.value]);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: slideTween.evaluate(animationController),
          child: Opacity(
            opacity: fadeTween.evaluate(animationController),
            child: child,
          ),
        );
      },
      child: GestureDetector(
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
                if (details.primaryVelocity! > 100 && !isDismissed.value) {
                  isDismissed.value = true;
                  animationController.reverse().then((_) => onDismiss());
                }
              }
            : null,
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 400 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ),
      ),
    );
  }
}
