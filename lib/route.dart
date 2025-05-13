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
      initial: true,
      children: [
        AutoRoute(page: ExploreRoute.page, path: 'explore'),
        AutoRoute(page: AccountRoute.page, path: 'account'),
        AutoRoute(page: RealmListRoute.page, path: 'realms'),
        AutoRoute(page: ChatListRoute.page, path: 'chat'),
      ],
    ),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),
    AutoRoute(page: MyselfProfileRoute.page, path: '/account/me'),
    AutoRoute(
      page: MyselfEventCalendarRoute.page,
      path: '/account/me/calendar',
    ),
    AutoRoute(page: UpdateProfileRoute.page, path: '/account/me/update'),
    AutoRoute(page: ManagedPublisherRoute.page, path: '/account/me/publishers'),
    AutoRoute(page: NewPublisherRoute.page, path: '/account/me/publishers/new'),
    AutoRoute(
      page: EditPublisherRoute.page,
      path: '/account/me/publishers/:id/edit',
    ),
    AutoRoute(page: AccountProfileRoute.page, path: '/account/:name'),
    AutoRoute(
      page: PublisherProfileRoute.page,
      path: '/account/:name/calendar',
    ),
    AutoRoute(page: PostComposeRoute.page, path: '/posts/compose'),
    AutoRoute(page: PostDetailRoute.page, path: '/posts/:id'),
    AutoRoute(page: PostEditRoute.page, path: '/posts/:id/edit'),
    AutoRoute(page: NewRealmRoute.page, path: '/realms/new'),
    AutoRoute(page: RealmDetailRoute.page, path: '/realms/:slug'),
    AutoRoute(page: EditRealmRoute.page, path: '/realms/:slug/edit'),
    AutoRoute(page: NewChatRoute.page, path: '/chat/new'),
    AutoRoute(page: EditChatRoute.page, path: '/chat/:id/edit'),
    AutoRoute(page: ChatRoomRoute.page, path: '/chat/:id'),
    AutoRoute(page: ChatDetailRoute.page, path: '/chat/:id/detail'),
    AutoRoute(page: CreatorHubRoute.page, path: '/creators'),
    AutoRoute(page: StickersRoute.page, path: '/creators/:name/stickers'),
    AutoRoute(
      page: NewStickerPacksRoute.page,
      path: '/creators/:name/stickers/new',
    ),
    AutoRoute(
      page: EditStickerPacksRoute.page,
      path: '/creators/:name/stickers/:packId/edit',
    ),
    AutoRoute(
      page: StickerPackDetailRoute.page,
      path: '/creators/:name/stickers/:packId',
    ),
    AutoRoute(
      page: NewStickersRoute.page,
      path: '/creators/:name/stickers/new',
    ),
    AutoRoute(
      page: EditStickersRoute.page,
      path: '/creators/:name/stickers/:id/edit',
    ),
  ];
}
