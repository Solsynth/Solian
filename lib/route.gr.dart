// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i19;
import 'package:flutter/material.dart' as _i20;
import 'package:island/models/post.dart' as _i21;
import 'package:island/screens/account.dart' as _i2;
import 'package:island/screens/account/me.dart' as _i12;
import 'package:island/screens/account/me/event_calendar.dart' as _i11;
import 'package:island/screens/account/me/publishers.dart' as _i7;
import 'package:island/screens/account/me/update.dart' as _i18;
import 'package:island/screens/account/profile.dart' as _i1;
import 'package:island/screens/auth/create_account.dart' as _i6;
import 'package:island/screens/auth/login.dart' as _i10;
import 'package:island/screens/auth/tabs.dart' as _i17;
import 'package:island/screens/chat/chat.dart' as _i4;
import 'package:island/screens/chat/room.dart' as _i5;
import 'package:island/screens/chat/room_detail.dart' as _i3;
import 'package:island/screens/explore.dart' as _i9;
import 'package:island/screens/posts/compose.dart' as _i13;
import 'package:island/screens/posts/detail.dart' as _i14;
import 'package:island/screens/realm/detail.dart' as _i15;
import 'package:island/screens/realm/realms.dart' as _i8;
import 'package:island/screens/settings.dart' as _i16;

/// generated route for
/// [_i1.AccountProfileScreen]
class AccountProfileRoute extends _i19.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i20.Key? key,
    required String name,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AccountProfileRouteArgs>(
        orElse:
            () => AccountProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i1.AccountProfileScreen(key: args.key, name: args.name);
    },
  );
}

class AccountProfileRouteArgs {
  const AccountProfileRouteArgs({this.key, required this.name});

  final _i20.Key? key;

  final String name;

  @override
  String toString() {
    return 'AccountProfileRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i19.PageRouteInfo<void> {
  const AccountRoute({List<_i19.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountScreen();
    },
  );
}

/// generated route for
/// [_i3.ChatDetailScreen]
class ChatDetailRoute extends _i19.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i20.Key? key,
    required int id,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => ChatDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i3.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i20.Key? key;

  final int id;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i4.ChatListScreen]
class ChatListRoute extends _i19.PageRouteInfo<void> {
  const ChatListRoute({List<_i19.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i5.ChatRoomScreen]
class ChatRoomRoute extends _i19.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i20.Key? key,
    required int id,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRoomRouteArgs>(
        orElse: () => ChatRoomRouteArgs(id: pathParams.getInt('id')),
      );
      return _i5.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i20.Key? key;

  final int id;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i6.CreateAccountScreen]
class CreateAccountRoute extends _i19.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i19.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i6.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i4.EditChatScreen]
class EditChatRoute extends _i19.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i20.Key? key, int? id, List<_i19.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        rawPathParams: {'id': id},
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => EditChatRouteArgs(id: pathParams.optInt('id')),
      );
      return _i4.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i20.Key? key;

  final int? id;

  @override
  String toString() {
    return 'EditChatRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i7.EditPublisherScreen]
class EditPublisherRoute extends _i19.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i20.Key? key,
    String? name,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         rawPathParams: {'id': name},
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => EditPublisherRouteArgs(name: pathParams.optString('id')),
      );
      return _i7.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i20.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i8.EditRealmScreen]
class EditRealmRoute extends _i19.PageRouteInfo<EditRealmRouteArgs> {
  EditRealmRoute({
    _i20.Key? key,
    String? slug,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         EditRealmRoute.name,
         args: EditRealmRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'EditRealmRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditRealmRouteArgs>(
        orElse: () => EditRealmRouteArgs(slug: pathParams.optString('slug')),
      );
      return _i8.EditRealmScreen(key: args.key, slug: args.slug);
    },
  );
}

class EditRealmRouteArgs {
  const EditRealmRouteArgs({this.key, this.slug});

  final _i20.Key? key;

  final String? slug;

  @override
  String toString() {
    return 'EditRealmRouteArgs{key: $key, slug: $slug}';
  }
}

/// generated route for
/// [_i9.ExploreScreen]
class ExploreRoute extends _i19.PageRouteInfo<void> {
  const ExploreRoute({List<_i19.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i9.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i10.LoginScreen]
class LoginRoute extends _i19.PageRouteInfo<void> {
  const LoginRoute({List<_i19.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i10.LoginScreen();
    },
  );
}

/// generated route for
/// [_i7.ManagedPublisherScreen]
class ManagedPublisherRoute extends _i19.PageRouteInfo<void> {
  const ManagedPublisherRoute({List<_i19.PageRouteInfo>? children})
    : super(ManagedPublisherRoute.name, initialChildren: children);

  static const String name = 'ManagedPublisherRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i7.ManagedPublisherScreen();
    },
  );
}

/// generated route for
/// [_i11.MyselfEventCalendarScreen]
class MyselfEventCalendarRoute extends _i19.PageRouteInfo<void> {
  const MyselfEventCalendarRoute({List<_i19.PageRouteInfo>? children})
    : super(MyselfEventCalendarRoute.name, initialChildren: children);

  static const String name = 'MyselfEventCalendarRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i11.MyselfEventCalendarScreen();
    },
  );
}

/// generated route for
/// [_i12.MyselfProfileScreen]
class MyselfProfileRoute extends _i19.PageRouteInfo<void> {
  const MyselfProfileRoute({List<_i19.PageRouteInfo>? children})
    : super(MyselfProfileRoute.name, initialChildren: children);

  static const String name = 'MyselfProfileRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i12.MyselfProfileScreen();
    },
  );
}

/// generated route for
/// [_i4.NewChatScreen]
class NewChatRoute extends _i19.PageRouteInfo<void> {
  const NewChatRoute({List<_i19.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i4.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i7.NewPublisherScreen]
class NewPublisherRoute extends _i19.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i19.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i7.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i8.NewRealmScreen]
class NewRealmRoute extends _i19.PageRouteInfo<void> {
  const NewRealmRoute({List<_i19.PageRouteInfo>? children})
    : super(NewRealmRoute.name, initialChildren: children);

  static const String name = 'NewRealmRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i8.NewRealmScreen();
    },
  );
}

/// generated route for
/// [_i13.PostComposeScreen]
class PostComposeRoute extends _i19.PageRouteInfo<PostComposeRouteArgs> {
  PostComposeRoute({
    _i20.Key? key,
    _i21.SnPost? originalPost,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         PostComposeRoute.name,
         args: PostComposeRouteArgs(key: key, originalPost: originalPost),
         initialChildren: children,
       );

  static const String name = 'PostComposeRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostComposeRouteArgs>(
        orElse: () => const PostComposeRouteArgs(),
      );
      return _i13.PostComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
      );
    },
  );
}

class PostComposeRouteArgs {
  const PostComposeRouteArgs({this.key, this.originalPost});

  final _i20.Key? key;

  final _i21.SnPost? originalPost;

  @override
  String toString() {
    return 'PostComposeRouteArgs{key: $key, originalPost: $originalPost}';
  }
}

/// generated route for
/// [_i14.PostDetailScreen]
class PostDetailRoute extends _i19.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i20.Key? key,
    required int id,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i14.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i20.Key? key;

  final int id;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i13.PostEditScreen]
class PostEditRoute extends _i19.PageRouteInfo<PostEditRouteArgs> {
  PostEditRoute({
    _i20.Key? key,
    required int id,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         PostEditRoute.name,
         args: PostEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostEditRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostEditRouteArgs>(
        orElse: () => PostEditRouteArgs(id: pathParams.getInt('id')),
      );
      return _i13.PostEditScreen(key: args.key, id: args.id);
    },
  );
}

class PostEditRouteArgs {
  const PostEditRouteArgs({this.key, required this.id});

  final _i20.Key? key;

  final int id;

  @override
  String toString() {
    return 'PostEditRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i15.RealmDetailScreen]
class RealmDetailRoute extends _i19.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i20.Key? key,
    required String slug,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i15.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i20.Key? key;

  final String slug;

  @override
  String toString() {
    return 'RealmDetailRouteArgs{key: $key, slug: $slug}';
  }
}

/// generated route for
/// [_i8.RealmListScreen]
class RealmListRoute extends _i19.PageRouteInfo<void> {
  const RealmListRoute({List<_i19.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i8.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i16.SettingsScreen]
class SettingsRoute extends _i19.PageRouteInfo<void> {
  const SettingsRoute({List<_i19.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i16.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i17.TabsScreen]
class TabsRoute extends _i19.PageRouteInfo<void> {
  const TabsRoute({List<_i19.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i17.TabsScreen();
    },
  );
}

/// generated route for
/// [_i18.UpdateProfileScreen]
class UpdateProfileRoute extends _i19.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i19.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i18.UpdateProfileScreen();
    },
  );
}
