import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: TabsRoute.page,
      path: '/',
      initial: true,
      children: [
        // Main tab routes - these are the simple list views
        AutoRoute(page: DashboardRoute.page, path: '', initial: true),
        AutoRoute(page: ExploreRoute.page, path: 'explore'),
        // Chat as simple list route - shell layout handled by screen itself
        AutoRoute(
          page: ChatRoute.page,
          path: 'chat',
          children: [
            AutoRoute(page: ChatRoomRoute.page, path: 'room/:id'),
            AutoRoute(page: ChatDetailRoute.page, path: 'detail/:id'),
          ],
        ),
        AutoRoute(page: RealmListRoute.page, path: 'realms'),
        AutoRoute(
          page: AccountShellRoute.page,
          path: 'account',
          children: [AutoRoute(page: LevelingRoute.page, path: 'leveling')],
        ),
        AutoRoute(page: FileListRoute.page, path: 'files'),
        AutoRoute(page: ThoughtRoute.page, path: 'thought'),
        AutoRoute(page: CreatorHubRoute.page, path: 'creators'),
        AutoRoute(page: DeveloperHubRoute.page, path: 'developers'),
      ],
    ),
    AutoRoute(page: UniversalSearchRoute.page),
  ];
}
