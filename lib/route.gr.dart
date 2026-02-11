// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i68;
import 'package:flutter/foundation.dart' as _i70;
import 'package:flutter/material.dart' as _i69;
import 'package:island/accounts/account_screen.dart' as _i5;
import 'package:island/accounts/screens/leveling.dart' as _i47;
import 'package:island/accounts/screens/me/account_settings.dart' as _i6;
import 'package:island/accounts/screens/me/profile_update.dart' as _i7;
import 'package:island/accounts/screens/profile.dart' as _i4;
import 'package:island/accounts/screens/relationship.dart' as _i59;
import 'package:island/auth/captcha.dart' as _i15;
import 'package:island/auth/create_account.dart' as _i19;
import 'package:island/auth/login.dart' as _i48;
import 'package:island/auth/oidc.native.dart' as _i49;
import 'package:island/chat/widgets/call_screen.dart' as _i14;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i16;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i18;
import 'package:island/chat/widgets/chat_room_form.dart' as _i39;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i17;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i60;
import 'package:island/creators/screens/hub.dart' as _i21;
import 'package:island/creators/screens/poll/poll_list.dart' as _i22;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i23;
import 'package:island/creators/screens/publishers_form.dart' as _i40;
import 'package:island/creators/screens/sites/site_detail.dart' as _i24;
import 'package:island/creators/screens/sites/site_list.dart' as _i25;
import 'package:island/creators/screens/stickers/stickers.dart' as _i26;
import 'package:island/creators/screens/webfeed/webfeed_list.dart' as _i20;
import 'package:island/developers/screens/app_detail.dart' as _i28;
import 'package:island/developers/screens/app_secrets.dart' as _i8;
import 'package:island/developers/screens/apps.dart' as _i30;
import 'package:island/developers/screens/bot_detail.dart' as _i32;
import 'package:island/developers/screens/bot_keys.dart' as _i12;
import 'package:island/developers/screens/bots.dart' as _i13;
import 'package:island/developers/screens/edit_app.dart' as _i29;
import 'package:island/developers/screens/edit_bot.dart' as _i33;
import 'package:island/developers/screens/edit_project.dart' as _i36;
import 'package:island/developers/screens/hub.dart' as _i35;
import 'package:island/developers/screens/new_app.dart' as _i31;
import 'package:island/developers/screens/new_bot.dart' as _i34;
import 'package:island/developers/screens/new_project.dart' as _i37;
import 'package:island/discovery/explore.dart' as _i41;
import 'package:island/discovery/screens/article_detail.dart' as _i10;
import 'package:island/discovery/screens/articles.dart' as _i11;
import 'package:island/discovery/screens/feeds/feed_detail.dart' as _i42;
import 'package:island/discovery/screens/feeds/feed_marketplace.dart' as _i43;
import 'package:island/discovery/screens/realms.dart' as _i38;
import 'package:island/discovery/search.dart' as _i66;
import 'package:island/drive/files/file_detail.dart' as _i44;
import 'package:island/drive/files/file_list.dart' as _i45;
import 'package:island/fitness/fitness_screen.dart' as _i46;
import 'package:island/polls/screens/poll_editor.dart' as _i50;
import 'package:island/posts/compose.dart' as _i72;
import 'package:island/posts/screens/compose_article.dart' as _i9;
import 'package:island/posts/screens/post_categories_list.dart' as _i51;
import 'package:island/posts/screens/post_category_detail.dart' as _i52;
import 'package:island/posts/screens/post_detail.dart' as _i53;
import 'package:island/posts/screens/publisher_profile.dart' as _i55;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i54;
import 'package:island/realms/screens/realm_detail.dart' as _i56;
import 'package:island/realms/screens/realm_form.dart' as _i57;
import 'package:island/realms/screens/realms.dart' as _i58;
import 'package:island/reports/screens/report_detail.dart' as _i2;
import 'package:island/reports/screens/report_list.dart' as _i3;
import 'package:island/settings/about.dart' as _i1;
import 'package:island/settings/dashboard/dash.dart' as _i27;
import 'package:island/settings/settings.dart' as _i61;
import 'package:island/settings/tabs_screen.dart' as _i64;
import 'package:island/stickers/screens/pack_detail.dart' as _i62;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i63;
import 'package:island/thoughts/screens/think.dart' as _i65;
import 'package:island/wallets/wallet.dart' as _i67;
import 'package:solar_network_sdk/solar_network_sdk.dart' as _i71;

/// generated route for
/// [_i1.AboutScreen]
class AboutRoute extends _i68.PageRouteInfo<void> {
  const AboutRoute({List<_i68.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutScreen();
    },
  );
}

/// generated route for
/// [_i2.AbuseReportDetailScreen]
class AbuseReportDetailRoute
    extends _i68.PageRouteInfo<AbuseReportDetailRouteArgs> {
  AbuseReportDetailRoute({
    _i69.Key? key,
    required String reportId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AbuseReportDetailRoute.name,
         args: AbuseReportDetailRouteArgs(key: key, reportId: reportId),
         initialChildren: children,
       );

  static const String name = 'AbuseReportDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AbuseReportDetailRouteArgs>();
      return _i2.AbuseReportDetailScreen(
        key: args.key,
        reportId: args.reportId,
      );
    },
  );
}

class AbuseReportDetailRouteArgs {
  const AbuseReportDetailRouteArgs({this.key, required this.reportId});

  final _i69.Key? key;

  final String reportId;

  @override
  String toString() {
    return 'AbuseReportDetailRouteArgs{key: $key, reportId: $reportId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AbuseReportDetailRouteArgs) return false;
    return key == other.key && reportId == other.reportId;
  }

  @override
  int get hashCode => key.hashCode ^ reportId.hashCode;
}

/// generated route for
/// [_i3.AbuseReportListScreen]
class AbuseReportListRoute extends _i68.PageRouteInfo<void> {
  const AbuseReportListRoute({List<_i68.PageRouteInfo>? children})
    : super(AbuseReportListRoute.name, initialChildren: children);

  static const String name = 'AbuseReportListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i3.AbuseReportListScreen();
    },
  );
}

/// generated route for
/// [_i4.AccountProfileScreen]
class AccountProfileRoute extends _i68.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i70.Key? key,
    required String name,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AccountProfileRouteArgs>();
      return _i4.AccountProfileScreen(key: args.key, name: args.name);
    },
  );
}

class AccountProfileRouteArgs {
  const AccountProfileRouteArgs({this.key, required this.name});

  final _i70.Key? key;

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
/// [_i5.AccountScreen]
class AccountRoute extends _i68.PageRouteInfo<void> {
  const AccountRoute({List<_i68.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i5.AccountScreen();
    },
  );
}

/// generated route for
/// [_i6.AccountSettingsScreen]
class AccountSettingsRoute extends _i68.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i68.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i6.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i7.AccountUpdateProfileScreen]
class AccountUpdateProfileRoute extends _i68.PageRouteInfo<void> {
  const AccountUpdateProfileRoute({List<_i68.PageRouteInfo>? children})
    : super(AccountUpdateProfileRoute.name, initialChildren: children);

  static const String name = 'AccountUpdateProfileRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i7.AccountUpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i8.AppSecretsScreen]
class AppSecretsRoute extends _i68.PageRouteInfo<AppSecretsRouteArgs> {
  AppSecretsRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    required String appId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
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

  final _i69.Key? key;

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
class ArticleComposeRoute extends _i68.PageRouteInfo<ArticleComposeRouteArgs> {
  ArticleComposeRoute({
    _i69.Key? key,
    _i71.SnPost? originalPost,
    _i72.PostComposeInitialState? initialState,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
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

  final _i69.Key? key;

  final _i71.SnPost? originalPost;

  final _i72.PostComposeInitialState? initialState;

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
class ArticleDetailRoute extends _i68.PageRouteInfo<ArticleDetailRouteArgs> {
  ArticleDetailRoute({
    _i69.Key? key,
    required String articleId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ArticleDetailRoute.name,
         args: ArticleDetailRouteArgs(key: key, articleId: articleId),
         initialChildren: children,
       );

  static const String name = 'ArticleDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleDetailRouteArgs>();
      return _i10.ArticleDetailScreen(key: args.key, articleId: args.articleId);
    },
  );
}

class ArticleDetailRouteArgs {
  const ArticleDetailRouteArgs({this.key, required this.articleId});

  final _i69.Key? key;

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
class ArticleEditRoute extends _i68.PageRouteInfo<ArticleEditRouteArgs> {
  ArticleEditRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ArticleEditRoute.name,
         args: ArticleEditRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ArticleEditRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleEditRouteArgs>();
      return _i9.ArticleEditScreen(key: args.key, id: args.id);
    },
  );
}

class ArticleEditRouteArgs {
  const ArticleEditRouteArgs({this.key, required this.id});

  final _i69.Key? key;

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
class ArticleStandRoute extends _i68.PageRouteInfo<void> {
  const ArticleStandRoute({List<_i68.PageRouteInfo>? children})
    : super(ArticleStandRoute.name, initialChildren: children);

  static const String name = 'ArticleStandRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i11.ArticleStandScreen();
    },
  );
}

/// generated route for
/// [_i12.BotKeysScreen]
class BotKeysRoute extends _i68.PageRouteInfo<BotKeysRouteArgs> {
  BotKeysRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    required String botId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BotKeysRouteArgs>();
      return _i12.BotKeysScreen(
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

  final _i69.Key? key;

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
/// [_i13.BotsScreen]
class BotsRoute extends _i68.PageRouteInfo<BotsRouteArgs> {
  BotsRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BotsRouteArgs>();
      return _i13.BotsScreen(
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

  final _i69.Key? key;

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
/// [_i14.CallScreen]
class CallRoute extends _i68.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i69.Key? key,
    required _i71.SnChatRoom room,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(key: key, room: room),
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CallRouteArgs>();
      return _i14.CallScreen(key: args.key, room: args.room);
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({this.key, required this.room});

  final _i69.Key? key;

  final _i71.SnChatRoom room;

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
/// [_i15.CaptchaScreen]
class CaptchaRoute extends _i68.PageRouteInfo<void> {
  const CaptchaRoute({List<_i68.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i15.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i16.ChatDetailScreen]
class ChatDetailRoute extends _i68.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatDetailRouteArgs>();
      return _i16.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i69.Key? key;

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
/// [_i17.ChatRoomScreen]
class ChatRoomRoute extends _i68.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRoomRouteArgs>();
      return _i17.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i69.Key? key;

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
class ChatRoute extends _i68.PageRouteInfo<void> {
  const ChatRoute({List<_i68.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i18.ChatScreen();
    },
  );
}

/// generated route for
/// [_i19.CreateAccountScreen]
class CreateAccountRoute extends _i68.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i68.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i19.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i20.CreatorFeedListScreen]
class CreatorFeedListRoute
    extends _i68.PageRouteInfo<CreatorFeedListRouteArgs> {
  CreatorFeedListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CreatorFeedListRoute.name,
         args: CreatorFeedListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorFeedListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorFeedListRouteArgs>();
      return _i20.CreatorFeedListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorFeedListRouteArgs {
  const CreatorFeedListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

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
/// [_i21.CreatorHubScreen]
class CreatorHubRoute extends _i68.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i68.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i21.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i22.CreatorPollListScreen]
class CreatorPollListRoute
    extends _i68.PageRouteInfo<CreatorPollListRouteArgs> {
  CreatorPollListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CreatorPollListRoute.name,
         args: CreatorPollListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorPollListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorPollListRouteArgs>();
      return _i22.CreatorPollListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPollListRouteArgs {
  const CreatorPollListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

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
/// [_i23.CreatorPostListScreen]
class CreatorPostListRoute
    extends _i68.PageRouteInfo<CreatorPostListRouteArgs> {
  CreatorPostListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CreatorPostListRoute.name,
         args: CreatorPostListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorPostListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorPostListRouteArgs>();
      return _i23.CreatorPostListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPostListRouteArgs {
  const CreatorPostListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

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
/// [_i24.CreatorSiteDetailScreen]
class CreatorSiteDetailRoute
    extends _i68.PageRouteInfo<CreatorSiteDetailRouteArgs> {
  CreatorSiteDetailRoute({
    _i69.Key? key,
    required String siteSlug,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorSiteDetailRouteArgs>();
      return _i24.CreatorSiteDetailScreen(
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

  final _i69.Key? key;

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
/// [_i25.CreatorSiteListScreen]
class CreatorSiteListRoute
    extends _i68.PageRouteInfo<CreatorSiteListRouteArgs> {
  CreatorSiteListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CreatorSiteListRoute.name,
         args: CreatorSiteListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorSiteListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorSiteListRouteArgs>();
      return _i25.CreatorSiteListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorSiteListRouteArgs {
  const CreatorSiteListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

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
/// [_i26.CreatorStickerListScreen]
class CreatorStickerListRoute
    extends _i68.PageRouteInfo<CreatorStickerListRouteArgs> {
  CreatorStickerListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CreatorStickerListRoute.name,
         args: CreatorStickerListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'CreatorStickerListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorStickerListRouteArgs>();
      return _i26.CreatorStickerListScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorStickerListRouteArgs {
  const CreatorStickerListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

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
/// [_i27.DashboardScreen]
class DashboardRoute extends _i68.PageRouteInfo<void> {
  const DashboardRoute({List<_i68.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i27.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i28.DeveloperAppDetailScreen]
class DeveloperAppDetailRoute
    extends _i68.PageRouteInfo<DeveloperAppDetailRouteArgs> {
  DeveloperAppDetailRoute({
    _i69.Key? key,
    required String pubName,
    required String projectId,
    required String appId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppDetailRouteArgs>();
      return _i28.DeveloperAppDetailScreen(
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

  final _i69.Key? key;

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
/// [_i29.DeveloperAppEditScreen]
class DeveloperAppEditRoute
    extends _i68.PageRouteInfo<DeveloperAppEditRouteArgs> {
  DeveloperAppEditRoute({
    _i69.Key? key,
    required String pubName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppEditRouteArgs>();
      return _i29.DeveloperAppEditScreen(
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

  final _i69.Key? key;

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
/// [_i30.DeveloperAppListScreen]
class DeveloperAppListRoute
    extends _i68.PageRouteInfo<DeveloperAppListRouteArgs> {
  DeveloperAppListRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppListRouteArgs>();
      return _i30.DeveloperAppListScreen(
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

  final _i69.Key? key;

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
/// [_i31.DeveloperAppNewScreen]
class DeveloperAppNewRoute
    extends _i68.PageRouteInfo<DeveloperAppNewRouteArgs> {
  DeveloperAppNewRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperAppNewRouteArgs>();
      return _i31.DeveloperAppNewScreen(
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

  final _i69.Key? key;

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
/// [_i32.DeveloperBotDetailScreen]
class DeveloperBotDetailRoute
    extends _i68.PageRouteInfo<DeveloperBotDetailRouteArgs> {
  DeveloperBotDetailRoute({
    _i69.Key? key,
    required String pubName,
    required String projectId,
    required String botId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotDetailRouteArgs>();
      return _i32.DeveloperBotDetailScreen(
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

  final _i69.Key? key;

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
/// [_i33.DeveloperBotEditScreen]
class DeveloperBotEditRoute
    extends _i68.PageRouteInfo<DeveloperBotEditRouteArgs> {
  DeveloperBotEditRoute({
    _i69.Key? key,
    required String pubName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotEditRouteArgs>();
      return _i33.DeveloperBotEditScreen(
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

  final _i69.Key? key;

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
/// [_i34.DeveloperBotNewScreen]
class DeveloperBotNewRoute
    extends _i68.PageRouteInfo<DeveloperBotNewRouteArgs> {
  DeveloperBotNewRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperBotNewRouteArgs>();
      return _i34.DeveloperBotNewScreen(
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

  final _i69.Key? key;

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
/// [_i35.DeveloperHubScreen]
class DeveloperHubRoute extends _i68.PageRouteInfo<DeveloperHubRouteArgs> {
  DeveloperHubRoute({
    _i69.Key? key,
    String? initialPublisherName,
    String? initialProjectId,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperHubRouteArgs>(
        orElse: () => const DeveloperHubRouteArgs(),
      );
      return _i35.DeveloperHubScreen(
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

  final _i69.Key? key;

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
/// [_i36.DeveloperProjectEditScreen]
class DeveloperProjectEditRoute
    extends _i68.PageRouteInfo<DeveloperProjectEditRouteArgs> {
  DeveloperProjectEditRoute({
    _i69.Key? key,
    required String pubName,
    String? id,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperProjectEditRouteArgs>();
      return _i36.DeveloperProjectEditScreen(
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

  final _i69.Key? key;

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
/// [_i37.DeveloperProjectNewScreen]
class DeveloperProjectNewRoute
    extends _i68.PageRouteInfo<DeveloperProjectNewRouteArgs> {
  DeveloperProjectNewRoute({
    _i69.Key? key,
    required String publisherName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         DeveloperProjectNewRoute.name,
         args: DeveloperProjectNewRouteArgs(
           key: key,
           publisherName: publisherName,
         ),
         initialChildren: children,
       );

  static const String name = 'DeveloperProjectNewRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeveloperProjectNewRouteArgs>();
      return _i37.DeveloperProjectNewScreen(
        key: args.key,
        publisherName: args.publisherName,
      );
    },
  );
}

class DeveloperProjectNewRouteArgs {
  const DeveloperProjectNewRouteArgs({this.key, required this.publisherName});

  final _i69.Key? key;

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
/// [_i38.DiscoveryRealmsScreen]
class DiscoveryRealmsRoute extends _i68.PageRouteInfo<void> {
  const DiscoveryRealmsRoute({List<_i68.PageRouteInfo>? children})
    : super(DiscoveryRealmsRoute.name, initialChildren: children);

  static const String name = 'DiscoveryRealmsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i38.DiscoveryRealmsScreen();
    },
  );
}

/// generated route for
/// [_i39.EditChatScreen]
class EditChatRoute extends _i68.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i69.Key? key, String? id, List<_i68.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => const EditChatRouteArgs(),
      );
      return _i39.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i69.Key? key;

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
/// [_i40.EditPublisherScreen]
class EditPublisherRoute extends _i68.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i69.Key? key,
    String? name,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => const EditPublisherRouteArgs(),
      );
      return _i40.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i69.Key? key;

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
/// [_i41.ExploreScreen]
class ExploreRoute extends _i68.PageRouteInfo<void> {
  const ExploreRoute({List<_i68.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i41.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i42.FeedMarketplaceDetailScreen]
class FeedMarketplaceDetailRoute
    extends _i68.PageRouteInfo<FeedMarketplaceDetailRouteArgs> {
  FeedMarketplaceDetailRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         FeedMarketplaceDetailRoute.name,
         args: FeedMarketplaceDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'FeedMarketplaceDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FeedMarketplaceDetailRouteArgs>();
      return _i42.FeedMarketplaceDetailScreen(key: args.key, id: args.id);
    },
  );
}

class FeedMarketplaceDetailRouteArgs {
  const FeedMarketplaceDetailRouteArgs({this.key, required this.id});

  final _i69.Key? key;

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
/// [_i43.FeedMarketplaceScreen]
class FeedMarketplaceRoute extends _i68.PageRouteInfo<void> {
  const FeedMarketplaceRoute({List<_i68.PageRouteInfo>? children})
    : super(FeedMarketplaceRoute.name, initialChildren: children);

  static const String name = 'FeedMarketplaceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i43.FeedMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i44.FileDetailScreen]
class FileDetailRoute extends _i68.PageRouteInfo<FileDetailRouteArgs> {
  FileDetailRoute({
    _i70.Key? key,
    required _i71.SnCloudFile item,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         FileDetailRoute.name,
         args: FileDetailRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'FileDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FileDetailRouteArgs>();
      return _i44.FileDetailScreen(key: args.key, item: args.item);
    },
  );
}

class FileDetailRouteArgs {
  const FileDetailRouteArgs({this.key, required this.item});

  final _i70.Key? key;

  final _i71.SnCloudFile item;

  @override
  String toString() {
    return 'FileDetailRouteArgs{key: $key, item: $item}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FileDetailRouteArgs) return false;
    return key == other.key && item == other.item;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode;
}

/// generated route for
/// [_i45.FileListScreen]
class FileListRoute extends _i68.PageRouteInfo<void> {
  const FileListRoute({List<_i68.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i45.FileListScreen();
    },
  );
}

/// generated route for
/// [_i46.FitnessActivityScreen]
class FitnessActivityRoute extends _i68.PageRouteInfo<void> {
  const FitnessActivityRoute({List<_i68.PageRouteInfo>? children})
    : super(FitnessActivityRoute.name, initialChildren: children);

  static const String name = 'FitnessActivityRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i46.FitnessActivityScreen();
    },
  );
}

/// generated route for
/// [_i47.LevelingScreen]
class LevelingRoute extends _i68.PageRouteInfo<void> {
  const LevelingRoute({List<_i68.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i47.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i48.LoginScreen]
class LoginRoute extends _i68.PageRouteInfo<void> {
  const LoginRoute({List<_i68.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i48.LoginScreen();
    },
  );
}

/// generated route for
/// [_i39.NewChatScreen]
class NewChatRoute extends _i68.PageRouteInfo<void> {
  const NewChatRoute({List<_i68.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i39.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i40.NewPublisherScreen]
class NewPublisherRoute extends _i68.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i68.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i40.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i49.OidcScreen]
class OidcRoute extends _i68.PageRouteInfo<OidcRouteArgs> {
  OidcRoute({
    _i70.Key? key,
    required String provider,
    String? title,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         OidcRoute.name,
         args: OidcRouteArgs(key: key, provider: provider, title: title),
         initialChildren: children,
       );

  static const String name = 'OidcRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OidcRouteArgs>();
      return _i49.OidcScreen(
        key: args.key,
        provider: args.provider,
        title: args.title,
      );
    },
  );
}

class OidcRouteArgs {
  const OidcRouteArgs({this.key, required this.provider, this.title});

  final _i70.Key? key;

  final String provider;

  final String? title;

  @override
  String toString() {
    return 'OidcRouteArgs{key: $key, provider: $provider, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OidcRouteArgs) return false;
    return key == other.key &&
        provider == other.provider &&
        title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ provider.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i50.PollEditorScreen]
class PollEditorRoute extends _i68.PageRouteInfo<PollEditorRouteArgs> {
  PollEditorRoute({
    _i70.Key? key,
    String? initialPollId,
    String? initialPublisher,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PollEditorRouteArgs>(
        orElse: () => const PollEditorRouteArgs(),
      );
      return _i50.PollEditorScreen(
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

  final _i70.Key? key;

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
/// [_i51.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i68.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i68.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i51.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i52.PostCategoryDetailScreen]
class PostCategoryDetailRoute
    extends _i68.PageRouteInfo<PostCategoryDetailRouteArgs> {
  PostCategoryDetailRoute({
    _i69.Key? key,
    required String slug,
    required bool isCategory,
    List<_i68.PageRouteInfo>? children,
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

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostCategoryDetailRouteArgs>();
      return _i52.PostCategoryDetailScreen(
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

  final _i69.Key? key;

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
/// [_i53.PostDetailScreen]
class PostDetailRoute extends _i68.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i70.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostDetailRouteArgs>();
      return _i53.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i70.Key? key;

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
/// [_i54.PostShuffleScreen]
class PostShuffleRoute extends _i68.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i68.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i54.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i55.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i68.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i69.Key? key,
    required String name,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PublisherProfileRouteArgs>();
      return _i55.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i69.Key? key;

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
/// [_i56.RealmDetailScreen]
class RealmDetailRoute extends _i68.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i69.Key? key,
    required String slug,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RealmDetailRouteArgs>();
      return _i56.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i69.Key? key;

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
/// [_i57.RealmEditScreen]
class RealmEditRoute extends _i68.PageRouteInfo<RealmEditRouteArgs> {
  RealmEditRoute({
    _i69.Key? key,
    String? slug,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         RealmEditRoute.name,
         args: RealmEditRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'RealmEditRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RealmEditRouteArgs>(
        orElse: () => const RealmEditRouteArgs(),
      );
      return _i57.RealmEditScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmEditRouteArgs {
  const RealmEditRouteArgs({this.key, this.slug});

  final _i69.Key? key;

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
/// [_i58.RealmListScreen]
class RealmListRoute extends _i68.PageRouteInfo<void> {
  const RealmListRoute({List<_i68.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i58.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i57.RealmNewScreen]
class RealmNewRoute extends _i68.PageRouteInfo<void> {
  const RealmNewRoute({List<_i68.PageRouteInfo>? children})
    : super(RealmNewRoute.name, initialChildren: children);

  static const String name = 'RealmNewRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i57.RealmNewScreen();
    },
  );
}

/// generated route for
/// [_i59.RelationshipScreen]
class RelationshipRoute extends _i68.PageRouteInfo<void> {
  const RelationshipRoute({List<_i68.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i59.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i60.SearchMessagesScreen]
class SearchMessagesRoute extends _i68.PageRouteInfo<SearchMessagesRouteArgs> {
  SearchMessagesRoute({
    _i69.Key? key,
    required String roomId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         SearchMessagesRoute.name,
         args: SearchMessagesRouteArgs(key: key, roomId: roomId),
         initialChildren: children,
       );

  static const String name = 'SearchMessagesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchMessagesRouteArgs>();
      return _i60.SearchMessagesScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class SearchMessagesRouteArgs {
  const SearchMessagesRouteArgs({this.key, required this.roomId});

  final _i69.Key? key;

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
/// [_i61.SettingsScreen]
class SettingsRoute extends _i68.PageRouteInfo<void> {
  const SettingsRoute({List<_i68.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i61.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i62.StickerMarketplacePackDetailScreen]
class StickerMarketplacePackDetailRoute
    extends _i68.PageRouteInfo<StickerMarketplacePackDetailRouteArgs> {
  StickerMarketplacePackDetailRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         StickerMarketplacePackDetailRoute.name,
         args: StickerMarketplacePackDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'StickerMarketplacePackDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StickerMarketplacePackDetailRouteArgs>();
      return _i62.StickerMarketplacePackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class StickerMarketplacePackDetailRouteArgs {
  const StickerMarketplacePackDetailRouteArgs({this.key, required this.id});

  final _i69.Key? key;

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
/// [_i63.StickerMarketplaceScreen]
class StickerMarketplaceRoute extends _i68.PageRouteInfo<void> {
  const StickerMarketplaceRoute({List<_i68.PageRouteInfo>? children})
    : super(StickerMarketplaceRoute.name, initialChildren: children);

  static const String name = 'StickerMarketplaceRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i63.StickerMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i64.TabsScreen]
class TabsRoute extends _i68.PageRouteInfo<void> {
  const TabsRoute({List<_i68.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i64.TabsScreen();
    },
  );
}

/// generated route for
/// [_i65.ThoughtScreen]
class ThoughtRoute extends _i68.PageRouteInfo<void> {
  const ThoughtRoute({List<_i68.PageRouteInfo>? children})
    : super(ThoughtRoute.name, initialChildren: children);

  static const String name = 'ThoughtRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i65.ThoughtScreen();
    },
  );
}

/// generated route for
/// [_i66.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i68.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i69.Key? key,
    _i66.SearchTab initialTab = _i66.SearchTab.posts,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         UniversalSearchRoute.name,
         args: UniversalSearchRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'UniversalSearchRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UniversalSearchRouteArgs>(
        orElse: () => const UniversalSearchRouteArgs(),
      );
      return _i66.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i66.SearchTab.posts,
  });

  final _i69.Key? key;

  final _i66.SearchTab initialTab;

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
/// [_i67.WalletScreen]
class WalletRoute extends _i68.PageRouteInfo<void> {
  const WalletRoute({List<_i68.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i67.WalletScreen();
    },
  );
}
