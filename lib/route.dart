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
      ],
    ),
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),
    AutoRoute(page: MyselfProfileRoute.page, path: '/account/me'),
    AutoRoute(page: UpdateProfileRoute.page, path: '/account/me/update'),
    AutoRoute(page: ManagedPublisherRoute.page, path: '/account/me/publishers'),
    AutoRoute(page: NewPublisherRoute.page, path: '/account/me/publishers/new'),
    AutoRoute(
      page: EditPublisherRoute.page,
      path: '/account/me/publishers/:id',
    ),
    AutoRoute(page: PostComposeRoute.page, path: '/posts/compose'),
  ];
}
