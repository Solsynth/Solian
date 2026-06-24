// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i70;
import 'package:flutter/foundation.dart' as _i71;
import 'package:flutter/material.dart' as _i72;
import 'package:island/accounts/account_screen.dart' as _i2;
import 'package:island/accounts/screens/action_logs.dart' as _i7;
import 'package:island/accounts/screens/affiliation_detail.dart' as _i8;
import 'package:island/accounts/screens/affiliations.dart' as _i9;
import 'package:island/accounts/screens/badges.dart' as _i12;
import 'package:island/accounts/screens/calendar_event_detail_screen.dart'
    as _i15;
import 'package:island/accounts/screens/event_hub_screen.dart' as _i35;
import 'package:island/accounts/screens/leveling.dart' as _i40;
import 'package:island/accounts/screens/me/account_qr.dart' as _i4;
import 'package:island/accounts/screens/me/account_settings.dart' as _i5;
import 'package:island/accounts/screens/me/profile_update.dart' as _i6;
import 'package:island/accounts/screens/meet.dart' as _i42;
import 'package:island/accounts/screens/physical_passport.dart' as _i44;
import 'package:island/accounts/screens/profile.dart' as _i3;
import 'package:island/accounts/screens/progress.dart' as _i53;
import 'package:island/accounts/screens/punishments.dart' as _i55;
import 'package:island/accounts/screens/relationship.dart' as _i58;
import 'package:island/auth/authorize_screen.dart' as _i11;
import 'package:island/auth/captcha.dart' as _i17;
import 'package:island/auth/create_account.dart' as _i23;
import 'package:island/auth/login.dart' as _i41;
import 'package:island/chat/widgets/call_screen.dart' as _i16;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i19;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i20;
import 'package:island/chat/widgets/chat_room_form.dart' as _i33;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i21;
import 'package:island/chat/widgets/chat_room_storage_screen.dart' as _i22;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i59;
import 'package:island/creators/screens/domains/domain_manage.dart' as _i24;
import 'package:island/creators/screens/hub.dart' as _i25;
import 'package:island/creators/screens/livestream/livestream_list.dart'
    as _i26;
import 'package:island/creators/screens/poll/poll_list.dart' as _i27;
import 'package:island/creators/screens/posts/post_collections_manage.dart'
    as _i28;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i29;
import 'package:island/creators/screens/publishers_form.dart' as _i34;
import 'package:island/creators/screens/stickers/pack_detail_screen.dart'
    as _i31;
import 'package:island/creators/screens/stickers/stickers.dart' as _i30;
import 'package:island/discovery/explore.dart' as _i36;
import 'package:island/discovery/search.dart' as _i68;
import 'package:island/drive/files/file_detail.dart' as _i38;
import 'package:island/drive/files/file_list.dart' as _i39;
import 'package:island/fediverse/actor_profile.dart' as _i37;
import 'package:island/misc/about.dart' as _i1;
import 'package:island/misc/cf_ip_speed_test_screen.dart' as _i18;
import 'package:island/misc/dashboard/dash.dart' as _i32;
import 'package:island/misc/not_found.dart' as _i43;
import 'package:island/misc/settings.dart' as _i60;
import 'package:island/misc/tabs_screen.dart' as _i63;
import 'package:island/plugins/screens/plugin_editor_screen.dart' as _i45;
import 'package:island/plugins/screens/plugin_manager_screen.dart' as _i46;
import 'package:island/polls/polls_widgets/poll/poll_submit_page.dart' as _i48;
import 'package:island/polls/screens/poll_editor.dart' as _i47;
import 'package:island/posts/compose.dart' as _i74;
import 'package:island/posts/screens/bookmarks.dart' as _i14;
import 'package:island/posts/screens/compose_article.dart' as _i10;
import 'package:island/posts/screens/compose_blog.dart' as _i13;
import 'package:island/posts/screens/post_categories_list.dart' as _i49;
import 'package:island/posts/screens/post_category_detail.dart' as _i50;
import 'package:island/posts/screens/post_detail.dart' as _i51;
import 'package:island/posts/screens/publisher_profile.dart' as _i54;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i52;
import 'package:island/realms/screens/realm_detail.dart' as _i56;
import 'package:island/realms/screens/realms.dart' as _i57;
import 'package:island/stickers/screens/pack_detail.dart' as _i61;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i62;
import 'package:island/thoughts/screens/think.dart' as _i64;
import 'package:island/tickets/screens/ticket_detail.dart' as _i65;
import 'package:island/tickets/screens/ticket_list.dart' as _i66;
import 'package:island/wallets/transaction_detail.dart' as _i67;
import 'package:island/wallets/wallet.dart' as _i69;
import 'package:solar_network_sdk/solar_network_sdk.dart' as _i73;

/// generated route for
/// [_i1.AboutScreen]
class AboutRoute extends _i70.PageRouteInfo<void> {
  const AboutRoute({List<_i70.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountListScreen]
class AccountListRoute extends _i70.PageRouteInfo<void> {
  const AccountListRoute({List<_i70.PageRouteInfo>? children})
    : super(AccountListRoute.name, initialChildren: children);

  static const String name = 'AccountListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountListScreen();
    },
  );
}

/// generated route for
/// [_i3.AccountProfileScreen]
class AccountProfileRoute extends _i70.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i71.Key? key,
    required String name,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i70.PageInfo page = _i70.PageInfo(
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

  final _i71.Key? key;

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
/// [_i4.AccountQrScreen]
class AccountQrRoute extends _i70.PageRouteInfo<void> {
  const AccountQrRoute({List<_i70.PageRouteInfo>? children})
    : super(AccountQrRoute.name, initialChildren: children);

  static const String name = 'AccountQrRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i4.AccountQrScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i70.PageRouteInfo<void> {
  const AccountRoute({List<_i70.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountScreen();
    },
  );
}

/// generated route for
/// [_i5.AccountSettingsScreen]
class AccountSettingsRoute extends _i70.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i70.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i5.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i6.AccountUpdateProfileScreen]
class AccountUpdateProfileRoute extends _i70.PageRouteInfo<void> {
  const AccountUpdateProfileRoute({List<_i70.PageRouteInfo>? children})
    : super(AccountUpdateProfileRoute.name, initialChildren: children);

  static const String name = 'AccountUpdateProfileRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i6.AccountUpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i7.ActionLogsScreen]
class ActionLogsRoute extends _i70.PageRouteInfo<void> {
  const ActionLogsRoute({List<_i70.PageRouteInfo>? children})
    : super(ActionLogsRoute.name, initialChildren: children);

  static const String name = 'ActionLogsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i7.ActionLogsScreen();
    },
  );
}

/// generated route for
/// [_i8.AffiliationDetailScreen]
class AffiliationDetailRoute
    extends _i70.PageRouteInfo<AffiliationDetailRouteArgs> {
  AffiliationDetailRoute({
    _i72.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         AffiliationDetailRoute.name,
         args: AffiliationDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'AffiliationDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AffiliationDetailRouteArgs>(
        orElse: () =>
            AffiliationDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i8.AffiliationDetailScreen(key: args.key, id: args.id);
    },
  );
}

class AffiliationDetailRouteArgs {
  const AffiliationDetailRouteArgs({this.key, required this.id});

  final _i72.Key? key;

  final String id;

  @override
  String toString() {
    return 'AffiliationDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AffiliationDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i9.AffiliationScreen]
class AffiliationRoute extends _i70.PageRouteInfo<void> {
  const AffiliationRoute({List<_i70.PageRouteInfo>? children})
    : super(AffiliationRoute.name, initialChildren: children);

  static const String name = 'AffiliationRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i9.AffiliationScreen();
    },
  );
}

/// generated route for
/// [_i10.ArticleComposeScreen]
class ArticleComposeRoute extends _i70.PageRouteInfo<ArticleComposeRouteArgs> {
  ArticleComposeRoute({
    _i72.Key? key,
    _i73.SnPost? originalPost,
    _i74.PostComposeInitialState? initialState,
    List<_i70.PageRouteInfo>? children,
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

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleComposeRouteArgs>(
        orElse: () => const ArticleComposeRouteArgs(),
      );
      return _i10.ArticleComposeScreen(
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

  final _i72.Key? key;

  final _i73.SnPost? originalPost;

  final _i74.PostComposeInitialState? initialState;

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
/// [_i10.ArticleEditScreen]
class ArticleEditRoute extends _i70.PageRouteInfo<ArticleEditRouteArgs> {
  ArticleEditRoute({
    _i72.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         ArticleEditRoute.name,
         args: ArticleEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ArticleEditRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArticleEditRouteArgs>(
        orElse: () => ArticleEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i10.ArticleEditScreen(key: args.key, id: args.id);
    },
  );
}

class ArticleEditRouteArgs {
  const ArticleEditRouteArgs({this.key, required this.id});

  final _i72.Key? key;

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
/// [_i11.AuthorizeScreen]
class AuthorizeRoute extends _i70.PageRouteInfo<AuthorizeRouteArgs> {
  AuthorizeRoute({
    _i72.Key? key,
    String? clientId,
    String? redirectUri,
    String? scope,
    String? state,
    String? responseType,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         AuthorizeRoute.name,
         args: AuthorizeRouteArgs(
           key: key,
           clientId: clientId,
           redirectUri: redirectUri,
           scope: scope,
           state: state,
           responseType: responseType,
         ),
         initialChildren: children,
       );

  static const String name = 'AuthorizeRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthorizeRouteArgs>(
        orElse: () => const AuthorizeRouteArgs(),
      );
      return _i11.AuthorizeScreen(
        key: args.key,
        clientId: args.clientId,
        redirectUri: args.redirectUri,
        scope: args.scope,
        state: args.state,
        responseType: args.responseType,
      );
    },
  );
}

class AuthorizeRouteArgs {
  const AuthorizeRouteArgs({
    this.key,
    this.clientId,
    this.redirectUri,
    this.scope,
    this.state,
    this.responseType,
  });

  final _i72.Key? key;

  final String? clientId;

  final String? redirectUri;

  final String? scope;

  final String? state;

  final String? responseType;

  @override
  String toString() {
    return 'AuthorizeRouteArgs{key: $key, clientId: $clientId, redirectUri: $redirectUri, scope: $scope, state: $state, responseType: $responseType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthorizeRouteArgs) return false;
    return key == other.key &&
        clientId == other.clientId &&
        redirectUri == other.redirectUri &&
        scope == other.scope &&
        state == other.state &&
        responseType == other.responseType;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      clientId.hashCode ^
      redirectUri.hashCode ^
      scope.hashCode ^
      state.hashCode ^
      responseType.hashCode;
}

/// generated route for
/// [_i12.BadgesScreen]
class BadgesRoute extends _i70.PageRouteInfo<void> {
  const BadgesRoute({List<_i70.PageRouteInfo>? children})
    : super(BadgesRoute.name, initialChildren: children);

  static const String name = 'BadgesRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i12.BadgesScreen();
    },
  );
}

/// generated route for
/// [_i13.BlogComposeScreen]
class BlogComposeRoute extends _i70.PageRouteInfo<BlogComposeRouteArgs> {
  BlogComposeRoute({
    _i72.Key? key,
    _i73.SnPost? originalPost,
    _i74.PostComposeInitialState? initialState,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         BlogComposeRoute.name,
         args: BlogComposeRouteArgs(
           key: key,
           originalPost: originalPost,
           initialState: initialState,
         ),
         initialChildren: children,
       );

  static const String name = 'BlogComposeRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BlogComposeRouteArgs>(
        orElse: () => const BlogComposeRouteArgs(),
      );
      return _i13.BlogComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
        initialState: args.initialState,
      );
    },
  );
}

class BlogComposeRouteArgs {
  const BlogComposeRouteArgs({this.key, this.originalPost, this.initialState});

  final _i72.Key? key;

  final _i73.SnPost? originalPost;

  final _i74.PostComposeInitialState? initialState;

  @override
  String toString() {
    return 'BlogComposeRouteArgs{key: $key, originalPost: $originalPost, initialState: $initialState}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BlogComposeRouteArgs) return false;
    return key == other.key &&
        originalPost == other.originalPost &&
        initialState == other.initialState;
  }

  @override
  int get hashCode =>
      key.hashCode ^ originalPost.hashCode ^ initialState.hashCode;
}

/// generated route for
/// [_i13.BlogEditScreen]
class BlogEditRoute extends _i70.PageRouteInfo<BlogEditRouteArgs> {
  BlogEditRoute({
    _i72.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         BlogEditRoute.name,
         args: BlogEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'BlogEditRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BlogEditRouteArgs>(
        orElse: () => BlogEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i13.BlogEditScreen(key: args.key, id: args.id);
    },
  );
}

class BlogEditRouteArgs {
  const BlogEditRouteArgs({this.key, required this.id});

  final _i72.Key? key;

  final String id;

  @override
  String toString() {
    return 'BlogEditRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BlogEditRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i14.BookmarksScreen]
class BookmarksRoute extends _i70.PageRouteInfo<void> {
  const BookmarksRoute({List<_i70.PageRouteInfo>? children})
    : super(BookmarksRoute.name, initialChildren: children);

  static const String name = 'BookmarksRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i14.BookmarksScreen();
    },
  );
}

/// generated route for
/// [_i15.CalendarEventDetailScreen]
class CalendarEventDetailRoute
    extends _i70.PageRouteInfo<CalendarEventDetailRouteArgs> {
  CalendarEventDetailRoute({
    _i72.Key? key,
    required String username,
    required String eventId,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CalendarEventDetailRoute.name,
         args: CalendarEventDetailRouteArgs(
           key: key,
           username: username,
           eventId: eventId,
         ),
         rawPathParams: {'name': username, 'id': eventId},
         initialChildren: children,
       );

  static const String name = 'CalendarEventDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CalendarEventDetailRouteArgs>(
        orElse: () => CalendarEventDetailRouteArgs(
          username: pathParams.getString('name'),
          eventId: pathParams.getString('id'),
        ),
      );
      return _i15.CalendarEventDetailScreen(
        key: args.key,
        username: args.username,
        eventId: args.eventId,
      );
    },
  );
}

class CalendarEventDetailRouteArgs {
  const CalendarEventDetailRouteArgs({
    this.key,
    required this.username,
    required this.eventId,
  });

  final _i72.Key? key;

  final String username;

  final String eventId;

  @override
  String toString() {
    return 'CalendarEventDetailRouteArgs{key: $key, username: $username, eventId: $eventId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CalendarEventDetailRouteArgs) return false;
    return key == other.key &&
        username == other.username &&
        eventId == other.eventId;
  }

  @override
  int get hashCode => key.hashCode ^ username.hashCode ^ eventId.hashCode;
}

/// generated route for
/// [_i16.CallScreen]
class CallRoute extends _i70.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i72.Key? key,
    required _i73.SnChatRoom room,
    bool cameraEnabled = false,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(
           key: key,
           room: room,
           cameraEnabled: cameraEnabled,
         ),
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CallRouteArgs>();
      return _i16.CallScreen(
        key: args.key,
        room: args.room,
        cameraEnabled: args.cameraEnabled,
      );
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({
    this.key,
    required this.room,
    this.cameraEnabled = false,
  });

  final _i72.Key? key;

  final _i73.SnChatRoom room;

  final bool cameraEnabled;

  @override
  String toString() {
    return 'CallRouteArgs{key: $key, room: $room, cameraEnabled: $cameraEnabled}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallRouteArgs) return false;
    return key == other.key &&
        room == other.room &&
        cameraEnabled == other.cameraEnabled;
  }

  @override
  int get hashCode => key.hashCode ^ room.hashCode ^ cameraEnabled.hashCode;
}

/// generated route for
/// [_i17.CaptchaScreen]
class CaptchaRoute extends _i70.PageRouteInfo<void> {
  const CaptchaRoute({List<_i70.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i17.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i18.CfIpSpeedTestScreen]
class CfIpSpeedTestRoute extends _i70.PageRouteInfo<void> {
  const CfIpSpeedTestRoute({List<_i70.PageRouteInfo>? children})
    : super(CfIpSpeedTestRoute.name, initialChildren: children);

  static const String name = 'CfIpSpeedTestRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i18.CfIpSpeedTestScreen();
    },
  );
}

/// generated route for
/// [_i19.ChatDetailScreen]
class ChatDetailRoute extends _i70.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i72.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => ChatDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i19.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i72.Key? key;

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
/// [_i20.ChatListScreen]
class ChatListRoute extends _i70.PageRouteInfo<void> {
  const ChatListRoute({List<_i70.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i20.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i21.ChatRoomScreen]
class ChatRoomRoute extends _i70.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i71.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRoomRouteArgs>(
        orElse: () => ChatRoomRouteArgs(id: pathParams.getString('id')),
      );
      return _i21.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i71.Key? key;

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
/// [_i22.ChatRoomStorageScreen]
class ChatRoomStorageRoute extends _i70.PageRouteInfo<void> {
  const ChatRoomStorageRoute({List<_i70.PageRouteInfo>? children})
    : super(ChatRoomStorageRoute.name, initialChildren: children);

  static const String name = 'ChatRoomStorageRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i22.ChatRoomStorageScreen();
    },
  );
}

/// generated route for
/// [_i20.ChatScreen]
class ChatRoute extends _i70.PageRouteInfo<void> {
  const ChatRoute({List<_i70.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i20.ChatScreen();
    },
  );
}

/// generated route for
/// [_i23.CreateAccountScreen]
class CreateAccountRoute extends _i70.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i70.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i23.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i24.CreatorDomainManageScreen]
class CreatorDomainManageRoute
    extends _i70.PageRouteInfo<CreatorDomainManageRouteArgs> {
  CreatorDomainManageRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorDomainManageRoute.name,
         args: CreatorDomainManageRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorDomainManageRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorDomainManageRouteArgs>(
        orElse: () => CreatorDomainManageRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i24.CreatorDomainManageScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorDomainManageRouteArgs {
  const CreatorDomainManageRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorDomainManageRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorDomainManageRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i25.CreatorHubListScreen]
class CreatorHubListRoute extends _i70.PageRouteInfo<void> {
  const CreatorHubListRoute({List<_i70.PageRouteInfo>? children})
    : super(CreatorHubListRoute.name, initialChildren: children);

  static const String name = 'CreatorHubListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i25.CreatorHubListScreen();
    },
  );
}

/// generated route for
/// [_i25.CreatorHubScreen]
class CreatorHubRoute extends _i70.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i70.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i25.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i26.CreatorLivestreamListScreen]
class CreatorLivestreamListRoute
    extends _i70.PageRouteInfo<CreatorLivestreamListRouteArgs> {
  CreatorLivestreamListRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorLivestreamListRoute.name,
         args: CreatorLivestreamListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorLivestreamListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorLivestreamListRouteArgs>(
        orElse: () => CreatorLivestreamListRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i26.CreatorLivestreamListScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorLivestreamListRouteArgs {
  const CreatorLivestreamListRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

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
/// [_i27.CreatorPollListScreen]
class CreatorPollListRoute
    extends _i70.PageRouteInfo<CreatorPollListRouteArgs> {
  CreatorPollListRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorPollListRoute.name,
         args: CreatorPollListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPollListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorPollListRouteArgs>(
        orElse: () =>
            CreatorPollListRouteArgs(pubName: pathParams.getString('pubName')),
      );
      return _i27.CreatorPollListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPollListRouteArgs {
  const CreatorPollListRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

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
/// [_i28.CreatorPostCollectionsScreen]
class CreatorPostCollectionsRoute
    extends _i70.PageRouteInfo<CreatorPostCollectionsRouteArgs> {
  CreatorPostCollectionsRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorPostCollectionsRoute.name,
         args: CreatorPostCollectionsRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostCollectionsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorPostCollectionsRouteArgs>(
        orElse: () => CreatorPostCollectionsRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i28.CreatorPostCollectionsScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorPostCollectionsRouteArgs {
  const CreatorPostCollectionsRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorPostCollectionsRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorPostCollectionsRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i29.CreatorPostListScreen]
class CreatorPostListRoute
    extends _i70.PageRouteInfo<CreatorPostListRouteArgs> {
  CreatorPostListRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorPostListRoute.name,
         args: CreatorPostListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorPostListRouteArgs>(
        orElse: () =>
            CreatorPostListRouteArgs(pubName: pathParams.getString('pubName')),
      );
      return _i29.CreatorPostListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorPostListRouteArgs {
  const CreatorPostListRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

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
/// [_i30.CreatorStickerListScreen]
class CreatorStickerListRoute
    extends _i70.PageRouteInfo<CreatorStickerListRouteArgs> {
  CreatorStickerListRoute({
    _i72.Key? key,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorStickerListRoute.name,
         args: CreatorStickerListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorStickerListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorStickerListRouteArgs>(
        orElse: () => CreatorStickerListRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i30.CreatorStickerListScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorStickerListRouteArgs {
  const CreatorStickerListRouteArgs({this.key, required this.pubName});

  final _i72.Key? key;

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
/// [_i31.CreatorStickerPackDetailScreen]
class CreatorStickerPackDetailRoute
    extends _i70.PageRouteInfo<CreatorStickerPackDetailRouteArgs> {
  CreatorStickerPackDetailRoute({
    _i72.Key? key,
    required String packId,
    required String pubName,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         CreatorStickerPackDetailRoute.name,
         args: CreatorStickerPackDetailRouteArgs(
           key: key,
           packId: packId,
           pubName: pubName,
         ),
         rawPathParams: {'packId': packId, 'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorStickerPackDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorStickerPackDetailRouteArgs>(
        orElse: () => CreatorStickerPackDetailRouteArgs(
          packId: pathParams.getString('packId'),
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i31.CreatorStickerPackDetailScreen(
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

  final _i72.Key? key;

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
/// [_i32.DashboardScreen]
class DashboardRoute extends _i70.PageRouteInfo<void> {
  const DashboardRoute({List<_i70.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i32.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i33.EditChatScreen]
class EditChatRoute extends _i70.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i72.Key? key, String? id, List<_i70.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => const EditChatRouteArgs(),
      );
      return _i33.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i72.Key? key;

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
/// [_i34.EditPublisherScreen]
class EditPublisherRoute extends _i70.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i72.Key? key,
    String? name,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => const EditPublisherRouteArgs(),
      );
      return _i34.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i72.Key? key;

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
/// [_i35.EventHubScreen]
class EventHubRoute extends _i70.PageRouteInfo<EventHubRouteArgs> {
  EventHubRoute({
    _i72.Key? key,
    required String name,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         EventHubRoute.name,
         args: EventHubRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'EventHubRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EventHubRouteArgs>(
        orElse: () => EventHubRouteArgs(name: pathParams.getString('name')),
      );
      return _i35.EventHubScreen(key: args.key, name: args.name);
    },
  );
}

class EventHubRouteArgs {
  const EventHubRouteArgs({this.key, required this.name});

  final _i72.Key? key;

  final String name;

  @override
  String toString() {
    return 'EventHubRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventHubRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i36.ExploreScreen]
class ExploreRoute extends _i70.PageRouteInfo<void> {
  const ExploreRoute({List<_i70.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i36.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i37.FediverseActorProfileScreen]
class FediverseActorProfileRoute
    extends _i70.PageRouteInfo<FediverseActorProfileRouteArgs> {
  FediverseActorProfileRoute({
    _i72.Key? key,
    required String id,
    String? fullHandle,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         FediverseActorProfileRoute.name,
         args: FediverseActorProfileRouteArgs(
           key: key,
           id: id,
           fullHandle: fullHandle,
         ),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'FediverseActorProfileRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FediverseActorProfileRouteArgs>(
        orElse: () =>
            FediverseActorProfileRouteArgs(id: pathParams.getString('id')),
      );
      return _i37.FediverseActorProfileScreen(
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

  final _i72.Key? key;

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
/// [_i38.FileDetailScreen]
class FileDetailRoute extends _i70.PageRouteInfo<FileDetailRouteArgs> {
  FileDetailRoute({
    _i71.Key? key,
    required String id,
    String? heroTag,
    _i73.SnPost? sourcePost,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         FileDetailRoute.name,
         args: FileDetailRouteArgs(
           key: key,
           id: id,
           heroTag: heroTag,
           sourcePost: sourcePost,
         ),
         initialChildren: children,
       );

  static const String name = 'FileDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FileDetailRouteArgs>();
      return _i38.FileDetailScreen(
        key: args.key,
        id: args.id,
        heroTag: args.heroTag,
        sourcePost: args.sourcePost,
      );
    },
  );
}

class FileDetailRouteArgs {
  const FileDetailRouteArgs({
    this.key,
    required this.id,
    this.heroTag,
    this.sourcePost,
  });

  final _i71.Key? key;

  final String id;

  final String? heroTag;

  final _i73.SnPost? sourcePost;

  @override
  String toString() {
    return 'FileDetailRouteArgs{key: $key, id: $id, heroTag: $heroTag, sourcePost: $sourcePost}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FileDetailRouteArgs) return false;
    return key == other.key &&
        id == other.id &&
        heroTag == other.heroTag &&
        sourcePost == other.sourcePost;
  }

  @override
  int get hashCode =>
      key.hashCode ^ id.hashCode ^ heroTag.hashCode ^ sourcePost.hashCode;
}

/// generated route for
/// [_i39.FileListScreen]
class FileListRoute extends _i70.PageRouteInfo<void> {
  const FileListRoute({List<_i70.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i39.FileListScreen();
    },
  );
}

/// generated route for
/// [_i40.LevelingScreen]
class LevelingRoute extends _i70.PageRouteInfo<void> {
  const LevelingRoute({List<_i70.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i40.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i41.LoginScreen]
class LoginRoute extends _i70.PageRouteInfo<void> {
  const LoginRoute({List<_i70.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i41.LoginScreen();
    },
  );
}

/// generated route for
/// [_i42.MeetDetailScreen]
class MeetDetailRoute extends _i70.PageRouteInfo<MeetDetailRouteArgs> {
  MeetDetailRoute({
    _i71.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         MeetDetailRoute.name,
         args: MeetDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MeetDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MeetDetailRouteArgs>(
        orElse: () => MeetDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i42.MeetDetailScreen(key: args.key, id: args.id);
    },
  );
}

class MeetDetailRouteArgs {
  const MeetDetailRouteArgs({this.key, required this.id});

  final _i71.Key? key;

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
/// [_i42.MeetScreen]
class MeetRoute extends _i70.PageRouteInfo<void> {
  const MeetRoute({List<_i70.PageRouteInfo>? children})
    : super(MeetRoute.name, initialChildren: children);

  static const String name = 'MeetRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i42.MeetScreen();
    },
  );
}

/// generated route for
/// [_i33.NewChatScreen]
class NewChatRoute extends _i70.PageRouteInfo<void> {
  const NewChatRoute({List<_i70.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i33.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i34.NewPublisherScreen]
class NewPublisherRoute extends _i70.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i70.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i34.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i43.NotFoundScreen]
class NotFoundRoute extends _i70.PageRouteInfo<void> {
  const NotFoundRoute({List<_i70.PageRouteInfo>? children})
    : super(NotFoundRoute.name, initialChildren: children);

  static const String name = 'NotFoundRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i43.NotFoundScreen();
    },
  );
}

/// generated route for
/// [_i44.PhysicalPassportScreen]
class PhysicalPassportRoute extends _i70.PageRouteInfo<void> {
  const PhysicalPassportRoute({List<_i70.PageRouteInfo>? children})
    : super(PhysicalPassportRoute.name, initialChildren: children);

  static const String name = 'PhysicalPassportRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i44.PhysicalPassportScreen();
    },
  );
}

/// generated route for
/// [_i45.PluginEditorScreen]
class PluginEditorRoute extends _i70.PageRouteInfo<void> {
  const PluginEditorRoute({List<_i70.PageRouteInfo>? children})
    : super(PluginEditorRoute.name, initialChildren: children);

  static const String name = 'PluginEditorRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i45.PluginEditorScreen();
    },
  );
}

/// generated route for
/// [_i46.PluginManagerScreen]
class PluginManagerRoute extends _i70.PageRouteInfo<void> {
  const PluginManagerRoute({List<_i70.PageRouteInfo>? children})
    : super(PluginManagerRoute.name, initialChildren: children);

  static const String name = 'PluginManagerRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i46.PluginManagerScreen();
    },
  );
}

/// generated route for
/// [_i47.PollEditorScreen]
class PollEditorRoute extends _i70.PageRouteInfo<PollEditorRouteArgs> {
  PollEditorRoute({
    _i71.Key? key,
    String? initialPollId,
    String? initialPublisher,
    List<_i70.PageRouteInfo>? children,
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

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PollEditorRouteArgs>(
        orElse: () => const PollEditorRouteArgs(),
      );
      return _i47.PollEditorScreen(
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

  final _i71.Key? key;

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
/// [_i48.PollSubmitPage]
class PollSubmitRoute extends _i70.PageRouteInfo<PollSubmitRouteArgs> {
  PollSubmitRoute({
    _i72.Key? key,
    required String pollId,
    bool isReadonly = false,
    bool isInitiallyExpanded = true,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         PollSubmitRoute.name,
         args: PollSubmitRouteArgs(
           key: key,
           pollId: pollId,
           isReadonly: isReadonly,
           isInitiallyExpanded: isInitiallyExpanded,
         ),
         rawPathParams: {'id': pollId},
         initialChildren: children,
       );

  static const String name = 'PollSubmitRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PollSubmitRouteArgs>(
        orElse: () => PollSubmitRouteArgs(pollId: pathParams.getString('id')),
      );
      return _i48.PollSubmitPage(
        key: args.key,
        pollId: args.pollId,
        isReadonly: args.isReadonly,
        isInitiallyExpanded: args.isInitiallyExpanded,
      );
    },
  );
}

class PollSubmitRouteArgs {
  const PollSubmitRouteArgs({
    this.key,
    required this.pollId,
    this.isReadonly = false,
    this.isInitiallyExpanded = true,
  });

  final _i72.Key? key;

  final String pollId;

  final bool isReadonly;

  final bool isInitiallyExpanded;

  @override
  String toString() {
    return 'PollSubmitRouteArgs{key: $key, pollId: $pollId, isReadonly: $isReadonly, isInitiallyExpanded: $isInitiallyExpanded}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PollSubmitRouteArgs) return false;
    return key == other.key &&
        pollId == other.pollId &&
        isReadonly == other.isReadonly &&
        isInitiallyExpanded == other.isInitiallyExpanded;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      pollId.hashCode ^
      isReadonly.hashCode ^
      isInitiallyExpanded.hashCode;
}

/// generated route for
/// [_i49.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i70.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i70.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i49.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i50.PostCategoryDetailScreen]
class PostCategoryDetailRoute
    extends _i70.PageRouteInfo<PostCategoryDetailRouteArgs> {
  PostCategoryDetailRoute({
    _i72.Key? key,
    required String slug,
    required bool isCategory,
    List<_i70.PageRouteInfo>? children,
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

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostCategoryDetailRouteArgs>();
      return _i50.PostCategoryDetailScreen(
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

  final _i72.Key? key;

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
/// [_i51.PostDetailScreen]
class PostDetailRoute extends _i70.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i71.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i51.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i71.Key? key;

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
/// [_i52.PostShuffleScreen]
class PostShuffleRoute extends _i70.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i70.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i52.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i53.ProgressScreen]
class ProgressRoute extends _i70.PageRouteInfo<void> {
  const ProgressRoute({List<_i70.PageRouteInfo>? children})
    : super(ProgressRoute.name, initialChildren: children);

  static const String name = 'ProgressRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i53.ProgressScreen();
    },
  );
}

/// generated route for
/// [_i54.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i70.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i72.Key? key,
    required String name,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherProfileRouteArgs>(
        orElse: () =>
            PublisherProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i54.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i72.Key? key;

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
/// [_i55.PunishmentsScreen]
class PunishmentsRoute extends _i70.PageRouteInfo<void> {
  const PunishmentsRoute({List<_i70.PageRouteInfo>? children})
    : super(PunishmentsRoute.name, initialChildren: children);

  static const String name = 'PunishmentsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i55.PunishmentsScreen();
    },
  );
}

/// generated route for
/// [_i56.RealmDetailScreen]
class RealmDetailRoute extends _i70.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i72.Key? key,
    required String slug,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i56.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i72.Key? key;

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
class RealmListRoute extends _i70.PageRouteInfo<void> {
  const RealmListRoute({List<_i70.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i57.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i58.RelationshipScreen]
class RelationshipRoute extends _i70.PageRouteInfo<void> {
  const RelationshipRoute({List<_i70.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i58.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i59.SearchMessagesScreen]
class SearchMessagesRoute extends _i70.PageRouteInfo<SearchMessagesRouteArgs> {
  SearchMessagesRoute({
    _i72.Key? key,
    required String roomId,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         SearchMessagesRoute.name,
         args: SearchMessagesRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'SearchMessagesRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SearchMessagesRouteArgs>(
        orElse: () =>
            SearchMessagesRouteArgs(roomId: pathParams.getString('id')),
      );
      return _i59.SearchMessagesScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class SearchMessagesRouteArgs {
  const SearchMessagesRouteArgs({this.key, required this.roomId});

  final _i72.Key? key;

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
class SettingsRoute extends _i70.PageRouteInfo<void> {
  const SettingsRoute({List<_i70.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i60.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i61.StickerMarketplacePackDetailScreen]
class StickerMarketplacePackDetailRoute
    extends _i70.PageRouteInfo<StickerMarketplacePackDetailRouteArgs> {
  StickerMarketplacePackDetailRoute({
    _i72.Key? key,
    required String id,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         StickerMarketplacePackDetailRoute.name,
         args: StickerMarketplacePackDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'StickerMarketplacePackDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickerMarketplacePackDetailRouteArgs>(
        orElse: () => StickerMarketplacePackDetailRouteArgs(
          id: pathParams.getString('id'),
        ),
      );
      return _i61.StickerMarketplacePackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class StickerMarketplacePackDetailRouteArgs {
  const StickerMarketplacePackDetailRouteArgs({this.key, required this.id});

  final _i72.Key? key;

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
/// [_i62.StickerMarketplaceScreen]
class StickerMarketplaceRoute extends _i70.PageRouteInfo<void> {
  const StickerMarketplaceRoute({List<_i70.PageRouteInfo>? children})
    : super(StickerMarketplaceRoute.name, initialChildren: children);

  static const String name = 'StickerMarketplaceRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i62.StickerMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i63.TabsScreen]
class TabsRoute extends _i70.PageRouteInfo<void> {
  const TabsRoute({List<_i70.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i63.TabsScreen();
    },
  );
}

/// generated route for
/// [_i64.ThoughtScreen]
class ThoughtRoute extends _i70.PageRouteInfo<void> {
  const ThoughtRoute({List<_i70.PageRouteInfo>? children})
    : super(ThoughtRoute.name, initialChildren: children);

  static const String name = 'ThoughtRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i64.ThoughtScreen();
    },
  );
}

/// generated route for
/// [_i65.TicketDetailScreen]
class TicketDetailRoute extends _i70.PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    _i72.Key? key,
    required String ticketId,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(key: key, ticketId: ticketId),
         rawPathParams: {'ticketId': ticketId},
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TicketDetailRouteArgs>(
        orElse: () =>
            TicketDetailRouteArgs(ticketId: pathParams.getString('ticketId')),
      );
      return _i65.TicketDetailScreen(key: args.key, ticketId: args.ticketId);
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticketId});

  final _i72.Key? key;

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
/// [_i66.TicketListScreen]
class TicketListRoute extends _i70.PageRouteInfo<void> {
  const TicketListRoute({List<_i70.PageRouteInfo>? children})
    : super(TicketListRoute.name, initialChildren: children);

  static const String name = 'TicketListRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i66.TicketListScreen();
    },
  );
}

/// generated route for
/// [_i67.TransactionDetailScreen]
class TransactionDetailRoute
    extends _i70.PageRouteInfo<TransactionDetailRouteArgs> {
  TransactionDetailRoute({
    _i72.Key? key,
    required String transactionId,
    String? currentWalletId,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         TransactionDetailRoute.name,
         args: TransactionDetailRouteArgs(
           key: key,
           transactionId: transactionId,
           currentWalletId: currentWalletId,
         ),
         rawPathParams: {'id': transactionId},
         initialChildren: children,
       );

  static const String name = 'TransactionDetailRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TransactionDetailRouteArgs>(
        orElse: () => TransactionDetailRouteArgs(
          transactionId: pathParams.getString('id'),
        ),
      );
      return _i67.TransactionDetailScreen(
        key: args.key,
        transactionId: args.transactionId,
        currentWalletId: args.currentWalletId,
      );
    },
  );
}

class TransactionDetailRouteArgs {
  const TransactionDetailRouteArgs({
    this.key,
    required this.transactionId,
    this.currentWalletId,
  });

  final _i72.Key? key;

  final String transactionId;

  final String? currentWalletId;

  @override
  String toString() {
    return 'TransactionDetailRouteArgs{key: $key, transactionId: $transactionId, currentWalletId: $currentWalletId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionDetailRouteArgs) return false;
    return key == other.key &&
        transactionId == other.transactionId &&
        currentWalletId == other.currentWalletId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ transactionId.hashCode ^ currentWalletId.hashCode;
}

/// generated route for
/// [_i68.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i70.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i72.Key? key,
    _i68.SearchTab initialTab = _i68.SearchTab.posts,
    List<_i70.PageRouteInfo>? children,
  }) : super(
         UniversalSearchRoute.name,
         args: UniversalSearchRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'UniversalSearchRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UniversalSearchRouteArgs>(
        orElse: () => const UniversalSearchRouteArgs(),
      );
      return _i68.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i68.SearchTab.posts,
  });

  final _i72.Key? key;

  final _i68.SearchTab initialTab;

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
/// [_i69.WalletScreen]
class WalletRoute extends _i70.PageRouteInfo<void> {
  const WalletRoute({List<_i70.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i70.PageInfo page = _i70.PageInfo(
    name,
    builder: (data) {
      return const _i69.WalletScreen();
    },
  );
}
