import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: TabsRoute.page,
      path: '/',
      children: [
        AutoRoute(
          page: ExploreShellRoute.page,
          path: '',
          children: [
            AutoRoute(page: ExploreRoute.page, path: ''),
            AutoRoute(page: PostDetailRoute.page, path: 'posts/:id'),
            AutoRoute(
              page: PublisherProfileRoute.page,
              path: 'publishers/:name',
            ),
          ],
        ),
        AutoRoute(
          page: AccountShellRoute.page,
          path: 'account',
          children: [
            AutoRoute(page: AccountRoute.page, path: ''),
            AutoRoute(page: NotificationRoute.page, path: 'notifications'),
            AutoRoute(page: WalletRoute.page, path: 'wallet'),
            AutoRoute(page: RelationshipRoute.page, path: 'relationships'),
            AutoRoute(page: AccountProfileRoute.page, path: ':name'),
            AutoRoute(page: UpdateProfileRoute.page, path: 'me/update'),
            AutoRoute(page: AccountSettingsRoute.page, path: 'settings'),
          ],
        ),
        AutoRoute(page: RealmListRoute.page, path: 'realms'),
        AutoRoute(
          page: ChatShellRoute.page,
          path: 'chat',
          children: [
            AutoRoute(page: ChatListRoute.page, path: ''),
            AutoRoute(page: ChatRoomRoute.page, path: ':id'),
            AutoRoute(page: CallRoute.page, path: ':id/call'),
            AutoRoute(page: NewChatRoute.page, path: 'new'),
            AutoRoute(page: EditChatRoute.page, path: ':id/edit'),
            AutoRoute(page: ChatDetailRoute.page, path: ':id/detail'),
          ],
        ),
      ],
    ),
    AutoRoute(page: PostComposeRoute.page, path: '/posts/compose'),
    AutoRoute(page: PostEditRoute.page, path: '/posts/:id/edit'),
    AutoRoute(page: EventCalanderRoute.page, path: '/account/:name/calendar'),
    AutoRoute(
      page: CreatorHubShellRoute.page,
      path: '/creators',
      children: [
        AutoRoute(page: CreatorHubRoute.page, path: ''),
        AutoRoute(page: CreatorPostListRoute.page, path: ':name/posts'),
        AutoRoute(page: StickersRoute.page, path: ':name/stickers'),
        AutoRoute(page: NewStickerPacksRoute.page, path: ':name/stickers/new'),
        AutoRoute(
          page: EditStickerPacksRoute.page,
          path: ':name/stickers/:packId/edit',
        ),
        AutoRoute(
          page: StickerPackDetailRoute.page,
          path: ':name/stickers/:packId',
        ),
        AutoRoute(page: NewStickersRoute.page, path: ':name/stickers/new'),
        AutoRoute(
          page: EditStickersRoute.page,
          path: ':name/stickers/:id/edit',
        ),
        AutoRoute(page: NewPublisherRoute.page, path: 'new'),
        AutoRoute(page: EditPublisherRoute.page, path: ':name/edit'),
      ],
    ),
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: NewRealmRoute.page, path: '/realms/new'),
    AutoRoute(page: RealmDetailRoute.page, path: '/realms/:slug'),
    AutoRoute(page: EditRealmRoute.page, path: '/realms/:slug/edit'),
  ];
}
