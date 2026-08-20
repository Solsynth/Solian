// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i74;
import 'package:flutter/foundation.dart' as _i78;
import 'package:island/accounts/account_screen.dart' as _i4;
import 'package:island/accounts/screens/action_logs.dart' as _i9;
import 'package:island/accounts/screens/affiliation_detail.dart' as _i10;
import 'package:island/accounts/screens/affiliations.dart' as _i11;
import 'package:island/accounts/screens/calendar_event_detail_screen.dart'
    as _i17;
import 'package:island/accounts/screens/event_hub_screen.dart' as _i37;
import 'package:island/accounts/screens/leveling.dart' as _i42;
import 'package:island/accounts/screens/me/account_activation.dart' as _i2;
import 'package:island/accounts/screens/me/account_qr.dart' as _i6;
import 'package:island/accounts/screens/me/account_settings.dart' as _i7;
import 'package:island/accounts/screens/me/ai_console.dart' as _i12;
import 'package:island/accounts/screens/me/board_edit.dart' as _i3;
import 'package:island/accounts/screens/me/profile_update.dart' as _i8;
import 'package:island/accounts/screens/meet.dart' as _i44;
import 'package:island/accounts/screens/profile.dart' as _i5;
import 'package:island/accounts/screens/progress.dart' as _i52;
import 'package:island/accounts/screens/punishments.dart' as _i54;
import 'package:island/accounts/screens/relationship.dart' as _i57;
import 'package:island/accounts/screens/store.dart' as _i62;
import 'package:island/auth/authorize_screen.dart' as _i14;
import 'package:island/auth/captcha.dart' as _i19;
import 'package:island/auth/create_account.dart' as _i25;
import 'package:island/auth/login.dart' as _i43;
import 'package:island/chat/widgets/call_screen.dart' as _i18;
import 'package:island/chat/widgets/chat_detail_screen.dart' as _i21;
import 'package:island/chat/widgets/chat_list_screen.dart' as _i22;
import 'package:island/chat/widgets/chat_room_form.dart' as _i35;
import 'package:island/chat/widgets/chat_room_screen.dart' as _i23;
import 'package:island/chat/widgets/chat_room_storage_screen.dart' as _i24;
import 'package:island/chat/widgets/chat_search_screen.dart' as _i58;
import 'package:island/creators/screens/domains/domain_manage.dart' as _i26;
import 'package:island/creators/screens/hub.dart' as _i27;
import 'package:island/creators/screens/posts/post_collections_manage.dart'
    as _i28;
import 'package:island/creators/screens/posts/post_manage_list.dart' as _i29;
import 'package:island/creators/screens/posts/tag_manage.dart' as _i33;
import 'package:island/creators/screens/publishers_form.dart' as _i36;
import 'package:island/creators/screens/stickers/pack_detail_screen.dart'
    as _i31;
import 'package:island/creators/screens/stickers/stickers.dart' as _i30;
import 'package:island/creators/screens/survey/survey_list.dart' as _i32;
import 'package:island/discovery/explore.dart' as _i38;
import 'package:island/discovery/search.dart' as _i70;
import 'package:island/drive/files/file_detail.dart' as _i40;
import 'package:island/drive/files/file_list.dart' as _i41;
import 'package:island/fediverse/actor_profile.dart' as _i39;
import 'package:island/misc/about.dart' as _i1;
import 'package:island/misc/cf_ip_speed_test_screen.dart' as _i20;
import 'package:island/misc/dashboard/dash.dart' as _i34;
import 'package:island/misc/not_found.dart' as _i45;
import 'package:island/misc/settings.dart' as _i59;
import 'package:island/misc/tabs_screen.dart' as _i66;
import 'package:island/payments/order_detail.dart' as _i71;
import 'package:island/plugins/screens/plugin_editor_screen.dart' as _i46;
import 'package:island/plugins/screens/plugin_manager_screen.dart' as _i47;
import 'package:island/posts/compose.dart' as _i77;
import 'package:island/posts/screens/bookmarks.dart' as _i16;
import 'package:island/posts/screens/compose_article.dart' as _i13;
import 'package:island/posts/screens/compose_blog.dart' as _i15;
import 'package:island/posts/screens/post_categories_list.dart' as _i48;
import 'package:island/posts/screens/post_category_detail.dart' as _i49;
import 'package:island/posts/screens/post_detail.dart' as _i50;
import 'package:island/posts/screens/publisher_profile.dart' as _i53;
import 'package:island/posts/widgets/compose/post_shuffle.dart' as _i51;
import 'package:island/realms/screens/realm_detail.dart' as _i55;
import 'package:island/realms/screens/realms.dart' as _i56;
import 'package:island/stickers/screens/pack_detail.dart' as _i60;
import 'package:island/stickers/screens/sticker_marketplace.dart' as _i61;
import 'package:island/surveys/screens/survey_editor.dart' as _i63;
import 'package:island/surveys/widgets/survey_feedback.dart' as _i64;
import 'package:island/surveys/widgets/survey_submit_page.dart' as _i65;
import 'package:island/tickets/screens/ticket_detail.dart' as _i67;
import 'package:island/tickets/screens/ticket_list.dart' as _i68;
import 'package:island/wallets/transaction_detail.dart' as _i69;
import 'package:island/wallets/wallet.dart' as _i72;
import 'package:island/workspaces/workspace_management.dart' as _i73;
import 'package:material_ui/material_ui.dart' as _i75;
import 'package:solar_network_sdk/solar_network_sdk.dart' as _i76;

/// generated route for
/// [_i1.AboutScreen]
class AboutRoute extends _i74.PageRouteInfo<void> {
  const AboutRoute({List<_i74.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountActivationScreen]
class AccountActivationRoute extends _i74.PageRouteInfo<void> {
  const AccountActivationRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountActivationRoute.name, initialChildren: children);

  static const String name = 'AccountActivationRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountActivationScreen();
    },
  );
}

/// generated route for
/// [_i3.AccountBoardEditScreen]
class AccountBoardEditRoute extends _i74.PageRouteInfo<void> {
  const AccountBoardEditRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountBoardEditRoute.name, initialChildren: children);

  static const String name = 'AccountBoardEditRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i3.AccountBoardEditScreen();
    },
  );
}

/// generated route for
/// [_i4.AccountListScreen]
class AccountListRoute extends _i74.PageRouteInfo<void> {
  const AccountListRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountListRoute.name, initialChildren: children);

  static const String name = 'AccountListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i4.AccountListScreen();
    },
  );
}

/// generated route for
/// [_i5.AccountProfileScreen]
class AccountProfileRoute extends _i74.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i75.Key? key,
    required String name,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AccountProfileRouteArgs>(
        orElse: () =>
            AccountProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i5.AccountProfileScreen(key: args.key, name: args.name);
    },
  );
}

class AccountProfileRouteArgs {
  const AccountProfileRouteArgs({this.key, required this.name});

  final _i75.Key? key;

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
/// [_i6.AccountQrScreen]
class AccountQrRoute extends _i74.PageRouteInfo<void> {
  const AccountQrRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountQrRoute.name, initialChildren: children);

  static const String name = 'AccountQrRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i6.AccountQrScreen();
    },
  );
}

/// generated route for
/// [_i4.AccountScreen]
class AccountRoute extends _i74.PageRouteInfo<void> {
  const AccountRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i4.AccountScreen();
    },
  );
}

/// generated route for
/// [_i7.AccountSettingsScreen]
class AccountSettingsRoute extends _i74.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i7.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i8.AccountUpdateProfileScreen]
class AccountUpdateProfileRoute extends _i74.PageRouteInfo<void> {
  const AccountUpdateProfileRoute({List<_i74.PageRouteInfo>? children})
    : super(AccountUpdateProfileRoute.name, initialChildren: children);

  static const String name = 'AccountUpdateProfileRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i8.AccountUpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i9.ActionLogsScreen]
class ActionLogsRoute extends _i74.PageRouteInfo<void> {
  const ActionLogsRoute({List<_i74.PageRouteInfo>? children})
    : super(ActionLogsRoute.name, initialChildren: children);

  static const String name = 'ActionLogsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i9.ActionLogsScreen();
    },
  );
}

/// generated route for
/// [_i10.AffiliationDetailScreen]
class AffiliationDetailRoute
    extends _i74.PageRouteInfo<AffiliationDetailRouteArgs> {
  AffiliationDetailRoute({
    _i75.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         AffiliationDetailRoute.name,
         args: AffiliationDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'AffiliationDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AffiliationDetailRouteArgs>(
        orElse: () =>
            AffiliationDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i10.AffiliationDetailScreen(key: args.key, id: args.id);
    },
  );
}

class AffiliationDetailRouteArgs {
  const AffiliationDetailRouteArgs({this.key, required this.id});

  final _i75.Key? key;

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
/// [_i11.AffiliationScreen]
class AffiliationRoute extends _i74.PageRouteInfo<void> {
  const AffiliationRoute({List<_i74.PageRouteInfo>? children})
    : super(AffiliationRoute.name, initialChildren: children);

  static const String name = 'AffiliationRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i11.AffiliationScreen();
    },
  );
}

/// generated route for
/// [_i12.AiConsoleScreen]
class AiConsoleRoute extends _i74.PageRouteInfo<void> {
  const AiConsoleRoute({List<_i74.PageRouteInfo>? children})
    : super(AiConsoleRoute.name, initialChildren: children);

  static const String name = 'AiConsoleRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i12.AiConsoleScreen();
    },
  );
}

/// generated route for
/// [_i13.ArticleComposeScreen]
class ArticleComposeRoute extends _i74.PageRouteInfo<ArticleComposeRouteArgs> {
  ArticleComposeRoute({
    _i75.Key? key,
    _i76.SnPost? originalPost,
    _i77.PostComposeInitialState? initialState,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleComposeRouteArgs>(
        orElse: () => const ArticleComposeRouteArgs(),
      );
      return _i13.ArticleComposeScreen(
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

  final _i75.Key? key;

  final _i76.SnPost? originalPost;

  final _i77.PostComposeInitialState? initialState;

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
/// [_i13.ArticleEditScreen]
class ArticleEditRoute extends _i74.PageRouteInfo<ArticleEditRouteArgs> {
  ArticleEditRoute({
    _i75.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         ArticleEditRoute.name,
         args: ArticleEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ArticleEditRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArticleEditRouteArgs>(
        orElse: () => ArticleEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i13.ArticleEditScreen(key: args.key, id: args.id);
    },
  );
}

class ArticleEditRouteArgs {
  const ArticleEditRouteArgs({this.key, required this.id});

  final _i75.Key? key;

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
/// [_i14.AuthorizeScreen]
class AuthorizeRoute extends _i74.PageRouteInfo<AuthorizeRouteArgs> {
  AuthorizeRoute({
    _i75.Key? key,
    String? clientId,
    String? redirectUri,
    String? scope,
    String? state,
    String? responseType,
    String? codeChallenge,
    String? codeChallengeMethod,
    String? userCode,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         AuthorizeRoute.name,
         args: AuthorizeRouteArgs(
           key: key,
           clientId: clientId,
           redirectUri: redirectUri,
           scope: scope,
           state: state,
           responseType: responseType,
           codeChallenge: codeChallenge,
           codeChallengeMethod: codeChallengeMethod,
           userCode: userCode,
         ),
         initialChildren: children,
       );

  static const String name = 'AuthorizeRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthorizeRouteArgs>(
        orElse: () => const AuthorizeRouteArgs(),
      );
      return _i14.AuthorizeScreen(
        key: args.key,
        clientId: args.clientId,
        redirectUri: args.redirectUri,
        scope: args.scope,
        state: args.state,
        responseType: args.responseType,
        codeChallenge: args.codeChallenge,
        codeChallengeMethod: args.codeChallengeMethod,
        userCode: args.userCode,
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
    this.codeChallenge,
    this.codeChallengeMethod,
    this.userCode,
  });

  final _i75.Key? key;

  final String? clientId;

  final String? redirectUri;

  final String? scope;

  final String? state;

  final String? responseType;

  final String? codeChallenge;

  final String? codeChallengeMethod;

  final String? userCode;

  @override
  String toString() {
    return 'AuthorizeRouteArgs{key: $key, clientId: $clientId, redirectUri: $redirectUri, scope: $scope, state: $state, responseType: $responseType, codeChallenge: $codeChallenge, codeChallengeMethod: $codeChallengeMethod, userCode: $userCode}';
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
        responseType == other.responseType &&
        codeChallenge == other.codeChallenge &&
        codeChallengeMethod == other.codeChallengeMethod &&
        userCode == other.userCode;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      clientId.hashCode ^
      redirectUri.hashCode ^
      scope.hashCode ^
      state.hashCode ^
      responseType.hashCode ^
      codeChallenge.hashCode ^
      codeChallengeMethod.hashCode ^
      userCode.hashCode;
}

/// generated route for
/// [_i15.BlogComposeScreen]
class BlogComposeRoute extends _i74.PageRouteInfo<BlogComposeRouteArgs> {
  BlogComposeRoute({
    _i75.Key? key,
    _i76.SnPost? originalPost,
    _i77.PostComposeInitialState? initialState,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BlogComposeRouteArgs>(
        orElse: () => const BlogComposeRouteArgs(),
      );
      return _i15.BlogComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
        initialState: args.initialState,
      );
    },
  );
}

class BlogComposeRouteArgs {
  const BlogComposeRouteArgs({this.key, this.originalPost, this.initialState});

  final _i75.Key? key;

  final _i76.SnPost? originalPost;

  final _i77.PostComposeInitialState? initialState;

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
/// [_i15.BlogEditScreen]
class BlogEditRoute extends _i74.PageRouteInfo<BlogEditRouteArgs> {
  BlogEditRoute({
    _i75.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         BlogEditRoute.name,
         args: BlogEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'BlogEditRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BlogEditRouteArgs>(
        orElse: () => BlogEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i15.BlogEditScreen(key: args.key, id: args.id);
    },
  );
}

class BlogEditRouteArgs {
  const BlogEditRouteArgs({this.key, required this.id});

  final _i75.Key? key;

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
/// [_i16.BookmarksScreen]
class BookmarksRoute extends _i74.PageRouteInfo<void> {
  const BookmarksRoute({List<_i74.PageRouteInfo>? children})
    : super(BookmarksRoute.name, initialChildren: children);

  static const String name = 'BookmarksRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i16.BookmarksScreen();
    },
  );
}

/// generated route for
/// [_i17.CalendarEventDetailScreen]
class CalendarEventDetailRoute
    extends _i74.PageRouteInfo<CalendarEventDetailRouteArgs> {
  CalendarEventDetailRoute({
    _i75.Key? key,
    required String username,
    required String eventId,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CalendarEventDetailRouteArgs>(
        orElse: () => CalendarEventDetailRouteArgs(
          username: pathParams.getString('name'),
          eventId: pathParams.getString('id'),
        ),
      );
      return _i17.CalendarEventDetailScreen(
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

  final _i75.Key? key;

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
/// [_i18.CallScreen]
class CallRoute extends _i74.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i75.Key? key,
    required _i76.SnChatRoom room,
    bool cameraEnabled = false,
    bool microphoneEnabled = true,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(
           key: key,
           room: room,
           cameraEnabled: cameraEnabled,
           microphoneEnabled: microphoneEnabled,
         ),
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CallRouteArgs>();
      return _i18.CallScreen(
        key: args.key,
        room: args.room,
        cameraEnabled: args.cameraEnabled,
        microphoneEnabled: args.microphoneEnabled,
      );
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({
    this.key,
    required this.room,
    this.cameraEnabled = false,
    this.microphoneEnabled = true,
  });

  final _i75.Key? key;

  final _i76.SnChatRoom room;

  final bool cameraEnabled;

  final bool microphoneEnabled;

  @override
  String toString() {
    return 'CallRouteArgs{key: $key, room: $room, cameraEnabled: $cameraEnabled, microphoneEnabled: $microphoneEnabled}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallRouteArgs) return false;
    return key == other.key &&
        room == other.room &&
        cameraEnabled == other.cameraEnabled &&
        microphoneEnabled == other.microphoneEnabled;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      room.hashCode ^
      cameraEnabled.hashCode ^
      microphoneEnabled.hashCode;
}

/// generated route for
/// [_i19.CaptchaScreen]
class CaptchaRoute extends _i74.PageRouteInfo<void> {
  const CaptchaRoute({List<_i74.PageRouteInfo>? children})
    : super(CaptchaRoute.name, initialChildren: children);

  static const String name = 'CaptchaRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i19.CaptchaScreen();
    },
  );
}

/// generated route for
/// [_i20.CfIpSpeedTestScreen]
class CfIpSpeedTestRoute extends _i74.PageRouteInfo<void> {
  const CfIpSpeedTestRoute({List<_i74.PageRouteInfo>? children})
    : super(CfIpSpeedTestRoute.name, initialChildren: children);

  static const String name = 'CfIpSpeedTestRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i20.CfIpSpeedTestScreen();
    },
  );
}

/// generated route for
/// [_i21.ChatDetailScreen]
class ChatDetailRoute extends _i74.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i75.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => ChatDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i21.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i75.Key? key;

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
/// [_i22.ChatListScreen]
class ChatListRoute extends _i74.PageRouteInfo<void> {
  const ChatListRoute({List<_i74.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i22.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i23.ChatRoomScreen]
class ChatRoomRoute extends _i74.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i78.Key? key,
    required String id,
    String? initialMessageId,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(
           key: key,
           id: id,
           initialMessageId: initialMessageId,
         ),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRoomRouteArgs>(
        orElse: () => ChatRoomRouteArgs(id: pathParams.getString('id')),
      );
      return _i23.ChatRoomScreen(
        key: args.key,
        id: args.id,
        initialMessageId: args.initialMessageId,
      );
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id, this.initialMessageId});

  final _i78.Key? key;

  final String id;

  final String? initialMessageId;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, id: $id, initialMessageId: $initialMessageId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRoomRouteArgs) return false;
    return key == other.key &&
        id == other.id &&
        initialMessageId == other.initialMessageId;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode ^ initialMessageId.hashCode;
}

/// generated route for
/// [_i24.ChatRoomStorageScreen]
class ChatRoomStorageRoute extends _i74.PageRouteInfo<void> {
  const ChatRoomStorageRoute({List<_i74.PageRouteInfo>? children})
    : super(ChatRoomStorageRoute.name, initialChildren: children);

  static const String name = 'ChatRoomStorageRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i24.ChatRoomStorageScreen();
    },
  );
}

/// generated route for
/// [_i22.ChatScreen]
class ChatRoute extends _i74.PageRouteInfo<void> {
  const ChatRoute({List<_i74.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i22.ChatScreen();
    },
  );
}

/// generated route for
/// [_i25.CreateAccountScreen]
class CreateAccountRoute extends _i74.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i74.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i25.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i26.CreatorDomainManageScreen]
class CreatorDomainManageRoute
    extends _i74.PageRouteInfo<CreatorDomainManageRouteArgs> {
  CreatorDomainManageRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorDomainManageRoute.name,
         args: CreatorDomainManageRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorDomainManageRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorDomainManageRouteArgs>(
        orElse: () => CreatorDomainManageRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i26.CreatorDomainManageScreen(
        key: args.key,
        pubName: args.pubName,
      );
    },
  );
}

class CreatorDomainManageRouteArgs {
  const CreatorDomainManageRouteArgs({this.key, required this.pubName});

  final _i75.Key? key;

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
/// [_i27.CreatorHubListScreen]
class CreatorHubListRoute extends _i74.PageRouteInfo<void> {
  const CreatorHubListRoute({List<_i74.PageRouteInfo>? children})
    : super(CreatorHubListRoute.name, initialChildren: children);

  static const String name = 'CreatorHubListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i27.CreatorHubListScreen();
    },
  );
}

/// generated route for
/// [_i27.CreatorHubScreen]
class CreatorHubRoute extends _i74.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i74.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i27.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i28.CreatorPostCollectionsScreen]
class CreatorPostCollectionsRoute
    extends _i74.PageRouteInfo<CreatorPostCollectionsRouteArgs> {
  CreatorPostCollectionsRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorPostCollectionsRoute.name,
         args: CreatorPostCollectionsRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostCollectionsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i75.Key? key;

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
    extends _i74.PageRouteInfo<CreatorPostListRouteArgs> {
  CreatorPostListRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorPostListRoute.name,
         args: CreatorPostListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorPostListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i75.Key? key;

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
    extends _i74.PageRouteInfo<CreatorStickerListRouteArgs> {
  CreatorStickerListRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorStickerListRoute.name,
         args: CreatorStickerListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorStickerListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i75.Key? key;

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
    extends _i74.PageRouteInfo<CreatorStickerPackDetailRouteArgs> {
  CreatorStickerPackDetailRoute({
    _i75.Key? key,
    required String packId,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i75.Key? key;

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
/// [_i32.CreatorSurveyListScreen]
class CreatorSurveyListRoute
    extends _i74.PageRouteInfo<CreatorSurveyListRouteArgs> {
  CreatorSurveyListRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorSurveyListRoute.name,
         args: CreatorSurveyListRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorSurveyListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorSurveyListRouteArgs>(
        orElse: () => CreatorSurveyListRouteArgs(
          pubName: pathParams.getString('pubName'),
        ),
      );
      return _i32.CreatorSurveyListScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorSurveyListRouteArgs {
  const CreatorSurveyListRouteArgs({this.key, required this.pubName});

  final _i75.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorSurveyListRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorSurveyListRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i33.CreatorTagManageScreen]
class CreatorTagManageRoute
    extends _i74.PageRouteInfo<CreatorTagManageRouteArgs> {
  CreatorTagManageRoute({
    _i75.Key? key,
    required String pubName,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         CreatorTagManageRoute.name,
         args: CreatorTagManageRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'pubName': pubName},
         initialChildren: children,
       );

  static const String name = 'CreatorTagManageRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CreatorTagManageRouteArgs>(
        orElse: () =>
            CreatorTagManageRouteArgs(pubName: pathParams.getString('pubName')),
      );
      return _i33.CreatorTagManageScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class CreatorTagManageRouteArgs {
  const CreatorTagManageRouteArgs({this.key, required this.pubName});

  final _i75.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'CreatorTagManageRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorTagManageRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i34.DashboardScreen]
class DashboardRoute extends _i74.PageRouteInfo<void> {
  const DashboardRoute({List<_i74.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i34.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i35.EditChatScreen]
class EditChatRoute extends _i74.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i75.Key? key, String? id, List<_i74.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => const EditChatRouteArgs(),
      );
      return _i35.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i75.Key? key;

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
/// [_i36.EditPublisherScreen]
class EditPublisherRoute extends _i74.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i75.Key? key,
    String? name,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => const EditPublisherRouteArgs(),
      );
      return _i36.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i75.Key? key;

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
/// [_i37.EventHubScreen]
class EventHubRoute extends _i74.PageRouteInfo<EventHubRouteArgs> {
  EventHubRoute({
    _i75.Key? key,
    required String name,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         EventHubRoute.name,
         args: EventHubRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'EventHubRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EventHubRouteArgs>(
        orElse: () => EventHubRouteArgs(name: pathParams.getString('name')),
      );
      return _i37.EventHubScreen(key: args.key, name: args.name);
    },
  );
}

class EventHubRouteArgs {
  const EventHubRouteArgs({this.key, required this.name});

  final _i75.Key? key;

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
/// [_i38.ExploreScreen]
class ExploreRoute extends _i74.PageRouteInfo<void> {
  const ExploreRoute({List<_i74.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i38.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i39.FediverseActorProfileScreen]
class FediverseActorProfileRoute
    extends _i74.PageRouteInfo<FediverseActorProfileRouteArgs> {
  FediverseActorProfileRoute({
    _i75.Key? key,
    required String id,
    String? fullHandle,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FediverseActorProfileRouteArgs>(
        orElse: () =>
            FediverseActorProfileRouteArgs(id: pathParams.getString('id')),
      );
      return _i39.FediverseActorProfileScreen(
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

  final _i75.Key? key;

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
/// [_i40.FileDetailScreen]
class FileDetailRoute extends _i74.PageRouteInfo<FileDetailRouteArgs> {
  FileDetailRoute({
    _i78.Key? key,
    required String id,
    String? heroTag,
    _i76.SnPost? sourcePost,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i78.Key? key;

  final String id;

  final String? heroTag;

  final _i76.SnPost? sourcePost;

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
class FileListRoute extends _i74.PageRouteInfo<void> {
  const FileListRoute({List<_i74.PageRouteInfo>? children})
    : super(FileListRoute.name, initialChildren: children);

  static const String name = 'FileListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i41.FileListScreen();
    },
  );
}

/// generated route for
/// [_i42.LevelingScreen]
class LevelingRoute extends _i74.PageRouteInfo<void> {
  const LevelingRoute({List<_i74.PageRouteInfo>? children})
    : super(LevelingRoute.name, initialChildren: children);

  static const String name = 'LevelingRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i42.LevelingScreen();
    },
  );
}

/// generated route for
/// [_i43.LoginScreen]
class LoginRoute extends _i74.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i75.Key? key,
    String? redirectUri,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, redirectUri: redirectUri),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i43.LoginScreen(key: args.key, redirectUri: args.redirectUri);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.redirectUri});

  final _i75.Key? key;

  final String? redirectUri;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, redirectUri: $redirectUri}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && redirectUri == other.redirectUri;
  }

  @override
  int get hashCode => key.hashCode ^ redirectUri.hashCode;
}

/// generated route for
/// [_i44.MeetDetailScreen]
class MeetDetailRoute extends _i74.PageRouteInfo<MeetDetailRouteArgs> {
  MeetDetailRoute({
    _i78.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         MeetDetailRoute.name,
         args: MeetDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MeetDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
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

  final _i78.Key? key;

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
class MeetRoute extends _i74.PageRouteInfo<void> {
  const MeetRoute({List<_i74.PageRouteInfo>? children})
    : super(MeetRoute.name, initialChildren: children);

  static const String name = 'MeetRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i44.MeetScreen();
    },
  );
}

/// generated route for
/// [_i35.NewChatScreen]
class NewChatRoute extends _i74.PageRouteInfo<void> {
  const NewChatRoute({List<_i74.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i35.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i36.NewPublisherScreen]
class NewPublisherRoute extends _i74.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i74.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i36.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i45.NotFoundScreen]
class NotFoundRoute extends _i74.PageRouteInfo<void> {
  const NotFoundRoute({List<_i74.PageRouteInfo>? children})
    : super(NotFoundRoute.name, initialChildren: children);

  static const String name = 'NotFoundRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i45.NotFoundScreen();
    },
  );
}

/// generated route for
/// [_i7.PhysicalPassportScreen]
class PhysicalPassportRoute extends _i74.PageRouteInfo<void> {
  const PhysicalPassportRoute({List<_i74.PageRouteInfo>? children})
    : super(PhysicalPassportRoute.name, initialChildren: children);

  static const String name = 'PhysicalPassportRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i7.PhysicalPassportScreen();
    },
  );
}

/// generated route for
/// [_i46.PluginEditorScreen]
class PluginEditorRoute extends _i74.PageRouteInfo<void> {
  const PluginEditorRoute({List<_i74.PageRouteInfo>? children})
    : super(PluginEditorRoute.name, initialChildren: children);

  static const String name = 'PluginEditorRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i46.PluginEditorScreen();
    },
  );
}

/// generated route for
/// [_i47.PluginManagerScreen]
class PluginManagerRoute extends _i74.PageRouteInfo<void> {
  const PluginManagerRoute({List<_i74.PageRouteInfo>? children})
    : super(PluginManagerRoute.name, initialChildren: children);

  static const String name = 'PluginManagerRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i47.PluginManagerScreen();
    },
  );
}

/// generated route for
/// [_i48.PostCategoriesListScreen]
class PostCategoriesListRoute extends _i74.PageRouteInfo<void> {
  const PostCategoriesListRoute({List<_i74.PageRouteInfo>? children})
    : super(PostCategoriesListRoute.name, initialChildren: children);

  static const String name = 'PostCategoriesListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i48.PostCategoriesListScreen();
    },
  );
}

/// generated route for
/// [_i49.PostCategoryDetailScreen]
class PostCategoryDetailRoute
    extends _i74.PageRouteInfo<PostCategoryDetailRouteArgs> {
  PostCategoryDetailRoute({
    _i75.Key? key,
    required String slug,
    required bool isCategory,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostCategoryDetailRouteArgs>();
      return _i49.PostCategoryDetailScreen(
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

  final _i75.Key? key;

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
/// [_i50.PostDetailScreen]
class PostDetailRoute extends _i74.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i78.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i50.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i78.Key? key;

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
/// [_i51.PostShuffleScreen]
class PostShuffleRoute extends _i74.PageRouteInfo<void> {
  const PostShuffleRoute({List<_i74.PageRouteInfo>? children})
    : super(PostShuffleRoute.name, initialChildren: children);

  static const String name = 'PostShuffleRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i51.PostShuffleScreen();
    },
  );
}

/// generated route for
/// [_i52.ProgressScreen]
class ProgressRoute extends _i74.PageRouteInfo<ProgressRouteArgs> {
  ProgressRoute({
    _i75.Key? key,
    int initialTab = 0,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         ProgressRoute.name,
         args: ProgressRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'ProgressRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProgressRouteArgs>(
        orElse: () => const ProgressRouteArgs(),
      );
      return _i52.ProgressScreen(key: args.key, initialTab: args.initialTab);
    },
  );
}

class ProgressRouteArgs {
  const ProgressRouteArgs({this.key, this.initialTab = 0});

  final _i75.Key? key;

  final int initialTab;

  @override
  String toString() {
    return 'ProgressRouteArgs{key: $key, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgressRouteArgs) return false;
    return key == other.key && initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [_i53.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i74.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i75.Key? key,
    required String name,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherProfileRouteArgs>(
        orElse: () =>
            PublisherProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i53.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i75.Key? key;

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
/// [_i54.PunishmentsScreen]
class PunishmentsRoute extends _i74.PageRouteInfo<void> {
  const PunishmentsRoute({List<_i74.PageRouteInfo>? children})
    : super(PunishmentsRoute.name, initialChildren: children);

  static const String name = 'PunishmentsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i54.PunishmentsScreen();
    },
  );
}

/// generated route for
/// [_i55.RealmDetailScreen]
class RealmDetailRoute extends _i74.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i75.Key? key,
    required String slug,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i55.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i75.Key? key;

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
/// [_i56.RealmListScreen]
class RealmListRoute extends _i74.PageRouteInfo<void> {
  const RealmListRoute({List<_i74.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i56.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i57.RelationshipScreen]
class RelationshipRoute extends _i74.PageRouteInfo<void> {
  const RelationshipRoute({List<_i74.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i57.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i58.SearchAllMessagesScreen]
class SearchAllMessagesRoute extends _i74.PageRouteInfo<void> {
  const SearchAllMessagesRoute({List<_i74.PageRouteInfo>? children})
    : super(SearchAllMessagesRoute.name, initialChildren: children);

  static const String name = 'SearchAllMessagesRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i58.SearchAllMessagesScreen();
    },
  );
}

/// generated route for
/// [_i58.SearchMessagesScreen]
class SearchMessagesRoute extends _i74.PageRouteInfo<SearchMessagesRouteArgs> {
  SearchMessagesRoute({
    _i75.Key? key,
    required String roomId,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         SearchMessagesRoute.name,
         args: SearchMessagesRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'SearchMessagesRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SearchMessagesRouteArgs>(
        orElse: () =>
            SearchMessagesRouteArgs(roomId: pathParams.getString('id')),
      );
      return _i58.SearchMessagesScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class SearchMessagesRouteArgs {
  const SearchMessagesRouteArgs({this.key, required this.roomId});

  final _i75.Key? key;

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
/// [_i59.SettingsScreen]
class SettingsRoute extends _i74.PageRouteInfo<void> {
  const SettingsRoute({List<_i74.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i59.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i60.StickerMarketplacePackDetailScreen]
class StickerMarketplacePackDetailRoute
    extends _i74.PageRouteInfo<StickerMarketplacePackDetailRouteArgs> {
  StickerMarketplacePackDetailRoute({
    _i75.Key? key,
    required String id,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         StickerMarketplacePackDetailRoute.name,
         args: StickerMarketplacePackDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'StickerMarketplacePackDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickerMarketplacePackDetailRouteArgs>(
        orElse: () => StickerMarketplacePackDetailRouteArgs(
          id: pathParams.getString('id'),
        ),
      );
      return _i60.StickerMarketplacePackDetailScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class StickerMarketplacePackDetailRouteArgs {
  const StickerMarketplacePackDetailRouteArgs({this.key, required this.id});

  final _i75.Key? key;

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
/// [_i61.StickerMarketplaceScreen]
class StickerMarketplaceRoute extends _i74.PageRouteInfo<void> {
  const StickerMarketplaceRoute({List<_i74.PageRouteInfo>? children})
    : super(StickerMarketplaceRoute.name, initialChildren: children);

  static const String name = 'StickerMarketplaceRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i61.StickerMarketplaceScreen();
    },
  );
}

/// generated route for
/// [_i62.StoreScreen]
class StoreRoute extends _i74.PageRouteInfo<void> {
  const StoreRoute({List<_i74.PageRouteInfo>? children})
    : super(StoreRoute.name, initialChildren: children);

  static const String name = 'StoreRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i62.StoreScreen();
    },
  );
}

/// generated route for
/// [_i63.SurveyEditorScreen]
class SurveyEditorRoute extends _i74.PageRouteInfo<SurveyEditorRouteArgs> {
  SurveyEditorRoute({
    _i78.Key? key,
    String? initialSurveyId,
    String? initialPublisher,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         SurveyEditorRoute.name,
         args: SurveyEditorRouteArgs(
           key: key,
           initialSurveyId: initialSurveyId,
           initialPublisher: initialPublisher,
         ),
         initialChildren: children,
       );

  static const String name = 'SurveyEditorRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SurveyEditorRouteArgs>(
        orElse: () => const SurveyEditorRouteArgs(),
      );
      return _i63.SurveyEditorScreen(
        key: args.key,
        initialSurveyId: args.initialSurveyId,
        initialPublisher: args.initialPublisher,
      );
    },
  );
}

class SurveyEditorRouteArgs {
  const SurveyEditorRouteArgs({
    this.key,
    this.initialSurveyId,
    this.initialPublisher,
  });

  final _i78.Key? key;

  final String? initialSurveyId;

  final String? initialPublisher;

  @override
  String toString() {
    return 'SurveyEditorRouteArgs{key: $key, initialSurveyId: $initialSurveyId, initialPublisher: $initialPublisher}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SurveyEditorRouteArgs) return false;
    return key == other.key &&
        initialSurveyId == other.initialSurveyId &&
        initialPublisher == other.initialPublisher;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialSurveyId.hashCode ^ initialPublisher.hashCode;
}

/// generated route for
/// [_i64.SurveyFeedbackPage]
class SurveyFeedbackRoute extends _i74.PageRouteInfo<SurveyFeedbackRouteArgs> {
  SurveyFeedbackRoute({
    _i75.Key? key,
    required String surveyId,
    String? title,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         SurveyFeedbackRoute.name,
         args: SurveyFeedbackRouteArgs(
           key: key,
           surveyId: surveyId,
           title: title,
         ),
         rawPathParams: {'id': surveyId},
         initialChildren: children,
       );

  static const String name = 'SurveyFeedbackRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SurveyFeedbackRouteArgs>(
        orElse: () =>
            SurveyFeedbackRouteArgs(surveyId: pathParams.getString('id')),
      );
      return _i64.SurveyFeedbackPage(
        key: args.key,
        surveyId: args.surveyId,
        title: args.title,
      );
    },
  );
}

class SurveyFeedbackRouteArgs {
  const SurveyFeedbackRouteArgs({this.key, required this.surveyId, this.title});

  final _i75.Key? key;

  final String surveyId;

  final String? title;

  @override
  String toString() {
    return 'SurveyFeedbackRouteArgs{key: $key, surveyId: $surveyId, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SurveyFeedbackRouteArgs) return false;
    return key == other.key &&
        surveyId == other.surveyId &&
        title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ surveyId.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i65.SurveySubmitPage]
class SurveySubmitRoute extends _i74.PageRouteInfo<SurveySubmitRouteArgs> {
  SurveySubmitRoute({
    _i75.Key? key,
    required String surveyId,
    bool isReadonly = false,
    bool isInitiallyExpanded = true,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         SurveySubmitRoute.name,
         args: SurveySubmitRouteArgs(
           key: key,
           surveyId: surveyId,
           isReadonly: isReadonly,
           isInitiallyExpanded: isInitiallyExpanded,
         ),
         rawPathParams: {'id': surveyId},
         initialChildren: children,
       );

  static const String name = 'SurveySubmitRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SurveySubmitRouteArgs>(
        orElse: () =>
            SurveySubmitRouteArgs(surveyId: pathParams.getString('id')),
      );
      return _i65.SurveySubmitPage(
        key: args.key,
        surveyId: args.surveyId,
        isReadonly: args.isReadonly,
        isInitiallyExpanded: args.isInitiallyExpanded,
      );
    },
  );
}

class SurveySubmitRouteArgs {
  const SurveySubmitRouteArgs({
    this.key,
    required this.surveyId,
    this.isReadonly = false,
    this.isInitiallyExpanded = true,
  });

  final _i75.Key? key;

  final String surveyId;

  final bool isReadonly;

  final bool isInitiallyExpanded;

  @override
  String toString() {
    return 'SurveySubmitRouteArgs{key: $key, surveyId: $surveyId, isReadonly: $isReadonly, isInitiallyExpanded: $isInitiallyExpanded}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SurveySubmitRouteArgs) return false;
    return key == other.key &&
        surveyId == other.surveyId &&
        isReadonly == other.isReadonly &&
        isInitiallyExpanded == other.isInitiallyExpanded;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      surveyId.hashCode ^
      isReadonly.hashCode ^
      isInitiallyExpanded.hashCode;
}

/// generated route for
/// [_i66.TabsScreen]
class TabsRoute extends _i74.PageRouteInfo<void> {
  const TabsRoute({List<_i74.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i66.TabsScreen();
    },
  );
}

/// generated route for
/// [_i67.TicketDetailScreen]
class TicketDetailRoute extends _i74.PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    _i75.Key? key,
    required String ticketId,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(key: key, ticketId: ticketId),
         rawPathParams: {'ticketId': ticketId},
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TicketDetailRouteArgs>(
        orElse: () =>
            TicketDetailRouteArgs(ticketId: pathParams.getString('ticketId')),
      );
      return _i67.TicketDetailScreen(key: args.key, ticketId: args.ticketId);
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticketId});

  final _i75.Key? key;

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
/// [_i68.TicketListScreen]
class TicketListRoute extends _i74.PageRouteInfo<void> {
  const TicketListRoute({List<_i74.PageRouteInfo>? children})
    : super(TicketListRoute.name, initialChildren: children);

  static const String name = 'TicketListRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i68.TicketListScreen();
    },
  );
}

/// generated route for
/// [_i69.TransactionDetailScreen]
class TransactionDetailRoute
    extends _i74.PageRouteInfo<TransactionDetailRouteArgs> {
  TransactionDetailRoute({
    _i75.Key? key,
    required String transactionId,
    String? currentWalletId,
    List<_i74.PageRouteInfo>? children,
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

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TransactionDetailRouteArgs>(
        orElse: () => TransactionDetailRouteArgs(
          transactionId: pathParams.getString('id'),
        ),
      );
      return _i69.TransactionDetailScreen(
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

  final _i75.Key? key;

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
/// [_i70.UniversalSearchScreen]
class UniversalSearchRoute
    extends _i74.PageRouteInfo<UniversalSearchRouteArgs> {
  UniversalSearchRoute({
    _i75.Key? key,
    _i70.SearchTab initialTab = _i70.SearchTab.posts,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         UniversalSearchRoute.name,
         args: UniversalSearchRouteArgs(key: key, initialTab: initialTab),
         initialChildren: children,
       );

  static const String name = 'UniversalSearchRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UniversalSearchRouteArgs>(
        orElse: () => const UniversalSearchRouteArgs(),
      );
      return _i70.UniversalSearchScreen(
        key: args.key,
        initialTab: args.initialTab,
      );
    },
  );
}

class UniversalSearchRouteArgs {
  const UniversalSearchRouteArgs({
    this.key,
    this.initialTab = _i70.SearchTab.posts,
  });

  final _i75.Key? key;

  final _i70.SearchTab initialTab;

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
/// [_i71.WalletOrderDetailScreen]
class WalletOrderDetailRoute
    extends _i74.PageRouteInfo<WalletOrderDetailRouteArgs> {
  WalletOrderDetailRoute({
    _i75.Key? key,
    required String orderId,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         WalletOrderDetailRoute.name,
         args: WalletOrderDetailRouteArgs(key: key, orderId: orderId),
         rawPathParams: {'id': orderId},
         initialChildren: children,
       );

  static const String name = 'WalletOrderDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WalletOrderDetailRouteArgs>(
        orElse: () =>
            WalletOrderDetailRouteArgs(orderId: pathParams.getString('id')),
      );
      return _i71.WalletOrderDetailScreen(key: args.key, orderId: args.orderId);
    },
  );
}

class WalletOrderDetailRouteArgs {
  const WalletOrderDetailRouteArgs({this.key, required this.orderId});

  final _i75.Key? key;

  final String orderId;

  @override
  String toString() {
    return 'WalletOrderDetailRouteArgs{key: $key, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalletOrderDetailRouteArgs) return false;
    return key == other.key && orderId == other.orderId;
  }

  @override
  int get hashCode => key.hashCode ^ orderId.hashCode;
}

/// generated route for
/// [_i72.WalletScreen]
class WalletRoute extends _i74.PageRouteInfo<void> {
  const WalletRoute({List<_i74.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i72.WalletScreen();
    },
  );
}

/// generated route for
/// [_i73.WorkspaceDetailScreen]
class WorkspaceDetailRoute
    extends _i74.PageRouteInfo<WorkspaceDetailRouteArgs> {
  WorkspaceDetailRoute({
    required String slug,
    _i75.Key? key,
    List<_i74.PageRouteInfo>? children,
  }) : super(
         WorkspaceDetailRoute.name,
         args: WorkspaceDetailRouteArgs(slug: slug, key: key),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'WorkspaceDetailRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WorkspaceDetailRouteArgs>(
        orElse: () =>
            WorkspaceDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i73.WorkspaceDetailScreen(slug: args.slug, key: args.key);
    },
  );
}

class WorkspaceDetailRouteArgs {
  const WorkspaceDetailRouteArgs({required this.slug, this.key});

  final String slug;

  final _i75.Key? key;

  @override
  String toString() {
    return 'WorkspaceDetailRouteArgs{slug: $slug, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkspaceDetailRouteArgs) return false;
    return slug == other.slug && key == other.key;
  }

  @override
  int get hashCode => slug.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i73.WorkspaceManagementScreen]
class WorkspaceManagementRoute extends _i74.PageRouteInfo<void> {
  const WorkspaceManagementRoute({List<_i74.PageRouteInfo>? children})
    : super(WorkspaceManagementRoute.name, initialChildren: children);

  static const String name = 'WorkspaceManagementRoute';

  static _i74.PageInfo page = _i74.PageInfo(
    name,
    builder: (data) {
      return const _i73.WorkspaceManagementScreen();
    },
  );
}
