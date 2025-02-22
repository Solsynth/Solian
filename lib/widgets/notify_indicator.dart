import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/screens/notification.dart';
import 'package:surface/types/notification.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/universal_image.dart';

import 'markdown_content.dart';

class NotifyIndicator extends StatefulWidget {
  const NotifyIndicator({super.key});

  @override
  State<NotifyIndicator> createState() => _NotifyIndicatorState();
}

class _NotifyIndicatorState extends State<NotifyIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  void _markOneAsRead(SnNotification notification) async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    if (notification.id == 0) return;
    if (notification.readAt != null) return;

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.put('/cgi/id/notifications/read/${notification.id}');

      if (!mounted) return;
      context.showSnackbar(
        'notificationMarkOneReadPrompt'.tr(args: ['#${notification.id}']),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    final nty = context.watch<NotificationProvider>();

    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);

    final show = nty.showingCount > 0 && ua.isAuthorized;

    if (show) {
      _animationController.animateTo(1);
    } else {
      _animationController.animateTo(0);
    }

    return ListenableBuilder(
        listenable: nty,
        builder: (context, _) {
          final current = nty.notifications.lastOrNull;

          return IgnorePointer(
            ignoring: !show,
            child: GestureDetector(
              child: Animate(
                autoPlay: false,
                controller: _animationController,
                effects: [
                  SlideEffect(
                    begin: isMobile ? Offset(0, -1) : Offset(1, 0),
                    end: Offset(0, 0),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.fastEaseInToSlowEaseOut,
                  ),
                  FadeEffect(
                    begin: 0.0,
                    end: 1.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth:
                        isMobile ? MediaQuery.of(context).size.width - 16 : 360,
                  ),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (current?.metadata['avatar'] != null)
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: UniversalImage.provider(
                              sn.getAttachmentUrl(current!.metadata['avatar']),
                            ),
                          )
                        else
                          Icon(kNotificationTopicIcons[current?.topic] ??
                              Symbols.notifications),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current?.title ?? 'Notification',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (current?.subtitle?.isNotEmpty ?? false)
                                Text(
                                  current!.subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              MarkdownTextContent(
                                content: current?.body ?? '',
                                isAutoWarp: true,
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(
                                  (current?.createdAt ?? DateTime.now())
                                              .millisecondsSinceEpoch >
                                          0
                                      ? (current?.createdAt ?? DateTime.now())
                                      : DateTime.now()),
                            ).fontSize(12).padding(right: 2),
                            const Gap(6),
                            if (current?.metadata['image'] != null)
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  child: AutoResizeUniversalImage(
                                    sn.getAttachmentUrl(
                                        current?.metadata['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ).padding(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              onTap: () {
                nty.clear();
                if (current != null) {
                  _markOneAsRead(current);
                }
              },
            ),
          );
        });
  }
}
