import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: ExploreRoute.page,
      path: '/',
      meta: {'bottomNav': true},
      initial: true,
    ),
    AutoRoute(
      page: AccountRoute.page,
      path: '/account',
      meta: {'bottomNav': true},
    ),
    AutoRoute(page: LoginRoute.page, path: '/auth/login'),
    AutoRoute(page: CreateAccountRoute.page, path: '/auth/create-account'),
  ];
}
