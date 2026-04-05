// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i82;
import 'package:flutter/foundation.dart' as _i83;
import 'package:flutter/material.dart' as _i84;
import 'package:island/accounts/account_screen.dart' as _i2;
import 'package:island/accounts/screens/action_logs.dart' as _i6;
import 'package:island/accounts/screens/badges.dart' as _i12;
import 'package:island/accounts/screens/leveling.dart' as _i54;
import 'package:island/accounts/screens/me/account_settings.dart' as _i4;
import 'package:island/accounts/screens/me/profile_update.dart' as _i5;
import 'package:island/accounts/screens/meet.dart' as _i57;
import 'package:island/accounts/screens/physical_passport.dart' as _i59;
import 'package:island/accounts/screens/profile.dart' as _i3;
import 'package:island/accounts/screens/progress.dart' as _i65;
import 'package:island/accounts/screens/relationship.dart' as _i70;
import 'package:island/auth/captcha.dart' as _i16;
import 'package:island/auth/create_account.dart' as _i20;
import 'package:island/auth/login.dart' as _i56;
import 'package:island/chat/widgets/call_screen.dart' as _i15;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i17;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i18;
import 'package:island/chat/widgets/chat_room_form.dart' as _i42;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i19;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i71;
import 'package:island/creators/screens/hub.dart' as _i22;
import 'package:island/creators/screens/livestream/livestream_detail.dart'
    as _i23;
import 'package:island/creators/screens/livestream/livestream_list.dart'
    as _i24;
import 'package:island/creators/screens/poll/poll_list.dart' as _i25;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i26;
import 'package:island/creators/screens/publishers_form.dart' as _i43;
import 'package:island/creators/screens/sites/site_detail.dart' as _i27;
import 'package:island/creators/screens/sites/site_list.dart' as _i28;
import 'package:island/creators/screens/stickers/pack_detail_screen.dart'
    as _i30;
import 'package:island/creators/screens/stickers/stickers.dart' as _i29;
import 'package:island/creators/screens/webfeed/webfeed_list.dart' as _i21;
import 'package:island/developers/screens/app_detail.dart' as _i32;
import 'package:island/developers/screens/app_secrets.dart' as _i8;
import 'package:island/developers/screens/apps.dart' as _i34;
import 'package:island/developers/screens/bot_detail.dart' as _i36;
import 'package:island/developers/screens/bot_keys.dart' as _i13;
import 'package:island/developers/screens/bots.dart' as _i14;
import 'package:island/developers/screens/edit_app.dart' as _i33;
import 'package:island/developers/screens/edit_bot.dart' as _i37;
import 'package:island/developers/screens/edit_project.dart' as _i40;
import 'package:island/developers/screens/hub.dart' as _i39;
import 'package:island/developers/screens/new_app.dart' as _i35;
import 'package:island/developers/screens/new_bot.dart' as _i38;
import 'package:island/developers/screens/new_project.dart' as _i41;
import 'package:island/discovery/explore.dart' as _i45;
import 'package:island/discovery/screens/article_detail.dart' as _i10;
import 'package:island/discovery/screens/articles.dart' as _i11;
import 'package:island/discovery/screens/feeds/feed_detail.dart' as _i47;
import 'package:island/discovery/screens/feeds/feed_marketplace.dart' as _i48;
import 'package:island/discovery/screens/livestream_watch.dart' as _i55;
import 'package:island/discovery/screens/livestreams.dart' as _i7;
import 'package:island/discovery/search.dart' as _i79;
import 'package:island/drive/files/file_detail.dart' as _i49;
import 'package:island/drive/files/file_list.dart' as _i50;
import 'package:island/fediverse/actor_profile.dart' as _i46;
import 'package:island/fitness/screens/exercises_route.dart' as _i44;
import 'package:island/fitness/screens/fitness_dashboard_route.dart' as _i51;
import 'package:island/fitness/screens/goals_route.dart' as _i52;
import 'package:island/fitness/screens/health_sync_screen.dart' as _i53;
import 'package:island/fitness/screens/metrics_route.dart' as _i58;
import 'package:island/fitness/screens/workouts_screen.dart' as _i81;
import 'package:island/misc/about.dart' as _i1;
import 'package:island/misc/dashboard/dash.dart' as _i31;
import 'package:island/misc/settings.dart' as _i72;
import 'package:island/misc/tabs_screen.dart' as _i75;
import 'package:island/polls/screens/poll_editor.dart' as _i60;
import 'package:island/posts/compose.dart' as _i86;
import 'package:island/posts/screens/compose_article.dart' as _i9;
import 'package:island/posts/screens/post_categories_list.dart' as _i61;
import 'package:island/posts/screens/post_category_detail.dart' as _i62;
import 'package:island/posts/screens/post_detail.dart' as _i63;
import 'package:island/posts/screens/publisher_profile.dart' as _i66;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i64;
import 'package:island/realms/screens/realm_detail.dart' as _i67;
import 'package:island/realms/screens/realm_form.dart' as _i68;
import 'package:island/realms/screens/realms.dart' as _i69;
import 'package:island/stickers/screens/pack_detail.dart' as _i73;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i74;
import 'package:island/thoughts/screens/think.dart' as _i76;
import 'package:island/tickets/screens/ticket_detail.dart' as _i77;
import 'package:island/tickets/screens/ticket_list.dart' as _i78;
import 'package:island/wallets/wallet.dart' as _i80;
import 'package:solar_network_sdk/solar_network_sdk.dart' as _i85;

/// generated route for
/// [_i1.AboutScreen]
class AboutRoute extends _i82.PageRouteInfo<void> {
  const AboutRoute({List<_i82.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountListScreen]
class AccountListRoute extends _i82.PageRouteInfo<void> {
  const AccountListRoute({List<_i82.PageRouteInfo>? children})
    : super(AccountListRoute.name, initialChildren: children);

  static const String name = 'AccountListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountListScreen();
    },
  );
}

/// generated route for
/// [_i3.AccountProfileScreen]
class AccountProfileRoute extends _i82.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i83.Key? key,
    required String name,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AccountProfileRouteArgs>(
        orElse: () =>
            AccountProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i3.AccountProfileScreen(key: args.key, name: args.name);
    },
  );
}

class AccountProfileRouteArgs {
  const AccountProfileRouteArgs({this.key, required this.name});

  final _i83.Key? key;

  final String name;

  @override
  String toString() {
    return 'AccountProfileRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountProfileRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i82.PageRouteInfo<void> {
  const AccountRoute({List<_i82.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountScreen();
    },
  );
}

/// generated route for
/// [_i4.AccountSettingsScreen]
class AccountSettingsRoute extends _i82.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i82.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i4.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i5.AccountUpdateProfileScreen]
class AccountUpdateProfileRoute extends _i82.PageRouteInfo<void> {
  const AccountUpdateProfileRoute({List<_i82.PageRouteInfo>? children})
    : super(AccountUpdateProfileRoute.name, initialChildren: children);

  static const String name = 'AccountUpdateProfileRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i5.AccountUpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i6.ActionLogsScreen]
class ActionLogsRoute extends _i82.PageRouteInfo<void> {
  const ActionLogsRoute({List<_i82.PageRouteInfo>? children})
    : super(ActionLogsRoute.name, initialChildren: children);

  static const String name = 'ActionLogsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i6.ActionLogsScreen();
    },
  );
}

/// generated route for
/// [_i7.ActiveLivestreamsScreen]
class ActiveLivestreamsRoute extends _i82.PageRouteInfo<void> {
  const ActiveLivestreamsRoute({List<_i82.PageRouteInfo>? children})
    : super(ActiveLivestreamsRoute.name, initialChildren: children);

  static const String name = 'ActiveLivestreamsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i7.ActiveLivestreamsScreen();
    },
  );
}

/// generated route for
/// [_i8.AppSecretsScreen]
class AppSecretsRoute extends _i82.PageRouteInfo<AppSecretsRouteArgs> {
  AppSecretsRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    required String appId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         AppSecretsRoute.name,
         args: AppSecretsRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           appId: appId,
         ),
         initialChildren: children,
       );

  static const String name = 'AppSecretsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AppSecretsRouteArgs>();
      return _i8.AppSecretsScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        appId: args.appId,
      );
    },
  );
}

class AppSecretsRouteArgs {
  const AppSecretsRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    required this.appId,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  final String appId;

  @override
  String toString() {
    return 'AppSecretsRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, appId: $appId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppSecretsRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        appId == other.appId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      appId.hashCode;
}

/// generated route for
/// [_i9.ArticleComposeScreen]
class ArticleComposeRoute extends _i82.PageRouteInfo<ArticleComposeRouteArgs> {
  ArticleComposeRoute({
    _i84.Key? key,
    _i85.SnPost? originalPost,
    _i86.PostComposeInitialState? initialState,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         ArticleComposeRoute.name,
         args: ArticleComposeRouteArgs(
           key: key,
           originalPost: originalPost,
           initialState: initialState,
         ),
         initialChildren: children,
       );

  static const String name = 'ArticleComposeRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleComposeRouteArgs>(
        orElse: () => const ArticleComposeRouteArgs(),
      );
      return _i9.ArticleComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
        initialState: args.initialState,
      );
    },
  );
}

class ArticleComposeRouteArgs {
  const ArticleComposeRouteArgs({
    this.key,
    this.originalPost,
    this.initialState,
  });

  final _i84.Key? key;

  final _i85.SnPost? originalPost;

  final _i86.PostComposeInitialState? initialState;

  @override
  String toString() {
    return 'ArticleComposeRouteArgs{key: $key, originalPost: $originalPost, initialState: $initialState}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleComposeRouteArgs) return false;
    return key == other.key &&
        originalPost == other.originalPost &&
        initialState == other.initialState;
  }

  @override
  int get hashCode =>
      key.hashCode ^ originalPost.hashCode ^ initialState.hashCode;
}

/// generated route for
/// [_i10.ArticleDetailScreen]
class ArticleDetailRoute extends _i82.PageRouteInfo<ArticleDetailRouteArgs> {
  ArticleDetailRoute({
    _i84.Key? key,
    required String articleId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         ArticleDetailRoute.name,
         args: ArticleDetailRouteArgs(key: key, articleId: articleId),
         initialChildren: children,
       );

  static const String name = 'ArticleDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleDetailRouteArgs>();
      return _i10.ArticleDetailScreen(key: args.key, articleId: args.articleId);
    },
  );
}

class ArticleDetailRouteArgs {
  const ArticleDetailRouteArgs({this.key, required this.articleId});

  final _i84.Key? key;

  final String articleId;

  @override
  String toString() {
    return 'ArticleDetailRouteArgs{key: $key, articleId: $articleId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleDetailRouteArgs) return false;
    return key == other.key && articleId == other.articleId;
  }

  @override
  int get hashCode => key.hashCode ^ articleId.hashCode;
}

/// generated route for
/// [_i9.ArticleEditScreen]
class ArticleEditRoute extends _i82.PageRouteInfo<ArticleEditRouteArgs> {
  ArticleEditRoute({
    _i84.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         ArticleEditRoute.name,
         args: ArticleEditRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ArticleEditRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleEditRouteArgs>();
      return _i9.ArticleEditScreen(key: args.key, id: args.id);
    },
  );
}

class ArticleEditRouteArgs {
  const ArticleEditRouteArgs({this.key, required this.id});

  final _i84.Key? key;

  final String id;

  @override
  String toString() {
    return 'ArticleEditRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleEditRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i11.ArticleStandScreen]
class ArticleStandRoute extends _i82.PageRouteInfo<void> {
  const ArticleStandRoute({List<_i82.PageRouteInfo>? children})
    : super(ArticleStandRoute.name, initialChildren: children);

  static const String name = 'ArticleStandRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i11.ArticleStandScreen();
    },
  );
}

/// generated route for
/// [_i12.BadgesScreen]
class BadgesRoute extends _i82.PageRouteInfo<void> {
  const BadgesRoute({List<_i82.PageRouteInfo>? children})
    : super(BadgesRoute.name, initialChildren: children);

  static const String name = 'BadgesRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i12.BadgesScreen();
    },
  );
}

/// generated route for
/// [_i13.BotKeysScreen]
class BotKeysRoute extends _i82.PageRouteInfo<BotKeysRouteArgs> {
  BotKeysRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    required String botId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         BotKeysRoute.name,
         args: BotKeysRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           botId: botId,
         ),
         initialChildren: children,
       );

  static const String name = 'BotKeysRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BotKeysRouteArgs>();
      return _i13.BotKeysScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        botId: args.botId,
      );
    },
  );
}

class BotKeysRouteArgs {
  const BotKeysRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    required this.botId,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  final String botId;

  @override
  String toString() {
    return 'BotKeysRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, botId: $botId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BotKeysRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        botId == other.botId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      botId.hashCode;
}

/// generated route for
/// [_i14.BotsScreen]
class BotsRoute extends _i82.PageRouteInfo<BotsRouteArgs> {
  BotsRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         BotsRoute.name,
         args: BotsRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
         ),
         initialChildren: children,
       );

  static const String name = 'BotsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BotsRouteArgs>();
      return _i14.BotsScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
      );
    },
  );
}

class BotsRouteArgs {
  const BotsRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  @override
  String toString() {
    return 'BotsRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BotsRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ publisherName.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [_i15.CallScreen]
class CallRoute extends _i82.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i84.Key? key,
    required _i85.SnChatRoom room,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(key: key, room: room),
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CallRouteArgs>();
      return _i15.CallScreen(key: args.key, room: args.room);
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({this.key, required this.room});

  final _i84.Key? key;

  final _i85.SnChatRoom room;

  @override
  String toString() {
    return 'CallRouteArgs{key: $key, room: $room}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallRouteArgs) return false;
    return key == other.key && room == other.room;
  }

  @override
  int get hashCode => key.hashCode ^ room.hashCode;
}

/// generated route for
/// [_i16.CaptchaScreen]
class CaptchaRoute extends _i82.PageRouteInfo<void> {
  const CaptchaRoute({List<_i82.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i16.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i17.ChatDetailScreen]
class ChatDetailRoute extends _i82.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i84.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatDetailRouteArgs>();
      return _i17.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i84.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i18.ChatListScreen]
class ChatListRoute extends _i82.PageRouteInfo<void> {
  const ChatListRoute({List<_i82.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i18.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i19.ChatRoomScreen]
class ChatRoomRoute extends _i82.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i83.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRoomRouteArgs>();
      return _i19.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i83.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRoomRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i18.ChatScreen]
class ChatRoute extends _i82.PageRouteInfo<void> {
  const ChatRoute({List<_i82.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i18.ChatScreen();
    },
  );
}

/// generated route for
/// [_i20.CreateAccountScreen]
class CreateAccountRoute extends _i82.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i82.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i20.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i21.CreatorFeedListScreen]
class CreatorFeedListRoute
    extends _i82.PageRouteInfo<CreatorFeedListRouteArgs> {
  CreatorFeedListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorFeedListRoute.name,
         args: CreatorFeedListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorFeedListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorFeedListRouteArgs>();
      return _i21.CreatorFeedListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorFeedListRouteArgs {
  const CreatorFeedListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorFeedListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorFeedListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i22.CreatorHubListScreen]
class CreatorHubListRoute extends _i82.PageRouteInfo<void> {
  const CreatorHubListRoute({List<_i82.PageRouteInfo>? children})
    : super(CreatorHubListRoute.name, initialChildren: children);

  static const String name = 'CreatorHubListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i22.CreatorHubListScreen();
    },
  );
}

/// generated route for
/// [_i22.CreatorHubScreen]
class CreatorHubRoute extends _i82.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i82.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i22.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i23.CreatorLivestreamDetailScreen]
class CreatorLivestreamDetailRoute
    extends _i82.PageRouteInfo<CreatorLivestreamDetailRouteArgs> {
  CreatorLivestreamDetailRoute({
    _i84.Key? key,
    required String livestreamId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorLivestreamDetailRoute.name,
         args: CreatorLivestreamDetailRouteArgs(
           key: key,
           livestreamId: livestreamId,
         ),
         initialChildren: children,
       );

  static const String name = 'CreatorLivestreamDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorLivestreamDetailRouteArgs>();
      return _i23.CreatorLivestreamDetailScreen(
        key: args.key,
        livestreamId: args.livestreamId,
      );
    },
  );
}

class CreatorLivestreamDetailRouteArgs {
  const CreatorLivestreamDetailRouteArgs({
    this.key,
    required this.livestreamId,
  });

  final _i84.Key? key;

  final String livestreamId;

  @override
  String toString() {
    return 'CreatorLivestreamDetailRouteArgs{key: $key, livestreamId: $livestreamId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorLivestreamDetailRouteArgs) return false;
    return key == other.key && livestreamId == other.livestreamId;
  }

  @override
  int get hashCode => key.hashCode ^ livestreamId.hashCode;
}

/// generated route for
/// [_i24.CreatorLivestreamListScreen]
class CreatorLivestreamListRoute
    extends _i82.PageRouteInfo<CreatorLivestreamListRouteArgs> {
  CreatorLivestreamListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorLivestreamListRoute.name,
         args: CreatorLivestreamListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorLivestreamListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorLivestreamListRouteArgs>();
      return _i24.CreatorLivestreamListScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorLivestreamListRouteArgs {
  const CreatorLivestreamListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorLivestreamListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorLivestreamListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i25.CreatorPollListScreen]
class CreatorPollListRoute
    extends _i82.PageRouteInfo<CreatorPollListRouteArgs> {
  CreatorPollListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorPollListRoute.name,
         args: CreatorPollListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorPollListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorPollListRouteArgs>();
      return _i25.CreatorPollListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPollListRouteArgs {
  const CreatorPollListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorPollListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorPollListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i26.CreatorPostListScreen]
class CreatorPostListRoute
    extends _i82.PageRouteInfo<CreatorPostListRouteArgs> {
  CreatorPostListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorPostListRoute.name,
         args: CreatorPostListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorPostListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorPostListRouteArgs>();
      return _i26.CreatorPostListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPostListRouteArgs {
  const CreatorPostListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorPostListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorPostListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i27.CreatorSiteDetailScreen]
class CreatorSiteDetailRoute
    extends _i82.PageRouteInfo<CreatorSiteDetailRouteArgs> {
  CreatorSiteDetailRoute({
    _i84.Key? key,
    required String siteSlug,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorSiteDetailRoute.name,
         args: CreatorSiteDetailRouteArgs(
           key: key,
           siteSlug: siteSlug,
           pubName: pubName,
         ),
         initialChildren: children,
       );

  static const String name = 'CreatorSiteDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorSiteDetailRouteArgs>();
      return _i27.CreatorSiteDetailScreen(
        key: args.key,
        siteSlug: args.siteSlug,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorSiteDetailRouteArgs {
  const CreatorSiteDetailRouteArgs({
    this.key,
    required this.siteSlug,
    required this.pubName,
  });

  final _i84.Key? key;

  final String siteSlug;

  final String pubName;

  @override
  String toString() {
    return 'CreatorSiteDetailRouteArgs{key: $key, siteSlug: $siteSlug, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorSiteDetailRouteArgs) return false;
    return key == other.key &&
        siteSlug == other.siteSlug &&
        pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ siteSlug.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i28.CreatorSiteListScreen]
class CreatorSiteListRoute
    extends _i82.PageRouteInfo<CreatorSiteListRouteArgs> {
  CreatorSiteListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorSiteListRoute.name,
         args: CreatorSiteListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorSiteListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorSiteListRouteArgs>();
      return _i28.CreatorSiteListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorSiteListRouteArgs {
  const CreatorSiteListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorSiteListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorSiteListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i29.CreatorStickerListScreen]
class CreatorStickerListRoute
    extends _i82.PageRouteInfo<CreatorStickerListRouteArgs> {
  CreatorStickerListRoute({
    _i84.Key? key,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorStickerListRoute.name,
         args: CreatorStickerListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorStickerListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorStickerListRouteArgs>();
      return _i29.CreatorStickerListScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorStickerListRouteArgs {
  const CreatorStickerListRouteArgs({this.key, required this.pubName});

  final _i84.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorStickerListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorStickerListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i30.CreatorStickerPackDetailScreen]
class CreatorStickerPackDetailRoute
    extends _i82.PageRouteInfo<CreatorStickerPackDetailRouteArgs> {
  CreatorStickerPackDetailRoute({
    _i84.Key? key,
    required String packId,
    required String pubName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         CreatorStickerPackDetailRoute.name,
         args: CreatorStickerPackDetailRouteArgs(
           key: key,
           packId: packId,
           pubName: pubName,
         ),
         initialChildren: children,
       );

  static const String name = 'CreatorStickerPackDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorStickerPackDetailRouteArgs>();
      return _i30.CreatorStickerPackDetailScreen(
        key: args.key,
        packId: args.packId,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorStickerPackDetailRouteArgs {
  const CreatorStickerPackDetailRouteArgs({
    this.key,
    required this.packId,
    required this.pubName,
  });

  final _i84.Key? key;

  final String packId;

  final String pubName;

  @override
  String toString() {
    return 'CreatorStickerPackDetailRouteArgs{key: $key, packId: $packId, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorStickerPackDetailRouteArgs) return false;
    return key == other.key &&
        packId == other.packId &&
        pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ packId.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i31.DashboardScreen]
class DashboardRoute extends _i82.PageRouteInfo<void> {
  const DashboardRoute({List<_i82.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i31.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i32.DeveloperAppDetailScreen]
class DeveloperAppDetailRoute
    extends _i82.PageRouteInfo<DeveloperAppDetailRouteArgs> {
  DeveloperAppDetailRoute({
    _i84.Key? key,
    required String pubName,
    required String projectId,
    required String appId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperAppDetailRoute.name,
         args: DeveloperAppDetailRouteArgs(
           key: key,
           pubName: pubName,
           projectId: projectId,
           appId: appId,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperAppDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppDetailRouteArgs>();
      return _i32.DeveloperAppDetailScreen(
        key: args.key,
        pubName: args.pubName,
        projectId: args.projectId,
        appId: args.appId,
      );
    },
  );
}

class DeveloperAppDetailRouteArgs {
  const DeveloperAppDetailRouteArgs({
    this.key,
    required this.pubName,
    required this.projectId,
    required this.appId,
  });

  final _i84.Key? key;

  final String pubName;

  final String projectId;

  final String appId;

  @override
  String toString() {
    return 'DeveloperAppDetailRouteArgs{key: $key, pubName: $pubName, projectId: $projectId, appId: $appId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperAppDetailRouteArgs) return false;
    return key == other.key &&
        pubName == other.pubName &&
        projectId == other.projectId &&
        appId == other.appId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ pubName.hashCode ^ projectId.hashCode ^ appId.hashCode;
}

/// generated route for
/// [_i33.DeveloperAppEditScreen]
class DeveloperAppEditRoute
    extends _i82.PageRouteInfo<DeveloperAppEditRouteArgs> {
  DeveloperAppEditRoute({
    _i84.Key? key,
    required String pubName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperAppEditRoute.name,
         args: DeveloperAppEditRouteArgs(
           key: key,
           pubName: pubName,
           projectId: projectId,
           id: id,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperAppEditRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppEditRouteArgs>();
      return _i33.DeveloperAppEditScreen(
        key: args.key,
        pubName: args.pubName,
        projectId: args.projectId,
        id: args.id,
        isModal: args.isModal,
      );
    },
  );
}

class DeveloperAppEditRouteArgs {
  const DeveloperAppEditRouteArgs({
    this.key,
    required this.pubName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  final _i84.Key? key;

  final String pubName;

  final String projectId;

  final String? id;

  final bool isModal;

  @override
  String toString() {
    return 'DeveloperAppEditRouteArgs{key: $key, pubName: $pubName, projectId: $projectId, id: $id, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperAppEditRouteArgs) return false;
    return key == other.key &&
        pubName == other.pubName &&
        projectId == other.projectId &&
        id == other.id &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      pubName.hashCode ^
      projectId.hashCode ^
      id.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i34.DeveloperAppListScreen]
class DeveloperAppListRoute
    extends _i82.PageRouteInfo<DeveloperAppListRouteArgs> {
  DeveloperAppListRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperAppListRoute.name,
         args: DeveloperAppListRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperAppListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppListRouteArgs>();
      return _i34.DeveloperAppListScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
      );
    },
  );
}

class DeveloperAppListRouteArgs {
  const DeveloperAppListRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  @override
  String toString() {
    return 'DeveloperAppListRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperAppListRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ publisherName.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [_i35.DeveloperAppNewScreen]
class DeveloperAppNewRoute
    extends _i82.PageRouteInfo<DeveloperAppNewRouteArgs> {
  DeveloperAppNewRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperAppNewRoute.name,
         args: DeveloperAppNewRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperAppNewRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppNewRouteArgs>();
      return _i35.DeveloperAppNewScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        isModal: args.isModal,
      );
    },
  );
}

class DeveloperAppNewRouteArgs {
  const DeveloperAppNewRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  final bool isModal;

  @override
  String toString() {
    return 'DeveloperAppNewRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperAppNewRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i36.DeveloperBotDetailScreen]
class DeveloperBotDetailRoute
    extends _i82.PageRouteInfo<DeveloperBotDetailRouteArgs> {
  DeveloperBotDetailRoute({
    _i84.Key? key,
    required String pubName,
    required String projectId,
    required String botId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperBotDetailRoute.name,
         args: DeveloperBotDetailRouteArgs(
           key: key,
           pubName: pubName,
           projectId: projectId,
           botId: botId,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperBotDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotDetailRouteArgs>();
      return _i36.DeveloperBotDetailScreen(
        key: args.key,
        pubName: args.pubName,
        projectId: args.projectId,
        botId: args.botId,
      );
    },
  );
}

class DeveloperBotDetailRouteArgs {
  const DeveloperBotDetailRouteArgs({
    this.key,
    required this.pubName,
    required this.projectId,
    required this.botId,
  });

  final _i84.Key? key;

  final String pubName;

  final String projectId;

  final String botId;

  @override
  String toString() {
    return 'DeveloperBotDetailRouteArgs{key: $key, pubName: $pubName, projectId: $projectId, botId: $botId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperBotDetailRouteArgs) return false;
    return key == other.key &&
        pubName == other.pubName &&
        projectId == other.projectId &&
        botId == other.botId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ pubName.hashCode ^ projectId.hashCode ^ botId.hashCode;
}

/// generated route for
/// [_i37.DeveloperBotEditScreen]
class DeveloperBotEditRoute
    extends _i82.PageRouteInfo<DeveloperBotEditRouteArgs> {
  DeveloperBotEditRoute({
    _i84.Key? key,
    required String pubName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperBotEditRoute.name,
         args: DeveloperBotEditRouteArgs(
           key: key,
           pubName: pubName,
           projectId: projectId,
           id: id,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperBotEditRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotEditRouteArgs>();
      return _i37.DeveloperBotEditScreen(
        key: args.key,
        pubName: args.pubName,
        projectId: args.projectId,
        id: args.id,
        isModal: args.isModal,
      );
    },
  );
}

class DeveloperBotEditRouteArgs {
  const DeveloperBotEditRouteArgs({
    this.key,
    required this.pubName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  final _i84.Key? key;

  final String pubName;

  final String projectId;

  final String? id;

  final bool isModal;

  @override
  String toString() {
    return 'DeveloperBotEditRouteArgs{key: $key, pubName: $pubName, projectId: $projectId, id: $id, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperBotEditRouteArgs) return false;
    return key == other.key &&
        pubName == other.pubName &&
        projectId == other.projectId &&
        id == other.id &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      pubName.hashCode ^
      projectId.hashCode ^
      id.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i38.DeveloperBotNewScreen]
class DeveloperBotNewRoute
    extends _i82.PageRouteInfo<DeveloperBotNewRouteArgs> {
  DeveloperBotNewRoute({
    _i84.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperBotNewRoute.name,
         args: DeveloperBotNewRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperBotNewRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotNewRouteArgs>();
      return _i38.DeveloperBotNewScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        isModal: args.isModal,
      );
    },
  );
}

class DeveloperBotNewRouteArgs {
  const DeveloperBotNewRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  final _i84.Key? key;

  final String publisherName;

  final String projectId;

  final bool isModal;

  @override
  String toString() {
    return 'DeveloperBotNewRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperBotNewRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i39.DeveloperHubListScreen]
class DeveloperHubListRoute extends _i82.PageRouteInfo<void> {
  const DeveloperHubListRoute({List<_i82.PageRouteInfo>? children})
    : super(DeveloperHubListRoute.name, initialChildren: children);

  static const String name = 'DeveloperHubListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i39.DeveloperHubListScreen();
    },
  );
}

/// generated route for
/// [_i39.DeveloperHubScreen]
class DeveloperHubRoute extends _i82.PageRouteInfo<DeveloperHubRouteArgs> {
  DeveloperHubRoute({
    _i84.Key? key,
    String? initialPublisherName,
    String? initialProjectId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperHubRoute.name,
         args: DeveloperHubRouteArgs(
           key: key,
           initialPublisherName: initialPublisherName,
           initialProjectId: initialProjectId,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperHubRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperHubRouteArgs>(
        orElse: () => const DeveloperHubRouteArgs(),
      );
      return _i39.DeveloperHubScreen(
        key: args.key,
        initialPublisherName: args.initialPublisherName,
        initialProjectId: args.initialProjectId,
      );
    },
  );
}

class DeveloperHubRouteArgs {
  const DeveloperHubRouteArgs({
    this.key,
    this.initialPublisherName,
    this.initialProjectId,
  });

  final _i84.Key? key;

  final String? initialPublisherName;

  final String? initialProjectId;

  @override
  String toString() {
    return 'DeveloperHubRouteArgs{key: $key, initialPublisherName: $initialPublisherName, initialProjectId: $initialProjectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperHubRouteArgs) return false;
    return key == other.key &&
        initialPublisherName == other.initialPublisherName &&
        initialProjectId == other.initialProjectId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialPublisherName.hashCode ^ initialProjectId.hashCode;
}

/// generated route for
/// [_i40.DeveloperProjectEditScreen]
class DeveloperProjectEditRoute
    extends _i82.PageRouteInfo<DeveloperProjectEditRouteArgs> {
  DeveloperProjectEditRoute({
    _i84.Key? key,
    required String pubName,
    String? id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperProjectEditRoute.name,
         args: DeveloperProjectEditRouteArgs(
           key: key,
           pubName: pubName,
           id: id,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperProjectEditRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperProjectEditRouteArgs>();
      return _i40.DeveloperProjectEditScreen(
        key: args.key,
        pubName: args.pubName,
        id: args.id,
      );
    },
  );
}

class DeveloperProjectEditRouteArgs {
  const DeveloperProjectEditRouteArgs({
    this.key,
    required this.pubName,
    this.id,
  });

  final _i84.Key? key;

  final String pubName;

  final String? id;

  @override
  String toString() {
    return 'DeveloperProjectEditRouteArgs{key: $key, pubName: $pubName, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperProjectEditRouteArgs) return false;
    return key == other.key && pubName == other.pubName && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i41.DeveloperProjectNewScreen]
class DeveloperProjectNewRoute
    extends _i82.PageRouteInfo<DeveloperProjectNewRouteArgs> {
  DeveloperProjectNewRoute({
    _i84.Key? key,
    required String publisherName,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         DeveloperProjectNewRoute.name,
         args: DeveloperProjectNewRouteArgs(
           key: key,
           publisherName: publisherName,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperProjectNewRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperProjectNewRouteArgs>();
      return _i41.DeveloperProjectNewScreen(
        key: args.key,
        publisherName: args.publisherName,
      );
    },
  );
}

class DeveloperProjectNewRouteArgs {
  const DeveloperProjectNewRouteArgs({this.key, required this.publisherName});

  final _i84.Key? key;

  final String publisherName;

  @override
  String toString() {
    return 'DeveloperProjectNewRouteArgs{key: $key, publisherName: $publisherName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeveloperProjectNewRouteArgs) return false;
    return key == other.key && publisherName == other.publisherName;
  }

  @override
  int get hashCode => key.hashCode ^ publisherName.hashCode;
}

/// generated route for
/// [_i42.EditChatScreen]
class EditChatRoute extends _i82.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i84.Key? key, String? id, List<_i82.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => const EditChatRouteArgs(),
      );
      return _i42.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i84.Key? key;

  final String? id;

  @override
  String toString() {
    return 'EditChatRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditChatRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i43.EditPublisherScreen]
class EditPublisherRoute extends _i82.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i84.Key? key,
    String? name,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => const EditPublisherRouteArgs(),
      );
      return _i43.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i84.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditPublisherRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i44.ExercisesRoute]
class ExercisesRoute extends _i82.PageRouteInfo<void> {
  const ExercisesRoute({List<_i82.PageRouteInfo>? children})
    : super(ExercisesRoute.name, initialChildren: children);

  static const String name = 'ExercisesRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i44.ExercisesRoute();
    },
  );
}

/// generated route for
/// [_i45.ExploreScreen]
class ExploreRoute extends _i82.PageRouteInfo<void> {
  const ExploreRoute({List<_i82.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i45.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i46.FediverseActorProfileScreen]
class FediverseActorProfileRoute
    extends _i82.PageRouteInfo<FediverseActorProfileRouteArgs> {
  FediverseActorProfileRoute({
    _i84.Key? key,
    required String id,
    String? fullHandle,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         FediverseActorProfileRoute.name,
         args: FediverseActorProfileRouteArgs(
           key: key,
           id: id,
           fullHandle: fullHandle,
         ),
         initialChildren: children,
       );

  static const String name = 'FediverseActorProfileRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FediverseActorProfileRouteArgs>();
      return _i46.FediverseActorProfileScreen(
        key: args.key,
        id: args.id,
        fullHandle: args.fullHandle,
      );
    },
  );
}

class FediverseActorProfileRouteArgs {
  const FediverseActorProfileRouteArgs({
    this.key,
    required this.id,
    this.fullHandle,
  });

  final _i84.Key? key;

  final String id;

  final String? fullHandle;

  @override
  String toString() {
    return 'FediverseActorProfileRouteArgs{key: $key, id: $id, fullHandle: $fullHandle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FediverseActorProfileRouteArgs) return false;
    return key == other.key && id == other.id && fullHandle == other.fullHandle;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode ^ fullHandle.hashCode;
}

/// generated route for
/// [_i47.FeedMarketplaceDetailScreen]
class FeedMarketplaceDetailRoute
    extends _i82.PageRouteInfo<FeedMarketplaceDetailRouteArgs> {
  FeedMarketplaceDetailRoute({
    _i84.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         FeedMarketplaceDetailRoute.name,
         args: FeedMarketplaceDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'FeedMarketplaceDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FeedMarketplaceDetailRouteArgs>();
      return _i47.FeedMarketplaceDetailScreen(key: args.key, id: args.id);
    },
  );
}

class FeedMarketplaceDetailRouteArgs {
  const FeedMarketplaceDetailRouteArgs({this.key, required this.id});

  final _i84.Key? key;

  final String id;

  @override
  String toString() {
    return 'FeedMarketplaceDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FeedMarketplaceDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i48.FeedMarketplaceScreen]
class FeedMarketplaceRoute extends _i82.PageRouteInfo<void> {
  const FeedMarketplaceRoute({List<_i82.PageRouteInfo>? children})
    : super(FeedMarketplaceRoute.name, initialChildren: children);

  static const String name = 'FeedMarketplaceRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i48.FeedMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i49.FileDetailScreen]
class FileDetailRoute extends _i82.PageRouteInfo<FileDetailRouteArgs> {
  FileDetailRoute({
    _i83.Key? key,
    required _i85.SnCloudFile item,
    String? heroTag,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         FileDetailRoute.name,
         args: FileDetailRouteArgs(key: key, item: item, heroTag: heroTag),
         initialChildren: children,
       );

  static const String name = 'FileDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FileDetailRouteArgs>();
      return _i49.FileDetailScreen(
        key: args.key,
        item: args.item,
        heroTag: args.heroTag,
      );
    },
  );
}

class FileDetailRouteArgs {
  const FileDetailRouteArgs({this.key, required this.item, this.heroTag});

  final _i83.Key? key;

  final _i85.SnCloudFile item;

  final String? heroTag;

  @override
  String toString() {
    return 'FileDetailRouteArgs{key: $key, item: $item, heroTag: $heroTag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FileDetailRouteArgs) return false;
    return key == other.key && item == other.item && heroTag == other.heroTag;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode ^ heroTag.hashCode;
}

/// generated route for
/// [_i50.FileListScreen]
class FileListRoute extends _i82.PageRouteInfo<void> {
  const FileListRoute({List<_i82.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i50.FileListScreen();
    },
  );
}

/// generated route for
/// [_i51.FitnessDashboardRoute]
class FitnessDashboardRoute extends _i82.PageRouteInfo<void> {
  const FitnessDashboardRoute({List<_i82.PageRouteInfo>? children})
    : super(FitnessDashboardRoute.name, initialChildren: children);

  static const String name = 'FitnessDashboardRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i51.FitnessDashboardRoute();
    },
  );
}

/// generated route for
/// [_i52.GoalsRoute]
class GoalsRoute extends _i82.PageRouteInfo<void> {
  const GoalsRoute({List<_i82.PageRouteInfo>? children})
    : super(GoalsRoute.name, initialChildren: children);

  static const String name = 'GoalsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i52.GoalsRoute();
    },
  );
}

/// generated route for
/// [_i53.HealthSyncScreen]
class HealthSyncRoute extends _i82.PageRouteInfo<void> {
  const HealthSyncRoute({List<_i82.PageRouteInfo>? children})
    : super(HealthSyncRoute.name, initialChildren: children);

  static const String name = 'HealthSyncRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i53.HealthSyncScreen();
    },
  );
}

/// generated route for
/// [_i54.LevelingScreen]
class LevelingRoute extends _i82.PageRouteInfo<void> {
  const LevelingRoute({List<_i82.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i54.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i55.LivestreamWatchScreen]
class LivestreamWatchRoute
    extends _i82.PageRouteInfo<LivestreamWatchRouteArgs> {
  LivestreamWatchRoute({
    _i84.Key? key,
    required String livestreamId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         LivestreamWatchRoute.name,
         args: LivestreamWatchRouteArgs(key: key, livestreamId: livestreamId),
         rawPathParams: {'id': livestreamId},
         initialChildren: children,
       );

  static const String name = 'LivestreamWatchRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LivestreamWatchRouteArgs>(
        orElse: () =>
            LivestreamWatchRouteArgs(livestreamId: pathParams.getString('id')),
      );
      return _i55.LivestreamWatchScreen(
        key: args.key,
        livestreamId: args.livestreamId,
      );
    },
  );
}

class LivestreamWatchRouteArgs {
  const LivestreamWatchRouteArgs({this.key, required this.livestreamId});

  final _i84.Key? key;

  final String livestreamId;

  @override
  String toString() {
    return 'LivestreamWatchRouteArgs{key: $key, livestreamId: $livestreamId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LivestreamWatchRouteArgs) return false;
    return key == other.key && livestreamId == other.livestreamId;
  }

  @override
  int get hashCode => key.hashCode ^ livestreamId.hashCode;
}

/// generated route for
/// [_i56.LoginScreen]
class LoginRoute extends _i82.PageRouteInfo<void> {
  const LoginRoute({List<_i82.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i56.LoginScreen();
    },
  );
}

/// generated route for
/// [_i57.MeetDetailScreen]
class MeetDetailRoute extends _i82.PageRouteInfo<MeetDetailRouteArgs> {
  MeetDetailRoute({
    _i83.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         MeetDetailRoute.name,
         args: MeetDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MeetDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MeetDetailRouteArgs>(
        orElse: () => MeetDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i57.MeetDetailScreen(key: args.key, id: args.id);
    },
  );
}

class MeetDetailRouteArgs {
  const MeetDetailRouteArgs({this.key, required this.id});

  final _i83.Key? key;

  final String id;

  @override
  String toString() {
    return 'MeetDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MeetDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i57.MeetScreen]
class MeetRoute extends _i82.PageRouteInfo<void> {
  const MeetRoute({List<_i82.PageRouteInfo>? children})
    : super(MeetRoute.name, initialChildren: children);

  static const String name = 'MeetRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i57.MeetScreen();
    },
  );
}

/// generated route for
/// [_i58.MetricsRoute]
class MetricsRoute extends _i82.PageRouteInfo<void> {
  const MetricsRoute({List<_i82.PageRouteInfo>? children})
    : super(MetricsRoute.name, initialChildren: children);

  static const String name = 'MetricsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i58.MetricsRoute();
    },
  );
}

/// generated route for
/// [_i42.NewChatScreen]
class NewChatRoute extends _i82.PageRouteInfo<void> {
  const NewChatRoute({List<_i82.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i42.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i43.NewPublisherScreen]
class NewPublisherRoute extends _i82.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i82.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i43.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i59.PhysicalPassportScreen]
class PhysicalPassportRoute extends _i82.PageRouteInfo<void> {
  const PhysicalPassportRoute({List<_i82.PageRouteInfo>? children})
    : super(PhysicalPassportRoute.name, initialChildren: children);

  static const String name = 'PhysicalPassportRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i59.PhysicalPassportScreen();
    },
  );
}

/// generated route for
/// [_i60.PollEditorScreen]
class PollEditorRoute extends _i82.PageRouteInfo<PollEditorRouteArgs> {
  PollEditorRoute({
    _i83.Key? key,
    String? initialPollId,
    String? initialPublisher,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         PollEditorRoute.name,
         args: PollEditorRouteArgs(
           key: key,
           initialPollId: initialPollId,
           initialPublisher: initialPublisher,
         ),
         initialChildren: children,
       );

  static const String name = 'PollEditorRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PollEditorRouteArgs>(
        orElse: () => const PollEditorRouteArgs(),
      );
      return _i60.PollEditorScreen(
        key: args.key,
        initialPollId: args.initialPollId,
        initialPublisher: args.initialPublisher,
      );
    },
  );
}

class PollEditorRouteArgs {
  const PollEditorRouteArgs({
    this.key,
    this.initialPollId,
    this.initialPublisher,
  });

  final _i83.Key? key;

  final String? initialPollId;

  final String? initialPublisher;

  @override
  String toString() {
    return 'PollEditorRouteArgs{key: $key, initialPollId: $initialPollId, initialPublisher: $initialPublisher}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PollEditorRouteArgs) return false;
    return key == other.key &&
        initialPollId == other.initialPollId &&
        initialPublisher == other.initialPublisher;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialPollId.hashCode ^ initialPublisher.hashCode;
}

/// generated route for
/// [_i61.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i82.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i82.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i61.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i62.PostCategoryDetailScreen]
class PostCategoryDetailRoute
    extends _i82.PageRouteInfo<PostCategoryDetailRouteArgs> {
  PostCategoryDetailRoute({
    _i84.Key? key,
    required String slug,
    required bool isCategory,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         PostCategoryDetailRoute.name,
         args: PostCategoryDetailRouteArgs(
           key: key,
           slug: slug,
           isCategory: isCategory,
         ),
         initialChildren: children,
       );

  static const String name = 'PostCategoryDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostCategoryDetailRouteArgs>();
      return _i62.PostCategoryDetailScreen(
        key: args.key,
        slug: args.slug,
        isCategory: args.isCategory,
      );
    },
  );
}

class PostCategoryDetailRouteArgs {
  const PostCategoryDetailRouteArgs({
    this.key,
    required this.slug,
    required this.isCategory,
  });

  final _i84.Key? key;

  final String slug;

  final bool isCategory;

  @override
  String toString() {
    return 'PostCategoryDetailRouteArgs{key: $key, slug: $slug, isCategory: $isCategory}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostCategoryDetailRouteArgs) return false;
    return key == other.key &&
        slug == other.slug &&
        isCategory == other.isCategory;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode ^ isCategory.hashCode;
}

/// generated route for
/// [_i63.PostDetailScreen]
class PostDetailRoute extends _i82.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i83.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i63.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i83.Key? key;

  final String id;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i64.PostShuffleScreen]
class PostShuffleRoute extends _i82.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i82.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i64.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i65.ProgressScreen]
class ProgressRoute extends _i82.PageRouteInfo<void> {
  const ProgressRoute({List<_i82.PageRouteInfo>? children})
    : super(ProgressRoute.name, initialChildren: children);

  static const String name = 'ProgressRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i65.ProgressScreen();
    },
  );
}

/// generated route for
/// [_i66.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i82.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i84.Key? key,
    required String name,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PublisherProfileRouteArgs>();
      return _i66.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i84.Key? key;

  final String name;

  @override
  String toString() {
    return 'PublisherProfileRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublisherProfileRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i67.RealmDetailScreen]
class RealmDetailRoute extends _i82.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i84.Key? key,
    required String slug,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i67.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i84.Key? key;

  final String slug;

  @override
  String toString() {
    return 'RealmDetailRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmDetailRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i68.RealmEditScreen]
class RealmEditRoute extends _i82.PageRouteInfo<RealmEditRouteArgs> {
  RealmEditRoute({
    _i84.Key? key,
    String? slug,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         RealmEditRoute.name,
         args: RealmEditRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'RealmEditRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RealmEditRouteArgs>(
        orElse: () => const RealmEditRouteArgs(),
      );
      return _i68.RealmEditScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmEditRouteArgs {
  const RealmEditRouteArgs({this.key, this.slug});

  final _i84.Key? key;

  final String? slug;

  @override
  String toString() {
    return 'RealmEditRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmEditRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i69.RealmListScreen]
class RealmListRoute extends _i82.PageRouteInfo<void> {
  const RealmListRoute({List<_i82.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i69.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i68.RealmNewScreen]
class RealmNewRoute extends _i82.PageRouteInfo<void> {
  const RealmNewRoute({List<_i82.PageRouteInfo>? children})
    : super(RealmNewRoute.name, initialChildren: children);

  static const String name = 'RealmNewRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i68.RealmNewScreen();
    },
  );
}

/// generated route for
/// [_i70.RelationshipScreen]
class RelationshipRoute extends _i82.PageRouteInfo<void> {
  const RelationshipRoute({List<_i82.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i70.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i71.SearchMessagesScreen]
class SearchMessagesRoute extends _i82.PageRouteInfo<SearchMessagesRouteArgs> {
  SearchMessagesRoute({
    _i84.Key? key,
    required String roomId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         SearchMessagesRoute.name,
         args: SearchMessagesRouteArgs(key: key, roomId: roomId),
         initialChildren: children,
       );

  static const String name = 'SearchMessagesRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchMessagesRouteArgs>();
      return _i71.SearchMessagesScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class SearchMessagesRouteArgs {
  const SearchMessagesRouteArgs({this.key, required this.roomId});

  final _i84.Key? key;

  final String roomId;

  @override
  String toString() {
    return 'SearchMessagesRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchMessagesRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i72.SettingsScreen]
class SettingsRoute extends _i82.PageRouteInfo<void> {
  const SettingsRoute({List<_i82.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i72.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i73.StickerMarketplacePackDetailScreen]
class StickerMarketplacePackDetailRoute
    extends _i82.PageRouteInfo<StickerMarketplacePackDetailRouteArgs> {
  StickerMarketplacePackDetailRoute({
    _i84.Key? key,
    required String id,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         StickerMarketplacePackDetailRoute.name,
         args: StickerMarketplacePackDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'StickerMarketplacePackDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StickerMarketplacePackDetailRouteArgs>();
      return _i73.StickerMarketplacePackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class StickerMarketplacePackDetailRouteArgs {
  const StickerMarketplacePackDetailRouteArgs({this.key, required this.id});

  final _i84.Key? key;

  final String id;

  @override
  String toString() {
    return 'StickerMarketplacePackDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StickerMarketplacePackDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i74.StickerMarketplaceScreen]
class StickerMarketplaceRoute extends _i82.PageRouteInfo<void> {
  const StickerMarketplaceRoute({List<_i82.PageRouteInfo>? children})
    : super(StickerMarketplaceRoute.name, initialChildren: children);

  static const String name = 'StickerMarketplaceRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i74.StickerMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i75.TabsScreen]
class TabsRoute extends _i82.PageRouteInfo<void> {
  const TabsRoute({List<_i82.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i75.TabsScreen();
    },
  );
}

/// generated route for
/// [_i76.ThoughtScreen]
class ThoughtRoute extends _i82.PageRouteInfo<void> {
  const ThoughtRoute({List<_i82.PageRouteInfo>? children})
    : super(ThoughtRoute.name, initialChildren: children);

  static const String name = 'ThoughtRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i76.ThoughtScreen();
    },
  );
}

/// generated route for
/// [_i77.TicketDetailScreen]
class TicketDetailRoute extends _i82.PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    _i84.Key? key,
    required String ticketId,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(key: key, ticketId: ticketId),
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TicketDetailRouteArgs>();
      return _i77.TicketDetailScreen(key: args.key, ticketId: args.ticketId);
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticketId});

  final _i84.Key? key;

  final String ticketId;

  @override
  String toString() {
    return 'TicketDetailRouteArgs{key: $key, ticketId: $ticketId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TicketDetailRouteArgs) return false;
    return key == other.key && ticketId == other.ticketId;
  }

  @override
  int get hashCode => key.hashCode ^ ticketId.hashCode;
}

/// generated route for
/// [_i78.TicketListScreen]
class TicketListRoute extends _i82.PageRouteInfo<void> {
  const TicketListRoute({List<_i82.PageRouteInfo>? children})
    : super(TicketListRoute.name, initialChildren: children);

  static const String name = 'TicketListRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i78.TicketListScreen();
    },
  );
}

/// generated route for
/// [_i79.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i82.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i84.Key? key,
    _i79.SearchTab initialTab = _i79.SearchTab.posts,
    List<_i82.PageRouteInfo>? children,
  }) : super(
         UniversalSearchRoute.name,
         args: UniversalSearchRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'UniversalSearchRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UniversalSearchRouteArgs>(
        orElse: () => const UniversalSearchRouteArgs(),
      );
      return _i79.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i79.SearchTab.posts,
  });

  final _i84.Key? key;

  final _i79.SearchTab initialTab;

  @override
  String toString() {
    return 'UniversalSearchRouteArgs{key: $key, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UniversalSearchRouteArgs) return false;
    return key == other.key && initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [_i80.WalletScreen]
class WalletRoute extends _i82.PageRouteInfo<void> {
  const WalletRoute({List<_i82.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i80.WalletScreen();
    },
  );
}

/// generated route for
/// [_i81.WorkoutsScreen]
class WorkoutsRoute extends _i82.PageRouteInfo<void> {
  const WorkoutsRoute({List<_i82.PageRouteInfo>? children})
    : super(WorkoutsRoute.name, initialChildren: children);

  static const String name = 'WorkoutsRoute';

  static _i82.PageInfo page = _i82.PageInfo(
    name,
    builder: (data) {
      return const _i81.WorkoutsScreen();
    },
  );
}
