import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_wrapper.dart';
import 'package:island/screens/tabs.dart';

import 'package:island/screens/explore.dart';
import 'package:island/screens/account.dart';
import 'package:island/screens/notification.dart';
import 'package:island/screens/wallet.dart';
import 'package:island/screens/account/relationship.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/screens/account/me/update.dart';
import 'package:island/screens/account/leveling.dart';
import 'package:island/screens/account/me/settings.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:island/screens/chat/room.dart';
import 'package:island/screens/chat/room_detail.dart';
import 'package:island/screens/chat/call.dart';
import 'package:island/screens/creators/hub.dart';
import 'package:island/screens/creators/posts/list.dart';
import 'package:island/screens/creators/stickers/stickers.dart';
import 'package:island/screens/creators/stickers/pack_detail.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/screens/posts/detail.dart';
import 'package:island/screens/posts/pub_profile.dart';
import 'package:island/screens/auth/login.dart';
import 'package:island/screens/auth/create_account.dart';
import 'package:island/screens/settings.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/screens/realm/detail.dart';
import 'package:island/screens/account/event_calendar.dart';
import 'package:island/screens/discovery/realms.dart';

// Shell route keys for nested navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _tabsShellKey = GlobalKey<NavigatorState>();

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppWrapper(child: child);
        },
        routes: [
          // Standalone routes without bottom navigation
          GoRoute(
            path: '/posts/compose',
            builder:
                (context, state) => PostComposeScreen(
                  initialState: state.extra as PostComposeInitialState?,
                ),
          ),
          GoRoute(
            path: '/posts/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PostEditScreen(id: id);
            },
          ),
          GoRoute(
            path: '/chat/:id/call',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CallScreen(roomId: id);
            },
          ),
          GoRoute(
            path: '/account/:name/calendar',
            builder: (context, state) {
              final name = state.pathParameters['name']!;
              return EventCalanderScreen(name: name);
            },
          ),
          ShellRoute(
            builder:
                (context, state, child) => CreatorHubShellScreen(child: child),
            routes: [
              GoRoute(
                path: '/creators',
                builder: (context, state) => const CreatorHubScreen(),
              ),
              GoRoute(
                path: '/creators/:name/posts',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return CreatorPostListScreen(pubName: name);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return StickersScreen(pubName: name);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers/new',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return NewStickerPacksScreen(pubName: name);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers/:packId/edit',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  final packId = state.pathParameters['packId']!;
                  return EditStickerPacksScreen(pubName: name, packId: packId);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers/:packId',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  final packId = state.pathParameters['packId']!;
                  return StickerPackDetailScreen(pubName: name, id: packId);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers/:packId/new',
                builder: (context, state) {
                  final packId = state.pathParameters['packId']!;
                  return NewStickersScreen(packId: packId);
                },
              ),
              GoRoute(
                path: '/creators/:name/stickers/:packId/:id/edit',
                builder: (context, state) {
                  final packId = state.pathParameters['packId']!;
                  final id = state.pathParameters['id']!;
                  return EditStickersScreen(id: id, packId: packId);
                },
              ),
              GoRoute(
                path: '/creators/new',
                builder: (context, state) => const NewPublisherScreen(),
              ),
              GoRoute(
                path: '/creators/:name/edit',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return EditPublisherScreen(name: name);
                },
              ),
            ],
          ),

          // Auth routes
          GoRoute(
            path: '/auth/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/auth/create-account',
            builder: (context, state) => const CreateAccountScreen(),
          ),

          // Other routes
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Main tabs with TabsScreen shell
          ShellRoute(
            navigatorKey: _tabsShellKey,
            builder: (context, state, child) {
              return TabsScreen(child: child);
            },
            routes: [
              // Explore tab
              ShellRoute(
                builder:
                    (context, state, child) => ExploreShellScreen(child: child),
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const ExploreScreen(),
                  ),
                  GoRoute(
                    path: '/posts/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PostDetailScreen(id: id);
                    },
                  ),
                  GoRoute(
                    path: '/publishers/:name',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return PublisherProfileScreen(name: name);
                    },
                  ),
                  GoRoute(
                    path: '/discovery/realms',
                    builder: (context, state) => const DiscoveryRealmsScreen(),
                  ),
                ],
              ),

              // Chat tab
              ShellRoute(
                builder:
                    (context, state, child) => ChatShellScreen(child: child),
                routes: [
                  GoRoute(
                    path: '/chat',
                    builder: (context, state) => const ChatListScreen(),
                  ),
                  GoRoute(
                    path: '/chat/new',
                    builder: (context, state) => const NewChatScreen(),
                  ),
                  GoRoute(
                    path: '/chat/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatRoomScreen(id: id);
                    },
                  ),
                  GoRoute(
                    path: '/chat/:id/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditChatScreen(id: id);
                    },
                  ),
                  GoRoute(
                    path: '/chat/:id/detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatDetailScreen(id: id);
                    },
                  ),
                ],
              ),

              // Realms tab
              GoRoute(
                path: '/realms',
                builder: (context, state) => const RealmListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const NewRealmScreen(),
                  ),
                  GoRoute(
                    path: ':slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug']!;
                      return RealmDetailScreen(slug: slug);
                    },
                  ),
                  GoRoute(
                    path: ':slug/edit',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug']!;
                      return EditRealmScreen(slug: slug);
                    },
                  ),
                ],
              ),

              // Account tab
              ShellRoute(
                builder:
                    (context, state, child) => AccountShellScreen(child: child),
                routes: [
                  GoRoute(
                    path: '/account',
                    builder: (context, state) => const AccountScreen(),
                  ),
                  GoRoute(
                    path: '/account/notifications',
                    builder: (context, state) => const NotificationScreen(),
                  ),
                  GoRoute(
                    path: '/account/wallet',
                    builder: (context, state) => const WalletScreen(),
                  ),
                  GoRoute(
                    path: '/account/relationships',
                    builder: (context, state) => const RelationshipScreen(),
                  ),
                  GoRoute(
                    path: '/account/:name',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return AccountProfileScreen(name: name);
                    },
                  ),
                  GoRoute(
                    path: '/account/me/update',
                    builder: (context, state) => const UpdateProfileScreen(),
                  ),
                  GoRoute(
                    path: '/account/me/leveling',
                    builder: (context, state) => const LevelingScreen(),
                  ),
                  GoRoute(
                    path: '/account/settings',
                    builder: (context, state) => const AccountSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Navigation helper functions
class AppRouter {
  static GoRouter of(BuildContext context) {
    return GoRouter.of(context);
  }

  static void go(BuildContext context, String path) {
    context.go(path);
  }

  static void push(BuildContext context, String path) {
    context.push(path);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}
