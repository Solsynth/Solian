import 'package:animations/animations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/about.dart';
import 'package:island/screens/developers/apps.dart';
import 'package:island/screens/developers/edit_app.dart';
import 'package:island/screens/developers/new_app.dart';
import 'package:island/screens/developers/hub.dart';
import 'package:island/screens/discovery/articles.dart';
import 'package:island/screens/posts/post_category_detail.dart';
import 'package:island/screens/posts/post_search.dart';
import 'package:island/widgets/app_wrapper.dart';
import 'package:island/screens/tabs.dart';
import 'package:island/screens/explore.dart';
import 'package:island/screens/discovery/article_detail.dart';
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
import 'package:island/screens/creators/posts/post_manage_list.dart';
import 'package:island/screens/creators/stickers/stickers.dart';
import 'package:island/screens/creators/stickers/pack_detail.dart';
import 'package:island/screens/stickers/marketplace.dart';
import 'package:island/screens/stickers/pack_detail.dart';
import 'package:island/screens/creators/poll/poll_list.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/creators/webfeed/webfeed_list.dart';
import 'package:island/screens/creators/webfeed/webfeed_edit.dart';
import 'package:island/screens/poll/poll_editor.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/screens/posts/post_detail.dart';
import 'package:island/screens/posts/pub_profile.dart';
import 'package:island/screens/auth/login.dart';
import 'package:island/screens/auth/create_account.dart';
import 'package:island/screens/settings.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/screens/realm/realm_detail.dart';
import 'package:island/screens/account/event_calendar.dart';
import 'package:island/screens/discovery/realms.dart';
import 'package:island/screens/reports/report_detail.dart';
import 'package:island/screens/reports/report_list.dart';

// Shell route keys for nested navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _tabsShellKey = GlobalKey<NavigatorState>();

Widget _tabPagesTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    fillColor: Theme.of(context).colorScheme.surface,
    child: child,
  );
}

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppWrapper(child: child);
        },
        routes: [
          // Standalone routes without bottom navigation
          GoRoute(
            name: 'postCompose',
            path: '/posts/compose',
            builder:
                (context, state) => PostComposeScreen(
                  initialState: state.extra as PostComposeInitialState?,
                  type:
                      int.tryParse(state.uri.queryParameters['type'] ?? '0') ??
                      0,
                ),
          ),
          GoRoute(
            name: 'postEdit',
            path: '/posts/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PostEditScreen(id: id);
            },
          ),
          GoRoute(
            name: 'chatCall',
            path: '/chat/:id/call',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CallScreen(roomId: id);
            },
          ),
          GoRoute(
            name: 'accountCalendar',
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
                name: 'creatorHub',
                path: '/creators',
                builder: (context, state) => const CreatorHubScreen(),
              ),
              // Web Feed Routes
              GoRoute(
                name: 'creatorFeeds',
                path: '/creators/:name/feeds',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return WebFeedListScreen(pubName: name);
                },
                routes: [
                  GoRoute(
                    name: 'creatorFeedNew',
                    path: 'new',
                    builder: (context, state) {
                      return WebFeedNewScreen(
                        pubName: state.pathParameters['name']!,
                      );
                    },
                  ),
                  GoRoute(
                    name: 'creatorFeedEdit',
                    path: ':feedId',
                    builder: (context, state) {
                      return WebFeedEditScreen(
                        pubName: state.pathParameters['name']!,
                        feedId: state.pathParameters['feedId'],
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'creatorPosts',
                path: '/creators/:name/posts',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return CreatorPostListScreen(pubName: name);
                },
              ),
              // Poll list route
              GoRoute(
                name: 'creatorPolls',
                path: '/creators/:name/polls',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return CreatorPollListScreen(pubName: name);
                },
              ),
              // Poll routes
              GoRoute(
                name: 'creatorPollNew',
                path: '/creators/:name/polls/new',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  // initialPollId left null for create; initialPublisher prefilled
                  return PollEditorScreen(initialPublisher: name);
                },
              ),
              GoRoute(
                name: 'creatorPollEdit',
                path: '/creators/:name/polls/:id/edit',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  final id = state.pathParameters['id']!;
                  return PollEditorScreen(
                    initialPollId: id,
                    initialPublisher: name,
                  );
                },
              ),
              GoRoute(
                name: 'creatorStickers',
                path: '/creators/:name/stickers',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return StickersScreen(pubName: name);
                },
              ),
              GoRoute(
                name: 'creatorStickerPackNew',
                path: '/creators/:name/stickers/new',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return NewStickerPacksScreen(pubName: name);
                },
              ),
              GoRoute(
                name: 'creatorStickerPackEdit',
                path: '/creators/:name/stickers/:packId/edit',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  final packId = state.pathParameters['packId']!;
                  return EditStickerPacksScreen(pubName: name, packId: packId);
                },
              ),
              GoRoute(
                name: 'creatorStickerPackDetail',
                path: '/creators/:name/stickers/:packId',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  final packId = state.pathParameters['packId']!;
                  return StickerPackDetailScreen(pubName: name, id: packId);
                },
              ),
              GoRoute(
                name: 'creatorStickerNew',
                path: '/creators/:name/stickers/:packId/new',
                builder: (context, state) {
                  final packId = state.pathParameters['packId']!;
                  return NewStickersScreen(packId: packId);
                },
              ),
              GoRoute(
                name: 'creatorStickerEdit',
                path: '/creators/:name/stickers/:packId/:id/edit',
                builder: (context, state) {
                  final packId = state.pathParameters['packId']!;
                  final id = state.pathParameters['id']!;
                  return EditStickersScreen(id: id, packId: packId);
                },
              ),
              GoRoute(
                name: 'creatorNew',
                path: '/creators/new',
                builder: (context, state) => const NewPublisherScreen(),
              ),
              GoRoute(
                name: 'creatorEdit',
                path: '/creators/:name/edit',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return EditPublisherScreen(name: name);
                },
              ),
            ],
          ),
          ShellRoute(
            builder:
                (context, state, child) =>
                    DeveloperHubShellScreen(child: child),
            routes: [
              GoRoute(
                name: 'developerHub',
                path: '/developers',
                builder: (context, state) => const DeveloperHubScreen(),
              ),
              GoRoute(
                name: 'developerApps',
                path: '/developers/:name/apps',
                builder:
                    (context, state) => CustomAppsScreen(
                      publisherName: state.pathParameters['name']!,
                    ),
              ),
              GoRoute(
                name: 'developerAppNew',
                path: '/developers/:name/apps/new',
                builder:
                    (context, state) => NewCustomAppScreen(
                      publisherName: state.pathParameters['name']!,
                    ),
              ),
              GoRoute(
                name: 'developerAppEdit',
                path: '/developers/:name/apps/:id',
                builder:
                    (context, state) => EditAppScreen(
                      publisherName: state.pathParameters['name']!,
                      id: state.pathParameters['id']!,
                    ),
              ),
            ],
          ),

          // Web articles
          GoRoute(
            name: 'articles',
            path: '/feeds/articles',
            builder: (context, state) => const ArticlesScreen(),
          ),
          GoRoute(
            name: 'articleDetail',
            path: '/feeds/articles/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ArticleDetailScreen(articleId: id);
            },
          ),

          // Auth routes
          GoRoute(
            name: 'login',
            path: '/auth/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            name: 'createAccount',
            path: '/auth/create-account',
            builder: (context, state) => const CreateAccountScreen(),
          ),

          // Other routes
          GoRoute(
            name: 'settings',
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            name: 'about',
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),

          // Main tabs with TabsScreen shell
          ShellRoute(
            navigatorKey: _tabsShellKey,
            builder: (context, state, child) {
              return TabsScreen(child: child);
            },
            routes: [
              // Explore tab
              GoRoute(
                name: 'explore',
                path: '/',
                pageBuilder:
                    (context, state) => CustomTransitionPage(
                      key: const ValueKey('explore'),
                      child: const ExploreScreen(),
                      transitionsBuilder: _tabPagesTransitionBuilder,
                    ),
              ),
              GoRoute(
                name: 'postSearch',
                path: '/posts/search',
                builder: (context, state) => const PostSearchScreen(),
              ),
              GoRoute(
                name: 'postDetail',
                path: '/posts/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PostDetailScreen(id: id);
                },
              ),
              GoRoute(
                name: 'postCategoryDetail',
                path: '/posts/categories/:slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  return PostCategoryDetailScreen(slug: slug, isCategory: true);
                },
              ),
              GoRoute(
                name: 'postTagDetail',
                path: '/posts/tags/:slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  return PostCategoryDetailScreen(
                    slug: slug,
                    isCategory: false,
                  );
                },
              ),
              GoRoute(
                name: 'publisherProfile',
                path: '/publishers/:name',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return PublisherProfileScreen(name: name);
                },
              ),
              GoRoute(
                name: 'discoveryRealms',
                path: '/discovery/realms',
                builder: (context, state) => const DiscoveryRealmsScreen(),
              ),

              // Chat tab
              ShellRoute(
                pageBuilder:
                    (context, state, child) => CustomTransitionPage(
                      key: const ValueKey('chat'),
                      child: ChatShellScreen(child: child),
                      transitionsBuilder: _tabPagesTransitionBuilder,
                    ),
                routes: [
                  GoRoute(
                    name: 'chatList',
                    path: '/chat',
                    builder: (context, state) => const ChatListScreen(),
                  ),
                  GoRoute(
                    name: 'chatNew',
                    path: '/chat/new',
                    builder: (context, state) => const NewChatScreen(),
                  ),
                  GoRoute(
                    name: 'chatRoom',
                    path: '/chat/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatRoomScreen(id: id);
                    },
                  ),
                  GoRoute(
                    name: 'chatEdit',
                    path: '/chat/:id/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditChatScreen(id: id);
                    },
                  ),
                  GoRoute(
                    name: 'chatDetail',
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
                name: 'realmList',
                path: '/realms',
                pageBuilder:
                    (context, state) => CustomTransitionPage(
                      key: const ValueKey('realms'),
                      child: const RealmListScreen(),
                      transitionsBuilder: _tabPagesTransitionBuilder,
                    ),
                routes: [
                  GoRoute(
                    name: 'realmNew',
                    path: 'new',
                    builder: (context, state) => const NewRealmScreen(),
                  ),
                  GoRoute(
                    name: 'realmDetail',
                    path: ':slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug']!;
                      return RealmDetailScreen(slug: slug);
                    },
                  ),
                  GoRoute(
                    name: 'realmEdit',
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
                pageBuilder:
                    (context, state, child) => CustomTransitionPage(
                      key: const ValueKey('account'),
                      child: AccountShellScreen(child: child),
                      transitionsBuilder: _tabPagesTransitionBuilder,
                    ),
                routes: [
                  GoRoute(
                    name: 'account',
                    path: '/account',
                    builder: (context, state) => const AccountScreen(),
                  ),
                  // Sticker marketplace (user-facing, no publisher)
                  GoRoute(
                    name: 'stickerMarketplace',
                    path: '/stickers',
                    builder:
                        (context, state) => const MarketplaceStickersScreen(),
                    routes: [
                      GoRoute(
                        name: 'stickerPackDetail',
                        path: ':packId',
                        builder: (context, state) {
                          final packId = state.pathParameters['packId']!;
                          return MarketplaceStickerPackDetailScreen(id: packId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: 'notifications',
                    path: '/account/notifications',
                    builder: (context, state) => const NotificationScreen(),
                  ),
                  GoRoute(
                    name: 'wallet',
                    path: '/account/wallet',
                    builder: (context, state) => const WalletScreen(),
                  ),
                  GoRoute(
                    name: 'relationships',
                    path: '/account/relationships',
                    builder: (context, state) => const RelationshipScreen(),
                  ),
                  GoRoute(
                    name: 'profileUpdate',
                    path: '/account/me/update',
                    builder: (context, state) => const UpdateProfileScreen(),
                  ),
                  GoRoute(
                    name: 'leveling',
                    path: '/account/me/leveling',
                    builder: (context, state) => const LevelingScreen(),
                  ),
                  GoRoute(
                    name: 'accountSettings',
                    path: '/account/me/settings',
                    builder: (context, state) => const AccountSettingsScreen(),
                  ),
                  GoRoute(
                    name: 'reportList',
                    path: '/safety/reports/me',
                    builder: (context, state) => const AbuseReportListScreen(),
                  ),
                  GoRoute(
                    name: 'reportDetail',
                    path: '/safety/reports/me/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AbuseReportDetailScreen(reportId: id);
                    },
                  ),
                ],
              ),

              GoRoute(
                name: 'accountProfile',
                path: '/account/:name',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return AccountProfileScreen(name: name);
                },
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

  static void pushNamed(BuildContext context, String name) {
    context.pushNamed(name);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}
