import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/route_item.dart';
import 'package:island/pods/chat/chat_room.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/services/event_bus.dart';

class SpecialAction {
  final String name;
  final String description;
  final IconData icon;
  final VoidCallback action;

  const SpecialAction({
    required this.name,
    required this.description,
    required this.icon,
    required this.action,
  });
}

class CommandPattleWidget extends HookConsumerWidget {
  final VoidCallback onDismiss;

  const CommandPattleWidget({super.key, required this.onDismiss});

  static final List<RouteItem> _availableRoutes = [
    RouteItem(
      name: 'Dashboard',
      path: '/',
      description: 'Main dashboard',
      icon: Symbols.home,
    ),
    RouteItem(
      name: 'Explore',
      path: '/explore',
      description: 'Discover content',
      icon: Symbols.explore,
    ),
    RouteItem(
      name: 'Post Search',
      path: '/posts/search',
      description: 'Search posts',
      icon: Symbols.search,
    ),
    RouteItem(
      name: 'Post Shuffle',
      path: '/posts/shuffle',
      description: 'Random posts',
      icon: Symbols.shuffle,
    ),
    RouteItem(
      name: 'Post Categories',
      path: '/posts/categories',
      description: 'Browse categories',
      icon: Symbols.category,
    ),
    RouteItem(
      name: 'Discovery Realms',
      path: '/discovery/realms',
      description: 'Explore realms',
      icon: Symbols.public,
    ),
    RouteItem(
      name: 'Chat',
      path: '/chat',
      description: 'Messages and conversations',
      icon: Symbols.chat,
    ),
    RouteItem(
      name: 'Realms',
      path: '/realms',
      description: 'Community realms',
      icon: Symbols.group,
    ),
    RouteItem(
      name: 'Account',
      path: '/account',
      description: 'Your profile and settings',
      icon: Symbols.person,
    ),
    RouteItem(
      name: 'Sticker Marketplace',
      path: '/stickers',
      description: 'Browse sticker packs',
      icon: Symbols.emoji_emotions,
    ),
    RouteItem(
      name: 'Web Feeds',
      path: '/feeds',
      description: 'RSS and web feeds',
      icon: Symbols.feed,
    ),
    RouteItem(
      name: 'Wallet',
      path: '/account/wallet',
      description: 'Your digital wallet',
      icon: Symbols.account_balance_wallet,
    ),
    RouteItem(
      name: 'Relationships',
      path: '/account/relationships',
      description: 'Friends and connections',
      icon: Symbols.people,
    ),
    RouteItem(
      name: 'Update Profile',
      path: '/account/me/update',
      description: 'Edit your profile',
      icon: Symbols.edit,
    ),
    RouteItem(
      name: 'Leveling',
      path: '/account/me/leveling',
      description: 'Your progress and levels',
      icon: Symbols.trending_up,
    ),
    RouteItem(
      name: 'Account Settings',
      path: '/account/me/settings',
      description: 'App preferences',
      icon: Symbols.settings,
    ),
    RouteItem(
      name: 'Reports',
      path: '/safety/reports/me',
      description: 'Your abuse reports',
      icon: Symbols.report,
    ),
    RouteItem(
      name: 'Files',
      path: '/files',
      description: 'File manager',
      icon: Symbols.folder,
    ),
    RouteItem(
      name: 'Thought',
      path: '/thought',
      description: 'AI assistant',
      icon: Symbols.psychology,
    ),
    RouteItem(
      name: 'Creator Hub',
      path: '/creators',
      description: 'Content creation tools',
      icon: Symbols.create,
    ),
    RouteItem(
      name: 'Developer Hub',
      path: '/developers',
      description: 'Developer tools',
      icon: Symbols.code,
    ),
    RouteItem(
      name: 'Logs',
      path: '/logs',
      description: 'Application logs',
      icon: Symbols.bug_report,
    ),
    RouteItem(
      name: 'Articles',
      path: '/feeds/articles',
      description: 'Web articles',
      icon: Symbols.article,
    ),
    RouteItem(
      name: 'Login',
      path: '/auth/login',
      description: 'Sign in to your account',
      icon: Symbols.login,
    ),
    RouteItem(
      name: 'Create Account',
      path: '/auth/create-account',
      description: 'Create a new account',
      icon: Symbols.person_add,
    ),
    RouteItem(
      name: 'Settings',
      path: '/settings',
      description: 'Application settings',
      icon: Symbols.settings,
    ),
    RouteItem(
      name: 'About',
      path: '/about',
      description: 'About this app',
      icon: Symbols.info,
    ),
  ];

  static List<SpecialAction> _getSpecialActions(BuildContext context) {
    return [
      SpecialAction(
        name: 'Compose Post',
        description: 'Create a new post',
        icon: Symbols.edit,
        action: () {
          eventBus.fire(const ShowComposeSheetEvent());
        },
      ),
      SpecialAction(
        name: 'Notifications',
        description: 'View your notifications',
        icon: Symbols.notifications,
        action: () {
          eventBus.fire(const ShowNotificationSheetEvent());
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final searchQuery = useState('');
    final focusedIndex = useState<int?>(null);
    final scrollController = useScrollController();

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      ),
    );
    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      ),
    );

    useEffect(() {
      focusNode.requestFocus();
      animationController.forward();
      return null;
    }, []);

    useEffect(() {
      void listener() {
        searchQuery.value = textController.text;
        // Reset focused index when search changes
        focusedIndex.value = null;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    final chatRooms = ref.watch(chatRoomJoinedProvider);

    bool isDesktop() =>
        kIsWeb ||
        (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS));

    final filteredChats = chatRooms.maybeWhen(
      data: (rooms) {
        if (searchQuery.value.isEmpty) return <SnChatRoom>[];
        return rooms
            .where((room) {
              final title = room.name ?? '';
              final desc = room.description ?? '';
              final query = searchQuery.value.toLowerCase();
              return title.toLowerCase().contains(query) ||
                  desc.toLowerCase().contains(query) ||
                  (room.members?.any(
                        (member) =>
                            member.account.name.contains(query) ||
                            member.account.nick.contains(query),
                      ) ??
                      false);
            })
            .take(5) // Limit to 5 results
            .toList();
      },
      orElse: () => <SnChatRoom>[],
    );

    final filteredRoutes = searchQuery.value.isEmpty
        ? <RouteItem>[]
        : _availableRoutes
              .where((route) {
                final query = searchQuery.value.toLowerCase();
                return route.name.toLowerCase().contains(query) ||
                    route.description.toLowerCase().contains(query);
              })
              .take(5) // Limit to 5 results
              .toList();

    final filteredSpecialActions = searchQuery.value.isEmpty
        ? <SpecialAction>[]
        : _getSpecialActions(context)
              .where((action) {
                final query = searchQuery.value.toLowerCase();
                return action.name.toLowerCase().contains(query) ||
                    action.description.toLowerCase().contains(query);
              })
              .take(5) // Limit to 5 results
              .toList();

    // Combine results: chats first, then special actions, then routes
    final allResults = [
      ...filteredChats,
      ...filteredSpecialActions,
      ...filteredRoutes,
    ];

    // Update focused index when results change
    useEffect(() {
      if (allResults.isNotEmpty && focusedIndex.value == null) {
        focusedIndex.value = 0;
      } else if (allResults.isEmpty) {
        focusedIndex.value = null;
      }
      return null;
    }, [allResults]);

    // Scroll to focused item
    useEffect(() {
      if (focusedIndex.value != null && allResults.isNotEmpty) {
        // Wait for the next frame to ensure ScrollController is attached
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            // Estimate item height (ListTile is typically around 72-88 pixels)
            const double estimatedItemHeight = 80.0;
            final double itemTopOffset =
                focusedIndex.value! * estimatedItemHeight;
            final double viewportHeight =
                scrollController.position.viewportDimension;
            final double centeredOffset =
                itemTopOffset -
                (viewportHeight / 2) +
                (estimatedItemHeight / 2);

            // Animate scroll to center the focused item
            scrollController.animateTo(
              centeredOffset.clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return null;
    }, [focusedIndex.value]);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            onDismiss();
          } else if (isDesktop()) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              final item = allResults[focusedIndex.value ?? 0];
              if (item is SnChatRoom) {
                _navigateToChat(context, ref, item);
              } else if (item is SpecialAction) {
                onDismiss();
                item.action();
              } else if (item is RouteItem) {
                _navigateToRoute(context, ref, item);
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (allResults.isNotEmpty) {
                if (focusedIndex.value == null) {
                  focusedIndex.value = 0;
                } else {
                  focusedIndex.value = math.max(0, focusedIndex.value! - 1);
                }
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (allResults.isNotEmpty) {
                if (focusedIndex.value == null) {
                  focusedIndex.value = 0;
                } else {
                  focusedIndex.value = math.min(
                    allResults.length - 1,
                    focusedIndex.value! + 1,
                  );
                }
              }
            }
          }
        }
      },
      child: GestureDetector(
        onTap: onDismiss,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) => Opacity(
                  opacity: opacityAnimation,
                  child: Transform.scale(scale: scaleAnimation, child: child),
                ),
                child: GestureDetector(
                  onTap:
                      () {}, // Prevent tap from dismissing when tapping inside
                  child: Container(
                    width: math.max(
                      MediaQuery.of(context).size.width * 0.6,
                      320,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 500,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SearchBar(
                            controller: textController,
                            focusNode: focusNode,
                            hintText: 'Search chats and pages...',
                            leading: CircleAvatar(
                              child: const Icon(Symbols.keyboard_command_key),
                            ).padding(horizontal: 8),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            child: allResults.isNotEmpty
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 300,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      controller: scrollController,
                                      shrinkWrap: true,
                                      itemCount: allResults.length,
                                      itemBuilder: (context, index) {
                                        final item = allResults[index];
                                        if (item is SnChatRoom) {
                                          return _ChatRoomSearchResult(
                                            room: item,
                                            isFocused:
                                                index == focusedIndex.value,
                                            onTap: () => _navigateToChat(
                                              context,
                                              ref,
                                              item,
                                            ),
                                          );
                                        } else if (item is SpecialAction) {
                                          return _SpecialActionSearchResult(
                                            action: item,
                                            isFocused:
                                                index == focusedIndex.value,
                                            onTap: () {
                                              onDismiss();
                                              item.action();
                                            },
                                          );
                                        } else if (item is RouteItem) {
                                          return _RouteSearchResult(
                                            route: item,
                                            isFocused:
                                                index == focusedIndex.value,
                                            onTap: () => _navigateToRoute(
                                              context,
                                              ref,
                                              item,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, WidgetRef ref, SnChatRoom room) {
    onDismiss();
    if (isWideScreen(context)) {
      debugPrint('${room.name}');
      ref
          .read(routerProvider)
          .replaceNamed('chatRoom', pathParameters: {'id': room.id});
    } else {
      ref
          .read(routerProvider)
          .pushNamed('chatRoom', pathParameters: {'id': room.id});
    }
  }

  void _navigateToRoute(BuildContext context, WidgetRef ref, RouteItem route) {
    onDismiss();
    ref.read(routerProvider).go(route.path);
  }
}

class _RouteSearchResult extends StatelessWidget {
  final RouteItem route;
  final bool isFocused;
  final VoidCallback onTap;

  const _RouteSearchResult({
    required this.route,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFocused
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          child: Icon(route.icon),
        ),
        title: Text(route.name),
        subtitle: Text(route.description),
        onTap: onTap,
      ),
    );
  }
}

class _SpecialActionSearchResult extends StatelessWidget {
  final SpecialAction action;
  final bool isFocused;
  final VoidCallback onTap;

  const _SpecialActionSearchResult({
    required this.action,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFocused
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          child: Icon(action.icon),
        ),
        title: Text(action.name),
        subtitle: Text(action.description),
        onTap: onTap,
      ),
    );
  }
}

class _ChatRoomSearchResult extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isFocused;
  final VoidCallback onTap;

  const _ChatRoomSearchResult({
    required this.room,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    var validMembers = room.members ?? [];
    if (validMembers.isNotEmpty && userInfo.value != null) {
      validMembers = validMembers
          .where((e) => e.accountId != userInfo.value!.id)
          .toList();
    }

    String titleText;
    if (room.type == 1 && room.name == null) {
      if (room.members?.isNotEmpty ?? false) {
        titleText = validMembers.map((e) => e.account.nick).join(', ');
      } else {
        titleText = 'Direct Message';
      }
    } else {
      titleText = room.name ?? '';
    }

    Widget buildSubtitle() {
      return summary.when(
        data: (data) => data == null
            ? (room.type == 1 && room.description == null
                  ? Text(
                      validMembers.map((e) => '@${e.account.name}').join(', '),
                    )
                  : Text(room.description ?? ''))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.unreadCount > 0)
                    Text(
                      'unreadMessages'.plural(data.unreadCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (data.lastMessage == null)
                    room.type == 1 && room.description == null
                        ? Text(
                            validMembers
                                .map((e) => '@${e.account.name}')
                                .join(', '),
                          )
                        : Text(room.description ?? '')
                  else
                    Row(
                      spacing: 4,
                      children: [
                        Badge(
                          label: Text(data.lastMessage!.sender.account.nick),
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            (data.lastMessage!.content?.isNotEmpty ?? false)
                                ? data.lastMessage!.content!
                                : 'messageNone'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            RelativeTime(
                              context,
                            ).format(data.lastMessage!.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
        loading: () => room.type == 1 && room.description == null
            ? Text(validMembers.map((e) => '@${e.account.name}').join(', '))
            : Text(room.description ?? ''),
        error: (_, _) => room.type == 1 && room.description == null
            ? Text(validMembers.map((e) => '@${e.account.name}').join(', '))
            : Text(room.description ?? ''),
      );
    }

    final isDirect = room.type == 1;

    return Container(
      decoration: BoxDecoration(
        color: isFocused
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: ListTile(
        leading: Badge(
          isLabelVisible: summary.maybeWhen(
            data: (data) => (data?.unreadCount ?? 0) > 0,
            orElse: () => false,
          ),
          child: (isDirect && room.picture?.id == null)
              ? SplitAvatarWidget(
                  filesId: validMembers
                      .map((e) => e.account.profile.picture?.id)
                      .toList(),
                )
              : room.picture?.id == null
              ? CircleAvatar(child: Text((room.name ?? 'DM')[0].toUpperCase()))
              : ProfilePictureWidget(
                  fileId: room.picture?.id,
                ), // Placeholder for now
        ),
        title: Text(titleText),
        subtitle: buildSubtitle(),
        onTap: onTap,
      ),
    );
  }
}
