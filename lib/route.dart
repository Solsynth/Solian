import 'dart:io' show Platform;
import 'package:animations/animations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/about.dart';
import 'package:island/screens/dashboard/dash.dart';
import 'package:island/screens/developers/app_detail.dart';
import 'package:island/screens/developers/bot_detail.dart';
import 'package:island/screens/developers/hub.dart';
import 'package:island/screens/developers/edit_project.dart';
import 'package:island/screens/developers/new_project.dart';
import 'package:island/screens/discovery/articles.dart';
import 'package:island/models/file.dart';
import 'package:island/screens/files/file_list.dart';
import 'package:island/screens/files/file_detail.dart';
import 'package:island/screens/posts/post_categories_list.dart';
import 'package:island/screens/posts/post_category_detail.dart';
import 'package:island/screens/search.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/app_wrapper.dart';
import 'package:island/screens/tabs.dart';
import 'package:island/screens/explore.dart';
import 'package:island/screens/discovery/article_detail.dart';
import 'package:island/screens/account.dart';
import 'package:island/screens/wallet.dart';
import 'package:island/screens/account/relationship.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/screens/account/me/profile_update.dart';
import 'package:island/screens/account/leveling.dart';
import 'package:island/screens/account/me/account_settings.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:island/screens/chat/room.dart';
import 'package:island/screens/chat/room_detail.dart';
import 'package:island/screens/chat/search_messages.dart';
import 'package:island/screens/thought/think.dart';
import 'package:island/screens/creators/hub.dart';
import 'package:island/screens/creators/posts/post_manage_list.dart';
import 'package:island/screens/creators/stickers/stickers.dart';
import 'package:island/screens/stickers/sticker_marketplace.dart';
import 'package:island/screens/stickers/pack_detail.dart';
import 'package:island/screens/discovery/feeds/feed_marketplace.dart';
import 'package:island/screens/discovery/feeds/feed_detail.dart';
import 'package:island/screens/creators/poll/poll_list.dart';
import 'package:island/screens/creators/sites/site_detail.dart';
import 'package:island/screens/creators/sites/site_list.dart';
import 'package:island/screens/creators/webfeed/webfeed_list.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/screens/posts/compose_article.dart';
import 'package:island/screens/posts/post_detail.dart';
import 'package:island/screens/posts/publisher_profile.dart';
import 'package:island/screens/auth/login.dart';
import 'package:island/screens/auth/create_account.dart';
import 'package:island/screens/settings.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/screens/realm/realm_form.dart';
import 'package:island/screens/realm/realm_detail.dart';
import 'package:island/screens/discovery/realms.dart';
import 'package:island/screens/reports/report_detail.dart';
import 'package:island/screens/reports/report_list.dart';
import 'package:island/talker.dart';
import 'package:island/widgets/post/post_shuffle.dart';
import 'package:talker_flutter/talker_flutter.dart';

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

bool get _supportsAnalytics =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [
      if (_supportsAnalytics)
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      TalkerRouteObserver(talker),
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
            name: 'articleCompose',
            path: '/articles/compose',
            builder: (context, state) => ArticleComposeScreen(
              initialState: state.extra as PostComposeInitialState?,
            ),
          ),
          GoRoute(
            name: 'articleEdit',
            path: '/articles/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ArticleEditScreen(id: id);
            },
          ),
          GoRoute(
            name: 'logs',
            path: '/logs',
            builder: (context, state) => TalkerScreen(
              talker: talker,
              appBarTitle: 'Debug Logs',
              appBarLeading: const PageBackButton(),
              theme: TalkerScreenTheme.fromTheme(Theme.of(context)),
            ),
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

          // File routes
          GoRoute(
            name: 'fileDetail',
            path: '/files/:id',
            builder: (context, state) {
              // For now, we'll need to pass the file object through extra
              // This will be updated when we modify the file list navigation
              final file = state.extra as SnCloudFile?;
              if (file != null) {
                return FileDetailScreen(item: file);
              }
              // Fallback - this shouldn't happen in normal flow
              Navigator.of(context).pop();
              return const SizedBox.shrink();
            },
          ),

          // Post routes
          GoRoute(
            name: 'postShuffle',
            path: '/posts/shuffle',
            builder: (context, state) => const PostShuffleScreen(),
          ),
          GoRoute(
            name: 'postCategories',
            path: '/posts/categories',
            builder: (context, state) => const PostCategoriesListScreen(),
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
              return PostCategoryDetailScreen(slug: slug, isCategory: false);
            },
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
            name: 'publisherProfile',
            path: '/publishers/:name',
            builder: (context, state) {
              final name = state.pathParameters['name']!;
              return PublisherProfileScreen(name: name);
            },
          ),

          GoRoute(
            name: 'universalSearch',
            path: '/search',
            builder: (context, state) {
              final initialTab = state.uri.queryParameters['tab'];
              SearchTab tab;
              if (initialTab == 'realms') {
                tab = SearchTab.realms;
              } else if (initialTab == 'fediverse') {
                tab = SearchTab.fediverse;
              } else {
                tab = SearchTab.posts;
              }
              return UniversalSearchScreen(initialTab: tab);
            },
          ),

          // Main tabs with TabsScreen shell
          ShellRoute(
            navigatorKey: _tabsShellKey,
            builder: (context, state, child) {
              return TabsScreen(child: child);
            },
            routes: [
              // Dashboard tab
              GoRoute(
                name: 'dashboard',
                path: '/',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: const ValueKey('dashboard'),
                  child: const DashboardScreen(),
                  transitionsBuilder: _tabPagesTransitionBuilder,
                ),
              ),
              // Explore tab
              GoRoute(
                name: 'explore',
                path: '/explore',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: const ValueKey('explore'),
                  child: const ExploreScreen(),
                  transitionsBuilder: _tabPagesTransitionBuilder,
                ),
              ),

              GoRoute(
                name: 'discoveryRealms',
                path: '/discovery/realms',
                builder: (context, state) => const DiscoveryRealmsScreen(),
              ),

              // Chat tab
              ShellRoute(
                pageBuilder: (context, state, child) => CustomTransitionPage(
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
                    name: 'chatRoom',
                    path: '/chat/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatRoomScreen(id: id);
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
                  GoRoute(
                    name: 'searchMessages',
                    path: '/chat/:id/search',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return SearchMessagesScreen(roomId: id);
                    },
                  ),
                ],
              ),

              // Realms tab
              GoRoute(
                name: 'realmList',
                path: '/realms',
                pageBuilder: (context, state) => CustomTransitionPage(
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
                pageBuilder: (context, state, child) => CustomTransitionPage(
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
                    builder: (context, state) =>
                        const MarketplaceStickersScreen(),
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
                    name: 'webFeedMarketplace',
                    path: '/feeds',
                    builder: (context, state) =>
                        const MarketplaceWebFeedsScreen(),
                    routes: [
                      GoRoute(
                        name: 'webFeedDetail',
                        path: ':feedId',
                        builder: (context, state) {
                          final feedId = state.pathParameters['feedId']!;
                          return MarketplaceWebFeedDetailScreen(id: feedId);
                        },
                      ),
                    ],
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
                path: '/accounts/:name',
                builder: (context, state) {
                  final name = state.pathParameters['name']!;
                  return AccountProfileScreen(name: name);
                },
              ),

              // Files tab
              GoRoute(
                name: 'files',
                path: '/files',
                builder: (context, state) => const FileListScreen(),
              ),

              // SN-chan tab
              GoRoute(
                name: 'thought',
                path: '/thought',
                builder: (context, state) => const ThoughtScreen(),
              ),

              // Creator hub tab
              GoRoute(
                name: 'creatorHub',
                path: '/creators',
                builder: (context, state) => const CreatorHubScreen(),
                routes: [
                  // Web Feed Routes
                  GoRoute(
                    name: 'creatorFeeds',
                    path: ':name/feeds',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return WebFeedListScreen(pubName: name);
                    },
                  ),
                  GoRoute(
                    name: 'creatorPosts',
                    path: ':name/posts',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return CreatorPostListScreen(pubName: name);
                    },
                  ),
                  // Poll list route
                  GoRoute(
                    name: 'creatorPolls',
                    path: ':name/polls',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return CreatorPollListScreen(pubName: name);
                    },
                  ),
                  // Site list route
                  GoRoute(
                    name: 'creatorSites',
                    path: ':name/sites',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return CreatorSiteListScreen(pubName: name);
                    },
                    routes: [
                      GoRoute(
                        name: 'creatorSiteDetail',
                        path: ':siteSlug',
                        builder: (context, state) {
                          final name = state.pathParameters['name']!;
                          final siteSlug = state.pathParameters['siteSlug']!;
                          return PublicationSiteDetailScreen(
                            siteSlug: siteSlug,
                            pubName: name,
                          );
                        },
                      ),
                    ],
                  ),

                  GoRoute(
                    name: 'creatorStickers',
                    path: ':name/stickers',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      return StickersScreen(pubName: name);
                    },
                  ),
                ],
              ),

              // Developer hub tab
              GoRoute(
                name: 'developerHub',
                path: '/developers',
                builder: (context, state) => DeveloperHubScreen(
                  initialPublisherName: state.uri.queryParameters['publisher'],
                  initialProjectId: state.uri.queryParameters['project'],
                ),
                routes: [
                  GoRoute(
                    name: 'developerProjectNew',
                    path: ':name/projects/new',
                    builder: (context, state) => NewProjectScreen(
                      publisherName: state.pathParameters['name']!,
                    ),
                  ),
                  GoRoute(
                    name: 'developerProjectEdit',
                    path: ':name/projects/:id/edit',
                    builder: (context, state) => EditProjectScreen(
                      publisherName: state.pathParameters['name']!,
                      id: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    name: 'developerProjectDetail',
                    path: ':name/projects/:projectId',
                    builder: (context, state) {
                      final name = state.pathParameters['name']!;
                      final projectId = state.pathParameters['projectId']!;
                      // Redirect to hub with project selected
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go(
                          '/developers?publisher=$name&project=$projectId',
                        );
                      });
                      return const SizedBox.shrink(); // Temporary placeholder
                    },
                    routes: [
                      GoRoute(
                        name: 'developerAppDetail',
                        path: 'apps/:appId',
                        builder: (context, state) => AppDetailScreen(
                          publisherName: state.pathParameters['name']!,
                          projectId: state.pathParameters['projectId']!,
                          appId: state.pathParameters['appId']!,
                        ),
                      ),
                      GoRoute(
                        name: 'developerBotDetail',
                        path: 'bots/:botId',
                        builder: (context, state) => BotDetailScreen(
                          publisherName: state.pathParameters['name']!,
                          projectId: state.pathParameters['projectId']!,
                          botId: state.pathParameters['botId']!,
                        ),
                      ),
                    ],
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
