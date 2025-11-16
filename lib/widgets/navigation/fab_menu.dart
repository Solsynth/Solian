import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/compose_sheet.dart';
import 'package:island/screens/chat/chat_form.dart';
import 'package:material_symbols_icons/symbols.dart';

enum FabMenuType { main, compose, chat, realm }

/// Global state provider for FAB menu type
final fabMenuTypeProvider = StateProvider<FabMenuType>(
  (ref) => FabMenuType.main,
);

class FabMenu extends HookConsumerWidget {
  final double? elevation;
  const FabMenu({super.key, this.elevation});

  Future<void> _createDirectMessage(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const AccountPickerSheet(),
    );
    if (result == null) return;
    final client = ref.read(apiClientProvider);
    try {
      await client.post(
        '/sphere/chat/direct',
        data: {'related_user_id': result.id},
      );
      eventBus.fire(const ChatRoomsRefreshEvent());
    } catch (err) {
      showErrorAlert(err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fabType = ref.watch(fabMenuTypeProvider);

    late final IconData icon;
    late final bool useRootNavigator;
    late final Widget menuContent;

    final commonEntires = <Widget>[
      if (!isWideScreen(context))
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.bubble_chart),
          title: Text('aiThoughtTitle').tr(),
          onTap: () async {
            Navigator.of(context).pop();
            context.goNamed('thought');
          },
        ),
      Consumer(
        builder: (context, ref, _) {
          final notificationCount = ref.watch(
            notificationUnreadCountNotifierProvider,
          );
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.notifications),
            trailing: Badge(
              label: Text(notificationCount.value.toString()),
              isLabelVisible: notificationCount.value! > 0,
            ),
            title: Text('notifications').tr(),
            onTap: () async {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) => const NotificationSheet(),
              );
            },
          );
        },
      ),
    ];

    switch (fabType) {
      case FabMenuType.compose:
        icon = Symbols.create;
        useRootNavigator = false;
        menuContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(24),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.post_add_rounded),
              title: Text('postCompose').tr(),
              onTap: () async {
                Navigator.of(context).pop();
                await PostComposeSheet.show(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.article),
              title: Text('articleCompose').tr(),
              onTap: () async {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed('articleCompose');
              },
            ),
            const Divider(),
            ...commonEntires,
            Gap(MediaQuery.of(context).padding.bottom + 16),
          ],
        );
        break;

      case FabMenuType.chat:
        icon = Symbols.chat_add_on;
        useRootNavigator = true;
        menuContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(24),
            ListTile(
              title: const Text('createChatRoom').tr(),
              leading: const Icon(Symbols.add),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  builder: (context) => const EditChatScreen(),
                ).then((value) {
                  if (value != null) {
                    eventBus.fire(const ChatRoomsRefreshEvent());
                  }
                });
              },
            ),
            ListTile(
              title: const Text('createDirectMessage').tr(),
              leading: const Icon(Symbols.person),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                _createDirectMessage(context, ref);
              },
            ),
            const Divider(),
            ...commonEntires,
            Gap(MediaQuery.of(context).padding.bottom + 16),
          ],
        );
        break;

      case FabMenuType.realm:
        icon = Symbols.group_add;
        useRootNavigator = false;
        menuContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(24),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.group_add),
              title: Text('createRealm').tr(),
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed('realmNew').then((value) {
                  if (value != null) {
                    // Fire realm refresh event if needed
                    // eventBus.fire(const RealmsRefreshEvent());
                  }
                });
              },
            ),
            const Divider(),
            ...commonEntires,
            Gap(MediaQuery.of(context).padding.bottom + 16),
          ],
        );
        break;

      case FabMenuType.main:
        icon = Symbols.menu;
        useRootNavigator = false;
        menuContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(24),
            ...commonEntires,
            Gap(MediaQuery.of(context).padding.bottom + 16),
          ],
        );
        break;
    }

    return FloatingActionButton(
      elevation: elevation,
      child: Icon(icon),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: useRootNavigator,
          builder: (BuildContext context) => menuContent,
        );
      },
    );
  }
}
