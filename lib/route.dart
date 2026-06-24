import 'dart:io' show Platform;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';

bool get supportsAnalytics =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

// Provider for the router
final routerProvider = Provider((ref) {
  return AppRouter();
});

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => (!kIsWeb && Platform.isIOS)
      ? RouteType.cupertino()
      : RouteType.material();

  @override
  List<AutoRoute> get routes => [
    // Standalone routes (outside of tabs)
    AutoRoute(page: ArticleComposeRoute.page, path: '/articles/compose'),
    AutoRoute(page: ArticleEditRoute.page, path: '/articles/:id/edit'),
    AutoRoute(page: BlogComposeRoute.page, path: '/blogs/compose'),
    AutoRoute(page: BlogEditRoute.page, path: '/blogs/:id/edit'),
    // AutoRoute(page: LogsRoute.page, path: '/logs'),



    // Auth routes
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),
    AutoRoute(page: AuthorizeRoute.page, path: '/auth/authorize'),

    // Other standalone routes
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: PluginManagerRoute.page, path: '/plugins'),
    AutoRoute(page: PluginEditorRoute.page, path: '/plugins/editor'),
    AutoRoute(
      page: ChatRoomStorageRoute.page,
      path: '/settings/chat-room-storage',
    ),
    AutoRoute(page: AboutRoute.page, path: '/about'),
    AutoRoute(page: CfIpSpeedTestRoute.page, path: '/cf-ip-speed-test'),
    AutoRoute(page: FileDetailRoute.page, path: '/files/:id'),
    AutoRoute(page: PostShuffleRoute.page, path: '/posts/shuffle'),
    AutoRoute(page: BookmarksRoute.page, path: '/posts/bookmarks'),
    AutoRoute(page: PostCategoriesListRoute.page, path: '/posts/categories'),
    AutoRoute(
      page: PostCategoryDetailRoute.page,
      path: '/posts/categories/:slug',
    ),
    AutoRoute(page: PostDetailRoute.page, path: '/posts/:id'),
    AutoRoute(page: PublisherProfileRoute.page, path: '/publishers/:name'),
    AutoRoute(
      page: FediverseActorProfileRoute.page,
      path: '/fediverse/actors/:id',
    ),
    AutoRoute(page: AccountProfileRoute.page, path: '/accounts/:name'),
    AutoRoute(page: UniversalSearchRoute.page, path: '/search'),
    AutoRoute(page: EventHubRoute.page, path: '/calendar/:name'),
    AutoRoute(
      page: CalendarEventDetailRoute.page,
      path: '/calendar/:name/events/:id',
    ),

    AutoRoute(page: RealmDetailRoute.page, path: '/realms/:slug'),
    AutoRoute(page: PollSubmitRoute.page, path: '/polls/:id'),
    AutoRoute(
      page: TransactionDetailRoute.page,
      path: '/wallet/transactions/:id',
    ),

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
            AutoRoute(page: StickerMarketplaceRoute.page, path: 'stickers'),
            AutoRoute(
              page: StickerMarketplacePackDetailRoute.page,
              path: 'stickers/:id',
            ),

            AutoRoute(page: RelationshipRoute.page, path: 'relationships'),
            AutoRoute(page: AccountUpdateProfileRoute.page, path: 'me/update'),
            AutoRoute(page: LevelingRoute.page, path: 'me/leveling'),
            AutoRoute(page: AccountSettingsRoute.page, path: 'me/settings'),
            AutoRoute(page: AccountQrRoute.page, path: 'me/qr'),
            AutoRoute(page: BadgesRoute.page, path: 'me/badges'),
            AutoRoute(page: ProgressRoute.page, path: 'me/progress'),
            AutoRoute(page: MeetRoute.page, path: 'me/meet'),
            AutoRoute(page: MeetDetailRoute.page, path: 'me/meet/:id'),
            AutoRoute(page: ActionLogsRoute.page, path: 'me/action-logs'),
            AutoRoute(
              page: PhysicalPassportRoute.page,
              path: 'me/physical-passports',
            ),
            // Ticket routes
            AutoRoute(page: TicketListRoute.page, path: 'tickets'),
            AutoRoute(page: TicketDetailRoute.page, path: 'tickets/:ticketId'),

            AutoRoute(page: PunishmentsRoute.page, path: 'me/punishments'),
            AutoRoute(page: AffiliationRoute.page, path: 'me/affiliations'),
            AutoRoute(
              page: AffiliationDetailRoute.page,
              path: 'me/affiliations/:id',
            ),
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
            AutoRoute(page: CreatorPostListRoute.page, path: ':pubName/posts'),
            AutoRoute(
              page: CreatorPostCollectionsRoute.page,
              path: ':pubName/collections',
            ),
            AutoRoute(page: CreatorPollListRoute.page, path: ':pubName/polls'),
            AutoRoute(
              page: CreatorStickerListRoute.page,
              path: ':pubName/stickers',
            ),
            AutoRoute(
              page: CreatorStickerPackDetailRoute.page,
              path: ':pubName/stickers/:packId',
            ),
            AutoRoute(
              page: CreatorDomainManageRoute.page,
              path: ':pubName/domains',
            ),
          ],
        ),

        // Wallet tab
        AutoRoute(page: WalletRoute.page, path: 'wallet'),
      ],
    ),

    // 404 catch-all (must be last)
    AutoRoute(page: NotFoundRoute.page, path: '*', fullscreenDialog: true),
  ];
}
