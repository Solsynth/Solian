import 'dart:io' show Platform;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';

// Shell route keys for nested navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();
final tabsShellKey = GlobalKey<NavigatorState>();

bool get supportsAnalytics =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

// Provider for the router
final routerProvider = Provider((ref) {
  return AppRouter();
});

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    enablePredictiveBackGesture: true,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Custom slide + fade transition for all routes
      final slideAnimation =
          Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          );

      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
    durationInMilliseconds: 250,
    reverseDurationInMilliseconds: 200,
  );

  @override
  List<AutoRoute> get routes => [
    // Standalone routes (outside of tabs)
    AutoRoute(page: ArticleComposeRoute.page, path: '/articles/compose'),
    AutoRoute(page: ArticleEditRoute.page, path: '/articles/:id/edit'),
    // AutoRoute(page: LogsRoute.page, path: '/logs'),

    // Web articles
    AutoRoute(page: ArticleStandRoute.page, path: '/feeds/articles'),
    AutoRoute(page: ArticleDetailRoute.page, path: '/feeds/articles/:id'),

    // Auth routes
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),

    // Other standalone routes
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: AboutRoute.page, path: '/about'),
    AutoRoute(page: FileDetailRoute.page, path: '/files/:id'),
    AutoRoute(page: PostShuffleRoute.page, path: '/posts/shuffle'),
    // AutoRoute(page: PostCategoriesRoute.page, path: '/posts/categories'),
    AutoRoute(
      page: PostCategoryDetailRoute.page,
      path: '/posts/categories/:slug',
    ),
    // Note: Tags use PostCategoryDetailRoute with isCategory: false
    // Navigate programmatically: PostCategoryDetailRoute(slug: 'tag', isCategory: false)
    AutoRoute(page: PostDetailRoute.page, path: '/posts/:id'),
    AutoRoute(page: PublisherProfileRoute.page, path: '/publishers/:name'),
    AutoRoute(page: AccountProfileRoute.page, path: '/accounts/:name'),
    AutoRoute(page: UniversalSearchRoute.page, path: '/search'),

    AutoRoute(page: RealmNewRoute.page, path: '/realms/new'),
    AutoRoute(page: RealmDetailRoute.page, path: '/realms/:slug'),
    AutoRoute(page: RealmEditRoute.page, path: '/realms/:slug/edit'),

    // Main tabs shell route
    AutoRoute(
      page: TabsRoute.page,
      path: '/',
      initial: true,
      children: [
        // Dashboard tab
        AutoRoute(page: DashboardRoute.page, path: '', initial: true),

        // Explore tab
        AutoRoute(page: ExploreRoute.page, path: 'explore'),

        // Chat tab with nested routes - ChatScreen handles the layout internally
        AutoRoute(
          page: ChatRoute.page,
          path: 'chat',
          children: [
            // Default child route -> Chat list
            AutoRoute(page: ChatListRoute.page, path: '', initial: true),
            // Chat room
            AutoRoute(page: ChatRoomRoute.page, path: ':id'),
            // Chat room detail
            AutoRoute(page: ChatDetailRoute.page, path: ':id/detail'),
            // Search inside a chat room
            AutoRoute(page: SearchMessagesRoute.page, path: ':id/search'),
          ],
        ),

        // Realms tab
        AutoRoute(page: RealmListRoute.page, path: 'realms'),

        // Account tab with nested shell
        AutoRoute(
          page: AccountRoute.page,
          path: 'account',
          children: [
            // Default child route -> Account list
            AutoRoute(page: AccountListRoute.page, path: '', initial: true),
            AutoRoute(
              page: StickerMarketplaceRoute.page,
              path: 'stickers',
              children: [
                AutoRoute(
                  page: StickerMarketplacePackDetailRoute.page,
                  path: ':id',
                ),
              ],
            ),
            AutoRoute(
              page: FeedMarketplaceRoute.page,
              path: 'feeds',
              children: [
                AutoRoute(
                  page: FeedMarketplaceDetailRoute.page,
                  path: ':feedId',
                ),
              ],
            ),
            AutoRoute(page: WalletRoute.page, path: 'wallet'),
            AutoRoute(page: RelationshipRoute.page, path: 'relationships'),
            AutoRoute(page: AccountUpdateProfileRoute.page, path: 'me/update'),
            AutoRoute(page: LevelingRoute.page, path: 'me/leveling'),
            AutoRoute(page: AccountSettingsRoute.page, path: 'me/settings'),
            AutoRoute(
              page: AbuseReportListRoute.page,
              path: 'safety/reports/me',
            ),
            AutoRoute(
              page: AbuseReportDetailRoute.page,
              path: 'safety/reports/me/:id',
            ),
            AutoRoute(page: FitnessActivityRoute.page, path: 'fitness'),
          ],
        ),

        // Files tab
        AutoRoute(page: FileListRoute.page, path: 'files'),

        // Thought tab
        AutoRoute(page: ThoughtRoute.page, path: 'thought'),

        // Creator hub tab with nested routes
        AutoRoute(
          page: CreatorHubRoute.page,
          path: 'creators',
          children: [
            // Default child route -> Creator hub list
            AutoRoute(page: CreatorHubListRoute.page, path: '', initial: true),
            AutoRoute(page: CreatorFeedListRoute.page, path: ':pubName/feeds'),
            AutoRoute(page: CreatorPostListRoute.page, path: ':pubName/posts'),
            AutoRoute(page: CreatorPollListRoute.page, path: ':pubName/polls'),
            AutoRoute(
              page: CreatorSiteListRoute.page,
              path: ':pubName/sites',
              children: [
                AutoRoute(page: CreatorSiteDetailRoute.page, path: ':siteSlug'),
              ],
            ),
            AutoRoute(
              page: CreatorStickerListRoute.page,
              path: ':pubName/stickers',
              children: [
                AutoRoute(
                  page: CreatorStickerPackDetailRoute.page,
                  path: ':packId',
                ),
              ],
            ),
          ],
        ),

        // Developer hub tab with nested routes
        AutoRoute(
          page: DeveloperHubRoute.page,
          path: 'developers',
          children: [
            // Default child route -> Developer hub list
            AutoRoute(
              page: DeveloperHubListRoute.page,
              path: '',
              initial: true,
            ),
            AutoRoute(
              page: DeveloperProjectNewRoute.page,
              path: ':pubName/projects/new',
            ),
            AutoRoute(
              page: DeveloperProjectEditRoute.page,
              path: ':pubName/projects/:id/edit',
            ),
            AutoRoute(
              page: DeveloperAppListRoute.page,
              path: ':pubName/projects/:projectId',
            ),
            AutoRoute(
              page: DeveloperAppDetailRoute.page,
              path: ':pubName/projects/:projectId/apps/:appId',
            ),
            AutoRoute(
              page: DeveloperAppNewRoute.page,
              path: ':pubName/projects/:projectId/apps/new',
            ),
            AutoRoute(
              page: DeveloperAppEditRoute.page,
              path: ':pubName/projects/:projectId/apps/:appId/edit',
            ),
            AutoRoute(
              page: DeveloperBotDetailRoute.page,
              path: ':pubName/projects/:projectId/bots/:botId',
            ),
            AutoRoute(
              page: DeveloperBotNewRoute.page,
              path: ':pubName/projects/:projectId/bots/new',
            ),
            AutoRoute(
              page: DeveloperBotEditRoute.page,
              path: ':pubName/projects/:projectId/bots/:botId/edit',
            ),
          ],
        ),
      ],
    ),
  ];
}
