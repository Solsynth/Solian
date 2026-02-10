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
import 'package:island/accounts/accounts_screen.dart' as _i5;
import 'package:island/accounts/screens/leveling.dart' as _i39;
import 'package:island/accounts/screens/me/account_settings.dart' as _i6;
import 'package:island/accounts/screens/me/profile_update.dart' as _i65;
import 'package:island/accounts/screens/profile.dart' as _i4;
import 'package:island/accounts/screens/relationship.dart' as _i58;
import 'package:island/auth/captcha.web.dart' as _i16;
import 'package:island/auth/create_account.dart' as _i20;
import 'package:island/auth/login.dart' as _i40;
import 'package:island/auth/oidc.web.dart' as _i48;
import 'package:island/chat/widgets/call_screen.dart' as _i15;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i17;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i18;
import 'package:island/chat/widgets/chat_room_form.dart' as _i31;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i19;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i59;
import 'package:island/creators/screens/hub.dart' as _i21;
import 'package:island/creators/screens/poll/poll_list.dart' as _i22;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i23;
import 'package:island/creators/screens/publishers_form.dart' as _i33;
import 'package:island/creators/screens/sites/site_detail.dart' as _i54;
import 'package:island/creators/screens/sites/site_list.dart' as _i24;
import 'package:island/creators/screens/stickers/stickers.dart' as _i61;
import 'package:island/creators/screens/webfeed/webfeed_list.dart' as _i67;
import 'package:island/developers/screens/app_detail.dart' as _i7;
import 'package:island/developers/screens/app_secrets.dart' as _i8;
import 'package:island/developers/screens/apps.dart' as _i25;
import 'package:island/developers/screens/bot_detail.dart' as _i12;
import 'package:island/developers/screens/bot_keys.dart' as _i13;
import 'package:island/developers/screens/bots.dart' as _i14;
import 'package:island/developers/screens/edit_app.dart' as _i29;
import 'package:island/developers/screens/edit_bot.dart' as _i30;
import 'package:island/developers/screens/edit_project.dart' as _i32;
import 'package:island/developers/screens/hub.dart' as _i27;
import 'package:island/developers/screens/new_app.dart' as _i46;
import 'package:island/developers/screens/new_bot.dart' as _i45;
import 'package:island/developers/screens/new_project.dart' as _i47;
import 'package:island/discovery/explore.dart' as _i35;
import 'package:island/discovery/screens/article_detail.dart' as _i10;
import 'package:island/discovery/screens/articles.dart' as _i11;
import 'package:island/discovery/screens/feeds/feed_detail.dart' as _i43;
import 'package:island/discovery/screens/feeds/feed_marketplace.dart' as _i44;
import 'package:island/discovery/screens/realms.dart' as _i28;
import 'package:island/discovery/search.dart' as _i64;
import 'package:island/drive/files/file_detail.dart' as _i36;
import 'package:island/drive/files/file_list.dart' as _i37;
import 'package:island/fitness/fitness_screen.dart' as _i38;
import 'package:island/polls/screens/poll_editor.dart' as _i49;
import 'package:island/posts/compose.dart' as _i72;
import 'package:island/posts/publisher_profile.dart' as _i55;
import 'package:island/posts/screens/compose_article.dart' as _i9;
import 'package:island/posts/screens/post_categories_list.dart' as _i50;
import 'package:island/posts/screens/post_category_detail.dart' as _i51;
import 'package:island/posts/screens/post_detail.dart' as _i52;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i53;
import 'package:island/realms/screens/realm_detail.dart' as _i56;
import 'package:island/realms/screens/realm_form.dart' as _i34;
import 'package:island/realms/screens/realms.dart' as _i57;
import 'package:island/reports/screens/report_detail.dart' as _i2;
import 'package:island/reports/screens/report_list.dart' as _i3;
import 'package:island/settings/about.dart' as _i1;
import 'package:island/settings/dashboard/dash.dart' as _i26;
import 'package:island/settings/settings.dart' as _i60;
import 'package:island/settings/tabs_screen.dart' as _i62;
import 'package:island/stickers/screens/pack_detail.dart' as _i41;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i42;
import 'package:island/thoughts/screens/think.dart' as _i63;
import 'package:island/wallets/wallet.dart' as _i66;
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
class AccountRoute extends _i68.PageRouteInfo<AccountRouteArgs> {
  AccountRoute({
    _i69.Key? key,
    bool isAside = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AccountRoute.name,
         args: AccountRouteArgs(key: key, isAside: isAside),
         initialChildren: children,
       );

  static const String name = 'AccountRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AccountRouteArgs>(
        orElse: () => const AccountRouteArgs(),
      );
      return _i5.AccountScreen(key: args.key, isAside: args.isAside);
    },
  );
}

class AccountRouteArgs {
  const AccountRouteArgs({this.key, this.isAside = false});

  final _i69.Key? key;

  final bool isAside;

  @override
  String toString() {
    return 'AccountRouteArgs{key: $key, isAside: $isAside}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountRouteArgs) return false;
    return key == other.key && isAside == other.isAside;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode;
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
/// [_i5.AccountShellScreen]
class AccountShellRoute extends _i68.PageRouteInfo<AccountShellRouteArgs> {
  AccountShellRoute({
    _i69.Key? key,
    required _i69.Widget child,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AccountShellRoute.name,
         args: AccountShellRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'AccountShellRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AccountShellRouteArgs>();
      return _i5.AccountShellScreen(key: args.key, child: args.child);
    },
  );
}

class AccountShellRouteArgs {
  const AccountShellRouteArgs({this.key, required this.child});

  final _i69.Key? key;

  final _i69.Widget child;

  @override
  String toString() {
    return 'AccountShellRouteArgs{key: $key, child: $child}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountShellRouteArgs) return false;
    return key == other.key && child == other.child;
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode;
}

/// generated route for
/// [_i7.AppDetailScreen]
class AppDetailRoute extends _i68.PageRouteInfo<AppDetailRouteArgs> {
  AppDetailRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    required String appId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         AppDetailRoute.name,
         args: AppDetailRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           appId: appId,
         ),
         initialChildren: children,
       );

  static const String name = 'AppDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AppDetailRouteArgs>();
      return _i7.AppDetailScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        appId: args.appId,
      );
    },
  );
}

class AppDetailRouteArgs {
  const AppDetailRouteArgs({
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
    return 'AppDetailRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, appId: $appId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppDetailRouteArgs) return false;
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
/// [_i11.ArticlesScreen]
class ArticlesRoute extends _i68.PageRouteInfo<void> {
  const ArticlesRoute({List<_i68.PageRouteInfo>? children})
    : super(ArticlesRoute.name, initialChildren: children);

  static const String name = 'ArticlesRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i11.ArticlesScreen();
    },
  );
}

/// generated route for
/// [_i12.BotDetailScreen]
class BotDetailRoute extends _i68.PageRouteInfo<BotDetailRouteArgs> {
  BotDetailRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    required String botId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         BotDetailRoute.name,
         args: BotDetailRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           botId: botId,
         ),
         initialChildren: children,
       );

  static const String name = 'BotDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BotDetailRouteArgs>();
      return _i12.BotDetailScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        botId: args.botId,
      );
    },
  );
}

class BotDetailRouteArgs {
  const BotDetailRouteArgs({
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
    return 'BotDetailRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, botId: $botId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BotDetailRouteArgs) return false;
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
/// [_i13.BotKeysScreen]
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
/// [_i14.BotsScreen]
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
/// [_i15.CallScreen]
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
      return _i15.CallScreen(key: args.key, room: args.room);
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
/// [_i16.CaptchaScreen]
class CaptchaRoute extends _i68.PageRouteInfo<void> {
  const CaptchaRoute({List<_i68.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i16.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i17.ChatDetailScreen]
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
      return _i17.ChatDetailScreen(key: args.key, id: args.id);
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
/// [_i18.ChatListScreen]
class ChatListRoute extends _i68.PageRouteInfo<ChatListRouteArgs> {
  ChatListRoute({
    _i69.Key? key,
    bool isAside = false,
    bool isFloating = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ChatListRoute.name,
         args: ChatListRouteArgs(
           key: key,
           isAside: isAside,
           isFloating: isFloating,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatListRouteArgs>(
        orElse: () => const ChatListRouteArgs(),
      );
      return _i18.ChatListScreen(
        key: args.key,
        isAside: args.isAside,
        isFloating: args.isFloating,
      );
    },
  );
}

class ChatListRouteArgs {
  const ChatListRouteArgs({
    this.key,
    this.isAside = false,
    this.isFloating = false,
  });

  final _i69.Key? key;

  final bool isAside;

  final bool isFloating;

  @override
  String toString() {
    return 'ChatListRouteArgs{key: $key, isAside: $isAside, isFloating: $isFloating}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatListRouteArgs) return false;
    return key == other.key &&
        isAside == other.isAside &&
        isFloating == other.isFloating;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode ^ isFloating.hashCode;
}

/// generated route for
/// [_i19.ChatRoomScreen]
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
      return _i19.ChatRoomScreen(key: args.key, id: args.id);
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
/// [_i18.ChatShellScreen]
class ChatShellRoute extends _i68.PageRouteInfo<ChatShellRouteArgs> {
  ChatShellRoute({
    _i69.Key? key,
    required _i69.Widget child,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         ChatShellRoute.name,
         args: ChatShellRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'ChatShellRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatShellRouteArgs>();
      return _i18.ChatShellScreen(key: args.key, child: args.child);
    },
  );
}

class ChatShellRouteArgs {
  const ChatShellRouteArgs({this.key, required this.child});

  final _i69.Key? key;

  final _i69.Widget child;

  @override
  String toString() {
    return 'ChatShellRouteArgs{key: $key, child: $child}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatShellRouteArgs) return false;
    return key == other.key && child == other.child;
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode;
}

/// generated route for
/// [_i20.CreateAccountScreen]
class CreateAccountRoute extends _i68.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i68.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i20.CreateAccountScreen();
    },
  );
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
/// [_i24.CreatorSiteListScreen]
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
      return _i24.CreatorSiteListScreen(key: args.key, pubName: args.pubName);
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
/// [_i25.CustomAppsScreen]
class CustomAppsRoute extends _i68.PageRouteInfo<CustomAppsRouteArgs> {
  CustomAppsRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         CustomAppsRoute.name,
         args: CustomAppsRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
         ),
         initialChildren: children,
       );

  static const String name = 'CustomAppsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomAppsRouteArgs>();
      return _i25.CustomAppsScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
      );
    },
  );
}

class CustomAppsRouteArgs {
  const CustomAppsRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
  });

  final _i69.Key? key;

  final String publisherName;

  final String projectId;

  @override
  String toString() {
    return 'CustomAppsRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomAppsRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ publisherName.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [_i26.DashboardScreen]
class DashboardRoute extends _i68.PageRouteInfo<void> {
  const DashboardRoute({List<_i68.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i26.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i27.DeveloperHubScreen]
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
      return _i27.DeveloperHubScreen(
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
/// [_i28.DiscoveryRealmsScreen]
class DiscoveryRealmsRoute extends _i68.PageRouteInfo<void> {
  const DiscoveryRealmsRoute({List<_i68.PageRouteInfo>? children})
    : super(DiscoveryRealmsRoute.name, initialChildren: children);

  static const String name = 'DiscoveryRealmsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i28.DiscoveryRealmsScreen();
    },
  );
}

/// generated route for
/// [_i29.EditAppScreen]
class EditAppRoute extends _i68.PageRouteInfo<EditAppRouteArgs> {
  EditAppRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EditAppRoute.name,
         args: EditAppRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           id: id,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'EditAppRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditAppRouteArgs>();
      return _i29.EditAppScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        id: args.id,
        isModal: args.isModal,
      );
    },
  );
}

class EditAppRouteArgs {
  const EditAppRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  final _i69.Key? key;

  final String publisherName;

  final String projectId;

  final String? id;

  final bool isModal;

  @override
  String toString() {
    return 'EditAppRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, id: $id, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditAppRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        id == other.id &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      id.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i30.EditBotScreen]
class EditBotRoute extends _i68.PageRouteInfo<EditBotRouteArgs> {
  EditBotRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    String? id,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EditBotRoute.name,
         args: EditBotRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           id: id,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'EditBotRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditBotRouteArgs>();
      return _i30.EditBotScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        id: args.id,
        isModal: args.isModal,
      );
    },
  );
}

class EditBotRouteArgs {
  const EditBotRouteArgs({
    this.key,
    required this.publisherName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  final _i69.Key? key;

  final String publisherName;

  final String projectId;

  final String? id;

  final bool isModal;

  @override
  String toString() {
    return 'EditBotRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, id: $id, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditBotRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        projectId == other.projectId &&
        id == other.id &&
        isModal == other.isModal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      publisherName.hashCode ^
      projectId.hashCode ^
      id.hashCode ^
      isModal.hashCode;
}

/// generated route for
/// [_i31.EditChatScreen]
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
      return _i31.EditChatScreen(key: args.key, id: args.id);
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
/// [_i32.EditProjectScreen]
class EditProjectRoute extends _i68.PageRouteInfo<EditProjectRouteArgs> {
  EditProjectRoute({
    _i69.Key? key,
    required String publisherName,
    String? id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EditProjectRoute.name,
         args: EditProjectRouteArgs(
           key: key,
           publisherName: publisherName,
           id: id,
         ),
         initialChildren: children,
       );

  static const String name = 'EditProjectRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProjectRouteArgs>();
      return _i32.EditProjectScreen(
        key: args.key,
        publisherName: args.publisherName,
        id: args.id,
      );
    },
  );
}

class EditProjectRouteArgs {
  const EditProjectRouteArgs({this.key, required this.publisherName, this.id});

  final _i69.Key? key;

  final String publisherName;

  final String? id;

  @override
  String toString() {
    return 'EditProjectRouteArgs{key: $key, publisherName: $publisherName, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProjectRouteArgs) return false;
    return key == other.key &&
        publisherName == other.publisherName &&
        id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ publisherName.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i33.EditPublisherScreen]
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
      return _i33.EditPublisherScreen(key: args.key, name: args.name);
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
/// [_i34.EditRealmScreen]
class EditRealmRoute extends _i68.PageRouteInfo<EditRealmRouteArgs> {
  EditRealmRoute({
    _i69.Key? key,
    String? slug,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         EditRealmRoute.name,
         args: EditRealmRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'EditRealmRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditRealmRouteArgs>(
        orElse: () => const EditRealmRouteArgs(),
      );
      return _i34.EditRealmScreen(key: args.key, slug: args.slug);
    },
  );
}

class EditRealmRouteArgs {
  const EditRealmRouteArgs({this.key, this.slug});

  final _i69.Key? key;

  final String? slug;

  @override
  String toString() {
    return 'EditRealmRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditRealmRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i35.ExploreScreen]
class ExploreRoute extends _i68.PageRouteInfo<void> {
  const ExploreRoute({List<_i68.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i35.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i36.FileDetailScreen]
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
      return _i36.FileDetailScreen(key: args.key, item: args.item);
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
/// [_i37.FileListScreen]
class FileListRoute extends _i68.PageRouteInfo<void> {
  const FileListRoute({List<_i68.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i37.FileListScreen();
    },
  );
}

/// generated route for
/// [_i38.FitnessActivityScreen]
class FitnessActivityRoute extends _i68.PageRouteInfo<void> {
  const FitnessActivityRoute({List<_i68.PageRouteInfo>? children})
    : super(FitnessActivityRoute.name, initialChildren: children);

  static const String name = 'FitnessActivityRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i38.FitnessActivityScreen();
    },
  );
}

/// generated route for
/// [_i39.LevelingScreen]
class LevelingRoute extends _i68.PageRouteInfo<void> {
  const LevelingRoute({List<_i68.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i39.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i40.LoginScreen]
class LoginRoute extends _i68.PageRouteInfo<void> {
  const LoginRoute({List<_i68.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i40.LoginScreen();
    },
  );
}

/// generated route for
/// [_i41.MarketplaceStickerPackDetailScreen]
class MarketplaceStickerPackDetailRoute
    extends _i68.PageRouteInfo<MarketplaceStickerPackDetailRouteArgs> {
  MarketplaceStickerPackDetailRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         MarketplaceStickerPackDetailRoute.name,
         args: MarketplaceStickerPackDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'MarketplaceStickerPackDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MarketplaceStickerPackDetailRouteArgs>();
      return _i41.MarketplaceStickerPackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class MarketplaceStickerPackDetailRouteArgs {
  const MarketplaceStickerPackDetailRouteArgs({this.key, required this.id});

  final _i69.Key? key;

  final String id;

  @override
  String toString() {
    return 'MarketplaceStickerPackDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MarketplaceStickerPackDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i42.MarketplaceStickersScreen]
class MarketplaceStickersRoute extends _i68.PageRouteInfo<void> {
  const MarketplaceStickersRoute({List<_i68.PageRouteInfo>? children})
    : super(MarketplaceStickersRoute.name, initialChildren: children);

  static const String name = 'MarketplaceStickersRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i42.MarketplaceStickersScreen();
    },
  );
}

/// generated route for
/// [_i43.MarketplaceWebFeedDetailScreen]
class MarketplaceWebFeedDetailRoute
    extends _i68.PageRouteInfo<MarketplaceWebFeedDetailRouteArgs> {
  MarketplaceWebFeedDetailRoute({
    _i69.Key? key,
    required String id,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         MarketplaceWebFeedDetailRoute.name,
         args: MarketplaceWebFeedDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'MarketplaceWebFeedDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MarketplaceWebFeedDetailRouteArgs>();
      return _i43.MarketplaceWebFeedDetailScreen(key: args.key, id: args.id);
    },
  );
}

class MarketplaceWebFeedDetailRouteArgs {
  const MarketplaceWebFeedDetailRouteArgs({this.key, required this.id});

  final _i69.Key? key;

  final String id;

  @override
  String toString() {
    return 'MarketplaceWebFeedDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MarketplaceWebFeedDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i44.MarketplaceWebFeedsScreen]
class MarketplaceWebFeedsRoute extends _i68.PageRouteInfo<void> {
  const MarketplaceWebFeedsRoute({List<_i68.PageRouteInfo>? children})
    : super(MarketplaceWebFeedsRoute.name, initialChildren: children);

  static const String name = 'MarketplaceWebFeedsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i44.MarketplaceWebFeedsScreen();
    },
  );
}

/// generated route for
/// [_i45.NewBotScreen]
class NewBotRoute extends _i68.PageRouteInfo<NewBotRouteArgs> {
  NewBotRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         NewBotRoute.name,
         args: NewBotRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'NewBotRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewBotRouteArgs>();
      return _i45.NewBotScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        isModal: args.isModal,
      );
    },
  );
}

class NewBotRouteArgs {
  const NewBotRouteArgs({
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
    return 'NewBotRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewBotRouteArgs) return false;
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
/// [_i31.NewChatScreen]
class NewChatRoute extends _i68.PageRouteInfo<void> {
  const NewChatRoute({List<_i68.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i31.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i46.NewCustomAppScreen]
class NewCustomAppRoute extends _i68.PageRouteInfo<NewCustomAppRouteArgs> {
  NewCustomAppRoute({
    _i69.Key? key,
    required String publisherName,
    required String projectId,
    bool isModal = false,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         NewCustomAppRoute.name,
         args: NewCustomAppRouteArgs(
           key: key,
           publisherName: publisherName,
           projectId: projectId,
           isModal: isModal,
         ),
         initialChildren: children,
       );

  static const String name = 'NewCustomAppRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewCustomAppRouteArgs>();
      return _i46.NewCustomAppScreen(
        key: args.key,
        publisherName: args.publisherName,
        projectId: args.projectId,
        isModal: args.isModal,
      );
    },
  );
}

class NewCustomAppRouteArgs {
  const NewCustomAppRouteArgs({
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
    return 'NewCustomAppRouteArgs{key: $key, publisherName: $publisherName, projectId: $projectId, isModal: $isModal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewCustomAppRouteArgs) return false;
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
/// [_i47.NewProjectScreen]
class NewProjectRoute extends _i68.PageRouteInfo<NewProjectRouteArgs> {
  NewProjectRoute({
    _i69.Key? key,
    required String publisherName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         NewProjectRoute.name,
         args: NewProjectRouteArgs(key: key, publisherName: publisherName),
         initialChildren: children,
       );

  static const String name = 'NewProjectRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewProjectRouteArgs>();
      return _i47.NewProjectScreen(
        key: args.key,
        publisherName: args.publisherName,
      );
    },
  );
}

class NewProjectRouteArgs {
  const NewProjectRouteArgs({this.key, required this.publisherName});

  final _i69.Key? key;

  final String publisherName;

  @override
  String toString() {
    return 'NewProjectRouteArgs{key: $key, publisherName: $publisherName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewProjectRouteArgs) return false;
    return key == other.key && publisherName == other.publisherName;
  }

  @override
  int get hashCode => key.hashCode ^ publisherName.hashCode;
}

/// generated route for
/// [_i33.NewPublisherScreen]
class NewPublisherRoute extends _i68.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i68.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i33.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i34.NewRealmScreen]
class NewRealmRoute extends _i68.PageRouteInfo<void> {
  const NewRealmRoute({List<_i68.PageRouteInfo>? children})
    : super(NewRealmRoute.name, initialChildren: children);

  static const String name = 'NewRealmRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i34.NewRealmScreen();
    },
  );
}

/// generated route for
/// [_i48.OidcScreen]
class OidcRoute extends _i68.PageRouteInfo<OidcRouteArgs> {
  OidcRoute({
    _i69.Key? key,
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
      return _i48.OidcScreen(
        key: args.key,
        provider: args.provider,
        title: args.title,
      );
    },
  );
}

class OidcRouteArgs {
  const OidcRouteArgs({this.key, required this.provider, this.title});

  final _i69.Key? key;

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
/// [_i49.PollEditorScreen]
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
      return _i49.PollEditorScreen(
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
/// [_i50.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i68.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i68.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i50.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i51.PostCategoryDetailScreen]
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
      return _i51.PostCategoryDetailScreen(
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
/// [_i52.PostDetailScreen]
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
      return _i52.PostDetailScreen(key: args.key, id: args.id);
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
/// [_i53.PostShuffleScreen]
class PostShuffleRoute extends _i68.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i68.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i53.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i54.PublicationSiteDetailScreen]
class PublicationSiteDetailRoute
    extends _i68.PageRouteInfo<PublicationSiteDetailRouteArgs> {
  PublicationSiteDetailRoute({
    _i69.Key? key,
    required String siteSlug,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         PublicationSiteDetailRoute.name,
         args: PublicationSiteDetailRouteArgs(
           key: key,
           siteSlug: siteSlug,
           pubName: pubName,
         ),
         initialChildren: children,
       );

  static const String name = 'PublicationSiteDetailRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PublicationSiteDetailRouteArgs>();
      return _i54.PublicationSiteDetailScreen(
        key: args.key,
        siteSlug: args.siteSlug,
        pubName: args.pubName,
      );
    },
  );
}

class PublicationSiteDetailRouteArgs {
  const PublicationSiteDetailRouteArgs({
    this.key,
    required this.siteSlug,
    required this.pubName,
  });

  final _i69.Key? key;

  final String siteSlug;

  final String pubName;

  @override
  String toString() {
    return 'PublicationSiteDetailRouteArgs{key: $key, siteSlug: $siteSlug, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicationSiteDetailRouteArgs) return false;
    return key == other.key &&
        siteSlug == other.siteSlug &&
        pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ siteSlug.hashCode ^ pubName.hashCode;
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
/// [_i57.RealmListScreen]
class RealmListRoute extends _i68.PageRouteInfo<void> {
  const RealmListRoute({List<_i68.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i57.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i58.RelationshipScreen]
class RelationshipRoute extends _i68.PageRouteInfo<void> {
  const RelationshipRoute({List<_i68.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i58.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i59.SearchMessagesScreen]
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
      return _i59.SearchMessagesScreen(key: args.key, roomId: args.roomId);
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
/// [_i60.SettingsScreen]
class SettingsRoute extends _i68.PageRouteInfo<void> {
  const SettingsRoute({List<_i68.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i60.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i61.StickersScreen]
class StickersRoute extends _i68.PageRouteInfo<StickersRouteArgs> {
  StickersRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         StickersRoute.name,
         args: StickersRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'StickersRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StickersRouteArgs>();
      return _i61.StickersScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class StickersRouteArgs {
  const StickersRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'StickersRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StickersRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i62.TabsScreen]
class TabsRoute extends _i68.PageRouteInfo<TabsRouteArgs> {
  TabsRoute({
    _i69.Key? key,
    _i69.Widget? child,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         TabsRoute.name,
         args: TabsRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'TabsRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TabsRouteArgs>(
        orElse: () => const TabsRouteArgs(),
      );
      return _i62.TabsScreen(key: args.key, child: args.child);
    },
  );
}

class TabsRouteArgs {
  const TabsRouteArgs({this.key, this.child});

  final _i69.Key? key;

  final _i69.Widget? child;

  @override
  String toString() {
    return 'TabsRouteArgs{key: $key, child: $child}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TabsRouteArgs) return false;
    return key == other.key && child == other.child;
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode;
}

/// generated route for
/// [_i63.ThoughtScreen]
class ThoughtRoute extends _i68.PageRouteInfo<void> {
  const ThoughtRoute({List<_i68.PageRouteInfo>? children})
    : super(ThoughtRoute.name, initialChildren: children);

  static const String name = 'ThoughtRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i63.ThoughtScreen();
    },
  );
}

/// generated route for
/// [_i64.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i68.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i69.Key? key,
    _i64.SearchTab initialTab = _i64.SearchTab.posts,
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
      return _i64.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i64.SearchTab.posts,
  });

  final _i69.Key? key;

  final _i64.SearchTab initialTab;

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
/// [_i65.UpdateProfileScreen]
class UpdateProfileRoute extends _i68.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i68.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i65.UpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i66.WalletScreen]
class WalletRoute extends _i68.PageRouteInfo<void> {
  const WalletRoute({List<_i68.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      return const _i66.WalletScreen();
    },
  );
}

/// generated route for
/// [_i67.WebFeedListScreen]
class WebFeedListRoute extends _i68.PageRouteInfo<WebFeedListRouteArgs> {
  WebFeedListRoute({
    _i69.Key? key,
    required String pubName,
    List<_i68.PageRouteInfo>? children,
  }) : super(
         WebFeedListRoute.name,
         args: WebFeedListRouteArgs(key: key, pubName: pubName),
         initialChildren: children,
       );

  static const String name = 'WebFeedListRoute';

  static _i68.PageInfo page = _i68.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebFeedListRouteArgs>();
      return _i67.WebFeedListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class WebFeedListRouteArgs {
  const WebFeedListRouteArgs({this.key, required this.pubName});

  final _i69.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'WebFeedListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebFeedListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}
