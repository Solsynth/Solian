import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/notification.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

import '../providers/userinfo.dart';
import '../widgets/unauthorized_hint.dart';

const Map<String, IconData> kNotificationTopicIcons = {
  'general': Symbols.notifications,
  'passport.security.alert': Symbols.gpp_maybe,
  'passport.security.otp': Symbols.password,
  'interactive.subscription': Symbols.subscriptions,
  'interactive.feedback': Symbols.add_reaction,
  'interactive.reply': Symbols.reply,
  'messaging.callStart': Symbols.call_received,
  'wallet.transaction.new': Symbols.receipt,
};

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isBusy = false;
  bool _isFirstLoading = true;
  bool _isSubmitting = false;

  final List<SnNotification> _notifications = List.empty(growable: true);
  int? _totalCount;

  Future<void> _fetchNotifications() async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final nty = context.read<NotificationProvider>();
      final resp = await sn.client.get(
        '/cgi/id/notifications',
        queryParameters: {'take': 10, 'offset': _notifications.length},
      );
      _totalCount = resp.data['count'];
      _notifications.addAll(resp.data['data']
              ?.map((e) => SnNotification.fromJson(e))
              .cast<SnNotification>() ??
          []);
      nty.updateTray();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      _isFirstLoading = false;
      setState(() => _isBusy = false);
    }
  }

  void _markAllAsRead() async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    if (_notifications.isEmpty) return;

    final confirm = await context.showConfirmDialog(
      'notificationMarkAllRead'.tr(),
      'notificationMarkAllReadDescription'.tr(),
    );
    if (!confirm) return;

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final nty = context.read<NotificationProvider>();
      final resp = await sn.client.put('/cgi/id/notifications/read/all');
      _notifications.clear();
      _fetchNotifications();
      nty.clear();

      if (!mounted) return;
      context.showSnackbar(
          'notificationMarkAllReadPrompt'.plural(resp.data['count']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _markOneAsRead(SnNotification notification) async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    if (notification.readAt != null) return;

    setState(() => _isSubmitting = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.put('/cgi/id/notifications/read/${notification.id}');
      _notifications.clear();
      _fetchNotifications();

      if (!mounted) return;
      context.showSnackbar(
          'notificationMarkOneReadPrompt'.tr(args: ['#${notification.id}']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();

    if (!ua.isAuthorized) {
      return AppScaffold(
        appBar: AppBar(
            leading: AutoAppBarLeading(),
            title: Text('screenNotification').tr()),
        body: Center(child: UnauthorizedHint()),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        leading: AutoAppBarLeading(),
        title: Text('screenNotification').tr(),
        actions: [
          IconButton(
              icon: const Icon(Symbols.checklist),
              onPressed: _isSubmitting ? null : _markAllAsRead),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isFirstLoading),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                _notifications.clear();
                return _fetchNotifications();
              },
              child: InfiniteList(
                padding: EdgeInsets.only(
                    top: 16,
                    bottom:
                        math.max(MediaQuery.of(context).padding.bottom, 16)),
                itemCount: _notifications.length,
                onFetchData: () {
                  _fetchNotifications();
                },
                isLoading: _isBusy,
                hasReachedMax: _totalCount != null &&
                    _notifications.length >= _totalCount!,
                itemBuilder: (context, idx) {
                  final nty = _notifications[idx];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(kNotificationTopicIcons[nty.topic]),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (nty.readAt == null)
                              StyledWidget(Badge(
                                      label: Text('notificationUnread').tr()))
                                  .padding(bottom: 4),
                            Text(nty.title,
                                style: Theme.of(context).textTheme.titleMedium),
                            if (nty.subtitle != null)
                              Text(nty.subtitle!,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            if (nty.subtitle != null) const Gap(4),
                            SelectionArea(
                                child: MarkdownTextContent(
                                    content: nty.body, isAutoWarp: true)),
                            if ([
                                  'interactive.reply',
                                  'interactive.feedback',
                                  'interactive.subscription',
                                ].contains(nty.topic) &&
                                nty.metadata['related_post'] != null)
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1),
                                  ),
                                  child: PostItem(
                                    data: SnPost.fromJson(
                                        nty.metadata['related_post']!),
                                    showComments: false,
                                    showReactions: false,
                                    showMenu: false,
                                  ).padding(vertical: 4),
                                ),
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    'postDetail',
                                    pathParameters: {
                                      'slug': nty
                                          .metadata['related_post']!['id']
                                          .toString()
                                    },
                                  );
                                },
                              ).padding(top: 8),
                            const Gap(8),
                            Row(
                              children: [
                                Text(DateFormat('yy/MM/dd')
                                        .format(nty.createdAt))
                                    .fontSize(12),
                                const Gap(4),
                                Text('·', style: TextStyle(fontSize: 12)),
                                const Gap(4),
                                Text(RelativeTime(context)
                                        .format(nty.createdAt))
                                    .fontSize(12),
                              ],
                            ).opacity(0.75),
                          ],
                        ),
                      ),
                      const Gap(16),
                      IconButton(
                        icon: const Icon(Symbols.check),
                        padding: EdgeInsets.all(0),
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed:
                            _isSubmitting ? null : () => _markOneAsRead(nty),
                      ),
                    ],
                  ).padding(horizontal: 16);
                },
                separatorBuilder: (_, __) => const Divider(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
