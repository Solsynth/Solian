import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:convert';
import 'package:island/core/models/route_item.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/widgets/draggable_log_overlay.dart';
import 'package:island/core/debug_sheet.dart';
import 'package:island/plugins/widgets/plugin_ui_bridge.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CommandPaletteWidget extends HookConsumerWidget {
  final VoidCallback onDismiss;

  const CommandPaletteWidget({super.key, required this.onDismiss});

  static List<SpecialAction> _getSpecialActions(
    WidgetRef ref,
    bool isDeveloperMode,
  ) {
    return [
      SpecialAction(
        name: 'postCompose'.tr(),
        description: 'postComposeDescription'.tr(),
        icon: Symbols.edit,
        action: () {
          eventBus.fire(const ShowComposeSheetEvent());
        },
      ),
      SpecialAction(
        name: 'notifications'.tr(),
        description: 'notificationsDescription'.tr(),
        searchableAliases: ['notifications', 'alert', 'bell'],
        icon: Symbols.notifications,
        action: () {
          eventBus.fire(const ShowNotificationModalEvent());
        },
      ),
      SpecialAction(
        name: 'Log Viewer',
        description: 'Open the log viewer overlay',
        searchableAliases: [
          'logs',
          'debug',
          'terminal',
          'console',
          'log viewer',
        ],
        icon: Symbols.terminal,
        action: () {
          toggleLogOverlay();
        },
      ),
      if (isDeveloperMode)
        SpecialAction(
          name: 'Debug Panel',
          description: 'Open the debug panel overlay',
          searchableAliases: ['debug', 'panel', 'bug', 'debug panel'],
          icon: Symbols.bug_report,
          action: () {
            toggleDebugOverlay(ref);
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
    final isDeveloperMode = ref.watch(developerModeProvider);

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
        : kAvailableRoutes
              .where((route) {
                final query = searchQuery.value.toLowerCase();
                return route.name.toLowerCase().contains(query) ||
                    route.description.toLowerCase().contains(query) ||
                    route.searchableAliases.any(
                      (e) => e.toLowerCase().contains(query),
                    );
              })
              .take(5) // Limit to 5 results
              .toList();

    final filteredSpecialActions = searchQuery.value.isEmpty
        ? <SpecialAction>[]
        : _getSpecialActions(ref, isDeveloperMode)
              .where((action) {
                final query = searchQuery.value.toLowerCase();
                return action.name.toLowerCase().contains(query) ||
                    action.description.toLowerCase().contains(query) ||
                    action.searchableAliases.any(
                      (e) => e.toLowerCase().contains(query),
                    );
              })
              .take(5) // Limit to 5 results
              .toList();

    // Plugin commands
    final pluginCommandsApi = PluginManager().getApi<CommandsApi>();
    final filteredPluginCommands = searchQuery.value.isEmpty
        ? <SpecialAction>[]
        : (pluginCommandsApi?.commands ?? [])
              .where((cmd) {
                final query = searchQuery.value.toLowerCase().replaceFirst(
                  RegExp(r'^/'),
                  '',
                );
                return cmd.name.toLowerCase().contains(query) ||
                    cmd.description.toLowerCase().contains(query);
              })
              .map(
                (cmd) => SpecialAction(
                  name: '/${cmd.name}',
                  description: cmd.description,
                  icon: Symbols.extension,
                  searchableAliases: [cmd.name],
                  action: () {
                    final runtime =
                        PluginManager().plugins[cmd.pluginId]?.runtime;
                    if (runtime != null) {
                      final result = pluginCommandsApi!.executeCommand(
                        cmd,
                        runtime,
                      );
                      if (result != null) {
                        _showCommandResult(context, result, runtime: runtime);
                      }
                    }
                  },
                ),
              )
              .take(5)
              .toList();

    final filteredFallbacks =
        searchQuery.value.isNotEmpty &&
            filteredChats.isEmpty &&
            filteredSpecialActions.isEmpty &&
            filteredRoutes.isEmpty
        ? _getFallbackActions(ref, context, searchQuery.value)
        : <FallbackAction>[];

    // Combine results: fallbacks first, then chats, special actions, plugin commands, routes
    final allResults = [
      ...filteredFallbacks,
      ...filteredChats,
      ...filteredSpecialActions,
      ...filteredPluginCommands,
      ...filteredRoutes,
    ];

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
              _executeItem(context, ref, item);
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
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
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
                              hintText: 'searchChatsAndPages'.tr(),
                              leading: CircleAvatar(
                                child: const Icon(Symbols.keyboard_command_key),
                              ).padding(horizontal: 8),
                              onSubmitted: !isDesktop() && allResults.isNotEmpty
                                  ? (value) => _executeItem(
                                      context,
                                      ref,
                                      allResults[0],
                                    )
                                  : null,
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
                                          } else if (item is FallbackAction) {
                                            return _FallbackSearchResult(
                                              action: item,
                                              isFocused:
                                                  index == focusedIndex.value,
                                              onTap: () {
                                                onDismiss();
                                                item.action();
                                              },
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
      ),
    );
  }

  void _navigateToChat(BuildContext context, WidgetRef ref, SnChatRoom room) {
    onDismiss();
    ref.read(routerProvider).navigate(ChatRoomRoute(id: room.id));
  }

  void _navigateToRoute(BuildContext context, WidgetRef ref, RouteItem route) {
    onDismiss();
    ref.read(routerProvider).navigatePath(route.path);
  }

  void _showCommandResult(
    BuildContext context,
    Object result, {
    required dynamic runtime,
  }) {
    final descriptor = result is String
        ? PluginUiRenderer.parse(result)
        : result is Map && result['type'] is String
        ? PluginUiDescriptor(
            type: result['type'] as String,
            data: result.map((key, value) => MapEntry(key.toString(), value)),
          )
        : null;
    if (descriptor != null) {
      PluginUiDescriptor currentDescriptor = descriptor;
      showDialog<void>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => Dialog.fullscreen(
            child: PluginUiRenderer(
              descriptor: currentDescriptor,
              onCallback: (callback, [value]) {
                final next = runtime.callFunction(
                  callback,
                  value == null ? null : [value],
                );
                final nextDescriptor = next is String
                    ? PluginUiRenderer.parse(next)
                    : next is Map && next['type'] is String
                    ? PluginUiDescriptor(
                        type: next['type'] as String,
                        data: next.map(
                          (key, value) => MapEntry(key.toString(), value),
                        ),
                      )
                    : null;
                if (nextDescriptor != null) {
                  setDialogState(() => currentDescriptor = nextDescriptor);
                }
              },
            ),
          ),
        ),
      );
      return;
    }
    // Parse UI descriptor from plugin if it's a JSON string
    String title = 'Command Result';
    String body = result.toString();

    if (result is String) {
      try {
        final decoded = jsonDecode(result);
        if (decoded is Map<String, dynamic>) {
          title = decoded['title']?.toString() ?? title;
          body =
              decoded['body']?.toString() ??
              decoded['content']?.toString() ??
              body;
        }
      } catch (_) {}
    }

    showInfoAlert(body, title);
  }

  void _executeItem(BuildContext context, WidgetRef ref, dynamic item) {
    if (item is SnChatRoom) {
      _navigateToChat(context, ref, item);
    } else if (item is SpecialAction) {
      onDismiss();
      item.action();
    } else if (item is RouteItem) {
      _navigateToRoute(context, ref, item);
    } else if (item is FallbackAction) {
      onDismiss();
      item.action();
    }
  }

  static List<FallbackAction> _getFallbackActions(
    WidgetRef ref,
    BuildContext context,
    String query,
  ) {
    final settings = ref.watch(appSettingsProvider);

    final List<FallbackAction> actions = [];

    // Check if query is a solian:// deep link
    final Uri? uri = Uri.tryParse(query);
    final isSolianLink = uri != null && uri.scheme == 'solian';
    final isValidUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    final isDomain = RegExp(
      r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    ).hasMatch(query);

    if (isSolianLink) {
      final path = '/${uri.host}${uri.path}';
      actions.add(
        FallbackAction(
          name: 'Open Link',
          description: 'Open $query in app',
          icon: Symbols.open_in_new,
          action: () {
            final params = uri.queryParameters;
            if (path == '/auth/authorize') {
              ref
                  .read(routerProvider)
                  .push(
                    AuthorizeRoute(
                      clientId: params['client_id'],
                      redirectUri: params['redirect_uri'],
                      scope: params['scope'],
                      state: params['state'],
                      responseType: params['response_type'],
                    ),
                  );
            } else if (path == '/auth/callback' &&
                params.containsKey('token')) {
              // Handled via deep link service; just navigate home
              ref.read(routerProvider).navigatePath('/');
            } else {
              ref.read(routerProvider).navigatePath(path);
            }
          },
        ),
      );
    }

    if (!isSolianLink && (isValidUrl || isDomain)) {
      final finalUri = isDomain ? Uri.parse('https://$query') : uri!;
      actions.add(
        FallbackAction(
          name: 'Open URL',
          description: 'Open ${finalUri.toString()} in browser',
          icon: Symbols.open_in_new,
          action: () async {
            if (await canLaunchUrl(finalUri)) {
              await launchUrl(finalUri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      );
    }

    // Ask the AI
    // Bugged, DO NOT USE
    // actions.add(
    //   FallbackAction(
    //     name: 'Ask the AI',
    //     description: 'Ask "$query" to the AI',
    //     icon: Symbols.bubble_chart,
    //     action: () {
    //       eventBus.fire(ShowThoughtSheetEvent(initialMessage: query));
    //     },
    //   ),
    // );

    // Search the web
    actions.add(
      FallbackAction(
        name: 'Search the web',
        description: 'Search "$query" on the Internet',
        icon: Symbols.search,
        action: () async {
          final searchUri = Uri.parse(
            settings.dashSearchEngine != null
                ? settings.dashSearchEngine!.replaceFirst('%s', query)
                : 'https://www.google.com/search?q=$query',
          );
          if (await canLaunchUrl(searchUri)) {
            await launchUrl(searchUri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );

    return actions;
  }
}

class FallbackAction {
  final String name;
  final String description;
  final IconData icon;
  final VoidCallback action;
  final List<String> searchableAliases;

  const FallbackAction({
    required this.name,
    required this.description,
    required this.icon,
    required this.action,
    this.searchableAliases = const [],
  });
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

class _FallbackSearchResult extends StatelessWidget {
  final FallbackAction action;
  final bool isFocused;
  final VoidCallback onTap;

  const _FallbackSearchResult({
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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
        leading: ChatRoomAvatar(
          room: room,
          isDirect: isDirect,
          summary: summary,
          validMembers: validMembers,
        ),
        title: Text(titleText),
        subtitle: buildSubtitle(),
        onTap: onTap,
      ),
    );
  }
}
