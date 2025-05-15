// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i24;
import 'package:flutter/material.dart' as _i25;
import 'package:island/models/post.dart' as _i26;
import 'package:island/screens/account.dart' as _i2;
import 'package:island/screens/account/me.dart' as _i15;
import 'package:island/screens/account/me/event_calendar.dart' as _i14;
import 'package:island/screens/account/me/publishers.dart' as _i8;
import 'package:island/screens/account/me/update.dart' as _i22;
import 'package:island/screens/account/profile.dart' as _i1;
import 'package:island/screens/auth/create_account.dart' as _i6;
import 'package:island/screens/auth/login.dart' as _i13;
import 'package:island/screens/auth/tabs.dart' as _i21;
import 'package:island/screens/chat/chat.dart' as _i4;
import 'package:island/screens/chat/room.dart' as _i5;
import 'package:island/screens/chat/room_detail.dart' as _i3;
import 'package:island/screens/creators/hub.dart' as _i7;
import 'package:island/screens/creators/stickers/pack_detail.dart' as _i11;
import 'package:island/screens/creators/stickers/stickers.dart' as _i10;
import 'package:island/screens/explore.dart' as _i12;
import 'package:island/screens/posts/compose.dart' as _i16;
import 'package:island/screens/posts/detail.dart' as _i17;
import 'package:island/screens/posts/pub_profile.dart' as _i18;
import 'package:island/screens/realm/detail.dart' as _i19;
import 'package:island/screens/realm/realms.dart' as _i9;
import 'package:island/screens/settings.dart' as _i20;
import 'package:island/screens/wallet.dart' as _i23;

/// generated route for
/// [_i1.AccountProfileScreen]
class AccountProfileRoute extends _i24.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i25.Key? key,
    required String name,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
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

  final _i25.Key? key;

  final String name;

  @override
  String toString() {
    return 'AccountProfileRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i24.PageRouteInfo<void> {
  const AccountRoute({List<_i24.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountScreen();
    },
  );
}

/// generated route for
/// [_i3.ChatDetailScreen]
class ChatDetailRoute extends _i24.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i25.Key? key,
    required String id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => ChatDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i3.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i4.ChatListScreen]
class ChatListRoute extends _i24.PageRouteInfo<void> {
  const ChatListRoute({List<_i24.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChatListScreen();
    },
  );
}

/// generated route for
/// [_i5.ChatRoomScreen]
class ChatRoomRoute extends _i24.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i25.Key? key,
    required String id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRoomRouteArgs>(
        orElse: () => ChatRoomRouteArgs(id: pathParams.getString('id')),
      );
      return _i5.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i6.CreateAccountScreen]
class CreateAccountRoute extends _i24.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i24.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i6.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i7.CreatorHubScreen]
class CreatorHubRoute extends _i24.PageRouteInfo<void> {
  const CreatorHubRoute({List<_i24.PageRouteInfo>? children})
    : super(CreatorHubRoute.name, initialChildren: children);

  static const String name = 'CreatorHubRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i7.CreatorHubScreen();
    },
  );
}

/// generated route for
/// [_i4.EditChatScreen]
class EditChatRoute extends _i24.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i25.Key? key, String? id, List<_i24.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        rawPathParams: {'id': id},
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => EditChatRouteArgs(id: pathParams.optString('id')),
      );
      return _i4.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i25.Key? key;

  final String? id;

  @override
  String toString() {
    return 'EditChatRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i8.EditPublisherScreen]
class EditPublisherRoute extends _i24.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i25.Key? key,
    String? name,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         rawPathParams: {'id': name},
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => EditPublisherRouteArgs(name: pathParams.optString('id')),
      );
      return _i8.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i25.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i9.EditRealmScreen]
class EditRealmRoute extends _i24.PageRouteInfo<EditRealmRouteArgs> {
  EditRealmRoute({
    _i25.Key? key,
    String? slug,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         EditRealmRoute.name,
         args: EditRealmRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'EditRealmRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditRealmRouteArgs>(
        orElse: () => EditRealmRouteArgs(slug: pathParams.optString('slug')),
      );
      return _i9.EditRealmScreen(key: args.key, slug: args.slug);
    },
  );
}

class EditRealmRouteArgs {
  const EditRealmRouteArgs({this.key, this.slug});

  final _i25.Key? key;

  final String? slug;

  @override
  String toString() {
    return 'EditRealmRouteArgs{key: $key, slug: $slug}';
  }
}

/// generated route for
/// [_i10.EditStickerPacksScreen]
class EditStickerPacksRoute
    extends _i24.PageRouteInfo<EditStickerPacksRouteArgs> {
  EditStickerPacksRoute({
    _i25.Key? key,
    required String pubName,
    String? packId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         EditStickerPacksRoute.name,
         args: EditStickerPacksRouteArgs(
           key: key,
           pubName: pubName,
           packId: packId,
         ),
         rawPathParams: {'name': pubName, 'packId': packId},
         initialChildren: children,
       );

  static const String name = 'EditStickerPacksRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditStickerPacksRouteArgs>(
        orElse:
            () => EditStickerPacksRouteArgs(
              pubName: pathParams.getString('name'),
              packId: pathParams.optString('packId'),
            ),
      );
      return _i10.EditStickerPacksScreen(
        key: args.key,
        pubName: args.pubName,
        packId: args.packId,
      );
    },
  );
}

class EditStickerPacksRouteArgs {
  const EditStickerPacksRouteArgs({
    this.key,
    required this.pubName,
    this.packId,
  });

  final _i25.Key? key;

  final String pubName;

  final String? packId;

  @override
  String toString() {
    return 'EditStickerPacksRouteArgs{key: $key, pubName: $pubName, packId: $packId}';
  }
}

/// generated route for
/// [_i11.EditStickersScreen]
class EditStickersRoute extends _i24.PageRouteInfo<EditStickersRouteArgs> {
  EditStickersRoute({
    _i25.Key? key,
    required String packId,
    required String? id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         EditStickersRoute.name,
         args: EditStickersRouteArgs(key: key, packId: packId, id: id),
         rawPathParams: {'packId': packId, 'id': id},
         initialChildren: children,
       );

  static const String name = 'EditStickersRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditStickersRouteArgs>(
        orElse:
            () => EditStickersRouteArgs(
              packId: pathParams.getString('packId'),
              id: pathParams.optString('id'),
            ),
      );
      return _i11.EditStickersScreen(
        key: args.key,
        packId: args.packId,
        id: args.id,
      );
    },
  );
}

class EditStickersRouteArgs {
  const EditStickersRouteArgs({
    this.key,
    required this.packId,
    required this.id,
  });

  final _i25.Key? key;

  final String packId;

  final String? id;

  @override
  String toString() {
    return 'EditStickersRouteArgs{key: $key, packId: $packId, id: $id}';
  }
}

/// generated route for
/// [_i12.ExploreScreen]
class ExploreRoute extends _i24.PageRouteInfo<void> {
  const ExploreRoute({List<_i24.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i12.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i13.LoginScreen]
class LoginRoute extends _i24.PageRouteInfo<void> {
  const LoginRoute({List<_i24.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoginScreen();
    },
  );
}

/// generated route for
/// [_i8.ManagedPublisherScreen]
class ManagedPublisherRoute extends _i24.PageRouteInfo<void> {
  const ManagedPublisherRoute({List<_i24.PageRouteInfo>? children})
    : super(ManagedPublisherRoute.name, initialChildren: children);

  static const String name = 'ManagedPublisherRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i8.ManagedPublisherScreen();
    },
  );
}

/// generated route for
/// [_i14.MyselfEventCalendarScreen]
class MyselfEventCalendarRoute extends _i24.PageRouteInfo<void> {
  const MyselfEventCalendarRoute({List<_i24.PageRouteInfo>? children})
    : super(MyselfEventCalendarRoute.name, initialChildren: children);

  static const String name = 'MyselfEventCalendarRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i14.MyselfEventCalendarScreen();
    },
  );
}

/// generated route for
/// [_i15.MyselfProfileScreen]
class MyselfProfileRoute extends _i24.PageRouteInfo<void> {
  const MyselfProfileRoute({List<_i24.PageRouteInfo>? children})
    : super(MyselfProfileRoute.name, initialChildren: children);

  static const String name = 'MyselfProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i15.MyselfProfileScreen();
    },
  );
}

/// generated route for
/// [_i4.NewChatScreen]
class NewChatRoute extends _i24.PageRouteInfo<void> {
  const NewChatRoute({List<_i24.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i4.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i8.NewPublisherScreen]
class NewPublisherRoute extends _i24.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i24.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i8.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i9.NewRealmScreen]
class NewRealmRoute extends _i24.PageRouteInfo<void> {
  const NewRealmRoute({List<_i24.PageRouteInfo>? children})
    : super(NewRealmRoute.name, initialChildren: children);

  static const String name = 'NewRealmRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i9.NewRealmScreen();
    },
  );
}

/// generated route for
/// [_i10.NewStickerPacksScreen]
class NewStickerPacksRoute
    extends _i24.PageRouteInfo<NewStickerPacksRouteArgs> {
  NewStickerPacksRoute({
    _i25.Key? key,
    required String pubName,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         NewStickerPacksRoute.name,
         args: NewStickerPacksRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'name': pubName},
         initialChildren: children,
       );

  static const String name = 'NewStickerPacksRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NewStickerPacksRouteArgs>(
        orElse:
            () =>
                NewStickerPacksRouteArgs(pubName: pathParams.getString('name')),
      );
      return _i10.NewStickerPacksScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class NewStickerPacksRouteArgs {
  const NewStickerPacksRouteArgs({this.key, required this.pubName});

  final _i25.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'NewStickerPacksRouteArgs{key: $key, pubName: $pubName}';
  }
}

/// generated route for
/// [_i11.NewStickersScreen]
class NewStickersRoute extends _i24.PageRouteInfo<NewStickersRouteArgs> {
  NewStickersRoute({
    _i25.Key? key,
    required String packId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         NewStickersRoute.name,
         args: NewStickersRouteArgs(key: key, packId: packId),
         rawPathParams: {'packId': packId},
         initialChildren: children,
       );

  static const String name = 'NewStickersRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NewStickersRouteArgs>(
        orElse:
            () => NewStickersRouteArgs(packId: pathParams.getString('packId')),
      );
      return _i11.NewStickersScreen(key: args.key, packId: args.packId);
    },
  );
}

class NewStickersRouteArgs {
  const NewStickersRouteArgs({this.key, required this.packId});

  final _i25.Key? key;

  final String packId;

  @override
  String toString() {
    return 'NewStickersRouteArgs{key: $key, packId: $packId}';
  }
}

/// generated route for
/// [_i16.PostComposeScreen]
class PostComposeRoute extends _i24.PageRouteInfo<PostComposeRouteArgs> {
  PostComposeRoute({
    _i25.Key? key,
    _i26.SnPost? originalPost,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         PostComposeRoute.name,
         args: PostComposeRouteArgs(key: key, originalPost: originalPost),
         initialChildren: children,
       );

  static const String name = 'PostComposeRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostComposeRouteArgs>(
        orElse: () => const PostComposeRouteArgs(),
      );
      return _i16.PostComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
      );
    },
  );
}

class PostComposeRouteArgs {
  const PostComposeRouteArgs({this.key, this.originalPost});

  final _i25.Key? key;

  final _i26.SnPost? originalPost;

  @override
  String toString() {
    return 'PostComposeRouteArgs{key: $key, originalPost: $originalPost}';
  }
}

/// generated route for
/// [_i17.PostDetailScreen]
class PostDetailRoute extends _i24.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i25.Key? key,
    required String id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i17.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final String id;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i16.PostEditScreen]
class PostEditRoute extends _i24.PageRouteInfo<PostEditRouteArgs> {
  PostEditRoute({
    _i25.Key? key,
    required String id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         PostEditRoute.name,
         args: PostEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostEditRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostEditRouteArgs>(
        orElse: () => PostEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i16.PostEditScreen(key: args.key, id: args.id);
    },
  );
}

class PostEditRouteArgs {
  const PostEditRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final String id;

  @override
  String toString() {
    return 'PostEditRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i18.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i24.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i25.Key? key,
    required String name,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherProfileRouteArgs>(
        orElse:
            () => PublisherProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i18.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i25.Key? key;

  final String name;

  @override
  String toString() {
    return 'PublisherProfileRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i19.RealmDetailScreen]
class RealmDetailRoute extends _i24.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i25.Key? key,
    required String slug,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i19.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i25.Key? key;

  final String slug;

  @override
  String toString() {
    return 'RealmDetailRouteArgs{key: $key, slug: $slug}';
  }
}

/// generated route for
/// [_i9.RealmListScreen]
class RealmListRoute extends _i24.PageRouteInfo<void> {
  const RealmListRoute({List<_i24.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i9.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i20.SettingsScreen]
class SettingsRoute extends _i24.PageRouteInfo<void> {
  const SettingsRoute({List<_i24.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i20.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i11.StickerPackDetailScreen]
class StickerPackDetailRoute
    extends _i24.PageRouteInfo<StickerPackDetailRouteArgs> {
  StickerPackDetailRoute({
    _i25.Key? key,
    required String pubName,
    required String id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         StickerPackDetailRoute.name,
         args: StickerPackDetailRouteArgs(key: key, pubName: pubName, id: id),
         rawPathParams: {'name': pubName, 'packId': id},
         initialChildren: children,
       );

  static const String name = 'StickerPackDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickerPackDetailRouteArgs>(
        orElse:
            () => StickerPackDetailRouteArgs(
              pubName: pathParams.getString('name'),
              id: pathParams.getString('packId'),
            ),
      );
      return _i11.StickerPackDetailScreen(
        key: args.key,
        pubName: args.pubName,
        id: args.id,
      );
    },
  );
}

class StickerPackDetailRouteArgs {
  const StickerPackDetailRouteArgs({
    this.key,
    required this.pubName,
    required this.id,
  });

  final _i25.Key? key;

  final String pubName;

  final String id;

  @override
  String toString() {
    return 'StickerPackDetailRouteArgs{key: $key, pubName: $pubName, id: $id}';
  }
}

/// generated route for
/// [_i10.StickersScreen]
class StickersRoute extends _i24.PageRouteInfo<StickersRouteArgs> {
  StickersRoute({
    _i25.Key? key,
    required String pubName,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         StickersRoute.name,
         args: StickersRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'name': pubName},
         initialChildren: children,
       );

  static const String name = 'StickersRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickersRouteArgs>(
        orElse: () => StickersRouteArgs(pubName: pathParams.getString('name')),
      );
      return _i10.StickersScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class StickersRouteArgs {
  const StickersRouteArgs({this.key, required this.pubName});

  final _i25.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'StickersRouteArgs{key: $key, pubName: $pubName}';
  }
}

/// generated route for
/// [_i21.TabsScreen]
class TabsRoute extends _i24.PageRouteInfo<void> {
  const TabsRoute({List<_i24.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i21.TabsScreen();
    },
  );
}

/// generated route for
/// [_i22.UpdateProfileScreen]
class UpdateProfileRoute extends _i24.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i24.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i22.UpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i23.WalletScreen]
class WalletRoute extends _i24.PageRouteInfo<void> {
  const WalletRoute({List<_i24.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i23.WalletScreen();
    },
  );
}
