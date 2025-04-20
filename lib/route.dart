import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [AutoRoute(page: ExploreRoute.page, path: '/')];
}
