import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surface/screens/abuse_report.dart';
import 'package:surface/screens/account.dart';
import 'package:surface/screens/account/account_settings.dart';
import 'package:surface/screens/account/badges.dart';
import 'package:surface/screens/account/factor_settings.dart';
import 'package:surface/screens/account/keypairs.dart';
import 'package:surface/screens/account/profile_page.dart';
import 'package:surface/screens/account/profile_edit.dart';
import 'package:surface/screens/account/publishers/publisher_edit.dart';
import 'package:surface/screens/account/publishers/publisher_new.dart';
import 'package:surface/screens/account/publishers/publishers.dart';
import 'package:surface/screens/album.dart';
import 'package:surface/screens/auth/login.dart';
import 'package:surface/screens/auth/register.dart';
import 'package:surface/screens/chat.dart';
import 'package:surface/screens/chat/call_room.dart';
import 'package:surface/screens/chat/channel_detail.dart';
import 'package:surface/screens/chat/manage.dart';
import 'package:surface/screens/chat/room.dart';
import 'package:surface/screens/explore.dart';
import 'package:surface/screens/friend.dart';
import 'package:surface/screens/home.dart';
import 'package:surface/screens/logging.dart';
import 'package:surface/screens/news/news_detail.dart';
import 'package:surface/screens/news/news_list.dart';
import 'package:surface/screens/notification.dart';
import 'package:surface/screens/post/post_detail.dart';
import 'package:surface/screens/post/post_editor.dart';
import 'package:surface/screens/post/publisher_page.dart';
import 'package:surface/screens/post/post_search.dart';
import 'package:surface/screens/realm.dart';
import 'package:surface/screens/realm/manage.dart';
import 'package:surface/screens/realm/realm_detail.dart';
import 'package:surface/screens/realm/realm_discovery.dart';
import 'package:surface/screens/settings.dart';
import 'package:surface/screens/sharing.dart';
import 'package:surface/screens/stickers.dart';
import 'package:surface/screens/stickers/pack_detail.dart';
import 'package:surface/screens/wallet.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/about.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

Widget _fadeThroughTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    fillColor: Colors.transparent,
    child: child,
  );
}

final _appRoutes = [
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/posts',
    name: 'explore',
    builder: (context, state) => const ExploreScreen(),
    routes: [
      GoRoute(
        path: '/write',
        name: 'postEditor',
        builder: (context, state) => PostEditorScreen(
          mode: state.uri.queryParameters['mode'],
          postEditId: int.tryParse(
            state.uri.queryParameters['editing'] ?? '',
          ),
          postReplyId: int.tryParse(
            state.uri.queryParameters['replying'] ?? '',
          ),
          postRepostId: int.tryParse(
            state.uri.queryParameters['reposting'] ?? '',
          ),
          extraProps: state.extra as PostEditorExtra?,
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'postSearch',
        builder: (context, state) => PostSearchScreen(
          initialTags: state.uri.queryParameters['tags']?.split(','),
          initialCategories:
              state.uri.queryParameters['categories']?.split(','),
        ),
      ),
      GoRoute(
        path: '/publishers/:name',
        name: 'postPublisher',
        builder: (context, state) =>
            PostPublisherScreen(name: state.pathParameters['name']!),
      ),
      GoRoute(
        path: '/:slug',
        name: 'postDetail',
        builder: (context, state) => PostDetailScreen(
          slug: state.pathParameters['slug']!,
          preload: state.extra as SnPost?,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/account',
    name: 'account',
    builder: (context, state) => const AccountScreen(),
    routes: [
      GoRoute(
        path: '/badges',
        name: 'accountBadges',
        builder: (context, state) => const AccountBadgesScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'accountWallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/keypairs',
        name: 'accountKeyPairs',
        builder: (context, state) => const KeyPairScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'accountSettings',
        builder: (context, state) => AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/factors',
        name: 'factorSettings',
        builder: (context, state) => FactorSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'accountProfileEdit',
        builder: (context, state) => ProfileEditScreen(),
      ),
      GoRoute(
        path: '/publishers',
        name: 'accountPublishers',
        builder: (context, state) => PublisherScreen(),
      ),
      GoRoute(
        path: '/publishers/new',
        name: 'accountPublisherNew',
        builder: (context, state) => AccountPublisherNewScreen(),
      ),
      GoRoute(
        path: '/publishers/edit/:name',
        name: 'accountPublisherEdit',
        builder: (context, state) => AccountPublisherEditScreen(
          name: state.pathParameters['name']!,
        ),
      ),
      GoRoute(
        path: '/:name',
        name: 'accountProfilePage',
        pageBuilder: (context, state) => NoTransitionPage(
          child: UserScreen(name: state.pathParameters['name']!),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/chat',
    name: 'chat',
    builder: (context, state) => const ChatScreen(),
    routes: [
      GoRoute(
        path: '/:scope/:alias',
        name: 'chatRoom',
        builder: (context, state) => ChatRoomScreen(
          scope: state.pathParameters['scope']!,
          alias: state.pathParameters['alias']!,
          extra: state.extra as ChatRoomScreenExtra?,
        ),
      ),
      GoRoute(
        path: '/:scope/:alias/call',
        name: 'chatCallRoom',
        builder: (context, state) => CallRoomScreen(
          scope: state.pathParameters['scope']!,
          alias: state.pathParameters['alias']!,
        ),
      ),
      GoRoute(
        path: '/:scope/:alias/detail',
        name: 'channelDetail',
        builder: (context, state) => ChannelDetailScreen(
          scope: state.pathParameters['scope']!,
          alias: state.pathParameters['alias']!,
        ),
      ),
      GoRoute(
        path: '/manage',
        name: 'chatManage',
        builder: (context, state) => ChatManageScreen(
          editingChannelAlias: state.uri.queryParameters['editing'],
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/realm',
    name: 'realm',
    pageBuilder: (context, state) => CustomTransitionPage(
      transitionsBuilder: _fadeThroughTransition,
      child: const RealmScreen(),
    ),
    routes: [
      GoRoute(
        path: '/manage',
        name: 'realmManage',
        builder: (context, state) => RealmManageScreen(
          editingRealmAlias: state.uri.queryParameters['editing'],
        ),
      ),
      GoRoute(
        path: '/discovery',
        name: 'realmDiscovery',
        builder: (context, state) => const RealmDiscoveryScreen(),
      ),
      GoRoute(
        path: '/:alias',
        name: 'realmDetail',
        builder: (context, state) =>
            RealmDetailScreen(alias: state.pathParameters['alias']!),
      ),
    ],
  ),
  GoRoute(
    path: '/news',
    name: 'news',
    builder: (context, state) => const NewsScreen(),
    routes: [
      GoRoute(
        path: '/:hash',
        name: 'newsDetail',
        builder: (context, state) => NewsDetailScreen(
          hash: state.pathParameters['hash']!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/stickers',
    name: 'stickers',
    builder: (context, state) => const StickerScreen(),
    routes: [
      GoRoute(
        path: '/packs/:id',
        name: 'stickerPack',
        builder: (context, state) => StickerPackScreen(
          id: int.tryParse(state.pathParameters['id']!)!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/debug/logging',
    name: 'debugLogging',
    builder: (context, state) => const DebugLoggingScreen(),
  ),
  GoRoute(
    path: '/album',
    name: 'album',
    builder: (context, state) => const AlbumScreen(),
  ),
  GoRoute(
    path: '/friend',
    name: 'friend',
    builder: (context, state) => const FriendScreen(),
  ),
  GoRoute(
    path: '/notification',
    name: 'notification',
    builder: (context, state) => const NotificationScreen(),
  ),
  GoRoute(
    path: '/auth/login',
    name: 'authLogin',
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    path: '/auth/register',
    name: 'authRegister',
    builder: (context, state) => RegisterScreen(),
  ),
  GoRoute(
    path: '/reports',
    name: 'abuseReport',
    builder: (context, state) => AbuseReportScreen(),
  ),
  GoRoute(
    path: '/settings',
    name: 'settings',
    builder: (context, state) => SettingsScreen(),
  ),
  GoRoute(
    path: '/about',
    name: 'about',
    builder: (context, state) => AboutScreen(),
  ),
];

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      routes: _appRoutes,
      builder: (context, state, child) => AppRootScaffold(
        body: AppSharingListener(child: child),
      ),
    ),
  ],
);
