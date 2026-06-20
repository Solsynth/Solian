// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i71;
import 'package:flutter/foundation.dart' as _i72;
import 'package:flutter/material.dart' as _i73;
import 'package:island/accounts/account_screen.dart' as _i2;
import 'package:island/accounts/screens/action_logs.dart' as _i7;
import 'package:island/accounts/screens/affiliation_detail.dart' as _i8;
import 'package:island/accounts/screens/affiliations.dart' as _i9;
import 'package:island/accounts/screens/badges.dart' as _i13;
import 'package:island/accounts/screens/calendar_event_detail_screen.dart'
    as _i15;
import 'package:island/accounts/screens/check_in.dart' as _i23;
import 'package:island/accounts/screens/event_hub_screen.dart' as _i35;
import 'package:island/accounts/screens/leveling.dart' as _i42;
import 'package:island/accounts/screens/me/account_qr.dart' as _i4;
import 'package:island/accounts/screens/me/account_settings.dart' as _i5;
import 'package:island/accounts/screens/me/profile_update.dart' as _i6;
import 'package:island/accounts/screens/meet.dart' as _i44;
import 'package:island/accounts/screens/physical_passport.dart' as _i45;
import 'package:island/accounts/screens/profile.dart' as _i3;
import 'package:island/accounts/screens/progress.dart' as _i54;
import 'package:island/accounts/screens/punishments.dart' as _i56;
import 'package:island/accounts/screens/relationship.dart' as _i59;
import 'package:island/auth/captcha.dart' as _i17;
import 'package:island/auth/create_account.dart' as _i24;
import 'package:island/auth/login.dart' as _i43;
import 'package:island/chat/widgets/call_screen.dart' as _i16;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i19;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i20;
import 'package:island/chat/widgets/chat_room_form.dart' as _i33;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i21;
import 'package:island/chat/widgets/chat_room_storage_screen.dart' as _i22;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i60;
import 'package:island/creators/screens/hub.dart' as _i26;
import 'package:island/creators/screens/poll/poll_list.dart' as _i27;
import 'package:island/creators/screens/posts/post_collections_manage.dart'
    as _i28;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i29;
import 'package:island/creators/screens/publishers_form.dart' as _i34;
import 'package:island/creators/screens/stickers/pack_detail_screen.dart'
    as _i31;
import 'package:island/creators/screens/stickers/stickers.dart' as _i30;
import 'package:island/creators/screens/webfeed/webfeed_list.dart' as _i25;
import 'package:island/discovery/explore.dart' as _i36;
import 'package:island/discovery/screens/article_detail.dart' as _i11;
import 'package:island/discovery/screens/articles.dart' as _i12;
import 'package:island/discovery/screens/feeds/feed_detail.dart' as _i38;
import 'package:island/discovery/screens/feeds/feed_marketplace.dart' as _i39;
import 'package:island/discovery/search.dart' as _i69;
import 'package:island/drive/files/file_detail.dart' as _i40;
import 'package:island/drive/files/file_list.dart' as _i41;
import 'package:island/fediverse/actor_profile.dart' as _i37;
import 'package:island/misc/about.dart' as _i1;
import 'package:island/misc/cf_ip_speed_test_screen.dart' as _i18;
import 'package:island/misc/dashboard/dash.dart' as _i32;
import 'package:island/misc/settings.dart' as _i61;
import 'package:island/misc/tabs_screen.dart' as _i64;
import 'package:island/plugins/screens/plugin_editor_screen.dart' as _i46;
import 'package:island/plugins/screens/plugin_manager_screen.dart' as _i47;
import 'package:island/polls/polls_widgets/poll/poll_submit_page.dart' as _i49;
import 'package:island/polls/screens/poll_editor.dart' as _i48;
import 'package:island/posts/compose.dart' as _i75;
import 'package:island/posts/screens/bookmarks.dart' as _i14;
import 'package:island/posts/screens/compose_article.dart' as _i10;
import 'package:island/posts/screens/post_categories_list.dart' as _i50;
import 'package:island/posts/screens/post_category_detail.dart' as _i51;
import 'package:island/posts/screens/post_detail.dart' as _i52;
import 'package:island/posts/screens/publisher_profile.dart' as _i55;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i53;
import 'package:island/realms/screens/realm_detail.dart' as _i57;
import 'package:island/realms/screens/realms.dart' as _i58;
import 'package:island/stickers/screens/pack_detail.dart' as _i62;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i63;
import 'package:island/thoughts/screens/think.dart' as _i65;
import 'package:island/tickets/screens/ticket_detail.dart' as _i66;
import 'package:island/tickets/screens/ticket_list.dart' as _i67;
import 'package:island/wallets/transaction_detail.dart' as _i68;
import 'package:island/wallets/wallet.dart' as _i70;
import 'package:solar_network_sdk/solar_network_sdk.dart' as _i74;

/// generated route for
/// [_i1.AboutScreen]
class AboutRoute extends _i71.PageRouteInfo<void> {
  const AboutRoute({List<_i71.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountListScreen]
class AccountListRoute extends _i71.PageRouteInfo<void> {
  const AccountListRoute({List<_i71.PageRouteInfo>? children})
    : super(AccountListRoute.name, initialChildren: children);

  static const String name = 'AccountListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountListScreen();
    },
  );
}

/// generated route for
/// [_i3.AccountProfileScreen]
class AccountProfileRoute extends _i71.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i72.Key? key,
    required String name,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i72.Key? key;

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
class AccountQrRoute extends _i71.PageRouteInfo<void> {
  const AccountQrRoute({List<_i71.PageRouteInfo>? children})
    : super(AccountQrRoute.name, initialChildren: children);

  static const String name = 'AccountQrRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i4.AccountQrScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i71.PageRouteInfo<void> {
  const AccountRoute({List<_i71.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountScreen();
    },
  );
}

/// generated route for
/// [_i5.AccountSettingsScreen]
class AccountSettingsRoute extends _i71.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i71.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i5.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i6.AccountUpdateProfileScreen]
class AccountUpdateProfileRoute extends _i71.PageRouteInfo<void> {
  const AccountUpdateProfileRoute({List<_i71.PageRouteInfo>? children})
    : super(AccountUpdateProfileRoute.name, initialChildren: children);

  static const String name = 'AccountUpdateProfileRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i6.AccountUpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i7.ActionLogsScreen]
class ActionLogsRoute extends _i71.PageRouteInfo<void> {
  const ActionLogsRoute({List<_i71.PageRouteInfo>? children})
    : super(ActionLogsRoute.name, initialChildren: children);

  static const String name = 'ActionLogsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i7.ActionLogsScreen();
    },
  );
}

/// generated route for
/// [_i8.AffiliationDetailScreen]
class AffiliationDetailRoute
    extends _i71.PageRouteInfo<AffiliationDetailRouteArgs> {
  AffiliationDetailRoute({
    _i73.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         AffiliationDetailRoute.name,
         args: AffiliationDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'AffiliationDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class AffiliationRoute extends _i71.PageRouteInfo<void> {
  const AffiliationRoute({List<_i71.PageRouteInfo>? children})
    : super(AffiliationRoute.name, initialChildren: children);

  static const String name = 'AffiliationRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i9.AffiliationScreen();
    },
  );
}

/// generated route for
/// [_i10.ArticleComposeScreen]
class ArticleComposeRoute extends _i71.PageRouteInfo<ArticleComposeRouteArgs> {
  ArticleComposeRoute({
    _i73.Key? key,
    _i74.SnPost? originalPost,
    _i75.PostComposeInitialState? initialState,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

  final _i74.SnPost? originalPost;

  final _i75.PostComposeInitialState? initialState;

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
/// [_i11.ArticleDetailScreen]
class ArticleDetailRoute extends _i71.PageRouteInfo<ArticleDetailRouteArgs> {
  ArticleDetailRoute({
    _i73.Key? key,
    required String articleId,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         ArticleDetailRoute.name,
         args: ArticleDetailRouteArgs(key: key, articleId: articleId),
         rawPathParams: {'id': articleId},
         initialChildren: children,
       );

  static const String name = 'ArticleDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArticleDetailRouteArgs>(
        orElse: () =>
            ArticleDetailRouteArgs(articleId: pathParams.getString('id')),
      );
      return _i11.ArticleDetailScreen(key: args.key, articleId: args.articleId);
    },
  );
}

class ArticleDetailRouteArgs {
  const ArticleDetailRouteArgs({this.key, required this.articleId});

  final _i73.Key? key;

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
/// [_i10.ArticleEditScreen]
class ArticleEditRoute extends _i71.PageRouteInfo<ArticleEditRouteArgs> {
  ArticleEditRoute({
    _i73.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         ArticleEditRoute.name,
         args: ArticleEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ArticleEditRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
/// [_i12.ArticleStandScreen]
class ArticleStandRoute extends _i71.PageRouteInfo<void> {
  const ArticleStandRoute({List<_i71.PageRouteInfo>? children})
    : super(ArticleStandRoute.name, initialChildren: children);

  static const String name = 'ArticleStandRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i12.ArticleStandScreen();
    },
  );
}

/// generated route for
/// [_i13.BadgesScreen]
class BadgesRoute extends _i71.PageRouteInfo<void> {
  const BadgesRoute({List<_i71.PageRouteInfo>? children})
    : super(BadgesRoute.name, initialChildren: children);

  static const String name = 'BadgesRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i13.BadgesScreen();
    },
  );
}

/// generated route for
/// [_i14.BookmarksScreen]
class BookmarksRoute extends _i71.PageRouteInfo<void> {
  const BookmarksRoute({List<_i71.PageRouteInfo>? children})
    : super(BookmarksRoute.name, initialChildren: children);

  static const String name = 'BookmarksRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i14.BookmarksScreen();
    },
  );
}

/// generated route for
/// [_i15.CalendarEventDetailScreen]
class CalendarEventDetailRoute
    extends _i71.PageRouteInfo<CalendarEventDetailRouteArgs> {
  CalendarEventDetailRoute({
    _i73.Key? key,
    required String username,
    required String eventId,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class CallRoute extends _i71.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i73.Key? key,
    required _i74.SnChatRoom room,
    bool cameraEnabled = false,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

  final _i74.SnChatRoom room;

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
class CaptchaRoute extends _i71.PageRouteInfo<void> {
  const CaptchaRoute({List<_i71.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i17.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i18.CfIpSpeedTestScreen]
class CfIpSpeedTestRoute extends _i71.PageRouteInfo<void> {
  const CfIpSpeedTestRoute({List<_i71.PageRouteInfo>? children})
    : super(CfIpSpeedTestRoute.name, initialChildren: children);

  static const String name = 'CfIpSpeedTestRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i18.CfIpSpeedTestScreen();
    },
  );
}

/// generated route for
/// [_i19.ChatDetailScreen]
class ChatDetailRoute extends _i71.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i73.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class ChatListRoute extends _i71.PageRouteInfo<void> {
  const ChatListRoute({List<_i71.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i20.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i21.ChatRoomScreen]
class ChatRoomRoute extends _i71.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i72.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i72.Key? key;

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
class ChatRoomStorageRoute extends _i71.PageRouteInfo<void> {
  const ChatRoomStorageRoute({List<_i71.PageRouteInfo>? children})
    : super(ChatRoomStorageRoute.name, initialChildren: children);

  static const String name = 'ChatRoomStorageRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i22.ChatRoomStorageScreen();
    },
  );
}

/// generated route for
/// [_i20.ChatScreen]
class ChatRoute extends _i71.PageRouteInfo<void> {
  const ChatRoute({List<_i71.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i20.ChatScreen();
    },
  );
}

/// generated route for
/// [_i23.CheckInScreen]
class CheckInRoute extends _i71.PageRouteInfo<void> {
  const CheckInRoute({List<_i71.PageRouteInfo>? children})
    : super(CheckInRoute.name, initialChildren: children);

  static const String name = 'CheckInRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i23.CheckInScreen();
    },
  );
}

/// generated route for
/// [_i24.CreateAccountScreen]
class CreateAccountRoute extends _i71.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i71.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i24.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i25.CreatorFeedListScreen]
class CreatorFeedListRoute
    extends _i71.PageRouteInfo<CreatorFeedListRouteArgs> {
  CreatorFeedListRoute({
    _i73.Key? key,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         CreatorFeedListRoute.name,
         args: CreatorFeedListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorFeedListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorFeedListRouteArgs>(
        orElse: () =>
            CreatorFeedListRouteArgs(pubName: pathParams.getString('pubName')),
      );
      return _i25.CreatorFeedListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorFeedListRouteArgs {
  const CreatorFeedListRouteArgs({this.key, required this.pubName});

  final _i73.Key? key;

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
/// [_i26.CreatorHubListScreen]
class CreatorHubListRoute extends _i71.PageRouteInfo<void> {
  const CreatorHubListRoute({List<_i71.PageRouteInfo>? children})
    : super(CreatorHubListRoute.name, initialChildren: children);

  static const String name = 'CreatorHubListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i26.CreatorHubListScreen();
    },
  );
}

/// generated route for
/// [_i26.CreatorHubScreen]
class CreatorHubRoute extends _i71.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i71.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i26.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i27.CreatorPollListScreen]
class CreatorPollListRoute
    extends _i71.PageRouteInfo<CreatorPollListRouteArgs> {
  CreatorPollListRoute({
    _i73.Key? key,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         CreatorPollListRoute.name,
         args: CreatorPollListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPollListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
    extends _i71.PageRouteInfo<CreatorPostCollectionsRouteArgs> {
  CreatorPostCollectionsRoute({
    _i73.Key? key,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         CreatorPostCollectionsRoute.name,
         args: CreatorPostCollectionsRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostCollectionsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
    extends _i71.PageRouteInfo<CreatorPostListRouteArgs> {
  CreatorPostListRoute({
    _i73.Key? key,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         CreatorPostListRoute.name,
         args: CreatorPostListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
    extends _i71.PageRouteInfo<CreatorStickerListRouteArgs> {
  CreatorStickerListRoute({
    _i73.Key? key,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         CreatorStickerListRoute.name,
         args: CreatorStickerListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorStickerListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
    extends _i71.PageRouteInfo<CreatorStickerPackDetailRouteArgs> {
  CreatorStickerPackDetailRoute({
    _i73.Key? key,
    required String packId,
    required String pubName,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class DashboardRoute extends _i71.PageRouteInfo<void> {
  const DashboardRoute({List<_i71.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i32.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i33.EditChatScreen]
class EditChatRoute extends _i71.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i73.Key? key, String? id, List<_i71.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class EditPublisherRoute extends _i71.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i73.Key? key,
    String? name,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class EventHubRoute extends _i71.PageRouteInfo<EventHubRouteArgs> {
  EventHubRoute({
    _i73.Key? key,
    required String name,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         EventHubRoute.name,
         args: EventHubRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'EventHubRoute';

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class ExploreRoute extends _i71.PageRouteInfo<void> {
  const ExploreRoute({List<_i71.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i36.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i37.FediverseActorProfileScreen]
class FediverseActorProfileRoute
    extends _i71.PageRouteInfo<FediverseActorProfileRouteArgs> {
  FediverseActorProfileRoute({
    _i73.Key? key,
    required String id,
    String? fullHandle,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
/// [_i38.FeedMarketplaceDetailScreen]
class FeedMarketplaceDetailRoute
    extends _i71.PageRouteInfo<FeedMarketplaceDetailRouteArgs> {
  FeedMarketplaceDetailRoute({
    _i73.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         FeedMarketplaceDetailRoute.name,
         args: FeedMarketplaceDetailRouteArgs(key: key, id: id),
         rawPathParams: {'feedId': id},
         initialChildren: children,
       );

  static const String name = 'FeedMarketplaceDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FeedMarketplaceDetailRouteArgs>(
        orElse: () =>
            FeedMarketplaceDetailRouteArgs(id: pathParams.getString('feedId')),
      );
      return _i38.FeedMarketplaceDetailScreen(key: args.key, id: args.id);
    },
  );
}

class FeedMarketplaceDetailRouteArgs {
  const FeedMarketplaceDetailRouteArgs({this.key, required this.id});

  final _i73.Key? key;

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
/// [_i39.FeedMarketplaceScreen]
class FeedMarketplaceRoute extends _i71.PageRouteInfo<void> {
  const FeedMarketplaceRoute({List<_i71.PageRouteInfo>? children})
    : super(FeedMarketplaceRoute.name, initialChildren: children);

  static const String name = 'FeedMarketplaceRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i39.FeedMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i40.FileDetailScreen]
class FileDetailRoute extends _i71.PageRouteInfo<FileDetailRouteArgs> {
  FileDetailRoute({
    _i72.Key? key,
    required String id,
    String? heroTag,
    _i74.SnPost? sourcePost,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FileDetailRouteArgs>();
      return _i40.FileDetailScreen(
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

  final _i72.Key? key;

  final String id;

  final String? heroTag;

  final _i74.SnPost? sourcePost;

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
/// [_i41.FileListScreen]
class FileListRoute extends _i71.PageRouteInfo<void> {
  const FileListRoute({List<_i71.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i41.FileListScreen();
    },
  );
}

/// generated route for
/// [_i42.LevelingScreen]
class LevelingRoute extends _i71.PageRouteInfo<void> {
  const LevelingRoute({List<_i71.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i42.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i43.LoginScreen]
class LoginRoute extends _i71.PageRouteInfo<void> {
  const LoginRoute({List<_i71.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i43.LoginScreen();
    },
  );
}

/// generated route for
/// [_i44.MeetDetailScreen]
class MeetDetailRoute extends _i71.PageRouteInfo<MeetDetailRouteArgs> {
  MeetDetailRoute({
    _i72.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         MeetDetailRoute.name,
         args: MeetDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MeetDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MeetDetailRouteArgs>(
        orElse: () => MeetDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i44.MeetDetailScreen(key: args.key, id: args.id);
    },
  );
}

class MeetDetailRouteArgs {
  const MeetDetailRouteArgs({this.key, required this.id});

  final _i72.Key? key;

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
/// [_i44.MeetScreen]
class MeetRoute extends _i71.PageRouteInfo<void> {
  const MeetRoute({List<_i71.PageRouteInfo>? children})
    : super(MeetRoute.name, initialChildren: children);

  static const String name = 'MeetRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i44.MeetScreen();
    },
  );
}

/// generated route for
/// [_i33.NewChatScreen]
class NewChatRoute extends _i71.PageRouteInfo<void> {
  const NewChatRoute({List<_i71.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i33.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i34.NewPublisherScreen]
class NewPublisherRoute extends _i71.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i71.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i34.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i45.PhysicalPassportScreen]
class PhysicalPassportRoute extends _i71.PageRouteInfo<void> {
  const PhysicalPassportRoute({List<_i71.PageRouteInfo>? children})
    : super(PhysicalPassportRoute.name, initialChildren: children);

  static const String name = 'PhysicalPassportRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i45.PhysicalPassportScreen();
    },
  );
}

/// generated route for
/// [_i46.PluginEditorScreen]
class PluginEditorRoute extends _i71.PageRouteInfo<void> {
  const PluginEditorRoute({List<_i71.PageRouteInfo>? children})
    : super(PluginEditorRoute.name, initialChildren: children);

  static const String name = 'PluginEditorRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i46.PluginEditorScreen();
    },
  );
}

/// generated route for
/// [_i47.PluginManagerScreen]
class PluginManagerRoute extends _i71.PageRouteInfo<void> {
  const PluginManagerRoute({List<_i71.PageRouteInfo>? children})
    : super(PluginManagerRoute.name, initialChildren: children);

  static const String name = 'PluginManagerRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i47.PluginManagerScreen();
    },
  );
}

/// generated route for
/// [_i48.PollEditorScreen]
class PollEditorRoute extends _i71.PageRouteInfo<PollEditorRouteArgs> {
  PollEditorRoute({
    _i72.Key? key,
    String? initialPollId,
    String? initialPublisher,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PollEditorRouteArgs>(
        orElse: () => const PollEditorRouteArgs(),
      );
      return _i48.PollEditorScreen(
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

  final _i72.Key? key;

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
/// [_i49.PollSubmitPage]
class PollSubmitRoute extends _i71.PageRouteInfo<PollSubmitRouteArgs> {
  PollSubmitRoute({
    _i73.Key? key,
    required String pollId,
    bool isReadonly = false,
    bool isInitiallyExpanded = true,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PollSubmitRouteArgs>(
        orElse: () => PollSubmitRouteArgs(pollId: pathParams.getString('id')),
      );
      return _i49.PollSubmitPage(
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

  final _i73.Key? key;

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
/// [_i50.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i71.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i71.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i50.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i51.PostCategoryDetailScreen]
class PostCategoryDetailRoute
    extends _i71.PageRouteInfo<PostCategoryDetailRouteArgs> {
  PostCategoryDetailRoute({
    _i73.Key? key,
    required String slug,
    required bool isCategory,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
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

  final _i73.Key? key;

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
class PostDetailRoute extends _i71.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i72.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i52.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i72.Key? key;

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
class PostShuffleRoute extends _i71.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i71.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i53.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i54.ProgressScreen]
class ProgressRoute extends _i71.PageRouteInfo<void> {
  const ProgressRoute({List<_i71.PageRouteInfo>? children})
    : super(ProgressRoute.name, initialChildren: children);

  static const String name = 'ProgressRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i54.ProgressScreen();
    },
  );
}

/// generated route for
/// [_i55.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i71.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i73.Key? key,
    required String name,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherProfileRouteArgs>(
        orElse: () =>
            PublisherProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i55.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i73.Key? key;

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
/// [_i56.PunishmentsScreen]
class PunishmentsRoute extends _i71.PageRouteInfo<void> {
  const PunishmentsRoute({List<_i71.PageRouteInfo>? children})
    : super(PunishmentsRoute.name, initialChildren: children);

  static const String name = 'PunishmentsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i56.PunishmentsScreen();
    },
  );
}

/// generated route for
/// [_i57.RealmDetailScreen]
class RealmDetailRoute extends _i71.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i73.Key? key,
    required String slug,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i57.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i73.Key? key;

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
/// [_i58.RealmListScreen]
class RealmListRoute extends _i71.PageRouteInfo<void> {
  const RealmListRoute({List<_i71.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i58.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i59.RelationshipScreen]
class RelationshipRoute extends _i71.PageRouteInfo<void> {
  const RelationshipRoute({List<_i71.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i59.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i60.SearchMessagesScreen]
class SearchMessagesRoute extends _i71.PageRouteInfo<SearchMessagesRouteArgs> {
  SearchMessagesRoute({
    _i73.Key? key,
    required String roomId,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         SearchMessagesRoute.name,
         args: SearchMessagesRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'SearchMessagesRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SearchMessagesRouteArgs>(
        orElse: () =>
            SearchMessagesRouteArgs(roomId: pathParams.getString('id')),
      );
      return _i60.SearchMessagesScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class SearchMessagesRouteArgs {
  const SearchMessagesRouteArgs({this.key, required this.roomId});

  final _i73.Key? key;

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
class SettingsRoute extends _i71.PageRouteInfo<void> {
  const SettingsRoute({List<_i71.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i61.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i62.StickerMarketplacePackDetailScreen]
class StickerMarketplacePackDetailRoute
    extends _i71.PageRouteInfo<StickerMarketplacePackDetailRouteArgs> {
  StickerMarketplacePackDetailRoute({
    _i73.Key? key,
    required String id,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         StickerMarketplacePackDetailRoute.name,
         args: StickerMarketplacePackDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'StickerMarketplacePackDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickerMarketplacePackDetailRouteArgs>(
        orElse: () => StickerMarketplacePackDetailRouteArgs(
          id: pathParams.getString('id'),
        ),
      );
      return _i62.StickerMarketplacePackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class StickerMarketplacePackDetailRouteArgs {
  const StickerMarketplacePackDetailRouteArgs({this.key, required this.id});

  final _i73.Key? key;

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
class StickerMarketplaceRoute extends _i71.PageRouteInfo<void> {
  const StickerMarketplaceRoute({List<_i71.PageRouteInfo>? children})
    : super(StickerMarketplaceRoute.name, initialChildren: children);

  static const String name = 'StickerMarketplaceRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i63.StickerMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i64.TabsScreen]
class TabsRoute extends _i71.PageRouteInfo<void> {
  const TabsRoute({List<_i71.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i64.TabsScreen();
    },
  );
}

/// generated route for
/// [_i65.ThoughtScreen]
class ThoughtRoute extends _i71.PageRouteInfo<void> {
  const ThoughtRoute({List<_i71.PageRouteInfo>? children})
    : super(ThoughtRoute.name, initialChildren: children);

  static const String name = 'ThoughtRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i65.ThoughtScreen();
    },
  );
}

/// generated route for
/// [_i66.TicketDetailScreen]
class TicketDetailRoute extends _i71.PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    _i73.Key? key,
    required String ticketId,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(key: key, ticketId: ticketId),
         rawPathParams: {'ticketId': ticketId},
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TicketDetailRouteArgs>(
        orElse: () =>
            TicketDetailRouteArgs(ticketId: pathParams.getString('ticketId')),
      );
      return _i66.TicketDetailScreen(key: args.key, ticketId: args.ticketId);
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticketId});

  final _i73.Key? key;

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
/// [_i67.TicketListScreen]
class TicketListRoute extends _i71.PageRouteInfo<void> {
  const TicketListRoute({List<_i71.PageRouteInfo>? children})
    : super(TicketListRoute.name, initialChildren: children);

  static const String name = 'TicketListRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i67.TicketListScreen();
    },
  );
}

/// generated route for
/// [_i68.TransactionDetailScreen]
class TransactionDetailRoute
    extends _i71.PageRouteInfo<TransactionDetailRouteArgs> {
  TransactionDetailRoute({
    _i73.Key? key,
    required String transactionId,
    String? currentWalletId,
    List<_i71.PageRouteInfo>? children,
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

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TransactionDetailRouteArgs>(
        orElse: () => TransactionDetailRouteArgs(
          transactionId: pathParams.getString('id'),
        ),
      );
      return _i68.TransactionDetailScreen(
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

  final _i73.Key? key;

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
/// [_i69.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i71.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i73.Key? key,
    _i69.SearchTab initialTab = _i69.SearchTab.posts,
    List<_i71.PageRouteInfo>? children,
  }) : super(
         UniversalSearchRoute.name,
         args: UniversalSearchRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'UniversalSearchRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UniversalSearchRouteArgs>(
        orElse: () => const UniversalSearchRouteArgs(),
      );
      return _i69.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i69.SearchTab.posts,
  });

  final _i73.Key? key;

  final _i69.SearchTab initialTab;

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
/// [_i70.WalletScreen]
class WalletRoute extends _i71.PageRouteInfo<void> {
  const WalletRoute({List<_i71.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i71.PageInfo page = _i71.PageInfo(
    name,
    builder: (data) {
      return const _i70.WalletScreen();
    },
  );
}
